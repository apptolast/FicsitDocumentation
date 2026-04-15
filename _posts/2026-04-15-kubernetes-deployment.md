---
title: "Kubernetes Deployment Guide"
date: 2026-04-15 00:18:00 +0000
categories: [deployment]
tags: [satisfactory, ficsitmonitor, kubernetes, k8s, deployment, traefik, cert-manager]
description: "Deploy FICSIT.monitor and a Satisfactory game server on Kubernetes. Full manifest walkthrough for namespaces, StatefulSets, services, Traefik ingress, and TLS."
toc: true
---

## Overview

This guide describes the production Kubernetes deployment powering FICSIT.monitor.
It deploys two namespaces: `satisfactory` for the game server, and
`satisfactory-dashboard` for the monitoring application stack.

This is an **advanced guide** targeting teams with Kubernetes experience. For a simpler
setup, use the [Docker deployment guide]({% post_url 2026-04-15-run-satisfactory-docker %}).

---

## Prerequisites

A bare-metal or cloud Kubernetes cluster with:
- **MetalLB** — bare-metal load balancer (for assigning external IPs)
- **Longhorn** — distributed block storage (for persistent volumes)
- **Traefik** — ingress controller
- **cert-manager** — TLS certificate management (Let's Encrypt)
- **Keel** — automated image update deployment

---

## Namespace Structure

```yaml
# satisfactory namespace — game server
# satisfactory-dashboard namespace — monitoring app
```

---

## Game Server Deployment (namespace: `satisfactory`)

### StatefulSet

The game server runs as a StatefulSet with 1 replica:

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: satisfactory
  namespace: satisfactory
  annotations:
    keel.sh/policy: force
    keel.sh/trigger: poll
    keel.sh/pollSchedule: "@every 6h"
spec:
  serviceName: satisfactory
  replicas: 1
  template:
    spec:
      containers:
        - name: satisfactory
          image: wolveix/satisfactory-server:latest
          env:
            - name: MAXPLAYERS
              value: "8"
            - name: PGID
              value: "1000"
            - name: PUID
              value: "1000"
            - name: STEAMBETA
              value: "false"
            - name: SKIPUPDATE
              value: "false"
            - name: AUTOSAVEINTERVAL
              value: "300"
          ports:
            - name: game-tcp
              containerPort: 7777
              protocol: TCP
            - name: game-udp
              containerPort: 7777
              protocol: UDP
            - name: reliable
              containerPort: 8888
              protocol: TCP
            - name: frm-http
              containerPort: 8080
              protocol: TCP
            - name: frm-ws
              containerPort: 8081
              protocol: TCP
          resources:
            requests:
              cpu: "2"
              memory: 8Gi
            limits:
              cpu: "4"
              memory: 16Gi
          volumeMounts:
            - name: gamedata
              mountPath: /config
  volumeClaimTemplates:
    - metadata:
        name: gamedata
      spec:
        accessModes:
          - ReadWriteOnce
        storageClassName: longhorn-gameserver
        resources:
          requests:
            storage: 75Gi
```

### Services

**satisfactory-tcp** (LoadBalancer — external game + API access):
```yaml
apiVersion: v1
kind: Service
metadata:
  name: satisfactory-tcp
  namespace: satisfactory
  annotations:
    metallb.universe.tf/allow-shared-ip: "shared-external-ip"
spec:
  type: LoadBalancer
  loadBalancerIP: "YOUR_PUBLIC_IP"
  selector:
    app.kubernetes.io/name: satisfactory
  ports:
    - name: game-tcp
      protocol: TCP
      port: 7777
      targetPort: 7777
    - name: reliable
      protocol: TCP
      port: 8888
      targetPort: 8888
```

**satisfactory-udp** (LoadBalancer — game UDP traffic):
```yaml
apiVersion: v1
kind: Service
metadata:
  name: satisfactory-udp
  namespace: satisfactory
  annotations:
    metallb.universe.tf/allow-shared-ip: "shared-external-ip"
spec:
  type: LoadBalancer
  loadBalancerIP: "YOUR_PUBLIC_IP"
  selector:
    app.kubernetes.io/name: satisfactory
  ports:
    - name: game-udp
      protocol: UDP
      port: 7777
      targetPort: 7777
```

**satisfactory-frm** (ClusterIP — internal FRM access from dashboard):
```yaml
apiVersion: v1
kind: Service
metadata:
  name: satisfactory-frm
  namespace: satisfactory
spec:
  type: ClusterIP
  selector:
    app.kubernetes.io/name: satisfactory
  ports:
    - name: frm-http
      protocol: TCP
      port: 8080
      targetPort: 8080
    - name: frm-ws
      protocol: TCP
      port: 8081
      targetPort: 8081
```

> With Kubernetes, FRM (ports 8080/8081) is accessible internally via ClusterIP.
> You only need to open 8080/8081 on the host firewall if you want external FRM access.
{: .prompt-info }

---

## Dashboard Stack (namespace: `satisfactory-dashboard`)

### Components

| Component | Type | Image | Purpose |
|-----------|------|-------|---------|
| PostgreSQL | StatefulSet | postgres:15 | Time-series metrics database (with TimescaleDB) |
| Redis | Deployment | redis:7 | Queue, cache, session storage |
| Web | Deployment | ocholoko888/satisfactory-dashboard:latest | nginx + PHP-FPM (Laravel app) |
| Reverb | Deployment | (same) | WebSocket server (Laravel Reverb) |
| Horizon | Deployment | (same) | Queue worker (Laravel Horizon) |
| Scheduler | Deployment | (same) | Cron runner (polling jobs) |

### Web Pod Init Container

The web pod runs an init container that migrates and seeds the database on startup:

```yaml
initContainers:
  - name: init-migrate
    image: ocholoko888/satisfactory-dashboard:latest
    command: ["sh", "-c", "php artisan migrate --force && php artisan db:seed --class=ServerSeeder --force"]
```

### Web Pod Resources

```yaml
resources:
  requests:
    cpu: 250m
    memory: 256Mi
  limits:
    cpu: "1"
    memory: 512Mi
```

### Traefik Ingress with TLS

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: dashboard-ingress
  namespace: satisfactory-dashboard
  annotations:
    cert-manager.io/cluster-issuer: cloudflare-clusterissuer
    traefik.ingress.kubernetes.io/router.entrypoints: websecure
spec:
  tls:
    - hosts:
        - satisfactory-dashboard.yourdomain.com
      secretName: dashboard-tls
  rules:
    - host: satisfactory-dashboard.yourdomain.com
      http:
        paths:
          # WebSocket path for Reverb
          - path: /app
            pathType: Prefix
            backend:
              service:
                name: dashboard-reverb
                port:
                  number: 8080
          # Everything else to the web service
          - path: /
            pathType: Prefix
            backend:
              service:
                name: dashboard-web
                port:
                  number: 80
```

---

## TimescaleDB Setup

PostgreSQL must have TimescaleDB enabled. The migrations create TimescaleDB hypertables
automatically, but the extension must be pre-installed. Apply a PostgreSQL ConfigMap
with:

```yaml
shared_preload_libraries: timescaledb
```

Or use a TimescaleDB Docker image instead of plain `postgres:15`.

---

## Auto-Update with Keel

Keel polls Docker Hub every 6 hours and automatically deploys new images when a newer
`latest` tag is available:

```yaml
annotations:
  keel.sh/policy: force
  keel.sh/trigger: poll
  keel.sh/pollSchedule: "@every 6h"
  keel.sh/approvals: "0"
```

This means deployments update automatically without manual intervention.

---

## See Also

- [Environment Variables Reference]({% post_url 2026-04-15-environment-variables %}) — configure the Laravel app
- [Running with Docker]({% post_url 2026-04-15-run-satisfactory-docker %}) — simpler Docker-based setup
