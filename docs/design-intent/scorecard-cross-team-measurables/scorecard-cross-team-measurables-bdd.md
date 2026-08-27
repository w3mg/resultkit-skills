# Team scorecard — measurables added from other teams, and including higher-level measurables

## Update log
| Date | Update description | Issue that led to update |
|---|---|---|
| 2026-08-27 | Initial spec: scorecard views include measurables added from other teams; affordance to include a measurable defined at a higher level | (issue to follow) |

## Problem

In the current product a team's scorecard can carry measurables that belong to other teams: the legacy scorecard's **"Re-use Existing"** action adds another team's measurable to this team's board, and customers use it — for example a root team's scorecard showing rows added from its child teams. Observed today:

- The scorecard surfaces in the new app (Data tab, Level 10 Scorecard section, and the other surfaces listed below) show only the team's own measurables — the added rows do not appear, so the same team's scorecard shows different lists in the legacy app and the new app.
- ResultKit's `/rkit:scorecard` view likewise shows only the team's own measurables and ignores the added ones.
- Neither the new app nor ResultKit offers any way to include a measurable defined at a higher level (a parent or ancestor team) on this team's scorecard.

Who it affects: any team that runs its weekly review off a scorecard with added measurables — the numbers they added are silently missing from the new surfaces, and there is no way to put them back.

## Screens covered

Swept from the screen-and-context-inventory (BDD-spec-skill). This behavior applies on:

