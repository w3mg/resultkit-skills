# Draft Issue (dry run — NOT filed)

**Target repo:** `w3mg/resultmaps-web-ui-2`
**Proposed labels:** `bug`
**Issue title:** Prioritizer week view: day totals above columns don't update after dragging a to-do to another day (until hard refresh)

---

## Issue body (exactly as it would be filed)

## Problem

On the new UI week view (Prioritizer — https://resultkit.ai/prioritizer/day-week), in Chrome:

1. Drag a to-do card from one day column to another (reported: **Tuesday → Thursday**)
2. The card moves to the target column immediately and looks correct
3. The **day totals above the columns do not update** — the source column still counts the moved card, and the target column's total doesn't increase
4. Hard refresh the page — the totals are now correct

The move itself persists fine; only the totals are stale. Observed twice on Chrome: 2026-06-10 and again 2026-06-11.

**Environment:** Chrome on macOS, reproduced on consecutive days.

## Expected behavior

- On drop, the totals above **both** affected columns repaint immediately along with the card move — source total decrements, target total increments. No refresh needed.
- If the move fails to persist, the card and the totals roll back **together** with an error toast. The totals and the visible cards should never disagree.

## Investigation notes

- The week-style drag surface in the new UI is the Prioritizer Day/Week view: `components/prioritizer/day-week/day-week-view.tsx`. Cross-column drag (`handleDragEnd`, ~L269–317) paints an optimistic `setLocalOverrides` for source + target columns, then POSTs `/api/v2/day-plan-actions/{dpaId}/move-to-day`.
- The pill-header count badge renders `{items.length}` from the same effective column items in `components/prioritizer/day-week/time-column.tsx` (~L89–97). If the card visibly moves, that badge should move with it — so first identify **which element renders the totals the reporter sees**; it may be a different component reading from a non-optimistic source (e.g., a refetch-backed hook rather than the local overrides).
- Column-name caveat: the Day/Week view's columns are Today / This Week / Next Week / Later, not weekday names. "Tuesday"/"Thursday" columns suggest this may instead be the **custom-columns view** with day-named columns: `components/prioritizer/custom-columns/custom-columns-view.tsx`, with the header count at `components/prioritizer/custom-columns/column-header.tsx` (~L118, `itemCount`). If the repro doesn't surface on day-week, check custom-columns next, and confirm with the reporter which prioritizer view/URL they were on.
- Same "stale until reload" class as #1430 (archiving from the item sidebar doesn't remove it from the day plan until reload).

## Acceptance criteria

- [ ] Dragging a to-do card between day columns in the week view updates the totals above both the source and target columns immediately (no refresh, no hard refresh)
- [ ] Totals stay correct after the move persists (no flicker back to stale values from a later refetch)
- [ ] If the move API call fails, the card and the totals roll back together with an error toast
- [ ] No regression to within-column reorder or to the card move itself
