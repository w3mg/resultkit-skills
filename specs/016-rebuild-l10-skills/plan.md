# Implementation Plan: Rebuild Skills with Skill Creator & L10 Route Coverage

**Branch**: `016-rebuild-l10-skills` | **Date**: 2026-02-28 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/016-rebuild-l10-skills/spec.md`

## Summary

Create a new `rkit:level10` skill that provides a complete EOS Level 10 workflow using L10-specific API routes (with generic fallback for operations L10 routes don't support). Rebuild all 11 existing skills through Skill Creator per Constitution Section X. Update `rkit:weekly` and `rkit:headlines` to prefer L10 routes for EOS teams.

## Technical Context

**Language/Version**: Bash 5.x (api.sh), Markdown (SKILL.md — Claude Code skill runtime)
**Primary Dependencies**: curl, jq, `scripts/api.sh` (shared API caller)
**Storage**: `~/.config/resultkit/config.json` (user config with token + default_team_id)
**Testing**: Skill Creator evals (behavioral benchmarking via `/skill-creator`)
**Target Platform**: Claude Code CLI (macOS/Linux)
**Project Type**: Plugin — Markdown skills + Bash helper scripts
**Performance Goals**: N/A — CLI tool, API latency-bound
**Constraints**: Self-contained per skill, no inter-skill dependencies, all constitution rules enforced
**Scale/Scope**: 12 skills (11 existing + 1 new level10)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| # | Principle | Status | Notes |
|---|-----------|--------|-------|
| I | Claude Code Skill Format | PASS | All skills are SKILL.md files with Markdown + embedded Bash |
| II | Self-Contained | PASS | Each skill works from any directory; no inter-skill deps |
| III | Config-Driven | PASS | Auth/defaults via config.json; never hardcoded |
| IV | Confirm Writes | PASS | FR-012 explicitly requires write confirmation in level10; all skills follow this |
| V | Show IDs | PASS | FR-009 requires all skills show entity IDs |
| VI | Framework-Aware | PASS | Core to this feature — level10 is EOS-specific; weekly/headlines get L10 route awareness |
| VII | Direct Execution | PASS | All skills use Bash + api.sh directly; no Task agents |
| VIII | Graceful Degradation | PASS | All skills handle missing config, 401, 404, 422 errors |
| IX | Concise Output | PASS | Tables and short summaries; no prose |
| X | Use Skill Builder | PASS | FR-005 mandates Skill Creator for all 12 skills |

**Gate result: PASS — no violations.**

## Project Structure

### Documentation (this feature)

```text
specs/016-rebuild-l10-skills/
├── spec.md              # Feature specification
├── plan.md              # This file
├── research.md          # Phase 0: L10 route mapping & rebuild strategy
├── data-model.md        # Phase 1: Entity/route mapping for level10 skill
├── quickstart.md        # Phase 1: How to build and test
├── contracts/           # Phase 1: Skill interface definitions
│   └── level10-interface.md
└── tasks.md             # Phase 2 output (/speckit.tasks — NOT created here)
```

### Source Code (repository root)

```text
skills/
├── level10/              # NEW — P1: EOS Level 10 skill
│   ├── SKILL.md          #   Entry point (built via Skill Creator)
│   ├── scripts/
│   │   └── api.sh        #   Shared API caller (synced from root)
│   └── references/
│       └── api-reference.md  # API reference (synced from root)
├── weekly/               # P2/P3: Rebuild + add L10 route awareness for EOS
│   └── SKILL.md
├── headlines/            # P2/P3: Rebuild + add L10 route awareness for EOS
│   └── SKILL.md
├── board/                # P2: Rebuild via Skill Creator
├── braindump/            # P2: Rebuild via Skill Creator
├── setup/                # P2: Rebuild via Skill Creator
├── teams/                # P2: Rebuild via Skill Creator
├── 1on1/                 # P2: Rebuild via Skill Creator
├── projects/             # P2: Rebuild via Skill Creator
├── result-feed/          # P2: Rebuild via Skill Creator
├── result-update/        # P2: Rebuild via Skill Creator
└── today/                # P2: Rebuild via Skill Creator

.claude-plugin/
└── plugin.json           # Version bump after changes
```

**Structure Decision**: Plugin skill structure — each skill is a self-contained directory under `skills/` with SKILL.md + scripts/ + references/. No traditional src/tests layout. The new `level10` directory follows the same pattern as all existing skills.

## Complexity Tracking

No constitution violations to justify. All designs fit within existing patterns.
