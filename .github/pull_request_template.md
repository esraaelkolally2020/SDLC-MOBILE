## What and why
<!-- Plain language, for PO and QA. -->
Ticket:

## Changes
-

## Backend
Endpoints used:
Contract status: confirmed / draft / mocked (a mocked PR cannot pass QA)

## Design
Figma link:
Deviations from design and why:

## How to test (QA)
Flavor / account:
Steps and expected results:
Edge cases: empty, offline, 401, Arabic/RTL, web

## Screenshots (UI changes)
| Mobile | Web | Arabic |
|---|---|---|
| | | |

## Verification
- [ ] `/pre-pr-check` passes and CI is green
- [ ] Tests added for new cubit methods and models
- [ ] No hard-coded strings; en-US and ar-SA updated
- [ ] No `dart:io` outside `*_io.dart`; no secrets; no `print`
- [ ] `flutter-reviewer` run, no must-fix left
- [ ] `design-reviewer` run (UI changes)
- [ ] `security-auditor` run (auth, storage, network, logging, build config)

## Approvals (docs/WORKFLOW.md G4)
- [ ] Mobile lead
- [ ] Designer (UI changes)
- [ ] Product owner accepted on a dev build
- [ ] Spec status is `approved` and matches the code

## Risks and rollback
