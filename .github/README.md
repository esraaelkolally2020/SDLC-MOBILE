# .github/: GitHub automation and templates

| File | Purpose |
|---|---|
| `workflows/ci.yml` | Runs on every pull request and on pushes to `main`: `pub get`, format check, `flutter analyze`, `flutter test`, web-safety grep (no `dart:io` or `Platform.is` outside `*_io.dart`), and en-US / ar-SA key parity. Mark it as a required check in branch protection. Keep it in line with `/pre-pr-check` |
| `pull_request_template.md` | Pre-filled PR description: what and why, backend and design status, QA steps, screenshots (mobile, web, Arabic), verification checklist, G4 approvals, risks. `/pr-description` fills it |
| `ISSUE_TEMPLATE/feature_request.md` | Work item that must meet the Definition of Ready (business goal, acceptance criteria, design, API contract, priority) with PO / DES / BE tick boxes |
| `ISSUE_TEMPLATE/bug_report.md` | Bug with steps, expected vs actual, environment (version, flavor, OS, device) and severity |
| `CODEOWNERS` | Auto-requests review from the listed owners. Needs "Require review from Code Owners" in branch protection and write access for each owner |

## Branch protection to enable on `main` (GitHub settings, not a file)
- Require a pull request and at least one approval
- Require the `CI / verify` check to pass
- Require review from Code Owners
- Block force pushes and deletion
