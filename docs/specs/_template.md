# <Feature title>
Status: draft | approved · Owner: <dev> · Ticket: <id>
Contract status: confirmed | draft | mocked

## Approvals (G1)
| Role | Name | Date | Notes |
|---|---|---|---|
| Mobile lead | | | |
| Product owner | | | |
| Backend | | | |
| Designer | | | |

## Goal
One paragraph: who uses it and what they can do. Link the business ticket.

## API
| Method | Endpoint const | Path | Request model | Response (inside ApiResponse) |
|---|---|---|---|---|

Sample response JSON (trimmed). Error codes and the message shown for each.
Pagination, auth, and nullability notes.

## Models
- `<Name>RequestModel` fields → `toMap()` keys
- `<Name>Model` fields ← `fromMap()` keys (note casing variants)

## Design
Figma link · Screens covered · States covered (default, loading, empty, error) · Arabic/RTL · Web/desktop.
| Design element | Component | Token or note |
|---|---|---|

## Screens
| Screen | Route const | Path | Bodies (mobile/web/desktop) | Entry point |
|---|---|---|---|---|

## States
Cubit `<Feature>Cubit` methods, and which BaseState each emits (Loading → Loaded/Empty/Error).

## Translations
| key | en-US | ar-SA |
|---|---|---|

## Reuse
Existing components or services used.

## Acceptance criteria
- [ ] Given … when … then …
- [ ] Works on web (no dart:io)
- [ ] RTL checked in Arabic

## Test plan
Unit tests (cubit methods, models) · Manual cases for QA.

## Open questions
| Question | Asked to | Answer |
|---|---|---|

## Out of scope
