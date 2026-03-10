# Implementation Plan: Monthly Measure Entry

**Branch**: `034-monthly-measure-entry-29` | **Date**: 2026-03-10 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/034-monthly-measure-entry-29/spec.md`

## Summary

Extend `api-reference.md` and `skills/scorecard/SKILL.md` to support monthly scorecard value recording. The upstream API change adds an optional `period` field (`"week"` | `"month"`) to `POST /measures/{id}/history`. The scorecard skill gains a `period=month` flag on the existing `record` command, with a monthly date default and appropriate confirmation/response formatting.

## Technical Context

**Language/Version**: Bash 5.x, Markdown (Claude Code skill runtime)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), `curl`, `jq`, `date`
**Storage**: N/A — all data via ResultMaps V2 API
**Testing**: Manual verification via `scripts/api.sh` against live API
**Target Platform**: Claude Code agent runtime (`SKILL.md` format)
**Project Type**: Single — skill update + reference doc update
**Performance Goals**: N/A (interactive skill, single API call per action)
**Constraints**: Must follow `allowed-tools` frontmatter pattern; POST requires user confirmation per Constitution IV. `Bash(date *)` already in `allowed-tools`.
**Scale/Scope**: 1 skill file (`skills/scorecard/SKILL.md`) + 1 master reference doc (`api-reference.md`)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Check | Notes |
|-----------|-------|-------|
| I. Claude Code Skill Format | ✅ PASS | Updating existing SKILL.md — no new entry points |
| II. Self-Contained | ✅ PASS | No new external dependencies; uses existing api.sh + date |
| III. Config-Driven | ✅ PASS | Auth/base URL from config.json as-is |
| IV. Confirm Writes | ✅ PASS | POST requires confirmation before execute — preserved in updated flow |
| V. Show IDs | ✅ PASS | Measure ID and history ID shown in all record confirmations and results |
| VI. Framework-Aware | ✅ N/A | Period type is not framework-specific |
| VII. Direct Execution | ✅ PASS | Bash + api.sh for all API calls |
| VIII. Graceful Degradation | ✅ PASS | 403, 422, 404 all handled explicitly |
| IX. Concise Output | ✅ PASS | Single-line confirm output; period label in confirmation text |

**Result**: All gates pass. No violations.

## Project Structure

### Documentation (this feature)

```text
specs/034-monthly-measure-entry-29/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── measure-history.md
└── tasks.md             # Phase 2 output (/speckit:tasks)
```

### Source Code (repository root)

```text
api-reference.md                          # Master API reference — update POST /measures/{id}/history row
skills/scorecard/
├── SKILL.md                              # Update argument table + Flow: Record Value
└── references/
    └── api-reference.md                  # Synced copy (updated by /sync-plugin)
```

**Structure Decision**: Single-project update. No new files at repo root. The scorecard skill's existing `record` flow is extended in-place with minimal changes.

## Complexity Tracking

No violations — table omitted.
