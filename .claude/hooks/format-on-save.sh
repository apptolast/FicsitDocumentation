#!/usr/bin/env bash
# format-on-save.sh
# Hook: PostToolUse (Write|Edit|MultiEdit)
# Formats markdown and YAML files with prettier after each save.
# Uses --prose-wrap preserve to avoid breaking documentation paragraphs.
#
# Must be executable: chmod +x .claude/hooks/format-on-save.sh

set -euo pipefail

# Read stdin — PostToolUse provides tool event JSON
INPUT=$(cat)

# Extract the file path from the tool event payload using Python3 (no jq dependency)
FILE_PATH=$(python3 - <<'PYEOF'
import sys, json, os
try:
    data = json.loads(sys.stdin.read())
    tool_input = data.get('tool_input', {})
    path = tool_input.get('file_path', tool_input.get('path', ''))
    print(path)
except Exception:
    print('')
PYEOF
<<< "$INPUT" 2>/dev/null || echo "")

# Skip if no file path extracted
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# Skip if file does not exist
if [[ ! -f "$FILE_PATH" ]]; then
  exit 0
fi

# Only format markdown and YAML files
EXTENSION="${FILE_PATH##*.}"
case "$EXTENSION" in
  md|markdown|yml|yaml)
    ;;
  *)
    exit 0
    ;;
esac

# Graceful: skip if prettier not available
if ! command -v prettier &>/dev/null; then
  exit 0
fi

# --prose-wrap preserve: critical flag — prevents prettier from breaking
# documentation paragraphs at 80 chars, which destroys readability.
prettier --write --prose-wrap preserve "$FILE_PATH" 2>/dev/null || true

exit 0
