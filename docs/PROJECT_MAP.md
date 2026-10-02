# Project map: what every file and folder is for

Reference for the whole repository. Each main folder also has its own README. For the process, read [WORKFLOW.md](WORKFLOW.md); for the stage overview, [PLAYBOOK.md](PLAYBOOK.md).

### Root
| Path | Purpose |
|---|---|
| `README.md` | Short entry page: what this is, how to start, the daily loop |
| `REVIEW.md` | Review policy: passes, severity, feedback loop |
| `CLAUDE.md` | Short project brief and hard rules that Claude loads in every session |
| `CHANGELOG.md` | Release notes, written by `/release` from Conventional Commits |
| `pubspec.yaml`, `pubspec.lock` | Dependencies, assets, version (`X.Y.Z+build`) |
| `analysis_options.yaml` | Analyzer and lint rules. `flutter analyze` must be clean |
| `api_end_points.env.example` | Documents every compile-time key (base URLs, DSN, SHA fingerprints). Copy to `api_end_points.env` |
| `api_end_points.env` | Your real values. **Git-ignored. Never commit, read or paste it** |
| `.gitignore` | Ignores env files, keystores, build output, symbols |
| `.metadata`, `starter_app.iml`, `.idea/` | IDE and Flutter tool files |
| `.vscode/launch.json` | Run configurations for the dev, stage and prod flavors |

### `lib/` (app code)
| Path | Purpose |
|---|---|
| `main.dart` | Entry point: bindings, `AppServices.init()`, DI, optional Sentry, `runApp` |
| `app_services.dart` | Startup services: localization, SharedPreferences, session, flavor |
| `di.dart` | get_it registrations: use cases, repositories, network and services (cubits are not registered) |
| `myapp.dart` | `MaterialApp.router` with theme and localization |
| `core/cubit/safe_cubit.dart` | Base class of every cubit. Ignores `emit` after close |
| `core/global/state/` | Shared `BaseState` classes (Initial, Loading, Loaded, Error, Empty, ButtonLoading, ...) |
| `core/global/enums/`, `global_func.dart` | Shared enums and helper functions |
| `core/data/constants/` | `api_endpoints_constants.dart` (all endpoints), `app_router.dart` (route paths), `app_colors.dart`, dimensions, shared-preferences keys |
| `core/data/assets_helper/` | Typed constants for icon and SVG asset paths |
| `core/data/app_dimensions/` | Spacing and sizing values |
| `core/data/repository/main_repository.dart` | Base class of repository implementations (`remoteData`) |
| `core/extensions/` | `String`, `DateTime` and navigator extensions |
| `core/component/` | Shared widgets: appbar, button (`PButton`), text (`PText`), text_field, image, custom dialog/bottom sheet/toast/loader, layout_builder (`CustomLayoutBuilder`), list_view and pagination |
| `core/services/network/` | The network layer: `interface/` (`NetworkClientInterface`), `client/` (Dio), `response/` (`EitherResponse`, `ApiResponse`), `error/` (typed errors), `interceptors/` (headers, 401 handling, logging, pinning), `log/` (log sanitizer) |
| `core/services/route_manager/` | go_router config, auth redirect hook, route logging |
| `core/services/platform/` | `AppPlatform` plus `_stub/_io/_web` files, the web-safe pattern |
| `core/services/local_storage/` | `secure_storage` (tokens) and `shared_preference` (non-sensitive) |
| `core/services/session_manager/` | Session and token state |
| `core/services/flavorizer/` | dev, stage and prod flavor model and base URL selection |
| `core/services/localization/` | easy_localization setup |
| `core/services/theme/` | Light and dark Material 3 themes, `ThemeCubit` |
| `core/services/connectivity/` | Online/offline detection and default actions |
| `core/services/log/app_log.dart` | The only allowed logger (debug only). No `print` |
| `core/services/sentry/` | Crash reporting, prod flavor only |
| `core/pickup_module/download_file_module/` | Shared file download module (web-safe saver) |
| `features/<feature>/` | One folder per feature: `data/model`, `data/repository`, `domain/repository`, `domain/use_case`, `presentation/cubit`, `presentation/ui/<screen>/{screen,widgets}` |
| `features/example/` | Reference feature. Copy its shape. Remove once a real feature exists |

### `assets/`, `test/`, platform folders
| Path | Purpose |
|---|---|
| `assets/translations/en-US.json`, `ar-SA.json` | All user-facing text. Keys must match in both files |
| `assets/images/svg/`, `assets/images/png/` | Icons and images, referenced through `assets_helper` |
| `test/` | Mirrors `lib/`. `test/features/example/` is the reference test |
| `android/`, `ios/`, `web/` | Platform projects: flavors, signing config, manifests, `index.html`. Signing files stay out of git |

