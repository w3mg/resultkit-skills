# Implementation Plan: rkit:seats Skill

**Branch**: `024-seats-skill` | **Date**: 2026-03-04 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/024-seats-skill/spec.md`

## Summary

Add a new `rkit:seats` skill for viewing and managing the accountability chart (seats) via the ResultMaps V2 API. The skill supports full CRUD (create, read, update, delete), tree moves, restore, and sub-resource management (measures, goals, links). Built as a Claude Code SKILL.md following existing `rkit:*` patterns with `scripts/api.sh` for API calls.

## Technical Context

**Language/Version**: Bash 5.x (api.sh), Markdown (SKILL.md — Claude Code skill runtime)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), curl, jq
**Storage**: N/A (all data via ResultMaps V2 API)
**Testing**: Manual CLI testing via `/rkit:seats` invocation
**Target Platform**: Claude Code CLI (any OS with bash)
**Project Type**: Single skill (SKILL.md + scripts + references)
**Performance Goals**: Chart display < 5 seconds (single API call fetches full tree)
**Constraints**: HTML stripping for accountabilities via sed; recursive tree rendering via indentation; client-side search (no server-side filtering)
**Scale/Scope**: Single skill with 8+ flows covering all seat operations

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| # | Principle | Status | Notes |
|---|-----------|--------|-------|
| I | Claude Code Skill Format | PASS | SKILL.md entry point, Markdown with embedded tool instructions |
| II | Self-Contained | PASS | Works from any directory, no project context needed |
| III | Config-Driven | PASS | Auth/defaults from `~/.config/resultkit/config.json` |
| IV | Confirm Writes | PASS | GET executes immediately; POST/PUT/PATCH/DELETE require confirmation |
| V | Show IDs | PASS | All entity IDs displayed in output |
| VI | Framework-Aware | PASS | Team framework field used for terminology (accountability chart vs org chart) |
| VII | Direct Execution | PASS | Bash with api.sh, no Task agents |
| VIII | Graceful Degradation | PASS | Missing config → setup, API errors → code + fix |
| IX | Concise Output | PASS | Tree view and tables, no verbose prose |

**Gate result**: ALL PASS — proceed to Phase 0.

## Project Structure

### Documentation (this feature)

```text
specs/024-seats-skill/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── seats-api.md
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
skills/seats/
├── SKILL.md                    # Skill entry point
├── scripts/
│   └── api.sh                  # Copied from root scripts/api.sh
└── references/
    └── api-reference.md        # Copied from root api-reference.md
```

**Structure Decision**: Standard rkit skill layout — single `skills/seats/` directory with SKILL.md, scripts/, and references/ subdirectories. Matches existing skills (result-feed, board, today, etc.).

## Complexity Tracking

No violations — no complexity tracking needed.
