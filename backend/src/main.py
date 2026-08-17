import logging
from typing import override

import uvicorn
from fastapi import FastAPI

from .routes import router

app = FastAPI()


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
