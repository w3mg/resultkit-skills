# Implementation Plan: Measure Data Source Fields

**Branch**: `035-measure-data-source-30` | **Date**: 2026-03-10 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `specs/035-measure-data-source-30/spec.md`

## Summary

The ResultMaps API now exposes `data_source_type` on all measures and supports roll-up measures (`data_source_type=3`). This plan updates `api-reference.md` with the new fields and patches the scorecard skill to (a) display roll-up context in the list view and (b) block manual value entry for roll-up measures. No extra API calls are needed — `data_source_type` is already included in the existing `GET /teams/{id}/measures` response.

## Technical Context

**Language/Version**: Bash 5.x (scripts), Markdown (SKILL.md — Claude Code skill runtime)
**Primary Dependencies**: curl, jq, `scripts/api.sh` (shared API caller)
**Storage**: N/A — all data via ResultMaps V2 API
**Testing**: Manual invocation of `/rkit:scorecard` against live API; review of updated api-reference.md
**Target Platform**: Claude Code plugin (SKILL.md format), Linux/macOS
**Performance Goals**: No additional API calls — `data_source_type` is already in the existing measures list response
**Constraints**: Must not introduce extra API calls; roll-up detection uses data already fetched during name resolution
**Scale/Scope**: Narrow — 2 files modified (api-reference.md, scorecard SKILL.md) + plugin sync

## Constitution Check

| Gate | Status | Notes |
|------|--------|-------|
| I. Claude Code Skill Format | ✅ PASS | SKILL.md entry point, Bash/jq for API calls |
| II. Self-Contained | ✅ PASS | No cross-skill dependencies introduced |
| III. Config-Driven | ✅ PASS | Uses `~/.config/resultkit/config.json`, unchanged |
| IV. Confirm Writes | ✅ PASS | Roll-up guard is read-only; record value already confirms |
| V. Show IDs | ✅ PASS | Measure IDs already displayed in all flows |
| VI. Framework-Aware | ✅ PASS | EOS "Measurables" label already handled; no change needed |
| VII. Direct Execution | ✅ PASS | Bash + api.sh only; no subagents |
| VIII. Graceful Degradation | ✅ PASS | Error table covers API errors; roll-up guard has clear message |
| IX. Concise Output | ✅ PASS | Roll-up indicator is a compact inline label |
| X. Use Skill Builder | ✅ PASS | SKILL.md changes must go through `/skill-creator` |

No violations. No Complexity Tracking needed.

## Project Structure

### Documentation (this feature)

```text
specs/035-measure-data-source-30/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
└── tasks.md             # Phase 2 output (/speckit:tasks)
```

### Source Code (repository root)

```text
api-reference.md                          # Master — update measures section
skills/scorecard/SKILL.md                 # Update list + record flows
skills/*/references/api-reference.md      # Updated by /sync-plugin (do not edit directly)
```

---

## Phase 0: Research

### Findings

**Decision**: Use `data_source_type` already present in `GET /teams/{id}/measures` response — no extra API calls.
**Rationale**: The API Change Handoff states `data_source_type` is always present on every measure in GET responses. The scorecard skill already fetches all measures during name resolution (Step 1 of any subcommand) and during list view. Both flows have full measure objects including `data_source_type`.
**Alternatives considered**: Fetching a single measure detail before recording — rejected because it adds an unnecessary API call; the list already contains all needed data.

---

**Decision**: Display roll-up indicator as an inline column badge in list view, not a separate table.
**Rationale**: The scorecard table is already wide. A compact `[roll-up: sum]` or `[roll-up: avg]` label appended to the measure name (like the existing `[archived]` label) is least disruptive and follows the established pattern in SKILL.md.
**Alternatives considered**: A separate "Source Type" column — rejected because it widens the already-wide table.

---

**Decision**: Block manual entry for `data_source_type=3` only; treat `1` and `2` as enterable by the skill (API may accept or reject).
**Rationale**: The API Change Handoff scopes this ticket to roll-up (`3`). Values `1` (google_sheets) and `2` (other_api) are external integrations — the API may still accept manual history entries for these and the handoff does not restrict them. Rolling out guard for all non-manual types is out of scope.
**Alternatives considered**: Block all non-zero types — deferred to a future ticket if needed.

---

**Decision**: Roll-up entry guard fires during name resolution step (after measure list is fetched), before the confirmation prompt.
**Rationale**: The measure list is fetched in Step 4 of the Record Value flow. `data_source_type` is in that response. Checking there avoids any extra API call and stops the flow before prompting the user for confirmation.

