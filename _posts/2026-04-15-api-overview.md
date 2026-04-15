---
title: "REST API Overview"
date: 2026-04-15 00:20:00 +0000
categories: [api-reference]
tags: [satisfactory, ficsitmonitor, api, rest-api, sanctum, authentication]
description: "FICSIT.monitor REST API overview. Base URL, Sanctum authentication, rate limits, JSON response format, and common error codes."
toc: true
---

## Overview

FICSIT.monitor exposes a REST API for programmatic access to server metrics, player
data, and server management. The API uses Sanctum for authentication (Personal Access
Tokens or session cookies).

---

## Base URL

```
https://satisfactory-dashboard.pablohgdev.com/api
```

All endpoints described in this documentation are relative to this base URL.

---

## Authentication

The API supports two authentication methods:

### Personal Access Tokens (PATs)

Include the token in the `Authorization` header:

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Accept: application/json"
```

### Session Cookie (SPA)

Used by the web dashboard. The cookie is set when you log in via `POST /api/login`.
Not suitable for external API clients.

---

## Content Type

All requests with a body must include:

```
Content-Type: application/json
```

All responses are JSON with `Content-Type: application/json`.

---

## Rate Limiting

| Endpoint group | Limit |
|----------------|-------|
| Authentication (`/register`, `/login`) | 6 requests/minute |
| All other endpoints | No hard limit (subject to fair use) |

Rate limit responses return HTTP `429 Too Many Requests`:

```json
{
  "message": "Too Many Attempts."
}
```

---

## Response Format

### Success

Successful responses return the resource directly:

```json
{
  "id": "uuid",
  "name": "My Server",
  "host": "46.224.182.211",
  "api_port": 7777,
  "frm_http_port": 8080,
  "status": "online",
  "last_seen_at": "2026-04-15T12:00:00Z",
  "created_at": "2026-04-01T00:00:00Z"
}
```

List endpoints return arrays (pagination may apply).

### Errors

Errors return a standard format:

```json
{
  "message": "Human-readable error message",
  "errors": {
    "field_name": ["Specific validation error"]
  }
}
```

---

## HTTP Status Codes

| Code | Meaning |
|------|---------|
| `200 OK` | Request succeeded |
| `201 Created` | Resource created successfully |
| `204 No Content` | Deletion succeeded |
| `401 Unauthorized` | Not authenticated |
| `403 Forbidden` | Authenticated but not authorized for this resource |
| `404 Not Found` | Resource does not exist |
| `422 Unprocessable Entity` | Validation failed (or wrong admin password) |
| `429 Too Many Requests` | Rate limit exceeded |
| `500 Internal Server Error` | Server-side error (check logs) |
| `502 Bad Gateway` | FICSIT.monitor cannot reach your Satisfactory server |

---

## Endpoint Overview

### Authentication

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | `/register` | No | Create a new user account |
| POST | `/login` | No | Authenticate and get session |
| POST | `/logout` | Yes | Invalidate session |
| GET | `/user` | Yes | Get current user |

### Configuration

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/v1/config/reverb` | Yes | WebSocket connection config for the frontend |

### Servers

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/v1/servers` | Yes | List all user's servers |
| POST | `/v1/servers` | Yes | Add a new server |
| GET | `/v1/servers/{id}` | Yes | Get server details |
| PUT/PATCH | `/v1/servers/{id}` | Yes | Update server |
| DELETE | `/v1/servers/{id}` | Yes | Remove server |

### Server Metrics

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| GET | `/v1/servers/{id}/metrics/latest` | Yes | Latest server state |
| GET | `/v1/servers/{id}/players` | Yes | Player list |
| GET | `/v1/servers/{id}/power/latest` | Yes | Latest power metrics |
| GET | `/v1/servers/{id}/production/latest` | Yes | Latest production metrics |
| GET | `/v1/servers/{id}/trains` | Yes | Train list |
| GET | `/v1/servers/{id}/drones` | Yes | Drone station list |
| GET | `/v1/servers/{id}/generators` | Yes | Generator list |
| GET | `/v1/servers/{id}/extractors` | Yes | Extractor list |
| GET | `/v1/servers/{id}/world-inventory` | Yes | World inventory |
| GET | `/v1/servers/{id}/resource-sink` | Yes | Resource sink data |
| GET | `/v1/servers/{id}/dashboard` | Yes | Full metrics snapshot |

---

## CORS

The API allows requests from the dashboard's own domain. For external API clients,
requests must include the `Accept: application/json` header to receive JSON error
responses instead of HTML redirects.

---

## See Also

- [API Authentication]({% post_url 2026-04-15-api-authentication %}) — PAT creation and usage
- [Servers API]({% post_url 2026-04-15-api-servers %}) — server management endpoints
- [Metrics API]({% post_url 2026-04-15-api-metrics %}) — all metric endpoints with field definitions
