---
name: fix-bug
description: BUILD stage for bugfix/ and hotfix/ branches. Reproduces a reported bug, writes a failing test, fixes the root cause with the smallest change, and records the root cause for the PR. Use when given a bug ticket, crash report, or production incident.
argument-hint: <ticket text | steps to reproduce | stack trace>
---

# Fix bug

## Steps
1. **Branch**: confirm the branch is `bugfix/<name>` (or `hotfix/<name>` for a production incident, cut from the last release tag). If not, say so and ask before creating one.
2. **Understand**: collect expected vs actual, app version, flavor, platform and OS, and logs (never paste tokens or PII). For a stack trace from an obfuscated release, ask for the symbolicated trace. Ask one batch of questions if the steps are incomplete.
3. **Locate**: find the layer that owns the fault using `.claude/rules/architecture.md`. Check if the cause is the API response instead of the app. If so, stop and write a backend question (see `docs/INTEGRATION.md`), because the app must not hide a contract bug.
4. **Reproduce in a test**: add a failing test under `test/` (cubit, model, or use case). If it cannot be unit-tested, write the manual steps for QA.
5. **Fix** the root cause with the smallest change. Do not edit existing tests or weaken assertions to make them pass; the only test change allowed is adding the new regression test. If an existing test is wrong, stop and tell the user why. No drive-by refactors or formatting changes in the same commit.
6. **Verify**: the new test passes, then `/pre-pr-check`.
7. **Report** for the PR:

```markdown
### Root cause
### Fix
### Regression test
### Risk and areas to retest
### Introduced in (commit or version, if known)
```

8. For a hotfix: keep the diff minimal, run `security-auditor` too, and remind the user to merge the fix back to the base branch after release (see `docs/WORKFLOW.md`).
9. Commit message: `fix(<scope>): <what is fixed>`. Commit only when the user asks.
