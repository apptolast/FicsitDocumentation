---
title: "Servers API"
date: 2026-04-15 00:22:00 +0000
categories: [api-reference]
tags: [satisfactory, ficsitmonitor, api, servers-api, onboarding]
description: "Manage Satisfactory servers via the FICSIT.monitor API. List, create, update, and delete server connections. Onboarding request fields and error codes."
toc: true
---

## Overview

The Servers API provides CRUD operations for managing your Satisfactory server
connections in FICSIT.monitor. All endpoints require authentication.

**Base path:** `/api/v1/servers`

---

## Server Object

The API returns servers in this format:

```json
{
  "id": "uuid",
  "name": "My Factory Server",
  "host": "46.224.182.211",
  "api_port": 7777,
  "frm_http_port": 8080,
  "status": "online",
  "last_seen_at": "2026-04-15T12:00:00Z",
  "created_at": "2026-04-01T00:00:00Z"
}
```

| Field | Description |
|-------|-------------|
| `id` | UUID — use this to reference the server in metric endpoints |
| `name` | Display name |
| `host` | IP address of the server |
| `api_port` | Vanilla API port (usually 7777) |
| `frm_http_port` | FRM HTTP API port (usually 8080) |
| `status` | `online`, `offline`, or `degraded` |
| `last_seen_at` | Last time the server responded to a health check |
| `created_at` | When this server was added to FICSIT.monitor |

> `frm_ws_port` and `api_token` are not included in the response.
{: .prompt-info }

---

## GET /api/v1/servers

List all servers belonging to the authenticated user.

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

**Response (200):**

```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Production Server",
    "host": "46.224.182.211",
    "api_port": 7777,
    "frm_http_port": 8080,
    "status": "online",
    "last_seen_at": "2026-04-15T12:00:00Z",
    "created_at": "2026-04-01T00:00:00Z"
  }
]
```

---

## POST /api/v1/servers

Add a new Satisfactory server to FICSIT.monitor. This triggers the onboarding
sequence: connectivity check, authentication, and initial metrics fetch.

**Request body:**

```json
{
  "name": "My Factory Server",
  "host": "YOUR_SERVER_IP",
  "api_port": 7777,
  "frm_http_port": 8080,
  "frm_ws_port": 8081,
  "admin_password": "YourAdminPassword"
}
```

| Field | Required | Default | Description |
|-------|----------|---------|-------------|
| `name` | Yes | — | Display name |
| `host` | Yes | — | Public IP of the server |
| `api_port` | No | 7777 | Vanilla HTTPS API port |
| `frm_http_port` | No | 8080 | FRM HTTP port |
| `frm_ws_port` | No | 8081 | FRM WebSocket port |
| `admin_password` | Yes | — | Server admin password |

```bash
curl -X POST https://satisfactory-dashboard.pablohgdev.com/api/v1/servers \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "name": "My Factory Server",
    "host": "YOUR_SERVER_IP",
    "api_port": 7777,
    "frm_http_port": 8080,
    "frm_ws_port": 8081,
    "admin_password": "YourAdminPassword"
  }'
```

**Success response (201):**

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "My Factory Server",
  "host": "YOUR_SERVER_IP",
  "api_port": 7777,
  "frm_http_port": 8080,
  "status": "online",
  "last_seen_at": "2026-04-15T12:00:00Z",
  "created_at": "2026-04-15T12:00:00Z"
}
```

### Onboarding Error Codes

| HTTP Status | Cause | Fix |
|-------------|-------|-----|
| **422** | `InvalidAdminPasswordException` — wrong admin password | Verify the admin password set in Server Settings → Administration |
| **502** | `ServerUnreachableException` — cannot reach host:port | Check firewall (port 7777), verify server is running |
| **500** | `ProvisioningFailedException` — setup failed after connecting | Usually FRM not accessible (port 8080 blocked or FRM not installed) |

---

## GET /api/v1/servers/{id}

Get details for a specific server.

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/SERVER_UUID \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

**Response (200):** Single server object (same format as the list).

**Not found (404):** Server does not exist or belongs to another user.

---

## PUT /api/v1/servers/{id}

Update server settings. Only the fields you provide are updated.

```bash
curl -X PUT https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/SERVER_UUID \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "name": "Updated Server Name",
    "admin_password": "NewPassword"
  }'
```

**Response (200):** Updated server object.

---

## DELETE /api/v1/servers/{id}

Remove a server from FICSIT.monitor. This stops polling for the server and removes
it from your dashboard. Historical metric data is retained for your plan's retention
period.

```bash
curl -X DELETE https://satisfactory-dashboard.pablohgdev.com/api/v1/servers/SERVER_UUID \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

**Response (204):** Empty body.

---

## Finding Your Server UUID

Your server's UUID is returned when you add it and in the `GET /api/v1/servers` list.
It is also visible in the dashboard URL: `/servers/{uuid}/dashboard`.
