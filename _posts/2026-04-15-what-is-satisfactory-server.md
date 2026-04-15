---
title: "What is a Satisfactory Dedicated Server?"
date: 2026-04-15 00:00:00 +0000
categories: [server-setup]
tags: [satisfactory, dedicated-server, game-server, hosting]
description: "Learn what a Satisfactory dedicated server is, why you might want one, and the hardware requirements to run it on a VPS or home machine."
toc: true
---

## Overview

A **Satisfactory dedicated server** is a standalone game server process that runs your
factory world continuously — 24 hours a day, 7 days a week — independently of any
player's machine. Unlike hosting a game from within Satisfactory (where the world
stops when you close the game), a dedicated server keeps running whether anyone is
connected or not.

FICSIT.monitor connects to your dedicated server to provide real-time monitoring of
your factory — power grids, production rates, connected players, trains, drones, and
individual machine efficiency.

---

## Dedicated Server vs. Host-from-Client

| | Host from Client | Dedicated Server |
|---|---|---|
| World runs when... | You have the game open | Always (24/7) |
| Performance | Shares resources with your PC | Dedicated hardware |
| Connection stability | Depends on your internet | VPS-grade uptime |
| FICSIT.monitor compatible | No | Yes |
| Setup complexity | None | Moderate |

If you want friends to be able to join at any time, or if you want FICSIT.monitor to
monitor your factory continuously, you need a dedicated server.

---

## Common Use Cases

- **Friends group** — Run a shared factory world that anyone can join at any time, without requiring one person to keep the game open
- **Community server** — Host a public or semi-public server for a larger group of players
- **24/7 factory monitoring** — Use FICSIT.monitor to track production, power, and efficiency even when you're offline
- **Long-running campaigns** — Keep the world persistent across weeks or months of play

---

## Hardware Requirements

Satisfactory is resource-intensive compared to most dedicated game servers. The game
simulates physics, production calculations, and pathfinding for all machines in the
factory.

| Resource | Minimum | Recommended |
|----------|---------|-------------|
| **CPU** | 4 cores | 8 cores |
| **RAM** | 12 GB | 16 GB |
| **Disk** | 20 GB | 75 GB |
| **Network** | 10 Mbps | 100 Mbps |
| **OS** | Ubuntu 22.04 LTS | Ubuntu 24.04 LTS |

> RAM usage grows as your factory expands. A small early-game factory may run on 8 GB,
> but a mid/late-game factory with thousands of machines can use 12–16 GB or more.
{: .prompt-warning }

> Disk usage includes the game files (~8–10 GB after installation via SteamCMD) plus
> save files, which grow with factory complexity. 75 GB provides comfortable room for
> save backups and game updates.
{: .prompt-info }

---

## What You Need Before Starting

1. **A VPS or machine** meeting the hardware requirements above
   → See [Choosing a VPS for Your Satisfactory Server]({% post_url 2026-04-15-vps-requirements %})

2. **Ubuntu 22.04 or 24.04 LTS** installed on your server

3. **Docker** installed
   → See [Installing Docker on Ubuntu]({% post_url 2026-04-15-install-docker %})

4. **Ports opened in your firewall**: 7777 TCP+UDP, 8888 TCP, 8080 TCP, 8081 TCP
   → See [Firewall & Port Configuration]({% post_url 2026-04-15-server-firewall %})

5. **A Satisfactory game license** (the game itself — not required for the server binary,
   but needed to connect as a client and configure the server)

---

## What You Do NOT Need

- A copy of Satisfactory installed on the server — the dedicated server uses its own
  separate binary (downloaded automatically via SteamCMD inside the Docker image)
- A Steam account on the server — SteamCMD downloads the server anonymously
- A GPU — the dedicated server runs headlessly with no graphical output

---

## Next Step

[Choose a VPS →]({% post_url 2026-04-15-vps-requirements %})
