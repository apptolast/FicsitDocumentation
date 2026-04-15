# FICSIT.monitor Documentation Site

## Producto

**FICSIT.monitor** es una plataforma SaaS para monitorizar servidores dedicados de
Satisfactory en tiempo real. Proporciona un dashboard web con métricas de fábrica,
red eléctrica, jugadores, trenes y drones actualizadas via WebSocket.

- Live URL: https://satisfactory-dashboard.pablohgdev.com
- Fuente del producto: `/home/pablo/satisfactory-server` (Laravel 12 + React 19 + K8s)
- VPS: 46.224.182.211

## Este proyecto

Sitio de documentación estático en **Jekyll + jekyll-theme-chirpy v7.5**.
Desplegado automáticamente en **GitHub Pages** cuando se hace push a `main`.

## Comandos esenciales

```bash
bundle exec jekyll serve            # dev local (http://localhost:4000)
./tools/run.sh                      # live reload dev server
./tools/test.sh                     # build + html-proofer (pre-deploy check)
bundle exec jekyll build --quiet    # build solo (CI/hooks)
chmod +x .claude/hooks/*.sh         # REQUERIDO tras crear hooks por primera vez
```

## Propósito de la documentación — CRÍTICO

**La documentación NO explica cómo está hecho FICSIT.monitor internamente.**
**Explica cómo el USUARIO monta y monitoriza su servidor de Satisfactory.**

Journey del lector:
1. **server-setup** → ¿Cómo instalo un servidor dedicado de Satisfactory en mi VPS?
2. **prerequisites** → ¿Cómo instalo el mod FRM y abro los puertos?
3. **getting-started** → ¿Cómo me registro en FICSIT.monitor y conecto mi servidor?
4. **dashboard** → ¿Cómo leo las métricas del dashboard?
5. (avanzado) → API, alertas, self-hosting, precios

El modelo de negocio: la gente que ya tiene (o quiere tener) un servidor de Satisfactory
se suscribe a FICSIT.monitor para monitorizarlo. La documentación es el embudo.

## Estructura del sitio

```
_posts/          ← todo el contenido de documentación (archivos .md con fecha)
_tabs/           ← navegación principal (about=hub, categories, archives, tags)
_data/           ← contact.yml, share.yml
_config.yml      ← configuración Jekyll (title, tagline, theme_mode, etc.)
assets/          ← imágenes, CSS personalizado
docs/            ← EXCLUIDO del build (ficheros de referencia para agentes)
```

> `docs/` está en el `exclude:` de `_config.yml`. Los ficheros en docs/ son para
> agentes, NO aparecen en el sitio publicado.

## Ownership de ficheros — CRÍTICO

Dos agentes NUNCA deben editar el mismo fichero simultáneamente.

| Agente | Ficheros de su propiedad |
|--------|--------------------------|
| **docs-architect** | `_tabs/**`, `docs/architecture.md` |
| **content-writer** | `_posts/**` (excepto posts de api-reference y kubernetes) |
| **jekyll-developer** | `_config.yml`, `_data/**`, `assets/css/**`, `_includes/**` |
| **qa-engineer** | READ-ONLY + corre `./tools/test.sh` |
| **seo-specialist** | front matter SEO en `_posts/` (solo campos: description, image, tags), `assets/img/og/` |
| **code-reviewer** | READ-ONLY — revisa calidad markdown y YAML |
| **security-reviewer** | READ-ONLY — audita secrets y datos sensibles |
| **tech-writer** | `_posts/*api-*`, `_posts/*kubernetes-*`, `_posts/*websocket-*` |
| **mentor** | READ-ONLY — explica al usuario |

## Referencias para agentes

- Especificación completa del producto: `@docs/technical-spec.md`
- Arquitectura de información del sitio: `@docs/architecture.md`
- Código fuente del producto (sólo lectura): `/home/pablo/satisfactory-server/`

## Datos clave verificados (NO inventar variaciones)

### Puertos requeridos del servidor de Satisfactory:
| Puerto | Protocolo | Servicio |
|--------|-----------|---------|
| 7777 | TCP + UDP | Game + vanilla HTTPS API |
| 8888 | TCP | Reliable messaging (Patch 1.1+) |
| 8080 | TCP | FRM HTTP API |
| 8081 | TCP | FRM WebSocket |

**DEPRECATED (nunca mencionar como activos): 15000, 15777**
**Port forwarding NO soportado** (external port == internal port)

### Cadencia de polling:
- 10s: health + server metrics
- 15s: players + power + generators
- 30s: production + trains + drones + extractors + world inventory
- 60s: factory buildings + resource sink

