---
name: pr-description
description: REVIEW stage. Drafts the pull request title and description from the branch diff, spec and commits, following .github/pull_request_template.md, including QA notes and the approval checklist. Use when opening or updating a PR, or when asked for a PR description or QA notes.
argument-hint: [ticket id]
---

# PR description

## Steps
1. Gather: `git log <base>..HEAD --pretty=format:'%s'`, `git diff --stat <base>...HEAD`, the spec at `docs/specs/<feature>.md` if present, and any `/pre-pr-check` or reviewer output from this session. `<base>` is `origin/main`.
2. Read `.github/pull_request_template.md` and fill every section. Do not invent test results: only report what was actually run in this session, and mark anything else as "not run".
3. Title: Conventional Commit style, ≤ 72 chars, e.g. `feat(leave-balance): show balance per leave type`.
4. Fill:
   - **What and why**: from the spec and ticket, in plain language for the PO and QA
   - **Changes**: grouped by layer or screen, not file by file
   - **Backend dependency**: endpoints used, contract status, any `mocked` parts
   - **Design**: Figma link, deviations from design and why
   - **How to test (QA)**: flavor, account type, steps, expected results, edge cases (empty, offline, 401, Arabic, web)
   - **Screenshots needed**: list mobile, web, and Arabic shots the author must attach (you cannot take them)
   - **Approvals**: the G4 checklist from `docs/WORKFLOW.md` with unchecked boxes
   - **Risks and rollback**
5. Output the title and the body as markdown for the user to paste. Create the PR with `gh` only if asked, and end the PR body with the attribution line from the session instructions when one applies.
