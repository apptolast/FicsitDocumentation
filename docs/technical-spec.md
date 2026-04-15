# FICSIT.monitor — Technical Specification

> **Agent reference document.** This file lives in `docs/` which is in Jekyll's `exclude:` list.
> It is NOT published to the documentation website. It is the authoritative source of truth
> for all content-writing agents. Every fact here has been verified against the
> `/home/pablo/satisfactory-server` source code.

---

## 1. Product Identity

| Field | Value |
|-------|-------|
| **Product name** | FICSIT.monitor (working name during dev: FicsitOps) |
| **Live URL** | https://satisfactory-dashboard.pablohgdev.com |
| **VPS IP** | 46.224.182.211 |
| **Source repo** | `/home/pablo/satisfactory-server` (private) |
| **Stack** | Laravel 12 + React 19 + Kubernetes (bare-metal) |
| **Purpose** | SaaS platform monitoring Satisfactory dedicated game servers in real-time |

---

## 2. Documentation Priority & Reader Journey

**CRITICAL for all content agents:** The documentation's primary purpose is to help
someone set up a Satisfactory dedicated server from scratch and connect it to FICSIT.monitor.

Reader journey:
1. **server-setup** → How do I run a Satisfactory server on my VPS?
2. **prerequisites** → Install FRM mod + open ports
3. **getting-started** → Sign up for FICSIT.monitor + connect server
4. **dashboard** → Read the metrics
5. (advanced) → API, alerts, deployment, pricing

The documentation does NOT explain how FICSIT.monitor is built internally.
It explains what the USER must do.

---

## 3. What is Satisfactory

Satisfactory is a factory-building automation game by Coffee Stain Studios. Players
automate production lines on an alien planet, building elaborate factory networks to
process resources and manufacture increasingly complex items.

A **dedicated server** allows persistent multiplayer — the game world runs 24/7
independently of any player's machine. Server admins typically run these on a VPS or
bare-metal machine.

The problem FICSIT.monitor solves: managing a dedicated server is a "black box" without
the game client open. Admins cannot see server status, player counts, power metrics, or
production data without logging into the game. FICSIT.monitor exposes all this data in
a real-time web dashboard accessible from any device.

---

## 3. Satisfactory Dedicated Server Setup (Docker)

> Verified against `/home/pablo/satisfactory-server/k8s/02-statefulset.yaml`
> The production server on 46.224.182.211 uses Kubernetes with wolveix/satisfactory-server.
> For documentation, present the simpler Docker approach (same image) first.

### Docker image
**Image:** `wolveix/satisfactory-server:latest` (GitHub: wolveix/satisfactory-server)
**Source:** This is what Pablo uses in production on K8s. Same image works with plain Docker.

### VPS Minimum Requirements
- **CPU:** 4 cores (2 dedicated minimum, 4 recommended)
- **RAM:** 12 GB minimum, 16 GB recommended
- **Disk:** 20 GB minimum, 75 GB recommended (saves + game data)
- **OS:** Ubuntu 22.04 or 24.04 LTS (recommended), any Linux with Docker
- **Bandwidth:** Unmetered or at least 1 TB/month

### Docker run command (simple deployment):
```bash
docker run -d \
  --name satisfactory-server \
  --restart unless-stopped \
  -p 7777:7777/tcp \
  -p 7777:7777/udp \
  -p 8888:8888/tcp \
  -p 8080:8080/tcp \
  -p 8081:8081/tcp \
  -e MAXPLAYERS=8 \
  -e PGID=1000 \
  -e PUID=1000 \
  -e STEAMBETA=false \
  -e SKIPUPDATE=false \
  -e AUTOSAVEINTERVAL=300 \
  -v /home/satisfactory/data:/config \
  wolveix/satisfactory-server:latest
```

### Docker Compose (recommended for easier management):
```yaml
services:
  satisfactory:
    image: wolveix/satisfactory-server:latest
    container_name: satisfactory-server
    restart: unless-stopped
    ports:
      - "7777:7777/tcp"
      - "7777:7777/udp"
      - "8888:8888/tcp"
      - "8080:8080/tcp"
      - "8081:8081/tcp"
    environment:
      - MAXPLAYERS=8
      - PGID=1000
      - PUID=1000
      - STEAMBETA=false
      - SKIPUPDATE=false
      - AUTOSAVEINTERVAL=300
    volumes:
      - ./data:/config
```

