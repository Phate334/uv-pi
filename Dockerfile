ARG NODE_VERSION=24.22.2
ARG UV_VERSION=0.13.6

FROM ghcr.io/astral-sh/uv:${UV_VERSION} AS uv

FROM node:${NODE_VERSION}-trixie-slim

ARG PI_AGENT_VERSION=1.5.0

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        curl \
        git \
        ripgrep \
    && rm -rf /var/lib/apt/lists/*

COPY --from=uv /uv /uvx /usr/local/bin/

RUN npm install -g --ignore-scripts \
        "@earendil-works/pi-coding-agent@${PI_AGENT_VERSION}" \
    && npm cache clean --force

ENV UV_PROJECT_ENVIRONMENT=/workspace/.venv \
    VIRTUAL_ENV=/workspace/.venv \
    PI_CODING_AGENT_DIR=/workspace/.pi/agent \
    PATH=/workspace/.venv/bin:$PATH

COPY --chmod=755 docker-entrypoint.sh \
    /usr/local/bin/docker-entrypoint.sh

WORKDIR /workspace

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["pi"]
