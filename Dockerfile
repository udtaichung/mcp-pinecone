# 使用已內建 uv 的 Python 3.12 slim 映像作為 build 階段
FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim AS uv

WORKDIR /app

# 複製專案碼
ADD . /app

ENV UV_COMPILE_BYTECODE=1
ENV UV_LINK_MODE=copy

# 同步並安裝依賴（無開發依賴）
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=bind,source=uv.lock,target=uv.lock \
    --mount=type=bind,source=pyproject.toml,target=pyproject.toml \
    uv sync --frozen --no-install-project --no-dev --no-editable

RUN --mount=type=cache,target=/root/.cache/uv uv sync --frozen --no-dev --no-editable


FROM python:3.12-slim-bookworm

WORKDIR /app

# 只複製虛擬環境即可
COPY --from=uv --chown=app:app /app/.venv /app/.venv

ENV PATH="/app/.venv/bin:$PATH"

ENTRYPOINT ["uv", "run", "mcp-pinecone"]
