#!/usr/bin/env bash
# security-check.sh
# Hook: PreToolUse (Write|Edit)
# Blocks writing of secrets and credentials into documentation files.
# Exit 2 = block the write (secret detected)
# Exit 0 = allow the write
#
# Must be executable: chmod +x .claude/hooks/security-check.sh

set -euo pipefail

# Read stdin — PreToolUse provides tool event JSON
INPUT=$(cat)

# Extract file path and content using Python3 (no jq dependency)
read -r FILE_PATH CONTENT <<< "$(python3 - <<'PYEOF'
import sys, json
try:
    data = json.loads(sys.stdin.read())
    tool_input = data.get('tool_input', {})
    file_path = tool_input.get('file_path', tool_input.get('path', ''))
    content = tool_input.get('content', tool_input.get('new_string', ''))
    # Output file_path on one line, content as remainder
    import base64
    print(file_path)
    print(base64.b64encode(content.encode()).decode())
except Exception:
    print('')
    print('')
PYEOF
<<< "$INPUT" 2>/dev/null)"

# Decode content from base64 (to handle newlines safely)
if command -v python3 &>/dev/null && [[ -n "$CONTENT" ]]; then
  DECODED_CONTENT=$(python3 -c "import base64,sys; print(base64.b64decode('$CONTENT').decode())" 2>/dev/null || echo "")
else
  DECODED_CONTENT=""
fi

FOUND=0

# Patterns that should never appear in documentation files
# Each pattern is checked against the decoded content
declare -a BLOCKED_PATTERNS=(
  "APP_KEY=base64:"
  "DB_PASSWORD=[^$\"]"
  "REDIS_PASSWORD=[^$\"]"
  "ghp_[A-Za-z0-9]{36}"
  "sk-[A-Za-z0-9]{20}"
  "Bearer [A-Za-z0-9._-]{40}"
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$DECODED_CONTENT" | grep -qE "$pattern" 2>/dev/null; then
    echo "SECURITY BLOCK: Potential secret matches pattern '$pattern'" >&2
    echo "File: $FILE_PATH" >&2
    echo "Use placeholder values in documentation (e.g., 'your-api-token-here')" >&2
    FOUND=1
  fi
done

# Block writing to sensitive file patterns
BLOCKED_FILES=(".env" "secrets/" ".key" ".pem" "id_rsa" "credentials.json")
for blocked in "${BLOCKED_FILES[@]}"; do
  if [[ "$FILE_PATH" == *"$blocked"* ]]; then
    echo "SECURITY BLOCK: Writing to sensitive file path: $FILE_PATH" >&2
    FOUND=1
  fi
done

# Non-blocking warnings (log to stderr but allow)
# Internal K8s service names in public docs — might be intentional in deployment guides
if echo "$DECODED_CONTENT" | grep -qE "dashboard-postgres|dashboard-redis|dashboard-web\." 2>/dev/null; then
  echo "WARNING: Internal K8s service name detected in $FILE_PATH — verify this is intentional" >&2
  echo "(This is a warning only, write is allowed)" >&2
fi

if [[ $FOUND -eq 1 ]]; then
  exit 2
fi

exit 0
