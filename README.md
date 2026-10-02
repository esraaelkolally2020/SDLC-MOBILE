# Flutter Starter Template

Start every new Flutter app (Android, iOS, web) from this template. You get:
- **App core:** Clean Architecture, Cubit, get_it, go_router, a Dio network layer that never throws, dev/stage/prod flavors, English and Arabic, web-safe platform code
- **Claude Code setup:** rules, skills, review agents and hooks that make Claude follow the same architecture and process for everyone
- **Guards:** git hooks and CI that block secrets, bad commits and broken builds
- **A process:** intent → spec → plan → build → verify → review → release, with named approvers at each step

## Start a new project (5 minutes)
```bash
cp -R flutter_starter_template my_app && cd my_app
rm -rf .git build .dart_tool
tool/rename_project.sh my_app com.company.myapp "My App"
git init -b main && tool/setup.sh        # enables git hooks, creates api_end_points.env, pub get
# fill in api_end_points.env (git-ignored), then run:
flutter run --flavor dev --dart-define-from-file=api_end_points.env
git add . && git commit -m "chore: bootstrap from starter template"
```
Then, once per project:
1. Set the real code owners in the CODEOWNERS file and turn on branch protection for `main` (PR required, one approval, CI green, code-owner review).
2. Keep `lib/features/example/` until your first real feature exists; the skills copy its shape. Then delete it.

## Build a feature: the developer loop
Run these in Claude Code, in order. The lead's approval gates are in [docs/WORKFLOW.md](docs/WORKFLOW.md).

| Step | Command | Result |
|---|---|---|
| 1 | `/new-intent <idea>` | `docs/intent/<name>.md`, approved by the product owner |
| 2 | `/api-contract-check` and `/design-handoff` | Questions for backend and designer |
| 3 | `/feature-spec <feature>` | `docs/specs/<feature>.md`, approved before any code |
| 4 | plan mode, then `/new-feature <feature>` | `docs/plans/<feature>.md`, then code wired into DI and routes |
| 5 | `/new-endpoint`, `/new-screen`, `/add-translation`, `/add-tests` | The rest of the feature, with tests |
| 6 | `/pre-pr-check` | Format, analyze, tests, web-safety, translations, secrets |
| 7 | ask for `flutter-reviewer` (and `design-reviewer`, `security-auditor` when relevant) | Findings to fix |
| 8 | `/pr-description`, open the PR | A human approves; you never merge your own work |
| 9 | `/release` | Version, changelog, tag, build commands |

Bugs: `/fix-bug`. Optional modules (Firebase, maps, device security): [docs/ADD_ONS.md](docs/ADD_ONS.md).

## Commands
| | |
|---|---|
| Run (mobile) | `flutter run --flavor dev --dart-define-from-file=api_end_points.env` |
| Run (web) | `flutter run -d chrome --dart-define-from-file=api_end_points.env --dart-define=FLUTTER_APP_FLAVOR=dev` |
| Check | `dart format lib test && flutter analyze && flutter test` |

## Read next
| You are | Read |
|---|---|
| Developer, first day | this page, then [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| Mobile lead | [docs/WORKFLOW.md](docs/WORKFLOW.md), [docs/PLAYBOOK.md](docs/PLAYBOOK.md), [REVIEW.md](REVIEW.md) |
| Working with backend, design or business | [docs/INTEGRATION.md](docs/INTEGRATION.md) |
| Looking for a file | [docs/PROJECT_MAP.md](docs/PROJECT_MAP.md), or the README in each folder |
| Seeing the process as pictures | [docs/WORKFLOW_DIAGRAM.md](docs/WORKFLOW_DIAGRAM.md) |

## Never
- Commit or read `api_end_points.env`, keystores or certificates (hooks block it).
- Use `dart:io` outside `*_io.dart` files (it breaks web), hard-code user-facing text, or bypass hooks with `--no-verify`.
- Start a feature whose spec is not approved, or invent API fields.
