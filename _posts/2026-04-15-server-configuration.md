---
title: "Configuring Your Satisfactory Server"
date: 2026-04-15 00:06:00 +0000
categories: [server-setup]
tags: [satisfactory, server-configuration, max-players, autosave, docker]
description: "Adjust Satisfactory server settings: max players, autosave interval, and server name via Docker environment variables and the vanilla HTTPS API."
toc: true
---

## Overview

Most Satisfactory server configuration is done through Docker environment variables
(set at container start) or via the vanilla HTTPS API (changed at runtime without
restarting). This guide covers the most common configuration options.

---

## Docker Environment Variables

These variables are set in the `docker run` command or `docker-compose.yml` and take
effect when the container starts (a restart is required to change them).

| Variable | Default | Description |
|----------|---------|-------------|
| `MAXPLAYERS` | 4 | Maximum number of simultaneously connected players |
| `AUTOSAVEINTERVAL` | 300 | Autosave frequency in seconds (300 = 5 minutes) |
| `PGID` | 1000 | Group ID for `/config` volume ownership |
| `PUID` | 1000 | User ID for `/config` volume ownership |
| `STEAMBETA` | false | Use the Steam beta (experimental) branch |
| `SKIPUPDATE` | false | Skip the SteamCMD update check on startup |

### Changing a variable

Edit your `docker-compose.yml`:

```yaml
environment:
  - MAXPLAYERS=16
  - AUTOSAVEINTERVAL=600
```

Then restart:

```bash
docker compose up -d
```

---

## API-Configurable Settings

These can be changed at runtime via the vanilla HTTPS API without restarting the server.
Get an authentication token first (see [Generating Your API Token]({% post_url 2026-04-15-api-token %})).

### Check Server State

```bash
curl -k -X POST https://YOUR_SERVER_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"function": "QueryServerState", "data": {}}'
```

Response fields:

| Field | Description |
|-------|-------------|
| `numConnectedPlayers` | Current player count |
| `playerLimit` | Maximum players allowed |
| `techTier` | Current research tier (0–9) |
| `isGameRunning` | Whether a session is active |
| `isGamePaused` | Whether the session is paused |
| `totalGameDuration` | Total session time in seconds |
| `activeSessionName` | Name of the active save |

### Rename the Server

```bash
curl -k -X POST https://YOUR_SERVER_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"function": "RenameServer", "data": {"serverName": "My Factory Server"}}'
```

### Run a Console Command

```bash
curl -k -X POST https://YOUR_SERVER_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"function": "RunCommand", "data": {"command": "server.ListSessions"}}'
```

---

## Verifying the Server is Healthy

Use the HealthCheck endpoint (no authentication required):

```bash
curl -k -X POST https://YOUR_SERVER_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -d '{"function": "HealthCheck", "data": {}}'
```

- `"health": "healthy"` — server is running normally
- `"health": "slow"` — server is running but under heavy load (tick rate degraded)

FICSIT.monitor polls this endpoint every 10 seconds and reflects the status in
the dashboard's server status indicator.

---

## Viewing Server Logs

```bash
# Follow live logs
docker logs -f satisfactory-server

# Last 100 lines
docker logs --tail 100 satisfactory-server
```

Look for these log patterns:

| Pattern | Meaning |
|---------|---------|
| `LogGameState: Match State Changed from WaitingToStart to InProgress` | Session started |
| `LogNet: Join request:` | Player attempting to connect |
| `LogNet: Client disconnected` | Player left |
| `LogSatisfactoryGame: Autosave` | Autosave completed |

---

## Save Management

### List Available Saves

```bash
curl -k -X POST https://YOUR_SERVER_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"function": "EnumerateSessions", "data": {}}'
```

### Create a Manual Save

```bash
curl -k -X POST https://YOUR_SERVER_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"function": "CreateSave", "data": {"saveName": "manual_backup_2026"}}'
```

### Back Up Save Files

Save files are stored in `./data/saves/` (relative to your `docker-compose.yml`).
Back them up with:

```bash
cp -r /home/satisfactory/data/saves/ /home/satisfactory/backups/$(date +%Y%m%d_%H%M%S)/
```

---

## Next Step

[Installing FicsitRemoteMonitoring (FRM) →]({% post_url 2026-04-15-frm-installation %})
