---
description: Initialize the complete FICSIT.monitor documentation agent team
allowed-tools: Read, Bash, Glob, Grep
---

# /project:init-team

Initialize the complete documentation agent team for FICSIT.monitor.
This command orchestrates all waves of documentation production.

## Pre-flight Verification (run BEFORE spawning any agents)

Verify these files exist. If any are missing, STOP and report which ones:
1. `CLAUDE.md` — project context
2. `docs/technical-spec.md` — product knowledge base
3. `docs/architecture.md` — IA plan
4. `.claude/settings.json` — agent teams enabled
5. `.claude/agents/` — all 9 agent definition files

Quick check:
```bash
bash scripts/init-agent-team.sh
```

## CRITICAL: Spawn ALL Agents BEFORE Activating Delegate Mode

Known bug: teammates spawned AFTER Delegate Mode is activated may inherit
restrictions that prevent them from reading/writing files. The correct sequence:
1. Spawn ALL teammates first
2. Wait for confirmation that all are running
3. THEN activate Delegate Mode (Shift+Tab)

## Wave 1 — Architecture (no dependencies)

Spawn these two simultaneously:

**Task 1 — docs-architect:**
```
Spawn agent: docs-architect
Team: ficsit-docs
Task: Design documentation IA and update navigation.

Read CLAUDE.md and docs/architecture.md completely.
Then do the following:
1. Update _tabs/about.md to serve as a Documentation hub with links to all doc categories. Use post_url tags.
2. Update the `icon:` in _tabs/about.md to `fas fa-book` and `order: 1`.
3. Review docs/architecture.md and confirm or update the list of posts to create.
4. Send a message to team-lead with the confirmed complete list of _posts/ filenames and their categories.

File ownership: _tabs/**, docs/architecture.md only.
```

**Task 2 — jekyll-developer:**
```
Spawn agent: jekyll-developer
Team: ficsit-docs
Task: Configure Jekyll site identity.

Read CLAUDE.md, then read _config.yml carefully.
1. Set: title="FICSIT.monitor Docs", tagline="Real-time monitoring for Satisfactory dedicated servers"
2. Set: theme_mode=dark, toc=true, lang=en
3. Set social name (Pablo Hurtado Gonzalo), email (pablohurtadohg@gmail.com), github username (PabloHurtadoGonzalo86)
4. Update _data/contact.yml: keep github and email, add a Discord placeholder entry
5. Update _data/share.yml: keep Twitter/X and Reddit
6. Run: bundle exec jekyll build --quiet — verify build passes
7. Report to team-lead when complete.

File ownership: _config.yml, _data/** only.
```

## Wave 2 — Content Production (blockedBy Wave 1)

Wait for docs-architect (Task 1) to confirm the file list, then spawn in parallel:

**Tasks 3-4 — content-writer (server-setup ⭐ PRIMARY):**
```
Spawn agent: content-writer
Team: ficsit-docs
Task: Write the server-setup documentation (PRIMARY category — most important).

The documentation explains how someone sets up a Satisfactory dedicated server FROM SCRATCH.

Read docs/technical-spec.md section 3 (Satisfactory Dedicated Server Setup) completely.
Read .claude/rules/content-rules.md for formatting.

Create these posts in _posts/:
1. 2026-04-15-what-is-satisfactory-server.md (categories: [server-setup])
   — What is a dedicated server, why run one, use cases
2. 2026-04-15-vps-requirements.md (categories: [server-setup])
   — VPS minimum specs: 4 CPU, 12GB RAM, 20GB disk; recommended providers
3. 2026-04-15-install-docker.md (categories: [server-setup])
   — Installing Docker CE on Ubuntu 22.04/24.04 step by step
4. 2026-04-15-run-satisfactory-docker.md (categories: [server-setup])
   — docker run + docker-compose for wolveix/satisfactory-server:latest
   — All env vars (MAXPLAYERS, AUTOSAVEINTERVAL, PGID/PUID)
   — Volume: /config, first boot, SteamCMD download
5. 2026-04-15-server-firewall.md (categories: [server-setup])
   — UFW rules for ports 7777 TCP+UDP, 8888 TCP, 8080 TCP, 8081 TCP
   — Cloud security group examples (Hetzner, DigitalOcean)
6. 2026-04-15-server-first-launch.md (categories: [server-setup])
   — Connecting game client to server, creating world, setting admin password

Key Docker command (from technical-spec.md section 3 — use exactly this):
docker run -d --name satisfactory-server --restart unless-stopped \
  -p 7777:7777/tcp -p 7777:7777/udp -p 8888:8888/tcp \
  -p 8080:8080/tcp -p 8081:8081/tcp \
  -e MAXPLAYERS=8 -e PGID=1000 -e PUID=1000 \
  -e STEAMBETA=false -e SKIPUPDATE=false -e AUTOSAVEINTERVAL=300 \
  -v /home/satisfactory/data:/config \
  wolveix/satisfactory-server:latest

Report to team-lead when all 6 posts are created.
```

