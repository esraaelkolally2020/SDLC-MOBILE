---
name: design-handoff
description: PLAN stage (design integration). Turns a Figma link, exported screens or screenshots into a component map, token decisions, asset list, missing-state questions and accessibility flags for the spec. Use when a designer hands over screens, or before building UI.
argument-hint: <figma link | screenshot paths | description of screens>
---

# Design handoff

Translate a design into this codebase's building blocks and find gaps **before** UI code is written. This skill does not edit code.

## Steps
1. Read the design input (screenshots can be read as images; a Figma link may need the user to paste details or export frames). If a state or breakpoint is not visible, treat it as missing, don't assume.
2. Read `.claude/rules/ui-components.md`, `lib/core/component/`, `lib/core/data/constants/app_colors.dart`, `lib/core/services/theme/app_theme.dart` and `lib/core/data/assets_helper/`.
3. For every screen, produce:
   - **Component map**: design element → existing widget (`PButton`, `PText`, `PTextField`, `PImage`, `CustomAppBar`, ...) or `NEW` with a one-line reason
   - **Tokens**: colors → `colorScheme`/`AppColors`; text styles → `textTheme`; spacing → `AppDimensions`/sizer. Anything with no match is a question for the designer, not a hard-coded value
   - **Assets**: icons and images needed, preferred format SVG, target folder, existing duplicates
   - **States**: default, loading, empty, error, disabled, success, pagination, pull to refresh. Mark each as shown or missing
   - **Responsive**: mobile, web, desktop bodies. Say if web/desktop are only the mobile body reused
   - **RTL and Arabic**: mirrored icons, text length growth, number formatting
   - **Accessibility**: contrast, tap targets of at least 48dp, text scaling, semantics labels for icon-only buttons
4. Output:

```markdown
## Design summary
Screens: … · Figma: <link>

## Component map
| Screen | Element | Component | Token / note |

## New components or tokens needed (need DES + lead approval)
- …

## Assets
| Asset | Format | Path |

## Missing states or breakpoints → questions for the designer
1. …

## Accessibility flags
- …
```

5. Next step: paste the summary into the spec's **Design** section via `/feature-spec`. Keep new tokens or components out of code until the designer and mobile lead approve.
