# api.py
from fastapi import APIRouter, HTTPException
from api_test.connection import get_db_connection
from api_test.models import *

router = APIRouter(
    prefix="/usuario",  # (Opcional) Adiciona um prefixo a todas as rotas deste arquivo
)

# GET - listar todos os usuários
@router.get("")
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
@router.post("")
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




