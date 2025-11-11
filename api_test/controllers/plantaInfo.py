from fastapi import APIRouter, HTTPException

from api_test.connection import get_db_connection
from api_test.models import PlantaInfoCreate

router = APIRouter(
    prefix="/plantas-info",
)


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


@router.get("/planta/{id_planta}")
def listar_info_planta(id_planta: int):
    conn = get_db_connection()
    try:
        query = (
            "SELECT PI.ID, PI.Luminosidade, PI.Temperatura, PI.Umidade, PI.Data, PI.Planta "
            "FROM PlantaInfo PI WHERE PI.Planta = ? ORDER BY PI.Data DESC, PI.ID DESC LIMIT 5"
        )
        plantas_info = conn.execute(query, (id_planta,)).fetchall()
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Erro ao listar informações da planta {id_planta}. Erro: {e}",
        )
    finally:
        conn.close()

    return [dict(u) for u in plantas_info]


@router.post("", status_code=201)
def criar_plantas_info(plantaInfo: PlantaInfoCreate):
    conn = get_db_connection()

    try:
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO PlantaInfo (Luminosidade, Temperatura, Umidade, Data, Planta) VALUES (?, ?, ?, ?, ?)",
            (plantaInfo.luminosidade, plantaInfo.temperatura, plantaInfo.umidade, plantaInfo.data, plantaInfo.plantaId),
        )
        conn.commit()
        novo_id = cursor.lastrowid
    except Exception as e:
        conn.rollback()
        raise HTTPException(status_code=500, detail=f"Erro ao criar informação da planta. Erro: {e}")
    finally:
        conn.close()

    return {
        "id": novo_id,
        "luminosidade": plantaInfo.luminosidade,
        "temperatura": plantaInfo.temperatura,
        "umidade": plantaInfo.umidade,
        "data": plantaInfo.data,
        "plantaId": plantaInfo.plantaId,
    }
