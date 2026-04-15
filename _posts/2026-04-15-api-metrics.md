---
title: "Metrics API Reference"
date: 2026-04-15 00:23:00 +0000
categories: [api-reference]
tags: [satisfactory, ficsitmonitor, api, metrics-api, monitoring, rest-api]
description: "Query Satisfactory server metrics via the FICSIT.monitor API. All /v1/servers/{id}/ endpoints with response field definitions and example responses."
toc: true
---

## Overview

The Metrics API provides access to all real-time data FICSIT.monitor collects from
your Satisfactory server. All endpoints require authentication and a valid server UUID.

**Base path:** `/api/v1/servers/{server_id}/`

Replace `{server_id}` with the UUID from `GET /api/v1/servers`.

---

## GET /metrics/latest

Latest server state (health, player count, game phase).

**Updates every 10 seconds.**

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/{id}/metrics/latest \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response:**

```json
{
  "time": "2026-04-15T12:00:00Z",
  "tick_rate": 30.1,
  "player_count": 3,
  "tech_tier": 4,
  "game_phase": "PhaseTwo",
  "is_running": true,
  "is_paused": false,
  "total_duration": 86400
}
```

| Field | Description |
|-------|-------------|
| `tick_rate` | Server game loop speed. Healthy = ~30 tick/s |
| `player_count` | Currently connected players |
| `tech_tier` | Research tier (0–9) |
| `game_phase` | Current game progression phase |
| `is_running` | `true` if a session is active |
| `is_paused` | `true` if the session is paused |
| `total_duration` | Total session time in seconds |

---

## GET /players

All players and their current status.

**Updates every 15 seconds (FRM required).**

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/{id}/players \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response:**

```json
[
  {
    "id": "uuid",
    "name": "PlayerName",
    "is_online": true,
    "health": 0.85,
    "speed": 45.2,
    "is_dead": false,
    "pos_x": 12450.5,
    "pos_y": -34200.0,
    "pos_z": 105.3,
    "last_seen_at": "2026-04-15T12:00:00Z"
  }
]
```

See [Players & Sessions Panel](/posts/players-sessions/) for field descriptions.

---

## GET /power/latest

Latest power circuit data.

**Updates every 15 seconds (FRM required).**

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/{id}/power/latest \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response:**

```json
[
  {
    "circuit_group_id": 1,
    "power_production": 500.0,
    "power_consumed": 420.5,
    "power_capacity": 600.0,
    "power_max_consumed": 650.0,
    "battery_percent": 100.0,
    "battery_capacity": 200.0,
    "battery_differential": 79.5,
    "fuse_triggered": false,
    "time": "2026-04-15T12:00:00Z"
  }
]
```

See [Power Grid Panel](/posts/power-grid-panel/) for field descriptions.

---

## GET /production/latest

Latest production and consumption rates per item.

**Updates every 30 seconds (FRM required).**

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/{id}/production/latest \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response:**

```json
[
  {
    "item_class_name": "Desc_IronIngot_C",
    "item_name": "Iron Ingot",
    "item_type": "item",
    "current_prod": 900.0,
    "max_prod": 900.0,
    "current_consumed": 720.0,
    "max_consumed": 900.0,
    "prod_percent": 100.0,
    "cons_percent": 80.0,
    "time": "2026-04-15T12:00:00Z"
  }
]
```

See [Production Panel](/posts/production-panel/) for field descriptions.

---

## GET /trains

All trains and their current state.

**Updates every 30 seconds (FRM required).**

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/{id}/trains \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response:**

```json
[
  {
    "id": "uuid",
    "frm_id": "Train_1",
    "name": "Iron Express",
    "status": "SelfDriving",
    "forward_speed": 120.5,
    "payload_mass": 32000.0,
    "max_payload_mass": 48000.0,
    "is_derailed": false,
    "is_pending_derail": false,
    "current_station": "Iron Mine Station",
    "self_driving": true,
    "power_consumed": 25.0,
    "updated_at": "2026-04-15T12:00:00Z"
  }
]
```

See [Trains & Drone Stations Panel](/posts/trains-drones/).

---

## GET /drones

All drone stations.

**Updates every 30 seconds (FRM required).**

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/{id}/drones \
  -H "Authorization: Bearer YOUR_TOKEN"
```

**Response:**

```json
[
  {
    "id": "uuid",
    "frm_id": "DroneStation_1",
    "name": "North Outpost",
    "drone_status": "Flying",
    "paired_station": "Main Hub",
    "avg_round_trip_secs": 45.0,
    "avg_inc_rate": 60.0,
    "avg_out_rate": 60.0,
    "power_consumed": 150.0,
    "updated_at": "2026-04-15T12:00:00Z"
  }
]
```

See [Trains & Drone Stations Panel](/posts/trains-drones/).

---

## GET /generators

Power generator data cached from FRM.

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/{id}/generators \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Returns the raw generator data from FRM `getGenerators`, cached in Redis.

---

## GET /extractors

Resource extractor data cached from FRM.

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/{id}/extractors \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Returns the raw extractor data from FRM `getExtractor` (singular — FRM endpoint name),
cached in Redis.

---

## GET /world-inventory

Global world inventory cached from FRM.

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/{id}/world-inventory \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Returns the raw world inventory from FRM `getWorldInv`, cached in Redis.

---

## GET /resource-sink

AWESOME Sink data cached from FRM.

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/{id}/resource-sink \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Returns the raw resource sink data from FRM `getResourceSink`, cached in Redis.

---

## GET /dashboard

Full metrics snapshot — all panels in one request. Useful for initial page load
or building a complete monitoring view.

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/{id}/dashboard \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Returns the combined data from all metric endpoints in a single response object.

---

## Notes

- Endpoints returning cached data (generators, extractors, world-inventory, resource-sink)
  reflect the last poll cycle (every 15–60 seconds depending on the endpoint)
- All timestamps are ISO 8601 UTC
- Server UUID must belong to the authenticated user — otherwise `404 Not Found`
