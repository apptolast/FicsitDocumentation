---
title: "Players & Sessions Panel"
date: 2026-04-15 00:15:00 +0000
categories: [dashboard]
tags: [satisfactory, ficsitmonitor, players, sessions, monitoring]
description: "See who is online on your Satisfactory server in real time. Player health, position, online status, and session history in the FICSIT.monitor dashboard."
toc: true
---

## Overview

The Players panel shows all players who have ever connected to your server, with
real-time status for currently online players. Player count is polled every **10 seconds**
(from server metrics), and detailed player data is polled every **15 seconds** (via FRM).

---

## Panel Data Sources

**Player count** (no FRM required):
- Sourced from `QueryServerState` vanilla API → `numConnectedPlayers`
- Updates every 10 seconds

**Detailed player data** (requires FRM):
- Sourced from FRM `getPlayer` endpoint
- Updates every 15 seconds
- Includes health, position, and death state

---

## Player Fields

Each player row shows:

| Field | Description |
|-------|-------------|
| `name` | Player's in-game name |
| `is_online` | `true` if currently connected to the server |
| `health` | Current health percentage (0.0–1.0, where 1.0 = full health) |
| `speed` | Movement speed (current walking/running speed) |
| `is_dead` | `true` if the player is dead (respawning) |
| `pos_x` | World X coordinate |
| `pos_y` | World Y coordinate |
| `pos_z` | World Z coordinate (elevation) |
| `last_seen_at` | Timestamp of the last time this player was seen online |

---

## Player Status Indicators

| State | Display | Meaning |
|-------|---------|---------|
| Online, alive | 🟢 | Player is connected and alive |
| Online, dead | 🔴 | Player is connected but dead (respawning) |
| Offline | ⚫ | Player is not currently connected |

---

## Health Values

`health` is a float between 0 and 1:

- `1.0` = full health (100%)
- `0.5` = half health (50%)
- `0.0` = dead (same as `is_dead: true`)

Satisfactory players have 100 HP by default. Health regenerates over time when not
taking damage.

---

## Player Positions

The `pos_x`, `pos_y`, `pos_z` coordinates are in Unreal Engine world units. The map
coordinate system uses:

- **X-axis**: East-West
- **Y-axis**: North-South  
- **Z-axis**: Elevation (height above the surface)

These coordinates match the in-game map grid and can be used to locate players
in the world.

> Position data is approximate and reflects the server's last-known position for
> each player, updated every 15 seconds.
{: .prompt-info }

---

## Session History

FICSIT.monitor tracks each player's `first_seen_at` and `last_seen_at` timestamps,
providing a session history. This shows:
- When players first joined
- Their most recent session
- How long they've been active on the server (over the retention period)

---

## API Reference

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/{SERVER_ID}/players \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Returns an array of `Player` objects with these fields:

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

See [Metrics API Reference]({% post_url 2026-04-15-api-metrics %}).
