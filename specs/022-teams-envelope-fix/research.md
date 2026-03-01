# Research: Teams Envelope Fix & Error Handling Update

**Branch**: `022-teams-envelope-fix` | **Date**: 2026-03-01

## Finding 1: Two Skills Parse GET /teams as Bare Array

**Decision**: Update `rkit:teams` and `rkit:setup` to parse `body.data` instead of `body` for the teams list.

**Rationale**: Both skills have explicit documentation that `GET /teams` returns a "flat JSON array" and access `body` directly. The API change wraps this in `{ "data": [...] }`, breaking the parsing.

**Affected code**:
- `skills/teams/SKILL.md` lines 67-69: "The `body` is a **flat JSON array** (not wrapped in `data`/`meta`). Each element is a team object." + "access it as `body` directly — not `body.data`."
- `skills/setup/SKILL.md` lines 75, 88-89: "returns authenticated user's teams as a flat array — no pagination" + "The response is a flat JSON array (not wrapped in `data`). Each team has `is_default`"

**Alternatives considered**:
- Make api.sh auto-unwrap data envelopes — rejected, would break all other skills that already handle the envelope correctly.

## Finding 2: No Other Skills Affected

**Decision**: Only `rkit:teams` and `rkit:setup` need changes. All other skills use team sub-endpoints (members, items, projects) which already use the data envelope.

**Rationale**: Searched all SKILL.md files for `GET /teams` bare-array parsing. Only the two identified skills reference the flat array format. Skills like `rkit:board`, `rkit:level10`, and `rkit:weekly` use `GET /teams/{id}` (single team detail) or team sub-endpoints, not the list endpoint.

## Finding 3: Constitution Already Expects Data Envelope

**Decision**: The constitution's API Constraints section (line 124-126) already states: "All list endpoints return `{ data: [...], meta: { page, per_page, total, total_pages } }`. Skills MUST handle pagination when results may exceed one page." The bare array was an inconsistency — this fix aligns `GET /teams` with the documented contract.

**Rationale**: No constitution change needed. The API is now consistent with what the constitution always required.

## Finding 4: 500 Internal Error Code

**Decision**: Add `500 internal_error` to the api-reference.md Error Responses table. Skills already handle "Other non-200" errors generically, so no skill-level error handling changes are required.

**Rationale**: The new `internal_error` code follows the same `{ "error": { "code", "message" } }` structure. Existing "Other non-200 → Show status code and error from response body" handling covers it. Adding it to the reference is for documentation completeness.

**Alternatives considered**:
- Add explicit 500 handling to every skill — rejected, generic error handling already covers it.

## Finding 5: Setup Skill Uses curl Directly

**Decision**: The setup skill calls `GET /teams` via raw curl (not api.sh) because config doesn't exist yet during first-time setup. The curl response parsing also assumes a bare array and needs updating.

**Rationale**: In Step 4 and the reconfigure flow (Option 2), the setup skill parses the curl response body directly. The comment "The response is a flat JSON array" must be changed and the parsing logic must unwrap from `data`.
