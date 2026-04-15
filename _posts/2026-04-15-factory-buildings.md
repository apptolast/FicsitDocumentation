---
title: "Factory Buildings Panel"
date: 2026-04-15 00:17:00 +0000
categories: [dashboard]
tags: [satisfactory, ficsitmonitor, factory, buildings, efficiency, overclocking]
description: "Inspect individual factory buildings in FICSIT.monitor. Per-machine efficiency, active recipe, overclocking status, and power consumption via FRM getFactory."
toc: true
---

## Overview

The Factory Buildings panel provides per-machine data across your entire factory,
sourced from FRM `getFactory`. It updates every **60 seconds** — the longest interval
of all panels because it involves fetching data for potentially thousands of machines.

> This panel requires the FRM mod. See [Installing FRM](/posts/frm-installation/).
{: .prompt-info }

---

## Building Fields

Each machine in your factory appears as a row:

| Field | Description |
|-------|-------------|
| `name` | Building display name |
| `class_name` | Game class identifier (e.g., `Build_SmelterMk1_C`) |
| `recipe` | Human-readable recipe name currently set (e.g., "Iron Ingot") |
| `recipe_class_name` | Game class identifier for the recipe |
| `manu_speed` | Manufacturing speed multiplier (100 = 100%, 150 = 150% with overclocking) |
| `somersloops` | Number of Somersloops applied (0–4 per machine) |
| `power_shards` | Number of Power Shards applied for overclocking (0–3) |
| `is_configured` | `true` if a recipe has been set |
| `is_producing` | `true` if the machine is currently running |
| `is_paused` | `true` if the machine is manually paused |
| `power_consumed` | Current power consumption (MW) |
| `circuit_group_id` | Power circuit this machine belongs to |
| `pos_x` / `pos_y` / `pos_z` | World coordinates of the building |

---

## Machine Status

A machine can be in these states based on its boolean fields:

| `is_configured` | `is_producing` | `is_paused` | State |
|-----------------|----------------|-------------|-------|
| true | true | false | Running normally |
| true | false | false | Stalled (input empty or output full) |
| true | false | true | Manually paused |
| false | false | false | No recipe set — needs configuration |

---

## Manufacturing Speed (`manu_speed`)

`manu_speed` is a percentage representing how fast the machine operates:

- `100` = base speed (no overclocking or underclocking)
- `>100` = overclocked with Power Shards (max 250 with 3 Power Shards)
- `<100` = underclocked to reduce power consumption
- Values above `100` are also possible with Somersloops (AWESOME factory augmentation)

---

## Overclocking: Power Shards and Somersloops

**Power Shards** (`power_shards: 0–3`):
- Each Power Shard increases production speed by ~50% and power consumption by ~133%
- Used to boost machine output when power is available but machine count is the constraint

**Somersloops** (`somersloops: 0–4`):
- Somersloops are special items that augment production at the cost of increased
  resource consumption
- The effect varies by recipe and machine type

---

## Finding Inefficient Machines

Sort the Factory Buildings panel by `is_producing` (ascending) to find all stalled
machines. Common causes:

1. **Input empty** — the belt feeding the machine is empty or the source has run dry
2. **Output full** — the belt exiting the machine is backed up
3. **Power outage** — the machine's circuit has a blown fuse
4. **Recipe not set** — `is_configured: false`
5. **Manually paused** — `is_paused: true`

---

## Power Consumption by Building

`power_consumed` shows the current actual power draw of each machine. This helps:
- Identify which machines contribute most to power demand
- Verify that overclocked machines aren't unexpectedly draining the grid
- See which machines are currently idle (power_consumed ≈ 0 or standby value)

---

## World Position

The `pos_x`, `pos_y`, `pos_z` coordinates allow you to locate any building on the
in-game map. FICSIT.monitor may visualize this on a factory map in future versions.

---

## API Reference

Factory building data is included in the dashboard snapshot:

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/{SERVER_ID}/dashboard \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Individual building data is refreshed from the FRM `getFactory` endpoint by the
polling job every 60 seconds. The API endpoint returns the latest cached data.

Example building entry:

```json
{
  "id": 42,
  "name": "Smelter",
  "class_name": "Build_SmelterMk1_C",
  "recipe": "Iron Ingot",
  "recipe_class_name": "Recipe_IngotIron_C",
  "manu_speed": 100.0,
  "somersloops": 0,
  "power_shards": 0,
  "is_configured": true,
  "is_producing": true,
  "is_paused": false,
  "power_consumed": 4.0,
  "circuit_group_id": 1,
  "pos_x": 12450.5,
  "pos_y": -34200.0,
  "pos_z": 105.3
}
```

See [Metrics API Reference](/posts/api-metrics/).
