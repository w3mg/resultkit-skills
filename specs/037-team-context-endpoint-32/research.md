# Research: Team Context Endpoint

**Branch**: `037-team-context-endpoint-32` | **Date**: 2026-03-13

## Findings

### Decision: New endpoint is `PATCH /users/me/team-context`

**Source**: API Change Handoff doc (Issue #32) — authoritative from API maintainer.

- **Request body**: `{ "team_id": <integer> }` (required)
- **Success (200)**: `{ "data": { "id": <integer>, "name": "<string>" } }`
- **400**: Malformed JSON body
- **401**: Missing or invalid Bearer token
- **422**: `team_id` missing, not an integer, team doesn't exist, or user is not a member
- **Idempotent**: Calling with the same `team_id` repeatedly is safe — returns 200 each time.

**Alternatives considered**: None — endpoint is already deployed.

### Decision: `current_team` in `GET /users/me` is now reliable

**Source**: API Change Handoff doc — the meta_key bug (`current_group_id` vs `current_group_context`) is fixed.

- Before: `current_team` was always `null` or stale regardless of what was set.
- After: `current_team` reflects the team last set via `PATCH /users/me/team-context`.
- No existing skills actively relied on `current_team` being non-null (setup skill displays it but doesn't branch on it).

**Action required**: Update api-reference.md to document this change and add a note to the `GET /users/me` row.

### Decision: Add `use {team_id}` action to `rkit:teams`

**Rationale**: The teams skill already owns team membership, role changes, and logo management. Setting active team context is a natural team-management action. The teams skill has an established pattern for PATCH confirmation flows (role change, logo remove) that can be reused directly.

**Alternatives considered**:
- `rkit:setup`: Handles initial config, not runtime team switching. Adding a runtime switch would conflate setup with daily usage.
- New standalone skill: Overkill for a single action.

### Decision: Confirmation pattern mirrors role-change flow

Existing role-change flow:
1. Fetch team name for human-readable confirmation prompt
2. Show: "Set active team to **{name}** (ID: {id})?"
3. On confirm: PATCH with `{ team_id }`
4. On success: "Active team set to **{name}** (ID: {id})."

This follows Constitution IV (Confirm Writes) and V (Show IDs).

### Decision: api-reference.md User Phrases table needs new row

Add a lookup phrase row for the new endpoint so skills can resolve natural language like "switch team", "use team", "set active team".
