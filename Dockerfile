FROM node:24-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive \
    NPM_CONFIG_UPDATE_NOTIFIER=false \
    NODE_ENV=production \
    SHELL=/bin/bash \
    TERM=xterm-256color

# Install system dependencies (git, build tools, Python for node-pty build, Rust)
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    curl \
    ca-certificates \
    build-essential \
    pkg-config \
    libssl-dev \
    python3 \
    xz-utils \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
    && . "$HOME/.cargo/env" && cargo --version \
    && rm -rf /var/lib/apt/lists/*

# Install forgejo CLI from crates.io (pinned version)
RUN . "$HOME/.cargo/env" && \
    cargo install forgejo-cli --version 0.6.0 --locked && \
    cp /root/.cargo/bin/fj /usr/local/bin/fj && \
    rm -rf /root/.cargo /root/.rustup

# Install pi coding agent globally (pinned via tarball URL with integrity hash)
RUN npm install -g --ignore-scripts https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-0.81.1.tgz#sha512-r6ovAsZOgAqbC/aU6s+/dPnv/sGZBuWyZNvi3pXjpbuX5wvp3XvGkQI7/VLvX2o9XpmpFaPUxKNym1WfkN/P8A==

# Install pi-web from npm and remove npm/python3 from final image
RUN npm install -g --allow-scripts=node-pty https://registry.npmjs.org/@jmfederico/pi-web/-/pi-web-1.202607.1.tgz#sha512-7a9ZsvkWX71PAkZ8fOv+yCsADabTCFEAr+qXcdOE6ho/fUhMHaCKHP2LTDOaEHr/NK2w8+PKgCdPjrUfBfQwww== && \
    npm cache clean --force && \
    rm -rf /usr/local/bin/npm /usr/local/bin/npx /usr/local/lib/node_modules/npm && \
    apt-get purge -y python3 && \
    apt-get autoremove --purge -y && \
    rm -rf /var/lib/apt/lists/*

# Install GitHub CLI (gh) — prebuilt binary with SHA256 verification
RUN curl -fSL -o /tmp/gh.tar.gz https://github.com/cli/cli/releases/download/v2.96.0/gh_2.96.0_linux_amd64.tar.gz && \
    echo "83d5c2ccad5498f58bf6368acb1ab32588cf43ab3a4b1c301bf36328b1c8bd60  /tmp/gh.tar.gz" | sha256sum -c - && \
    tar xzf /tmp/gh.tar.gz -C /tmp && \
    mv /tmp/gh_2.96.0_linux_amd64/bin/gh /usr/local/bin/gh && \
    rm -rf /tmp/gh.tar.gz /tmp/gh_2.96.0_linux_amd64

# Install GitLab CLI (glab) — prebuilt binary with SHA256 verification
RUN curl -fSL -o /tmp/glab.tar.gz https://github.com/profclems/glab/releases/download/v1.22.0/glab_1.22.0_Linux_x86_64.tar.gz && \
    echo "7d70af94648cd7720899315ddd9efdf981769f636b3cf6976508a939d5248a5f  /tmp/glab.tar.gz" | sha256sum -c - && \
    mkdir -p /tmp/glab-extract && \
    tar xzf /tmp/glab.tar.gz -C /tmp/glab-extract && \
    mv /tmp/glab-extract/bin/glab /usr/local/bin/glab && \
    rm -rf /tmp/glab.tar.gz /tmp/glab-extract

# Install Gitea CLI (tea) — prebuilt binary with SHA256 verification
RUN curl -fSL -o /tmp/tea.xz https://gitea.com/gitea/tea/releases/download/v0.14.2/tea-0.14.2-linux-amd64.xz && \
    echo "c72fbf11942d44581607cc352e4199039cf7908ffdd81ab15864756fbf3969c8  /tmp/tea.xz" | sha256sum -c - && \
    xz -d /tmp/tea.xz && \
    mv /tmp/tea /usr/local/bin/tea && \
    chmod +x /usr/local/bin/tea

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
