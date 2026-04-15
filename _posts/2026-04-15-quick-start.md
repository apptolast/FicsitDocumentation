---
title: "Quick Start: Monitor Your Server in 10 Minutes"
date: 2026-04-15 00:10:00 +0000
categories: [getting-started]
tags: [satisfactory, ficsitmonitor, quick-start, getting-started, setup]
description: "Get FICSIT.monitor monitoring your Satisfactory server in 10 minutes. Prerequisites: server running, FRM installed, ports open, admin password set."
toc: true
---

## Overview

This guide gets you from zero to a live FICSIT.monitor dashboard in approximately
10 minutes, assuming your Satisfactory server is already running.

---

## Prerequisites

Before starting, verify all of these are true:

- [ ] Satisfactory dedicated server is running → [Running with Docker](/posts/run-satisfactory-docker/)
- [ ] FRM mod is installed and responding → test: `curl http://YOUR_IP:8080/getPower`
- [ ] Ports 7777 (TCP+UDP), 8888 (TCP), 8080 (TCP), 8081 (TCP) are open → [Firewall Guide](/posts/server-firewall/)
- [ ] Admin password is set on the server → [First Launch Guide](/posts/server-first-launch/)

> If `curl http://YOUR_IP:8080/getPower` returns `Connection refused`, the FRM mod
> is not installed or port 8080 is blocked. See [Installing FRM](/posts/frm-installation/).
{: .prompt-danger }

---

## Step 1: Create Your Account

1. Go to [satisfactory-dashboard.pablohgdev.com](https://satisfactory-dashboard.pablohgdev.com)
2. Click **Register**
3. Enter your email, name, and password
4. Click **Create Account**

You'll be logged in and directed to the dashboard. Since no servers are connected yet,
the dashboard will prompt you to add your first server.

---

## Step 2: Add Your Server

Click **Add Server** (or go to **Servers** → **Create**) and fill in the form:

| Field | Value | Notes |
|-------|-------|-------|
| **Name** | My Factory Server | Display name, choose anything |
| **Host** | `YOUR_SERVER_IP` | Public IP of your VPS |
| **API Port** | `7777` | Default — do not change |
| **FRM HTTP Port** | `8080` | Default — do not change |
| **FRM WS Port** | `8081` | Default — do not change |
| **Admin Password** | `YourAdminPassword` | The password set in Step 4 of the first launch guide |

Click **Add Server**.

---

## Step 3: Wait for Onboarding

FICSIT.monitor runs an onboarding sequence when you add a server:

1. Verifies connectivity to port 7777 (HealthCheck)
2. Authenticates with the admin password (PasswordLogin)
3. Tests the FRM API on port 8080
4. Configures polling schedules
5. Fetches the first set of metrics

This takes 10–30 seconds. A progress indicator shows the status.

---

## Step 4: View Your Dashboard

Once onboarding completes, you're redirected to your server's dashboard. You'll see:

- **Server Status** panel: online indicator, tick rate, player count
- **Power Grid** panel: power production, consumption, and battery data (requires FRM)
- **Production** panel: item production/consumption rates (requires FRM)
- **Players** panel: connected players with health and position (requires FRM)

The dashboard updates automatically every 10–60 seconds depending on the panel.

---

## Common Onboarding Errors

| Error | Cause | Fix |
|-------|-------|-----|
| **422 Unprocessable Entity** | Wrong admin password | Go back and enter the correct password |
| **502 Bad Gateway** | Cannot reach the server | Check firewall — port 7777 must be accessible |
| **500 Internal Server Error** | FRM not responding | Verify FRM is installed and port 8080 is open |

---

## What's Next

- [Dashboard Overview](/posts/dashboard-overview/) — understand each panel
- [Power Grid Panel](/posts/power-grid-panel/) — power production and fuse alerts
- [Plans & Pricing](/posts/pricing-plans/) — upgrade for more servers and longer retention

---

## Troubleshooting Quick Reference

```bash
# Verify server API is accessible
curl -k -X POST https://YOUR_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -d '{"function":"HealthCheck","data":{}}'
# Expected: {"data":{"health":"healthy"}}

# Verify FRM is accessible
curl http://YOUR_IP:8080/getPower
# Expected: JSON array (not empty, not connection refused)

# Verify admin password works
curl -k -X POST https://YOUR_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -d '{"function":"PasswordLogin","data":{"minimumPrivilegeLevel":"Administrator","password":"YourPassword"}}'
# Expected: {"data":{"authenticationToken":"..."}}
```