### FRM endpoints (todos los nombres exactos de FrmApiClient.php):
`getPower`, `getProdStats`, `getFactory`, `getPlayer`, `getTrains`,
`getDroneStation`, `getWorldInv`, `getGenerators`, `getExtractor` (SINGULAR), `getResourceSink`

### REST API base URL: `https://satisfactory-dashboard.pablohgdev.com/api`

### Precios (exactos, verificados en STITCH_LANDING_PROMPT.md):

| Tier | Mensual | Anual | Servidores | Retención | Polling | Alertas |
|------|---------|-------|-----------|-----------|---------|---------|
| Free | 0€ | 0€ | 1 | 24h | 30s | No |
| Hobby | 6€ | 58€ | 2 | 7d | 15s | Discord |
| Pro | 19€ | 182€ | 5 | 30d | 10s | Multi-canal |
| Team | 49€ | 470€ | 15 | 90d | 10s | Multi-canal + roles |
| Enterprise | custom | custom | ilimitado | custom | 10s | custom |

Anual ≈ 20% descuento (2 meses gratis). IVA no incluido.

## Categorías de documentación (orden de importancia)

1. **server-setup** ⭐ PRINCIPAL — cómo instalar el servidor de Satisfactory (Docker, VPS)
2. **getting-started** — crear cuenta FICSIT.monitor, conectar servidor
3. **prerequisites** — instalar FRM mod, generar token API
4. **dashboard** — walkthroughs de cada panel (power, production, players, trains...)
5. **deployment** — self-hosting del dashboard (K8s, Docker Compose, env vars)
6. **api-reference** — REST API + WebSocket events
7. **alerts** — configurar notificaciones Discord/webhook
8. **pricing** — planes y precios
9. **troubleshooting** — FAQ, errores comunes, conexión fallida

**Docker image del servidor de juego:** `wolveix/satisfactory-server:latest`
**Comando básico Docker:** `docker run -d --name satisfactory-server -p 7777:7777/tcp -p 7777:7777/udp -p 8888:8888/tcp -p 8080:8080/tcp -p 8081:8081/tcp -e MAXPLAYERS=8 -v ./data:/config wolveix/satisfactory-server:latest`
**VPS mínimo:** 4 CPU, 12GB RAM, 20GB disco (75GB recomendado)

## Convenciones de contenido

- Nombre del producto: **FICSIT.monitor** (no "FicsitOps", no "ficsit monitor", no "FICSIT Monitor")
- Todos los posts en `_posts/` requieren: `title`, `date`, `categories`, `tags`, `description` (150-160 chars), `toc: true`
- Sintaxis callout Chirpy: `> Texto {: .prompt-tip }` / `{: .prompt-warning }` / `{: .prompt-danger }` / `{: .prompt-info }`
- Code blocks siempre con language specifier: ` ```bash `, ` ```yaml `, ` ```json `
- Links internos: usar tag `{% post_url 2026-04-15-slug %}`

## Reglas de Agent Teams

### Delegate Mode — advertencia crítica
**Activar Delegate Mode SOLO DESPUÉS de hacer spawn de TODOS los teammates.**
Bug conocido: los teammates spawneados DESPUÉS de activar Delegate Mode pueden heredar
restricciones y no poder leer/escribir ficheros.

### Waves de ejecución:
```
Wave 1: docs-architect (IA) + jekyll-developer (config) — sin dependencias
Wave 2: content-writer (posts) + tech-writer (api/k8s) — paralelo, blockedBy Wave 1
Wave 3: qa-engineer + seo-specialist + code-reviewer — blockedBy Wave 2
Wave 4: security-reviewer — blockedBy Wave 2
```

### Sizing de tareas:
- 5-15 minutos por tarea
- 5-6 tareas por teammate
- Máximo práctico: 8 teammates simultáneos

### Comunicación entre agentes:
- docs-architect → content-writer: lista exacta de ficheros a crear (via SendMessage)
- qa-engineer → Team Lead: reporte de errores (no directamente a content-writer)
- Si un agente necesita un fichero de otro, SendMessage al Team Lead para coordinar

## Quality gate antes de commit a main

1. `bundle exec jekyll build --quiet` debe salir con código 0
2. `./tools/test.sh` debe pasar (html-proofer)
3. Ningún post sin campo `description`
4. Ninguna mención de puertos 15000 o 15777 como activos
5. Sin secrets (APP_KEY, DB_PASSWORD, tokens reales) en ningún fichero

El deploy a GitHub Pages ocurre automáticamente al hacer push a `main` via GitHub Actions.
**No hacer push directo a main sin pasar el quality gate.**
