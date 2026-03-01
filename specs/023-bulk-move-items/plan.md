# Implementation Plan: Bulk Move Items

**Branch**: `023-bulk-move-items` | **Date**: 2026-03-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/023-bulk-move-items/spec.md`

## Summary

A new `PATCH /items/bulk-move` endpoint allows moving up to 1000 items under a target parent in one request. This plan adds the endpoint to api-reference.md, adds a `bulk-move` flow to the existing `rkit:board` skill, and syncs shared files. The skill confirms the action, executes the bulk move, and reports moved/failed counts with per-item error details.

## Technical Context

**Language/Version**: Bash 5.x (api.sh), Markdown (SKILL.md — Claude Code skill runtime)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), curl, jq
**Storage**: N/A (all data via ResultMaps V2 API)
**Testing**: N/A (manual verification via skill invocation)
**Target Platform**: Claude Code CLI + Gemini CLI
**Project Type**: Plugin skill suite (Markdown + Bash)
**Performance Goals**: N/A (fire-and-forget API call)
**Constraints**: N/A
**Scale/Scope**: 1 SKILL.md edit (add flow) + 1 api-reference.md update + sync

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | PASS | Adding flow to existing SKILL.md |
| II. Self-Contained | PASS | No new dependencies |
| III. Config-Driven | PASS | No config changes |
| IV. Confirm Writes | PASS | Bulk-move is a write (PATCH) — confirmation required before execution |
| V. Show IDs | PASS | Item IDs shown in confirmation and result |
| VI. Framework-Aware | PASS | Not framework-specific — operates on item IDs |
| VII. Direct Execution | PASS | Uses api.sh via Bash |
| VIII. Graceful Degradation | PASS | Handles 401, 403, 404, 422 + partial failures |
| IX. Concise Output | PASS | Summary counts + error table |

**Gate result**: PASS — no violations.

## Project Structure

### Documentation (this feature)

```text
specs/023-bulk-move-items/
├── plan.md              # This file
├── research.md          # Phase 0: Behavior verification
├── quickstart.md        # Phase 1: Verification scenarios
├── contracts/           # Phase 1: API contract
│   └── bulk-move-api.md # PATCH /items/bulk-move contract
└── tasks.md             # Phase 2 output (/speckit:tasks)
```

### Source Code (repository root)

```text
skills/board/SKILL.md              # Update: add bulk-move flow + argument parsing entry
api-reference.md                   # Update: add PATCH /items/bulk-move endpoint
```

**Structure Decision**: No new files created. Two existing files edited in-place. The bulk-move flow is added to the board skill which already handles item hierarchy operations (move, add, remove).

## Complexity Tracking

No violations — table not needed.
