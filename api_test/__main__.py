# api.py
from fastapi import FastAPI
from api_test.controllers import login, usuario

app = FastAPI(title="API Plantas")

app.include_router(login.router)
app.include_router(usuario.router)

if __name__ == "__main__":
    # Permite executar o arquivo diretamente: python api_test\API.py
    try:
        import uvicorn
    except Exception:
        print("Uvicorn não está instalado. Instale com: pip install uvicorn[standard]")
        print("Ou execute o app com: python -m uvicorn api_test.__main__:app --reload")
    else:
        # Inicia o servidor passando a aplicação como import string — necessário para reload/workers
        # formato: "package.module:app_object"
        uvicorn.run("api_test.__main__:app", host="127.0.0.1", port=8000, reload=True)
