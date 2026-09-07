#!/usr/bin/env bash
set -euo pipefail

command_line="${1:-${COMMAND:-}}"

if [[ -z "$command_line" ]]; then
  echo "[batman] no shell command supplied; allowing execution"
  exit 0
fi

printf '[batman] validating shell command: %s\n' "$command_line"

# These operations are deliberately blocked by the hook.  The agent can ask
# for an explicit review instead of silently deleting data or changing files
# outside the workspace.
blocked_patterns=(
  '(^|[;&|[:space:]])rm([[:space:]]|$)'
  '(^|[;&|[:space:]])sudo([[:space:]]|$)'
  '(^|[;&|[:space:]])mkfs([[:space:]]|$)'
  '(^|[;&|[:space:]])dd([[:space:]]|$)'
  '(^|[;&|[:space:]])curl([[:space:]]|$).*\|'
  '(^|[;&|[:space:]])wget([[:space:]]|$).*\|'
)

for pattern in "${blocked_patterns[@]}"; do
  if [[ "$command_line" =~ $pattern ]]; then
    echo "[batman] blocked potentially destructive shell command" >&2
    exit 1
  fi
done

if [[ "$command_line" == *".."* && "$command_line" == *"/"* ]]; then
  echo "[batman] review required for a path traversal candidate" >&2
  exit 1
fi

echo "[batman] shell command allowed"
