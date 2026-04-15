---
title: "Choosing a VPS for Your Satisfactory Server"
date: 2026-04-15 00:01:00 +0000
categories: [server-setup]
tags: [satisfactory, vps, hosting, server-setup, hetzner, digitalocean]
description: "Hardware requirements and VPS provider recommendations for running a Satisfactory dedicated server. Minimum specs, disk sizing, and provider comparison."
toc: true
---

## Overview

Choosing the right VPS is the most important hardware decision for running a Satisfactory
dedicated server. This guide covers minimum and recommended specifications, disk sizing,
and which providers work well for game server hosting.

---

## Hardware Specifications

### CPU

Satisfactory's dedicated server is **single-threaded for world simulation**. Clock speed
matters more than core count for server performance, but you need enough cores to avoid
CPU starvation from the OS and other processes.

| Tier | Cores | Use case |
|------|-------|----------|
| Minimum | 4 vCPU | Small factory, 1–4 players, early game |
| Recommended | 8 vCPU | Medium/large factory, 4–8 players |
| High-end | 16 vCPU | Very large factory, many machines |

### RAM

RAM usage scales with factory complexity. A world with thousands of machines and long
supply chains uses significantly more RAM than an early-game factory.

| Tier | RAM | Use case |
|------|-----|----------|
| Minimum | 12 GB | Early game / small factory |
| Recommended | 16 GB | Mid-game factory |
| Large factory | 24–32 GB | Late-game / megabase |

> If the server runs out of RAM, it will either crash or become unresponsive.
> Start with 16 GB to give yourself room to grow.
{: .prompt-warning }

### Disk

| Component | Size |
|-----------|------|
| Satisfactory server binary (SteamCMD download) | ~8–10 GB |
| Initial save file | < 100 MB |
| Large late-game save | 300–800 MB |
| Buffer for updates + backups | 10 GB |

**Recommended disk**: 75 GB (matches the production Kubernetes deployment in this project).
20 GB is the absolute minimum but leaves little room for growth.

### Network

The server sends physics and game state updates to all connected clients. Upload
bandwidth is the constraint.

- **Minimum**: 10 Mbps upload
- **Recommended**: 100 Mbps upload
- **Players**: ~2–5 Mbps upload per connected player during active gameplay

---

## Recommended VPS Providers

These providers are commonly used for game server hosting and offer bare-metal-level
performance at affordable prices.

### Hetzner (Best value, Europe)

- **Location**: Germany, Finland, USA (Ashburn, Hillsboro)
- **Recommended tier**: CPX31 or CPX41 (4–8 vCPU, 8–16 GB RAM, NVMe SSD)
- **Price**: €10–€22/month
- **Network**: 20 TB/month included, 1 Gbit/s uplink
- **Control panel**: Hetzner Cloud (easy firewall rules)
- [hetzner.com](https://www.hetzner.com/cloud)

### Contabo (Budget option)

- **Location**: Germany, USA, UK, Singapore, Japan, Australia
- **Recommended tier**: VPS M (6 vCPU, 16 GB RAM, 400 GB NVMe)
- **Price**: ~€9/month
- **Note**: CPU is shared and can be throttled under sustained load
- [contabo.com](https://contabo.com)

### OVHcloud

- **Location**: Worldwide (Europe, US, Canada, Asia)
- **Recommended tier**: Starter (4 vCPU, 8 GB) or Value (8 vCPU, 16 GB)
- **Price**: €9–€18/month
- [ovhcloud.com](https://www.ovhcloud.com/en/vps/)

### DigitalOcean

- **Recommended tier**: General Purpose 8 GB Droplet
- **Price**: ~$48/month (more expensive but excellent reliability)
- **Note**: Good for teams already using DigitalOcean
- [digitalocean.com](https://www.digitalocean.com)

---

## Operating System

**Recommended: Ubuntu 24.04 LTS** (supported until April 2029)

All commands in this documentation target Ubuntu 22.04 or 24.04 LTS. Other Linux
distributions work but may require adjusted package manager commands.

When provisioning your VPS, select:
- **OS**: Ubuntu 24.04 LTS (or 22.04 LTS)
- **Architecture**: x86_64 (amd64)
- Do NOT use ARM-based instances — Docker images for the Satisfactory server require amd64

---

## Storage Type

Use **NVMe SSD** or SSD storage only. The Satisfactory dedicated server does frequent
read/write operations for saves, checkpoints, and logging. Spinning HDD storage causes
perceptible stuttering in the game world.

---

## IPv4 vs IPv6

The Satisfactory dedicated server requires a **public IPv4 address**. The game client
does not support connecting via IPv6. Ensure your VPS has a dedicated public IPv4 (most
VPS plans include one).

---

## What This Project Uses in Production

The server running FICSIT.monitor in production (46.224.182.211) uses a **bare-metal
Kubernetes cluster** on a Hetzner dedicated server with:
- 8 CPU cores
- 32 GB RAM
- 500 GB NVMe SSD

The Satisfactory game server pod is allocated 2–4 CPU cores and 8–16 GB RAM
(see the [Kubernetes Deployment guide](/posts/kubernetes-deployment/) for full manifest details).

---

## Next Step

[Install Docker on Ubuntu →](/posts/install-docker/)
