# Implementation Plan: V2 Seat API Integration

**Branch**: `029-v2-seat-api` | **Date**: 2026-03-05 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/029-v2-seat-api/spec.md`

## Summary

Update the existing `rkit:seats` skill and `api-reference.md` to match the finalized V2 Seat API. The skill is largely implemented; this plan addresses six targeted gaps: two field name corrections (`group_id`, `accountability_owner_id`), one missing flag (`--include-archived`), one missing command (`update-link`), and two messaging improvements (recursive archive, non-recursive restore).

## Technical Context

**Language/Version**: Bash 5.x (scripts), Markdown (Claude Code skill runtime)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), `jq`, `curl`
**Storage**: `~/.config/resultkit/config.json` (read-only at skill runtime)
**Testing**: Manual API testing via `scripts/api.sh`; skill invocation testing via Claude Code
**Target Platform**: Claude Code plugin runtime (`~/.claude/plugins/`)
**Project Type**: Single skill extension (modifying existing `skills/seats/SKILL.md`)
**Performance Goals**: Chart view renders in under 5 seconds on typical team sizes
**Constraints**: No new external dependencies; skill must remain self-contained
**Scale/Scope**: Single skill file (~560 lines); targeted edits to ~8 locations

## Constitution Check

*GATE: Must pass before implementation.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | PASS | SKILL.md entry point already exists |
| II. Self-Contained | PASS | api.sh path resolution already in skill |
| III. Config-Driven | PASS | Reads from config.json; no hardcoded values |
| IV. Confirm Writes | PASS | All write flows already confirm; messaging being improved |
| V. Show IDs | PASS | All output includes IDs |
| VI. Framework-Aware | PASS | EOS/non-EOS terminology already handled |
| VII. Direct Execution | PASS | Bash + api.sh; no Task agents |
| VIII. Graceful Degradation | PASS | Error handling table covers all cases |
| IX. Concise Output | PASS | Tables and short summaries throughout |

**Gate result**: All principles satisfied. No violations.

## Project Structure

### Documentation (this feature)

```text
specs/029-v2-seat-api/
├── plan.md              # This file
├── spec.md              # Feature specification
├── research.md          # Phase 0 — gaps analysis and decisions
├── data-model.md        # Phase 1 — V2 canonical field names
├── quickstart.md        # Phase 1 — change guide
├── contracts/
│   └── skill-commands.md  # Phase 1 — full API call contracts
├── checklists/
│   └── requirements.md    # Spec quality checklist
└── tasks.md             # Phase 2 output (from /speckit.tasks)
```

### Source Code (repository root)

```text
skills/seats/
├── SKILL.md                        # Primary change target
└── references/
    └── api-reference.md            # Auto-synced from master

api-reference.md                    # Master API reference (edit here)
```

**Structure Decision**: Single skill extension. No new files or directories in `skills/`. All changes are in-place edits to the existing skill and master reference.

## Phase 0: Research — Complete

See [research.md](research.md) for full findings. Summary:

| Question | Decision |
|----------|----------|
| `group_id` vs `team_id` for root seat creation | Use `group_id` (V2 canonical) |
| `accountability_owner_id` vs `seat_owner_id` | Use `accountability_owner_id` (V2 canonical) |
| Does `GET /teams/{id}/seats` support `include_archived`? | Yes — add `--include-archived` flag |
| Is `update-link` needed? | Yes — `PATCH /seats/{id}/links/{lid}` exists but has no CLI flow |
| Is recursive archive messaging adequate? | No — enhance confirmation to call out all descendants |
| Is non-recursive restore messaging adequate? | No — enhance confirmation to note children remain archived |

## Phase 1: Design — Complete

### Change Set (ordered by implementation priority)

#### Change 1: Fix `group_id` in Create Seat flow (HIGH)

**File**: `skills/seats/SKILL.md` — Flow: Create Seat, Step 4

Current:
```bash
RESPONSE=$("$API_SH" POST "/seats" '{"name":"NAME","team_id":TEAM_ID,"parent_id":PARENT_ID}')
```

Replace with two distinct cases:
- Root seat (no `--parent`): body = `{"name":"NAME","group_id":TEAM_ID}`
- Child seat (with `--parent`): body = `{"name":"NAME","parent_id":PARENT_ID}`

**File**: `api-reference.md` — Seats CRUD table, POST /seats row — update body docs from `team_id` to `group_id`.

#### Change 2: Fix `accountability_owner_id` in Update Seat flow (HIGH)

**File**: `skills/seats/SKILL.md` — Flow: Update Seat, Step 2

Current mapping:
```
--owner {uid} → "seat_owner_id": {uid}
```

Updated:
```
--owner {uid} → "accountability_owner_id": {uid}
```

Also add to confirmation message: "Note: changing the owner will reassign all aligned measures and goals to the new owner."

**File**: `api-reference.md` — Seats CRUD table, PATCH /seats/{id} row — update field name.

#### Change 3: Add `--include-archived` to Chart View (HIGH)

**File**: `skills/seats/SKILL.md`

1. Argument parsing table — add row: `--include-archived` → Include archived seats in chart
2. Chart view flow — Step 2: append `?include_archived=true` when flag is present
3. Chart view flow — Step 3: for seats with `archived: true`, append `[archived]` to the tree line

**File**: `api-reference.md` — Tree endpoint row: confirm `include_archived=true` param (remove `?` uncertainty).

#### Change 4: Add `update-link` command (MEDIUM)

**File**: `skills/seats/SKILL.md`

1. Argument parsing table — add row: `update-link {id} --link {lid} [--url "..."] [--title "..."]`
2. Add new flow section "Flow: Update Link" after "Flow: Add Link":
   - Parse seat ID, `--link {lid}`, optional `--url` and `--title`
   - Confirm: "Update link [ID: {lid}] on seat [ID: {id}]: {changes}?"
   - Execute: `PATCH /seats/{SEAT_ID}/links/{LID}` with `{"url":"...","title":"..."}`
   - 200: show updated link (ID, Title, URL)
   - Other errors: error handling table

#### Change 5: Enhance Delete confirmation messaging (MEDIUM)

**File**: `skills/seats/SKILL.md` — Flow: Delete Seat, Step 2

Current: "Archive seat [ID: {id}]? This will remove it from the chart."
Updated: "Archive seat [ID: {id}]? This will archive this seat AND all its descendants. This cannot be undone without restoring each seat individually."

#### Change 6: Enhance Restore confirmation messaging (LOW)

**File**: `skills/seats/SKILL.md` — Flow: Restore Seat, Step 2

Current: "Restore seat [ID: {id}]?"
Updated: "Restore seat [ID: {id}]? Only this seat will be restored — descendant seats remain archived and must be restored individually."

### Post-Change Steps

1. Run `/sync-plugin` to copy updated `api-reference.md` to `skills/seats/references/api-reference.md` and bump plugin version.
2. Verify all 6 changes with live API calls (see [quickstart.md](quickstart.md) verification steps).
3. Close GitHub Issue #19.
