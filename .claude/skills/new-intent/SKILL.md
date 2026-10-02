---
name: new-intent
description: PLAN stage 1. Turns a conversation about an idea, problem or incident into docs/intent/<name>.md from the template, with open questions, ready for product owner approval. Use when someone has a new idea, change request or production incident and no intent file exists yet.
argument-hint: <short idea or incident description>
---

# New intent

An intent is a conversation starter, not a specification. Keep it short and honest about what is unknown.

## Steps
1. Ask one batch of questions only for what is missing: who has the problem, what outcome is wanted, which platforms (Android, iOS, web), deadline, and which teams or systems are affected. Do not invent details.
2. Copy `docs/intent/_template.md` to `docs/intent/<kebab-name>.md` and fill every section. Put anything unknown under **Constraints** as "open question: ...". Set `Status: draft`, the originator's name, and today's date.
3. For an incident, include the evidence (Sentry issue, store review, steps to reproduce) and no personal data or tokens.
4. Show the file path and a 3-line summary. Say who must approve (product owner) and that the next step is `/api-contract-check` and `/design-handoff`, then `/feature-spec`.
5. Do not start a spec or any code. Commit only when the user asks: `docs(intent): add <name>`.
