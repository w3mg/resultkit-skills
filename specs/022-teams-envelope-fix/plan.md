# Implementation Plan: Teams Envelope Fix & Error Handling Update

**Branch**: `022-teams-envelope-fix` | **Date**: 2026-03-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/022-teams-envelope-fix/spec.md`

## Summary

The ResultMaps API now wraps `GET /teams` in the standard `{ "data": [...] }` envelope (previously a bare array) and returns structured `{ "error": { "code": "internal_error", "message": "..." } }` on 500 errors. Two skills (`rkit:teams`, `rkit:setup`) explicitly parse the teams response as a bare array and will break. This plan updates those skills' parsing instructions, updates api-reference.md to document the envelope and new error code, and syncs shared files.

## Technical Context

**Language/Version**: Bash 5.x (api.sh), Markdown (SKILL.md — Claude Code skill runtime)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), curl, jq
**Storage**: N/A (all data via ResultMaps V2 API)
**Testing**: N/A (manual verification via skill invocation)
**Target Platform**: Claude Code CLI + Gemini CLI
**Project Type**: Plugin skill suite (Markdown + Bash)
**Performance Goals**: N/A (fire-and-forget API call)
**Constraints**: N/A
**Scale/Scope**: 2 SKILL.md edits + 1 api-reference.md update + sync

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | PASS | No new skills — editing existing SKILL.md files |
| II. Self-Contained | PASS | No new dependencies introduced |
| III. Config-Driven | PASS | No config changes |
| IV. Confirm Writes | PASS | No new write operations — changes are in GET response parsing |
| V. Show IDs | PASS | ID display unchanged |
| VI. Framework-Aware | PASS | Framework handling unchanged |
| VII. Direct Execution | PASS | Still uses api.sh via Bash |
| VIII. Graceful Degradation | PASS | Adding 500 internal_error handling improves degradation |
| IX. Concise Output | PASS | Output format unchanged |

**Gate result**: PASS — no violations.

## Project Structure

### Documentation (this feature)

```text
specs/022-teams-envelope-fix/
├── plan.md              # This file
├── research.md          # Phase 0: API behavior verification
├── quickstart.md        # Phase 1: Verification scenarios
├── contracts/           # Phase 1: Updated API contract
│   └── teams-api.md     # GET /teams response contract
└── tasks.md             # Phase 2 output (/speckit:tasks)
```

### Source Code (repository root)

```text
skills/teams/SKILL.md              # Update: parse body.data instead of body
skills/setup/SKILL.md              # Update: parse data envelope during team selection
api-reference.md                   # Update: document data envelope + 500 error
```

**Structure Decision**: No new files created. Three existing files edited in-place. Standard skill-level edits following existing patterns.

## Complexity Tracking

No violations — table not needed.
