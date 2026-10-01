---
name: release
description: SHIP stage. Prepares a release: bumps the pubspec version/build number, writes the changelog from Conventional Commits, prints the per-flavor obfuscated build commands and the Sentry symbol upload steps. Use when asked to release, bump the version, build for the store, or prepare a build for QA/UAT.
argument-hint: <patch|minor|major|build> <dev|stage|prod>
disable-model-invocation: true
---

# Release

## 1. Preconditions
- The working tree is clean, the branch is `release/<x.y.z>` (or ask to create it), and `/pre-pr-check` passes.

## 2. Version
- In `pubspec.yaml`, `version: X.Y.Z+B`. Always increment `B`. Bump `X.Y.Z` per the argument (`build` = only `B`).
- Ask if unsure whether the stores already have a higher build number.

## 3. Changelog
- Find the commits since the last tag: `git log $(git describe --tags --abbrev=0 2>/dev/null || git rev-list --max-parents=0 HEAD)..HEAD --pretty=format:'%s'`
- Group them in `CHANGELOG.md` under `## X.Y.Z+B – <date>`: **Features** (feat), **Fixes** (fix), **Other** (perf, refactor, build). Skip chore, docs, style and test.

## 4. Commit and tag (only when the user confirms)
`git commit -am "chore(release): X.Y.Z+B"` and `git tag vX.Y.Z+B`.

## 5. Build commands (print them; run only if asked)
```bash
# Android App Bundle
flutter build appbundle --release --flavor <flavor> \
  --dart-define-from-file=api_end_points.env \
  --obfuscate --split-debug-info=build/symbols/<flavor>/X.Y.Z+B

# iOS
flutter build ipa --release --flavor <flavor> \
  --dart-define-from-file=api_end_points.env \
  --obfuscate --split-debug-info=build/symbols/<flavor>/X.Y.Z+B

# Web (no flavors; set FLUTTER_APP_FLAVOR explicitly)
flutter build web --release --dart-define-from-file=api_end_points.env \
  --dart-define=FLUTTER_APP_FLAVOR=<flavor>
```
Release signing needs `android/key.properties` + keystore (never in git) and the iOS distribution profile on the build machine.

## 6. Sentry symbols (prod)
```bash
dart run sentry_dart_plugin   # or: sentry-cli debug-files upload --org <org> --project <project> build/symbols/<flavor>/X.Y.Z+B
```
Keep `build/symbols/...` archived per release. Obfuscated stack traces can't be read without the symbols.

## 7. Report
The version, changelog entry, tag, commands to run, and a checklist: store notes, QA sign-off, and a smoke test on a real device for each platform.
