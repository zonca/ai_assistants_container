# Repository Guidelines

This repository defines a container image for terminal-based AI coding assistants and a GitHub Actions workflow that builds, tests, and publishes it to GHCR.

## Project Structure & Module Organization

- `Containerfile`: image definition (Node base + system deps + global CLI installs).
- `test_versions.sh`: smoke test that verifies expected CLIs exist and prints versions; exits non-zero on missing tools.
- `.github/workflows/build-container.yml`: CI workflow (build, run `test_versions.sh`, tag, push to `ghcr.io`).
- `.dockerignore`, `README.md`, `LICENSE`: repo metadata and docs.

There is no application "src/" tree; changes are mostly to container build logic and CI.

## Build, Test, and Development Commands

- Build locally (Docker):
  - `docker build -f Containerfile -t ai-assistants-container:test .`
- Build locally (Podman):
  - `podman build -f Containerfile -t ai-assistants-container:test .`
- Run smoke tests in the image:
  - `docker run --rm ai-assistants-container:test /app/test_versions.sh`
  - `podman run --rm ai-assistants-container:test /app/test_versions.sh`
- Quick script sanity check:
  - `bash -n test_versions.sh`

## Coding Style & Naming Conventions

- YAML: 2-space indentation (GitHub Actions workflow).
- Shell: bash (`#!/bin/bash`), prefer strictness (`set -u`) and explicit quoting.
- Keep filenames stable: use `Containerfile` (not `Dockerfile`) unless you intentionally change tooling/CI accordingly.

## Testing Guidelines

- Primary test is `test_versions.sh` inside the built image.
- If you change installed tools in `Containerfile`, also update expected commands in `test_versions.sh` and tool list in `README.md`.

## Commit & Pull Request Guidelines

- Commit messages are short, imperative, and scoped (examples from history: `Fix ...`, `Add ...`, `Drop ...`).
- PRs should include:
  - what changed (`Containerfile`, workflow, or scripts),
  - how you validated it (commands + output summary),
  - confirmation that "Build and Push Container" CI passes.

## Security & Configuration Tips

- Do not commit credentials. CI uses the built-in `GITHUB_TOKEN` for `ghcr.io` login/push.
- Prefer deterministic tags and avoid generating invalid image tags in the workflow.
