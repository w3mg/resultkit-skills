# Implementation Plan: rkit:board

**Branch**: `003-board` | **Date**: 2026-02-16 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/003-board/spec.md`

## Summary

Board view skill that renders any item's two-level hierarchy as columns. Children become column headers, grandchildren become items listed under each column. Supports view (full board or single column), move between columns, add to column, and remove from column with interactive destination prompts.

## Technical Context

**Language/Version**: Bash 5.x (api.sh), Markdown + Claude Code runtime
**Primary Dependencies**: curl, jq, shared `scripts/api.sh`
**Storage**: `~/.config/resultkit/config.json` (auth + `default_board_id`)
**Testing**: Manual invocation via Claude Code (no automated test framework for skills)
**Target Platform**: macOS / Linux (Claude Code CLI)
**Project Type**: Single (Claude Code skill — SKILL.md + references)
**Performance Goals**: N/A (interactive, API-latency-bound)
**Constraints**: Board view requires 1 + N API calls (1 for columns + 1 per column for children). Max 11 calls at 10-column cap.
**Scale/Scope**: Single skill, 5 user scenarios (US1–US5), 13 functional requirements

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | PASS | SKILL.md entry point, Claude Code runtime |
| II. Self-Contained | PASS | No dependency on other rkit skills. Day plan API called directly via api.sh for remove flow (not via rkit:today) |
| III. Config-Driven | PASS | Auth from config.json, `default_board_id` added to config schema |
| IV. Confirm Writes | PASS | Move, add, remove all require confirmation before execution |
| V. Show IDs | PASS | Column headers show name + ID, items show name + ID + status + due |
| VI. Framework-Aware | N/A | Board is item-tree based — no framework-specific terminology needed |
| VII. Direct Execution | PASS | Bash + api.sh, no Task agents or subagents |
| VIII. Graceful Degradation | PASS | Missing config, 401, 404, validation errors all handled |
| IX. Concise Output | PASS | Table-formatted output |

**Result**: All gates PASS. No violations.

## Project Structure

### Documentation (this feature)

```text
specs/003-board/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── api-calls.md     # API calls used by this skill
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
skills/rkit/board/
├── SKILL.md                # Skill entry point (Claude Code skill format)
└── references/
    └── api-reference.md    # API reference copy

scripts/
└── api.sh                  # Shared API caller (already exists)
```

**Structure Decision**: Follows the established pattern from rkit:setup and rkit:today — SKILL.md in `skills/rkit/board/` with a `references/` subdirectory. The `install.sh` script already handles copying api.sh into installed skills' `scripts/` directories.

## Complexity Tracking

No violations — table not needed.
