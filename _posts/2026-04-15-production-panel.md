---
title: "Production & Consumption Panel"
date: 2026-04-15 00:14:00 +0000
categories: [dashboard]
tags: [satisfactory, ficsitmonitor, production, items, factory, efficiency]
description: "Track Satisfactory factory production and consumption rates per item in FICSIT.monitor. Items/min rates, efficiency percentages, and factory balance overview."
toc: true
---

## Overview

The Production & Consumption panel shows per-item production and consumption rates
across your entire factory, sourced from the FRM `getProdStats` endpoint. It updates
every **30 seconds** and helps identify production bottlenecks and resource imbalances.

> This panel requires the FRM mod. See [Installing FRM]({% post_url 2026-04-15-frm-installation %}).
{: .prompt-info }

---

## Panel Fields

Each row represents one item type (e.g., Iron Ingot, Copper Wire, Circuit Board):

| Field | Description |
|-------|-------------|
| `item_name` | Human-readable item name (e.g., "Iron Plate") |
| `item_class_name` | Game class identifier (e.g., `Desc_IronPlate_C`) |
| `item_type` | Type of item: `item`, `fluid`, or `gas` |
| `current_prod` | Current production rate (items/min) |
| `max_prod` | Maximum possible production rate if all machines ran at 100% |
| `current_consumed` | Current consumption rate (items/min) |
| `max_consumed` | Maximum possible consumption rate |
| `prod_percent` | Production efficiency (current_prod / max_prod × 100) |
| `cons_percent` | Consumption efficiency (current_consumed / max_consumed × 100) |

---

## Reading Production Balance

The key insight from this panel is whether production is keeping up with consumption:

**Healthy item (surplus production):**
```
item_name:       "Iron Ingot"
current_prod:    900 items/min
current_consumed: 720 items/min
prod_percent:    100%  ← all smelters running at full speed
cons_percent:    80%   ← consumers are slightly underutilized
```

**Bottleneck (production deficit):**
```
item_name:       "Copper Wire"
current_prod:    200 items/min
current_consumed: 350 items/min  ← consuming more than produced
prod_percent:    100%  ← constructors running at max
cons_percent:    57%   ← downstream machines are starved
```

When `current_consumed > current_prod`, items are being consumed faster than produced.
Downstream machines will stall when input buffers are empty.

---

## Efficiency Percentages

### `prod_percent` — Production Efficiency

`current_prod / max_prod × 100`

- **100%**: all production machines are running at full speed
- **< 100%**: some machines are idle, paused, or power-starved
- Machines overclock using Power Shards may push `current_prod` above `max_prod`
  (efficiency > 100%)

### `cons_percent` — Consumption Efficiency

`current_consumed / max_consumed × 100`

- **100%**: all consuming machines are running at full demand
- **< 100%**: consuming machines are idle or starved (input depleted)

---

## Sorting and Filtering

The panel allows sorting by:
- Item name (alphabetical)
- Production rate (highest first)
- Balance (current_prod − current_consumed, useful for finding deficits)
- Efficiency percentage

Filter to show only items where production < consumption to quickly find bottlenecks.

---

## Fluid and Gas Items

Items with `item_type: "fluid"` (e.g., Water, Crude Oil, Fuel) and
`item_type: "gas"` (e.g., Nitrogen Gas) display rates in **m³/min** rather than
items/min. The same production balance analysis applies.

---

## Historical Charts

Production metrics are stored as a TimescaleDB time-series, allowing historical views
of how your factory's output has changed over time (within your plan's retention period).

---

## API Reference

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/{SERVER_ID}/production/latest \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Returns an array of `ProductionMetric` objects with the fields described above.
See [Metrics API Reference]({% post_url 2026-04-15-api-metrics %}).
