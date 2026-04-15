---
title: "API Authentication"
date: 2026-04-15 00:21:00 +0000
categories: [api-reference]
tags: [satisfactory, ficsitmonitor, api, authentication, sanctum, tokens]
description: "Authenticate with the FICSIT.monitor API using Sanctum session authentication. Register, login, logout, and retrieve the current user via the REST API."
toc: true
---

## Overview

FICSIT.monitor uses **Laravel Sanctum** for API authentication. The API supports
session-based authentication (cookie) for the web SPA and token-based authentication
for external API clients.

---

## Authentication Endpoints

### POST /api/register

Create a new user account.

**Request:**

```bash
curl -X POST https://satisfactory-dashboard.pablohgdev.com/api/register \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -d '{
    "name": "Pablo",
    "email": "pablo@example.com",
    "password": "your_secure_password",
    "password_confirmation": "your_secure_password"
  }'
```

**Success response (201):**

```json
{
  "id": "uuid",
  "name": "Pablo",
  "email": "pablo@example.com"
}
```

**Validation error (422):**

```json
{
  "message": "The given data was invalid.",
  "errors": {
    "email": ["The email has already been taken."]
  }
}
```

---

### POST /api/login

Authenticate with email and password. Returns a session cookie.

**Request:**

```bash
curl -X POST https://satisfactory-dashboard.pablohgdev.com/api/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -c cookies.txt \
  -d '{
    "email": "pablo@example.com",
    "password": "your_secure_password"
  }'
```

**Success response (200):**

```json
{
  "id": "uuid",
  "name": "Pablo",
  "email": "pablo@example.com"
}
```

The session cookie is stored in `cookies.txt` with `-c cookies.txt`. Use `-b cookies.txt`
in subsequent requests to authenticate.

**Authentication failure (401):**

```json
{
  "message": "These credentials do not match our records."
}
```

---

### POST /api/logout

Invalidate the current session. Requires authentication.

**Request:**

```bash
curl -X POST https://satisfactory-dashboard.pablohgdev.com/api/logout \
  -H "Accept: application/json" \
  -b cookies.txt
```

**Success response (204):** Empty body.

---

### GET /api/user

Get the currently authenticated user. Requires authentication.

**Request:**

```bash
curl https://satisfactory-dashboard.pablohgdev.com/api/user \
  -H "Accept: application/json" \
  -b cookies.txt
```

**Success response (200):**

```json
{
  "id": "uuid",
  "name": "Pablo",
  "email": "pablo@example.com"
}
```

---

## Using the Session for API Requests

After login, include the session cookie in all authenticated requests:

```bash
# Login and save cookie
curl -X POST https://satisfactory-dashboard.pablohgdev.com/api/login \
  -H "Content-Type: application/json" \
  -H "Accept: application/json" \
  -c cookies.txt \
  -d '{"email":"pablo@example.com","password":"your_password"}'

# Use the session for subsequent requests
curl https://satisfactory-dashboard.pablohgdev.com/api/v1/servers \
  -H "Accept: application/json" \
  -b cookies.txt
```

---

## CSRF Protection

For browser-based clients making state-changing requests (POST, PUT, DELETE), a CSRF
token is required. The SPA dashboard handles this automatically. External API clients
using session cookies should fetch the CSRF token from `/sanctum/csrf-cookie` before
making state-changing requests.

For scripts and tools, using session cookies with the `Accept: application/json` header
bypasses CSRF requirements on JSON API endpoints.

---

## Unauthenticated Response

Any request to a protected endpoint without authentication returns:

```json
{
  "message": "Unauthenticated."
}
```

HTTP status: `401 Unauthorized`

---

## See Also

- [REST API Overview]({% post_url 2026-04-15-api-overview %}) — base URL and general usage
- [Servers API]({% post_url 2026-04-15-api-servers %}) — manage your servers
- [Metrics API]({% post_url 2026-04-15-api-metrics %}) — query server metrics
