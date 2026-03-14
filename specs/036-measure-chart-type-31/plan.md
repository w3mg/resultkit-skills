# Implementation Plan: Measure chart_type Field

**Branch**: `036-measure-chart-type-31` | **Date**: 2026-03-13 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/036-measure-chart-type-31/spec.md`

## Summary

Add `chart_type` field support to the `scorecard` and `seats` skills, and document it in `api-reference.md`. The API already returns `chart_type` on all measure responses and accepts it on create/update. This plan is purely additive — no new skills, no new infrastructure, only targeted edits to two SKILL.md files and the master api-reference.md.

## Technical Context

**Language/Version**: Bash 5.x (scripts), Markdown (Claude Code skill runtime)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), `jq`, `curl`
**Storage**: N/A — all data via ResultMaps V2 API
**Testing**: Manual API verification via `scripts/api.sh`
**Target Platform**: Claude Code skill runtime (`~/.claude/skills/`)
**Project Type**: Single project (skill-only edits)
**Performance Goals**: No additional API calls required — `chart_type` is already in all existing measure responses
**Constraints**: Must not break existing `scorecard` or `seats` skill behavior; `chart_type` display is additive
**Scale/Scope**: 2 skills modified, 1 reference file updated, `/sync-plugin` to propagate

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | ✅ PASS | All changes in SKILL.md entry points |
| II. Self-Contained | ✅ PASS | No new cross-skill dependencies |
| III. Config-Driven | ✅ PASS | No hardcoded values introduced |
| IV. Confirm Writes | ✅ PASS | POST/PATCH mutations already confirm; `chart_type` follows same pattern |
| V. Show IDs | ✅ PASS | No change to ID display |
| VI. Framework-Aware | ✅ PASS | `chart_type` is framework-agnostic |
| VII. Direct Execution | ✅ PASS | All API calls via `api.sh` Bash tool |
| VIII. Graceful Degradation | ✅ PASS | Missing/null `chart_type` handled gracefully |
| IX. Concise Output | ✅ PASS | `chart_type` shown only when set (additive column) |

**Result**: No violations. Proceeding to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/036-measure-chart-type-31/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit:tasks)
```

### Source Files (modified, not created)

```text
api-reference.md                          # Master — add chart_type to 4 measure endpoints
skills/scorecard/SKILL.md                 # Add chart_type to display, add, update flows
skills/seats/SKILL.md                     # Add chart_type to seat measure listings

# Propagated by /sync-plugin after api-reference.md update:
skills/*/references/api-reference.md      # All copies updated automatically
```

---

## Phase 0: Research

### Unknowns to Resolve

1. Does `GET /seats/{id}/measures` return `chart_type` per measure, or only the basic `{id, name, description}` shape seen in seat detail?
2. Does the PATCH body correctly preserve `chart_type` when the key is omitted (vs. sent as null)?
3. What does the API actually return on a 422 for invalid `chart_type`?

### Research Tasks

**Task R1 — Verify GET /teams/{id}/measures response includes chart_type**

```bash
scripts/api.sh GET "/teams/$(jq -r .default_team_id ~/.config/resultkit/config.json)/measures" | jq '.data[0] | {id, name, chart_type}'
```

**Task R2 — Verify GET /seats/{id}/measures response shape**

```bash
# Get a seat ID first, then check its measures endpoint
scripts/api.sh GET "/teams/$(jq -r .default_team_id ~/.config/resultkit/config.json)/seats" | jq '.data[0].id'
# Then: scripts/api.sh GET "/seats/{id}/measures" | jq '.data[0] | keys'
```

**Task R3 — Verify PATCH preserves chart_type when key omitted**

Send a PATCH with only `name` and verify `chart_type` is unchanged in the response.

**Task R4 — Verify 422 error message format for invalid chart_type**

```bash
scripts/api.sh POST "/teams/$(jq -r .default_team_id ~/.config/resultkit/config.json)/measures" \
  '{"measure":{"name":"test-chart-type-invalid","chart_type":"invalid_value"}}' | jq .
```

*Note: No live config available in dev environment. All four questions resolved from authoritative API change spec (issue #31). See [research.md](research.md).*

---

## Phase 1: Design & Contracts

See [data-model.md](data-model.md) and [quickstart.md](quickstart.md) for full design detail.

### Touch Points

| File | Change | Scope |
|------|--------|-------|
| `api-reference.md` | Add `chart_type` to 4 endpoints + validation note | Master — propagated via `/sync-plugin` |
| `skills/scorecard/SKILL.md` | Display, add, update `chart_type` | 3 flows updated |
| `skills/seats/SKILL.md` | Show `chart_type` in post-alignment measure list | 1 flow updated |

### Constitution Re-check (post-design)

All principles pass. Changes are purely additive. No new write paths, no new deps, no hardcoded values. Confirm Writes (IV) unaffected — `chart_type` is passed as part of the existing confirmed mutation flows.