**Tasks 5-6 — content-writer (getting-started + prerequisites + FAQ):**
```
Spawn agent: content-writer
Team: ficsit-docs
Task: Write getting-started, prerequisites and FAQ documentation.

Read docs/technical-spec.md completely before writing.
Read .claude/rules/content-rules.md for formatting.

Create these posts in _posts/:
1. 2026-04-15-what-is-ficsitmonitor.md (categories: [getting-started])
2. 2026-04-15-quick-start.md (categories: [getting-started])
3. 2026-04-15-frm-installation.md (categories: [prerequisites])
   — FRM mod: Satisfactory Mod Manager install, verify with curl http://IP:8080/getPower
4. 2026-04-15-api-token.md (categories: [prerequisites])
5. 2026-04-15-add-first-server.md (categories: [getting-started])
6. 2026-04-15-faq.md (categories: [troubleshooting])

Key facts: FRM required for most metrics, ports 7777/8888/8080/8081, deprecated 15000/15777.
Report to team-lead when all 6 posts are created.
```

**Tasks 7-8 — content-writer (dashboard + pricing):**
```
Spawn agent: content-writer
Team: ficsit-docs
Task: Write dashboard features and pricing documentation.

Read docs/technical-spec.md completely before writing.

Create these posts:
1. 2026-04-15-dashboard-overview.md (categories: [dashboard])
2. 2026-04-15-power-grid-panel.md (categories: [dashboard])
3. 2026-04-15-production-panel.md (categories: [dashboard])
4. 2026-04-15-players-sessions.md (categories: [dashboard])
5. 2026-04-15-pricing-plans.md (categories: [pricing])

Power panel: document power_production, power_consumed, power_capacity,
battery_percent, battery_differential, fuse_triggered fields.
Pricing: use exact prices from technical-spec.md pricing section.

Report to team-lead when all 5 posts are created.
```

**Tasks 7-8 — tech-writer (API + Kubernetes):**
```
Spawn agent: tech-writer
Team: ficsit-docs
Task: Write API reference and Kubernetes deployment documentation.

Read docs/technical-spec.md, then read source files:
- /home/pablo/satisfactory-server/routes/api.php
- /home/pablo/satisfactory-server/app/Modules/Server/Services/FrmApiClient.php
- /home/pablo/satisfactory-server/k8s/dashboard/ (all manifest files)

Create these posts:
1. 2026-04-15-api-overview.md (categories: [api-reference])
2. 2026-04-15-api-authentication.md (categories: [api-reference])
3. 2026-04-15-api-servers.md (categories: [api-reference])
4. 2026-04-15-api-metrics.md (categories: [api-reference])
5. 2026-04-15-kubernetes-deployment.md (categories: [deployment])

Use ACTUAL field names from models. Verify K8s resources from manifests.
Include example curl requests and JSON responses.

Report to team-lead when all 5 posts are created.
```

## Wave 3 — Quality (blockedBy Wave 2 completion)

After Wave 2 agents confirm completion, spawn simultaneously:

**Task 9 — qa-engineer:**
```
Run full validation suite:
1. bundle exec jekyll build --quiet
2. ./tools/test.sh
3. Check all posts have required front matter fields
4. Check for deprecated ports (15000, 15777)
5. Check for wrong product name (FicsitOps)
Report all issues to team-lead.
```

**Task 10 — seo-specialist:**
```
SEO pass on all posts in _posts/:
1. Verify every post has description of 150-160 chars
2. Verify tags include 'satisfactory' and 'ficsitmonitor'
3. Add OG image references where missing (placeholder path is fine)
4. Optimize descriptions using keyword map from .claude/agents/seo-specialist.md
Report changes made to team-lead.
```

**Task 11 — code-reviewer:**
```
Review all posts for:
1. Heading hierarchy (no skipping H2→H4)
2. Code blocks with language specifiers
3. Technical accuracy vs docs/technical-spec.md
4. Cross-reference links exist
Report findings categorized as blocking/warning/suggestion.
```

## Wave 4 — Security (blockedBy Wave 2, parallel with Wave 3)

**Task 12 — security-reviewer:**
```
Security audit of all _posts/ files:
1. Scan for real credentials, API tokens, private keys
2. Scan for internal K8s service names in wrong context
3. Verify example IPs are placeholder values
Report all findings with risk levels.
```

## Completion

After all tasks complete:
1. Fix any blocking issues from Wave 3/4
2. Run `./tools/test.sh` one final time
3. Report final status to user
4. Clean up the team with TeamDelete

$ARGUMENTS can provide additional focus areas or specific sections to prioritize.
