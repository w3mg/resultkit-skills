# Implementation Plan: rkit:today

**Branch**: `002-today` | **Date**: 2026-02-15 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/002-today/spec.md`

## Summary

Day plan management skill for viewing, completing, adding, and removing
items from today's plan. Uses the Day Plans API via the shared `api.sh`
script. Primary "start of day" skill — the first skill users run after
`/rkit:setup`.

## Technical Context

**Language/Version**: Bash 5.x (api.sh), Markdown + Claude Code runtime
**Primary Dependencies**: curl, jq, shared `scripts/api.sh`
**Storage**: N/A — reads from ResultMaps API; config at `~/.config/resultkit/config.json`
**Testing**: Manual invocation via `/rkit:today` in Claude Code
**Target Platform**: Claude Code on macOS/Linux
**Project Type**: Single project (skill suite)
**Performance Goals**: API calls return within 5 seconds
**Constraints**: No external runtimes, no package managers, POSIX-compatible paths
**Scale/Scope**: Single-user day plan, typically 3–15 items per day

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| # | Principle | Status | Notes |
|---|-----------|--------|-------|
| I | Claude Code Skill Format | ✅ Pass | SKILL.md entry point, uses shared api.sh |
| II | Self-Contained | ✅ Pass | No project context needed, works from any directory |
| III | Config-Driven | ✅ Pass | Reads token and team from config.json |
| IV | Confirm Writes | ✅ Pass | GET (view) is immediate; POST/PUT/PATCH/DELETE confirm before executing |
| V | Show IDs | ✅ Pass | Item IDs shown in table output and confirmation messages |
| VI | Framework-Aware | ✅ Pass | Day plans are framework-agnostic; no terminology translation needed |
| VII | Direct Execution | ✅ Pass | Bash tool + api.sh for all API calls; no subagents |
| VIII | Graceful Degradation | ✅ Pass | Missing config → /rkit:setup; 404 → item not found; 401 → new token |
| IX | Concise Output | ✅ Pass | Table format for plan view; short confirmations for mutations |

**Gate result**: PASS — no violations.

## Project Structure

### Documentation (this feature)

```text
specs/002-today/
├── plan.md
├── research.md
├── data-model.md
├── quickstart.md
└── contracts/
    ├── get-day-plans-today-items.md
    ├── post-day-plans-today-items.md
    ├── put-day-plans-today-items-id.md
    ├── patch-day-plans-today-items-id.md
    └── delete-day-plans-today-items-id.md
```

### Source Code (repository root)

```text
skills/rkit/today/
├── SKILL.md              # Skill entry point (Claude Code format)
└── references/
    └── api-reference.md  # Copy of API reference
```

**Structure Decision**: Same pattern as `rkit:setup` — SKILL.md with
references directory. No new scripts needed; uses existing `api.sh`.
The install script already handles copying `api.sh` into each skill.

## Complexity Tracking

No constitution violations — section intentionally empty.
