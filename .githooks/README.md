# .githooks/: local git hooks

Enabled once per clone by `tool/setup.sh` (`git config core.hooksPath .githooks`). They run on your machine before code leaves it. Never bypass them with `--no-verify`; fix the cause.

| File | Runs on | What it checks |
|---|---|---|
| `pre-commit` | `git commit` | Rejects staged secret files (`.env`, `key.properties`, `.jks`, `.keystore`, `.pem`, `.p12`, `.p8`, `.cer`, `.mobileprovision`, Firebase configs) except `*.example`. Scans added lines for secret-looking values (API keys, private keys, tokens, `password = '...'`). Add `# secrets-ignore` to a line for a known false positive |
| `commit-msg` | `git commit` | Header must be `type(scope)!: subject` with type in feat, fix, refactor, perf, test, docs, build, ci, chore, revert, style. Merge, revert, fixup and squash messages pass |
| `pre-push` | `git push` | Branch name must match `feature\|bugfix\|hotfix\|release\|chore/<kebab-name>`; blocks pushes to `master`, `main`, `develop`; then `dart format` check, `flutter analyze`, and `flutter test` |

The same checks run in CI (`.github/workflows/ci.yml`), so a skipped hook is still caught on the PR.
