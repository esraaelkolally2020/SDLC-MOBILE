# REVIEW.md: review policy

Read by the review agents and by human reviewers. The agent never approves its own code: a human approves every PR (CODEOWNERS).

## Passes
| Pass | Who | Looks for |
|---|---|---|
| Correctness | `flutter-reviewer` agent | Bugs, architecture and state-management rule breaks, missing tests, hard-coded strings, `dart:io` outside `*_io.dart` |
| UI | `design-reviewer` agent | Deviation from the Figma handoff, missing loading/empty/error states, RTL |
| Security | `security-auditor` agent | Run when auth, storage, network, logging or build config changed. Secrets, token storage, logging of PII, pinning |
| Human | Lead (+ designer for UI, PO for scope) | Intent matches the approved spec; the findings below are resolved |

## Severity
- **Must fix**: blocks merge (bug, security, rule break, spec mismatch).
- **Should fix**: fix now or open a ticket.
- **Nit**: never blocks.

## Feedback loop
If the same finding appears a second time, add or tighten a line in `CLAUDE.md` or the matching `.claude/rules/*.md` in the same PR, so Claude stops making it.
