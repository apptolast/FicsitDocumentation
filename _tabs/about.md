---
icon: fas fa-book
order: 1
title: Documentation
---

Welcome to the **FICSIT.monitor** documentation. FICSIT.monitor is a real-time monitoring
platform for Satisfactory dedicated servers — follow these guides to set up your server
and start monitoring your factory.

---

## Getting Started

The fastest path to a monitored server:

1. [What is a Satisfactory Dedicated Server?](/posts/what-is-satisfactory-server/) — start here if you're new to dedicated servers
2. [Choosing a VPS](/posts/vps-requirements/) — hardware and provider recommendations
3. [Installing Docker on Ubuntu](/posts/install-docker/) — required to run the server
4. [Running Satisfactory with Docker](/posts/run-satisfactory-docker/) — deploy the game server
5. [Firewall & Port Configuration](/posts/server-firewall/) — open the required ports
6. [First Launch & World Setup](/posts/server-first-launch/) — connect and create your world
7. [Installing FicsitRemoteMonitoring (FRM)](/posts/frm-installation/) — required for factory metrics
8. [What is FICSIT.monitor?](/posts/what-is-ficsitmonitor/) — overview of the monitoring platform
9. [Quick Start: Monitor in 10 Minutes](/posts/quick-start/) — connect FICSIT.monitor to your server

---

## Server Setup

Complete guide to running a Satisfactory dedicated server.

| Guide | Description |
|-------|-------------|
| [What is a Dedicated Server?](/posts/what-is-satisfactory-server/) | Concepts, use cases, hardware requirements |
| [Choosing a VPS](/posts/vps-requirements/) | Specs, providers, OS recommendations |
| [Installing Docker on Ubuntu](/posts/install-docker/) | Docker CE install on Ubuntu 22.04/24.04 |
| [Running with Docker](/posts/run-satisfactory-docker/) | Docker run command, Compose, env vars |
| [Firewall & Ports](/posts/server-firewall/) | UFW rules, cloud security groups |
| [First Launch & World Setup](/posts/server-first-launch/) | Connect client, create world, admin password |
| [Server Configuration](/posts/server-configuration/) | Max players, autosave, server name |

---

## Prerequisites for FICSIT.monitor

Required setup on your Satisfactory server before connecting to FICSIT.monitor.

| Guide | Description |
|-------|-------------|
| [Installing FRM](/posts/frm-installation/) | FicsitRemoteMonitoring mod — enables factory metrics |
| [Generating Your API Token](/posts/api-token/) | Admin password and authentication token setup |

---

## Getting Started with FICSIT.monitor

| Guide | Description |
|-------|-------------|
| [What is FICSIT.monitor?](/posts/what-is-ficsitmonitor/) | Platform overview, features, and pricing summary |
| [Quick Start Guide](/posts/quick-start/) | From zero to monitored in 10 minutes |
| [Adding Your First Server](/posts/add-first-server/) | Server form fields and onboarding errors |

---

## Dashboard

Detailed walkthroughs for each monitoring panel.

| Guide | Description |
|-------|-------------|
| [Dashboard Overview](/posts/dashboard-overview/) | Tour of all panels, polling cadence, live updates |
| [Power Grid Panel](/posts/power-grid-panel/) | Circuit power, batteries, fuse alerts |
| [Production & Consumption Panel](/posts/production-panel/) | Items/min rates and factory balance |
| [Players & Sessions Panel](/posts/players-sessions/) | Online players, health, position |
| [Trains & Drone Stations Panel](/posts/trains-drones/) | Derailment alerts, travel times, throughput |
| [Factory Buildings Panel](/posts/factory-buildings/) | Per-machine efficiency %, recipe, overclocking |

---

## Deployment

Advanced deployment guides for self-hosters.

| Guide | Description |
|-------|-------------|
| [Kubernetes Deployment](/posts/kubernetes-deployment/) | Full K8s setup with Traefik, TLS, and Keel |
| [Environment Variables Reference](/posts/environment-variables/) | All .env variables explained |

---

## API Reference

| Guide | Description |
|-------|-------------|
| [REST API Overview](/posts/api-overview/) | Base URL, authentication, rate limits, errors |
| [API Authentication](/posts/api-authentication/) | Sanctum tokens and session auth |
| [Servers API](/posts/api-servers/) | CRUD operations, onboarding, error codes |
| [Metrics API](/posts/api-metrics/) | All /v1/servers/{id}/ endpoints and response fields |

---

## Pricing

| Guide | Description |
|-------|-------------|
| [Plans & Pricing](/posts/pricing-plans/) | Free, Hobby, Pro, Team, and Enterprise tiers |

---

## Troubleshooting

| Guide | Description |
|-------|-------------|
| [FAQ](/posts/faq/) | 15 most common questions answered |
| [Common Errors & Solutions](/posts/troubleshooting/) | Error codes with causes and fixes |
| [Server Won't Connect](/posts/connection-errors/) | Step-by-step connectivity diagnosis |

---

> **Live dashboard:** [satisfactory-dashboard.pablohgdev.com](https://satisfactory-dashboard.pablohgdev.com)
{: .prompt-info }
