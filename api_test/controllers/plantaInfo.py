from fastapi import APIRouter, HTTPException
from api_test.connection import get_db_connection
from api_test.models import *

router = APIRouter(
    prefix="/plantas-info",  # (Opcional) Adiciona um prefixo a todas as rotas deste arquivo
)

# GET - listar todas as infomações das plantas
@router.get("")
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
@router.post("")
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
