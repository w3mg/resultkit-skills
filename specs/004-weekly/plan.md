# Implementation Plan: rkit:weekly

**Branch**: `003-board` | **Date**: 2026-02-16 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-weekly/spec.md`
**Status**: Implemented — SKILL.md created and installed

## Summary

Team weekly skill for viewing all four columns (next, done, issues, parked),
viewing a single column, moving items between columns, and adding/removing items.
Column headers use framework-specific terminology based on the team's `framework`
field. Invoked as `/rkit:weekly` or `/rkit:level10` (synonym). Uses the shared
`api.sh` script and follows the same SKILL.md pattern as `rkit:setup` and
`rkit:today`.

## Technical Context

**Language/Version**: Bash 5.x (api.sh), Markdown + Claude Code runtime
**Primary Dependencies**: curl, jq, shared `scripts/api.sh`
**Storage**: N/A — reads from ResultMaps API; config at `~/.config/resultkit/config.json`
**Testing**: Manual invocation via `/rkit:weekly` in Claude Code
**Target Platform**: Claude Code on macOS/Linux
**Project Type**: Single project (skill suite)
**Performance Goals**: API calls return within 5 seconds; 4 parallel column fetches for weekly view
**Constraints**: No external runtimes, no package managers, POSIX-compatible paths
**Scale/Scope**: Team-level weekly, typically 5–30 items across all columns; `per_page=50` cap per column

## Constitution Check

| # | Principle | Status | Notes |
|---|-----------|--------|-------|
| I | Claude Code Skill Format | Pass | SKILL.md entry point, uses shared api.sh |
| II | Self-Contained | Pass | No project context needed, works from any directory |
| III | Config-Driven | Pass | Reads token, team, and api_base from config.json |
| IV | Confirm Writes | Pass | GET (view) immediate; PUT/DELETE confirm before executing |
| V | Show IDs | Pass | Item IDs shown in table output |
| VI | Framework-Aware | Pass | Fetches team framework, maps column headers to framework terms |
| VII | Direct Execution | Pass | Bash tool + api.sh for all API calls; no subagents |
| VIII | Graceful Degradation | Pass | Missing config → /rkit:setup; no team → list teams; 401 → new token |
| IX | Concise Output | Pass | Table format per column; short confirmations for mutations |

**Gate result**: PASS — no violations.

## Project Structure

### Source Code (repository root)

```text
skills/rkit/weekly/
├── SKILL.md              # Skill entry point (Claude Code format)
└── references/
    └── api-reference.md  # Copy of API reference
```

**Structure Decision**: Same pattern as `rkit:setup` and `rkit:today` — SKILL.md
with references directory. The install script will create `rkit:weekly`. A
separate duplicate at install creates the `rkit:level10` synonym.

## Implementation Notes

### 2026-02-16

- SKILL.md created at `skills/rkit/weekly/SKILL.md` with all 5 flows (view weekly, view single column, move, add, remove)
- Installed to `~/.claude/skills/rkit:weekly` via `scripts/install.sh`
- Key design decision: Use status-specific endpoints (`/items/next`, `/items/done`, `/items/issues`, `/items/parked`) NOT the generic `/teams/{id}/items` which returns all 6,041+ items undifferentiated
- Dropped "ask about descriptions" interactive step from US1 — keeps output concise by default
- Level 10 synonym (`rkit:level10`) not yet installed — requires duplicate directory in install script

## Complexity Tracking

No constitution violations — section intentionally empty.
