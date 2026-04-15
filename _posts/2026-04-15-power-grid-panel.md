---
title: "Power Grid Panel"
date: 2026-04-15 00:13:00 +0000
categories: [dashboard]
tags: [satisfactory, ficsitmonitor, power, factory-monitoring, fuses, batteries]
description: "Monitor your Satisfactory factory's power grid in FICSIT.monitor. View MW production, consumption, capacity, battery charge, and fuse alerts per circuit."
toc: true
---

## Overview

The Power Grid panel displays real-time data from every power circuit in your factory.
It uses the FRM `getPower` endpoint, polled every **15 seconds**, and stored as a
time-series for historical charts.

> This panel requires the FRM mod. See [Installing FRM](/posts/frm-installation/).
{: .prompt-info }

---

## Panel Fields

Each power circuit appears as a row. The data fields correspond directly to the
`PowerMetric` model:

| Field | Unit | Description |
|-------|------|-------------|
| `circuit_group_id` | — | Circuit identifier (circuits are numbered automatically) |
| `power_production` | MW | Current power being produced by all generators on this circuit |
| `power_consumed` | MW | Current power being consumed by all machines on this circuit |
| `power_capacity` | MW | Total generator capacity (maximum possible production) |
| `power_max_consumed` | MW | Theoretical maximum consumption if all machines ran at 100% |
| `battery_percent` | % | Current battery charge level (0–100%) |
| `battery_capacity` | MWh | Total battery storage capacity |
| `battery_differential` | MW | Rate of charge/discharge (positive = charging, negative = discharging) |
| `fuse_triggered` | bool | Whether the circuit fuse has blown |

---

## Understanding Power Balance

The most important metric is the relationship between production and consumption:

**Healthy circuit:**
```
power_production = 150 MW
power_consumed   = 120 MW  ← below production
battery_percent  = 100%    ← fully charged
fuse_triggered   = false
```

**Overloaded circuit (fuse about to blow):**
```
power_production = 150 MW
power_consumed   = 162 MW  ← exceeds production
battery_differential = -12 MW  ← batteries draining
battery_percent  = 45%     ← batteries not full
fuse_triggered   = false   ← but will blow soon
```

**Blown fuse:**
```
fuse_triggered   = true    ← ALL machines on this circuit are offline
```

---

## Fuse Alerts

> **Fuse triggered — critical alert.** When `fuse_triggered` is `true`, all machines
> on that circuit have stopped. Production on the entire circuit is zero until you
> repair the fuse in-game (via the Power Switch or the circuit breaker).
{: .prompt-danger }

A fuse blows when consumption exceeds production for long enough to drain the batteries
completely. FICSIT.monitor displays a prominent alert when any circuit's fuse is blown.

---

## Battery Status

Satisfactory uses battery storage (Power Storage machines) to buffer power consumption
spikes. The battery fields help diagnose power grid health:

| `battery_differential` | `battery_percent` | Situation |
|------------------------|-------------------|-----------|
| Positive | < 100% | Batteries charging — good, production exceeds consumption |
| Zero | 100% | Batteries full, power balanced |
| Negative | Falling | Consumption exceeds production — risk of fuse blow |
| Negative | 0% | Fuse is about to blow or has already blown |

---

## Multiple Circuits

Large factories often have multiple power circuits (separated by Power Switches). Each
circuit appears as a separate row in the Power Grid panel, identified by its
`circuit_group_id`.

> If `circuit_group_id` is `1` for all your machines, you have a single circuit.
> Most early/mid-game factories are single-circuit.
{: .prompt-info }

---

## Historical Charts

Power metrics are stored as a time-series (TimescaleDB hypertable). The panel shows
a time-series chart of power production, consumption, and battery differential over
your retention period.

This helps identify:
- When power issues started
- How power demand has grown as you've expanded
- Whether periodic spikes correlate with specific factory events

---

## API Reference

The raw data powering this panel is available via the API:

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/{SERVER_ID}/power/latest \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Response fields match the table above. See [Metrics API Reference](/posts/api-metrics/)
for full documentation.
