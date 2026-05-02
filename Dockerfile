FROM ghcr.io/astral-sh/uv:python3.13-bookworm-slim AS builder
ENV UV_CACHE_DIR=/tmp/.cache/uv
WORKDIR /app

COPY pyproject.toml uv.lock ./
# or with --extra <EXTRA>
RUN --mount=type=cache,target=${UV_CACHE_DIR} \
    uv export --frozen --no-dev --all-extras --no-annotate --no-header --no-hashes --no-editable --no-emit-project -o requirements.txt

COPY pile_o_bananas .
RUN --mount=type=cache,target=${UV_CACHE_DIR} \
    uv build --wheel




FROM python:3.13-slim AS runner
ENV PIP_CACHE_DIR=/tmp/.cache/pip
WORKDIR /app

COPY --from=builder /app/requirements.txt .
RUN --mount=type=cache,target=${PIP_CACHE_DIR} \
    pip install -r requirements.txt

COPY --from=builder /app/dist/*.whl .
RUN --mount=type=cache,target=${PIP_CACHE_DIR} \
    pip install *.whl

ENTRYPOINT ["cast"]
