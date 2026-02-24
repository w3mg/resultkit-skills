# Implementation Plan: rkit:headlines

**Branch**: `013-eos-headlines` | **Date**: 2026-02-24 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/013-eos-headlines/spec.md`

## Summary

Headlines skill for EOS teams that manages People & Customer Headlines via the V2 API. Supports listing active headlines, creating new headlines (with default 7-day expiration), editing text/expiration, and archiving (soft-delete). Follows the same team-scoped pattern as `rkit:weekly` with `--team` flag override and `default_team_id` from config.

## Technical Context

**Language/Version**: Bash 5.x (api.sh), Markdown + Claude Code runtime
**Primary Dependencies**: curl, jq, shared `scripts/api.sh`
**Storage**: `~/.config/resultkit/config.json` (auth + `default_team_id`)
**Testing**: Manual invocation via Claude Code (no automated test framework for skills)
**Target Platform**: macOS / Linux (Claude Code CLI)
**Project Type**: Single (Claude Code skill — SKILL.md + scripts + references)
**Performance Goals**: N/A (interactive, API-latency-bound)
**Constraints**: All operations require 1-2 API calls max. List is a single GET; create/update/archive are single POST/PATCH/DELETE calls.
**Scale/Scope**: Single skill, 4 user scenarios (US1–US4), 12 functional requirements

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | PASS | SKILL.md entry point, Claude Code runtime |
| II. Self-Contained | PASS | No dependency on other rkit skills. Uses api.sh directly for all API calls |
| III. Config-Driven | PASS | Auth from config.json, team ID from `default_team_id` or `--team` flag |
| IV. Confirm Writes | PASS | Create, update, archive all require confirmation before execution |
| V. Show IDs | PASS | Headlines show ID, creator ID in all output |
| VI. Framework-Aware | PASS | Skill is EOS-specific — surfaces clear error for non-EOS teams (422 from API) |
| VII. Direct Execution | PASS | Bash + api.sh, no Task agents or subagents |
| VIII. Graceful Degradation | PASS | Missing config → setup prompt, 401/403/404/422 errors all handled, non-EOS teams get clear message |
| IX. Concise Output | PASS | Table-formatted headline list |

**Result**: All gates PASS. No violations.

## Project Structure

### Documentation (this feature)

```text
specs/013-eos-headlines/
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
skills/headlines/
├── SKILL.md                # Skill entry point (Claude Code skill format)
├── scripts/
│   └── api.sh              # Copy of shared API caller
└── references/
    └── api-reference.md    # Copy of API reference
```

**Structure Decision**: Follows the established pattern from rkit:weekly and rkit:board — SKILL.md in `skills/headlines/` with `scripts/` and `references/` subdirectories. The skill folder name `headlines` produces the invocation `/rkit:headlines` via the plugin namespace.

## Complexity Tracking

No violations — table not needed.