### Environment variables (verified from K8s statefulset):
| Variable | Default | Description |
|----------|---------|-------------|
| `MAXPLAYERS` | 4 | Maximum simultaneous players |
| `PGID` | 1000 | Group ID for volume permissions |
| `PUID` | 1000 | User ID for volume permissions |
| `STEAMBETA` | false | Use experimental branch |
| `SKIPUPDATE` | false | Skip auto-update on start |
| `AUTOSAVEINTERVAL` | 300 | Autosave every N seconds (300 = 5 min) |

### Volume: `/config`
The container stores ALL data in `/config`:
- `saves/` — game save files
- `config/` — server configuration
- `logs/` — server logs

Map this to a persistent directory on the host. Losing this = losing the world.

### First boot sequence:
1. First run downloads the game (~15 GB via SteamCMD — takes 10-20 min)
2. Server starts and listens on port 7777
3. Connect from game client → Server Manager → enter IP:7777
4. Create a new game session
5. Set admin password via: Server Settings → Administration

### Setting admin password (for FICSIT.monitor):
Once connected as a client:
1. Open Server Settings (top right menu in server browser)
2. Go to Administration tab
3. Set an Admin Password
4. This password is what FICSIT.monitor uses to authenticate

Or via API (PasswordlessLogin if no password set yet, then SetAdminPassword):
```bash
# If server has no password yet:
curl -k -X POST https://YOUR_SERVER_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -d '{"function": "PasswordlessLogin", "data": {"minimumPrivilegeLevel": "Administrator"}}'
# Response includes a token to use for subsequent calls
```

### Firewall (UFW on Ubuntu):
```bash
# Allow Satisfactory ports
sudo ufw allow 7777/tcp
sudo ufw allow 7777/udp
sudo ufw allow 8888/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 8081/tcp
sudo ufw reload
sudo ufw status
```

### Verifying the server is running:
```bash
# Check container is up
docker ps | grep satisfactory

# Check logs (see SteamCMD download progress)
docker logs -f satisfactory-server

# Test vanilla API (no auth needed)
curl -k -X POST https://YOUR_SERVER_IP:7777/api/v1 \
  -H "Content-Type: application/json" \
  -d '{"function": "HealthCheck", "data": {}}'
# Expected: {"data":{"health":"healthy"}}

# Test FRM (after mod is installed)
curl http://YOUR_SERVER_IP:8080/getPower
# Expected: JSON array with power circuit data
```

---

## 4. FicsitRemoteMonitoring (FRM) Mod — CRITICAL PREREQUISITE

The FRM mod **MUST** be installed in the Satisfactory game server for most metrics to work.

### Without FRM (vanilla API only):
- `/api/v1` endpoint on port 7777 only
- Available: `HealthCheck`, `QueryServerState`, session management, save management
- No factory data, no power circuits, no production rates

### With FRM installed:
- 10+ additional metric endpoints via HTTP (port 8080) and WebSocket (port 8081)
- Full power grid, production rates, player positions, trains, drones, factory buildings

### FRM access methods:
- **Direct HTTP**: `GET http://host:8080/endpoint` (e.g., `GET http://host:8080/getPower`)
- **WebSocket**: `ws://host:8081/` with subscription messages
- **Via vanilla API port** (FRM v1.1+): `POST https://host:7777/api/v1` with body:
  ```json
  {"function": "frm", "endpoint": "getPower"}
  ```

### How to install FRM:
1. Open the Satisfactory Mod Manager (FICSIT App / SMM)
2. Search for "FicsitRemoteMonitoring"
3. Install the mod on the dedicated server
4. Restart the server after installation
5. Verify: `curl http://your-server-ip:8080/getPower` should return JSON

---

## 4. Network Requirements

> **Source**: verified against `k8s/02-statefulset.yaml` in `satisfactory-server` repo.

