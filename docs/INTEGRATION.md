# Integration with backend, design and business

Three tracks feed the gates in [WORKFLOW.md](WORKFLOW.md). Each track has an input the mobile team requires, a check we run, and a sign-off.

## Backend track (contract first)
**Input (G0):** Swagger/OpenAPI or Postman collection, plus a sample JSON for success and each error case. Base URLs for `dev` and `stage` (added to `api_end_points.env`, never committed).

**What the mobile team checks, with `/api-contract-check`:**
- Every endpoint has method, path, auth requirement, request fields (required/optional, types) and response envelope
- Response matches `ApiResponse` (`data`, `status`, `code`, `message`, `englishMessage`/`arabicMessage`, `totalCount`). Deviations are listed
- Error codes and what the app should show for each (401, 403, 404, 422 validation, 5xx)
- Pagination style (page/size or cursor), sorting, filters
- Nullability and key casing (`Id` vs `id`), date formats and time zones, enums as ints or strings, money and decimal precision
- File upload and download details, size limits
- Versioning and deprecation plan

**Output:** open questions sent to BE in the ticket. Answers are recorded in the spec's API section. The spec's `Contract status` is one of `confirmed` (BE signed off), `draft` (still moving) or `mocked` (building against a fake).

**If the API isn't ready:** build against a fake repository that implements the abstract `<Feature>Repository` (the pattern in `test/features/example/`). Do not invent fields. Mark the spec `mocked`, list the assumptions, and replace the fake when BE delivers. G6 cannot pass while a spec is `mocked`.

**Environments:** `dev` for building, `stage` for QA/UAT, `prod` only for release smoke. BE must keep `stage` data stable during UAT.

**Sign-off:** BE approves the API section of the spec (G1) and does a smoke test of the stage build (G6).

### Backend changes after release
Breaking changes must be announced to the mobile lead with the app versions affected. Rules:
- Additive changes (new optional field) need no release.
- Breaking changes need a versioned endpoint or a minimum supported app version, agreed before BE deploys.
- Old app versions keep working until the agreed sunset date. Use the in-app update add-on ([ADD_ONS.md](ADD_ONS.md)) when forcing an upgrade.

## Design track (design to code)
**Input (G0):** Figma link (or exported screens) with default, loading, empty, error, disabled and success states, plus Arabic/RTL and web/desktop layouts when those are in scope. Colors and text styles from the design system.

**What the mobile team does, with `/design-handoff`:**
- Maps each design element to an existing `lib/core/component/` widget, or lists what is missing
- Maps colors and text styles to `AppColors`, `colorScheme` and `textTheme`. New tokens go through DES and the lead, not hard-coded
- Lists missing states or breakpoints as questions to DES
- Lists assets needed (SVG preferred, into `assets/images/svg/`, constants in `assets_helper`)
- Flags accessibility problems (contrast, tap targets of at least 48dp, text scaling)

**Output:** a design section in the spec: screen list, component map, token decisions, open questions.

**Review:** the `design-reviewer` agent checks the branch against the spec and design notes. DES then checks a dev build (or screenshots for mobile, web and Arabic) before G4. Design changes after G1 go through the change loop in [WORKFLOW.md](WORKFLOW.md#when-the-plan-changes).

## Business track (scope and acceptance)
**Input (G0):** goal, user story, acceptance criteria, priority, release target, and any rules (limits, permissions, roles). Analytics events if required.

**Mobile team does:**
- Turns the criteria into the spec's acceptance checklist and into test cases (`/add-tests`)
- Raises ambiguity as questions in the ticket, one batch
- Lists what is out of scope in the spec so PO can confirm

**Sign-off:**
- PO approves the spec (G1)
- PO accepts the feature on a `dev` build before merge (G4)
- PO runs UAT on the `stage` build (G6) and approves the release (G7)

## Who to ask
| Question | Ask |
|---|---|
| What should happen when ... | PO |
| What does the screen look like when ... | DES |
| What does the API return when ... | BE |
| Where does this code go, is this the right pattern | LEAD, then `docs/ARCHITECTURE.md` |
| Is this ready to ship | QA for quality, PO for scope, LEAD for go/no-go |

## Communication rules
- Questions and decisions live in the ticket or PR, not only in chat. Link the decision in the spec.
- A decision that changes scope, contract or design restarts G1 for that part.
- Demo on a `dev` build before asking for G4 sign-off from DES and PO. Surprises at UAT are a process failure, not a QA failure.
