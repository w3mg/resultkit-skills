# Implementation Plan: Fix 1on1 Skill API Endpoints

**Branch**: `001-fix-1on1-endpoints-gh97` | **Date**: 2026-04-22 | **Spec**: [spec.md](spec.md)

## Summary

The `rkit:1on1` skill calls `/meetings` endpoints that don't exist in the V2 API. All calls return 404. The fix is to update the skill to call the real `/1-on-1` endpoints, correct the filter parameter (`team_id` → `group_id`), fix response parsing for nested `persons` and `items` objects, and update both copies of `api-reference.md`.

## Technical Context

**Language/Version**: Bash 5.x (scripts), Markdown (Claude Code skill runtime)  
**Primary Dependencies**: curl, jq, `scripts/api.sh` (shared API caller)  
**Storage**: N/A — all data via ResultMaps V2 API  
**Testing**: Manual CLI testing against live API  
**Target Platform**: Claude Code skill runtime (Linux/macOS)  
**Project Type**: Single skill (Claude Code SKILL.md format)  
**Performance Goals**: Standard interactive API latency (no change from current)  
**Constraints**: Self-contained per constitution; no dependencies beyond `~/.config/resultkit/config.json`  
**Scale/Scope**: 2–3 files changed; no new pages, routes, or skills

## Constitution Check

*GATE: Must pass before Phase 0 research.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | ✅ Pass | SKILL.md stays as entry point; format unchanged |
| II. Self-Contained | ✅ Pass | No new external dependencies introduced |
| III. Config-Driven | ✅ Pass | Existing config.json usage unchanged |
| IV. Confirm Writes | ✅ Pass | Confirmation behavior preserved; only endpoint paths change |
| V. Show IDs | ✅ Pass | ID display logic unchanged |
| VI. Framework-Aware | N/A | No framework terminology involved |
| VII. Direct Execution | ✅ Pass | Continues using Bash + api.sh directly |
| VIII. Graceful Degradation | ✅ Pass | Error handling preserved |
| IX. Concise Output | ✅ Pass | Output format unchanged |

**Constitution note**: The constitution's status values list (`not_started`, `next`, `parked`, `blocked`, `done`, `archived`, `draft`) is for the general items API. The 1on1 items endpoint uses different status values (`active`, `realized`) — this is consistent with the API having separate conventions for meeting items. See research.md for details.

**Gate result**: ✅ All applicable principles pass. No violations.

## Project Structure

### Documentation (this feature)

```text
specs/001-fix-1on1-endpoints-gh97/
├── plan.md              ← this file
├── research.md          ← Phase 0 output
├── data-model.md        ← Phase 1 output
└── tasks.md             ← Phase 2 output (/speckit:tasks)
```

### Source Code (files changed)

```text
skills/1on1/
├── SKILL.md                      ← update all endpoint paths + response parsing
└── references/
    └── api-reference.md          ← rewrite 1on1/meetings section

api-reference.md                  ← root master — rewrite 1on1/meetings section
```

**Structure Decision**: Single-skill fix. No new files created. `skills/1on1/scripts/api.sh` is a copy of the root `scripts/api.sh` — no 1on1-specific overrides exist, so it needs no changes. The root `scripts/api.sh` also needs no changes.

## Complexity Tracking

No constitution violations — this section is not applicable.
