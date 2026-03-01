# Implementation Plan: Password Reset Skill

**Branch**: `021-password-reset` | **Date**: 2026-03-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/021-password-reset/spec.md`

## Summary

Minimal `rkit:password-reset` skill for admins to trigger password reset emails. One command, one API call, one confirmation. Also updates api-reference.md with both password endpoints.

## Technical Context

**Language/Version**: Bash 5.x (api.sh), Markdown (SKILL.md — Claude Code skill runtime)
**Primary Dependencies**: curl, jq, `scripts/api.sh` (shared API caller)
**Storage**: N/A (fire-and-forget API call)
**Testing**: Manual verification via API calls
**Target Platform**: Claude Code agent runtime (CLI)
**Project Type**: Single (Claude Code skill)
**Performance Goals**: N/A (single API call)
**Constraints**: Must work from any directory, single config file dependency
**Scale/Scope**: 1 SKILL.md file, 1 api.sh script copy, 1 api-reference.md copy, 1 api-reference.md update at root

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| # | Principle | Status | Notes |
|---|-----------|--------|-------|
| I | Claude Code Skill Format | PASS | SKILL.md entry point |
| II | Self-Contained | PASS | Only depends on config.json |
| III | Config-Driven | PASS | Token from config |
| IV | Confirm Writes | PASS | FR-002 requires confirmation |
| V | Show IDs | PASS | Shows user ID in confirmation |
| VI | Framework-Aware | N/A | No framework terminology |
| VII | Direct Execution | PASS | Bash + api.sh directly |
| VIII | Graceful Degradation | PASS | FR-004 handles all error codes |
| IX | Concise Output | PASS | Single success/error message |

All gates pass.

## Project Structure

### Documentation (this feature)

```text
specs/021-password-reset/
├── spec.md
├── plan.md              # This file
├── research.md          # Phase 0 output
├── quickstart.md        # Phase 1 output
├── contracts/
│   └── password-api.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
skills/password-reset/
├── SKILL.md              # Skill entry point (rkit:password-reset)
├── scripts/
│   └── api.sh            # Shared API caller (copied from root)
└── references/
    └── api-reference.md  # API reference (copied from root)
```

**Structure Decision**: Standard single-skill layout. Minimal SKILL.md with one flow. No data-model.md needed — no persistent entities.
