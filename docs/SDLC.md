# Working with Claude Code: team SDLC

Every stage has a skill or agent, so Claude follows the same steps and conventions for everyone.
Skills are run with `/name`. Agents are started by asking Claude, e.g. "run the flutter-reviewer agent".

| Stage | Use | Output |
|---|---|---|
| 1. Plan | `/feature-spec <feature>` (use plan mode for big or unclear work) | `docs/specs/<feature>.md` approved by the dev and the lead |
| 2. Build | `/new-feature`, `/new-endpoint`, `/new-screen`, `/add-translation`, `/web-safe-platform` | Code in the standard layout, wired into DI and routes |
| 3. Verify | `/pre-pr-check` | Format, analyze, tests, web-safety, translations, secrets checklist |
| 4. Review | `flutter-reviewer` agent; `security-auditor` agent when auth, storage, network, logging or build config changed | Findings by severity, with file:line |
| 5. Ship | `/release <bump> <flavor>` | Version bump, changelog, tag, build commands, Sentry symbols |

## What runs automatically
| Guard | Where | What it does |
|---|---|---|
| Path-scoped rules | `.claude/rules/*.md` | Loaded when Claude touches matching files (e.g. the networking rules for `data/`) |
| Secret-file hook | `.claude/hooks/block_secrets.sh` (PreToolUse) | Blocks Claude from reading or editing `.env`, keystores, certs and Firebase configs |
| Permissions | `.claude/settings.json` | Allows analyze, test, format and git read commands without prompts; denies force-push and `--no-verify` |
| pre-commit | `.githooks/pre-commit` | Rejects secret files and secret-looking values |
| commit-msg | `.githooks/commit-msg` | Enforces Conventional Commits |
| pre-push | `.githooks/pre-push` | Branch naming, no pushes to master/main/develop, format check, analyze, test |

Git hooks are enabled by `tool/setup.sh` (`git config core.hooksPath .githooks`). Every developer runs it once after cloning.

## A typical feature
```text
git switch -c feature/leave-balance
/feature-spec leave_balance          ← paste the ticket and the API sample; review the spec
/new-feature leave_balance           ← scaffolds and wires everything
(iterate: /new-endpoint, /new-screen, manual UI polish)
/pre-pr-check
"run flutter-reviewer"               ← fix the must-fix findings
git commit -m "feat(leave-balance): show balance per leave type"
git push -u origin feature/leave-balance   ← pre-push runs the checks
```

## Team conventions for using Claude
- Commit `.claude/` and `CLAUDE.md`. Personal tweaks go in `.claude/settings.local.json` / `CLAUDE.local.md` (git-ignored).
- When Claude gets a convention wrong twice, fix the rule file, not just the code. Rules are reviewed in PRs like code.
- Keep `CLAUDE.md` short. Detail belongs in the rules (loaded by path) and skills (loaded on demand).
- Claude commits or pushes only when asked. Hooks are never bypassed.

## Changing this setup
| To change | Edit |
|---|---|
| A convention | the matching `.claude/rules/*.md`, and the templates in the related skill |
| A scaffold template | `.claude/skills/<skill>/SKILL.md` + `lib/features/example/` (keep them in sync) |
| Blocked secret patterns | `.claude/hooks/block_secrets.sh`, `.githooks/pre-commit`, `.gitignore`, `settings.json` deny list |
| Commit or branch format | `.githooks/commit-msg`, `.githooks/pre-push`, `.claude/rules/git-workflow.md` |
