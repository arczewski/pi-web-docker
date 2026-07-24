# pi-web Docker

Self-hosted [pi-web](https://github.com/jmfederico/pi-web) with [pi-coding-agent](https://github.com/earendil-works/pi-coding-agent).

## Quick Start

```bash
# Pull prebuilt image (published on every push to main)
docker pull ghcr.io/arczewski/pi-web-docker:main

# Or build locally
docker build -t pi-web .

# Run with just an API key
docker run -d --name pi-web -p 8504:8504 -v ~/projects:/workspace -e DEEPSEEK_API_KEY=123 pi-web
```

Open `http://localhost:8504`.

## Run Reference

```bash
docker run -d --name pi-web -p 8504:8504 \
  -v ~/projects:/workspace \
  -v ~/.pi/agent/settings.json:/home/pi-web/.pi/agent/settings.json:ro \  # (optional) mount your config files individually
  -v ~/.pi/agent/models.json:/home/pi-web/.pi/agent/models.json:ro \
  -v ~/.pi/agent/skills:/home/pi-web/.pi/agent/skills:ro \               # or mount full ~/.pi
  -e ANTHROPIC_API_KEY=123 \        # AI provider (pick one)
  -e DEEPSEEK_API_KEY=123 \
  -e GITHUB_TOKEN=123 \             # Git platform CLIs
  -e GITLAB_TOKEN=123 \
  -e FORGEJO_TOKEN=123 -e FORGEJO_URL=https://forgejo.example.com \
  -e TEA_TOKEN=123 -e TEA_BASE_URL=https://gitea.example.com \
  -e PI_WEB_PROJECT=/workspace/my-project \           # auto-open this project on page load
  -e SKILL_REPOSITORIES="https://git.su58.net/arczewski/dot-agent-skills.git" \  # auto-clone skills on startup
  pi-web
```

| Env var | Default | Purpose |
|---------|---------|---------|
| `PORT` / `PI_WEB_PORT` | `8504` | Web UI port |
| `PI_WEB_HOST` | `0.0.0.0` | Bind address |
| `ANTHROPIC_API_KEY` | — | Anthropic AI provider |
| `DEEPSEEK_API_KEY` | — | DeepSeek AI provider |
| `OPENAI_API_KEY` | — | OpenAI AI provider |
| `GITHUB_TOKEN` | — | GitHub CLI (`gh`) |
| `GITLAB_TOKEN` | — | GitLab CLI (`glab`) |
| `FORGEJO_TOKEN` | — | Forgejo CLI (`fj`) — also stores current session |
| `FORGEJO_URL` | — | Forgejo instance URL |
| `TEA_TOKEN` | — | Gitea CLI (`tea`) |
| `TEA_BASE_URL` | — | Gitea instance URL |
| `PI_WEB_PROJECT` | — | Subdirectory under `/workspace` to open automatically on page load |
| `SKILL_REPOSITORIES` | — | Space-separated git URLs cloned to `~/.pi/agent/skills/` on startup |

Mounting `~/.pi:/home/pi-web/.pi:ro` brings in all your pi config (settings, models, auth, skills) at once — no need for individual env vars except API keys that aren't in `auth.json`.

## Management

```bash
docker logs -f pi-web     # View logs
docker stop pi-web        # Stop
docker start pi-web       # Start
docker restart pi-web     # Restart
docker rm -f pi-web       # Remove
```

## Security

| Package | Version | Verification |
|---------|---------|-------------|
| pi-coding-agent | 0.81.1 | SHA512 from npm |
| pi-web | 1.202607.1 | SHA512 from npm |
| GitHub CLI | 2.96.0 | SHA256 prebuilt binary |
| GitLab CLI | 1.22.0 | SHA256 prebuilt binary |
| Gitea CLI | 0.14.2 | SHA256 prebuilt binary |
| Forgejo CLI | 0.6.0 | Compiled from source |

The `pi-web` user has no access to `npm`, `npx`, `python3`, or `cargo`. Build fails if any integrity hash mismatches.
