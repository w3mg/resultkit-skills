---
name: BDD-spec-skill
description: >
  Write or review a Behavior-Driven Development (BDD) spec — a Feature with one or more
  Scenarios in Given/When/Then form that describe observable, user-visible behavior. Use this
  skill WHENEVER the user wants to write, draft, review, tighten, split, or convert anything into
  a BDD spec, behavior spec, acceptance criteria, acceptance test, scenario, or "Given/When/Then"
  — for a feature, user story, bug, or endpoint in any ResultMaps repo. Also use when the user
  says "BDD", "behavior spec", "spec out this behavior", "write scenarios", or hands you a feature
  and asks what the expected behavior should be. BDD is the practice; Gherkin is only one notation
  for it — trigger regardless of whether the word "Gherkin", a .feature file, or any tool is
  mentioned. Bundles the Examp.ly example organization (accountability chart: real people, seats,
  roles, reporting lines) so scenarios can use realistic named actors.
user-invocable: true
allowed-tools: Read, Write, Edit, Glob, Grep
---

# BDD Spec

## Where this skill lives — update every copy (binding)

Canonical home: `resultkit-internal-pm/.claude/skills/BDD-spec-skill/` (the SuperPM repo).
Deployed copies — each repo where BDD work happens carries a full copy so the skill triggers there:

- `resultmaps-web-ui-2/.claude/skills/BDD-spec-skill/`
- `resultmaps-api2/.claude/skills/BDD-spec-skill/`
- `resultkit-design-content/.claude/skills/BDD-spec-skill/`
- `resultkit-skills/.claude/skills/BDD-spec-skill/`

Any edit to this skill — SKILL.md or `references/` — is applied to the canonical home AND every
deployed copy in the same session, then committed and pushed in each repo. A drifted copy is a
defect (api2 drifted behind for five days before 2026-07-20). The bundled
`references/screen-and-context-inventory.md` also stays identical to its locked-in source:
`resultkit-design-content/completed-reference/screen-and-context-inventory.md`.

Write behavior specs that describe **what a user observes**, not how the system is built.

BDD (Behavior-Driven Development) captures a capability as a **Feature** with one or more
**Scenarios**, each written in **Given / When / Then** steps. BDD is the practice; Gherkin is just
one notation people use to write it down — you do not need the word "Gherkin," a `.feature` file,
or any tool. What matters is the shape below and that every step is observable behavior.

## Name the real screen — use the app screen inventory

Every scenario that happens on a screen must name the **actual** screen, in the app's own words —
never a vague placeholder ("the right place", "the team's context") or an invented control name
("the team label control"). Inventing or blurring the surface is a top failure this skill exists to stop.

Before writing a scenario, open **`references/screen-and-context-inventory.md`** (bundled with this
skill). It is the canonical hierarchical list of the current app's screens, each grouped by the
context it belongs to — **Personal, Team, Project, or Global**. Find the screen the behavior actually
happens on and use its exact name and context. If a behavior spans several screens, that is several
scenarios — one per screen (see "No fudging" below).

If the screen isn't in the inventory, say so and ask — do not invent one, and do not fall back to a
generic phrase.

> Canonical source (locked-in): `resultkit-design-content/completed-reference/screen-and-context-inventory.md`.
> The bundled `references/` copy must stay identical to it; re-sync on any change.

## Name real people — use the Examp.ly org

