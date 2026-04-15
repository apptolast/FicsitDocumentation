---
title: "Environment Variables Reference"
date: 2026-04-15 00:19:00 +0000
categories: [deployment]
tags: [satisfactory, ficsitmonitor, environment-variables, configuration, docker, kubernetes]
description: "Complete reference for all FICSIT.monitor environment variables. Database, Redis, Reverb WebSocket, Satisfactory server connection, and application settings."
toc: true
---

## Overview

FICSIT.monitor is a Laravel 12 application. All configuration is done through
environment variables, either in a `.env` file for local development or Kubernetes
Secrets/ConfigMaps for production.

> Never commit your `.env` file or Kubernetes Secrets to a public repository.
> The `.env.example` file provides a safe template with no real values.
{: .prompt-danger }

---

## Application Settings

| Variable | Example | Description |
|----------|---------|-------------|
| `APP_NAME` | `Satisfactory Dashboard` | Application display name |
| `APP_ENV` | `production` | Environment: `local`, `production` |
| `APP_KEY` | `base64:xxx...` | Laravel application encryption key. Generate with `php artisan key:generate` |
| `APP_DEBUG` | `false` | Enable debug mode. **Set to `false` in production** |
| `APP_URL` | `https://your-domain.com` | Public URL of the application |
| `APP_LOCALE` | `en` | Application locale |

---

## Database (PostgreSQL + TimescaleDB)

| Variable | Example | Description |
|----------|---------|-------------|
| `DB_CONNECTION` | `pgsql` | Database driver — **must be `pgsql`** (PostgreSQL) |
| `DB_HOST` | `postgres` | Database hostname (K8s service name or IP) |
| `DB_PORT` | `5432` | PostgreSQL port |
| `DB_DATABASE` | `satisfactory_dashboard` | Database name |
| `DB_USERNAME` | `satisfactory` | Database user |
| `DB_PASSWORD` | `strong_password` | Database password |

> TimescaleDB must be installed and enabled in PostgreSQL. The migrations run
> `CREATE EXTENSION timescaledb;` and create hypertables for time-series data.
{: .prompt-warning }

---

## Redis

| Variable | Example | Description |
|----------|---------|-------------|
| `REDIS_CLIENT` | `phpredis` | PHP Redis client. Use `phpredis` for best performance |
| `REDIS_HOST` | `redis` | Redis hostname (K8s service name or IP) |
| `REDIS_PASSWORD` | `null` | Redis password (null if no auth configured) |
| `REDIS_PORT` | `6379` | Redis port |

Redis is used for: queue backing (Horizon), session storage, and current-state metric cache.

---

## Session & Queue

| Variable | Value | Description |
|----------|-------|-------------|
| `SESSION_DRIVER` | `redis` | **Must be `redis`** for WebSocket authentication to work |
| `SESSION_LIFETIME` | `120` | Session lifetime in minutes |
| `QUEUE_CONNECTION` | `redis` | **Must be `redis`** — uses Laravel Horizon |
| `CACHE_STORE` | `redis` | Cache backend |
| `BROADCAST_CONNECTION` | `reverb` | **Must be `reverb`** — uses Laravel Reverb WebSocket |

---

## WebSocket (Laravel Reverb)

| Variable | Example | Description |
|----------|---------|-------------|
| `REVERB_APP_ID` | `satisfactory-dashboard` | Reverb application ID |
| `REVERB_APP_KEY` | `your-reverb-key` | Reverb application key (also used by frontend) |
| `REVERB_APP_SECRET` | `your-reverb-secret` | Reverb application secret |
| `REVERB_HOST` | `reverb-service` | Hostname of the Reverb WebSocket server |
| `REVERB_PORT` | `8080` | Internal Reverb port |
| `REVERB_SCHEME` | `http` | Internal scheme (`http` inside K8s, `https` if behind proxy) |

**Frontend variables** (used by Vite to build the React frontend):

