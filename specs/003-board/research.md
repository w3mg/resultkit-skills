# Research: rkit:board

**Date**: 2026-02-16

## R1: Orphan API Behavior

**Question**: Does `PUT /items/{id}/move` with `{"parent_id": null}` orphan an item?

**Decision**: Yes — use `PUT /items/{id}/move` with `{"parent_id": null}` to orphan.

**Rationale**: API reference states the move endpoint accepts `parent_id*` as "integer or null". Passing `null` removes the parent relationship, making the item a root-level item (orphaned from any project/column).

**Alternatives considered**: None — this is the documented API behavior.

## R2: Board View — Multiple API Calls

**Question**: Board view requires 1 + N API calls (fetch columns + fetch each column's children). Best approach?

**Decision**: Sequential calls orchestrated by Claude Code from SKILL.md instructions. Each call is a separate Bash tool invocation.

**Rationale**: This matches the established pattern in rkit:today (one Bash call per API operation). With the 10-column cap (FR-008), worst case is 11 API calls. Claude Code can execute these sequentially in a single skill invocation. A batch script was considered but adds unnecessary complexity — the SKILL.md already orchestrates multi-step flows (see rkit:today's mark-complete-then-refresh pattern).

**Alternatives considered**:
- Single bash script that loops internally: More efficient but harder to debug, breaks the established pattern of Claude Code orchestrating individual api.sh calls.
- Parallel background subshells: Over-engineered for 11 calls max.

## R3: Day Plan Attach for Remove Flow

**Question**: After orphaning an item in the remove flow, can we attach it to today's day plan?

**Decision**: Yes — use `PUT /day-plans/today/items/{item_id}` to attach the orphaned item to today's plan.

**Rationale**: The day plan attach endpoint is idempotent and accepts any valid item ID regardless of its parent state. This was confirmed from the API reference: `PUT /day-plans/today/items/{item_id}` — "Attach existing item to today (auto-creates plan)". No parent_id requirement.

**Alternatives considered**: Using rkit:today skill — rejected per Constitution II (Self-Contained). Direct API call via api.sh is correct.

## R4: Column Name Filtering

**Question**: How to handle case-insensitive matching and duplicate column names for US2?

**Decision**: Case-insensitive substring match on column names. If multiple matches, list them with IDs and ask user to pick (per clarification Q3).

**Rationale**: Users will type column names from memory, so case-insensitive matching reduces friction. Substring match allows partial names (e.g., "eng" matches "Engineering"). When ambiguous, the interactive prompt resolves it.

**Alternatives considered**: Exact match only — rejected as too strict for interactive CLI use.

## R5: Config Schema Extension

**Question**: What does `default_board_id` look like in config?

**Decision**: Add optional `default_board_id` field to config.json. Accepts an integer (item ID) or the string `"ask"`.

**Rationale**: Per clarification Q2 — if set to an integer, use that item ID as the default board. If set to `"ask"`, prompt user to confirm/change before loading. If not set, prompt user for an item ID. Config schema:

```json
{
  "api_token": "<bearer-token>",
  "default_team_id": "<int>",
  "api_base": "https://api.resultmaps.com/api/v2",
  "default_board_id": 42
}
```

**Alternatives considered**: None — straightforward config extension matching existing patterns.
