---
title: "Server Won't Connect: Diagnosing Connection Issues"
date: 2026-04-15 00:27:00 +0000
categories: [troubleshooting]
tags: [satisfactory, ficsitmonitor, connection, firewall, troubleshooting, diagnosis]
description: "Step-by-step guide to diagnose why FICSIT.monitor can't connect to your Satisfactory server. Check firewall, ports, TLS, FRM availability, and common fixes."
toc: true
---

## Overview

This guide provides a systematic diagnostic procedure for connection failures between
FICSIT.monitor and your Satisfactory server. Work through the steps in order to
isolate the root cause.

---

## Quick Diagnostic Flowchart

```
Is the server container running?
  └── No → docker start satisfactory-server, wait 2 min
  └── Yes ↓

Does HealthCheck respond?
  └── No → Port 7777 is blocked or server crashed → Step 1
  └── Yes ↓

Does PasswordLogin succeed?
  └── No (wrong_password) → Admin password is wrong → Step 2
  └── Yes ↓

Does FRM respond?
  └── No → Port 8080 blocked or FRM not installed → Step 3
  └── Yes ↓

All checks pass → contact support
```

---

## Step 1: Verify Server is Running and Port 7777 is Open

### Check Docker container

```bash
docker ps | grep satisfactory
```

Expected: shows `Up X hours` or `Up X minutes`.

If not running:
```bash
docker start satisfactory-server
docker logs -f satisfactory-server | grep "InProgress"
# Wait for "LogGameState: Match State Changed from WaitingToStart to InProgress"
```

### Check port 7777 is listening

On the server:
```bash
ss -tulnp | grep 7777
```

Expected output:
```
tcp  LISTEN  0  100  0.0.0.0:7777  0.0.0.0:*  users:(("FactoryServer",pid=xxx,fd=x))
udp  UNCONN  0  0    0.0.0.0:7777  0.0.0.0:*  users:(("FactoryServer",pid=xxx,fd=x))
```

If nothing appears, the game server process is not running. Check Docker logs for errors.

### Check UFW allows port 7777

```bash
sudo ufw status | grep 7777
```

Expected:
```
7777/tcp  ALLOW Anywhere
7777/udp  ALLOW Anywhere
```

If missing:
```bash
sudo ufw allow 7777/tcp
sudo ufw allow 7777/udp
sudo ufw reload
```

### Test the vanilla API (from an external machine)

Run this from your local PC (not from the server itself):

```bash
curl -k -X POST https://YOUR_PUBLIC_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -d '{"function":"HealthCheck","data":{}}'
```

- ✅ `{"data":{"health":"healthy"}}` — Port 7777 is accessible externally. Proceed to Step 2.
- ❌ `Connection refused` — The game server is not running or port 7777 is blocked externally.
- ❌ `Connection timed out` — Port 7777 is blocked by a firewall (cloud security group or VPS provider firewall).
- ❌ `SSL: certificate verify failed` — Normal. Add `-k` flag to ignore the self-signed certificate.

---

## Step 2: Verify the Admin Password

```bash
curl -k -X POST https://YOUR_PUBLIC_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -d '{
    "function": "PasswordLogin",
    "data": {
      "minimumPrivilegeLevel": "Administrator",
      "password": "YourAdminPassword"
    }
  }'
```

- ✅ `{"data":{"authenticationToken":"..."}}` — Password is correct. Proceed to Step 3.
- ❌ `{"errorCode":"wrong_password"}` — Incorrect password.

**Fix for wrong password:**
1. Connect from game client
2. Go to **Escape → Server Settings → Administration**
3. Reset the admin password
4. Update the password in FICSIT.monitor

If you've forgotten the admin password and cannot connect from the game client:
1. Stop the container: `docker stop satisfactory-server`
2. Open `./data/config/GameUserSettings.ini`
3. Find `AdminPassword=` and reset it
4. Start the container: `docker start satisfactory-server`

---

## Step 3: Verify FRM is Running

```bash
curl http://YOUR_PUBLIC_IP:8080/getPower
```

- ✅ JSON array (may be empty `[]`) — FRM is running. If `[]`, no session is active yet (start a game).
- ❌ `Connection refused` — FRM is not running or port 8080 is blocked.
- ❌ `Connection timed out` — Port 8080 is blocked by the cloud firewall.

**Fix for FRM not accessible:**

1. Open port 8080 in UFW:
```bash
sudo ufw allow 8080/tcp
sudo ufw allow 8081/tcp
sudo ufw reload
```

2. If using a cloud provider, open ports 8080 and 8081 TCP in the cloud firewall / security group.

3. Verify FRM is installed. From outside the game, you can check via the vanilla API:
```bash
curl -k -X POST https://YOUR_PUBLIC_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"function":"frm","endpoint":"getPower"}'
```

If FRM is installed but port 8080 is blocked, this alternative endpoint still works.

---

## Step 4: Cloud Provider Firewall Checks

If UFW is configured correctly but external connections still fail, your cloud provider
may have a separate firewall that overrides UFW.

**Hetzner Cloud:**
- Go to Cloud Console → Firewalls
- Verify your server's firewall includes inbound rules for TCP 7777, UDP 7777, TCP 8888, TCP 8080, TCP 8081

**DigitalOcean:**
- Go to Networking → Firewalls
- Verify the Droplet's firewall allows the required ports

**AWS:**
- Go to EC2 → Security Groups
- Verify inbound rules include TCP 7777, UDP 7777, TCP 8888, TCP 8080, TCP 8081 from `0.0.0.0/0`

---

## Step 5: Verify the IP is Public

FICSIT.monitor's servers connect to your server from the internet. Common mistake: using
a private or local IP.

```bash
# Check your server's public IP
curl ifconfig.me
# or
curl api.ipify.org
```

The public IP shown here is what you should enter in FICSIT.monitor — not `localhost`,
not `192.168.x.x`, not `10.x.x.x`.

---

## Still Not Working?

Gather this diagnostic information before seeking support:

1. Output of `docker ps | grep satisfactory`
2. Output of `curl -k -X POST https://YOUR_IP:7777/api/v1 -H "Content-Type: application/json" -d '{"function":"HealthCheck","data":{}}'`
3. Output of `curl http://YOUR_IP:8080/getPower`
4. Output of `sudo ufw status`
5. The exact error code shown in FICSIT.monitor (422, 502, or 500)
