# Implementation Plan: Fix rkit:1on1 Endpoints

**Branch**: `worktree-fix-1on1-endpoints-gh97` | **Date**: 2026-04-23 | **Spec**: `specs/011-1on1/spec.md`
**Issue**: #97 — rkit:1on1 wrong API endpoints and response shapes

## Summary

The `rkit:1on1` skill is completely broken — every API call returns 404 because the skill references `/meetings` endpoints that don't exist. The actual API uses `/1-on-1` endpoints with different parameter names (`group_id` not `team_id`) and different response shapes (persons nested under `persons`, sections nested under `items`, blocked called `issues`). This plan covers migrating all endpoint references, fixing response parsing, updating the API reference, and adding the done-filter and notes flows.

## Technical Context

**Language/Version**: Bash 5.x, Markdown (Claude Code skill runtime)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), `curl`, `jq`
**Storage**: N/A — all data via ResultMaps V2 API
**Testing**: Manual via `scripts/api.sh` calls
**Target Platform**: Claude Code skill runtime (any OS)
**Project Type**: Single (skill SKILL.md + supporting scripts)
**Constraints**: No live API access in dev environment — changes verified against issue #97's API source inspection

## Constitution Check

| Principle | Status | Notes |
|---|---|---|
| I. Claude Code Skill Format | PASS | SKILL.md entry point, no external runtimes |
| II. Self-Contained | PASS | No project context dependency |
| III. Config-Driven | PASS | Uses `~/.config/resultkit/config.json` |
| IV. Confirm Writes | PASS | All mutations confirm before executing |
| V. Show IDs | PASS | IDs shown in all output |
| VI. Framework-Aware | N/A | 1on1s are framework-agnostic |
| VII. Direct Execution | PASS | Bash + api.sh, no subagents |
| VIII. Graceful Degradation | PASS | Config/404/401 handling present |
| IX. Concise Output | PASS | Tables and short summaries |

No violations.

## Project Structure

### Documentation (this feature)

```text
specs/011-1on1/
├── spec.md              # Feature spec (needs endpoint updates)
├── plan.md              # This file
├── research.md          # Endpoint migration research
├── data-model.md        # Correct response shapes
└── tasks.md             # Task breakdown (generated next)
```

### Source Code

```text
skills/1on1/
├── SKILL.md             # Main skill file (primary edit target)
├── scripts/
│   └── api.sh           # Shared API caller (synced copy)
└── references/
    └── api-reference.md # API reference (synced copy)

api-reference.md         # Master API reference (Meetings section → 1-on-1 section)
```

## Changes Required

### Phase 1: Endpoint Path Migration

Replace all `/meetings` references with `/1-on-1` in:
1. `skills/1on1/SKILL.md` — all bash code blocks and flow descriptions
2. `api-reference.md` — Meetings section header and endpoint table
3. `specs/011-1on1/spec.md` — API Endpoints Used table

### Phase 2: Parameter and Response Shape Fixes

In `skills/1on1/SKILL.md`:
1. Change `team_id` filter param to `group_id` in List flow
2. Update person field access: `persons.person1` / `persons.person2` instead of top-level
3. Update detail view parsing: sections are under `items` key, `blocked` → `issues`
4. Use `human_name` for display name where available (simplifies fallback logic)

In `api-reference.md`:
1. Update MeetingSimple/Meeting field documentation
2. Document `group_id` param
3. Document `persons` nesting and `items.issues` naming

### Phase 3: New Flows

In `skills/1on1/SKILL.md`:
1. Add Done Items flow with dedicated `GET /1-on-1/{id}/done` endpoint and `--since` filter
2. Add Save Notes flow via `PUT /1-on-1/{id}/notes`
3. Update argument parsing table for new flows

### Phase 4: Sync and Version

1. Run `/sync-plugin` to copy updated `api-reference.md` to all skill copies
2. Bump plugin version in `.claude-plugin/plugin.json`

## Complexity Tracking

No constitution violations — no entries needed.
