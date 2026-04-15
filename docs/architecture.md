# FICSIT.monitor Docs — Information Architecture

> **Agent reference document.** Not published to the website (in Jekyll's `exclude:` list).
> This is the IA plan for the documentation site itself — what pages to create,
> how navigation is structured, and what content goes where.

---

## 1. Site Identity

| Field | Value |
|-------|-------|
| **Title** | FICSIT.monitor Documentation |
| **Tagline** | Real-time monitoring for Satisfactory dedicated servers |
| **Theme** | jekyll-theme-chirpy v7.5, dark mode |
| **Deploy** | GitHub Pages via GitHub Actions (push to main) |
| **Audience** | Satisfactory server admins running dedicated servers on VPS or bare-metal |

---

## 2. Navigation Structure (Chirpy Tabs)

Tabs live in `_tabs/`. Chirpy renders them as top-level navigation.

| File | Title | Icon | Order | Purpose |
|------|-------|------|-------|---------|
| `_tabs/about.md` | Documentation | `fas fa-book` | 1 | Docs hub — table of contents for all pages |
| `_tabs/categories.md` | By Topic | `fas fa-stream` | 2 | Browse docs by category |
| `_tabs/archives.md` | Changelog | `fas fa-archive` | 3 | Release notes and updates |
| `_tabs/tags.md` | Tags | `fas fa-tags` | 4 | Tag cloud for discoverability |

The `_tabs/about.md` file should be repurposed as the Documentation hub — a table of
contents linking to all major sections.

---

## 3. Documentation Purpose & Reader Journey

**Primary goal:** Help someone who has a VPS (or any machine) set up a Satisfactory
dedicated server from scratch, and then connect it to FICSIT.monitor to monitor it.

**Reader journey:**
```
1. server-setup       → How do I run a Satisfactory dedicated server?
2. prerequisites      → How do I install FRM and open the ports?
3. getting-started    → How do I sign up for FICSIT.monitor and connect my server?
4. dashboard          → How do I read the metrics?
5. (advanced)         → API, alerts, self-hosting, pricing
```

The documentation is NOT about how FICSIT.monitor is built internally.
It is about **what the user must do** to have a working monitored server.

---

## 4. Documentation Pages (All as Jekyll `_posts/`)

All documentation is created as dated posts in `_posts/`. Chirpy's category/tag system
provides navigation. Posts use front matter to control categorization.

**Filename convention**: `YYYY-MM-DD-slug.md` (use `2026-04-15` as base date)

**Front matter template**:
```yaml
---
title: "Page Title"
date: 2026-04-15 00:00:00 +0000
categories: [category-name]
tags: [satisfactory, ficsitmonitor, tag3, tag4]
description: "SEO meta description — must be 150-160 characters."
toc: true
pin: false
---
```

---

### Category: `server-setup` ⭐ PRIMARY CATEGORY

**This is the heart of the documentation.** How to run a Satisfactory dedicated server
from scratch on a VPS or bare-metal machine. Most users arrive here first.

| # | Filename | Title | Key content |
|---|----------|-------|-------------|
| 1 | `2026-04-15-what-is-satisfactory-server.md` | Running a Satisfactory Dedicated Server | What a dedicated server is, why run one, use cases, hardware requirements |
| 2 | `2026-04-15-vps-requirements.md` | Choosing a VPS for Satisfactory | Minimum specs (CPU, RAM, disk), recommended VPS providers (Hetzner, DigitalOcean, etc.) |
| 3 | `2026-04-15-install-docker.md` | Installing Docker on Ubuntu | Prerequisites, Docker CE install on Ubuntu 22.04/24.04, docker compose plugin |
| 4 | `2026-04-15-run-satisfactory-docker.md` | Running Satisfactory with Docker | wolveix/satisfactory-server image, docker run command, volume setup, env vars, first boot |
| 5 | `2026-04-15-server-configuration.md` | Configuring Your Server | Max players, autosave interval, server name, admin password via game console or API |
| 6 | `2026-04-15-server-firewall.md` | Firewall & Port Configuration | Required ports (7777 TCP+UDP, 8888 TCP, 8080 TCP, 8081 TCP), UFW rules, cloud security groups |
| 7 | `2026-04-15-server-first-launch.md` | First Launch & World Creation | Connecting the game client to your server, creating a world, saving |

---

### Category: `getting-started`

Connecting your running server to FICSIT.monitor (after server-setup is complete).

| # | Filename | Title | Key content |
|---|----------|-------|-------------|
| 8 | `2026-04-15-what-is-ficsitmonitor.md` | What is FICSIT.monitor? | Product overview, what it monitors, why subscribe, pricing tiers |
| 9 | `2026-04-15-quick-start.md` | Quick Start Guide | End-to-end in 10 minutes: server running → FRM installed → FICSIT.monitor connected |
| 10 | `2026-04-15-account-setup.md` | Creating Your Account | Registration, plan selection |
| 11 | `2026-04-15-add-first-server.md` | Adding Your First Server | Server wizard: host IP, ports, admin password, onboarding flow |

---

### Category: `prerequisites`

Required setup BEFORE connecting to FICSIT.monitor. Server must already be running (server-setup).

| # | Filename | Title | Key content |
|---|----------|-------|-------------|
| 12 | `2026-04-15-frm-installation.md` | Installing FicsitRemoteMonitoring (FRM) | What FRM is, why it's needed, installing via Satisfactory Mod Manager, verifying ports 8080/8081 |
| 13 | `2026-04-15-api-token.md` | Generating Your API Token | Admin password setup, generating token via game console or PasswordlessLogin API call |

---

### Category: `dashboard`

Feature walkthroughs for each dashboard panel.

| # | Filename | Title | Key content |
|---|----------|-------|-------------|
| 8 | `2026-04-15-dashboard-overview.md` | Dashboard Overview | Layout tour, all panels at a glance, real-time update indicator, polling cadence |
| 9 | `2026-04-15-power-grid-panel.md` | Power Grid Panel | Circuit data, MW produced/consumed/capacity, battery %, fuse alerts, fuse_triggered field |
| 10 | `2026-04-15-production-panel.md` | Production & Consumption Panel | Items/min rates, balance (production vs consumption), sorting/filtering |
| 11 | `2026-04-15-players-sessions.md` | Players & Sessions | Online players, health, position data, session history, player count chart |
| 12 | `2026-04-15-trains-drones.md` | Trains & Drones | Train speed/fuel/derailment, drone station inventory, flight time |
| 13 | `2026-04-15-factory-buildings.md` | Factory Buildings Panel | Per-building efficiency %, recipe, inventory — requires FRM getFactory |

---

### Category: `deployment`

How to deploy FICSIT.monitor itself (for self-hosters or enterprise).

| # | Filename | Title | Key content |
|---|----------|-------|-------------|
| 14 | `2026-04-15-kubernetes-deployment.md` | Kubernetes Deployment | Full K8s setup: namespaces, StatefulSets, services, Traefik ingress, TLS, Keel auto-deploy |
| 15 | `2026-04-15-docker-compose.md` | Docker Compose (Self-Hosted) | Simplified local/small-scale deployment with docker-compose |
| 16 | `2026-04-15-environment-variables.md` | Environment Variables Reference | All .env variables with descriptions, required vs optional, example values |

---

### Category: `api-reference`

Technical API documentation. Written by `tech-writer` agent (uses Opus).

| # | Filename | Title | Key content |
|---|----------|-------|-------------|
| 17 | `2026-04-15-api-overview.md` | REST API Overview | Base URL, authentication flow, rate limits, response format, error codes |
| 18 | `2026-04-15-api-authentication.md` | API Authentication | Sanctum Personal Access Tokens, creating tokens, using PATs in requests, cookie auth for SPA |
| 19 | `2026-04-15-api-servers.md` | Servers API | CRUD endpoints for servers, onboarding request/response, error handling |
| 20 | `2026-04-15-api-metrics.md` | Metrics API | All `/v1/servers/{id}/*` endpoints with field definitions, example responses |
| 21 | `2026-04-15-api-websockets.md` | WebSocket Events | Reverb channels, event types, connecting with Laravel Echo / Pusher JS |

---

### Category: `alerts`

Configuring notifications when server metrics cross thresholds.

| # | Filename | Title | Key content |
|---|----------|-------|-------------|
| 22 | `2026-04-15-alert-rules.md` | Configuring Alert Rules | Creating rules, supported metrics, conditions, threshold configuration |
| 23 | `2026-04-15-discord-alerts.md` | Discord Notifications | Setting up Discord webhook, alert message format, testing |
| 24 | `2026-04-15-webhook-alerts.md` | Webhook Integration | Custom webhook setup, payload format, retry behavior, HMAC signing |

---

### Category: `pricing`

Plans, billing, and subscription management.

| # | Filename | Title | Key content |
|---|----------|-------|-------------|
| 25 | `2026-04-15-pricing-plans.md` | Plans & Pricing | Full tier comparison (Free/Hobby/Pro/Team/Enterprise), feature matrix |
| 26 | `2026-04-15-subscription.md` | Managing Your Subscription | Upgrading/downgrading, billing portal, cancellation, data retention after cancellation |

---

### Category: `troubleshooting`

FAQs and error resolution guides.

| # | Filename | Title | Key content |
|---|----------|-------|-------------|
| 27 | `2026-04-15-faq.md` | Frequently Asked Questions | Top 15 questions: FRM not showing data, connection refused, wrong port, etc. |
| 28 | `2026-04-15-troubleshooting.md` | Common Errors | Error codes from the API (422, 502, 500) with resolution steps |
| 29 | `2026-04-15-connection-errors.md` | Server Won't Connect | Diagnosing connectivity: firewall, port forwarding, TLS, FRM not running |

---

## 4. `_tabs/about.md` — Documentation Hub

This file should be edited to serve as the documentation table of contents.
Chirpy renders `about.md` as the "About" tab (icon + sidebar). We repurpose it as "Documentation".

Content structure:
```markdown
---
title: Documentation
icon: fas fa-book
order: 1
---

# FICSIT.monitor Documentation

[intro paragraph]

## Getting Started
- [What is FICSIT.monitor?](link)
- [Quick Start Guide](link)
...

## Prerequisites
- [Installing FRM](link)
...

[etc. for each category]
```

---

## 5. Assets Structure

```
assets/
├── img/
│   ├── posts/        ← screenshots used within post content
│   ├── og/           ← Open Graph images (1200×630 PNG, one per post)
│   └── favicons/     ← favicon set (replace with FICSIT.monitor brand later)
└── css/
    └── custom.scss   ← optional custom CSS overrides (create if needed)
```

### OG Image naming:
`assets/img/og/{post-slug}-og.png`
Example: `assets/img/og/quick-start-og.png`

---

## 6. `_config.yml` Target Values

The jekyll-developer agent should set these in `_config.yml`:

```yaml
title: "FICSIT.monitor Docs"
tagline: "Real-time monitoring for Satisfactory dedicated servers"
description: >-
  Official documentation for FICSIT.monitor — real-time Satisfactory server
  monitoring with FRM integration, power panels, production metrics, and alerts.
lang: en
theme_mode: dark
toc: true

social:
  name: Pablo Hurtado Gonzalo
  email: pablohurtadohg@gmail.com
  links:
    - https://github.com/PabloHurtadoGonzalo86

github:
  username: PabloHurtadoGonzalo86
```

---

## 7. Post Cross-link Map

Key linking relationships between posts (ensures reader flow):

| From | Should link to |
|------|---------------|
| quick-start | frm-installation, network-ports, add-first-server |
| frm-installation | network-ports, api-token |
| network-ports | api-token |
| add-first-server | dashboard-overview |
| dashboard-overview | power-grid-panel, production-panel, players-sessions |
| api-overview | api-authentication, api-servers, api-metrics |
| kubernetes-deployment | environment-variables |
| pricing-plans | subscription, quick-start |
| troubleshooting | connection-errors, faq |
| connection-errors | network-ports, frm-installation |

---

## 8. SEO Keywords Map

Target primary keywords for top discovery pages:

| Page | Primary keyword | Secondary keywords |
|------|----------------|-------------------|
| what-is-ficsitmonitor | satisfactory server monitoring | ficsit monitor, factory dashboard |
| quick-start | ficsit monitor setup | satisfactory dedicated server monitor |
| frm-installation | ficsitremotemonitoring install | FRM mod satisfactory |
| network-ports | satisfactory dedicated server ports | port 7777 8080 satisfactory |
| kubernetes-deployment | satisfactory kubernetes | satisfactory server k8s |
| pricing-plans | ficsit monitor pricing | satisfactory monitoring saas |
| api-overview | ficsit monitor api | satisfactory monitoring rest api |
