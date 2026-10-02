# Workflow diagrams

Visual version of [WORKFLOW.md](WORKFLOW.md). The diagrams are Mermaid, so GitHub and VS Code (Markdown preview with a Mermaid extension) render them. Role short names: **PO** product owner, **DES** designer, **BE** backend, **LEAD** mobile lead, **DEV** mobile developer, **QA**.

## 1. End to end: one work item from idea to store

```mermaid
flowchart TD
    A["Idea / ticket<br/>/new-intent → docs/intent/name.md<br/>(PO approves)"] --> G0
    G0{{"G0 READY<br/>PO + DES + BE approve<br/>Definition of Ready"}}
    G0 -->|"missing criteria, design or contract"| A
    G0 --> P1["/api-contract-check<br/>questions for BE"]
    G0 --> P2["/design-handoff<br/>questions for DES"]
    P1 --> S["/feature-spec<br/>docs/specs/feature.md<br/>(from docs/specs/_template.md)"]
    P2 --> S
    S --> G1{{"G1 SPEC APPROVED<br/>LEAD + PO + BE + DES<br/>draft PR, Status: approved"}}
    G1 -->|"changes requested"| S
    G1 --> B["BUILD (DEV)<br/>/new-feature  /new-endpoint  /new-screen<br/>/add-translation  /web-safe-platform  /add-tests"]
    B --> G2{{"G2 BUILT<br/>code + tests in standard layout"}}
    G2 --> V["/pre-pr-check<br/>+ CI (.github/workflows/ci.yml)"]
    V --> G3{{"G3 VERIFIED<br/>all checks green"}}
    G3 -->|"red"| B
    G3 --> R["REVIEW<br/>flutter-reviewer · design-reviewer<br/>security-auditor (when relevant)<br/>/pr-description"]
    R --> G4{{"G4 REVIEWED<br/>LEAD review + DES sign-off<br/>+ PO accepts on dev build"}}
    G4 -->|"must-fix findings"| B
    G4 --> G5["G5 MERGE to main<br/>LEAD approves (CODEOWNERS)"]
    G5 --> G6{{"G6 ACCEPTED<br/>QA on stage build<br/>PO runs UAT<br/>BE smoke test"}}
    G6 -->|"defect"| BUG["bugfix/ branch<br/>/fix-bug"]
    BUG --> V
    G6 --> REL["release/x.y.z<br/>security-auditor on full diff"]
    REL --> G7{{"G7 RELEASED<br/>LEAD go/no-go + PO<br/>/release: version, changelog, tag,<br/>obfuscated build, Sentry symbols"}}
    G7 --> STORE["Store rollout<br/>watch Sentry 24h"]
```

## 2. Who does what, and when (swimlanes)

```mermaid
sequenceDiagram
    autonumber
    participant PO as Product owner
    participant DES as Designer
    participant BE as Backend
    participant DEV as Mobile dev (+ Claude)
    participant LEAD as Mobile lead
    participant QA as QA
    participant CI as CI + git hooks

    PO->>DEV: Ticket with acceptance criteria
    DES->>DEV: Figma (all states, Arabic, web)
    BE->>DEV: Swagger / sample JSON, dev URL
    Note over PO,BE: G0 Ready
    DEV->>BE: /api-contract-check questions
    DEV->>DES: /design-handoff questions
    BE-->>DEV: Answers (contract confirmed or mocked)
    DES-->>DEV: Answers (tokens, missing states)
    DEV->>LEAD: Draft PR with docs/specs/feature.md
    LEAD->>PO: Spec review
    PO-->>LEAD: Approve
    BE-->>LEAD: Approve API section
    DES-->>LEAD: Approve screens
    Note over DEV,LEAD: G1 Spec approved (Status: approved)
    DEV->>DEV: Build + tests (skills)
    DEV->>CI: commit (pre-commit, commit-msg), push (pre-push)
    CI-->>DEV: Format, analyze, test, web-safety, translations
    Note over DEV,CI: G2 + G3
    DEV->>LEAD: PR ready (/pr-description, screenshots)
    DEV->>DEV: flutter-reviewer, design-reviewer, security-auditor
    DES->>DEV: UI sign-off on dev build
    PO->>DEV: Acceptance on dev build
    LEAD->>DEV: Approve (CODEOWNERS)
    Note over DEV,LEAD: G4 Reviewed, G5 Merged
    DEV->>QA: Stage build + test notes from the PR
    QA-->>LEAD: Test report
    PO-->>LEAD: UAT sign-off
    BE-->>LEAD: Smoke test OK
    Note over QA,BE: G6 Accepted
    LEAD->>DEV: /release patch|minor|major prod
    Note over LEAD,PO: G7 Released
```

## 3. Bug fix and hotfix paths

