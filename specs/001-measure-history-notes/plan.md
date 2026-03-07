# Implementation Plan: Measure History Notes

**Branch**: `001-measure-history-notes` | **Date**: 2026-03-07 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-measure-history-notes/spec.md`

## Summary

Add per-week note support to `rkit:scorecard`: a new `note` subcommand to record or clear text notes on measure history slots via `POST /api/v2/measures/:id/history/note`, plus display of notes in the scorecard list view. Update `api-reference.md` (master + skill copy) to document the new endpoint and the updated history slot shape.

## Technical Context

**Language/Version**: Bash 5.x + Markdown (Claude Code skill runtime)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), `jq`, `curl`
**Storage**: N/A — all data via ResultMaps V2 API
**Testing**: Manual API verification with `scripts/api.sh`; acceptance scenario walkthrough
**Target Platform**: Claude Code agent runtime (Linux/macOS)
**Project Type**: Single skill update — no new skill, no new project
**Performance Goals**: No special requirements beyond normal API response times
**Constraints**: Must comply with all nine constitution principles; no raw curl; must use shared api.sh

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | ✅ PASS | Modifying existing `SKILL.md`; stays in Claude Code runtime |
| II. Self-Contained | ✅ PASS | No new external dependencies; uses existing config and api.sh |
| III. Config-Driven | ✅ PASS | Reads token and base URL from `~/.config/resultkit/config.json` |
| IV. Confirm Writes | ✅ PASS | `note record` (POST) will require confirmation; `note clear` (POST with null) also confirms |
| V. Show IDs | ✅ PASS | Will show measure ID in note confirmation and success output |
| VI. Framework-Aware | ✅ PASS | Not directly impacted; existing framework handling unchanged |
| VII. Direct Execution | ✅ PASS | All API calls via `Bash(scripts/api.sh *)` |
| VIII. Graceful Degradation | ✅ PASS | Error handling follows existing patterns in SKILL.md |
| IX. Concise Output | ✅ PASS | Short confirmation and success messages; notes surfaced as table footnotes |

**Gate result**: All principles satisfied. No violations. Proceed to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/001-measure-history-notes/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit:tasks — NOT created by /speckit:plan)
```

### Source Code (repository root)

```text
skills/scorecard/
├── SKILL.md                          # Add: note subcommand flow, note display in list
└── references/
    └── api-reference.md              # Add: POST /measures/:id/history/note, note field on history slots

api-reference.md                      # Master copy — same changes as above
```

**Structure Decision**: Single-skill update. No new files, no new skill directories. Two logical change areas: (1) SKILL.md new flow + list display update, (2) api-reference.md additions. After editing master `api-reference.md`, run `/sync-plugin` to propagate to all skill copies.

## Complexity Tracking

> No constitution violations — section not applicable.
