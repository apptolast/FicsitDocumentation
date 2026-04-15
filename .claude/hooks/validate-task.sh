#!/usr/bin/env bash
# validate-task.sh
# Hook: TaskCompleted
# Runs a Jekyll build before allowing a task to be marked complete.
# Exit 2 = block task completion (build failed)
# Exit 0 = allow completion
#
# Must be executable: chmod +x .claude/hooks/validate-task.sh

set -euo pipefail

# Read stdin — required for all hooks even if not used
INPUT=$(cat)

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-/home/pablo/FicsitDocumentation}"
cd "$PROJECT_DIR"

# Graceful degradation: skip if bundler not installed
if ! command -v bundle &>/dev/null; then
  echo "WARNING: bundler not found — skipping Jekyll build validation" >&2
  exit 0
fi

# Graceful degradation: skip if Jekyll gems not installed
if ! bundle list 2>/dev/null | grep -q "jekyll-theme-chirpy"; then
  echo "WARNING: Jekyll gems not installed — run 'bundle install' — skipping validation" >&2
  exit 0
fi

echo "Running Jekyll build validation..." >&2

if bundle exec jekyll build --quiet 2>&1; then
  echo "Jekyll build passed." >&2
  exit 0
else
  echo "" >&2
  echo "ERROR: Jekyll build failed. Task completion blocked." >&2
  echo "Fix the build errors above before marking this task complete." >&2
  exit 2
fi
