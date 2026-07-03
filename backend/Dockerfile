FROM registry.access.redhat.com/hi/python:3.14-builder AS builder

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /usr/local/bin/

ENV UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    UV_NO_DEV=1 \
    UV_PYTHON_DOWNLOADS=0 \
    UV_CACHE_DIR=/tmp/.cache/uv

USER root
WORKDIR /app
RUN --mount=type=cache,target=/tmp/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --locked --no-install-project
COPY . /app
RUN --mount=type=cache,target=/tmp/.cache/uv \
    uv sync --locked


# Then, use a final image without uv
FROM registry.access.redhat.com/hi/python:3.14

WORKDIR /app

# Copy the application from the builder
COPY --from=builder --chown=65532:0 /app /app

# Place executables in the environment at the front of the path
ENV PATH="/app/.venv/bin:$PATH"

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD ["python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"]

# Run the FastAPI application by default
CMD ["python", "-m", "src.main"]
