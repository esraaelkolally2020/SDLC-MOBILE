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
4. Write `docs/specs/<feature_name>.md` with this template:

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

5. Show the user the spec path and a 3-line summary, plus any open questions. Implementation starts only after the user approves; next step is `/new-feature <feature_name>`.
