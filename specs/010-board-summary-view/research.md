# Research: Board Summary View

**Date**: 2026-02-18

## R1: How to get column item counts

**Decision**: Count items from the data already fetched. The existing View Board flow fetches all columns and all their items. The item count per column is simply the length of each column's fetched `data` array (or `meta.total` if it exceeds the page size).

**Rationale**: No new API calls needed. The data is already in hand.

## R2: Interaction pattern for drill-in prompt

**Decision**: Use `AskUserQuestion` with options: "All columns", "Pick one", "None". If user picks "Pick one", ask which column (by number, name, or ID — same matching as existing View Single Column flow).

**Rationale**: `AskUserQuestion` is already in the skill's `allowed-tools`. Reuses existing column-matching logic.

## R3: What changes

**Decision**: Only the display order in "Flow: View Board" Steps 2–3 changes. Fetch logic stays the same. After fetching, show summary table first, ask user, then show detail for selected column(s).

**Rationale**: Minimal change. No new API calls, no new dependencies.
