# Implementation Plan: Update Skills to Reflect Latest Endpoints

**Branch**: `017-update-skill-endpoints` | **Date**: 2026-02-28 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/017-update-skill-endpoints/spec.md`

## Summary

Add missing L10 board sections (parked, done, remove) to `rkit:level10` and update both `rkit:level10` and `rkit:weekly` to use L10-specific API routes consistently for EOS teams. Two skills modified, zero new skills created.

## Technical Context

**Language/Version**: Bash 5.x (api.sh helper), Markdown (SKILL.md — Claude Code skill runtime)
**Primary Dependencies**: curl, jq, `scripts/api.sh` (shared API caller)
**Storage**: N/A (all data via ResultMaps V2 API)
**Testing**: Manual invocation + skill evals (via `/skill-creator`)
**Target Platform**: Claude Code agent runtime (macOS/Linux/zsh/bash)
**Project Type**: Plugin skills (Markdown + Bash scripts)
**Performance Goals**: N/A (API response latency only)
**Constraints**: Skills must be self-contained SKILL.md files; no external runtimes
**Scale/Scope**: 2 skills modified (`rkit:level10`, `rkit:weekly`), 0 new skills

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | PASS | Both skills are SKILL.md files with Bash tool-use instructions |
| II. Self-Contained | PASS | No cross-skill dependencies introduced |
| III. Config-Driven | PASS | Uses existing `~/.config/resultkit/config.json` |
| IV. Confirm Writes | PASS | All new write flows (park, remove) will describe action and confirm |
| V. Show IDs | PASS | All entity output includes numeric IDs |
| VI. Framework-Aware | PASS | L10 skill is EOS-only; weekly uses framework→terminology mapping |
| VII. Direct Execution | PASS | All API calls via Bash + api.sh directly |
| VIII. Graceful Degradation | PASS | Error handling patterns carried forward from existing flows |
| IX. Concise Output | PASS | Table format and short summaries maintained |

**Gate result**: PASS — no violations.

## Project Structure

### Documentation (this feature)

```text
specs/017-update-skill-endpoints/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output (endpoint contract diffs)
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 output (via /speckit.tasks)
```

### Source Code (repository root)

```text
skills/
├── level10/
│   └── SKILL.md          # Modified: add parked/done/remove flows, L10 routes for PUT
└── weekly/
    └── SKILL.md          # Modified: L10 Route Selection table update
```

**Structure Decision**: No new files created. Two existing SKILL.md files are modified in-place. No structural changes to the repo.

## Complexity Tracking

No constitution violations — this section is empty by design.