| Port | Protocol | Service | Notes |
|------|----------|---------|-------|
| **7777** | TCP + UDP | Satisfactory game + vanilla HTTPS API | Primary port; both protocols required |
| **8888** | TCP | Reliable messaging channel | Required since **Patch 1.1** (June 2025) |
| **8080** | TCP | FRM HTTP API | Required for monitoring; FRM mod must be installed |
| **8081** | TCP | FRM WebSocket | Required for real-time FRM data |

### DEPRECATED ports (do NOT open, do NOT document as required):
- ~~15000~~ — deprecated since Patch 1.0 launch
- ~~15777~~ — deprecated since Patch 1.0 launch

### Critical constraints:
- **Port forwarding NOT supported** — external port must equal internal port (7777→7777, not 7777→8080)
- All four active ports must be open in the firewall/security group
- For cloud VPS: configure both inbound TCP and UDP rules for port 7777

### Firewall example (UFW on Ubuntu):
```bash
sudo ufw allow 7777/tcp
sudo ufw allow 7777/udp
sudo ufw allow 8888/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 8081/tcp
sudo ufw reload
```

---

## 5. Vanilla API Reference

All vanilla API calls are `POST https://host:7777/api/v1` with `Content-Type: application/json`.
TLS is self-signed; use `--insecure` with curl or disable certificate verification in clients.

### Authentication
- First call: `PasswordlessLogin` (if server has no admin password) or `PasswordLogin`
- Receive a bearer token; include in subsequent requests as `Authorization: Bearer <token>`
- Or: generate via game console command `server.GenerateAPIToken`

### Endpoint reference

| Function | Auth Required | Description |
|----------|---------------|-------------|
| `HealthCheck` | No | Returns server health status ("healthy" or "slow") |
| `QueryServerState` | No | Returns tick_rate, player_count, tech_tier, game_phase, is_running, is_paused, total_duration |
| `PasswordlessLogin` | No | Obtain auth token (no admin password set) |
| `PasswordLogin` | No | Obtain auth token with admin password |
| `RunCommand` | Yes | Execute server console command |
| `ApplyServerOptions` | Yes | Modify server settings (max players, autosave interval) |
| `RenameServer` | Yes | Change server display name |
| `SetClientPassword` / `SetAdminPassword` | Yes | Change passwords |
| `CreateSave` | Yes | Create a save file |
| `LoadGame` | Yes | Load a save file |
| `SaveGame` | Yes | Save current state |
| `DeleteSaveFile` | Yes | Delete a save |
| `DownloadSaveGame` | Yes | Download save file |

### Example — HealthCheck:
```bash
curl -k -X POST https://46.224.182.211:7777/api/v1 \
  -H "Content-Type: application/json" \
  -d '{"function": "HealthCheck", "data": {}}'
```
Response:
```json
{"data": {"health": "healthy"}}
```

### Example — QueryServerState:
```bash
curl -k -X POST https://46.224.182.211:7777/api/v1 \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"function": "QueryServerState", "data": {}}'
```
Response fields: `serverGameState.activeSessionName`, `serverGameState.numConnectedPlayers`,
`serverGameState.playerLimit`, `serverGameState.techTier`, `serverGameState.isGameRunning`,
`serverGameState.totalGameDuration`, `serverGameState.gamePhase`

---

## 6. FRM API Endpoints

> **Source**: verified against `app/Modules/Server/Services/FrmApiClient.php`

All FRM endpoints return JSON arrays. Access via direct HTTP (port 8080) or via vanilla
API port 7777 using `{"function":"frm","endpoint":"<name>"}`.

| Endpoint | HTTP path | Description |
|----------|-----------|-------------|
| `getPower` | `/getPower` | Power circuits data (see fields below) |
| `getProdStats` | `/getProdStats` | Production/consumption rates per item (items/min) |
| `getFactory` | `/getFactory` | Each building: recipe, efficiency %, inventories |
| `getPlayer` | `/getPlayer` | Player names, online status, health, XYZ position |
| `getTrains` | `/getTrains` | Train details: speed, fuel, derailment, travel time |
| `getDroneStation` | `/getDroneStation` | Drone stations: flight time, fuel, inventory |
| `getWorldInv` | `/getWorldInv` | Global storage inventory totals |
| `getGenerators` | `/getGenerators` | Power generator details |
| `getExtractor` | `/getExtractor` | Resource extractor details (**singular**, not plural) |
| `getResourceSink` | `/getResourceSink` | AWESOME Sink coupon points |

