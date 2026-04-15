---
description: Show current documentation site status — what's written, what's missing
allowed-tools: Bash, Read, Glob, Grep
---

# /project:status

Show the current state of the FICSIT.monitor documentation site.

## 1. Posts Written

```bash
echo "=== Posts in _posts/ ==="
ls _posts/*.md 2>/dev/null | sort || echo "(none)"
echo ""
echo "Total: $(ls _posts/*.md 2>/dev/null | wc -l) posts"
```

## 2. Posts by Category

```bash
echo "=== Posts by category ==="
grep -rh "^categories:" _posts/ 2>/dev/null | sort | uniq -c | sort -rn
```

## 3. Expected Posts (from docs/architecture.md)

Compare written posts against the expected list:

```bash
echo "=== Expected posts from docs/architecture.md ==="
grep "2026-04-15-.*\.md" docs/architecture.md 2>/dev/null | sort
```

Missing = posts in architecture.md but not in _posts/.

## 4. Site Configuration Status

```bash
echo "=== _config.yml status ==="
grep -E "^title:|^tagline:|^theme_mode:|^toc:" _config.yml 2>/dev/null
```

If title is still "Chirpy" or blank, site hasn't been configured yet.

## 5. Build Status

```bash
echo "=== Jekyll build ==="
if command -v bundle &>/dev/null && bundle list 2>/dev/null | grep -q jekyll-theme-chirpy; then
  bundle exec jekyll build --quiet 2>&1 | tail -5 && echo "Build: PASSED" || echo "Build: FAILED"
else
  echo "Jekyll gems not installed — run: bundle install"
fi
```

## 6. Front Matter Coverage

```bash
echo "=== Front matter coverage ==="
total=$(ls _posts/*.md 2>/dev/null | wc -l)
with_desc=$(grep -rl "^description:" _posts/ 2>/dev/null | wc -l)
with_toc=$(grep -rl "^toc: true" _posts/ 2>/dev/null | wc -l)
echo "Posts with description: $with_desc / $total"
echo "Posts with toc: $with_toc / $total"
```

## 7. Agent Team Infrastructure

```bash
echo "=== Agent team setup ==="
# Check settings
grep -q "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" .claude/settings.json 2>/dev/null && \
  echo "Agent teams: ENABLED" || echo "Agent teams: NOT configured"

# Count agents
echo "Agents defined: $(ls .claude/agents/*.md 2>/dev/null | wc -l) / 9"

# Check hooks executable
echo "Hooks executable:"
for h in .claude/hooks/*.sh; do
  [[ -x "$h" ]] && echo "  [OK] $h" || echo "  [WARN] $h (not executable — run: chmod +x .claude/hooks/*.sh)"
done
```

## 8. Summary Table

Output a coverage table:

```
DOCUMENTATION STATUS
====================
Category              Expected  Written  Status
─────────────────────────────────────────────
getting-started       4         X        [DONE/IN PROGRESS/NOT STARTED]
prerequisites         3         X        [...]
dashboard             6         X        [...]
deployment            3         X        [...]
api-reference         5         X        [...]
alerts                3         X        [...]
pricing               2         X        [...]
troubleshooting       3         X        [...]
─────────────────────────────────────────────
TOTAL                 29        X        [X% complete]

Jekyll build:         [PASS/FAIL/NOT CHECKED]
Agent teams enabled:  [YES/NO]
Hooks executable:     [YES/NEEDS chmod]
Next action:          [recommendation]
```

$ARGUMENTS can filter to a specific category: `/project:status dashboard`
