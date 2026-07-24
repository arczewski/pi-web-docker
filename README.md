# pi-web Docker

Self-hosted [pi-web](https://github.com/jmfederico/pi-web) server with [pi-coding-agent](https://github.com/earendil-works/pi-coding-agent).

## Quick Start

### Prebuilt image

The image is published to GitHub Container Registry on every push to `main`:

```bash
docker pull ghcr.io/arczewski/pi-web-docker:main
```

### Build locally

```bash
docker build -t pi-web .
```

All dependencies are verified with SHA512 integrity hashes. Build fails if any hash mismatches.

### Run

```bash
docker run -d \
  --name pi-web \
  -p 8504:8504 \
  -v ~/projects:/workspace \
  pi-web
```

Open `http://localhost:8504` in your browser.

## Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` / `PI_WEB_PORT` | `8504` | Port to listen on |
| `PI_WEB_HOST` | `0.0.0.0` | Bind address (`0.0.0.0` for all interfaces, `127.0.0.1` for local-only) |

Custom port:

```bash
docker run -d --name pi-web -p 9000:9000 -e PORT=9000 -v ~/projects:/workspace pi-web
```

## Authentication

### pi-coding-agent (AI Provider)

pi reads API keys and provider configuration from your `~/.pi/agent/` directory at runtime. Mount it to use your existing setup:

**Option 1: Mount your existing config (recommended)**

This brings in your auth, custom providers (local servers, llama.cpp, etc.), settings, and models — everything works as-is:

```bash
docker run -d \
  --name pi-web \
  -p 8504:8504 \
  -v ~/projects:/workspace \
  -v ~/.pi:/home/pi-web/.pi:ro \
  pi-web
```

**Option 2: Environment variables**

pi also reads API keys from env vars. Useful if you don't want to mount your full config:

| Provider | Environment Variable |
|----------|---------------------|
| Anthropic | `ANTHROPIC_API_KEY` |
| OpenAI | `OPENAI_API_KEY` |
| DeepSeek | `DEEPSEEK_API_KEY` |
| Google Gemini | `GEMINI_API_KEY` |
| ... and many more | see [pi docs](https://github.com/earendil-works/pi-coding-agent) |

```bash
docker run -d \
  --name pi-web \
  -p 8504:8504 \
  -v ~/projects:/workspace \
  -e DEEPSEEK_API_KEY=123 \
  pi-web
```

### Git Platform CLIs

The container includes CLI tools for Git platform operations:

| Tool | Binary | Platform | Auth via env var |
|------|--------|----------|-----------------|
| **GitHub CLI** | `gh` | github.com | `GITHUB_TOKEN` |
| **GitLab CLI** | `glab` | gitlab.com | `GITLAB_TOKEN` |
| **Gitea CLI** | `tea` | any Gitea instance | `TEA_TOKEN` + `TEA_BASE_URL` |
| **Forgejo CLI** | `fj` | any Forgejo instance | `FORGEJO_TOKEN` + `FORGEJO_URL` |

### Full example (config + all tokens)

```bash
docker run -d \
  --name pi-web \
  -p 8504:8504 \
  -v ~/projects:/workspace \
  -v ~/.pi:/home/pi-web/.pi:ro \
  -e GITHUB_TOKEN=123 \
  -e GITLAB_TOKEN=123 \
  -e GITLAB_HOST=gitlab.example.com \
  -e TEA_TOKEN=123 \
  -e TEA_BASE_URL=https://gitea.example.com \
  -e FORGEJO_TOKEN=123 \
  -e FORGEJO_URL=https://forgejo.example.com \
  pi-web
```

All environment variables are consumed at runtime by their respective tools. The AI provider config (DeepSeek, local servers, llama.cpp) comes from your mounted `~/.pi/agent/` files — no need to pass those as env vars.

## Management

```bash
# View logs
docker logs -f pi-web

# Stop/Start/Restart
docker stop pi-web
docker start pi-web
docker restart pi-web

# Remove
docker stop pi-web && docker rm pi-web
```

## Security

- **pi-coding-agent** v0.81.1: SHA512 integrity hash from npm
- **pi-web** v1.202607.1: SHA512 integrity hash from npm
- **forgejo-cli** v0.6.0: compiled from source via cargo
- **GitHub CLI** v2.96.0: prebuilt binary with SHA256 verification
- **GitLab CLI** v1.22.0: prebuilt binary with SHA256 verification
- **Gitea CLI** v0.14.2: prebuilt binary with SHA256 verification
- **User restrictions**: The `pi-web` user has no access to `npm`, `npx`, `python3`, or `cargo` — only pre-installed packages and CLIs can be used

All packages are verified with integrity hashes at build time. Build fails if any hash mismatches.
