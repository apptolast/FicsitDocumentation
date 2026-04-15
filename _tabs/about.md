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

1. [What is a Satisfactory Dedicated Server?]({% post_url 2026-04-15-what-is-satisfactory-server %}) — start here if you're new to dedicated servers
2. [Choosing a VPS]({% post_url 2026-04-15-vps-requirements %}) — hardware and provider recommendations
3. [Installing Docker on Ubuntu]({% post_url 2026-04-15-install-docker %}) — required to run the server
4. [Running Satisfactory with Docker]({% post_url 2026-04-15-run-satisfactory-docker %}) — deploy the game server
5. [Firewall & Port Configuration]({% post_url 2026-04-15-server-firewall %}) — open the required ports
6. [First Launch & World Setup]({% post_url 2026-04-15-server-first-launch %}) — connect and create your world
7. [Installing FicsitRemoteMonitoring (FRM)]({% post_url 2026-04-15-frm-installation %}) — required for factory metrics
8. [What is FICSIT.monitor?]({% post_url 2026-04-15-what-is-ficsitmonitor %}) — overview of the monitoring platform
9. [Quick Start: Monitor in 10 Minutes]({% post_url 2026-04-15-quick-start %}) — connect FICSIT.monitor to your server

---

## Server Setup

Complete guide to running a Satisfactory dedicated server.

| Guide | Description |
|-------|-------------|
| [What is a Dedicated Server?]({% post_url 2026-04-15-what-is-satisfactory-server %}) | Concepts, use cases, hardware requirements |
| [Choosing a VPS]({% post_url 2026-04-15-vps-requirements %}) | Specs, providers, OS recommendations |
| [Installing Docker on Ubuntu]({% post_url 2026-04-15-install-docker %}) | Docker CE install on Ubuntu 22.04/24.04 |
| [Running with Docker]({% post_url 2026-04-15-run-satisfactory-docker %}) | Docker run command, Compose, env vars |
| [Firewall & Ports]({% post_url 2026-04-15-server-firewall %}) | UFW rules, cloud security groups |
| [First Launch & World Setup]({% post_url 2026-04-15-server-first-launch %}) | Connect client, create world, admin password |
| [Server Configuration]({% post_url 2026-04-15-server-configuration %}) | Max players, autosave, server name |

---

## Prerequisites for FICSIT.monitor

Required setup on your Satisfactory server before connecting to FICSIT.monitor.

| Guide | Description |
|-------|-------------|
| [Installing FRM]({% post_url 2026-04-15-frm-installation %}) | FicsitRemoteMonitoring mod — enables factory metrics |
| [Generating Your API Token]({% post_url 2026-04-15-api-token %}) | Admin password and authentication token setup |

---

## Getting Started with FICSIT.monitor

| Guide | Description |
|-------|-------------|
| [What is FICSIT.monitor?]({% post_url 2026-04-15-what-is-ficsitmonitor %}) | Platform overview, features, and pricing summary |
| [Quick Start Guide]({% post_url 2026-04-15-quick-start %}) | From zero to monitored in 10 minutes |
| [Adding Your First Server]({% post_url 2026-04-15-add-first-server %}) | Server form fields and onboarding errors |

---

## Dashboard

Detailed walkthroughs for each monitoring panel.

| Guide | Description |
|-------|-------------|
| [Dashboard Overview]({% post_url 2026-04-15-dashboard-overview %}) | Tour of all panels, polling cadence, live updates |
| [Power Grid Panel]({% post_url 2026-04-15-power-grid-panel %}) | Circuit power, batteries, fuse alerts |
| [Production & Consumption Panel]({% post_url 2026-04-15-production-panel %}) | Items/min rates and factory balance |
| [Players & Sessions Panel]({% post_url 2026-04-15-players-sessions %}) | Online players, health, position |
| [Trains & Drone Stations Panel]({% post_url 2026-04-15-trains-drones %}) | Derailment alerts, travel times, throughput |
| [Factory Buildings Panel]({% post_url 2026-04-15-factory-buildings %}) | Per-machine efficiency %, recipe, overclocking |

---

## Deployment

Advanced deployment guides for self-hosters.

| Guide | Description |
|-------|-------------|
| [Kubernetes Deployment]({% post_url 2026-04-15-kubernetes-deployment %}) | Full K8s setup with Traefik, TLS, and Keel |
| [Environment Variables Reference]({% post_url 2026-04-15-environment-variables %}) | All .env variables explained |

---

## API Reference

| Guide | Description |
|-------|-------------|
| [REST API Overview]({% post_url 2026-04-15-api-overview %}) | Base URL, authentication, rate limits, errors |
| [API Authentication]({% post_url 2026-04-15-api-authentication %}) | Sanctum tokens and session auth |
| [Servers API]({% post_url 2026-04-15-api-servers %}) | CRUD operations, onboarding, error codes |
| [Metrics API]({% post_url 2026-04-15-api-metrics %}) | All /v1/servers/{id}/ endpoints and response fields |

---

## Pricing

| Guide | Description |
|-------|-------------|
| [Plans & Pricing]({% post_url 2026-04-15-pricing-plans %}) | Free, Hobby, Pro, Team, and Enterprise tiers |

---

## Troubleshooting

| Guide | Description |
|-------|-------------|
| [FAQ]({% post_url 2026-04-15-faq %}) | 15 most common questions answered |
| [Common Errors & Solutions]({% post_url 2026-04-15-troubleshooting %}) | Error codes with causes and fixes |
| [Server Won't Connect]({% post_url 2026-04-15-connection-errors %}) | Step-by-step connectivity diagnosis |

---

> **Live dashboard:** [satisfactory-dashboard.pablohgdev.com](https://satisfactory-dashboard.pablohgdev.com)
{: .prompt-info }
