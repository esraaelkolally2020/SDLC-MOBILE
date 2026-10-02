# AI-native SDLC playbook: what to do at each stage

Maps the [Claude AI-native SDLC playbook](https://claude.com/blog/the-ai-native-sdlc-playbook) onto this template. Each stage commits one file that the next stage reads. Humans approve the files; hooks and skills enforce policy as code.

```
intent.md → spec.md → plan.md → PR (diff) → release → incident intent.md
```

| # | Stage | Do | File produced | Claude tool | Approver |
|---|---|---|---|---|---|
| 1 | Plan | Write the idea as an intent | `docs/intent/<name>.md` | copy `docs/intent/_template.md` | Product owner |
| 2 | Design | Turn the intent into a spec with API, design, states, translations | `docs/specs/<feature>.md` | `/api-contract-check`, `/design-handoff`, `/feature-spec` | PO + lead + backend + designer (G1) |
| 3 | Build | Plan in plan mode, then implement | `docs/plans/<feature>.md`, code, tests | plan mode, `/new-feature`, `/new-endpoint`, `/new-screen`, `/add-tests`, `/fix-bug` | Lead skims the plan if high-risk |
| 4 | Test | Claude verifies its own work before humans look | passing checklist | `/pre-pr-check`, CI | CI green |
| 5 | Deploy | Review passes, PR, release | PR, `CHANGELOG.md`, tag | review agents, `/pr-description`, `/release` | Lead + code owners (human only) |
| 6 | Maintain | Watch crashes and reviews, turn findings into new intents | `docs/intent/<incident>.md` | `/fix-bug`, Sentry, store reviews | Service owner triages, fix goes through stage 5 |

Gate numbers (G0 to G7) and role checklists are in [WORKFLOW.md](WORKFLOW.md).

## Where each kind of file lives
| Kind | Location | Purpose | Change it when |
|---|---|---|---|
| Knowledge | `CLAUDE.md` (one page), `docs/` | Shared facts Claude loads every session | A convention is wrong or missing |
| Rules | `.claude/rules/*.md` | Conventions loaded when Claude touches matching paths | Claude gets something wrong twice |
| Skills | `.claude/skills/<name>/SKILL.md` | Repeatable procedures run with `/name` | A procedure changes or a new one repeats |
| Agents | `.claude/agents/*.md` | Reusable reviewer subagents | Review scope changes |
| Hooks | `.claude/hooks/`, `.claude/settings.json`, `.githooks/` | Policy enforced as code: block secrets, commit format, pre-push checks | A guard is missing. Never bypass |
| Memory | Per-developer, outside the repo; findings promoted to `CLAUDE.md` or rules | Personal preferences stay local. Anything the team needs goes into the repo | A review finding appears twice |
| Approvals | `docs/WORKFLOW.md`, `.changerequest/` (PR template, CODEOWNERS, CI), `REVIEW.md` | Who signs off at each gate | Roles or risk tiers change |

## Maintain (stage 6) tiers
Respond by severity. Claude may diagnose; it only proposes a fix, never ships one.
| Signal | Response |
|---|---|
| Small blip (crash rate slightly up) | Log only |
| Sustained breach (crash-free sessions below target, error spike in Sentry) | Ask Claude to diagnose read-only and write `docs/intent/<incident>.md` |
| Severe (login or payments broken) | Hotfix branch, `/fix-bug`, normal PR review, `/release` |
Add each fixed incident as a regression test (`/add-tests`).

## Source of truth
Markdown in the repo is authoritative (`docs/intent`, `docs/specs`, `docs/plans`). If you also use a ticket tracker, put the ticket id in the intent/spec header, in the branch or PR title, and link the PR in the ticket. Never keep two versions of the same decision.

## Measure (check monthly, no tooling needed)
| Stage | Leading | Lagging |
|---|---|---|
| Plan | Hours from first conversation to a committed intent | Intents accepted into design |
| Design | Hours from intent to approved spec | Specs edited after the plan was written (rework) |
| Build | PRs merged from the first implementation pass | Review cycles per PR |
| Test | First-pass CI success rate | Defects found in QA or production per release |
| Deploy | Hours to first review | Share of review findings that repeat (should fall as rules improve) |
| Maintain | Hours from crash spike to incident intent | Repeat incidents of the same kind |

## Changing the setup safely
`CLAUDE.md`, rules, skills, agents and hooks are code. A change goes through a PR like any other. After changing one, run a small known task (for example `/new-feature` for a throwaway feature on a scratch branch) and confirm `flutter analyze` and `flutter test` are clean and the output follows the rules. Add every fixed incident as a regression test (`/add-tests`).

## Optional for larger organizations (not set up here)
- A CI job that runs Claude Code review on each PR using `REVIEW.md` (the playbook's `claude-code-action`), with the human code-owner approval still required.
- Organization-managed Claude Code settings: forced deny rules, sandboxing, only approved hooks and skills.
- A hook that blocks a production release unless an approval variable is set; a deterministic crash-rate check that opens an intent when a threshold is crossed.
- Several Claude sessions in parallel git worktrees on independent tasks.
