# uv-pi

Docker image for running `@earendil-works/pi-coding-agent` with `uv`.

On startup, the image runs `uv sync --no-install-project` when `/workspace/pyproject.toml` exists, then starts `pi`. Python tools launched by pi use `/workspace/.venv` through:

- `UV_PROJECT_ENVIRONMENT=/workspace/.venv`
- `VIRTUAL_ENV=/workspace/.venv`
- `PATH=/workspace/.venv/bin:$PATH`

## Run

```bash
docker run --rm -it \
  -v "$PWD:/workspace" \
  -v pi-agent-home:/root/.pi/agent \
  -e ANTHROPIC_API_KEY \
  ghcr.io/phate334/uv-pi:0.80.3
```

Replace the image tag with the pi agent version published by the GitHub Actions workflow.

## Compose

`compose.yaml` runs the published image, mounts local pi state from `./.pi`, and installs dependencies from `pyproject.toml` into a persistent `.venv` volume:

```bash
mkdir -p .pi
docker compose run --rm pi
```

The included [./.pi/agent/models.json](./.pi/agent/models.json) points pi at the `llm` service through `http://llm:8080/v1`.

After the `llm` service is healthy, test pi against it with:

```bash
docker compose run --rm pi pi --print --model custom-openai/gemma-4-e2b "Reply with exactly: pi-ok"
```

## Publish

Run the `Publish uv-pi image` workflow manually and enter the pi agent version to install, for example `0.80.3`.

The workflow builds `linux/amd64` and `linux/arm64` separately, pushes both images by digest, and publishes a multi-arch manifest to:

```text
ghcr.io/phate334/uv-pi:<pi_agent_version>
```

## Third-party LLM providers

Built-in providers can use their documented environment variables, such as `ANTHROPIC_API_KEY`, Azure OpenAI, AWS Bedrock, and Cloudflare variables. For arbitrary OpenAI-compatible endpoints, configure `~/.pi/agent/models.json`; this repo includes that file under [./.pi/agent/models.json](./.pi/agent/models.json).
