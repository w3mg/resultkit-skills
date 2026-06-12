# Draft issue (dry run — not filed)

**Target repo:** `w3mg/resultmaps-web-ui-2` (frontend — new UI)

**Proposed labels:** `bug`

**Issue title:**

Week view: day totals above the columns go stale after dragging a card to another day, until hard refresh

**Issue body (exactly as it would be filed):**

```markdown
## Problem

In the new UI week view (Prioritizer → Day/Week, `/prioritizer/day-week`), dragging a to-do card
from one day's column to another moves the card correctly, but the totals shown above the columns
do not update to reflect the move. The stale totals persist until the user hard-refreshes the page
— after refresh the totals are correct, so the move itself is saved.

Example from the report: dragging a card from Tuesday's column to Thursday's column — the card
lands in Thursday, but Tuesday's total still counts it and Thursday's total doesn't. Observed on
Chrome, twice on consecutive days (2026-06-10 and 2026-06-11).

The totals are how a user judges each day's load at a glance. Drag-and-drop between days is the
main rebalancing action this view exists for, and right after it the numbers contradict the cards
in front of the user — the view can't be trusted without a refresh.

## Desired behavior

### Scenario: Day totals follow a dragged card
- **Given** the week view shows a to-do card in one day's column, and each column shows a total above it
- **When** the user drags that card into a different day's column
- **Then** the card paints in the target column immediately, the source column's total decreases by
  one, and the target column's total increases by one — with no page refresh

### Scenario: Totals always match the visible cards
- **Given** any column in the week view
- **When** a drag-and-drop completes — successfully, or unsuccessfully (a failed move returns the
  card to its source column with an error message)
- **Then** the total above each column equals the number of cards displayed in that column

## Missing tests

Each test below is missing today. For each one, in order: add the test, run it, **watch it fail
for the right reason**, then write whatever makes it pass. Do not start implementation before the
failing test exists.

1. **After a cross-column drag, the source column's header total decrements and the target
   column's header total increments immediately, before any reload** — covers Scenario: Day totals
   follow a dragged card. Level: component. Suite: `__tests__/prioritizer/day-week/`.
2. **When a cross-column move fails and the card returns to its source column, every column's
   header total equals the number of card rows rendered in that column** — covers Scenario: Totals
   always match the visible cards. Level: component. Suite: `__tests__/prioritizer/day-week/`.

## Done when

Every test above exists and passes, and every scenario holds.
```
