# Draft Issue (dry run — not filed)

- **Target repo:** `w3mg/resultmaps-web-ui-2` (frontend — where the team scorecard surface lives and where the symptom is observed; see Open questions for possible re-route)
- **Proposed labels:** `bug`, `question` (`question` because the report is still exploratory — open questions below gate the final spec)
- **Issue title:** Team scorecard shows stale values every Monday — Friday's updates only appear after a manual nudge

---

## Issue body (exactly as it would be filed)

## Problem

Team members report updating their scorecard measurable values on Friday, but every Monday the
team scorecard still shows the values from before those updates. The stale view persists until
someone manually "pokes" the scorecard (exact action unconfirmed — see Open questions), after
which the Friday values appear. This recurs weekly — it is not a one-off.

Who it affects and why it matters: Monday is when the team scorecard gets its highest-stakes
viewing (weekly review). Every week the team starts its review from numbers they believe are
wrong, and the people who entered data on Friday get asked why they "didn't update." That erodes
trust in the scorecard as the source of truth and trains people to re-enter or double-check
numbers that were already submitted.

Today nothing in the product states a guarantee for when newly saved values become visible on
the team scorecard — including across the weekend/week boundary. Whatever the root cause turns
out to be, the absence of that guarantee is part of the problem, not an accepted default.

Reported by multiple team members across multiple weeks; not yet reproduced in triage (the
symptom is tied to the Monday week boundary). Checked for duplicates: #1421 (and api2 #334)
cover values for one specific week not persisting at all — different failure. Here the values
do appear once the scorecard is nudged.

## Open questions

These need answers before this spec can be considered final. They are captured here because the
report is exploratory — the reporter's own words: "I'm not even sure what's wrong or where."

1. What exactly is the "poke" that makes the values appear — a browser reload, clicking into a
   cell, switching team/week/period, or re-entering the numbers? (If the numbers have to be
   **re-entered**, this is a persistence failure, overlaps #1421 / api2#334, and the scenarios
   below need rewriting.)
2. Where do team members enter their numbers on Friday — the team scorecard grid itself, a
   1:1/personal view, the measurable drawer, AI chat, or an integration feeding the measure?
3. Which surface shows the stale values on Monday — the team scorecard page in the new app, an
   L10 meeting scorecard, a dashboard tile, or the legacy web scorecard? And is it a fresh
   Monday login or a tab left open since the previous week?
4. Are the affected measurables manual-entry, rollups aggregating child teams, or data-source
   fed? Do all measurables on the scorecard go stale, or only some?
5. Routing: filed to frontend because that is where the symptom is observed. If the answers show
   the API itself returns pre-Friday values on Monday (or the Friday write lands somewhere the
   team scorecard read does not look), this issue moves to `w3mg/resultmaps-api2` or
   `w3mg/resultmaps`. The scenarios below describe user-observable behavior and stay the same
   wherever the work lands.

## Desired behavior

Scenarios state the invariant as currently understood; answers to the open questions may tighten
them but should not weaken them.

### Scenario: Friday's entries are on the board Monday
- **Given** a team member updated a measurable's value on Friday and the save was accepted
- **When** anyone on the team opens the team scorecard the following Monday
- **Then** the prior week's column shows the Friday-saved value immediately — no refresh, edit,
  or any other nudge required

### Scenario: A new week starts cleanly
- **Given** the calendar has crossed into a new week
- **When** the team scorecard is viewed on Monday
- **Then** the current-week marker sits on the new week's column, and the prior week's column
  displays exactly the values that were saved during that week

### Scenario: Returning to a scorecard left open over the weekend
- **Given** the team scorecard was already open in a browser tab before the weekend
- **When** a user comes back to that tab on Monday
- **Then** what they see reflects the latest saved values and the current week — a user is never
  silently shown last week's view as if it were current

### Scenario: Values entered elsewhere show up on the team scorecard
- **Given** a team member updates their measurable value from another surface in the app
  (wherever they normally enter it — Open question 2)
- **When** the team scorecard is next viewed
- **Then** the updated value appears without anyone having to nudge the scorecard

## Missing tests

Each test below is missing today. For each one, in order: add the test, run it, **watch it fail
for the right reason**, then write whatever makes it pass. Do not start implementation before the
failing test exists.

1. **Weekly grid rendered after a week boundary includes the new current-week column and shows
   the prior week's saved values in the prior week's column** — covers Scenario: A new week
   starts cleanly. Level: unit (time-controlled). Suite: `__tests__/hooks/use-scorecard.test.ts`
   (existing column tests only assert against a fixed "now"; none cross a week boundary).
2. **A value saved late in the prior week renders on a fresh Monday open with no user
   interaction** — covers Scenario: Friday's entries are on the board Monday. Level: integration.
   Suite: `__tests__/components/scorecard/`.
3. **A scorecard view that was mounted in the prior week never presents last week's view as
   current once the user returns to it in the new week** — covers Scenario: Returning to a
   scorecard left open over the weekend. Level: integration. Suite:
   `__tests__/components/scorecard/`.
4. **A history-value update made elsewhere in the app is reflected on the team scorecard without
   a manual nudge** — covers Scenario: Values entered elsewhere show up on the team scorecard.
   Level: integration. Suite: `__tests__/components/scorecard/use-scorecard-propagation.test.ts`
   (currently covers only name/target metadata patches — no history-value case).
5. **Enter a value during week N, view the team scorecard in week N+1, and see the value with no
   nudge** — covers Scenarios: Friday's entries are on the board Monday + A new week starts
   cleanly, end to end. Level: e2e (clock-controlled). Suite: `e2e/components-scorecard.spec.ts`.

## Done when

Every test above exists and passes, every scenario holds through a real Friday-entry →
Monday-view cycle, and the open questions are answered — with the issue re-routed (and tests
relocated to the owning repo's suite) if the answers point off the frontend.
