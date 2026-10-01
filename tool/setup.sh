#!/usr/bin/env bash
# One-time setup after cloning: git hooks, local env file, dependencies.
set -euo pipefail
cd "$(dirname "$0")/.."

git config core.hooksPath .githooks
chmod +x .githooks/* .claude/hooks/*.sh tool/*.sh
echo "✔ git hooks enabled (.githooks)"

if [ ! -f api_end_points.env ]; then
  cp api_end_points.env.example api_end_points.env
  echo "✔ created api_end_points.env from the example. Fill in real values (it is git-ignored)."
fi

flutter pub get
echo "✔ done. Run: flutter run --flavor dev --dart-define-from-file=api_end_points.env"
