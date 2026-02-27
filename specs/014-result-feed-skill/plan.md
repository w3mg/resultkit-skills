# Implementation Plan: rkit:result-feed Skill

**Branch**: `014-result-feed-skill` | **Date**: 2026-02-26 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/014-result-feed-skill/spec.md`

## Summary

Add a new `rkit:result-feed` skill for managing daily check-in reports (the "90-second practice") via the ResultMaps V2 API. The skill covers viewing, building, submitting, and sharing result feeds — plus viewing team check-ins. Implementation requires first updating `api-reference.md` with the Result Feeds endpoints, syncing shared files, then creating the skill directory with SKILL.md following established rkit patterns.

## Technical Context

**Language/Version**: Bash 5.x (api.sh), Markdown (SKILL.md — Claude Code skill runtime)
**Primary Dependencies**: curl, jq, `scripts/api.sh` (shared API caller)
**Storage**: `~/.config/resultkit/config.json` (user config with token + default_team_id)
**Testing**: Manual invocation via `/rkit:result-feed` in Claude Code
**Target Platform**: Claude Code CLI (cross-platform via Bash)
**Project Type**: Claude Code plugin skill (Markdown + Bash scripts)
**Performance Goals**: N/A — bounded by API response time
**Constraints**: Must follow existing skill patterns; api-reference.md must be updated first; API not yet deployed to production
**Scale/Scope**: Single skill (SKILL.md + shared scripts/references)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | PASS | SKILL.md entry point, Claude Code runtime, api.sh as supporting script |
| II. Self-Contained | PASS | No dependency on other rkit skills; only needs config.json |
| III. Config-Driven | PASS | Reads api_token, default_team_id, api_base from config |
| IV. Confirm Writes | PASS | FR-009 requires confirmation for POST/PUT/DELETE |
| V. Show IDs | PASS | FR-011 requires item IDs in all output |
| VI. Framework-Aware | N/A | Result feeds are framework-agnostic (not column-name dependent) |
| VII. Direct Execution | PASS | Uses Bash + api.sh, no Task agents |
| VIII. Graceful Degradation | PASS | Edge cases cover missing config, 401, 404, missing default team |
| IX. Concise Output | PASS | Tables and short summaries per spec |

**Gate result**: PASS — all applicable principles satisfied.

## Project Structure

### Documentation (this feature)

```text
specs/014-result-feed-skill/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── result-feed-api.md
└── checklists/
    └── requirements.md  # Spec quality checklist
```

### Source Code (repository root)

```text
skills/result-feed/
├── SKILL.md                      # Skill entry point (Claude Code runtime)
├── scripts/
│   └── api.sh                    # Copied from master scripts/api.sh
└── references/
    └── api-reference.md          # Copied from master api-reference.md

api-reference.md                  # Master — updated with Result Feeds section
```

**Structure Decision**: Follows the established rkit skill directory convention. Each skill gets its own directory under `skills/` with SKILL.md, scripts/, and references/. The plugin.json auto-discovers all skills from `./skills/`.

## Constitution Re-Check (Post Phase 1 Design)

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | PASS | SKILL.md entry point confirmed in project structure |
| II. Self-Contained | PASS | No cross-skill dependencies in any design artifact |
| III. Config-Driven | PASS | Submit flow reads default_team_id; all auth via config |
| IV. Confirm Writes | PASS | All write flows include confirmation step in design |
| V. Show IDs | PASS | ItemSimple format (ID + name) used everywhere |
| VI. Framework-Aware | N/A | Result feeds don't use framework-specific column names |
| VII. Direct Execution | PASS | All flows use Bash + api.sh |
| VIII. Graceful Degradation | PASS | Missing default_team_id prompts user; all error states handled |
| IX. Concise Output | PASS | Tables and short summaries in all display flows |

**Post-design gate result**: PASS — no regressions from Phase 1 design decisions.

## Complexity Tracking

No constitution violations — table not needed.
