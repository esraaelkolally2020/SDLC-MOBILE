# CLAUDE.md

Flutter app (Android, iOS, web) built from the team starter template.
Clean Architecture with feature folders, Cubit state, get_it DI, go_router, and a Dio network layer that never throws.

## Commands
- Setup once: `tool/setup.sh` (git hooks, local env file, pub get)
- Run: `flutter run --flavor dev --dart-define-from-file=api_end_points.env`
- Web: `flutter run -d chrome --dart-define-from-file=api_end_points.env` (no `--flavor` on web)
- Check: `dart format lib test` · `flutter analyze` · `flutter test`. Run all three before you say a task is done; analyze must report no issues and tests must pass. Healthy output: `No issues found!` and `All tests passed!`.
- Flavors: `dev`, `stage`, `prod`. The flavor is read from `FLUTTER_APP_FLAVOR`, which `--flavor` sets.

## Layout
```
lib/
  main.dart · app_services.dart (startup) · di.dart (get_it) · myapp.dart
  core/
    cubit/safe_cubit.dart          base for every cubit
    global/state/base_state.dart   shared states (Loading, Loaded<T>, Error, Empty, ...)
    data/constants/                app_router.dart (paths), api_endpoints_constants.dart, app_colors.dart
    data/repository/main_repository.dart
    services/network/              NetworkClientInterface, EitherResponse, ApiResponse, errors
    services/route_manager/        go_router config
    services/platform/             AppPlatform + _stub/_io/_web files
    component/                     shared widgets (p_button, p_text, custom_layout_builder, ...)
  features/<feature>/              see .claude/rules/architecture.md
assets/translations/{en-US,ar-SA}.json
```
`lib/features/example/` is the reference feature. Copy its shape for new code.

## Rules
Path-scoped rules in `.claude/rules/` load automatically:
architecture · state-management · networking · ui-components · localization · platform-web · security · testing · git-workflow.

## Workflow
Gates, approvers and the integration with backend, design and business are in `docs/WORKFLOW.md` and `docs/INTEGRATION.md`. Tooling is in `docs/SDLC.md`:
`/api-contract-check` + `/design-handoff` → `/feature-spec` (approved before code) → `/new-feature` (`/new-endpoint`, `/new-screen`, `/add-translation`, `/web-safe-platform`, `/add-tests`; `/fix-bug` for bugs) → `/pre-pr-check` → `flutter-reviewer`, `design-reviewer`, `security-auditor` agents → `/pr-description` → `/release`.
Do not start building a feature whose spec is not `Status: approved`. Never invent API fields or design tokens; ask.

## Review
Review policy is in `REVIEW.md`. You never approve your own code. When the same review finding appears twice, propose a line for this file or a rule.
Stage overview: `docs/PLAYBOOK.md`. For non-trivial work, write `docs/plans/<feature>.md` in plan mode before coding.

## Never
- Read, print or edit `*.env`, `key.properties`, keystores or certificates. A hook blocks this. Use `api_end_points.env.example`.
- Import `dart:io` or use `Platform.*` outside `*_io.dart` files. It breaks the web build.
- Hard-code user-facing strings. Add keys to both translation files.
- Use `--no-verify`, or push to `master`/`main`/`develop`.
