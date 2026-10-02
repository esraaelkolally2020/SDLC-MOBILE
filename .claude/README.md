# .claude/: Claude Code setup

Everything here is committed and shared. It makes Claude follow the team architecture and SDLC the same way for every developer. Personal tweaks go in `.claude/settings.local.json` (git-ignored).

This README is the only one in `.claude/`: Claude Code scans `rules/`, `skills/` and `agents/` and treats every file there as a rule, skill or agent, so a README inside them would be loaded as one.

## settings.json
Project permissions and hooks.
- **allow**: `flutter analyze/test/pub get/doctor`, `dart format/analyze`, read-only git (`status`, `diff`, `log`, `branch`, `show`) run without prompts.
- **deny**: reading or editing env files, `key.properties`, keystores, certificates and Firebase configs; `git push --force`; `--no-verify` on commit and push.
- **hooks**: runs `hooks/block_secrets.sh` before every Read, Edit, Write, Grep and Bash call, and `hooks/format_dart.sh` after every edit.

## hooks/
| File | What it does |
|---|---|
| `format_dart.sh` | PostToolUse hook. Runs `dart format` on a Dart file right after Claude edits it. Never blocks |
| `block_secrets.sh` | PreToolUse guard. Reads the tool call, extracts the target path or command, and exits with code 2 (block) if it names a secret file (`.env`, `key.properties`, `.jks`, `.keystore`, `.pem`, `.p12`, `.p8`, `.cer`, `google-services.json`, `GoogleService-Info.plist`). `*.env.example` and `--dart-define-from-file=...` are allowed. If it blocks a harmless command, change the wording or fix the pattern in this file |

## rules/
Conventions loaded automatically when Claude touches files that match the `paths:` in each file's header. Rules are reviewed in PRs like code.

| File | Loads for | Covers |
|---|---|---|
| `architecture.md` | `lib/**` | Feature folder layout, dependency direction (presentation → domain → data → core), DI and route wiring |
| `state-management.md` | presentation, `core/cubit`, `core/global/state` | `SafeCubit`, shared `BaseState` classes, standard method shape, where to create cubits |
| `networking.md` | `data/`, `domain/`, `core/services/network`, endpoint constants | `NetworkClientInterface`, `EitherResponse` that never throws, `ApiResponse` envelope, endpoints, hand-written models |
| `ui-components.md` | `presentation/ui`, `core/component` | Reuse shared widgets, theme tokens, `CustomLayoutBuilder`, sizer, const, RTL-safe layout |
| `localization.md` | `lib/**`, `assets/translations` | `.tr()` keys, naming, identical keys in en-US and ar-SA |
| `platform-web.md` | `lib/**` | No `dart:io` outside `*_io.dart`; conditional-import facade pattern |
| `security.md` | everything | Secrets in the git-ignored env file, secure storage for tokens, `AppLog` not `print`, certificate pinning, release obfuscation |
| `testing.md` | `test/**`, cubits, models, domain | Test layout, hand-written fakes, what each cubit method and model needs, bug-fix-first-test |
| `git-workflow.md` | everything | Branch names, `main` as base, Conventional Commits, one logical change per commit, PR rules, commit only when asked |

## skills/
Run with `/name`. Each folder contains one `SKILL.md` (the instructions Claude follows).

| Skill | Stage | What it does |
|---|---|---|
| `new-intent` | Plan | Turns an idea or incident into `docs/intent/<name>.md` for product owner approval |
| `api-contract-check` | Plan | Reviews a Swagger or sample JSON against the network layer; outputs gaps, questions for BE and a contract status |
| `design-handoff` | Plan | Turns designs into a component map, token decisions, asset list, missing-state questions and accessibility flags |
| `feature-spec` | Plan | Writes `docs/specs/<feature>.md` from `docs/specs/_template.md`; code starts only when it is approved |
| `new-feature` | Build | Scaffolds a full feature from `lib/features/example/`, wires DI, route, endpoint constant and translations |
| `new-endpoint` | Build | Adds one API call through every layer: constant, models, repository, use case, cubit |
| `new-screen` | Build | Adds a screen (main, mobile, web, desktop bodies) with its route and `BlocProvider` |
| `add-translation` | Build | Adds keys to both translation files and checks parity |
| `web-safe-platform` | Build | Wraps `dart:io` or plugin code in a `_stub/_io/_web` facade so web still builds |
| `add-tests` | Build | Writes cubit and model tests with hand-written fakes |
| `fix-bug` | Build | Reproduces a bug with a failing test, fixes the root cause, records it for the PR |
| `pre-pr-check` | Verify | Format, analyze, tests, web-safety, translations, conventions, secrets, branch/commits, spec/tests |
| `pr-description` | Review | Drafts the PR title and body from the diff and spec using the PR template |
| `release` | Ship | Version bump, changelog from commits, tag, per-flavor obfuscated build commands, Sentry symbols. Manual only (`disable-model-invocation`) |

## agents/
Read-only reviewers. Start one by asking Claude, for example "run the design-reviewer agent".

| Agent | Reviews | Output |
|---|---|---|
| `flutter-reviewer.md` | Architecture layers, folders, state, network, web safety, localization, UI, wiring, correctness | Must fix / Should fix / Nits with `file:line` |
| `design-reviewer.md` | Spec fidelity, theme tokens, all states, responsiveness, RTL, accessibility, performance | Must fix / Should fix / Needs a human visual check |
| `security-auditor.md` | Committed secrets, token storage, PII in logs, certificate pinning, WebView and deeplinks, `dart:io` leaks, debug code in release | Findings by severity |

## Changing this setup
Edit the rule and the matching skill template together, and keep `lib/features/example/` in sync. If Claude gets a convention wrong twice, fix the rule rather than the code only.
