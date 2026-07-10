#!/usr/bin/env bash
set -euo pipefail

if [[ -f pyproject.toml ]]; then
    sync_args=()

    if [[ -f uv.lock ]]; then
        sync_args+=(--locked)
    fi

    # src layout 專案需要安裝自身，才能正常 import package。
    if [[ ! -d src ]]; then
        sync_args+=(--no-install-project)
    fi

    uv sync "${sync_args[@]}"
fi

if [[ $# -eq 0 || "${1#-}" != "$1" ]]; then
    set -- pi "$@"
fi

exec "$@"