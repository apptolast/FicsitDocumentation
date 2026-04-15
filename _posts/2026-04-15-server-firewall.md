---
title: "Firewall & Port Configuration for Satisfactory"
date: 2026-04-15 00:04:00 +0000
categories: [server-setup]
tags: [satisfactory, firewall, ports, ufw, security-groups, networking]
description: "Open the required ports for a Satisfactory dedicated server: 7777 TCP/UDP, 8888 TCP, 8080 TCP, and 8081 TCP. UFW and cloud security group instructions included."
toc: true
---

## Overview

A Satisfactory dedicated server requires four ports to be open to external traffic.
This guide covers configuring UFW on Ubuntu and adding firewall rules on common cloud
providers.

---

## Required Ports

| Port | Protocol | Service | Required for |
|------|----------|---------|--------------|
| **7777** | TCP | Game API (HTTPS) | All connections + FICSIT.monitor |
| **7777** | UDP | Game traffic | Players connecting to the server |
| **8888** | TCP | Reliable messaging | Stable connections (Patch 1.1+) |
| **8080** | TCP | FRM HTTP API | FICSIT.monitor factory metrics |
| **8081** | TCP | FRM WebSocket | FICSIT.monitor real-time metrics |

> **Ports 8080 and 8081 require the FicsitRemoteMonitoring (FRM) mod to be installed.**
> Without FRM, these ports are not used. See [Installing FRM](/posts/frm-installation/).
{: .prompt-info }

---

## Deprecated Ports — Do NOT Open

> **Do NOT open ports 15000 or 15777.** These ports were used in early access versions
> of Satisfactory and were deprecated in Patch 1.0. Opening them has no effect and
> may expose unnecessary attack surface.
{: .prompt-danger }

---

## Port Forwarding Limitation

> **Port forwarding (NAT) is NOT supported.** The Satisfactory game server binds
> directly to its external IP address. The external port **must equal** the internal port.
> You cannot forward port 17777 externally to 7777 internally.
{: .prompt-danger }

This means:
- Your VPS must have a **public IP** assigned directly to the network interface
- If using a home server, you need a direct public IP (or use a VPN tunnel workaround)

---

## UFW (Ubuntu Firewall)

Most Ubuntu installations include UFW. Configure it as follows:

```bash
# Allow game traffic (TCP + UDP)
sudo ufw allow 7777/tcp
sudo ufw allow 7777/udp

# Allow reliable messaging
sudo ufw allow 8888/tcp

# Allow FRM HTTP API (required for FICSIT.monitor)
sudo ufw allow 8080/tcp

# Allow FRM WebSocket (required for FICSIT.monitor)
sudo ufw allow 8081/tcp

# Apply changes
sudo ufw reload

# Verify
sudo ufw status
```

Expected output:

```text
Status: active

To                         Action      From
--                         ------      ----
7777/tcp                   ALLOW       Anywhere
7777/udp                   ALLOW       Anywhere
8888/tcp                   ALLOW       Anywhere
8080/tcp                   ALLOW       Anywhere
8081/tcp                   ALLOW       Anywhere
```

> Keep SSH (port 22) open: `sudo ufw allow ssh` before enabling UFW if it's not
> already configured.
{: .prompt-warning }

---

## Hetzner Cloud Firewall

In the Hetzner Cloud Console:

1. Go to **Firewalls** → **Create Firewall**
2. Add **Inbound** rules:

| Protocol | Port | Source |
|----------|------|--------|
| TCP | 7777 | Any IPv4, Any IPv6 |
| UDP | 7777 | Any IPv4, Any IPv6 |
| TCP | 8888 | Any IPv4, Any IPv6 |
| TCP | 8080 | Any IPv4, Any IPv6 |
| TCP | 8081 | Any IPv4, Any IPv6 |

3. Apply the firewall to your server

---

## DigitalOcean Firewall

In the DigitalOcean Control Panel:

1. Go to **Networking** → **Firewalls** → **Create Firewall**
2. Under **Inbound Rules**, add:

| Type | Protocol | Port |
|------|----------|------|
| Custom | TCP | 7777 |
| Custom | UDP | 7777 |
| Custom | TCP | 8888 |
| Custom | TCP | 8080 |
| Custom | TCP | 8081 |

3. Apply the firewall to your Droplet

---

## Verifying Port Accessibility

After configuring your firewall, verify the server is reachable:

```bash
# Test the game API (from outside your server)
curl -k -X POST https://YOUR_SERVER_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -d '{"function": "HealthCheck", "data": {}}'
# Expected: {"data":{"health":"healthy"}}

# Test FRM HTTP (after FRM mod is installed)
curl http://YOUR_SERVER_IP:8080/getPower
# Expected: JSON array with power circuit data
```

From inside your server, verify listening ports:

```bash
ss -tulnp | grep -E '7777|8888|8080|8081'
```

---

## Common Issues

**Port 7777 not reachable** → Verify UFW is allowing it AND Docker published the port correctly
(`docker ps` should show `0.0.0.0:7777->7777/tcp`).

**Port 8080 not reachable** → FRM mod may not be installed or not started. See
[Installing FRM](/posts/frm-installation/).

**Game client connects but FICSIT.monitor shows 502** → Double-check that port 8080 is
accessible from FICSIT.monitor's servers (external, not just from localhost). See
[Diagnosing Connection Issues](/posts/connection-errors/).

---

## Next Step

[First Launch & World Setup →](/posts/server-first-launch/)
