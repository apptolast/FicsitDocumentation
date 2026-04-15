#!/usr/bin/env bash
# init-agent-team.sh
# Pre-flight check for FICSIT.monitor documentation agent team.
# Verifies all required files exist before launching the team.
#
# Usage: bash scripts/init-agent-team.sh

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERRORS=0
WARNINGS=0

echo -e "${BLUE}╔═══════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  FICSIT.monitor Docs — Agent Team Pre-flight Check ║${NC}"
echo -e "${BLUE}╚═══════════════════════════════════════════════════╝${NC}"
echo ""

# Helper functions
check_file() {
  local desc="$1"
  local path="$2"
  if [[ -f "$path" ]]; then
    echo -e "  ${GREEN}[OK]${NC}      $desc"
  else
    echo -e "  ${RED}[MISSING]${NC} $desc"
    echo -e "            Expected: $path"
    ERRORS=$((ERRORS + 1))
  fi
}

check_executable() {
  local desc="$1"
  local path="$2"
  if [[ -x "$path" ]]; then
    echo -e "  ${GREEN}[OK]${NC}      $desc (executable)"
  elif [[ -f "$path" ]]; then
    echo -e "  ${YELLOW}[WARN]${NC}    $desc exists but is NOT executable"
    echo -e "            Run: chmod +x $path"
    WARNINGS=$((WARNINGS + 1))
  else
    echo -e "  ${RED}[MISSING]${NC} $desc"
    ERRORS=$((ERRORS + 1))
  fi
}

check_content() {
  local desc="$1"
  local file="$2"
  local pattern="$3"
  if [[ -f "$file" ]] && grep -q "$pattern" "$file" 2>/dev/null; then
    echo -e "  ${GREEN}[OK]${NC}      $desc"
  elif [[ -f "$file" ]]; then
    echo -e "  ${YELLOW}[WARN]${NC}    $desc — pattern not found in $(basename "$file")"
    WARNINGS=$((WARNINGS + 1))
  fi
}

echo "── Foundation files ──────────────────────────────────"
check_file "CLAUDE.md" "$PROJECT_DIR/CLAUDE.md"
check_file "docs/technical-spec.md" "$PROJECT_DIR/docs/technical-spec.md"
check_file "docs/architecture.md" "$PROJECT_DIR/docs/architecture.md"

echo ""
echo "── Claude Code configuration ─────────────────────────"
check_file ".claude/settings.json" "$PROJECT_DIR/.claude/settings.json"
check_content "Agent teams enabled" "$PROJECT_DIR/.claude/settings.json" "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS"

echo ""
echo "── Agent definitions ─────────────────────────────────"
for agent in docs-architect content-writer jekyll-developer qa-engineer seo-specialist code-reviewer security-reviewer tech-writer mentor; do
  check_file ".claude/agents/$agent.md" "$PROJECT_DIR/.claude/agents/$agent.md"
done

echo ""
echo "── Hooks ─────────────────────────────────────────────"
check_executable ".claude/hooks/validate-task.sh" "$PROJECT_DIR/.claude/hooks/validate-task.sh"
check_executable ".claude/hooks/format-on-save.sh" "$PROJECT_DIR/.claude/hooks/format-on-save.sh"
check_executable ".claude/hooks/security-check.sh" "$PROJECT_DIR/.claude/hooks/security-check.sh"

echo ""
echo "── Commands ──────────────────────────────────────────"
for cmd in init-team write-section validate-docs review-pr status; do
  check_file ".claude/commands/$cmd.md" "$PROJECT_DIR/.claude/commands/$cmd.md"
done

echo ""
echo "── Skills ────────────────────────────────────────────"
check_file ".claude/skills/team-orchestration.md" "$PROJECT_DIR/.claude/skills/team-orchestration.md"
check_file ".claude/skills/quality-gates.md" "$PROJECT_DIR/.claude/skills/quality-gates.md"

echo ""
echo "── Jekyll environment ────────────────────────────────"
if command -v bundle &>/dev/null; then
  echo -e "  ${GREEN}[OK]${NC}      bundler: $(bundle --version 2>/dev/null || echo 'found')"
  if bundle list 2>/dev/null | grep -q "jekyll-theme-chirpy"; then
    echo -e "  ${GREEN}[OK]${NC}      jekyll-theme-chirpy installed"
  else
    echo -e "  ${YELLOW}[WARN]${NC}    Jekyll gems not installed — run: bundle install"
    echo -e "            (Jekyll validation hooks will be skipped until gems are installed)"
    WARNINGS=$((WARNINGS + 1))
  fi
else
  echo -e "  ${YELLOW}[WARN]${NC}    bundler not found — Jekyll validation hooks will be skipped"
  echo -e "            Install Ruby and bundler if you want build validation"
  WARNINGS=$((WARNINGS + 1))
fi

echo ""
echo "── Hooks permissions reminder ────────────────────────"
if [[ ! -x "$PROJECT_DIR/.claude/hooks/validate-task.sh" ]] || \
   [[ ! -x "$PROJECT_DIR/.claude/hooks/format-on-save.sh" ]] || \
   [[ ! -x "$PROJECT_DIR/.claude/hooks/security-check.sh" ]]; then
  echo -e "  ${YELLOW}[ACTION]${NC}  Make hooks executable:"
  echo -e "            chmod +x $PROJECT_DIR/.claude/hooks/*.sh"
fi

echo ""
echo "═══════════════════════════════════════════════════════"

if [[ $ERRORS -gt 0 ]]; then
  echo -e "${RED}FAILED: $ERRORS required file(s) missing.${NC}"
  echo "Create the missing files before launching the agent team."
  echo ""
  exit 1
elif [[ $WARNINGS -gt 0 ]]; then
  echo -e "${YELLOW}READY with $WARNINGS warning(s).${NC}"
  echo "The team can be launched, but check the warnings above."
else
  echo -e "${GREEN}ALL CHECKS PASSED.${NC}"
fi

echo ""
echo "To launch the agent team, open Claude Code in this project and run:"
echo ""
echo -e "  ${BLUE}/project:init-team${NC}"
echo ""
echo "Or to write a single section:"
echo ""
echo -e "  ${BLUE}/project:write-section [section-name]${NC}"
echo ""
echo "Or to check documentation status:"
echo ""
echo -e "  ${BLUE}/project:status${NC}"
echo ""
