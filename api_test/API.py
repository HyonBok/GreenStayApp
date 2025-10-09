# api.py
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import sqlite3
from pathlib import Path

app = FastAPI(title="API Plantas")

# -----------------------
# Conexão com SQLite
# -----------------------
DB_PATH = Path(__file__).resolve().parent.parent / "database" / "greendb"

def get_db_connection():
    # usa um caminho absoluto baseado na localização do arquivo para evitar erros
    conn = sqlite3.connect(str(DB_PATH))
    conn.row_factory = sqlite3.Row
    return conn

# Modelo para criação de usuário
class UsuarioCreate(BaseModel):
    nome: str
    senha: str

# Modelo para criação de cliente
class ClienteCreate(BaseModel):
    nome: str
    usuarioId: int

# Modelo para criação de planta
class PlantaCreate(BaseModel):
    nome: str
    especie: str
    clienteId: int

# Modelo para criação de informação da planta
class PlantaInfoCreate(BaseModel):
    luminosidade: int
    temperatura: int
    umidade: int
    data: str
    plantaId: int

# GET - listar todos os usuários
@app.get("/usuarios")
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

# GET - listar todos os clientes
@app.get("/clientes")
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
@app.post("/cliente")
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
@app.get("/plantas")
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
@app.get("/plantas/{id_cliente}")
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
@app.post("/planta")
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
@app.get("/plantas-info")
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
@app.post("/plantas-info")
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


if __name__ == "__main__":
    # Permite executar o arquivo diretamente: python api_test\API.py
    try:
        import uvicorn
    except Exception:
        print("Uvicorn não está instalado. Instale com: pip install uvicorn[standard]")
        print("Ou execute o app com: python -m uvicorn api_test.API:app --reload")
    else:
        # Inicia o servidor passando a aplicação como import string — necessário para reload/workers
        # formato: "package.module:app_object"
        uvicorn.run("API:app", host="127.0.0.1", port=8000, reload=True)