- Team · 2.1.3 Data (scorecard)
- Team · 2.2.1 Level 10 Meeting — Agenda tab, Scorecard section
- Team · 2.7 Quarterly Business Review — Measurables slide
- Home — Scorecard card (`components/home/scorecard-card.tsx`) — **not in the screen inventory**; listed here by its component name rather than skipped
- AI chat — scorecard measurables card (`components/ai/tool-results/get-scorecard-measurables-card.tsx`) — **not in the screen inventory**; listed here by its component name rather than skipped
- ResultKit CLI — the `/rkit:scorecard` view (the target repo's surface; the web screen inventory does not cover CLI surfaces)

Excluded: 2.2.2 1-on-1 — Measures section (its list is the measures aligned to that 1-on-1, not the team scorecard). Measure edit sheet (edits one measurable; which measurables make up the scorecard is not decided there).

## Desired behavior

The team's scorecard is one list everywhere it renders: the team's own measurables plus every measurable added from another team. A measurable defined at a higher level can be included from the scorecard, and an included measurable is the same measurable — same weekly values on every board that shows it.

### Scenario: added measurable shows on Data (scorecard) — 2.1.3
- **Given** Eileen Sharp (Integrator), signed in as team admin of the Examp.ly root team, whose scorecard includes "Defects to clients" (goal 0, Sue Baylor's measurable defined on Examply Service Delivery), added from that team
- **And** on Data (scorecard) (2.1.3), viewing the Examp.ly root team
- **When** the scorecard loads
- **Then** "Defects to clients" appears in the list with its weekly values, alongside the team's own measurables — the same list the legacy scorecard shows for this team

### Scenario: added measurable shows in the Level 10 Scorecard section — 2.2.1
- **Given** Eileen Sharp (Integrator), signed in as team admin of the Examp.ly root team, whose scorecard includes "Defects to clients" added from Examply Service Delivery
- **And** on Level 10 Meeting (2.2.1), Agenda tab, Scorecard section, for the Examp.ly root team
- **When** the Scorecard section loads
- **Then** "Defects to clients" appears with its weekly values alongside the team's own measurables

### Scenario: added measurable shows on the Quarterly Business Review Measurables slide — 2.7
- **Given** Eileen Sharp (Integrator), signed in as team admin of the Examp.ly root team, whose scorecard includes "Defects to clients" added from Examply Service Delivery
- **And** on Quarterly Business Review (2.7) for the Examp.ly root team, on the Measurables slide
- **When** the slide loads
- **Then** "Defects to clients" appears among the team's measurables

### Scenario: added measurable shows on the Home Scorecard card
- **Given** Eileen Sharp (Integrator), signed in with the Examp.ly root team as her current team, whose scorecard includes "Defects to clients" added from Examply Service Delivery
- **And** on Home, where the Scorecard card renders
- **When** the card loads
- **Then** the card's measures include "Defects to clients" — its summary and counts reflect the full list, not only the team's own measurables

### Scenario: added measurable shows in the AI chat scorecard measurables card
- **Given** Eileen Sharp (Integrator), signed in with the Examp.ly root team as her current team, whose scorecard includes "Defects to clients" added from Examply Service Delivery
- **When** she asks the chat for the team's scorecard and the scorecard measurables card renders
- **Then** the card lists "Defects to clients" alongside the team's own measurables

### Scenario: ResultKit CLI shows the added measurable
- **Given** Eileen Sharp (Integrator), authenticated in ResultKit with the Examp.ly root team as her active team, whose scorecard includes "Defects to clients" added from Examply Service Delivery
- **When** she views the team scorecard with `/rkit:scorecard`
- **Then** the scorecard table includes "Defects to clients" with its recent weekly values — the same list Data (scorecard) shows for this team

### Scenario: include a measurable defined at a higher level — confirm by click — 2.1.3
- **Given** Eileen Sharp (Integrator), signed in as team admin of Examply Sales
- **And** "Gross monthly revenue" (goal 500000) is a measurable defined on the Examp.ly root team
- **And** on Data (scorecard) (2.1.3), viewing Examply Sales
- **When** she uses the scorecard's add affordance, picks "Gross monthly revenue" from the Examp.ly root team, and clicks the confirm control
- **Then** the "Gross monthly revenue" row paints on Examply Sales' scorecard immediately, before the server confirms, and the save completes in the background

### Scenario: include a measurable defined at a higher level — confirm by Enter — 2.1.3
- **Given** Eileen Sharp (Integrator), signed in as team admin of Examply Sales
- **And** "Gross monthly revenue" (goal 500000) is a measurable defined on the Examp.ly root team
- **And** on Data (scorecard) (2.1.3), viewing Examply Sales, with "Gross monthly revenue" picked in the add affordance
- **When** she presses Enter to confirm
- **Then** the "Gross monthly revenue" row paints on Examply Sales' scorecard immediately, before the server confirms, and the save completes in the background

### Scenario: include a measurable defined at a higher level from ResultKit
- **Given** Eileen Sharp (Integrator), authenticated in ResultKit with Examply Sales as her active team
- **And** "Gross monthly revenue" (goal 500000) is a measurable defined on the Examp.ly root team
- **When** she asks ResultKit to include "Gross monthly revenue" from the Examp.ly root team on the Examply Sales scorecard and confirms
- **Then** the next `/rkit:scorecard` view of Examply Sales lists "Gross monthly revenue"

### Scenario: an included measurable is the same measurable — values flow through
- **Given** the Examp.ly root team's scorecard includes "Defects to clients", Sue Baylor's measurable defined on Examply Service Delivery
- **And** Sue Baylor (Customer Support), signed in as a member of Examply Service Delivery, records this week's value on "Defects to clients" on her own team's Data (scorecard)
- **When** Eileen Sharp (Integrator), signed in as team admin of the Examp.ly root team, views the Examp.ly root team's Data (scorecard)
- **Then** "Defects to clients" shows the value Sue recorded in the same week's cell — one measurable, same values on every board that shows it

## Missing tests

Each test below is missing today. For each one, in order: add the test, run it, **watch it fail for the right reason**, then write whatever makes it pass. Do not start implementation before the failing test exists.

1. **Data (scorecard) lists a measurable added from another team, with its weekly values** — covers Scenario: added measurable shows on Data (scorecard). Level: unit/component. Suite: `__tests__/components/scorecard/`.
2. **Level 10 Scorecard section lists a measurable added from another team** — covers Scenario: added measurable shows in the Level 10 Scorecard section. Level: unit/component. Suite: `__tests__/components/l10/meeting-agenda/scorecard-section.test.tsx`.
3. **Quarterly Business Review Measurables slide lists a measurable added from another team** — covers Scenario: added measurable shows on the Quarterly Business Review Measurables slide. Level: unit/component. Suite: `__tests__/components/team-business-review/`.
4. **Home Scorecard card includes an added measurable in its list and summary counts** — covers Scenario: added measurable shows on the Home Scorecard card. Level: unit/component. Suite: `__tests__/components/home/scorecard-card.test.tsx`.
5. **AI chat scorecard measurables card lists an added measurable** — covers Scenario: added measurable shows in the AI chat scorecard measurables card. Level: unit/component. Suite: `__tests__/components/ai/tool-results/get-scorecard-measurables-card.test.tsx`.
6. **Including a higher-level measurable via the add affordance, confirmed by click, shows it on the team's scorecard** — covers Scenario: include a measurable defined at a higher level — confirm by click. Level: e2e. Suite: `e2e/features/scorecard-behavior.feature`.
7. **Including a higher-level measurable confirmed by Enter shows it on the team's scorecard** — covers Scenario: include a measurable defined at a higher level — confirm by Enter. Level: e2e. Suite: `e2e/features/scorecard-behavior.feature`.
8. **Paint-before-response: the included measurable's row renders while the include request is still unresolved** — covers the Then of both include scenarios. Level: unit/component, holding the server promise unresolved and asserting the row is already painted. Suite: `__tests__/components/scorecard/`.
9. **A value recorded on the owning team appears on the including team's scorecard for the same week** — covers Scenario: an included measurable is the same measurable. Level: e2e. Suite: `e2e/features/scorecard-behavior.feature`.
10. **ResultKit `/rkit:scorecard` lists added measurables and can include a higher-level measurable** — covers the two ResultKit scenarios. The resultkit-skills repo has no automated test suite today; this check lands wherever that repo's verification lives, and the frontend tests above stand regardless.

## Done when

Every test above exists and passes, and every scenario holds on every screen listed.
