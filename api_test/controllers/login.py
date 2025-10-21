# api.py
from fastapi import APIRouter, HTTPException
from api_test.connection import get_db_connection
from api_test.models import *

router = APIRouter(
    prefix="/login",
    tags=["login"]
)

# POST - logar um usuário
@router.post("/")
def logar_usuario(usuario: Usuario):
    conn = get_db_connection()
    try:
        user = conn.execute("SELECT * FROM Usuario WHERE Nome = ? AND Senha = ? LIMIT 1", 
                            (usuario.nome, usuario.senha)).fetchone()
        if not user:
            raise HTTPException(status_code=401, detail="Usuário ou senha inválidos")
    except HTTPException:
        # re-lança HTTPException sem alterá-la
        raise
    except Exception as e:
        # qualquer outro erro vira erro 500
        raise HTTPException(status_code=500, detail=f"Erro interno: {e}")
    finally:
        conn.close()

    return {
        "message": "Login realizado com sucesso",
        "user": {
            "id": user["ID"],
        }
    }
