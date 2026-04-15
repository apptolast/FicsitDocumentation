---
title: "Common Errors & Solutions"
date: 2026-04-15 00:26:00 +0000
categories: [troubleshooting]
tags: [satisfactory, ficsitmonitor, troubleshooting, errors, error-codes]
description: "Troubleshoot FICSIT.monitor errors: 422 admin password, 502 server unreachable, 500 provisioning failed, FRM not responding, and stale data issues."
toc: true
---

## Overview

This page covers the most common errors encountered when setting up or using
FICSIT.monitor, with their causes and step-by-step fixes.

---

## FICSIT.monitor Error Codes

### 422 — Wrong Admin Password

**Error:** `InvalidAdminPasswordException`

**Cause:** The admin password you provided when adding the server does not match
the password set on the Satisfactory server.

**Fix:**
1. Connect to your server from the game client
2. Go to **Escape → Server Settings → Administration**
3. Note the admin password (or reset it to a known value)
4. In FICSIT.monitor, go to your server → Edit → update the admin password
5. Retry adding or reconnecting the server

**Verify the password manually:**
```bash
curl -k -X POST https://YOUR_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -d '{"function":"PasswordLogin","data":{"minimumPrivilegeLevel":"Administrator","password":"YOUR_PASSWORD"}}'
```

If this returns `{"errorCode":"wrong_password"}`, the password is incorrect.

---

### 502 — Server Unreachable

**Error:** `ServerUnreachableException`

**Cause:** FICSIT.monitor cannot establish a TCP connection to your server on port 7777.

**Fix checklist:**

1. Verify the server container is running:
```bash
docker ps | grep satisfactory
# Should show "Up X hours"
```

2. Verify the server is listening on port 7777:
```bash
ss -tulnp | grep 7777
# Should show: 0.0.0.0:7777
```

3. Verify the port is open in UFW:
```bash
sudo ufw status | grep 7777
# Should show: 7777/tcp ALLOW Anywhere
```

4. Test from an external machine:
```bash
curl -k -X POST https://YOUR_PUBLIC_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -d '{"function":"HealthCheck","data":{}}'
# Expected: {"data":{"health":"healthy"}}
```

5. Verify the IP in FICSIT.monitor is the **public** IP — not `localhost`, `127.0.0.1`,
   or a private IP like `192.168.x.x`.

---

### 500 — Provisioning Failed

**Error:** `ProvisioningFailedException`

**Cause:** FICSIT.monitor connected to the server (port 7777 is OK), authenticated
(password is correct), but something failed during the setup phase. Usually caused by
FRM not being accessible on port 8080.

**Fix checklist:**

1. Verify FRM is running:
```bash
curl http://YOUR_PUBLIC_IP:8080/getPower
# Expected: JSON array
# If "Connection refused": FRM not running or port 8080 not open
```

2. Open port 8080 in UFW:
```bash
sudo ufw allow 8080/tcp && sudo ufw reload
```

3. Verify FRM is installed (restart server after installing):
```bash
docker restart satisfactory-server
# Wait ~2 minutes for the server to come back online
curl http://YOUR_PUBLIC_IP:8080/getPower
```

---

## FRM-Specific Issues

### FRM Shows No Data (Empty Array)

**Symptom:** `curl http://YOUR_IP:8080/getPower` returns `[]`

**Cause:** The server is running but no game session is active (no world loaded).

**Fix:** Connect from the game client and start or load a game session.

### FRM Not Installed

**Symptom:** `curl http://YOUR_IP:8080/getPower` returns `Connection refused`

**Fix:**
1. Install FRM via Satisfactory Mod Manager (see [Installing FRM](/posts/frm-installation/))
2. Restart the server container: `docker restart satisfactory-server`
3. Wait for the server to come back online and retry

### FRM Data Stops Updating

**Symptom:** Dashboard panels show data, but it's not changing

**Cause:** The background polling jobs may have stopped.

**Fix:** Check the Laravel Horizon queue worker status. In Kubernetes, check the
Horizon deployment pod is running. In Docker, this would require the full application
stack (not just the game server).

---

## Dashboard Issues

### Dashboard Shows Stale Data

**Symptom:** The dashboard isn't updating automatically

**Cause:** The WebSocket (Reverb) connection has been lost.

**Fix:**
1. Refresh the page — this will reconnect to the WebSocket
2. Check your browser's network tab for WebSocket errors
3. Verify the Reverb service is running (for self-hosted deployments)

### Server Shows as "Degraded"

**Symptom:** Server status is yellow "Degraded"

**Cause:** `tick_rate` dropped below the normal threshold (~15 tick/s).

**Meaning:** The server is responding but running slowly. Your factory may be
too complex for the current VPS specs.

**Options:**
- Reduce factory complexity (merge/simplify production lines)
- Upgrade to a VPS with more CPU cores
- Enable underclocking on machines to reduce simulation load

### Power Panel Shows No Data

**Symptom:** Power panel is empty but other panels work

**Cause:** Your factory has no active power circuits (no generators placed yet),
or you're very early in the game with no electrical infrastructure.

This is normal for early-game sessions. The panel populates once you place generators
and connect machines to a power grid.

---

## Docker Issues

### Server Stopped After Restart

**Symptom:** Server container stops after system reboot

**Cause:** The container wasn't started with `--restart unless-stopped`.

**Fix:**
```bash
# Stop and remove the old container
docker stop satisfactory-server && docker rm satisfactory-server

# Recreate with restart policy
docker run -d \
  --name satisfactory-server \
  --restart unless-stopped \
  [... rest of your docker run command ...]
```

Or if using Compose, Docker Compose services restart automatically if `restart: unless-stopped`
is set (which it is in the guide's example).

### Container Exits Immediately

**Symptom:** `docker ps` shows the container stopped

**Cause:** Usually an error during startup (permissions, missing files, etc.)

**Fix:** Check logs immediately after the container exits:
```bash
docker logs satisfactory-server
```

Look for errors like `permission denied` (PUID/PGID mismatch) or SteamCMD failures.
