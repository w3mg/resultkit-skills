# Research: Strategy Skill (rkit:strategy)

**Branch**: `001-strategy-skill` | **Date**: 2026-03-09

No NEEDS CLARIFICATION markers in spec. All API behavior verified against the live OpenAPI spec and live API calls. This document records decisions made from reviewing the spec, existing skills, and real API responses.

---

## Decision: Skill Directory Name

**Decision**: `skills/strategy/` → skill name `rkit:strategy`
**Rationale**: "strategy" is the API resource name (`/teams/{id}/strategy`). Users think in terms of "strategy" as an umbrella covering goals, rocks, objectives, etc.
**Alternatives**: `rkit:goals` — rejected because the tree contains multiple object types beyond goals (rocks, key results, milestones, focus areas).

---

## Decision: Tree Display Format

**Decision**: Display the strategy tree as an indented hierarchy using 2-space indentation per level. Each node shows: status indicator, name, object_type label (framework-aware), assignees, due date, and ID.
**Rationale**: The API returns a nested tree structure. Indentation naturally represents hierarchy. Consistent with how project management tools display goal hierarchies.
**Alternatives**: Flat table with parent column — loses visual hierarchy. Numbered outline — doesn't convey depth as naturally.

**Example output** (EOS team):
```
Strategy for Patricks [EOS] Team (eos) — 2026 Q1

🟢 Annual Goal: Hit $10M ARR (yearly_goal #6520, due 2026-12-31)
  🟢 Rock: Improve onboarding (rock #6528, due 2026-03-31, → Patrick A.)
    ⚪ Milestone: Reduce time to first value (milestone #153685, due 2026-03-31)
    ⚪ Milestone: Automate welcome sequence (milestone #153686, due 2026-03-31)
  🟡 Rock: Launch partner program (rock #6529, due 2026-03-31)

Unaligned:
  🟢 Rock: Internal tooling cleanup (rock #7281, due 2026-03-31)
```

---

## Decision: Framework-Aware Labels

**Decision**: Map `object_type` values to framework-specific display labels:
- EOS: `yearly_goal` → "Yearly Goal", `rock` → "Rock", `milestone` → "Milestone" (EOS uses "milestone" where OKR uses "key_result")
- OKR: `objective` → "Objective", `rock` → "Rock", `key_result` → "Key Result", `focus_area` → "Focus Area"
- 4DX: `objective` → "WIG", `rock` → "Battle", `key_result` → "Lead Measure"
- Fallback: Use `object_type` as-is for unknown frameworks (SRT, V2MOM, null, etc.)

**Rationale**: Constitution principle VI. The API returns normalized `object_type` values — the skill should translate them to the user's framework terminology.
**Alternatives**: Always show raw `object_type` — simpler but loses domain meaning.

---

## Decision: Object Name Resolution

**Decision**: Flatten the strategy tree (including unaligned) into a list. Case-insensitive substring match. If multiple matches, show disambiguation list with id, object_type, status, and parent context. Stop and ask user to pick.
**Rationale**: Consistent with `rkit:scorecard` measure resolution. Users shouldn't need to remember exact names or IDs.
**Alternatives**: Require exact match (too strict); allow ID-based reference only (not user-friendly).

---

## Decision: Parent Resolution for Create/Align

**Decision**: When user specifies a parent by name (e.g., `under "Annual Goal"`), resolve it from the tree using the same name matching. Automatically derive `parent_type` from the matched node's `object_type`. User never specifies `parent_type` or `object_type` directly.
**Rationale**: The API requires `parent_id` + `parent_type` for create and `object_type` + `parent_type` for align/delete. These are internal API concepts — the skill should abstract them away.
**Alternatives**: Require user to pass object_type values — too technical for CLI use.

---

## Decision: Confirmation Flow

**Decision**: For create, update, align, and detach operations, show a summary of the intended action and ask for confirmation before calling the API.
**Rationale**: Constitution principle IV. Consistent with all existing rkit skills.
**Alternatives**: No confirmation — violates constitution.

---

## Decision: Inherited Node Handling

**Decision**: Display inherited nodes with an "[inherited from Team Name]" label. Block any create/update/align/detach operations targeting inherited nodes with a clear error message.
**Rationale**: The API returns `inherited: true` and `inherited_from` for nodes from parent teams. These are read-only — attempting to modify them would result in a 403.
**Alternatives**: Allow the attempt and let the API fail — worse UX.

---

## Decision: Year/Quarter Defaults

**Decision**: Default to current year and current quarter (matching API defaults). Support `year=All` and `quarter=All` overrides. Compute current quarter from today's date.
**Rationale**: Most users want to see current strategy, not historical. The API defaults match this.
**Alternatives**: Always show all years — too much data for most teams.

---

## API Behavior Notes (verified against live API)

- `GET /api/v2/teams/:id/strategy` — query params: `year` (int or "All"), `quarter` (1-4 or "All"). Returns `{ data: { framework, strategy: StrategyNode[], unaligned: StrategyNode[] } }`.
- `POST /api/v2/teams/:id/strategy` — body: `{ name*, description?, status?, due?, assignees?, parent_id?, parent_type?, is_focus_area? }`. Returns `{ data: { id, object_type } }` (201).
- `PATCH /api/v2/strategy/:objectType/:objectId` — body: `{ name?, description?, status?, due?, assignees? }`. Assignees replaces all.
- `DELETE /api/v2/strategy/:objectType/:objectId` — body: `{ parent_id*, parent_type*, also_archive? }`. Detaches link; optionally archives.
- `PUT /api/v2/strategy/align` — body: `{ object_id*, object_type*, parent_id*, parent_type* }`. Links object to parent.
- Status values: active, complete, archived, deferred, review, draft, cancelled, at_risk, off_track.
- Object types: yearly_goal, rock, focus_area, objective, key_result, milestone, action.
- EOS framework uses "milestone" where OKR uses "key_result" at the third level.
- Inherited nodes have `inherited: true` and `inherited_from: { team_id, team_name }`.
