# Implementation Plan: Scorecard Skill (rkit:scorecard)

**Branch**: `001-scorecard-skill` | **Date**: 2026-03-05 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-scorecard-skill/spec.md`

## Summary

Add a new `rkit:scorecard` Claude Code skill that lets users view their team's weekly KPI scorecard, record values, and manage measures. Wires to 5 new ResultMaps V2 API endpoints. Follows established rkit skill patterns (seats, board).

## Technical Context

**Language/Version**: Bash 5.x + Markdown (Claude Code skill runtime)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), `jq`, `curl`
**Storage**: N/A — all data via ResultMaps V2 API
**Testing**: Manual invocation via `/rkit:scorecard` in Claude Code
**Target Platform**: Claude Code skill runtime (Linux/macOS)
**Project Type**: Claude Code plugin skill (single SKILL.md + supporting scripts)
**Performance Goals**: API responses confirmed in user-perceived < 3 seconds
**Constraints**: Self-contained per constitution; config-driven; no external binaries beyond `curl`/`jq`
**Scale/Scope**: One new skill directory; 5 new API endpoint wrappers; `api-reference.md` additions

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Requirement | Status |
|-----------|-------------|--------|
| I. Skill Format | `SKILL.md` entry point in `skills/scorecard/` | PASS — will follow `seats` pattern |
| II. Self-Contained | No dependency on other skills | PASS — config + api.sh only |
| III. Config-Driven | Read token + team from `~/.config/resultkit/config.json` | PASS |
| IV. Confirm Writes | POST/PATCH/DELETE require confirmation; GET executes immediately | PASS — will apply per-operation |
| V. Show IDs | Include measure IDs in all output | PASS |
| VI. Framework-Aware | "Scorecard" / "Measures" / "KPIs" — EOS uses "Measurables" | PASS — apply via team `framework` field |
| VII. Direct Execution | Bash + api.sh, no Task agents | PASS |
| VIII. Graceful Degradation | Config missing, 401, 422, API errors handled | PASS |
| IX. Concise Output | Tables + short summaries | PASS |
| *Workflow Note* | Use `/skill-creator` when iterating on SKILL.md quality (not a constitution principle) | Noted in T024 |

No violations. Complexity Tracking not required.

## Project Structure

### Documentation (this feature)

```text
specs/001-scorecard-skill/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── list-measures.md
│   ├── create-measure.md
│   ├── update-measure.md
│   ├── archive-measure.md
│   └── record-history.md
└── tasks.md             # Phase 2 output (/speckit:tasks)
```

### Source Code (repository root)

```text
skills/scorecard/
├── SKILL.md                        # Claude Code skill entry point
├── scripts/
│   └── api.sh                      # Copied from master via sync-plugin
└── references/
    └── api-reference.md            # Copied from master via sync-plugin

api-reference.md                    # Master — add team scorecard measures section
```

**Structure Decision**: Single skill directory under `skills/scorecard/`, matching all existing rkit skills. No new top-level directories needed. Master `api-reference.md` updated with 5 new endpoints, then synced via `/sync-plugin`.
