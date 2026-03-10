# Implementation Plan: Strategy API Phase 2 Update

**Branch**: `032-strategy-api-phase2-26` | **Date**: 2026-03-08 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/032-strategy-api-phase2-26/spec.md`

## Summary

Update `api-reference.md` to document the Phase 2 strategy endpoints, and integrate the `rkit:strategy` skill (already built and Phase 2 compliant on `origin/001-strategy-skill`) into the plugin distribution on main. No changes required to the strategy skill itself — it was authored against the Phase 2 API contract.

## Technical Context

**Language/Version**: Bash 5.x (api.sh), Markdown (Claude Code skill format)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), `jq`, `curl`
**Storage**: N/A — all data via ResultMaps V2 API
**Testing**: Manual — invoke skill and verify API call bodies/params
**Target Platform**: Claude Code plugin runtime (`~/.claude/skills/`)
**Project Type**: Single project (skill suite)
**Performance Goals**: N/A (skill runtime, not server)
**Constraints**: All Phase 2 breaking changes must be reflected; no deprecated params in any call
**Scale/Scope**: One new skill (`rkit:strategy`), one api-reference.md section (~50 lines)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | ✅ PASS | strategy uses SKILL.md entry point |
| II. Self-Contained | ✅ PASS | strategy skill has its own api.sh copy |
| III. Config-Driven | ✅ PASS | reads `~/.config/resultkit/config.json` |
| IV. Confirm Writes | ✅ PASS | POST/PUT/PATCH/DELETE all require confirmation |
| V. Show IDs | ✅ PASS | all responses show `#{id}` |
| VI. Framework-Aware | ✅ PASS | 4DX/OKR/EOS label mapping in SKILL.md |
| VII. Direct Execution | ✅ PASS | uses `Bash(scripts/api.sh *)` only |
| VIII. Graceful Degradation | ✅ PASS | error handling table in SKILL.md |
| IX. Concise Output | ✅ PASS | indented tree + short summaries |

**Post-design re-check**: All principles pass. No violations.

## Project Structure

### Documentation (this feature)

```text
specs/032-strategy-api-phase2-26/
├── plan.md              # This file
├── spec.md              # Feature spec
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/
│   └── strategy-endpoints.md   # Phase 2 endpoint contracts
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output (/speckit:tasks)
```

### Source Code (repository root)

```text
api-reference.md                        # Master — add Strategy section
scripts/api.sh                          # No changes needed

skills/strategy/                        # NEW — integrate from 001-strategy-skill
├── SKILL.md
├── scripts/
│   └── api.sh
└── references/
    └── api-reference.md

.claude-plugin/
└── plugin.json                         # Add strategy to skills list
```

**Structure Decision**: Single project. The only source changes are:
1. `api-reference.md` — add strategy endpoint section
2. `skills/strategy/` — copy from `origin/001-strategy-skill`
3. `.claude-plugin/plugin.json` — add strategy skill entry

## Implementation Phases

### Phase A: Update api-reference.md

Add a Strategy section documenting all 8 Phase 2 endpoint variants (5 distinct routes, some with both team-less and team-scoped forms). Reference `contracts/strategy-endpoints.md` for content. Include:
- GET /teams/{id}/strategy (no `cascade` param)
- POST /teams/{id}/strategy (no `object_type`, add `is_focus_area`)
- PUT /strategy/align (team-less, no `link_type`)
- PATCH /strategy/{type}/{id} (team-less)
- DELETE /strategy/{type}/{id} (requires `parent_id`+`parent_type` in body, `also_archive` instead of `?action=`)
- Note deprecated team-scoped equivalents where applicable

### Phase B: Integrate strategy skill

Cherry-pick or copy `skills/strategy/` from `origin/001-strategy-skill` to this branch. Add the skill to `.claude-plugin/plugin.json`.

### Phase C: Sync and ship

Run `/sync-plugin` to propagate updated `api-reference.md` to all skill copies. Bump plugin version. Commit and push.
