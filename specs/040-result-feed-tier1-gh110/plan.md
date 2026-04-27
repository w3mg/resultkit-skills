# Implementation Plan: Daily Update API v2 — Tier 1 Backend Gap Coverage

**Branch**: `040-result-feed-tier1-gh110` | **Date**: 2026-04-27 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/040-result-feed-tier1-gh110/spec.md`

## Summary

Update `rkit:today` and `rkit:result-feed` skills to handle the breaking section shape change (`done`/`next`/`blocked` are now objects with `items`, `notes`, `attachments` instead of flat arrays). Add 8 new endpoints and update 2 changed endpoints in `api-reference.md` and relevant skill files. All changes follow the Claude Code skill format with `SKILL.md` + `scripts/api.sh`.

## Technical Context

**Language/Version**: Bash 5.x, Markdown (Claude Code skill runtime)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), `curl`, `jq`
**Storage**: N/A — all data via ResultMaps V2 API
**Testing**: Manual via `/rkit:today` and `/rkit:result-feed` invocation against live API
**Target Platform**: Claude Code CLI (any OS with Bash)
**Project Type**: Single (Claude Code plugin)
**Performance Goals**: N/A — skill execution is near-instant
**Constraints**: Skills must be self-contained per Constitution II; all mutations require confirmation per Constitution IV
**Scale/Scope**: 2 skill files to update, 1 master api-reference.md, sync to all skills

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | PASS | All changes are SKILL.md + scripts |
| II. Self-Contained | PASS | No new inter-skill dependencies |
| III. Config-Driven | PASS | Uses existing config.json |
| IV. Confirm Writes | PASS | New PUT/POST endpoints will require confirmation before execution |
| V. Show IDs | PASS | All entity IDs displayed in output |
| VI. Framework-Aware | N/A | No framework-specific terminology in result-feed |
| VII. Direct Execution | PASS | All API calls via Bash + api.sh |
| VIII. Graceful Degradation | PASS | Error handling for 403/404/422/502 responses |
| IX. Concise Output | PASS | Table/summary format preserved |

**Gate result**: PASS — no violations.

## Project Structure

### Documentation (this feature)

```text
specs/040-result-feed-tier1-gh110/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── contracts/           # Phase 1 output
└── tasks.md             # Phase 2 output
```

### Source Code (repository root)

```text
skills/
├── today/
│   ├── SKILL.md              # rkit:today — update section parsing, add notes/attachments display
│   ├── scripts/api.sh        # Shared API caller (synced from root)
│   └── references/
│       └── api-reference.md  # Synced from root
├── result-feed/
│   ├── SKILL.md              # rkit:result-feed — update section parsing, add new commands
│   ├── scripts/api.sh        # Shared API caller (synced from root)
│   └── references/
│       └── api-reference.md  # Synced from root
└── [other skills]/
    └── references/
        └── api-reference.md  # All get synced copy

api-reference.md              # Master — add new endpoints, update section shape docs
scripts/api.sh                # Master — no changes needed (generic caller)
```

**Structure Decision**: Existing plugin structure. Changes touch `skills/today/SKILL.md`, `skills/result-feed/SKILL.md`, and master `api-reference.md` (then synced via `/sync-plugin`).

## Complexity Tracking

No violations — table not needed.
