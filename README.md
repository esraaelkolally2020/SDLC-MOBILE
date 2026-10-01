# Flutter Starter Template

The team's starting point for new Flutter apps (Android, iOS, web). It contains:
- a production-tested core: Clean Architecture, Cubit, get_it, go_router, a Dio network layer that never throws, flavors, en/ar localization, and web-safe platform code
- a Claude Code setup that follows the team SDLC: plan, build, verify, review, ship
- git hooks for secrets, commit messages and pre-push checks

## Start a new project
```bash
cp -R flutter_starter_template my_app && cd my_app
rm -rf .git build .dart_tool
tool/rename_project.sh my_app com.company.myapp "My App"
git init -b master && tool/setup.sh          # enables hooks, creates api_end_points.env, pub get
# fill in api_end_points.env (git-ignored), then:
flutter run --flavor dev --dart-define-from-file=api_end_points.env
git add . && git commit -m "chore: bootstrap from starter template"
```
Then remove or replace `lib/features/example/` once your first real feature exists. Keep it until then, because the Claude skills use it as their reference.

## Daily commands
| | |
|---|---|
| Run (mobile) | `flutter run --flavor dev --dart-define-from-file=api_end_points.env` |
| Run (web) | `flutter run -d chrome --dart-define-from-file=api_end_points.env --dart-define=FLUTTER_APP_FLAVOR=dev` |
| Check | `dart format lib test && flutter analyze && flutter test` |
| Release | `/release` in Claude Code, or see `.claude/skills/release/SKILL.md` |

## Docs
- [docs/SDLC.md](docs/SDLC.md): how to work with Claude Code here (skills, agents, hooks)
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md): layers, network layer, state, flavors, web support
- [docs/ADD_ONS.md](docs/ADD_ONS.md): Firebase, maps, device security, in-app update and more
- [CLAUDE.md](CLAUDE.md) and [.claude/rules/](.claude/rules/): conventions (Claude and humans both follow them)

## Project layout
```
lib/core/        shared code: network, state, DI helpers, components, services
lib/features/    one folder per feature (data / domain / presentation)
.claude/         rules, skills, agents, hooks, settings
.githooks/       pre-commit, commit-msg, pre-push
tool/            setup.sh, rename_project.sh
docs/            SDLC, architecture, add-ons, specs/
```
