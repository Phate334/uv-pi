# uv-pi

A Docker image for running [Pi Coding Agent](https://github.com/earendil-works/pi) with a Python environment managed by [uv](https://docs.astral.sh/uv/).

The image includes:

- Node.js 24
- Pi Coding Agent
- `uv` and `uvx`
- Git, ripgrep, curl, and Bash

When `/workspace/pyproject.toml` exists, the container runs `uv sync` before starting Pi. If `uv.lock` exists, it uses `uv sync --locked`.

## Docker

Run Pi inside the current project:

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -v uv-pi-venv:/workspace/.venv \
  -v uv-pi-cache:/root/.cache/uv \
  -v "$PWD/.pi:/root/.pi" \
  -e ANTHROPIC_API_KEY \
  ghcr.io/phate334/uv-pi:0.80.6
```

The project is mounted at `/workspace`. Python commands executed by Pi use the environment at `/workspace/.venv`.

To run another command instead of Pi:

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  ghcr.io/phate334/uv-pi:0.80.6 \
  uv run pytest
```

## Docker Compose

Copy `compose.yaml` into the root of your project, then run:

```bash
mkdir -p .pi
docker compose run --rm pi
```

Recommended volume configuration:

```yaml
services:
  pi:
    image: ghcr.io/phate334/uv-pi:0.80.6
    stdin_open: true
    tty: true
    working_dir: /workspace
    volumes:
      - .:/workspace
      - uv-pi-venv:/workspace/.venv
      - uv-pi-cache:/root/.cache/uv
      - ./.pi:/root/.pi

volumes:
  uv-pi-venv:
  uv-pi-cache:
```

The volumes keep the Linux virtual environment and uv download cache outside the host project.

## Authentication

Pass the environment variables required by your LLM provider:

```yaml
services:
  pi:
    environment:
      ANTHROPIC_API_KEY: ${ANTHROPIC_API_KEY}
```

Pi settings, authentication, and sessions are stored under `/root/.pi`.

For custom OpenAI-compatible endpoints, configure:

```text
.pi/agent/models.json
```

## Disable automatic sync

To manage the Python environment manually:

```yaml
services:
  pi:
    environment:
      UV_PI_AUTO_SYNC: "0"
```

You can then run commands such as:

```bash
docker compose run --rm pi uv sync
docker compose run --rm pi uv add pytest
```
