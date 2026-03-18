# Implementation Plan: Goals, Rocks & Milestones API Migration

**Branch**: `038-goals-rocks-api-40` | **Date**: 2026-03-18 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/038-goals-rocks-api-40/spec.md`

## Summary

Migrate the `rkit:strategy` skill and `api-reference.md` from the old generic strategy mutation endpoints (7 removed) to the new typed goals/rocks/milestones endpoints (14 added). Rename the read endpoint from `GET /teams/{id}/strategy` to `GET /teams/{id}/targets`. Update response field names (`goal_type`→`type`, `progress_color`→`color`), document the milestone filter bug workaround, and sync changes to all skills.

## Technical Context

**Language/Version**: Bash 5.x, Markdown (Claude Code skill runtime)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), `jq`, `curl`
**Storage**: N/A — all data via ResultMaps V2 API
**Testing**: Manual API testing via `scripts/api.sh` against live API
**Target Platform**: Claude Code plugin (all platforms)
**Project Type**: Claude Code plugin skill suite
**Performance Goals**: N/A (interactive skill, single API calls)
**Constraints**: Skills must be self-contained per constitution; no external runtimes
**Scale/Scope**: 2 files to modify (`api-reference.md`, `skills/strategy/SKILL.md`), ~40 skill copies to sync

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | PASS | SKILL.md entry point unchanged |
| II. Self-Contained | PASS | No new external dependencies |
| III. Config-Driven | PASS | Config usage unchanged |
| IV. Confirm Writes | **DESIGN** | Detach flow semantics change — DELETE now always archives. Need to redesign `detach` command: use PATCH to unlink (set `parent_id: null`), DELETE only for archive. Both still require confirmation. |
| V. Show IDs | PASS | New responses include `id` and `type` |
| VI. Framework-Aware | **DESIGN** | Create flow changes from auto-inferred types to explicit typed endpoints. Skill must determine goal/rock/milestone based on parent type or user intent. GET /teams/{id}/targets tree still uses `object_type` field for node types. |
| VII. Direct Execution | PASS | Still uses Bash + api.sh |
| VIII. Graceful Degradation | PASS | 422 EOS-only error must be surfaced clearly |
| IX. Concise Output | PASS | Display format unchanged for view flow |

**Gate result**: PASS with design notes for principles IV and VI.

## Project Structure

### Documentation (this feature)

```text
specs/038-goals-rocks-api-40/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── goals-crud.md
│   ├── rocks-crud.md
│   ├── milestones-crud.md
│   └── targets-read.md
└── tasks.md             # Phase 2 output (not created by /speckit.plan)
```

### Source Code (repository root)

```text
api-reference.md                          # Master API reference (modify Strategy section + Glossary)
skills/strategy/SKILL.md                  # Strategy skill (modify all mutation flows + schemas)
skills/*/references/api-reference.md      # Synced copies (via /sync-plugin)
.claude-plugin/plugin.json                # Version bump (via /sync-plugin)
```

**Structure Decision**: No new files needed. This is a migration of two existing files plus a sync operation. The strategy skill SKILL.md and master api-reference.md are the only files requiring manual edits.

## Key Design Decisions

### 1. Create Flow Redesign

The old API auto-inferred object type from parent position. The new API has typed endpoints. The skill must determine the target type:

| User Intent | Parent | Endpoint | Body |
|-------------|--------|----------|------|
| Create at root (EOS) | none | `POST /teams/{id}/goals` | `name, achieve_by?, assignee_ids?` |
| Create under yearly_goal | goal node | `POST /teams/{id}/rocks` | `name, parent_id?, assignee_ids?` |
| Create under rock | rock node | `POST /teams/{id}/milestones` | `name, parent_id, due?` |
| Explicit "create goal" | ignored | `POST /teams/{id}/goals` | `name, achieve_by?, assignee_ids?` |
| Explicit "create rock" | optional | `POST /teams/{id}/rocks` | `name, parent_id?, assignee_ids?` |
| Explicit "create milestone" | required | `POST /teams/{id}/milestones` | `name, parent_id, due?` |

**EOS-only**: All new endpoints return 422 for non-EOS teams. For non-EOS frameworks (OKR, 4DX), the old `POST /teams/{id}/strategy` is gone. These frameworks will need separate handling or the strategy skill must surface the 422 error.

### 2. Detach/Delete Flow Redesign

The old API had `DELETE /strategy/{type}/{id}` with `parent_id`+`also_archive` semantics. The new API:

- **Unlink (move to unaligned)**: `PATCH /goals/{id}`, `PATCH /rocks/{id}`, or `PATCH /milestones/{id}` with `{ "parent_id": null }`
- **Archive**: `DELETE /goals/{id}`, `DELETE /rocks/{id}`, or `DELETE /milestones/{id}` (archives directly)

The `detach` command should:
- Default (no `--archive`): PATCH to set `parent_id: null` → moves to unaligned
- With `--archive`: DELETE → archives the object

### 3. Align Flow Redesign

The old `PUT /strategy/align` took all four IDs. The new API:
- `PUT /rocks/{id}` with `{ "parent_id": goal_id }` — align rock to goal
- `PUT /milestones/{id}` with `{ "parent_id": rock_id }` — align milestone to rock

Only the child object's ID and the parent's ID are needed. No more `object_type`/`parent_type` params.

### 4. Update Flow Redesign

The old `PATCH /strategy/{objectType}/{objectId}` becomes three typed endpoints. The skill already resolves the object from the tree (which includes `object_type`), so it can route to the correct endpoint:
- `object_type == "yearly_goal"` → `PATCH /goals/{id}`
- `object_type == "rock"` → `PATCH /rocks/{id}`
- `object_type == "milestone"` → `PATCH /milestones/{id}`

### 5. Milestone Filter Workaround

The skill MUST NOT use `?year=&quarter=` when listing milestones due to the known API bug. Instead, use `?parent_id=ROCK_ID` to get milestones under a specific rock. For the tree view, this is not an issue since `GET /teams/{id}/targets` returns the full tree.

### 6. Non-EOS Framework Handling

The 14 new endpoints are EOS-only. For OKR/4DX teams, the old mutation endpoints are gone with no replacement. The strategy skill must:
- Still support `GET /teams/{id}/targets` for all frameworks (read is not EOS-only)
- Surface the 422 "EOS teams only" error clearly when mutations are attempted on non-EOS teams
- The view flow works for all frameworks; only mutation flows are EOS-restricted

## Complexity Tracking

No constitution violations requiring justification.
