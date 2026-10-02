# docs/: project documentation

Read in this order if you are new.

| File | What it explains | Read it when |
|---|---|---|
| `PROJECT_MAP.md` | Every file and folder in the repository and what it is for | You are looking for a file |
| `PLAYBOOK.md` | The six playbook stages mapped to files, skills, hooks, memory and approvers | You want the one-page overview |
| `WORKFLOW.md` | Roles, approval gates G0 to G7, Definition of Ready and Done, and the feature, bug, hotfix and release paths | You start any work item. The lead's checklist |
| `WORKFLOW_DIAGRAM.md` | The same process as diagrams (end to end, swimlanes, bug and hotfix, automatic guards) with a stage-by-stage file reference | You want the picture, or are onboarding someone |
| `INTEGRATION.md` | How backend (contract), design (handoff) and business (acceptance) feed the gates | You depend on another team |
| `SDLC.md` | How Claude Code supports each stage: skills, agents, hooks, permissions | You use Claude Code |
| `ARCHITECTURE.md` | Layers, startup, DI, routing, network layer, state, flavors, web support, localization | You write or review code |
| `ADD_ONS.md` | Optional modules left out of the template: Firebase, maps, device security, in-app update, inspector, code generation | A project needs one of them |
| `specs/_template.md` | Spec template with approvals, contract status, design, screens, states, translations, acceptance and test plan | You start a feature (copied by `/feature-spec`) |
| `specs/<feature>.md` | One approved spec per feature, written before code | Always, as the source of truth for the feature |
| `intent/_template.md` | Stage 1 intent: problem, outcome, constraints, PO approval | You have a new idea or incident |
| `plans/_template.md` | Stage 3 plan written in plan mode before code | You start building |
