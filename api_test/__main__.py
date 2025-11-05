"""FastAPI application entry-point.

Render executes the project via ``uvicorn`` with the ``PORT`` environment
variable, so we expose the ``app`` object at module level and read the
runtime configuration from environment variables when the module is run as a
script.  This keeps local development straightforward (``python -m api_test``)
while matching Render's expectations.
"""

from __future__ import annotations

import os
from fastapi import FastAPI

from api_test.controllers import cliente, imagem, login, planta, plantaInfo, usuario

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
    except Exception:  # pragma: no cover - import error path for local usage
        print("Uvicorn não está instalado. Instale com: pip install uvicorn[standard]")
        print("Ou execute o app com: python -m uvicorn api_test.__main__:app --reload")
    else:
        host = os.getenv("HOST", "0.0.0.0")
        port = int(os.getenv("PORT", "8000"))
        uvicorn.run("api_test.__main__:app", host=host, port=port, reload=False)
