---
name: pre-pr-check
description: VERIFY stage. Runs the full local quality gate on the current branch (format, analyze, tests, web-safety grep, translation parity, secret scan, architecture conventions on changed files) and reports a pass/fail checklist. Use before opening a PR, before pushing, or when asked whether the work is done or ready.
---

# Pre-PR check

Run every step, even if an earlier one fails. Report a checklist at the end.

1. **Scope**: `git diff --name-only $(git merge-base HEAD origin/develop 2>/dev/null || git merge-base HEAD origin/main 2>/dev/null || git merge-base HEAD origin/master)...HEAD` plus uncommitted changes. Review only these files for steps 6–7.
2. **Format**: `dart format --output=none --set-exit-if-changed lib test`. If it fails, run `dart format lib test` and say so.
3. **Analyze**: `flutter analyze`. There must be 0 errors and 0 warnings. List the infos introduced by this branch.
4. **Tests**: `flutter test`.
5. **Web safety**: `grep -rn "import 'dart:io'" lib | grep -v '_io.dart'` and `grep -rn "Platform\.is" lib | grep -v '_io.dart'` must both print nothing.
6. **Translations**:
   - Run the key-parity script from `.claude/skills/add-translation/SKILL.md`.
   - In changed Dart files, look for hard-coded user-facing strings in `Text('...')`, `title: '...'` or `hintText: '...'` without `.tr()`.
7. **Conventions** on changed files:
   - Folder names match `.claude/rules/architecture.md`.
   - Cubits extend `SafeCubit<BaseState>`, and no cubit imports a repository or the network client.
   - Every new route has a constant in `AppRouter`, and every new repository and use case is registered in `di.dart`.
   - No `print(`, no `Dio(` outside `core/services/network`, no inline URLs.
8. **Secrets**: run `.githooks/pre-commit` logic against the branch diff (`git diff <base>...HEAD`). Look for keys, tokens and passwords.
9. **Branch name and commits**: the branch matches `^(feature|bugfix|hotfix|release|chore)/`, and the commit headers follow Conventional Commits.
10. **Process**:
   - Feature branches have `docs/specs/<feature>.md` with `Status: approved`; flag a missing or `draft` spec. `Contract status: mocked` blocks QA.
   - Every new cubit and model under the diff has a matching test in `test/` (see `.claude/rules/testing.md`).
   - `CHANGELOG.md` is only touched by `/release`.

## Report
```
Pre-PR check: <branch>
✅/❌ Format   ✅/❌ Analyze (n issues)   ✅/❌ Tests (n passed)
✅/❌ Web-safe   ✅/❌ Translations   ✅/❌ Conventions   ✅/❌ Secrets   ✅/❌ Branch/commits   ✅/❌ Spec/tests
Must fix: …
Suggestions: …
```
If everything passes, suggest running the `flutter-reviewer` agent, the `design-reviewer` agent for UI changes, and `security-auditor` if auth, storage, network or logging changed. Then run `/pr-description`.
