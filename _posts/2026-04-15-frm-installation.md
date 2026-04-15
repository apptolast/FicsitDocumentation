---
title: "Installing FicsitRemoteMonitoring (FRM)"
date: 2026-04-15 00:07:00 +0000
categories: [prerequisites]
tags: [satisfactory, frm, ficsitremotemonitoring, mod, monitoring, smm]
description: "Install the FicsitRemoteMonitoring mod on your Satisfactory dedicated server to enable power, production, and factory metrics in FICSIT.monitor."
toc: true
---

## Overview

FicsitRemoteMonitoring (FRM) is a Satisfactory mod that exposes your factory data as
a JSON API. **FICSIT.monitor requires FRM** to display most of its monitoring panels —
without it, only the basic server health and player count are available.

---

## What FRM Enables

| Feature | Without FRM | With FRM |
|---------|-------------|----------|
| Server health (online/offline) | ✅ | ✅ |
| Player count | ✅ | ✅ |
| Tick rate / game phase | ✅ | ✅ |
| **Power grid data** | ❌ | ✅ |
| **Production rates** | ❌ | ✅ |
| **Factory buildings (efficiency %)** | ❌ | ✅ |
| **Player health and position** | ❌ | ✅ |
| **Trains and drone stations** | ❌ | ✅ |
| **World inventory** | ❌ | ✅ |
| **Resource sink data** | ❌ | ✅ |

---

## How FRM Works

Once installed, FRM runs as part of the game server and exposes an HTTP API on
**port 8080** and a WebSocket on **port 8081**:

```
GET http://YOUR_SERVER_IP:8080/getPower     → Power circuit data
GET http://YOUR_SERVER_IP:8080/getPlayer    → Connected players
GET http://YOUR_SERVER_IP:8080/getProdStats → Production metrics
... (10+ endpoints)
```

FICSIT.monitor polls these endpoints at regular intervals (every 15–60 seconds
depending on the endpoint) and stores the data in a time-series database.

---

## Prerequisites

- Your server is running → see [Running with Docker]({% post_url 2026-04-15-run-satisfactory-docker %})
- Port 8080 and 8081 are open → see [Firewall Configuration]({% post_url 2026-04-15-server-firewall %})
- You can connect to the server from the game client

---

## Step 1: Install the Satisfactory Mod Manager

FRM is installed via the **Satisfactory Mod Manager (SMM)**, also known as the
**FICSIT App**.

1. Download SMM from [ficsit.app](https://ficsit.app/) for your operating system
2. Launch SMM and log in with your Satisfactory game account

> SMM must be installed on **your PC** (the machine running the game client),
> not on the VPS running the server.
{: .prompt-info }

---

## Step 2: Connect SMM to Your Dedicated Server

1. In SMM, click the server icon (top of the left sidebar) or go to **Manage Servers**
2. Click **Add Server**
3. Enter your server's IP and port: `YOUR_SERVER_IP:7777`
4. Enter your admin password when prompted
5. SMM will connect to the server

---

## Step 3: Install FicsitRemoteMonitoring

1. With your dedicated server selected in SMM, use the search bar to search for
   **FicsitRemoteMonitoring**
2. Find the mod by **P.H.I.L** (published on ficsit.app)
3. Click **Install** → SMM installs the mod directly to your server
4. Click **Launch** / **Apply** to activate the changes

---

## Step 4: Restart the Server

After mod installation, restart the server container to apply the changes:

```bash
docker restart satisfactory-server
```

Wait for the server to come back online (~2–3 minutes):

```bash
docker logs -f satisfactory-server | grep "InProgress"
```

---

## Step 5: Verify FRM is Running

Test the FRM HTTP API:

```bash
curl http://YOUR_SERVER_IP:8080/getPower
```

Expected: a JSON array with power circuit data. Example (empty factory):

```json
[
  {
    "CircuitGroupID": 1,
    "PowerProduction": 100.0,
    "PowerConsumed": 45.2,
    "PowerCapacity": 100.0,
    "PowerMaxConsumed": 50.0,
    "BatteryPercent": 0.0,
    "BatteryCapacity": 0.0,
    "BatteryDifferential": 0.0,
    "FuseTriggered": false
  }
]
```

If `curl` returns a connection refused error, check:
1. Port 8080 is open in your firewall
2. The container restarted successfully after mod installation
3. The mod is enabled in SMM

---

## FRM via the Vanilla API (Port 7777)

Since FRM v1.1, factory data is also accessible via the vanilla HTTPS API port (7777),
avoiding the need to expose port 8080 publicly:

```bash
curl -k -X POST https://YOUR_SERVER_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -d '{"function": "frm", "endpoint": "getPower"}'
```

FICSIT.monitor supports both access methods and will use whichever is available.

---

## FRM Endpoints Reference

| Endpoint | Data | Polling interval |
|----------|------|-----------------|
| `getPower` | Power circuits (production, consumption, batteries, fuses) | 15s |
| `getProdStats` | Production/consumption rates per item | 30s |
| `getFactory` | Per-building data (efficiency %, recipe, power) | 60s |
| `getPlayer` | Player status (online, health, position) | 15s |
| `getTrains` | Train status (speed, mass, derailment, schedule) | 30s |
| `getDroneStation` | Drone station data (trip times, rates, power) | 30s |
| `getWorldInv` | Global storage inventory totals | 30s |
| `getGenerators` | Power generator details | 15s |
| `getExtractor` | Resource extractor data | 30s |
| `getResourceSink` | AWESOME Sink coupon points | 60s |

> Polling intervals above are FICSIT.monitor's default schedule. They are not
> configurable in the Free tier.
{: .prompt-info }

---

## Next Step

[Generating Your API Token →]({% post_url 2026-04-15-api-token %})
