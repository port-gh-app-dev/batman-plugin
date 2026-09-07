#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$ROOT_DIR/.cursor-plugin/plugin.json"
MCP_CONFIG="$ROOT_DIR/mcp.json"

log() {
  printf '[batman] %s\n' "$*"
}

failures=0
check_file() {
  local file="$1"
  if [[ -f "$file" ]]; then
    log "found ${file#"$ROOT_DIR"/}"
  else
    printf '[batman] missing required file: %s\n' "${file#"$ROOT_DIR"/}" >&2
    failures=$((failures + 1))
  fi
}

log "running session audit"
check_file "$MANIFEST"
check_file "$MCP_CONFIG"
check_file "$ROOT_DIR/hooks/hooks.json"
check_file "$ROOT_DIR/README.md"

if [[ -f "$MANIFEST" ]] && ! grep -q '"version"' "$MANIFEST"; then
  printf '[batman] plugin manifest does not declare a version\n' >&2
  failures=$((failures + 1))
fi

if [[ -f "$MCP_CONFIG" ]] && grep -nE 'https?://(example\.com|localhost)' "$MCP_CONFIG"; then
  log "warning: MCP configuration contains a placeholder endpoint"
fi

if (( failures > 0 )); then
  printf '[batman] audit failed with %d issue(s)\n' "$failures" >&2
  exit 1
fi

log "audit passed"
