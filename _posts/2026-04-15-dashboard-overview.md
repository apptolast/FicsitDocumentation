---
title: "Dashboard Overview"
date: 2026-04-15 00:12:00 +0000
categories: [dashboard]
tags: [satisfactory, ficsitmonitor, dashboard, monitoring, real-time, websocket]
description: "Tour of the FICSIT.monitor real-time dashboard: server status, power grid, production, players, trains, drones, and factory panels. Live WebSocket updates."
toc: true
---

## Overview

The FICSIT.monitor dashboard is the central view for monitoring your Satisfactory
server. It shows real-time data across multiple panels, each focused on a different
aspect of your factory. The dashboard updates automatically via WebSocket — no manual
page refresh is needed.

---

## Dashboard Panels

The dashboard is divided into the following panels:

| Panel | Data source | Update interval |
|-------|-------------|-----------------|
| **Server Status** | Vanilla API | 10 seconds |
| **Power Grid** | FRM `getPower` | 15 seconds |
| **Production** | FRM `getProdStats` | 30 seconds |
| **Players** | FRM `getPlayer` | 15 seconds |
| **Trains** | FRM `getTrains` | 30 seconds |
| **Drone Stations** | FRM `getDroneStation` | 30 seconds |
| **Factory Buildings** | FRM `getFactory` | 60 seconds |

> Power Grid, Production, Players, Trains, Drone Stations, and Factory Buildings all
> require the FRM mod. Server Status works without FRM.
{: .prompt-info }

---

## Server Status Panel

Located at the top of the dashboard. Shows:

- **Status indicator**: 🟢 Online / 🔴 Offline / 🟡 Degraded
- **Tick rate**: the server's game loop speed. A healthy server runs at ~30 tick/s.
  Values below ~15 indicate the server is overloaded.
- **Player count**: how many clients are currently connected
- **Tech tier**: the current research tier reached (0–9)
- **Game phase**: the current game progression phase
- **Session name**: the active save file name
- **Uptime**: total game session duration (hours:minutes)

**Status definitions:**

| Status | Meaning |
|--------|---------|
| Online | Server is reachable, tick rate is normal |
| Degraded | Server is reachable but tick rate is low (below ~15 tick/s) |
| Offline | Server is unreachable or has crashed |

---

## Polling Cadence

FICSIT.monitor polls your server on fixed intervals using background jobs:

| Interval | Data fetched |
|----------|--------------|
| Every **10 seconds** | Server health check, server metrics (tick rate, players, game state) |
| Every **15 seconds** | Player details, power grid, generators |
| Every **30 seconds** | Production stats, trains, drone stations, extractors, world inventory |
| Every **60 seconds** | Factory buildings, resource sink |

The intervals are fixed and not configurable in the Free or Hobby tiers. The Pro tier
and above poll at 10 seconds for all metrics.

---

## Live Updates

The dashboard connects to the backend via **WebSocket** (Laravel Reverb, Pusher
protocol). When new data is stored after each polling cycle, the backend broadcasts
an update event to your browser session. The relevant panel re-renders automatically.

This means:
- You do not need to refresh the page
- Multiple browser tabs or devices show the same live data
- If you close and reopen the browser, the dashboard loads the latest cached snapshot
  immediately, then begins receiving live updates

---

## Panel-by-Panel Documentation

Each panel has a dedicated guide:

- [Power Grid Panel]({% post_url 2026-04-15-power-grid-panel %}) — MW production, consumption, batteries, fuse alerts
- [Production & Consumption Panel]({% post_url 2026-04-15-production-panel %}) — item rates and factory balance
- [Players & Sessions Panel]({% post_url 2026-04-15-players-sessions %}) — online players, health, position
- [Trains & Drone Stations Panel]({% post_url 2026-04-15-trains-drones %}) — logistics monitoring
- [Factory Buildings Panel]({% post_url 2026-04-15-factory-buildings %}) — per-machine efficiency and overclocking

---

## Data Retention

Historical data retention depends on your subscription plan:

| Plan | Retention |
|------|-----------|
| Free | 24 hours |
| Hobby | 7 days |
| Pro | 30 days |
| Team | 90 days |
| Enterprise | Custom |

After the retention period, data is automatically pruned from the time-series database.
Real-time monitoring works regardless of plan — retention only affects how far back
you can view historical charts.
