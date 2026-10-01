---
paths:
  - "**"
---
# Git workflow

- Branches: `feature/<kebab-name>`, `bugfix/…`, `hotfix/…`, `release/<x.y.z>`, `chore/…`. Pushing to `master`/`main`/`develop` is blocked. Changes go through PRs.
- Commits use Conventional Commits, enforced by `.githooks/commit-msg`:
  `feat(login): add OTP resend timer` · `fix(network): handle 502 as server error` · `refactor(example): extract card widget`.
  Types: feat, fix, refactor, perf, test, docs, build, ci, chore, revert, style. Header ≤ 72 chars, imperative mood, no trailing period.
- One logical change per commit. Don't mix formatting-only changes with behavior changes.
- `pre-push` runs the format check, `flutter analyze` and `flutter test`. Never bypass hooks with `--no-verify`. Fix the cause.
- Only commit or push when the user asks.
- PR description: what and why, screenshots for UI changes (mobile and web), how it was tested, and the linked work item.
