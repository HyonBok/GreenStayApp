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
@router.get("/cliente/{id_cliente}")
def listar_plantas_cliente(id_cliente: int):
    conn = get_db_connection()
    try:
        plantas = conn.execute("SELECT * FROM Planta WHERE Cliente = ?", (id_cliente,)).fetchall()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar plantas do cliente {id_cliente}. Erro: {e}")
    finally:
        conn.close()

    return [dict(u) for u in plantas]

# GET - listar plantas de um usuário
@router.get("/usuario/{id_usuario}")
def listar_plantas_usuario(id_usuario: int):
    conn = get_db_connection()
    try:
        plantas = conn.execute("SELECT P.Id, P.Nome As NomePlanta, P.Especie, C.Nome As NomeCliente FROM Planta P INNER JOIN Cliente C ON P.Cliente = C.ID WHERE C.Usuario = ?", (id_usuario,)).fetchall()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao listar plantas do cliente {id_usuario}. Erro: {e}")
    finally:
        conn.close()

    return [dict(u) for u in plantas]

# GET - listar planta ativa
@router.get("/ativo/{id_ativo}")
def planta_ativo(id_ativo: int):
    conn = get_db_connection()
    try:
        planta = conn.execute("SELECT P.Id, P.TemperaturaIdeal, P.LuminosidadeIdeal, P.UmidadeIdeal FROM Planta P WHERE ATIVO = ?", (id_ativo,)).fetchall()
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Erro ao verificar planta ativa do módulo {id_ativo}. Erro: {e}")
    finally:
        conn.close()

    return planta

# POST - criar uma nova planta 
@router.post("")
def planta_criar(planta: PlantaCreate):
    conn = get_db_connection()

    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO Planta (Nome, Especie, Cliente, UmidadeIdeal, LuminosidadeIdeal, TemperaturaIdeal, Imagem64) VALUES (?, ?, ?, ?, ?, ?, ?)",
        (planta.nome, planta.especie, planta.clienteId, planta.umidade, planta.luminosidade, planta.temperatura, planta.base64)
    )
    conn.commit()
    novo_id = cursor.lastrowid
    conn.close()

    return {"id": novo_id, "nome": planta.nome, "especie": planta.especie}

# POST - colocar planta ativa
@router.post("/ativar")
def planta_ativar(plantaAtivar: PlantaAtivar):
    conn = get_db_connection()

    conn.execute(
                """
                UPDATE Planta
                SET Ativo = CASE
                    WHEN Id = ? THEN ?
                    WHEN Ativo = ? THEN 0
                    ELSE Ativo
                END;
                """, 
                (plantaAtivar.plantaId, plantaAtivar.moduloId, plantaAtivar.moduloId))
    conn.commit()

    conn.close()

    return plantaAtivar.plantaId
    
