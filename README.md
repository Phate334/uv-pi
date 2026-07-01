# uv-pi

Docker image for running `@earendil-works/pi-coding-agent` with `uv` available in the same container.

When the container starts in `/workspace`, `docker-entrypoint.sh` runs `uv sync` if `pyproject.toml` exists. The image sets:

- `UV_PROJECT_ENVIRONMENT=/workspace/.venv`
- `VIRTUAL_ENV=/workspace/.venv`
- `PATH=/workspace/.venv/bin:$PATH`

This makes Python scripts and tools launched by pi prefer the virtual environment managed by `uv`.

## Run

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -v pi-agent-home:/root/.pi/agent \
  -e ANTHROPIC_API_KEY \
  ghcr.io/phate334/uv-pi:0.80.3
```

Replace the image tag with the pi agent version published by the GitHub Actions workflow.

## Publish

Run the `Publish uv-pi image` workflow manually and enter the pi agent version to install, for example `0.80.3`.

The workflow builds `linux/amd64` and `linux/arm64` separately, pushes both images by digest, and publishes a multi-arch manifest to:

```text
ghcr.io/phate334/uv-pi:<pi_agent_version>
```

## Third-party LLM providers

Pi supports several built-in providers through environment variables, for example `ANTHROPIC_API_KEY`, Azure OpenAI variables such as `AZURE_OPENAI_API_KEY` and `AZURE_OPENAI_BASE_URL`, AWS Bedrock variables, and Cloudflare variables.

For arbitrary OpenAI-compatible endpoints, pi documents `~/.pi/agent/models.json` as the supported configuration path. The values in `models.json` can reference environment variables with `$ENV_VAR` or `${ENV_VAR}` syntax:

```json
{
  "providers": {
    "custom-openai": {
      "baseUrl": "$OPENAI_BASE_URL",
      "api": "openai-completions",
      "apiKey": "$OPENAI_API_KEY",
      "authHeader": true,
      "models": [
        {
          "id": "my-model",
          "name": "My Model",
          "contextWindow": 128000,
          "maxTokens": 4096
        }
      ]
    }
  }
}
```

Then run pi with:

```bash
pi --provider custom-openai --model my-model
```

In short: API keys can often be environment variables directly; a generic OpenAI-compatible `baseUrl` and custom model name should be configured through `models.json` or a pi extension, with `models.json` allowed to read those values from environment variables.
