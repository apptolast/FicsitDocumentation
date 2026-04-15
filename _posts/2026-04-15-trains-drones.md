---
title: "Trains & Drone Stations Panel"
date: 2026-04-15 00:16:00 +0000
categories: [dashboard]
tags: [satisfactory, ficsitmonitor, trains, drones, logistics, derailment]
description: "Monitor Satisfactory train networks and drone station throughput in FICSIT.monitor. Derailment alerts, payload mass, travel times, and station efficiency."
toc: true
---

## Overview

The Trains & Drone Stations panel monitors your logistics network. Train data is
sourced from FRM `getTrains` and drone station data from FRM `getDroneStation`,
both polled every **30 seconds**.

> This panel requires the FRM mod. See [Installing FRM](/posts/frm-installation/).
{: .prompt-info }

---

## Trains

### Train Fields

| Field | Description |
|-------|-------------|
| `name` | Train name as set in-game |
| `status` | Current train status (e.g., "SelfDriving", "Manual", "Parked") |
| `forward_speed` | Current speed in km/h (positive = forward, 0 = stopped) |
| `payload_mass` | Current cargo mass in kg |
| `max_payload_mass` | Maximum cargo capacity in kg |
| `is_derailed` | `true` if the train has derailed |
| `is_pending_derail` | `true` if the train is at risk of derailing |
| `current_station` | Name of the station the train is currently at or heading to |
| `self_driving` | `true` if the train is in autonomous driving mode |
| `power_consumed` | Current power draw of the locomotive (MW) |

### Derailment Alerts

> **Train derailed.** When `is_derailed` is `true`, the train has crashed and is
> completely stopped. It will not move or transport cargo until it is repaired in-game.
> Go to the train's location and interact with the locomotive to reset it.
{: .prompt-danger }

> **Derailment risk.** When `is_pending_derail` is `true`, the train is at risk of
> derailing due to high speed on a curve or another condition. No cargo is lost yet,
> but immediate attention may be needed.
{: .prompt-warning }

### Reading Train Status

| `status` | `forward_speed` | Situation |
|----------|-----------------|-----------|
| `SelfDriving` | > 0 | Train moving autonomously on schedule |
| `SelfDriving` | 0 | Train stopped at a station, loading/unloading |
| `Manual` | > 0 | A player is driving the train |
| `Parked` | 0 | Train is parked, not on a schedule |
| `Derailed` | 0 | Train has crashed |

### Payload Mass

`payload_mass / max_payload_mass` shows how full the train is. A train at 100% payload
means it's fully loaded. A train consistently at 0% may indicate a problem with
the loading station's belt/item supply.

---

## Drone Stations

### Drone Station Fields

| Field | Description |
|-------|-------------|
| `name` | Station name as set in-game |
| `drone_status` | Current drone state (e.g., "Flying", "Docking", "Idle") |
| `paired_station` | Name of the paired destination station |
| `avg_round_trip_secs` | Average round-trip time in seconds |
| `avg_inc_rate` | Average incoming items/min (from paired station) |
| `avg_out_rate` | Average outgoing items/min (to paired station) |
| `power_consumed` | Current power draw of the drone station (MW) |

### Interpreting Drone Efficiency

**Round-trip time** (`avg_round_trip_secs`) measures how long the drone takes to
complete one delivery cycle (depart → deliver → return). Longer distances mean
longer round trips and lower throughput.

**Throughput rates** (`avg_inc_rate`, `avg_out_rate`) show items transferred per minute.
If these are lower than expected:
- The source station may be understocked
- The drone may not have a full load on each trip
- The distance between stations may be very long

### Drone Status Values

| `drone_status` | Meaning |
|----------------|---------|
| `Flying` | Drone is in transit |
| `Docking` | Drone is landing or departing from a station |
| `Idle` | Drone is waiting for items or a loading cycle |
| `Charging` | Drone is charging (if using battery fuel) |

---

## API Reference

### Trains

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/{SERVER_ID}/trains \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Example response item:

```json
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
```

### Drone Stations

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/{SERVER_ID}/drones \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Example response item:

```json
{
  "id": "uuid",
  "frm_id": "DroneStation_1",
  "name": "North Mining Outpost",
  "drone_status": "Flying",
  "paired_station": "Main Factory Hub",
  "avg_round_trip_secs": 45.0,
  "avg_inc_rate": 60.0,
  "avg_out_rate": 60.0,
  "power_consumed": 150.0,
  "updated_at": "2026-04-15T12:00:00Z"
}
```

See [Metrics API Reference](/posts/api-metrics/).
