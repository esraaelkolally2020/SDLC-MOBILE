# Delivery workflow and approval gates

The one document a mobile lead follows for any work item (feature, bug, hotfix, release).
[SDLC.md](SDLC.md) explains the Claude tooling. [INTEGRATION.md](INTEGRATION.md) explains the backend, design and business tracks that feed the gates below.

## Roles
| Role | Short | Owns |
|---|---|---|
| Product owner / business analyst | PO | Scope, acceptance criteria, UAT sign-off |
| Designer | DES | Figma, tokens, states, design sign-off |
| Backend lead | BE | API contract, stage/dev data, API changes |
| Mobile lead | LEAD | Spec approval, architecture, code review, release go/no-go |
| Mobile developer | DEV | Spec, code, tests, PR |
| QA | QA | Test cases, stage testing, regression |

## The gates
Nothing moves to the next stage until the gate's approvers have signed off in the ticket or PR. "Evidence" is what the DEV attaches.

| Gate | Stage | Approvers | Evidence | Claude tool |
|---|---|---|---|---|
| G0 Ready | Intake | PO, DES, BE | Ticket meets the Definition of Ready (below) | `/api-contract-check`, `/design-handoff` |
| G1 Spec | Plan | LEAD, PO, BE (contract), DES (screens) | `docs/specs/<feature>.md` in a draft PR, status `approved` | `/feature-spec` |
| G2 Built | Build | DEV | Code in the standard layout, tests written | `/new-feature`, `/new-endpoint`, `/new-screen`, `/add-translation`, `/web-safe-platform`, `/add-tests` |
| G3 Verified | Verify | CI + DEV | `/pre-pr-check` all green, CI green | `/pre-pr-check` |
| G4 Reviewed | Review | LEAD, DES (UI work), PO (acceptance on a dev build) | Review comments resolved, screenshots mobile + web + Arabic | `flutter-reviewer`, `design-reviewer`, `security-auditor`, `/pr-description` |
| G5 Merged | Integrate | LEAD | Squash or merge into the base branch, ticket moved to "In QA" | |
| G6 Accepted | QA / UAT | QA (stage build), PO (UAT), BE (smoke) | Test report, UAT sign-off | |
| G7 Released | Ship | LEAD (go/no-go), PO | Tag, changelog, store build, symbols uploaded | `/release`, `security-auditor` |

## Definition of Ready (G0)
A ticket may be picked up only when it has all of these. Missing items go back to the owner, DEV does not guess.
- [ ] Business goal and acceptance criteria written by PO (Given/When/Then)
- [ ] Design link covering default, loading, empty, error, and Arabic/RTL states (DES)
- [ ] API contract: Swagger/Postman link or sample JSON for every endpoint, with auth, error codes and pagination (BE). Endpoint available on `dev`, or an agreed mock
- [ ] Analytics, permissions, and feature-flag needs stated, or "none"
- [ ] Priority and target release

## Definition of Done (G4 to G5)
- [ ] Spec status is `approved` and still matches the code (update the spec if scope changed)
- [ ] `/pre-pr-check` passes locally and CI is green
- [ ] Unit tests cover each new cubit method and each new model `fromMap`
- [ ] No hard-coded strings, both translation files updated, RTL checked
- [ ] Works on web (no `dart:io`)
- [ ] `flutter-reviewer` has no must-fix items. `security-auditor` run if auth, storage, network, logging or build config changed
- [ ] Screenshots attached: mobile, web, Arabic (UI changes)
- [ ] PR description uses the template, ticket linked
- [ ] No secrets, no `print`, no TODO without a ticket number

## Step by step: a feature
```text
1  Ticket reaches G0 (PO + DES + BE).
2  git switch -c feature/<kebab-name>
3  /design-handoff <figma-link-or-screenshots>     component map, tokens, missing states → questions to DES
4  /api-contract-check <swagger-or-sample>         contract gaps → questions to BE
5  /feature-spec <feature>                         writes docs/specs/<feature>.md
6  git commit -m "docs(<feature>): add spec" && git push -u origin HEAD     opens a DRAFT PR
   → G1: LEAD, PO, BE, DES approve the spec in the PR. Set Status: approved, commit.
7  /new-feature <feature>, then /new-endpoint, /new-screen, /add-translation, /add-tests
   Commit per logical change (Conventional Commits).
8  /pre-pr-check                                   fix everything red
9  "run flutter-reviewer", "run design-reviewer", "run security-auditor" (when relevant)
10 /pr-description                                 mark the PR ready, attach screenshots
   → G4: LEAD reviews, DES signs off the UI, PO accepts on a dev build.
11 Merge (G5). QA tests the stage build, PO runs UAT, BE smoke-tests (G6).
12 /release (G7), cut from a release branch.
```

## Bug fix
1. Ticket has steps to reproduce, expected vs actual, app version, flavor, device/OS, and logs (no PII). Reproduce first.
2. `git switch -c bugfix/<name>`, then `/fix-bug <ticket>`. It writes a failing test first, fixes the cause, and notes the root cause.
3. Gates G3 to G6 apply. G1 is replaced by LEAD agreeing the root cause in the ticket. Bugs caused by an API change go to BE first (see [INTEGRATION.md](INTEGRATION.md#backend-changes-after-release)).

## Hotfix (production incident)
1. LEAD declares the hotfix in the ticket. `git switch -c hotfix/<name>` from the latest release tag.
2. `/fix-bug` with the smallest possible change, plus the regression test.
3. `/pre-pr-check`, `flutter-reviewer` and `security-auditor` still run. Skipping is not allowed, only the waiting is shortened.
4. LEAD approves, QA smoke-tests the exact build, then `/release patch prod`. Merge the fix back to the base branch the same day.

## Release (G7)
1. `git switch -c release/<x.y.z>` from the base branch. Only fixes land on it.
2. QA regression on the `stage` flavor, PO UAT sign-off, BE confirms prod API is deployed and compatible.
3. `security-auditor` agent over the whole release diff. Fix all high and critical items.
4. `/release <bump> prod`: version, changelog, tag, obfuscated builds, Sentry symbols archived.
5. LEAD go/no-go, store submission, phased rollout, watch Sentry for 24 hours.

## Branches and merging
- Names: `feature/`, `bugfix/`, `hotfix/`, `release/`, `chore/`. Enforced by `.githooks/pre-push`.
- Base branch: `main`. Direct pushes to `master`, `main` and `develop` are blocked by the hook, so every change goes through a PR.
- At least one LEAD approval. The PR author never merges their own PR without a second reviewer. `.github/CODEOWNERS` requests reviewers automatically.
- Keep branches under about 3 working days or 400 changed lines. Split larger work into spec-agreed slices.

## When the plan changes
Scope, design, or API changes after G1 go back through G1: update the spec, note the change in the PR, get the same approvers to re-approve. Never silently implement a different contract.
