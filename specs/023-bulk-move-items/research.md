# Research: Bulk Move Items

**Branch**: `023-bulk-move-items` | **Date**: 2026-03-01

## Finding 1: Board Skill Is the Natural Home

**Decision**: Add the bulk-move flow to `skills/board/SKILL.md` rather than creating a new skill.

**Rationale**: The board skill already handles item hierarchy operations: view (children), move (reparent), add, and remove. Bulk-move is a batch version of the existing single-item move. The argument parsing table already has `move {item_id} {target_id}` — adding `bulk-move {item_ids} {parent_id}` follows the same pattern.

**Alternatives considered**:
- New standalone `rkit:bulk-move` skill — rejected, too narrow for a separate skill. Bulk-move is a board/hierarchy operation.
- Add to a generic "items" skill — rejected, no such skill exists in this project.

## Finding 2: Partial Failure Handling Is Unique

**Decision**: Display a summary line + error table for partial failures. This is a new pattern not present in existing skills.

**Rationale**: Unlike single-item operations that either succeed or fail entirely, bulk-move can partially succeed. The response includes `moved`, `failed`, and per-item `errors` array. The skill needs to:
1. Always show the summary: "Moved N items under #{parent_id}. M failed."
2. If `failed > 0`, show a table of failed items with ID and reason.

**Pattern**:
```
Moved 3 items under #100. 2 failed.

| Item ID | Reason |
|---------|--------|
| 42 | forbidden |
| 99 | not_found |
```

## Finding 3: Board Warning About Weekly Boards

**Decision**: Include a warning in the confirmation prompt that moved items will be removed from all weekly boards.

**Rationale**: This is a significant side effect that users might not expect. The API removes items from all board placements after a bulk move. The confirmation prompt should mention this so users make an informed decision.

## Finding 4: No Framework Terminology Needed

**Decision**: The bulk-move command operates on raw item IDs. No framework-specific terminology mapping is needed.

**Rationale**: Unlike L10 or weekly board operations where users might say "rocks" or "to-dos", bulk-move is a structural operation. Users specify item IDs and a parent ID directly. The handoff's suggestion to map "move these rocks under this goal" is handled by Claude's natural language understanding — the skill just needs the IDs.
