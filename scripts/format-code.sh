#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

printf '[batman] checking shell script formatting\n'
while IFS= read -r -d '' script; do
  if [[ ! -x "$script" ]]; then
    printf '[batman] %s is not executable\n' "${script#"$ROOT_DIR"/}" >&2
    exit 1
  fi
  if [[ -n "$(tail -c 1 "$script" 2>/dev/null)" ]]; then
    printf '[batman] %s is missing a trailing newline\n' "${script#"$ROOT_DIR"/}" >&2
    exit 1
  fi
done < <(find "$ROOT_DIR/scripts" -type f -name '*.sh' -print0)

printf '[batman] shell formatting check passed\n'
