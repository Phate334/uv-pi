#!/usr/bin/env bash
set -euo pipefail

if [[ -f pyproject.toml ]]; then
  uv sync --no-install-project
fi

if [[ $# -eq 0 || "${1#-}" != "$1" ]]; then
  set -- pi "$@"
fi

exec "$@"