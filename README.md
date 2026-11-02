# uv-pi

A Docker image for [Pi Coding Agent](https://github.com/earendil-works/pi) with a Python environment managed by [uv](https://docs.astral.sh/uv/).

The image includes Node.js 24, Pi Coding Agent, `uv`, `uvx`, Git, ripgrep, curl, and Bash. When `/workspace/pyproject.toml` exists, the entrypoint runs `uv sync`; with `uv.lock`, it uses `uv sync --locked`.

## Docker

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -v uv-pi-venv:/workspace/.venv \
  -e OPENAI_API_KEY \
  ghcr.io/phate334/uv-pi:v1.5.0
```

## Docker Compose

Copy [`compose.yaml`](compose.yaml) into the project root, set `OPENAI_API_KEY`, then run:

```bash
mkdir -p .pi/agent
docker compose run --rm pi
```

The Compose file persists only the Linux virtual environment; the uv cache is ephemeral, so dependencies may be downloaded again when the container is recreated. Set `UV_PI_AUTO_SYNC=0` to manage the Python environment manually.

## OpenAI-compatible API

Pi loads custom providers from `.pi/agent/models.json`. The image sets `PI_CODING_AGENT_DIR=/workspace/.pi/agent`, so the project `.pi` directory is used directly. Create `.pi/agent/models.json` with a configuration like:

```json
{
  "providers": {
    "custom-openai": {
      "baseUrl": "https://api.example.com/v1",
      "api": "openai-completions",
      "apiKey": "$OPENAI_API_KEY",
      "authHeader": true,
      "compat": {
        "supportsDeveloperRole": false,
        "supportsReasoningEffort": false
      },
      "models": [
        {
          "id": "your-model",
          "name": "Your Model",
          "reasoning": false,
          "input": ["text"],
          "contextWindow": 32768,
          "maxTokens": 4096
        }
      ]
    }
  }
}
```

Replace `baseUrl` and the model fields with values from your API. Remove unsupported `compat` flags only when the server supports those request fields. Select the model with:

```bash
docker compose run --rm pi --model custom-openai/your-model
```

See Pi's [custom models documentation](https://pi.dev/docs/latest/models) for the full provider and compatibility reference.
