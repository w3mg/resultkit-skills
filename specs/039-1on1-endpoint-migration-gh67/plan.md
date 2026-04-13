# Implementation Plan: Update rkit:1on1 Skill to New API Endpoints

**Branch**: `039-1on1-endpoint-migration-gh67` | **Date**: 2026-04-13 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/039-1on1-endpoint-migration-gh67/spec.md`

## Summary

The ResultMaps API has renamed all `/api/v2/meetings/*` routes to `/api/v2/1-on-1/*` and deleted the old routes. The `rkit:1on1` skill (`skills/1on1/SKILL.md`) calls `/meetings/...` throughout — making every flow broken. This plan migrates all endpoint paths in the skill and the shared `api-reference.md` to the new `/1-on-1/...` paths. It also adds a `notes` flow using the new `PUT /1-on-1/{id}/notes` endpoint.

## Technical Context

**Language/Version**: Bash 5.x (scripts), Markdown (Claude Code skill format)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), `curl`, `jq`
**Storage**: N/A — stateless API calls; config at `~/.config/resultkit/config.json`
**Testing**: Manual API verification via `scripts/api.sh` before coding (per CLAUDE.md rules)
**Target Platform**: Claude Code skill runtime (`~/.claude/skills/`)
**Project Type**: Single skill update — `SKILL.md` + shared `api-reference.md`
**Performance Goals**: N/A
**Constraints**: Must comply with all 9 constitution principles; must verify live API before writing skill logic
**Scale/Scope**: 1 SKILL.md file + 1 master api-reference.md + sync to all skill copies

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | ✅ Pass | `SKILL.md` remains the entry point; no new binaries |
| II. Self-Contained | ✅ Pass | Skill uses its own `scripts/api.sh` copy |
| III. Config-Driven | ✅ Pass | Auth/base URL read from `~/.config/resultkit/config.json` |
| IV. Confirm Writes | ✅ Pass | Notes save (PUT) must confirm before executing |
| V. Show IDs | ✅ Pass | All output tables include entity IDs |
| VI. Framework-Aware | ✅ N/A | 1:1 meetings are not framework-specific concepts |
| VII. Direct Execution | ✅ Pass | Bash + api.sh directly; no subagents |
| VIII. Graceful Degradation | ✅ Pass | Existing error handling patterns preserved |
| IX. Concise Output | ✅ Pass | Tables and short summaries; no verbose prose |

No violations. Proceed.

## Project Structure

### Documentation (this feature)

```text
specs/039-1on1-endpoint-migration-gh67/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── spec.md              # Feature spec
├── checklists/
│   └── requirements.md  # Spec quality checklist
└── tasks.md             # Phase 2 output (created by /speckit:tasks)
```

### Source Code (repository root)

```text
skills/1on1/
├── SKILL.md             # Primary change — replace /meetings/* paths
└── scripts/api.sh       # Shared copy (updated via /sync-plugin)

api-reference.md         # Master API reference — replace /meetings section
scripts/api.sh           # Master API caller script
.claude-plugin/
└── plugin.json          # Version bump required
```

After editing master files, `/sync-plugin` propagates `api-reference.md` to all `skills/*/references/api-reference.md` copies.

## Complexity Tracking

> No constitution violations — table not required.

---

## Phase 0: Research

**Output**: `research.md`

### Research Tasks

1. **Verify live API endpoint shapes** — per CLAUDE.md rules, call the actual API before writing skill logic. Confirm:
   - `GET /1-on-1` returns the same envelope shape as old `GET /meetings`
   - `GET /1-on-1/{id}` returns `persons`, `items.done/next/blocked`, `notes` fields
   - `POST /1-on-1/{id}/items` and `DELETE /1-on-1/{id}/items/{id}` behave identically to old equivalents
   - `PUT /1-on-1/{id}/notes` request body shape and success response

2. **Check for any other `/meetings` references** in skill files or specs that need updating.

---

## Phase 1: Design & Contracts

**Prerequisites**: research.md complete

### Endpoint Mapping (no new data model — pure path rename)

| Old Path | New Path | Method | Skill Flow |
|----------|----------|--------|-----------|
| `/meetings` | `/1-on-1` | GET | List One-on-Ones |
| `/meetings?team_id=X` | `/1-on-1?team_id=X` | GET | List with team filter |
| `/meetings/{id}` | `/1-on-1/{id}` | GET | View Detail |
| `/meetings/{id}/items/{section}` | `/1-on-1/{id}/items/{section}` | GET | View Single Column |
| `/meetings/{id}/items` | `/1-on-1/{id}/items` | POST | Add New Item |
| `/meetings/{id}/items/{item_id}` | `/1-on-1/{id}/items/{item_id}` | PUT | Attach Existing Item |
| `/meetings/{id}/items/{item_id}` | `/1-on-1/{id}/items/{item_id}` | DELETE | Remove Item |
| *(new)* | `/1-on-1/{id}/notes` | PUT | Save Notes |

### Notes Flow Design

**Trigger**: `{meeting_id} notes "text"`

1. Confirm: "Save notes to one-on-one {id}? (This will overwrite existing notes.)"
2. Execute: `PUT /1-on-1/{meeting_id}/notes` with body `{"notes": "TEXT"}`
3. On 200: "Notes saved to one-on-one {id}."
4. On error: use standard error handling.

### api-reference.md Changes

Replace the `/meetings` section (~lines 568-577) with a `/1-on-1` section documenting all 17 endpoints from the API handoff (including the 14 new ones: notes, notes-lock, align, unalign, set-positions, assistants, attachments, goals, measures, done, fetch, POST create).

Update the glossary mapping at the bottom: `meetings` → `/1-on-1`.

### Argument Parsing Addition

Add `notes` to the argument parsing table in SKILL.md:

| Input | Flow |
|-------|------|
| `{meeting_id} notes "text"` | Save Notes |
