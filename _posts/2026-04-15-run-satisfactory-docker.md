---
title: "Running Satisfactory Server with Docker"
date: 2026-04-15 00:03:00 +0000
categories: [server-setup]
tags: [satisfactory, docker, wolveix, dedicated-server, docker-compose]
description: "Deploy a Satisfactory dedicated server using the wolveix/satisfactory-server Docker image. Docker run and Compose examples with all environment variables explained."
toc: true
---

## Overview

This guide deploys a Satisfactory dedicated server using the
[`wolveix/satisfactory-server`](https://github.com/wolveix/satisfactory-server) Docker
image — the same image used in the production Kubernetes deployment powering this
documentation. The image handles SteamCMD downloads, auto-updates, and server startup
automatically.

---

## Prerequisites

- Docker installed → see [Installing Docker on Ubuntu]({% post_url 2026-04-15-install-docker %})
- Ports opened in your firewall → see [Firewall & Port Configuration]({% post_url 2026-04-15-server-firewall %})
- At least 20 GB free disk space (75 GB recommended)

---

## Option A: Docker Run (Quick Start)

```bash
docker run -d \
  --name satisfactory-server \
  --restart unless-stopped \
  -p 7777:7777/tcp \
  -p 7777:7777/udp \
  -p 8888:8888/tcp \
  -p 8080:8080/tcp \
  -p 8081:8081/tcp \
  -e MAXPLAYERS=8 \
  -e PGID=1000 \
  -e PUID=1000 \
  -e STEAMBETA=false \
  -e SKIPUPDATE=false \
  -e AUTOSAVEINTERVAL=300 \
  -v /home/satisfactory/data:/config \
  wolveix/satisfactory-server:latest
```

Create the data directory first:

```bash
mkdir -p /home/satisfactory/data
```

---

## Option B: Docker Compose (Recommended)

Create the directory and compose file:

```bash
mkdir -p /home/satisfactory
cd /home/satisfactory
```

Create `docker-compose.yml`:

```yaml
services:
  satisfactory:
    image: wolveix/satisfactory-server:latest
    container_name: satisfactory-server
    restart: unless-stopped
    ports:
      - "7777:7777/tcp"
      - "7777:7777/udp"
      - "8888:8888/tcp"
      - "8080:8080/tcp"
      - "8081:8081/tcp"
    environment:
      - MAXPLAYERS=8
      - PGID=1000
      - PUID=1000
      - STEAMBETA=false
      - SKIPUPDATE=false
      - AUTOSAVEINTERVAL=300
    volumes:
      - ./data:/config
```

Start the server:

```bash
docker compose up -d
```

---

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `MAXPLAYERS` | 4 | Maximum simultaneous connected players |
| `PGID` | 1000 | Group ID for file ownership inside the container |
| `PUID` | 1000 | User ID for file ownership inside the container |
| `STEAMBETA` | false | Use Steam beta (experimental) branch |
| `SKIPUPDATE` | false | Skip SteamCMD update check on startup |
| `AUTOSAVEINTERVAL` | 300 | Autosave every N seconds (300 = 5 minutes) |

> PGID and PUID should match the user owning the `/config` volume on the host.
> The default 1000 matches the first non-root user on most Ubuntu installations.
{: .prompt-info }

---

## Data Volume

All server data is stored in `/config` inside the container, mapped to `./data` on the
host (or `/home/satisfactory/data` if using the `docker run` command).

```text
data/
├── config/          ← Server configuration files
│   ├── GameUserSettings.ini
│   └── ServerSettings.ini
├── saves/           ← Game save files
│   └── session_name/
│       └── *.sav
└── logs/            ← Server logs
    └── FactoryGame.log
```

> Never delete the `data/` directory. It contains your game world saves.
> Back it up regularly.
{: .prompt-danger }

---

## First Boot

On the very first start, the container:

1. Downloads the Satisfactory Dedicated Server via SteamCMD (~8–10 GB)
2. Extracts and configures the server
3. Starts the game server process

**First boot takes 10–30 minutes** depending on your internet connection and server speed.
Follow the progress:

```bash
docker logs -f satisfactory-server
```

Look for these lines in the log output:

```text
...
Update state (0x61) downloading, progress: 98.74 (7,856,547,712 / 7,946,123,264)
Success! App '1690800' fully installed.
...
LogGameState: Match State Changed from WaitingToStart to InProgress
```

The server is ready when you see the `InProgress` line.

---

## Verify the Server is Running

Test the vanilla API (no authentication required):

```bash
curl -k -X POST https://YOUR_SERVER_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -d '{"function": "HealthCheck", "data": {}}'
```

Expected response:

```json
{"data":{"health":"healthy"}}
```

> Use `-k` because the Satisfactory server uses a self-signed TLS certificate.
{: .prompt-info }

---

## Managing the Container

```bash
# View live logs
docker logs -f satisfactory-server

# Stop the server
docker compose down          # (or: docker stop satisfactory-server)

# Start the server
docker compose up -d         # (or: docker start satisfactory-server)

# Restart
docker compose restart       # (or: docker restart satisfactory-server)

# View resource usage
docker stats satisfactory-server
```

---

## Auto-Updates

The container checks for Satisfactory server updates on every restart (controlled by
`SKIPUPDATE=false`). To apply an update:

```bash
docker compose pull && docker compose up -d
```

Set `SKIPUPDATE=true` to disable automatic update checks (useful for scheduled
maintenance windows).

---

## Next Step

[Firewall & Port Configuration →]({% post_url 2026-04-15-server-firewall %})
