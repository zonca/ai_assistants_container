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

# Install terminal-based coding assistants (npm packages)
# Binaries installed:
# - @openai/codex -> codex
# - @google/gemini-cli -> gemini
# - opencode-ai -> opencode
# - @charmland/crush -> crush
RUN npm install -g \
    @openai/codex \
    @google/gemini-cli \
    opencode-ai \
    @charmland/crush \
    && npm cache clean --force

# Create a simple version check script
COPY test_versions.sh /app/test_versions.sh
RUN chmod +x /app/test_versions.sh

# Set entrypoint
CMD ["/bin/bash"]
