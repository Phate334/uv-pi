#!/usr/bin/env bash
set -euo pipefail

if [[ -f pyproject.toml ]]; then
  uv sync
fi

exec "$@"