---
title: "What is FICSIT.monitor?"
date: 2026-04-15 00:09:00 +0000
categories: [getting-started]
tags: [satisfactory, ficsitmonitor, monitoring, saas, dashboard, overview]
description: "FICSIT.monitor is a real-time SaaS monitoring dashboard for Satisfactory dedicated servers. Monitor power grids, production rates, players, trains, and drones."
toc: true
---

## Overview

**FICSIT.monitor** is a web-based monitoring platform for Satisfactory dedicated
servers. It connects to your game server and the FicsitRemoteMonitoring (FRM) mod to
provide a real-time dashboard showing factory metrics, server health, connected players,
logistics, and more.

Access the live dashboard at [satisfactory-dashboard.pablohgdev.com](https://satisfactory-dashboard.pablohgdev.com).

---

## The Problem It Solves

When you're not in the game, your dedicated server is a black box. You don't know:
- Is the server running or has it crashed?
- How many players are connected?
- Is the power grid stable or has a fuse blown?
- Is production keeping up with consumption?
- Are any trains derailed?

FICSIT.monitor solves this by polling your server continuously and presenting the data
in a real-time web dashboard you can open from any device — your phone, tablet, or
another PC — without launching the game.

---

## How It Works

```
Satisfactory Server + FRM mod
        ↓ HTTP polling (every 10–60 seconds)
FICSIT.monitor backend (Laravel + Horizon)
        ↓ stores data in
PostgreSQL + TimescaleDB
        ↓ pushes live updates via
WebSocket (Laravel Reverb)
        ↓ displayed in
React dashboard (your browser)
```

The dashboard updates automatically without page refreshes. When a fuse blows or a
train derails, the panel reflects the change within seconds.

---

## What FICSIT.monitor Monitors

### Server Status
- Online/offline/degraded indicator
- Tick rate (server performance)
- Player count
- Tech tier and game phase
- Total session duration

### Power Grid
- Power production, consumption, and capacity (MW)
- Battery charge percentage and differential
- Fuse status per circuit

### Production
- Item production rate (items/min) per resource
- Item consumption rate (items/min) per resource
- Production efficiency (%)

### Players
- Online/offline status per player
- Player health and movement speed
- Position (X/Y/Z coordinates)

### Trains
- Train status and current station
- Speed (km/h) and payload mass
- Derailment alerts

### Drone Stations
- Drone status and paired station
- Average round-trip time
- Incoming/outgoing throughput rates

### Factory Buildings
- Per-machine efficiency (%)
- Active recipe
- Overclocking status (Somersloops, Power Shards)
- Power consumption per machine

---

## Requirements

To connect your server to FICSIT.monitor, you need:

1. ✅ A Satisfactory dedicated server running
2. ✅ FicsitRemoteMonitoring (FRM) mod installed
3. ✅ Ports 7777, 8888, 8080, and 8081 open in your firewall
4. ✅ An admin password configured on your server
5. ✅ A FICSIT.monitor account (Free tier available)

---

## Pricing Summary

| Tier | Price | Servers | Retention |
|------|-------|---------|-----------|
| Free | 0€/mo | 1 | 24 hours |
| Hobby | 6€/mo | 2 | 7 days |
| Pro | 19€/mo | 5 | 30 days |
| Team | 49€/mo | 15 | 90 days |
| Enterprise | Custom | Unlimited | Custom |

See [Plans & Pricing]({% post_url 2026-04-15-pricing-plans %}) for the full feature comparison.

---

## Next Step

[Quick Start: Monitor Your Server in 10 Minutes →]({% post_url 2026-04-15-quick-start %})
