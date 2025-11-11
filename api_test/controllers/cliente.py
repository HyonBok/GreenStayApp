from fastapi import APIRouter, HTTPException

from api_test.connection import get_db_connection
from api_test.models import ClienteCreate

router = APIRouter(
    prefix="/clientes",
)


@router.get("")
def listar_clientes():
    conn = get_db_connection()
    try:
        clientes = conn.execute("SELECT * FROM Cliente").fetchall()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar clientes. Erro: {e}")
    finally:
        conn.close()

    return [dict(u) for u in clientes]


@router.get("/usuario/{id_usuario}")
def listar_clientes_usuario(id_usuario: int):
    conn = get_db_connection()
    try:
        clientes = conn.execute(
            "SELECT * FROM Cliente WHERE Usuario = ?",
            (id_usuario,),
        ).fetchall()
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Erro ao listar clientes do usuário {id_usuario}. Erro: {e}",
        )
    finally:
        conn.close()

    return [dict(u) for u in clientes]


@router.post("", status_code=201)
def criar_cliente(cliente: ClienteCreate):
    conn = get_db_connection()

    try:
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO Cliente (Nome, Usuario) VALUES (?, ?)",
            (cliente.nome, cliente.usuarioId),
        )
        conn.commit()
        novo_id = cursor.lastrowid
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Erro ao criar cliente. Erro: {e}")
    finally:
        conn.close()

    return {"id": novo_id, "nome": cliente.nome, "usuarioId": cliente.usuarioId}


@router.delete("/{cliente_id}")
def deletar_cliente(cliente_id: int, cascade: bool = False):
    conn = get_db_connection()

    try:
        cursor = conn.cursor()

        cliente = cursor.execute(
            "SELECT ID FROM Cliente WHERE ID = ?",
            (cliente_id,),
        ).fetchone()

        if not cliente:
            raise HTTPException(status_code=404, detail="Cliente não encontrado.")

        plantas = cursor.execute(
            "SELECT ID FROM Planta WHERE Cliente = ?",
            (cliente_id,),
        ).fetchall()

        plantas_ids = [row["ID"] for row in plantas]

        if plantas_ids and not cascade:
            raise HTTPException(
                status_code=409,
                detail={
                    "code": "CLIENT_HAS_PLANTS",
                    "message": "Existem plantas vinculadas a este cliente.",
                    "plantCount": len(plantas_ids),
                },
            )

        if plantas_ids:
            cursor.executemany(
                "DELETE FROM PlantaInfo WHERE Planta = ?",
                [(planta_id,) for planta_id in plantas_ids],
            )
            cursor.execute(
                "DELETE FROM Planta WHERE Cliente = ?",
                (cliente_id,),
            )

        cursor.execute(
            "DELETE FROM Cliente WHERE ID = ?",
            (cliente_id,),
        )
        conn.commit()
    except HTTPException:
        conn.rollback()
        raise
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Erro ao excluir cliente. Erro: {e}")
    finally:
        conn.close()

    return {"deleted": True, "cascade": cascade, "removedPlants": len(plantas_ids)}
