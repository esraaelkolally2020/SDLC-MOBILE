---
name: api-contract-check
description: PLAN stage (backend integration). Reviews a Swagger/OpenAPI file, Postman export, or sample JSON against this app's network layer and lists contract gaps and questions for the backend team before the spec is written. Use at the start of a feature or when the backend changes an API.
argument-hint: <swagger path | pasted JSON | endpoint notes>
---

# API contract check

Find what is missing or risky in an API contract **before** code is written. This skill does not edit code.

## Steps
1. Read the input. Never open `*.env` files. If only a URL is given, ask the user to paste the contract.
2. Read `.claude/rules/networking.md` and `lib/core/services/network/response/api_response.dart`, so the checks use the real envelope.
3. For each endpoint, check and record:
   - Method, path, auth required, content type
   - Request fields: required or optional, type, limits; query vs body
   - Response matches `ApiResponse` (`data`, `status`, `code`, `message`, `englishMessage`/`arabicMessage`, `totalCount`). List any deviation
   - Error cases: 400/422 validation shape, 401, 403, 404, 409, 5xx, and the message to show
   - Pagination style, sorting, filters
   - Nullable fields, key casing variants, date and time zone format, enum encoding, money precision
   - Files: upload field names, size and type limits
   - Idempotency and retry safety for writes
4. Compare with existing code: `ApiEndpointsConstants` and `lib/features/*/data/model/` for duplicates or conflicts.
5. Output:

```markdown
## Contract summary
| Endpoint | Method | Auth | Fits ApiResponse | Gaps |

## Questions for backend (send as one batch)
1. …

## Assumptions we will make if unanswered (need BE confirmation)
- …

## Suggested Contract status for the spec
confirmed | draft | mocked, with the reason
```

6. Never invent fields. If the contract is incomplete, say `mocked` and list what the fake repository will assume.
7. Next step: answers go into `docs/specs/<feature>.md` via `/feature-spec`.
