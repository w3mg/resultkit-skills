# Research: Goals, Rocks & Milestones API Migration

**Branch**: `038-goals-rocks-api-40` | **Date**: 2026-03-18

## R1: Response Field Name Changes

**Decision**: Use `type` (not `goal_type`) and `color` (not `progress_color`) in all documentation and skill logic.

**Rationale**: Curl testing on 2026-03-18 confirmed the actual field names differ from the original handoff document. The verified response shapes show `type` with string values (`"yearly_goal"`, `"rock"`, `"milestone"`) and `color` (string or null).

**Alternatives considered**: None — this is a factual correction.

## R2: GET /teams/{id}/targets Tree Response Shape

**Decision**: Assume `GET /teams/{id}/targets` returns the same response shape as the old `GET /teams/{id}/strategy`. The tree nodes still use `object_type` for the hierarchical type field (not `type`).

**Rationale**: The handoff document only mentions a path rename, not a schema change. The tree response has its own schema (`StrategyNode` with `object_type`, `children`, `inherited`, etc.) which is separate from the flat CRUD response schema (which uses `type`). The skill's tree-rendering logic should not need changes beyond the URL.

**Alternatives considered**: Could verify with a live API call during implementation. Recommended as a verification step.

## R3: Detach Without Archive

**Decision**: Implement "detach" (unlink from parent) using PATCH to set `parent_id: null`. Implement archive using DELETE.

**Rationale**: The old API had `DELETE /strategy/{type}/{id}` with `also_archive` boolean — a single endpoint for both unlink and archive. The new API separates these: PATCH updates fields (including removing a parent), DELETE archives. The `detach` command's `--archive` flag maps cleanly to this split.

**Alternatives considered**:
1. Drop the `detach` command entirely and only support `delete` (archive). Rejected: users need to reorganize trees without destroying nodes.
2. Always use DELETE (always archive on detach). Rejected: breaks existing user workflows.

## R4: EOS-Only Restriction Impact

**Decision**: Surface the 422 error clearly for non-EOS teams. Do not attempt to hide or work around the restriction.

**Rationale**: The new CRUD endpoints only work for EOS teams. OKR, 4DX, SRT, V2MOM teams cannot use them. The read endpoint (`GET /teams/{id}/targets`) works for all frameworks. Since there's no replacement for non-EOS mutations, the skill should show a clear message: "Goal/rock/milestone management is only available for EOS teams."

**Alternatives considered**: Could attempt to fall back to old endpoints for non-EOS teams. Rejected: old endpoints are deleted from the API.

## R5: Milestone Year/Quarter Filter Bug

**Decision**: Use `?parent_id=ROCK_ID` filter instead of `?year=&quarter=` when the skill needs to list milestones independently. For the tree view, no filter needed since `GET /teams/{id}/targets` returns all nodes.

**Rationale**: Known bug — V2 milestone year/quarter filter returns incorrect results (extra milestones from non-rock parents, missing milestones with null group_id). The `parent_id` filter returns exact parity with Rails.

**Alternatives considered**: Use year/quarter and warn users about potential inaccuracies. Rejected: silent data discrepancies are worse than using the working filter.

## R6: Create Flow Type Determination

**Decision**: Determine the object type to create based on (1) explicit user specification or (2) parent type inference using EOS hierarchy: root→goal, under goal→rock, under rock→milestone.

**Rationale**: The old API auto-inferred type from position in the tree. The new API has separate endpoints per type. The skill must make this determination itself. EOS hierarchy is fixed: yearly_goal → rock → milestone (3 levels). If user says "create under [rock name]", the skill knows to create a milestone.

**Alternatives considered**: Always require explicit type specification. Rejected: breaks backward compatibility with existing `/rkit:strategy create "Name" under "Parent"` syntax.

## R7: Rock `persist_until_cleared` Field

**Decision**: Display in output when true. Do not expose as a creation parameter initially.

**Rationale**: The field appears in rock responses but is not shown in any creation request example in the handoff. Likely an API-controlled field. Can be added later if users request it.

**Alternatives considered**: Add as an optional create/update parameter. Deferred: insufficient documentation on whether the API accepts it as writable.