```mermaid
flowchart LR
    T["Bug ticket<br/>(.github/ISSUE_TEMPLATE/bug_report.md)"] --> C{"Cause in<br/>the app?"}
    C -->|"no: API or design issue"| X["Raise to BE or DES<br/>see docs/INTEGRATION.md"]
    C -->|"yes"| SEV{"Production<br/>incident?"}
    SEV -->|"no"| BF["git switch -c bugfix/name<br/>from main"]
    SEV -->|"yes"| HF["git switch -c hotfix/name<br/>from last release tag"]
    BF --> F["/fix-bug<br/>failing test → root-cause fix"]
    HF --> F
    F --> V["/pre-pr-check + CI"]
    V --> RV["flutter-reviewer<br/>+ security-auditor (always for hotfix)"]
    RV --> L["LEAD approves"]
    L --> Q["QA smoke test on exact build"]
    Q --> SH{"Hotfix?"}
    SH -->|"no"| M["Merge to main,<br/>ships in next release"]
    SH -->|"yes"| REL["/release patch prod<br/>then merge back to main same day"]
```

## 4. What runs automatically (guards)

```mermaid
flowchart LR
    subgraph Claude["While Claude works"]
        H1[".claude/settings.json<br/>permissions allow / deny"]
        H2[".claude/hooks/block_secrets.sh<br/>blocks env, keystores, certs"]
        H3[".claude/rules/*.md<br/>loaded by file path"]
    end
    subgraph Local["On your machine (git hooks)"]
        G1c[".githooks/pre-commit<br/>no secret files or values"]
        G2c[".githooks/commit-msg<br/>Conventional Commits"]
        G3c[".githooks/pre-push<br/>branch name, no push to main,<br/>format, analyze, test"]
    end
    subgraph Remote["On GitHub"]
        R1[".github/workflows/ci.yml<br/>format, analyze, test,<br/>web-safety, translation parity"]
        R2[".github/CODEOWNERS<br/>auto-request review"]
        R3["Branch protection<br/>PR + approval + green CI"]
    end
    Claude --> Local --> Remote
```

## 5. Stage reference: what each stage is, and which files it uses

| Stage | Gate | Purpose | Tools and files involved | Output |
|---|---|---|---|---|
| Intake | G0 | Make sure the work is defined before anyone codes. Missing business criteria, design or API contract go back to their owner | `.github/ISSUE_TEMPLATE/feature_request.md`, `docs/WORKFLOW.md` (Definition of Ready) | A ticket that passes the Ready checklist |
| Backend check | G0 to G1 | Find contract gaps early: envelope fit, errors, pagination, nullability | `/api-contract-check` (`.claude/skills/api-contract-check/SKILL.md`), `.claude/rules/networking.md`, `docs/INTEGRATION.md` | Questions for BE, contract status |
| Design check | G0 to G1 | Map the design to existing components and tokens, find missing states | `/design-handoff` (`.claude/skills/design-handoff/SKILL.md`), `.claude/rules/ui-components.md`, `lib/core/component/` | Component map, questions for DES |
| Spec | G1 | One agreed document of endpoints, models, screens, states, translations and acceptance criteria | `/feature-spec` (`.claude/skills/feature-spec/SKILL.md`), `docs/specs/_template.md`, `docs/specs/<feature>.md` | Approved spec in a draft PR |
| Build | G2 | Implement in the standard layout with tests | `/new-feature`, `/new-endpoint`, `/new-screen`, `/add-translation`, `/web-safe-platform`, `/add-tests` (`.claude/skills/*`), rules `architecture`, `state-management`, `networking`, `ui-components`, `localization`, `platform-web`, `testing`, reference `lib/features/example/` | Code and tests wired into `lib/di.dart` and the router |
| Verify | G3 | Same checks locally and in CI | `/pre-pr-check`, `.githooks/*`, `.github/workflows/ci.yml` | Pass/fail checklist |
| Review | G4 | Independent review of rules, UI fidelity and security | `.claude/agents/flutter-reviewer.md`, `design-reviewer.md`, `security-auditor.md`, `/pr-description`, `.github/pull_request_template.md`, `.github/CODEOWNERS` | Findings by severity, PR ready for approval |
| Merge | G5 | Land the change on `main` through a PR | Branch protection, `.claude/rules/git-workflow.md` | Merged PR |
| Acceptance | G6 | QA tests the stage build, PO runs UAT, BE smoke-tests | The PR's "How to test" section, the spec's test plan | Test report, UAT sign-off |
| Release | G7 | Version, changelog, tag, obfuscated builds, symbols | `/release` (`.claude/skills/release/SKILL.md`), `CHANGELOG.md`, `pubspec.yaml`, `.claude/rules/security.md` | Tagged release in the stores |
| Bug / hotfix | G3 to G6 | Reproduce with a test, fix the root cause, smallest change | `/fix-bug` (`.claude/skills/fix-bug/SKILL.md`), `.github/ISSUE_TEMPLATE/bug_report.md` | Fix with a regression test |

For a description of every individual file, see the README in each folder, starting with the root [README.md](../README.md) and [.claude/README.md](../.claude/README.md).
