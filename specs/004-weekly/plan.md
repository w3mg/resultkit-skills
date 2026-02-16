# Implementation Plan: rkit:weekly

**Branch**: `004-weekly` | **Date**: 2026-02-15 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/004-weekly/spec.md`

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

## Complexity Tracking

No constitution violations — section intentionally empty.
