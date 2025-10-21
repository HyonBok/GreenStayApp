# api.py
from fastapi import APIRouter, HTTPException
from api_test.connection import get_db_connection
from api_test.models import *

router = APIRouter(
    prefix="/plantas",  # (Opcional) Adiciona um prefixo a todas as rotas deste arquivo
)

# GET - listar todas as plantas
@router.get("")
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
@router.get("/{id_cliente}")
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
@router.post("")
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
