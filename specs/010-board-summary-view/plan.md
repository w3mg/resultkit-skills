# Implementation Plan: Board Summary View

**Branch**: `010-board-summary-view` | **Date**: 2026-02-18 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/010-board-summary-view/spec.md`

## Summary

Modify the rkit:board "View Board" flow (Steps 2–3 in SKILL.md) to display a column summary table first, then prompt the user to drill into one column, all columns, or none. This replaces the current behavior of eagerly fetching and displaying all items for every column.

## Technical Context

**Language/Version**: Bash 5.x (api.sh), Markdown + Claude Code runtime
**Primary Dependencies**: curl, jq, shared `scripts/api.sh`
**Storage**: N/A — reads from ResultMaps API; config at `~/.config/resultkit/config.json`
**Testing**: Manual invocation of `/rkit:board` against live API
**Target Platform**: Claude Code CLI (macOS/Linux)
**Project Type**: Single (Claude Code skill)
**Performance Goals**: N/A — interactive CLI skill
**Constraints**: Minimize API calls during summary display
**Scale/Scope**: Modification to one flow in one skill file (`skills/rkit/board/SKILL.md`)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | Pass | Modifies existing SKILL.md — no format change |
| II. Self-Contained | Pass | No new dependencies introduced |
| III. Config-Driven | Pass | No config changes |
| IV. Confirm Writes | Pass | This change is read-only (GET requests only) |
| V. Show IDs | Pass | Summary table includes column IDs |
| VI. Framework-Aware | N/A | No framework terminology changes |
| VII. Direct Execution | Pass | All API calls through api.sh via Bash tool |
| VIII. Graceful Degradation | Pass | Inherits existing error handling |
| IX. Concise Output | Pass | Summary table is more concise than full dump |

All gates pass. No violations.

## Project Structure

### Documentation (this feature)

```text
specs/010-board-summary-view/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── api-calls.md
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
skills/rkit/board/
└── SKILL.md             # Only file modified — "Flow: View Board" section
```

**Structure Decision**: No new files or directories. This feature modifies the "Flow: View Board" section (Steps 2–3) of the existing `skills/rkit/board/SKILL.md`. The installed copy at `~/.claude/skills/rkit:board/SKILL.md` will be updated via `scripts/install.sh`.
