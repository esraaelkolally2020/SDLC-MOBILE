---
name: feature-spec
description: PLAN stage. Turns a feature request, ticket or API contract into a spec at docs/specs/<feature>.md (endpoints, models, screens, states, translations, acceptance criteria) before any code is written. Use when starting a new feature or a large change.
argument-hint: <feature_name> [ticket text or API notes]
---

# Feature spec

Write a short, concrete spec that `/new-feature` can implement without guessing.

## Steps
1. Collect inputs: the user's description, any pasted ticket, Swagger or JSON samples, and designs. If endpoint paths, request/response shapes or the screen list are missing, **ask** (one batch of questions). Don't invent API fields.
2. Read `lib/features/example/` and `.claude/rules/architecture.md` so the spec uses the real folder and class names.
3. Check `lib/core/component/` and other features for anything reusable, and list it.
3b. If the user has a Swagger/sample or design, run `/api-contract-check` and `/design-handoff` first and use their output for the API and Design sections.
4. Copy `docs/specs/_template.md` to `docs/specs/<feature_name>.md` and fill it (it adds Approvals, Contract status, Design, Test plan and Open questions to the outline below). Keep `Status: draft` until the approvers in `docs/WORKFLOW.md` (G1) sign off. The outline:

```markdown
# <Feature title>
Status: draft · Owner: <name> · Ticket: <id>

## Goal
One paragraph: who uses it and what they can do.

## API
| Method | Endpoint const | Path | Request model | Response (inside ApiResponse) |
|---|---|---|---|---|

Sample response JSON (trimmed).

## Models
- `<Name>RequestModel` fields → `toMap()` keys
- `<Name>Model` fields ← `fromMap()` keys (note casing variants)

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

## Out of scope
```

5. Show the user the spec path and a 3-line summary, plus any open questions. Implementation starts only after the spec is approved (Status: approved, G1 in `docs/WORKFLOW.md`: lead, PO, backend, designer). Suggest committing it as `docs(<feature>): add spec` and opening a draft PR for the approvals. Next step is `/new-feature <feature_name>`.
