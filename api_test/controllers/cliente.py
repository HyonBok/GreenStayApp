# api.py
from fastapi import APIRouter, HTTPException
from api_test.connection import get_db_connection
from api_test.models import *

router = APIRouter(
    prefix="/clientes",  # (Opcional) Adiciona um prefixo a todas as rotas deste arquivo
)

# GET - listar todos os clientes
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

# POST - criar um novo cliente
@router.post("")
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