> **IMPORTANT**: `getExtractor` is singular. This is intentional in FRM. Do not write `getExtractors`.

### Power circuit fields (PowerMetric model — verified):
```
power_production     float  — MW being produced
power_consumed       float  — MW consumed by factory
power_capacity       float  — total capacity (generators)
power_max_consumed   float  — peak consumption this tick
battery_percent      float  — battery charge %
battery_capacity     float  — battery total MWh
battery_differential float  — charge/discharge rate
fuse_triggered       bool   — whether a fuse has blown
circuit_group_id     int    — circuit identifier
```

---

## 7. FICSIT.monitor Architecture (How the SaaS Works)

### Pipeline: Poll → Store → Broadcast → Alert

```
[Satisfactory Server + FRM]
        ↓ HTTP polling (Laravel Scheduler)
[Laravel Jobs via Horizon]
        ↓ store raw data
[PostgreSQL + TimescaleDB hypertables]
        ↓ broadcast via
[Laravel Reverb WebSocket server]
        ↓ real-time push to
[React 19 frontend via Laravel Echo]
```

### Polling cadence (verified in `routes/console.php`):

| Interval | Jobs |
|----------|------|
| **10 seconds** | `PollServerHealth`, `PollServerMetrics` |
| **15 seconds** | `PollPlayers`, `PollPowerMetrics`, `PollGenerators` |
| **30 seconds** | `PollProductionMetrics`, `PollTrains`, `PollDroneStations`, `PollExtractors`, `PollWorldInventory` |
| **60 seconds** | `PollFactory`, `PollResourceSink` |

### Storage:
- **PostgreSQL + TimescaleDB**: hypertables on `power_metrics`, `production_metrics`, `server_metrics`
- **Redis**: current state cache (latest snapshot per server), queue backing
- Retention: 7 days compressed → 90 days max

### WebSocket channels (Laravel Reverb, Pusher protocol):
- `private-servers.{id}` — main dashboard updates
- `private-admin.servers.{id}` — admin-only events
- `private-monitoring.{id}` — monitoring alerts

---

## 8. Full REST API Reference

> **Source**: verified against `routes/api.php`

Base URL: `https://satisfactory-dashboard.pablohgdev.com/api`

### Authentication endpoints (rate limited: 6 req/min)

| Method | Path | Description |
|--------|------|-------------|
| POST | `/register` | Create new account |
| POST | `/login` | Authenticate (returns Sanctum cookie) |
| POST | `/logout` | Invalidate session |
| GET | `/user` | Current authenticated user |

