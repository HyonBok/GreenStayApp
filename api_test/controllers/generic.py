# api.py
from fastapi import APIRouter, HTTPException
from api_test.connection import get_db_connection
from api_test.models import *

router = APIRouter(
    prefix="",  # (Opcional) Adiciona um prefixo a todas as rotas deste arquivo
)

# GET - listar todos os usuários
@router.get("/usuarios")
def listar_usuarios():
    conn = get_db_connection()
    try:
        usuarios = conn.execute("SELECT * FROM Usuario").fetchall()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar usuarios. Erro: {e}")
    finally:
        conn.close()

    return [dict(u) for u in usuarios]

# POST - criar um novo usuário
@router.post("/usuario")
def criar_usuario(usuario: Usuario):
    conn = get_db_connection()

    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO Usuario (Nome, Senha) VALUES (?, ?)",
        (usuario.nome, usuario.senha)
    )
    conn.commit()
    novo_id = cursor.lastrowid
    conn.close()

    return {"id": novo_id, "nome": usuario.nome}

# GET - listar todos os clientes
@router.get("/clientes")
def listar_clientes():
    conn = get_db_connection()
    try:
        clientes = conn.execute("SELECT * FROM Cliente").fetchall()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar clientes. Erro: {e}")
    finally:
        conn.close()

    return [dict(u) for u in clientes]

# POST - criar um novo cliente
@router.post("/cliente")
def criar_cliente(cliente: ClienteCreate):
    conn = get_db_connection()

    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO Cliente (Nome, Usuario) VALUES (?, ?)",
        (cliente.nome, cliente.usuarioId)
    )
    conn.commit()
    novo_id = cursor.lastrowid
    conn.close()

    return {"id": novo_id, "nome": cliente.nome}

# GET - listar todas as plantas
@router.get("/plantas")
def listar_plantas():
    conn = get_db_connection()
    try:
        plantas = conn.execute("SELECT * FROM Planta").fetchall()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar plantas. Erro: {e}")
    finally:
        conn.close()

    return [dict(u) for u in plantas]

# GET - listar plantas de um cliente
@router.get("/plantas/{id_cliente}")
def listar_plantas_cliente(id_cliente: int):
    conn = get_db_connection()
    try:
        plantas = conn.execute("SELECT * FROM Planta WHERE Cliente = ?", (id_cliente,)).fetchall()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar plantas do cliente {id_cliente}. Erro: {e}")
    finally:
        conn.close()

    return [dict(u) for u in plantas]

# POST - criar uma nova planta 
@router.post("/planta")
def criar_planta(planta: PlantaCreate):
    conn = get_db_connection()

    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO Planta (Nome, Especie, Cliente) VALUES (?, ?, ?)",
        (planta.nome, planta.especie, planta.clienteId)
    )
    conn.commit()
    novo_id = cursor.lastrowid
    conn.close()

    return {"id": novo_id, "nome": planta.nome, "especie": planta.especie}

# GET - listar todas as infomações das plantas
@router.get("/plantas-info")
def listar_plantas_info():
    conn = get_db_connection()
    try:
        plantasInfo = conn.execute("SELECT * FROM PlantaInfo").fetchall()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar informações das plantas. Erro: {e}")
    finally:
        conn.close()

    return [dict(u) for u in plantasInfo]

# POST - criar uma nova informação da planta
@router.post("/plantas-info")
def criar_plantas_info(plantaInfo: PlantaInfoCreate):
    conn = get_db_connection()

    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO PlantaInfo (Luminosidade, Temperatura, Umidade, Data, Planta) VALUES (?, ?, ?, ?, ?)",
        (plantaInfo.luminosidade, plantaInfo.temperatura, plantaInfo.umidade, plantaInfo.data, plantaInfo.plantaId)
    )
    conn.commit()
    novo_id = cursor.lastrowid
    conn.close()

    return {"id": novo_id, "luminosidade": plantaInfo.luminosidade, "temperatura": plantaInfo.temperatura, "umidade": plantaInfo.umidade, "data": plantaInfo.data, "plantaId": plantaInfo.plantaId}
