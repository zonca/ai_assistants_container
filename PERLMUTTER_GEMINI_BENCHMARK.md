# Gemini Startup Benchmark on Perlmutter

This document records how `gemini` startup behaved on NERSC Perlmutter when run:

- natively on the host, without the container
- through `podman-hpc` with a fresh container per invocation
- inside one long-lived container session

The goal was to answer two questions:

1. How much startup overhead does the container add for one-off commands?
2. After the first run, can a persistent container become faster than native startup?

## Environment

- System: NERSC Perlmutter login node
- Remote access used from the local workstation: `ssh perlmutter`
- Native Gemini path on Perlmutter:

  ```bash
  /global/homes/z/zonca/.nvm/versions/node/v24.12.0/bin/gemini
  ```

- Container image:

  ```bash
  ghcr.io/zonca/ai_assistants_container:latest
  ```

## Important Perlmutter Detail

On Perlmutter, `podman-hpc` can pull the image directly from GHCR:

```bash
podman-hpc pull ghcr.io/zonca/ai_assistants_container:latest
```

However, this image inherits the Node base image entrypoint, and `podman-hpc` failed when using the default entrypoint:

```text
Error: crun: executable file `docker-entrypoint.sh` not found in $PATH
```

For Perlmutter, the working pattern is to override the entrypoint explicitly:

```bash
podman-hpc run --rm --entrypoint /bin/bash ghcr.io/zonca/ai_assistants_container:latest ...
```

For the one-off Gemini benchmark below, using `--entrypoint gemini` also worked.

## Benchmark 1: Fresh Process Each Time

This benchmark measures the cost of starting a new process for every invocation.

### Native Commands

```bash
ssh perlmutter 'bash -lc '\''for i in 1 2 3 4 5; do /usr/bin/time -f "native %e" gemini --version >/dev/null; done'\'''
```

### Container Commands

```bash
ssh perlmutter 'bash -lc '\''for i in 1 2 3 4 5; do /usr/bin/time -f "container %e" podman-hpc run --rm --entrypoint gemini ghcr.io/zonca/ai_assistants_container:latest --version >/dev/null; done'\'''
```

### Results

```text
native:    9.29, 5.27, 5.39, 5.45, 5.17
container: 16.06, 15.33, 15.03, 15.18, 15.18
```

### Interpretation

- Native average over 5 runs: `6.11s`
- Container average over 5 runs: `15.36s`
- Native warm average over runs 2-5: `5.32s`
- Container warm average over runs 2-5: `15.18s`

For one-off commands on Perlmutter, running `gemini` through a fresh container each time is much slower. The container adds about `9.9s` on warm runs and is roughly `2.9x` slower than native startup.

## Benchmark 2: Persistent Container Session

This benchmark separates:

- the one-time container startup cost
- repeated `gemini` startups inside an already-running container

This is the important test if the workflow is "open one container and run multiple Gemini commands inside it."

### Native Commands

```bash
ssh perlmutter 'bash -lc '\''echo "native_host $(hostname)"; /usr/bin/time -f "native shell startup %e" bash -lc "true"; for i in 1 2 3 4 5; do /usr/bin/time -f "native in-shell %e" gemini --version >/dev/null; done'\'''
```

### Container Commands

The container image does not include `/usr/bin/time`, so the benchmark used Bash's built-in `time` inside the container and `/usr/bin/time` outside the container to measure the one-time `podman-hpc run` startup cost:

```bash
ssh perlmutter 'bash -lc '\''tmp=$(mktemp); /usr/bin/time -o "$tmp" -f "%e" podman-hpc run --rm --entrypoint /bin/bash ghcr.io/zonca/ai_assistants_container:latest -lc "TIMEFORMAT=\"container in-shell %R\"; for i in 1 2 3 4 5; do time gemini --version >/dev/null; done"; rc=$?; startup=$(cat "$tmp"); rm -f "$tmp"; echo "container startup $startup"; exit $rc'\'''
```

### Results

```text
native shell startup: 0.36
native gemini runs:   9.52, 5.53, 5.34, 5.49, 5.52

container startup:    34.26
container gemini runs:
  15.278, 4.298, 4.267, 4.182, 4.292
```

### Interpretation

- Native warm average over runs 2-5: `5.47s`
- Container warm average over runs 2-5: `4.26s`

Inside a single already-running container, `gemini` startup became faster than native after the first in-container invocation. The warm in-container runs were about `1.2s` faster than the warm native runs on the tested Perlmutter host.

## Practical Conclusion

The answer depends on how the container is used:

- If each command uses a fresh `podman-hpc run`, the container is clearly slower.
- If one container session is kept alive and multiple Gemini commands are run inside it, the warm in-container startups can be faster than native.
- The one-time container startup cost is large enough that native remains better for short, one-off invocations.

## Recommended Usage

If the goal is reproducibility and you want the container, use it as a persistent environment rather than starting a new container per command. On Perlmutter, that means:

1. Start one interactive allocation if needed.
2. Start one `podman-hpc` container shell.
3. Run multiple `gemini` commands inside that same shell.

Example:

```bash
salloc -N 1 -q interactive -t 00:30:00
podman-hpc run --rm -it --entrypoint /bin/bash ghcr.io/zonca/ai_assistants_container:latest
gemini --version
gemini
```

That pattern amortizes the `podman-hpc` startup cost and is the only scenario in this test where the container showed a startup advantage after warm-up.
