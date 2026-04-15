---
description: Spawn an agent to write a specific documentation section
allowed-tools: Read, Glob
---

# /project:write-section

Spawn a documentation agent to write a specific section.

## Usage

```
/project:write-section [section-name]
```

## Available Sections

### ⭐ Server Setup (PRIMARY category — start here)

| Section name | Category | Agent | Filename |
|-------------|----------|-------|----------|
| `what-is-server` | server-setup | content-writer | 2026-04-15-what-is-satisfactory-server.md |
| `vps-requirements` | server-setup | content-writer | 2026-04-15-vps-requirements.md |
| `install-docker` | server-setup | content-writer | 2026-04-15-install-docker.md |
| `run-docker` | server-setup | content-writer | 2026-04-15-run-satisfactory-docker.md |
| `server-firewall` | server-setup | content-writer | 2026-04-15-server-firewall.md |
| `server-first-launch` | server-setup | content-writer | 2026-04-15-server-first-launch.md |
| `server-config` | server-setup | content-writer | 2026-04-15-server-configuration.md |

### FICSIT.monitor (after server is running)

| Section name | Category | Agent | Filename |
|-------------|----------|-------|----------|
| `what-is` | getting-started | content-writer | 2026-04-15-what-is-ficsitmonitor.md |
| `quick-start` | getting-started | content-writer | 2026-04-15-quick-start.md |
| `account-setup` | getting-started | content-writer | 2026-04-15-account-setup.md |
| `add-server` | getting-started | content-writer | 2026-04-15-add-first-server.md |
| `frm-installation` | prerequisites | content-writer | 2026-04-15-frm-installation.md |
| `network-ports` | prerequisites | content-writer | 2026-04-15-network-ports.md |
| `api-token` | prerequisites | content-writer | 2026-04-15-api-token.md |
| `dashboard-overview` | dashboard | content-writer | 2026-04-15-dashboard-overview.md |
| `power-panel` | dashboard | content-writer | 2026-04-15-power-grid-panel.md |
| `production-panel` | dashboard | content-writer | 2026-04-15-production-panel.md |
| `players` | dashboard | content-writer | 2026-04-15-players-sessions.md |
| `trains-drones` | dashboard | content-writer | 2026-04-15-trains-drones.md |
| `factory` | dashboard | content-writer | 2026-04-15-factory-buildings.md |
| `kubernetes` | deployment | tech-writer | 2026-04-15-kubernetes-deployment.md |
| `docker-compose` | deployment | content-writer | 2026-04-15-docker-compose.md |
| `env-vars` | deployment | content-writer | 2026-04-15-environment-variables.md |
| `api-overview` | api-reference | tech-writer | 2026-04-15-api-overview.md |
| `api-auth` | api-reference | tech-writer | 2026-04-15-api-authentication.md |
| `api-servers` | api-reference | tech-writer | 2026-04-15-api-servers.md |
| `api-metrics` | api-reference | tech-writer | 2026-04-15-api-metrics.md |
| `api-websockets` | api-reference | tech-writer | 2026-04-15-api-websockets.md |
| `alert-rules` | alerts | content-writer | 2026-04-15-alert-rules.md |
| `discord-alerts` | alerts | content-writer | 2026-04-15-discord-alerts.md |
| `webhooks` | alerts | content-writer | 2026-04-15-webhook-alerts.md |
| `pricing` | pricing | content-writer | 2026-04-15-pricing-plans.md |
| `subscription` | pricing | content-writer | 2026-04-15-subscription.md |
| `faq` | troubleshooting | content-writer | 2026-04-15-faq.md |
| `troubleshooting` | troubleshooting | content-writer | 2026-04-15-troubleshooting.md |
| `connection-errors` | troubleshooting | content-writer | 2026-04-15-connection-errors.md |

## Spawn Template

When spawning a content-writer for a section, use this prompt template:

```
Spawn agent: [content-writer OR tech-writer based on table above]
Team: ficsit-docs (or create a new single-task team)

Task: Write the [SECTION NAME] documentation post.

Required filename: _posts/[filename from table]
Category: [category from table]

BEFORE WRITING:
1. Read docs/technical-spec.md completely
2. Read .claude/rules/content-rules.md for formatting requirements

Required front matter fields:
- title: "[Title]"
- date: 2026-04-15 00:00:00 +0000
- categories: [[category]]
- tags: [satisfactory, ficsitmonitor, 2-4 specific tags]
- description: "[150-160 char SEO description]"
- toc: true

Required sections: Overview, Prerequisites, [main content], Next Steps

Key technical facts to include (from technical-spec.md):
[FILL IN specific facts relevant to this section]

Cross-links to include:
[FILL IN related posts to link to]

Report to team-lead when the post is created.
```

## For tech-writer sections (API + Kubernetes)

Add to the prompt:
```
Also read:
- /home/pablo/satisfactory-server/routes/api.php
- /home/pablo/satisfactory-server/app/Modules/Server/Services/FrmApiClient.php
- /home/pablo/satisfactory-server/k8s/dashboard/ (for kubernetes)

Use actual field names from models. Do not invent API field names.
```

$ARGUMENTS provides the section name to write.
