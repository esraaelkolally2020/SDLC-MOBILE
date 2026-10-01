#!/usr/bin/env bash
# PreToolUse hook: stops Claude from reading, editing or shelling into secret
# files. Exit code 2 blocks the tool call and sends stderr back to Claude.
set -euo pipefail

input="$(cat)"

# Pull out the field that names the target: file_path / path for file tools,
# command for Bash. Falls back to the raw JSON if no JSON parser is available.
extract() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$input" | jq -r '.tool_input | (.file_path // .path // .notebook_path // .command // .pattern // "")'
  elif command -v python3 >/dev/null 2>&1; then
    printf '%s' "$input" | python3 -c 'import json,sys; t=json.load(sys.stdin).get("tool_input",{}); print(t.get("file_path") or t.get("path") or t.get("notebook_path") or t.get("command") or t.get("pattern") or "")'
  else
    printf '%s' "$input"
  fi
}

target="$(extract)"

# Allowed uses are removed first so they never trigger a match:
# *.env.example templates, and passing the env file to flutter as
# --dart-define-from-file (flutter reads it; Claude never sees the values).
cleaned="$(printf '%s' "$target" | sed -E \
  -e 's/[A-Za-z0-9_.\/-]*\.env\.example//g' \
  -e 's/--dart-define-from-file[= ][A-Za-z0-9_.\/-]+//g')"

pattern='(\.env([^A-Za-z0-9_]|$)|key\.properties|\.jks([^A-Za-z0-9_]|$)|\.keystore([^A-Za-z0-9_]|$)|\.pem([^A-Za-z0-9_]|$)|\.p12([^A-Za-z0-9_]|$)|\.p8([^A-Za-z0-9_]|$)|\.cer([^A-Za-z0-9_]|$)|google-services\.json|GoogleService-Info\.plist|auth_readme)'

if printf '%s' "$cleaned" | grep -Eiq "$pattern"; then
  echo "Blocked by .claude/hooks/block_secrets.sh: '$target' is a secret file (env, signing key, certificate or credentials). Do not read or change it. Ask the user to make the change, or use the matching *.example file." >&2
  exit 2
fi

exit 0
