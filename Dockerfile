FROM node:24-bookworm-slim

   ENV DEBIAN_FRONTEND=noninteractive \
     NPM_CONFIG_UPDATE_NOTIFIER=false \
     NODE_ENV=production \
     SHELL=/bin/bash \
     TERM=xterm-256color

   # Install system dependencies (git, Rust toolchain from Debian, forgejo-cli)
   RUN apt-get update && apt-get install -y --no-install-recommends \
       git \
       curl \
       ca-certificates \
       build-essential \
       pkg-config \
       libssl-dev \
       rustc \
       cargo \
       && rm -rf /var/lib/apt/lists/*

   # Install forgejo CLI from crates.io (pinned version with SHA256 verification)
   RUN mkdir -p /tmp/forgejo-cli && \
       curl -fSL -o /tmp/forgejo-cli.crate https://crates.io/api/v1/crates/forgejo-cli/0.6.0/download && \
       echo "4d56acd6ab5caab2870d6e301cd6e42741ca98761fc1d5890dad09b21b44780e  /tmp/forgejo-cli.crate" | sha256sum -c - && \
       tar xzf /tmp/forgejo-cli.crate -C /tmp/forgejo-cli --strip-components=1 && \
       cargo install --force --locked --path /tmp/forgejo-cli && \
       rm -rf /tmp/forgejo-cli /tmp/forgejo-cli.crate

   # Use standard npm registry (package-lock.json pins exact versions via SHA)

   # Install pi coding agent globally (pinned via tarball URL with integrity hash)
   RUN npm install -g --ignore-scripts https://registry.npmjs.org/@earendil-works/pi-coding-agent/-/pi-coding-agent-0.81.1.tgz#sha512-r6ovAsZOgAqbC/aU6s+/dPnv/sGZBuWyZNvi3pXjpbuX5wvp3XvGkQI7/VLvX2o9XpmpFaPUxKNym1WfkN/P8A==

   # Install pi-web from npm (pinned via tarball URL with integrity hash)
   RUN npm install -g --allow-scripts=node-pty https://registry.npmjs.org/@jmfederico/pi-web/-/pi-web-1.202607.1.tgz#sha512-7a9ZsvkWX71PAkZ8fOv+yCsADabTCFEAr+qXcdOE6ho/fUhMHaCKHP2LTDOaEHr/NK2w8+PKgCdPjrUfBfQwww== && \
       pi-web install && \
       pi-web doctor

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
