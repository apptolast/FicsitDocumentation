---
title: "Adding Your First Server to FICSIT.monitor"
date: 2026-04-15 00:11:00 +0000
categories: [getting-started]
tags: [satisfactory, ficsitmonitor, server-setup, onboarding, add-server]
description: "Add your Satisfactory dedicated server to FICSIT.monitor. Complete field reference for the server form, onboarding process, and error code explanations."
toc: true
---

## Overview

This guide provides a complete reference for adding a Satisfactory server to
FICSIT.monitor — covering every form field, what the onboarding process does, and
how to resolve common error codes.

---

## The Add Server Form

Navigate to **Servers** → **Add Server**. The form has these fields:

### Name

A display name for your server in the FICSIT.monitor dashboard. This is not the
in-game server name — it's only used inside FICSIT.monitor.

- Example: `Pablo's Factory`, `Production Server`, `Public Community Server`
- Required, maximum 255 characters

### Host

The **public IP address** of the machine running your Satisfactory server.

- Example: `46.224.182.211`
- Must be a publicly accessible IP — not `localhost`, `127.0.0.1`, or a private
  IP like `192.168.x.x`

> FICSIT.monitor's servers make outbound connections to your server. The IP must be
> reachable from the internet.
{: .prompt-warning }

### API Port

The port where the Satisfactory vanilla HTTPS API listens.

- **Default: `7777`** — do not change this unless you've specifically remapped the port
- This is the port that handles `HealthCheck`, `PasswordLogin`, and `QueryServerState`

### FRM HTTP Port

The port where FicsitRemoteMonitoring (FRM) exposes its HTTP API.

- **Default: `8080`** — do not change unless you've customized FRM
- This is used for polling factory metrics (power, production, buildings, etc.)

### FRM WebSocket Port

The port for FRM's WebSocket connection.

- **Default: `8081`** — do not change unless you've customized FRM
- Used for real-time updates from FRM

### Admin Password

The admin password you set on your Satisfactory server during [First Launch]({% post_url 2026-04-15-server-first-launch %}).

- FICSIT.monitor uses this to call `PasswordLogin` on your server
- The password is stored encrypted and never exposed via the API
- If you change your admin password, update it here to restore connectivity

---

## What Happens During Onboarding

When you submit the form, FICSIT.monitor runs the following sequence:

1. **Connectivity check** — sends `HealthCheck` to `https://HOST:API_PORT/api/v1`
   - Failure → 502 error (host unreachable)
2. **Authentication** — calls `PasswordLogin` with the admin password
   - Failure → 422 error (wrong password)
3. **FRM verification** — sends a test request to `http://HOST:FRM_HTTP_PORT/getPower`
   - Failure → 500 error (FRM not accessible — check port 8080 and mod installation)
4. **Initial data fetch** — polls all metric endpoints
5. **Polling schedule setup** — configures recurring jobs for this server

If all steps succeed, you're redirected to the server dashboard.

---

## Error Codes Reference

| HTTP Status | Error | Cause | Fix |
|-------------|-------|-------|-----|
| **422** | `InvalidAdminPasswordException` | The admin password is wrong | Verify the password set in the game's Server Settings → Administration tab |
| **502** | `ServerUnreachableException` | Cannot connect to `HOST:7777` | Check firewall (port 7777 TCP), verify the server is running (`docker ps`), verify the IP is correct |
| **500** | `ProvisioningFailedException` | Connected but something failed during setup | Usually FRM not accessible (port 8080 blocked or FRM not installed) |

---

## Before You Submit the Form

Run these checks from your local machine to confirm everything is working:

```bash
# 1. Test vanilla API (no auth)
curl -k -X POST https://YOUR_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -d '{"function":"HealthCheck","data":{}}'
# Expected: {"data":{"health":"healthy"}}

# 2. Test admin password
curl -k -X POST https://YOUR_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -d '{"function":"PasswordLogin","data":{"minimumPrivilegeLevel":"Administrator","password":"YOUR_PASSWORD"}}'
# Expected: {"data":{"authenticationToken":"..."}}

# 3. Test FRM
curl http://YOUR_IP:8080/getPower
# Expected: JSON array (not empty, not connection refused)
```

If all three commands succeed, the FICSIT.monitor onboarding will succeed.

---

## Adding More Servers

You can add additional servers from the **Servers** → **Add Server** page at any time.
The number of servers you can add depends on your subscription plan:

| Plan | Max Servers |
|------|-------------|
| Free | 1 |
| Hobby | 2 |
| Pro | 5 |
| Team | 15 |
| Enterprise | Unlimited |

See [Plans & Pricing]({% post_url 2026-04-15-pricing-plans %}) for details.

---

## Next Step

[Dashboard Overview →]({% post_url 2026-04-15-dashboard-overview %})
