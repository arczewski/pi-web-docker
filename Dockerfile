FROM node:24-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    NODE_ENV=production \
    SHELL=/bin/bash \
    TERM=xterm-256color

# Install system dependencies (git, build tools, Python for node-pty build)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    build-essential \
    pkg-config \
    libssl-dev \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Install pi coding agent globally (pinned via tarball URL with integrity hash)
RUN npm install -g --ignore-scripts https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-0.81.1.tgz#sha512-r6ovAsZOgAqbC/aU6s+/dPnv/sGZBuWyZNvi3pXjpbuX5wvp3XvGkQI7/VLvX2o9XpmpFaPUxKNym1WfkN/P8A==

# Install pi-web from npm (pinned via tarball URL with integrity hash)
RUN npm install -g --allow-scripts=node-pty https://registry.npmjs.org/@jmfederico/pi-web/-/pi-web-1.202607.1.tgz#sha512-7a9ZsvkWX71PAkZ8fOv+yCsADabTCFEAr+qXcdOE6ho/fUhMHaCKHP2LTDOaEHr/NK2w8+PKgCdPjrUfBfQwww== && \
    npm cache clean --force && \
    rm -rf /usr/local/bin/npm /usr/local/bin/npx /usr/local/lib/node_modules/npm && \
    apt-get purge -y python3 && \
    apt-get autoremove --purge -y && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd -g 1000 pi-web && \
    useradd -u 1000 -g pi-web -m pi-web && \
    mkdir -p /home/pi-web/.ssh && \
    chmod 700 /home/pi-web/.ssh

# Workspace for all user projects (not pi-web itself)
WORKDIR /workspace

# Default port — override at runtime with -e PORT=...
ENV PORT=8504

EXPOSE ${PORT}

USER pi-web

# Launch pi-web server (pi agent operates on /workspace)
CMD ["pi-web-server"]
