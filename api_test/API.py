# api.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import sqlite3

app = FastAPI(title="API Plantas")

# -----------------------
# Conexão com SQLite
# -----------------------
def get_db_connection():
    conn = sqlite3.connect("../database/greendb")
    conn.row_factory = sqlite3.Row
    return conn

# -----------------------
# Modelo para criação de usuário
# -----------------------
class UsuarioCreate(BaseModel):
    nome: str
    senha: str

# -----------------------
# GET - listar todos os usuários
# -----------------------
@app.get("/usuarios")
def listar_usuarios():
    conn = get_db_connection()
    try:
        usuarios = conn.execute("SELECT ID, Nome FROM Usuario").fetchall()
    except Exception as e:
        raise HTTPException(status_code=500, detail="Erro ao listar usuários. Erro: " + str(e))
    finally:
        conn.close()

    return [dict(u) for u in usuarios]

# -----------------------
# POST - criar um novo usuário
# -----------------------
@app.post("/usuario")
def criar_usuario(usuario: UsuarioCreate):
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
