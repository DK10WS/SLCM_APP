import logging
from typing import override

import uvicorn
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from httpx import HTTPStatusError

from .routes import router

app = FastAPI()


@app.exception_handler(HTTPStatusError)
async def upstream_error(_: Request, exc: HTTPStatusError) -> JSONResponse:
    # SLCM redirects to the login page when a session dies, that's a 401 not a 500
    if exc.response.is_redirect:
        return JSONResponse({"detail": "Session expired"}, status_code=401)
    raise exc


class _HealthAccessLogFilter(logging.Filter):
    @override
    def filter(self, record: logging.LogRecord) -> bool:
        return "/health" not in record.getMessage()


logging.getLogger("uvicorn.access").addFilter(_HealthAccessLogFilter())


@app.get("/health")
async def status():
    return {"message": "OK"}


app.include_router(router, prefix="/api")

if __name__ == "__main__":
    uvicorn.run("src.main:app", host="0.0.0.0", port=8000)
