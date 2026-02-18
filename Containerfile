# Use lightweight Node 24 base image
FROM node:24-slim

# Set working directory
WORKDIR /app

# Install system dependencies that might be needed
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install terminal-based coding assistants
# Note: Installing the tools with best-effort approach as exact package names may vary
RUN npm install -g \
    codex-cli \
    gemini-cli \
    opencode \
    crush \
    || true

# Also try alternative package names if the above don't exist
RUN npm install -g \
    @openai/codex-cli \
    @google/generative-ai-cli \
    @github/copilot-cli \
    crush-cli \
    || true

# Create a simple version check script
COPY test_versions.sh /app/test_versions.sh
RUN chmod +x /app/test_versions.sh

# Set entrypoint
CMD ["/bin/bash"]
