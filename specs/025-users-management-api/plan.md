# Implementation Plan: Users Management API Endpoints

**Branch**: `025-users-management-api` | **Date**: 2026-03-04 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/025-users-management-api/spec.md`

## Summary

14 new V2 user management endpoints are added to api-reference.md with full documentation and glossary phrases. A new `rkit:profile` skill is created to surface user stats, preferences (view/update), password change, and account member management. Measurables, rocks, feedback, integrations, progress dashboard, and login-check are documented only — no skill flows.

## Technical Context

**Language/Version**: Bash 5.x (api.sh), Markdown (SKILL.md — Claude Code skill runtime)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), curl, jq
**Storage**: N/A (all data via ResultMaps V2 API)
**Testing**: N/A (manual verification via skill invocation)
**Target Platform**: Claude Code CLI + Gemini CLI
**Project Type**: Plugin skill suite (Markdown + Bash)
**Performance Goals**: N/A (fire-and-forget API calls)
**Constraints**: N/A
**Scale/Scope**: 1 api-reference.md update + 1 new SKILL.md (rkit:profile)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | PASS | New SKILL.md follows standard format |
| II. Self-Contained | PASS | New skill uses only api.sh and config.json |
| III. Config-Driven | PASS | No hardcoded values; reads config.json |
| IV. Confirm Writes | PASS | PATCH preferences, PATCH password, DELETE account member all require confirmation; GET stats is immediate |
| V. Show IDs | PASS | User ID, account ID, member IDs shown in all output |
| VI. Framework-Aware | PASS | Stats/preferences/password are user-scoped, not framework-dependent; no mapping needed |
| VII. Direct Execution | PASS | Uses api.sh via Bash |
| VIII. Graceful Degradation | PASS | Handles 401, 403, 404, 422 for all flows |
| IX. Concise Output | PASS | Tables for members, short summaries for stats and preferences |

**Gate result**: PASS — no violations.

## Project Structure

### Documentation (this feature)

```text
specs/025-users-management-api/
├── plan.md              # This file
├── research.md          # Phase 0: Decisions
├── quickstart.md        # Phase 1: Verification scenarios
├── contracts/           # Phase 1: API contracts
│   └── profile-skill-contract.md
└── tasks.md             # Phase 2 output (/speckit:tasks)
```

### Source Code (repository root)

```text
api-reference.md                     # Update: add 14 new user endpoints + glossary
skills/profile/SKILL.md              # NEW: rkit:profile skill
skills/profile/scripts/api.sh        # Copied from scripts/api.sh (shared)
skills/profile/references/api-reference.md  # Copied from api-reference.md (shared)
```

**Structure Decision**: One new skill directory (`skills/profile/`) following the same layout as `skills/teams/`. api-reference.md is updated as the master source. The shared api.sh and api-reference.md copies are distributed by the existing `/sync-plugin` flow.

## Complexity Tracking

No violations — table not needed.
