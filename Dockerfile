FROM node:24-bookworm-slim

   ENV DEBIAN_FRONTEND=noninteractive \
     NPM_CONFIG_UPDATE_NOTIFIER=false \
     NODE_ENV=production \
     SHELL=/bin/bash \
     TERM=xterm-256color

   # Install system dependencies (git, cargo/rust toolchain for forgejo-cli)
   RUN apt-get update && apt-get install -y --no-install-recommends \
       git \
       curl \
       ca-certificates \
       build-essential \
       pkg-config \
       libssl-dev \
       && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y \
       && . "$HOME/.cargo/env" && cargo --version \
       && rm -rf /var/lib/apt/lists/*

   # Install forgejo CLI
   RUN . "$HOME/.cargo/env" && cargo install forgejo-cli --locked

   # Use standard npm registry (package-lock.json pins exact versions via SHA)

   # Install pi coding agent globally (pinned via tarball URL with integrity hash)
   RUN npm install -g --ignore-scripts https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-0.81.1.tgz

   # Install pi-web globally
   COPY package.json package-lock.json ./
   RUN npm ci --omit=dev --include=peer --allow-scripts=node-pty && \
       npm run build && \
       npm install -g . && \
       npm cache clean --force

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
