#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERRORS=0
WARNINGS=0

error() {
  printf '[batman] error: %s\n' "$*" >&2
  ERRORS=$((ERRORS + 1))
}

warning() {
  printf '[batman] warning: %s\n' "$*" >&2
  WARNINGS=$((WARNINGS + 1))
}

require_file() {
  local path="$1"
  [[ -f "$ROOT_DIR/$path" ]] || error "missing required file: $path"
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || error "required command is unavailable: $1"
}

json_has_key() {
  local file="$1"
  local key="$2"
  node -e '
    const fs = require("fs");
    const [file, key] = process.argv.slice(1);
    const value = JSON.parse(fs.readFileSync(file, "utf8"));
    if (!(key in value)) process.exit(1);
  ' "$file" "$key"
}

json_is_valid() {
  local file="$1"
  node -e '
    const fs = require("fs");
    JSON.parse(fs.readFileSync(process.argv[1], "utf8"));
  ' "$file" 2>/dev/null
}

check_json() {
  local relative="$1"
  local absolute="$ROOT_DIR/$relative"
  if ! json_is_valid "$absolute"; then
    error "$relative is not valid JSON"
  fi
}

check_manifest() {
  local manifest="$ROOT_DIR/.cursor-plugin/plugin.json"
  check_json ".cursor-plugin/plugin.json"
  for key in name displayName version description; do
    if ! json_has_key "$manifest" "$key"; then
      error "plugin manifest is missing '$key'"
    fi
  done

  if grep -q '"version"[[:space:]]*:[[:space:]]*"0\.0\.0"' "$manifest"; then
    warning "plugin version is still 0.0.0"
  fi
}

check_mcp_servers() {
  local config="$ROOT_DIR/mcp.json"
  check_json "mcp.json"
  local names
  names="$(node - "$config" <<'NODE'
const fs = require("fs");
const value = JSON.parse(fs.readFileSync(process.argv[2], "utf8"));
const servers = value.mcpServers || {};
for (const [name, server] of Object.entries(servers)) {
  if (!server.command && !server.url) {
    console.error(`${name}: server must define command or url`);
    process.exitCode = 1;
  }
  if (server.command && !Array.isArray(server.args)) {
    console.error(`${name}: command servers must define args as an array`);
    process.exitCode = 1;
  }
  if (server.url && !/^https?:\/\//.test(server.url)) {
    console.error(`${name}: remote server URL must use HTTP(S)`);
    process.exitCode = 1;
  }
  console.log(name);
}
NODE
)" || {
    error "MCP server entries are invalid"
    return
  }

  [[ -n "$names" ]] || error "mcp.json must define at least one server"
  while IFS= read -r name; do
    [[ "$name" =~ ^[a-z0-9][a-z0-9-]*$ ]] ||
      error "MCP server name '$name' must use lowercase kebab-case"
  done <<< "$names"
}

check_hooks() {
  local hooks="$ROOT_DIR/hooks/hooks.json"
  check_json "hooks/hooks.json"
  local referenced
  referenced="$(grep -oE '\./scripts/[A-Za-z0-9._-]+\.sh' "$hooks" | sort -u || true)"
  [[ -n "$referenced" ]] || error "hooks/hooks.json does not reference any scripts"
  while IFS= read -r path; do
    [[ -z "$path" ]] && continue
    local script="$ROOT_DIR/${path#./}"
    [[ -f "$script" ]] || error "hook references missing script: ${path#./}"
    [[ -x "$script" ]] || error "hook script is not executable: ${path#./}"
  done <<< "$referenced"
}

check_documentation() {
  for path in README.md CHANGELOG.md LICENSE; do
    require_file "$path"
  done
  grep -q 'validate-plugin.sh' "$ROOT_DIR/README.md" ||
    warning "README does not document validate-plugin.sh"
}

printf '[batman] validating plugin in %s\n' "$ROOT_DIR"
require_command node
check_manifest
check_mcp_servers
check_hooks
check_documentation

if (( ERRORS > 0 )); then
  printf '[batman] validation failed: %d error(s), %d warning(s)\n' "$ERRORS" "$WARNINGS" >&2
  exit 1
fi

printf '[batman] validation passed with %d warning(s)\n' "$WARNINGS"
