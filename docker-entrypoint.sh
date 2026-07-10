#!/usr/bin/env bash
set -euo pipefail

if [[ "${UV_PI_AUTO_SYNC:-1}" == "1" && -f pyproject.toml ]]; then
    sync_args=()

    if [[ -f uv.lock ]]; then
        sync_args+=(--locked)
    fi

    uv sync "${sync_args[@]}"
fi

if [[ $# -eq 0 || "${1#-}" != "$1" ]]; then
    set -- pi "$@"
fi

exec "$@"