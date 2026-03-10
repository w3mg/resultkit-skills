# Implementation Plan: Team Logo URL Support

**Branch**: `033-team-logo-url-27` | **Date**: 2026-03-09 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/033-team-logo-url-27/spec.md`

## Summary

Update `api-reference.md` and `skills/teams/SKILL.md` to reflect four team logo URL API changes: `logo_url` field added to team GET responses, `POST /teams/:id/logo` now accepts JSON (breaking change from multipart), and new `DELETE /teams/:id/logo` endpoint. The teams skill gains two new flows: set logo and remove logo.

## Technical Context

**Language/Version**: Bash 5.x, Markdown (Claude Code skill runtime)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), `curl`, `jq`
**Storage**: N/A — all data via ResultMaps V2 API
**Testing**: Manual verification via `scripts/api.sh` against live API
**Target Platform**: Claude Code agent runtime (`SKILL.md` format)
**Project Type**: Single — skill update + reference doc update
**Performance Goals**: N/A (interactive skill, single API call per action)
**Constraints**: Must follow `allowed-tools` frontmatter pattern; POST/DELETE require user confirmation per Constitution IV
**Scale/Scope**: 1 skill file (`skills/teams/SKILL.md`) + 1 master reference doc (`api-reference.md`)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Notes |
|-----------|-------|-------|
| I. Claude Code Skill Format | ✅ PASS | Updating existing SKILL.md — no new entry points |
| II. Self-Contained | ✅ PASS | No new external dependencies; uses existing api.sh |
| III. Config-Driven | ✅ PASS | Auth/base URL from config.json as-is |
| IV. Confirm Writes | ✅ PASS | POST and DELETE logo endpoints require confirmation before execute |
| V. Show IDs | ✅ PASS | Team ID shown in all logo action confirmations and results |
| VI. Framework-Aware | ✅ N/A | Logo URLs are not framework-specific |
| VII. Direct Execution | ✅ PASS | Bash + api.sh for all API calls |
| VIII. Graceful Degradation | ✅ PASS | 403, 422, 404 all handled explicitly |
| IX. Concise Output | ✅ PASS | Logo URL shown in team table; action results are single-line confirms |

**Result**: All gates pass. No violations.

## Project Structure

### Documentation (this feature)

```text
specs/033-team-logo-url-27/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── team-logo.md
└── tasks.md             # Phase 2 output (/speckit:tasks)
```

### Source Code (repository root)

```text
api-reference.md                      # Master API reference — add logo_url field + logo endpoints
skills/teams/
├── SKILL.md                          # Add logo display to team list; add set-logo and remove-logo flows
└── references/
    └── api-reference.md              # Synced copy (updated by /sync-plugin)
```

**Structure Decision**: Single-project update. No new files at repo root beyond the master `api-reference.md`. The teams skill gets new flows inline in its existing SKILL.md.

## Complexity Tracking

No violations — table omitted.