When a scenario needs an actor — the role in a Given ("Given I am an admin"), a manager/report
pair, an assignee, a teammate — use a real person from **Examp.ly**, the canonical example
organization, instead of inventing "User A" or "Alice the admin". Read
**`references/examply-accountability-chart.md`** (bundled with this skill): the full accountability
chart — every seat, the person who fills it, reporting lines, accountabilities, measurables, and
rocks. Pick the person whose seat actually carries the behavior (a Finance behavior belongs to the
Finance seat's owner, not a random name), and keep the same people consistent across the scenarios
of one Feature. Realistic actors matter for the same reason real screen names do: they pin the
scenario to a testable situation — a seat with real reports, real measurables, real scope.

Presumption (locked-in): **Eileen Sharp, the Integrator, is also the system admin.** Use her for
admin-role scenarios unless the spec explicitly says otherwise.

## No fudging — ever

A BDD spec earns its place only when it pins one real behavior precisely enough to become one
failing test. Anything that blurs that is fudging. Do not fudge, and do not offer fudging to the user
as a "lighter," "simpler," or "grouped" option — not even to save time. Refuse these:

- **Vague context.** "When I'm in the team's context," "in the right place," "wherever appropriate."
  Name the actual surface — the specific screen, list, picker, filter, or card. If a behavior happens
  on five surfaces, that is five scenarios, each naming its surface and its real scope.
- **Lumping.** Two or more behaviors in one scenario ("Then I see it, and I can apply it, and
  everyone else sees it too"). Each distinct behavior is its own scenario.
- **False collapsing.** Merging behaviors that are only superficially alike into one scenario or one
  Scenario Outline. A Scenario Outline is legitimate ONLY when every row is the same behavior with
  the same expected result, differing by a single value. The moment surfaces or rules differ
  (different scope, capabilities, or outcome) they are different behaviors and get separate
  scenarios — a row-per-surface table that hides those differences is a fudge.
- **Policy instead of behavior.** "Only admins can X" is a rule, not a spec. Write the situation and
  the observable result.
- **Hedged outcomes.** A Then like "the system handles it correctly," or "nothing changes" when
  nothing was even attempted. Every Then is a specific, observable result.

Why this is non-negotiable: a fudged spec produces a test that passes while proving far less than it
appears to — worse than no test, because it reads as coverage. And completeness here is not a cost.
Writing each surface and each behavior out is a tiny, one-time effort. The real cost is
under-specification: it ships wrong, is caught late, and burns days of rework and re-litigation.
Never frame thoroughness to the user as a tradeoff against speed — doing it correctly the first time
is the fast path.

## Clarification gate — ask before anything is committed or filed (binding)

Learned 2026-07-20 (pages markdown support): invented OPEN items — a "keyboard modality" blocker
the user never specced, plus codebase-derived storage and sanitizer questions — stalled a simple
feature for three days and pulled a second person into chasing them. The rules:

- **An OPEN item may only record a gap in what the user themselves said** — something their
  description left genuinely undecided. NEVER create an OPEN item from reading the codebase, from
  implementation knowledge (storage, sanitizers, API shapes), or from standards the author holds
  (a11y paths, input modalities, edge-case policies). Spec work is behavior and prototypes;
  implementation questions are not spec questions.
- **Prompting the user for additional guidance is always fine — declaring blockers is not.**
  "Must be resolved before development continues" is the user's call, never the spec author's.
  Write the question, not the roadblock.
- **Before the BDD is committed — and before any issue is filed from it — put every OPEN item to
  the user as direct questions, in one batch, in the session.** Each item ends either answered
  (record the dated decision) or explicitly deferred by the user ("file with these open"). A
  decisions queue the user has not seen and ruled on never ships.

## Journey scenarios — the specificity bar (binding)

Learned 2026-07-15 building the context-chips master BDD: restating rules in scenario clothing
reads as coverage but ships ambiguity — "it's all theoretical because you've avoided going into
specific situations." The bar that fixed it:

- **Follow one named person and one named item** from the page where the item is created to every
  other surface it appears on: *given an individual adds a particular item to a particular page,
  then views that same item in other contexts.* Spec state journeys, not rules.
- **Restate the full Given in every scenario.** Never "same as above," never "Sequencer: same."
  A scenario someone reads in isolation must still be a complete login script.
- **Name the exact surface AND its subdivision** — page, tab, section/column, whose column
  ("the Agenda tab's To-Do section on Examp.ly's Level 10 Meeting page," "Evan's member column").
  When two pages share a surface name (more than one page has an "Agenda"), qualify with the page
  name — and disambiguate by naming *this* surface precisely, never by mentioning the other page:
  a stray "not the X page's agenda" reads as a statement about page X and creates new ambiguity.
- **State the complete observable set, including explicit exclusions.** A display scenario lists
  exactly what renders AND what does not ("no `Personal Planner` chip"), each exclusion with its
  reason. "Shows X" without the full set leaves every unlisted element ambiguous — which is where
  contradictory rules hide.
- **Tag every scenario `LOCKED` / `PROPOSED` / `OPEN`.** LOCKED = the user confirmed the exact
  wording (cite who and the date). PROPOSED = written to the locked pattern, awaiting review.
  OPEN = an undecided question — keep these in a decisions queue and build nothing on them.

Exemplar: `resultkit-design-content/app-design-projects/item-alignment-and-context/context-chips-journey-bdd.md`.

## Definition of done these scenarios must encode (binding)

These scenarios are the script three downstream gates run against: the **real-flow gate** (a person
drives this exact flow in the running app — opens the named view, types, presses Enter, watches the
result appear, side-by-side with the binding prototype where one exists), the **test** that locks
it, and **review**. So the spec is finished only when it encodes the three standards below;
weakening any of them is fudging.

1. **Per-view scenarios, enumerated from the inventory.** Every behavior rule is written as
   per-view / per-screen scenarios drawn from the screen-and-context inventory above — **one named
   scenario per view**, never a generic scenario standing in for many. A rule that applies on five
   screens is five named scenarios. This is the spec's core, not a nicety.

2. **Each scenario names its input modality — Enter = Save is ONE behavior, both covered.** Reaching
   a behavior by pressing **Enter** in the field and by clicking **Save** (or the tick / add
   control) is the same behavior via two paths; the spec covers **both**, each naming its modality
   in the When ("When she presses Enter", "When she clicks Save") — never only the path the author
   pictured.

3. **Paint-before-response is written into the Then.** For any add / save / mutate, the scenario
   states that the originating view shows the result **immediately, before the server confirms** —
   order the Then-clauses as the user perceives them: the row / feedback paints first, the save
   completes after ("Then the item appears in the list at once, and the save completes afterward").
   A scenario whose only Then is the eventual server state cannot become the paint-before-response
   test that locks it (that test holds the server promise unresolved and asserts the painted result
   before it resolves).

## The shape

```
Feature: <the capability, named for the behavior>
Scenario: <one specific behavior>
Given <a role, account state, or starting context>
And <more context, if needed>
When <one action the user takes>
And <continuation of that action, if needed>
Then <one clear, observable result>
And <more observable results, if needed>
```

## The pattern to copy

Most strong scenarios follow this structure:

- **Given** a user role, account state, or plan state
- **When** the user performs one action
- **Then** the system shows one clear result

Example:

- Given I am an admin on a paid workspace
- When I invite a teammate
- Then the invite is sent and the seat count updates

## What makes a scenario solid

- **User-visible behavior only.** Write what the person sees or can do — "the teammate appears in
  Pending Invites," not "a row is inserted into the invites table." The reader is a product owner or
  QA, not the implementer.
- **Concrete Given / When / Then.** Specific starting conditions, one clear action, specific
  outcomes. Avoid vague verbs like "validate," "handle," or "process" — they hide the behavior.
- **No implementation details.** No database writes, service or API calls, table/function names, or
  HTTP status codes. If a step describes how the system works internally, it is in the wrong
  document — restate it as what the user observes.
- **One behavior per scenario.** If a scenario asserts two unrelated things, split it. Group related
  behaviors as multiple Scenarios under one Feature (e.g. "request a reset link," then "reset with a
  valid token").
- **Name the concrete surface.** A behavior happens somewhere specific. If team labels appear in a
  picker on five screens, write five scenarios that each name the screen — never one "in the app" or
  "in that context" catch-all. Different surfaces usually carry different scope and capabilities, so a
  spec that doesn't name the surface can't become a real test for it.
- **Readable the same way by product, QA, and automation.** A good scenario doubles as a
  requirement, a test case, and an acceptance check without translation.

## Bad vs good

- **Bad:** "System should validate login input." — vague, the system is its own actor, nothing
  observable.
- **Good:** "Given I am on the sign-in page, When I enter an invalid password, Then I see an error
  message and I am not signed in." — a real situation with a result the user can see.

The good version is better because it says exactly what happens in a real situation, which is the
whole point of BDD.

## Gold-standard examples

Before writing, read [`references/examples.md`](references/examples.md) — eight adaptable SaaS
scenarios (teammate invites, trial upgrade, password reset, project creation, plan changes, member
removal, integrations, usage limits), plus the summary of what makes them solid. Match their level
of concreteness and their avoidance of implementation detail. Adapt the closest example to the
behavior at hand rather than inventing a new structure.

## Writing a spec

1. Name the **Feature** after the capability, in the user's own words — not after a solution.
2. For each distinct behavior, write one **Scenario** with a short, specific name.
3. Set **Given** to the role / account / plan state that behavior requires.
4. Put the single **When** action the user takes.
5. List the **Then** outcomes the user can observe. For UI behavior, order them the way the user
   perceives them — feedback paints first, then the result completes.
6. Re-read every step: if any names something internal, rewrite it as what the user observes.
