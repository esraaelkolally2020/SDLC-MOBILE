---
paths:
  - "**"
---
# Git workflow

- Branches: `feature/<kebab-name>`, `bugfix/…`, `hotfix/…`, `release/<x.y.z>`, `chore/…`. Pushing to `master`/`main`/`develop` is blocked. Changes go through PRs.
- Base branch: `develop` if the project has one, otherwise `main`. PRs target it. Hotfixes branch from the last release tag. Approval gates and who signs off are in `docs/WORKFLOW.md`.
- Commits use Conventional Commits, enforced by `.githooks/commit-msg`:
  `feat(login): add OTP resend timer` · `fix(network): handle 502 as server error` · `refactor(example): extract card widget`.
  Types: feat, fix, refactor, perf, test, docs, build, ci, chore, revert, style. Header ≤ 72 chars, imperative mood, no trailing period.
- One logical change per commit. Don't mix formatting-only changes with behavior changes.
- `pre-push` runs the format check, `flutter analyze` and `flutter test`. Never bypass hooks with `--no-verify`. Fix the cause.
- Only commit or push when the user asks.
- PR description: use `.github/pull_request_template.md` (what and why, screenshots for UI changes on mobile, web and Arabic, how it was tested, linked work item, approvals). `/pr-description` drafts it.
- At least one mobile-lead approval before merge; the author does not merge unreviewed work.
