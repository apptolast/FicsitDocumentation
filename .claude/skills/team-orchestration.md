# Team Orchestration Skill

## When to Invoke This Skill

Invoke when the user asks to:
- "Generate documentation" / "write the docs"
- "Set up the agent team" / "initialize the team"
- "Write all the documentation pages"
- Work on multiple documentation sections simultaneously

## Pre-conditions Checklist

Before spawning any agents, verify ALL of these:
- [ ] `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in `.claude/settings.json`
- [ ] `CLAUDE.md` exists with project context
- [ ] `docs/technical-spec.md` exists with product knowledge
- [ ] `docs/architecture.md` exists with IA plan
- [ ] Hook scripts are executable: `chmod +x .claude/hooks/*.sh`

Quick pre-flight: `bash scripts/init-agent-team.sh`

## Wave Execution Pattern

### Wave 1 — Architecture (no dependencies, simultaneous)

```
Task → docs-architect:
  Read CLAUDE.md + docs/architecture.md
  Update _tabs/about.md as documentation hub
  Confirm exact list of _posts/ files to create
  Send list to team-lead via SendMessage

Task → jekyll-developer:
  Read CLAUDE.md + _config.yml
  Set title="FICSIT.monitor Docs", theme_mode=dark, social fields
  Update _data/contact.yml and _data/share.yml
  Run bundle exec jekyll build --quiet
  Report build status to team-lead
```

### Wave 2 — Content Production (blockedBy Wave 1, parallel)

Wait for docs-architect to confirm file list, then spawn simultaneously:

```
Task → content-writer (batch A):
  getting-started (4 posts) + prerequisites (3 posts)
  Read docs/technical-spec.md before writing
  Each post: complete front matter + overview + prereqs + content + next steps

Task → content-writer (batch B):
  dashboard (5 posts) + pricing (1 post) + faq (1 post)
  Read docs/technical-spec.md before writing

Task → tech-writer:
  api-reference (5 posts) + kubernetes deployment (1 post)
  Read source files: routes/api.php, FrmApiClient.php, k8s/dashboard/
  Use actual field names, not invented ones
```

### Wave 3 — Validation (blockedBy Wave 2, parallel with Wave 4)

```
Task → qa-engineer:
  bundle exec jekyll build --quiet
  ./tools/test.sh (build + html-proofer)
  Grep for deprecated ports, wrong product name
  Report blocking issues to team-lead

Task → seo-specialist:
  Verify description 150-160 chars per post
  Check tag coverage (satisfactory + ficsitmonitor on every post)
  Add OG image references where missing
  Report changes made to team-lead

Task → code-reviewer:
  Check heading hierarchy in all posts
  Check code block language specifiers
  Cross-verify technical facts against technical-spec.md
  Report findings as blocking/warning/suggestion
```

### Wave 4 — Security (blockedBy Wave 2, parallel with Wave 3)

```
Task → security-reviewer:
  Scan _posts/ for real credentials, tokens, private keys
  Check for internal K8s service names in wrong context
  Verify example IPs are placeholders
  Report with risk levels
```

## Spawn Order Critical Note

**ALWAYS spawn ALL teammates BEFORE activating Delegate Mode (Shift+Tab)**

Known bug: teammates spawned after Delegate Mode activation may inherit
restrictions and fail to read/write files.

Correct sequence:
1. Spawn ALL wave agents
2. Confirm they're all running (Shift+Down to cycle through)
3. THEN activate Delegate Mode

## Optimal Team Configuration

| Role | Count | Model | Wave |
|------|-------|-------|------|
| docs-architect | 1 | opus | 1 |
| jekyll-developer | 1 | sonnet | 1 |
| content-writer | 2-3 (parallel batches) | sonnet | 2 |
| tech-writer | 1 | opus | 2 |
| qa-engineer | 1 | sonnet | 3 |
| seo-specialist | 1 | sonnet | 3 |
| code-reviewer | 1 | sonnet | 3 |
| security-reviewer | 1 | sonnet | 4 |

**Total: max 9 teammates (spawn QA/SEO/review/security as Wave 2 finishes)**

## Task Sizing Guidelines

- Each content-writer task: 5-7 posts maximum
- Each task should complete in 5-15 minutes
- Tech-writer tasks: 3-5 posts (more complex, slower)
- QA/review tasks: entire codebase in one task (read-only, faster)

## Inter-agent Communication Patterns

| Sender | Receiver | When | Content |
|--------|----------|------|---------|
| docs-architect | team-lead | After Wave 1 | Confirmed list of exact filenames |
| team-lead | content-writer(s) | Start of Wave 2 | Task assignments with filename lists |
| qa-engineer | team-lead | Wave 3 complete | Blocking issues list |
| code-reviewer | team-lead | Wave 3 complete | Review report |
| team-lead | content-writer | After QA reports | Fix assignments |

Use broadcast sparingly (only for team-wide announcements like "Wave 2 complete").
Direct messages for task-specific communication.

## Cleanup

After all documentation is generated and validated:
1. Run final `./tools/test.sh` to confirm clean build
2. Ask team-lead to clean up team (TeamDelete)
3. `git add -A && git commit -m "Add complete FICSIT.monitor documentation"`
4. Push to main for GitHub Pages deployment (after human review)