### Config

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/config/reverb` | WebSocket connection config for client |

### Server Management (Sanctum auth required)

| Method | Path | Description |
|--------|------|-------------|
| GET | `/v1/servers` | List user's servers |
| POST | `/v1/servers` | Add a new server |
| GET | `/v1/servers/{id}` | Server details |
| PUT/PATCH | `/v1/servers/{id}` | Update server settings |
| DELETE | `/v1/servers/{id}` | Remove server |

#### POST /v1/servers — request fields:
```json
{
  "name": "My Factory Server",
  "host": "46.224.182.211",
  "api_port": 7777,
  "frm_http_port": 8080,
  "frm_ws_port": 8081,
  "admin_password": "your-password"
}
```

#### Error responses:
- `422 Unprocessable Entity` — `InvalidAdminPasswordException` (wrong password)
- `502 Bad Gateway` — `ServerUnreachableException` (cannot connect to server)
- `500 Internal Server Error` — `ProvisioningFailedException` (setup failed after connect)

### Server Metrics

| Method | Path | Returns |
|--------|------|---------|
| GET | `/v1/servers/{id}/metrics/latest` | ServerMetric snapshot |
| GET | `/v1/servers/{id}/players` | Player list |
| GET | `/v1/servers/{id}/power/latest` | PowerMetric snapshot |
| GET | `/v1/servers/{id}/production/latest` | ProductionMetric snapshot |
| GET | `/v1/servers/{id}/trains` | Train list |
| GET | `/v1/servers/{id}/drones` | DroneStation list |
| GET | `/v1/servers/{id}/generators` | Generator list (Redis cache) |
| GET | `/v1/servers/{id}/extractors` | Extractor list (Redis cache) |
| GET | `/v1/servers/{id}/world-inventory` | World inventory (Redis cache) |
| GET | `/v1/servers/{id}/resource-sink` | Resource sink data (Redis cache) |
| GET | `/v1/servers/{id}/dashboard` | Full dashboard snapshot (initial page load) |

### Data Models (actual field names — verified against migrations and Eloquent models)

#### ServerMetric (TimescaleDB hypertable):
```
time              timestamptz
server_id         uuid
tick_rate         float
player_count      int
tech_tier         int
game_phase        string
is_running        bool
is_paused         bool
total_duration    int  (seconds)
```

#### PowerMetric (TimescaleDB hypertable):
```
time                 timestamptz
server_id            uuid
circuit_group_id     int
power_production     float  (MW)
power_consumed       float  (MW)
power_capacity       float  (MW)
power_max_consumed   float  (MW)
battery_percent      float
battery_capacity     float  (MWh)
battery_differential float  (MW)
fuse_triggered       bool
```

#### Server model:
```
id               uuid
user_id          uuid
name             string
host             string
api_port         int
frm_http_port    int
frm_ws_port      int
api_token        string (encrypted)
status           enum: online|offline|degraded
is_active        bool
last_seen_at     timestamp
```

---

## 9. Kubernetes Deployment (Production)

> **Source**: verified against `k8s/` manifests in `satisfactory-server` repo.

### Game Server (namespace: `satisfactory`)

- **Resource**: StatefulSet `satisfactory`, 1 replica
- **Image**: `wolveix/satisfactory-server:latest`
- **Resources**: CPU 2 req / 4 limit; RAM 8Gi req / 16Gi limit; PVC 75Gi (longhorn-gameserver)
- **Env**: `MAXPLAYERS=8`, `AUTOSAVEINTERVAL=300` (5 min)
- **Services**:
  - `satisfactory-tcp` (LoadBalancer, MetalLB) → ports 7777 TCP, 8888 TCP → `46.224.182.211`
  - `satisfactory-udp` (LoadBalancer, MetalLB) → port 7777 UDP → `46.224.182.211`
  - `satisfactory-frm` (ClusterIP) → ports 8080 TCP, 8081 TCP
- **Auto-update**: Keel annotation polls every 6h

### Dashboard Stack (namespace: `satisfactory-dashboard`)

| Component | Resource | Image | Notes |
|-----------|----------|-------|-------|
| PostgreSQL | StatefulSet | postgres:15 | TimescaleDB extension via configmap |
| Redis | Deployment | redis:7 | NodePort 30379 |
| Web | Deployment | ocholoko888/satisfactory-dashboard:latest | nginx + PHP-FPM sidecars |
| Reverb | Deployment | (same image) | WebSocket server, port 8080 |
| Horizon | Deployment | (same image) | Queue worker |
| Scheduler | Deployment | (same image) | Cron runner |

Web pod init container: `php artisan migrate --force && php artisan db:seed --class=ServerSeeder --force`

Web pod resources: CPU 250m req / 1 limit; RAM 256Mi req / 512Mi limit

### Ingress (Traefik + cert-manager):
- Domain: `satisfactory-dashboard.pablohgdev.com`
- TLS: Let's Encrypt via Cloudflare ClusterIssuer
- WebSocket routing: `/app/*` → reverb service; all other paths → web service

### Infrastructure components:
- **Longhorn**: distributed block storage (PVCs)
- **MetalLB**: bare-metal load balancer (assigns `46.224.182.211`)
- **Calico**: network policies
- **Traefik**: ingress controller
- **cert-manager**: TLS certificate management
- **Keel**: automated container image updates

---

## 10. Pricing Tiers

> **Source**: verified against `STITCH_LANDING_PROMPT.md`

| Tier | Monthly | Annual | Servers | Retention | Polling | Alerts |
|------|---------|--------|---------|-----------|---------|--------|
| **Free** | 0€ | 0€ | 1 | 24h | 30s | None |
| **Hobby** | 6€ | 58€ | 2 | 7 days | 15s | Discord only |
| **Pro** | 19€ | 182€ | 5 | 30 days | 10s | Multi-channel |
| **Team** | 49€ | 470€ | 15 | 90 days | 10s | Multi-channel + user roles |
| **Enterprise** | custom | custom | Unlimited | Custom | 10s | Custom |

Annual pricing = ~20% discount (equivalent to 2 free months). IVA not included.
Prices are indicative; beta pricing may differ.

### Feature breakdown by tier:

**Pro features** (beyond Hobby):
- API access: 10,000 requests/day
- Shareable read-only dashboard links
- Twitch/YouTube overlay widget
- <24h email support

**Team features** (beyond Pro):
- Multi-user access with role management (Admin, Viewer, Operator)
- Optional SSO integration
- 99.9% uptime SLA
- Priority support

**Enterprise features**:
- On-premises or private Kubernetes deployment
- 99.99% uptime SLA
- Dedicated support channel
- Custom security audit and compliance review

---

## 11. Technology Stack Reference

| Layer | Technology |
|-------|-----------|
| Backend framework | Laravel 12 / PHP 8.2+ |
| ORM | Eloquent (Laravel) |
| Frontend framework | React 19.2 + TypeScript |
| SPA bridge | Inertia.js 2.x |
| CSS | Tailwind CSS 4.0 |
| Charts | ApexCharts 5.6 |
| State management | Zustand 5.0 |
| Database | PostgreSQL 15+ with TimescaleDB extension |
| Cache & queues | Redis 7+ |
| Queue manager | Laravel Horizon |
| WebSocket server | Laravel Reverb (Pusher protocol) |
| WebSocket client | Laravel Echo 2.3 |
| Authentication | Laravel Sanctum (cookie SPA + Personal Access Tokens) |
| Observability | Laravel Pulse |
| Build tool | Vite 7.0 |
| Testing (PHP) | Pest PHP 3.8+ |
| Static analysis | Larastan (PHPStan for Laravel) 3.0 |
| Code style | Laravel Pint |

---

## 12. Known Constraints and Gotchas

These are facts every agent must know to avoid writing incorrect documentation:

1. **Port forwarding not supported** — The game server binds to its external IP directly.
   External port must equal internal port. NAT/PAT is not supported by the game.

2. **Ports 15000 and 15777 are deprecated** — Do not mention these as required. They
   were used in early access but removed in Patch 1.0/1.1.

3. **FRM is not optional for most panels** — The dashboard's power, production, factory,
   trains, and drones panels all require FRM. Only the basic "server status" panel works
   without FRM (it uses the vanilla `QueryServerState` endpoint).

4. **Self-signed TLS on port 7777** — The Satisfactory dedicated server uses a self-signed
   certificate for its HTTPS API. Clients must disable certificate verification.

5. **TimescaleDB extension** — PostgreSQL must have TimescaleDB installed and enabled via
   `CREATE EXTENSION timescaledb;`. Standard PostgreSQL is not sufficient for the migrations.

6. **`getExtractor` is singular** — The FRM endpoint is named `getExtractor`, not
   `getExtractors`. The REST API endpoint is `/api/v1/servers/{id}/extractors` (plural).
   These are different names for different layers.

7. **Reverb WebSocket uses Pusher protocol** — Frontend uses `Laravel Echo` with Pusher
   driver. The WebSocket URL is not a direct ws:// connection but uses the Pusher auth flow.

8. **The `docs/` directory** is in Jekyll's `exclude:` list in `_config.yml`. Files in
   `docs/` are NOT built into the documentation website. They are agent reference only.
