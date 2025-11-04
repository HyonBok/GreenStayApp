# api.py
import base64
from fastapi import APIRouter, HTTPException, File, UploadFile
from api_test.connection import get_db_connection
from api_test.models import *
from typing import Optional
import openai
from dotenv import load_dotenv
import json

router = APIRouter(
    prefix="/imagem",
    tags=["imagem"]
)

load_dotenv()
client = openai.OpenAI()

class IAResponse(BaseModel):
    nome_popular: Optional[str] = None
    nome_cientifico: str
    especie: Optional[str] = None
    umidade_ideal: Optional[float] = None
    luminosidade_ideal: Optional[float] = None
    temperatura_ideal: Optional[float]= None
    confianca: float 

@router.post("", response_model=IAResponse) 
async def identificar_planta(file: UploadFile = File(...)):
    contents = await file.read()
    img_base64 = base64.b64encode(contents).decode("utf-8")
    img_url_base64 = f"data:image/jpeg;base64,{img_base64}"

    system_prompt = """
    Você é um assistente botânico especialista. 
    Analise a imagem da planta fornecida e retorne APENAS um objeto JSON 
    válido com a seguinte estrutura:
    
    {
      "nome_popular": "Nome popular (ou 'Desconhecido' se não souber)",
      "nome_cientifico": "Nome científico (ou 'Desconhecido' se não souber)",
      "especie": "Espécie (ou 'Desconhecido' se não souber)",
      "umidade_ideal": 0.0,
      "luminosidade_ideal": 0.0,
      "temperatura_ideal":0.0,
      "confianca": 0.0 
    }

    Preencha os valores de umidade (em %), luminosidade (em lux) e temperatura em graus celsius com
    médias ideais conhecidas para essa planta. 
    Preencha 'confianca' com um valor de 0.0 a 1.0 indicando 
    o quão certo você está da identificação.
    """

    try:
        response = client.chat.completions.create(
            model="gpt-4o",
            response_format={ "type": "json_object" }, 
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": [
                    {"type": "text", "text": "Analise esta imagem e retorne o JSON formatado."},
                    {"type": "image_url", "image_url": {"url": img_url_base64}}
                ]}
            ]
        )
        json_string_resposta = response.choices[0].message.content
        print(f"Resposta da IA recebida: {json_string_resposta}")
        dados_ia = json.loads(json_string_resposta)
        return IAResponse(**dados_ia)

    except openai.APIConnectionError as e:
        print("Erro ao conectar na OpenAI:", e)
        raise HTTPException(status_code=503, detail="Não foi possível conectar à API de IA.")
    except openai.RateLimitError as e:
        print("Erro de limite de taxa:", e)
        raise HTTPException(status_code=429, detail="Limite de requisições para a IA excedido.")
    except Exception as e:
        print(f"Erro inesperado na IA: {e}")
        raise HTTPException(status_code=500, detail=f"Erro interno no processamento da IA: {str(e)}")