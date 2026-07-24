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
| `PORT` | `8504` | Port to listen on |

Custom port:

```bash
docker run -d --name pi-web -p 9000:9000 -e PORT=9000 -v ~/projects:/workspace pi-web
```

## Authentication

### pi-coding-agent (AI Provider)

pi reads API keys directly from environment variables at runtime. Pass the key for your chosen provider:

| Provider | Environment Variable |
|----------|---------------------|
| Anthropic | `ANTHROPIC_API_KEY` |
| OpenAI | `OPENAI_API_KEY` |
| Google Gemini | `GEMINI_API_KEY` |
| DeepSeek | `DEEPSEEK_API_KEY` |
| xAI | `XAI_API_KEY` |
| OpenRouter | `OPENROUTER_API_KEY` |
| Groq | `GROQ_API_KEY` |
| ... and many more | see [pi docs](https://github.com/earendil-works/pi-coding-agent) |

```bash
docker run -d \
  --name pi-web \
  -p 8504:8504 \
  -v ~/projects:/workspace \
  -e ANTHROPIC_API_KEY=sk-ant-... \
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

### Full example with all tokens

```bash
docker run -d \
  --name pi-web \
  -p 8504:8504 \
  -v ~/projects:/workspace \
  -v ~/.pi:/home/pi-web/.pi:ro \
  -e ANTHROPIC_API_KEY=sk-ant-... \
  -e GITHUB_TOKEN=ghp_xxx \
  -e GITLAB_TOKEN=glpat_xxx \
  -e GITLAB_HOST=gitlab.example.com \
  -e TEA_TOKEN=xxx \
  -e TEA_BASE_URL=https://gitea.example.com \
  -e FORGEJO_TOKEN=xxx \
  -e FORGEJO_URL=https://forgejo.example.com \
  pi-web
```

All environment variables are consumed at runtime by their respective tools, allowing agent skills to use both AI and Git platform APIs.

## User Home & Pi Configuration

The container runs as user `pi-web` with home directory at `/home/pi-web`.

To mount your local `.pi` folder (for custom skills, configurations, etc.):

```bash
docker run -d \
  --name pi-web \
  -p 8504:8504 \
  -v ~/projects:/workspace \
  -v ~/.pi:/home/pi-web/.pi:ro \
  pi-web
```

This maps your local `~/.pi` directory into the container at `/home/pi-web/.pi`, allowing pi-web to access your custom skills, configurations, and preferences.

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
