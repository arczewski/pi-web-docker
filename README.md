# pi-web Docker

Self-hosted [pi-web](https://github.com/jmfederico/pi-web) server with [pi-coding-agent](https://github.com/earendil-works/pi-coding-agent).

## Quick Start

### Build

```bash
docker build -t pi-web .
```

All dependencies are verified with SHA512/SHA256 hashes. Build fails if any hash mismatches.

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
- **forgejo-cli** v0.6.0: Version pinned, compiled from source

npm packages are verified with integrity hashes. Build fails if any hash mismatches.
