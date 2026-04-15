---
title: "First Launch and World Setup"
date: 2026-04-15 00:05:00 +0000
categories: [server-setup]
tags: [satisfactory, game-server, world-creation, admin-password, first-launch]
description: "Connect to your Satisfactory dedicated server for the first time, create a new world, and set your admin password — required to connect FICSIT.monitor."
toc: true
---

## Overview

With your server running and ports open, this guide walks through connecting to your
dedicated server from the Satisfactory game client, creating a new world, and setting
the admin password that FICSIT.monitor needs to authenticate.

---

## Prerequisites

- Server is running and healthy (verify: `curl -k -X POST https://YOUR_IP:7777/api/v1 -H "Content-Type: application/json" -d '{"function":"HealthCheck","data":{}}'` → `{"data":{"health":"healthy"}}`)
- Game client (Satisfactory) installed on your PC
- Ports 7777 TCP and UDP are open

---

## Step 1: Connect from the Game Client

1. Launch **Satisfactory** on your PC
2. From the main menu, go to **Play** → **Server Manager**
3. Click **Add Server**
4. Enter your server's public IP address: `YOUR_SERVER_IP`
5. Leave the port as `7777`
6. Click **Confirm**

The server should appear in your server list. If it shows as offline:
- Check the server container is running: `docker logs satisfactory-server | tail -20`
- Verify port 7777 UDP is open in your firewall

---

## Step 2: Join the Server

1. Select your server from the list
2. If prompted for a password, leave it empty (no client password set by default)
3. Click **Join**

You'll land in the server's main menu. The server is running but has no game session yet.

---

## Step 3: Create a New Game Session

1. Once connected, click **Create Game**
2. Choose your starting location (no impact on server monitoring)
3. Set a **Session Name** (this is the world name, visible in the API)
4. Click **Create**

The world will generate. This takes 1–3 minutes on a VPS.

---

## Step 4: Set the Admin Password

The admin password is **required** for FICSIT.monitor to authenticate with your server.
Set it before disconnecting.

While in-game and connected to the server:

1. Press **Escape** to open the menu
2. Click **Manage Server** (or **Server Settings**)
3. Go to the **Administration** tab
4. Enter a strong password in **Admin Password**
5. Confirm the password
6. Click **Apply**

> Choose a strong admin password and keep it safe. Anyone with this password can
> manage your server, save files, and run console commands.
{: .prompt-danger }

Alternatively, set the admin password via the API (useful for headless setup):

```bash
# Step 1: Get an authentication token (PasswordlessLogin — only works if no password is set)
curl -k -X POST https://YOUR_SERVER_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -d '{"function": "PasswordlessLogin", "data": {"minimumPrivilegeLevel": "Administrator"}}'

# Step 2: Use the token to set the admin password (replace TOKEN with the token from step 1)
curl -k -X POST https://YOUR_SERVER_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer TOKEN" \
  -d '{"function": "SetAdminPassword", "data": {"password": "YourStrongPassword", "authenticationToken": "TOKEN"}}'
```

---

## Step 5: Verify the Admin Password

Test authentication with your new password:

```bash
curl -k -X POST https://YOUR_SERVER_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -d '{"function": "PasswordLogin", "data": {"minimumPrivilegeLevel": "Administrator", "password": "YourStrongPassword"}}'
```

Expected response:

```json
{"data":{"authenticationToken":"<your-token>"}}
```

If you get `{"errorCode":"wrong_password"}`, the password was not set correctly.

---

## Autosave Configuration

The server autosaves every 5 minutes by default (`AUTOSAVEINTERVAL=300`). To change
this, update the environment variable in your Docker run command or `docker-compose.yml`
and restart the container.

Common intervals:

| Interval | Seconds | Notes |
|----------|---------|-------|
| 5 minutes | 300 | Default — good balance |
| 10 minutes | 600 | Less frequent writes |
| 2 minutes | 120 | More protection against crashes |

---

## What FICSIT.monitor Needs

After completing this guide, you have:

- ✅ A running Satisfactory server
- ✅ An active game session (world created)
- ✅ An admin password set

You now need to:
- Install the FRM mod → see [Installing FicsitRemoteMonitoring](/posts/frm-installation/)
- Connect FICSIT.monitor → see [Quick Start Guide](/posts/quick-start/)

---

## Next Step

[Installing FicsitRemoteMonitoring (FRM) →](/posts/frm-installation/)
