# Implementation Plan: Strategy Skill (rkit:strategy)

**Branch**: `001-strategy-skill` | **Date**: 2026-03-09 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-strategy-skill/spec.md`

## Summary

Add a new `rkit:strategy` Claude Code skill that lets users view, create, update, align, and detach strategy objects in their team's hierarchical strategy tree. Wires to 5 new ResultMaps V2 API endpoints. Supports all management frameworks (EOS, OKR, 4DX) with framework-aware terminology. Follows established rkit skill patterns (seats, scorecard).

## Technical Context

**Language/Version**: Bash 5.x + Markdown (Claude Code skill runtime)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), `jq`, `curl`
**Storage**: N/A — all data via ResultMaps V2 API
**Testing**: Manual invocation via `/rkit:strategy` in Claude Code
**Target Platform**: Claude Code skill runtime (Linux/macOS)
**Project Type**: Claude Code plugin skill (single SKILL.md + supporting scripts)
**Performance Goals**: API responses confirmed in user-perceived < 3 seconds
**Constraints**: Self-contained per constitution; config-driven; no external binaries beyond `curl`/`jq`
**Scale/Scope**: One new skill directory; 5 new API endpoint wrappers; `api-reference.md` already updated with strategy section

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Requirement | Status |
|-----------|-------------|--------|
| I. Skill Format | `SKILL.md` entry point in `skills/strategy/` | PASS — will follow `seats` pattern |
| II. Self-Contained | No dependency on other skills | PASS — config + api.sh only |
| III. Config-Driven | Read token + team from `~/.config/resultkit/config.json` | PASS |
| IV. Confirm Writes | POST/PUT/PATCH/DELETE require confirmation; GET executes immediately | PASS — will apply per-operation |
| V. Show IDs | Include object IDs and object_types in all output | PASS |
| VI. Framework-Aware | EOS: "Yearly Goals / Rocks / Milestones"; OKR: "Objectives / Rocks / Key Results / Focus Areas" | PASS — derive from `framework` field |
| VII. Direct Execution | Bash + api.sh, no Task agents | PASS |
| VIII. Graceful Degradation | Config missing, 401, 403, 422, API errors handled | PASS |
| IX. Concise Output | Indented tree + short summaries | PASS |

No violations. Complexity Tracking not required.

## Project Structure

### Documentation (this feature)

```text
specs/001-strategy-skill/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   ├── get-strategy.md
│   ├── create-strategy.md
│   ├── update-strategy.md
│   ├── delete-strategy.md
│   └── align-strategy.md
└── tasks.md             # Phase 2 output (/speckit:tasks)
```

### Source Code (repository root)

```text
skills/strategy/
├── SKILL.md                        # Claude Code skill entry point
├── scripts/
│   └── api.sh                      # Copied from master via sync-plugin
└── references/
    └── api-reference.md            # Copied from master via sync-plugin

api-reference.md                    # Master — strategy section already added
```

**Structure Decision**: Single skill directory under `skills/strategy/`, matching all existing rkit skills. No new top-level directories needed. Master `api-reference.md` already updated with 5 strategy endpoints; will sync via `/sync-plugin`.