| Variable | Value | Description |
|----------|-------|-------------|
| `VITE_APP_NAME` | `${APP_NAME}` | App name for frontend |
| `VITE_REVERB_APP_KEY` | `${REVERB_APP_KEY}` | Reverb key for Laravel Echo |
| `VITE_REVERB_HOST` | `your-domain.com` | Public hostname for WebSocket connections |
| `VITE_REVERB_PORT` | `443` | Public WebSocket port (443 if using HTTPS/WSS) |
| `VITE_REVERB_SCHEME` | `https` | Public WebSocket scheme |

> `VITE_REVERB_HOST` should be your public domain, not the internal service name.
> Clients connect to it from their browsers.
{: .prompt-warning }

---

## Satisfactory Server Connection

These variables configure how FICSIT.monitor connects to your Satisfactory server.
In production, these are set dynamically per-server via the database. The env vars
below are for a single default server in development/testing scenarios.

| Variable | Example | Description |
|----------|---------|-------------|
| `SATISFACTORY_SERVER_HOST` | `46.224.182.211` | IP address of the Satisfactory server |
| `SATISFACTORY_API_PORT` | `7777` | Satisfactory vanilla HTTPS API port |
| `SATISFACTORY_API_TOKEN` | (empty) | Pre-configured API token (optional; FICSIT.monitor generates tokens via PasswordLogin) |
| `SATISFACTORY_FRM_HOST` | `46.224.182.211` | IP address for FRM access (usually same as server host) |
| `SATISFACTORY_FRM_PORT` | `8080` | FRM HTTP API port |

> In Kubernetes, `SATISFACTORY_FRM_HOST` can be the internal ClusterIP service name
> `satisfactory-frm.satisfactory.svc.cluster.local` when the dashboard and game server
> are in the same cluster, avoiding external network traffic.
{: .prompt-info }

---

## Mail (Optional)

Mail is used for account-related emails. In development, `MAIL_MAILER=log` writes
emails to the application log instead of sending them.

| Variable | Value | Description |
|----------|-------|-------------|
| `MAIL_MAILER` | `log` (dev) / `smtp` (prod) | Mail driver |
| `MAIL_HOST` | `smtp.example.com` | SMTP server hostname |
| `MAIL_PORT` | `587` | SMTP port |
| `MAIL_USERNAME` | `user@example.com` | SMTP username |
| `MAIL_PASSWORD` | `password` | SMTP password |
| `MAIL_FROM_ADDRESS` | `no-reply@yourdomain.com` | Sender email address |
| `MAIL_FROM_NAME` | `FICSIT.monitor` | Sender display name |

---

## Minimum Production `.env`

A minimal working production configuration:

```bash
APP_NAME="FICSIT.monitor"
APP_ENV=production
APP_KEY=base64:GENERATE_THIS_WITH_ARTISAN
APP_DEBUG=false
APP_URL=https://your-domain.com

DB_CONNECTION=pgsql
DB_HOST=postgres
DB_PORT=5432
DB_DATABASE=satisfactory_dashboard
DB_USERNAME=satisfactory
DB_PASSWORD=STRONG_PASSWORD

REDIS_CLIENT=phpredis
REDIS_HOST=redis
REDIS_PORT=6379

SESSION_DRIVER=redis
QUEUE_CONNECTION=redis
BROADCAST_CONNECTION=reverb
CACHE_STORE=redis

REVERB_APP_ID=satisfactory-dashboard
REVERB_APP_KEY=YOUR_REVERB_KEY
REVERB_APP_SECRET=YOUR_REVERB_SECRET
REVERB_HOST=reverb
REVERB_PORT=8080
REVERB_SCHEME=http

VITE_REVERB_APP_KEY=YOUR_REVERB_KEY
VITE_REVERB_HOST=your-domain.com
VITE_REVERB_PORT=443
VITE_REVERB_SCHEME=https
```