### `docs/`
| Path | Purpose | Audience |
|---|---|---|
| `docs/WORKFLOW.md` | Roles, gates G0 to G7, Definition of Ready/Done, bug, hotfix and release paths | Everyone, lead first |
| `docs/PLAYBOOK.md` | The six AI-native SDLC stages mapped to files, skills, hooks, approvers, metrics | Everyone |
| `docs/intent/`, `docs/plans/` | Stage 1 intent and stage 3 plan templates and files | DEV, PO |
| `docs/WORKFLOW_DIAGRAM.md` | Diagrams of the process, who does what, guards, and a stage-by-stage file reference | Everyone |
| `docs/README.md` | Index of the docs folder and reading order | New joiners |
| `docs/INTEGRATION.md` | Backend contract, design handoff, business acceptance tracks | Lead, DEV, BE, DES, PO |
| `docs/SDLC.md` | How Claude Code is used per stage, and what runs automatically | Developers |
| `docs/ARCHITECTURE.md` | Layers, DI, routing, network layer, state, flavors, web | Developers |
| `docs/ADD_ONS.md` | Optional modules: Firebase, maps, device security, in-app update | Developers |
| `docs/specs/_template.md` | Spec template with approvals, contract status and design sections | DEV |
| `docs/specs/<feature>.md` | One approved spec per feature | Everyone |

### `.claude/` (Claude Code setup)
| Path | Purpose |
|---|---|
| `settings.json` | Permissions (allow checks, deny secrets and force-push) and the secrets hook |
| `hooks/block_secrets.sh` | Stops Claude from reading or editing env files, keystores, certs and Firebase configs |
| `rules/architecture.md` | Feature folders, dependency direction, DI and route wiring |
| `rules/state-management.md` | `SafeCubit`, `BaseState`, method shape, BlocProvider placement |
| `rules/networking.md` | Network client, `EitherResponse`, endpoints, models |
| `rules/ui-components.md` | Shared components, theme tokens, responsive and RTL rules |
| `rules/localization.md` | Translation keys and file parity |
| `rules/platform-web.md` | No `dart:io` outside `*_io.dart`, conditional-import pattern |
| `rules/security.md` | Secrets, storage, logging, pinning, release obfuscation |
| `rules/testing.md` | Test layout, fakes, what to cover |
| `rules/git-workflow.md` | Branches, Conventional Commits, PR rules |

Skills (run with `/name`):
| Skill | Stage | Use it to |
|---|---|---|
| `api-contract-check` | Plan | Review a Swagger or sample JSON and produce questions for backend |
| `design-handoff` | Plan | Turn designs into a component map, token decisions and questions for the designer |
| `feature-spec` | Plan | Write the spec that gets approved at G1 |
| `new-feature` | Build | Scaffold a full feature and wire DI, route and translations |
| `new-endpoint` | Build | Add one API call through every layer |
| `new-screen` | Build | Add a screen with its bodies and route |
| `add-translation` | Build | Add keys to both languages and check parity |
| `web-safe-platform` | Build | Wrap a platform API in a `_stub/_io/_web` facade |
| `add-tests` | Build | Write cubit and model tests |
| `fix-bug` | Build | Reproduce, test, fix and document a bug or hotfix |
| `pre-pr-check` | Verify | Run the local quality gate |
| `pr-description` | Review | Draft the PR body and QA notes |
| `release` | Ship | Version, changelog, tag, obfuscated builds, symbols |

Agents (ask Claude, e.g. "run the design-reviewer agent"):
| Agent | Use it to |
|---|---|
| `flutter-reviewer` | Review the branch against architecture, state, network, web, localization and UI rules |
| `design-reviewer` | Review UI against the spec: tokens, states, RTL, responsive, accessibility |
| `security-auditor` | Audit secrets, storage, logging, pinning, deeplinks and build config |

### `.githooks/` and `tool/`
| Path | Purpose |
|---|---|
| `.githooks/pre-commit` | Rejects secret files and secret-looking values |
| `.githooks/commit-msg` | Enforces Conventional Commits |
| `.githooks/pre-push` | Branch naming, blocks pushes to master/main/develop, then format, analyze and tests |
| `tool/setup.sh` | One-time setup after cloning: enables hooks, creates the env file, `pub get` |
| `tool/rename_project.sh` | Renames package, bundle id and app name for a new project |

### `.github/`
| Path | Purpose |
|---|---|
| `workflows/ci.yml` | CI on every PR: format, analyze, test, web-safety, translation parity |
| `pull_request_template.md` | PR format with verification and approval checklists |
| `ISSUE_TEMPLATE/feature_request.md` | Work item that must meet the Definition of Ready |
| `ISSUE_TEMPLATE/bug_report.md` | Bug format with environment and severity |
| `CODEOWNERS` | Auto-requests lead review. Replace the placeholder team |

## Keeping this setup healthy
- When Claude gets a convention wrong twice, fix the rule file, not just the code. Rules are reviewed in PRs like code.
- Change a convention in the rule, the matching skill template and `lib/features/example/` in the same PR.
- Keep `.github/workflows/ci.yml` and `/pre-pr-check` checking the same things.
