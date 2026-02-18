# AI Assistants Container

A lightweight container image based on Node.js 24 that provides a foundation for terminal-based AI coding assistants.

## Features

This container is designed to include the following terminal-based AI coding assistants:
- **codex**: OpenAI Codex CLI (`@openai/codex`)
- **gemini**: Google Gemini CLI (`@google/gemini-cli`)
- **opencode**: OpenCode CLI (`opencode-ai`)
- **crush**: Charm Crush (`@charmland/crush`)

## Base Image

This container is based on the official `node:24-slim` image, providing:
- Node.js 24 (latest LTS version)
- npm package manager
- Lightweight Debian-based system
- Python 3 and pip (for Python-based CLI tools)
- Git and curl for development workflows

## Building the Container

### Using Podman (locally)
```bash
podman build -f Containerfile -t ai-assistants-container .
```

### Using Docker (locally)
```bash
docker build -f Containerfile -t ai-assistants-container .
```

## Running the Container

```bash
# Run interactively
podman run -it ai-assistants-container /bin/bash

# Run the version test script
podman run --rm ai-assistants-container /app/test_versions.sh
```

## Testing

The container includes a test script (`test_versions.sh`) that verifies all installed tools and prints their versions:

```bash
podman run --rm ai-assistants-container /app/test_versions.sh
```

## GitHub Actions CI/CD

This repository includes a GitHub Actions workflow (`.github/workflows/build-container.yml`) that:
1. Builds the container using podman-hpc (NERSC's podman action)
2. Runs the test suite to verify all tools are functional
3. Pushes the container image to GitHub Container Registry (ghcr.io)

The workflow is triggered on:
- Push to main/master branch
- Pull requests to main/master branch
- Manual workflow dispatch

## Pulling the Pre-built Image

Once the GitHub Action has run, you can pull the pre-built image:

```bash
podman pull ghcr.io/zonca/ai_assistants_container:latest
```

## License

See [LICENSE](LICENSE) file for details.
