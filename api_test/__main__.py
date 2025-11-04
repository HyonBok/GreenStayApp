from fastapi import FastAPI
from api_test.controllers import cliente, login, planta, plantaInfo, usuario, imagem

app = FastAPI(title="API Plantas")

app.include_router(login.router)
app.include_router(usuario.router)
app.include_router(cliente.router)
app.include_router(planta.router)
app.include_router(plantaInfo.router)
app.include_router(imagem.router)

if __name__ == "__main__":
    try:
        import uvicorn
    except Exception:
        print("Uvicorn não está instalado. Instale com: pip install uvicorn[standard]")
        print("Ou execute o app com: python -m uvicorn api_test.__main__:app --reload")
    else:
        # Inicia o servidor passando a aplicação como import string — necessário para reload/workers
        # formato: "package.module:app_object"
        uvicorn.run("api_test.__main__:app", host="127.0.0.1", port=8000, reload=True)
