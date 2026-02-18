# AI Assistants Container

A container image (Node.js-based) that bundles several terminal AI coding assistant CLIs and is published to GitHub Container Registry (GHCR).

## Features

Included CLIs (installed globally via npm):
- **codex**: OpenAI Codex CLI (`@openai/codex`)
- **gemini**: Google Gemini CLI (`@google/gemini-cli`)
- **opencode**: OpenCode CLI (`opencode-ai`)
- **crush**: Charm Crush (`@charmland/crush`)

## Quickstart (Local)

Pull the pre-built image:

```bash
docker pull ghcr.io/zonca/ai_assistants_container:latest
```

Run an interactive shell:

```bash
docker run --rm -it ghcr.io/zonca/ai_assistants_container:latest /bin/bash
```

Run the smoke test (verifies the CLIs exist and prints versions):

```bash
docker run --rm ghcr.io/zonca/ai_assistants_container:latest /app/test_versions.sh
```

Podman works the same way (`podman pull`, `podman run`).

## Building the Container

```bash
docker build -f Containerfile -t ai-assistants-container:test .
```

## Using on Perlmutter (NERSC)

Perlmutter supports `podman-hpc`, which can pull OCI images and run them inside interactive or batch jobs.

1. Pull the image (login node is fine):

   ```bash
   podman-hpc pull ghcr.io/zonca/ai_assistants_container:latest
   ```

2. Run interactively on a compute node:

   ```bash
   salloc -N 1 -q interactive -t 00:30:00
   podman-hpc run --rm -it ghcr.io/zonca/ai_assistants_container:latest /bin/bash
   ```

3. Run the smoke test in a batch job (example):

   ```bash
   #!/bin/bash
   #SBATCH -N 1
   #SBATCH -q regular
   #SBATCH -t 00:05:00

   podman-hpc run --rm ghcr.io/zonca/ai_assistants_container:latest /app/test_versions.sh
   ```

Notes:
- If you need to access files from `$SCRATCH`/`$PWD`, mount them with standard Podman flags (example: `-v "$PWD:/work" -w /work`).
- Each CLI has its own authentication/config; pass env vars with `-e ...` and/or mount your config directory as needed.

## GitHub Actions CI/CD

`.github/workflows/build-container.yml` builds the image with Podman, runs `/app/test_versions.sh`, and pushes tags to `ghcr.io/zonca/ai_assistants_container`.

Tags include:
- `latest` on the default branch
- `pr-<n>` for pull requests
- `sha-<shortsha>` for commit SHA tags

## License

See [LICENSE](LICENSE) file for details.
