#!/usr/bin/env bash
# PostToolUse hook: formats a Dart file right after Claude edits it, so
# formatting never shows up as noise in review. Never blocks; always exits 0.
set -uo pipefail

input="$(cat)"

if command -v jq >/dev/null 2>&1; then
  file="$(printf '%s' "$input" | jq -r '.tool_input.file_path // .tool_input.path // ""')"
elif command -v python3 >/dev/null 2>&1; then
  file="$(printf '%s' "$input" | python3 -c 'import json,sys; t=json.load(sys.stdin).get("tool_input",{}); print(t.get("file_path") or t.get("path") or "")')"
else
  exit 0
fi

case "$file" in
  *.dart) [ -f "$file" ] && dart format "$file" >/dev/null 2>&1 ;;
esac
exit 0
