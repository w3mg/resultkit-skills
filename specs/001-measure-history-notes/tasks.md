# Tasks: Measure History Notes

**Input**: Design documents from `/specs/001-measure-history-notes/`
**Prerequisites**: plan.md ✅, spec.md ✅, research.md ✅, data-model.md ✅, contracts/ ✅, quickstart.md ✅

**Tests**: Not requested — no test tasks generated.

**Organization**: Tasks grouped by user story. This is a single-skill update with two change areas: `api-reference.md` (master) and `skills/scorecard/SKILL.md`.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to

## Path Conventions

Single-skill update. Key files:
- `api-reference.md` — master API reference (repo root)
- `skills/scorecard/SKILL.md` — scorecard skill entry point
- `skills/scorecard/references/api-reference.md` — skill-local copy (updated via `/sync-plugin`)

---

## Phase 1: Setup

**Purpose**: Verify working environment before making changes.

- [x] T001 Verify `scripts/api.sh` is present and config at `~/.config/resultkit/config.json` is valid; confirm live API is reachable by running `scripts/api.sh GET "/teams/$(jq -r .default_team_id ~/.config/resultkit/config.json)/measures" | jq '.status'`

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Update the master `api-reference.md` with the new endpoint and updated history slot shape. This is the source of truth referenced by all skill flows and must be complete before SKILL.md changes.

**⚠️ CRITICAL**: All user story SKILL.md work depends on the api-reference being accurate first.

- [x] T002 In `api-reference.md` (repo root), in the **Team Scorecard Measures** endpoint table (around line 548), add a new row after the `POST /measures/{id}/history` row: `| POST | \`/measures/{id}/history/note\` | Record or clear a per-week text note on a history slot (body: date*, note — string or null to clear). Upserts; clears are no-ops if no note exists. | "add note", "record note", "annotate week", "note this week", "clear note", "remove note", "weekly note" | — |`
- [x] T003 In `api-reference.md` (repo root), update the `MeasureHistory fields:` line (around line 552) to append `, \`note\` (string | null — null if no note recorded for this slot)` to the field list
- [x] T004 In `api-reference.md` (repo root), in the response shapes block (around line 555–559), add: `- \`POST /measures/{id}/history/note\` → \`{ "data": { "id": int|null, "measure_id": int, "date": string, "note": string|null } }\` (200, upsert; id is null when note is cleared)`

**Checkpoint**: `api-reference.md` now documents the complete note API. Proceed to user story phases.

---

## Phase 3: User Story 1 — Record a note on a scorecard week (Priority: P1) 🎯 MVP

**Goal**: Users can run `/rkit:scorecard note "Measure Name" "Note text" [date=YYYY-MM-DD]` to record a text note on a measure's weekly history slot.

**Independent Test**: Run `/rkit:scorecard note "Measure Name" "test note" date=<last-monday>` → confirm prompt, say y → verify success message shows measure ID and date. Then run `/rkit:scorecard` → confirm the week shows `*` marker and note appears in footnotes.

### Implementation for User Story 1

- [x] T005 [US1] In `skills/scorecard/SKILL.md`, add two rows to the **Argument Parsing** table (after the `record` row): `\| \`note "NAME" "TEXT" [date=YYYY-MM-DD]\` \| Record a per-week note for a measure \|` and `\| \`note clear "NAME" [date=YYYY-MM-DD]\` \| Clear the note for a measure's week \|`
- [x] T006 [US1] In `skills/scorecard/SKILL.md`, add a new **Flow: Record Note** section after `Flow: Record Value`. The section must cover: (1) Trigger condition: first arg is `note` AND second arg is NOT `clear`. (2) Parse args: NAME = arg 2 (required), TEXT = arg 3 (required), DATE from `date=YYYY-MM-DD` if present. (3) Client-side validation: NAME missing → usage error; TEXT missing → usage error; `${#TEXT}` > 255 → "Note is too long (max 255 characters)." and stop. (4) Date resolution: same logic as `record` (default to current Monday). (5) Measure name resolution: use Measure Name Resolution. (6) Confirmation prompt: `Record note for "{MEASURE_NAME}" (ID: {MEASURE_ID}) for week of {DATE}:\n  "{TEXT}"\n[y/N]` via AskUserQuestion. (7) Execute: `"$API_SH" POST "/measures/$MEASURE_ID/history/note" "{\"date\": \"$DATE\", \"note\": \"$TEXT\"}"`. (8) Handle 200 → `Noted: {MEASURE_NAME} (ID: {MEASURE_ID}) — week of {DATE}\n  "{TEXT}"`; 401 → auth error; 403 → permission error; 404 → not found; 422 → show API validation message; other → generic error.

**Checkpoint**: User Story 1 fully functional. `/rkit:scorecard note "Name" "text"` records a note end-to-end.

---

## Phase 4: User Story 2 — Clear a note from a scorecard week (Priority: P2)

**Goal**: Users can run `/rkit:scorecard note clear "Measure Name" [date=YYYY-MM-DD]` to remove an existing note. Clearing a non-existent note succeeds silently.

**Independent Test**: First record a note (US1). Then run `/rkit:scorecard note clear "Measure Name"` → confirm prompt, say y → verify `Note cleared` message. Run `/rkit:scorecard` → confirm `*` marker is gone. Also run clear on a week with no note → should still succeed.

### Implementation for User Story 2

- [x] T007 [US2] In `skills/scorecard/SKILL.md`, add a new **Flow: Clear Note** section after `Flow: Record Note`. The section must cover: (1) Trigger condition: first arg is `note` AND second arg is `clear`. (2) Parse args: NAME = arg 3 (required), DATE from `date=YYYY-MM-DD` if present. (3) Validation: NAME missing → `Usage: /rkit:scorecard note clear "Measure Name" [date=YYYY-MM-DD]` and stop. (4) Date resolution: same Monday-default logic as `record`. (5) Measure name resolution: use Measure Name Resolution. (6) Confirmation prompt: `Clear note for "{MEASURE_NAME}" (ID: {MEASURE_ID}) for week of {DATE}? [y/N]` via AskUserQuestion. (7) Execute: `"$API_SH" POST "/measures/$MEASURE_ID/history/note" "{\"date\": \"$DATE\", \"note\": null}"`. (8) Handle 200 → `Note cleared: {MEASURE_NAME} (ID: {MEASURE_ID}) — week of {DATE}`; 401/403/404/422/other → same error patterns as Record Note flow.

**Checkpoint**: User Stories 1 and 2 both functional. Notes can be recorded and cleared.

---

## Phase 5: User Story 3 — View notes when reading a scorecard (Priority: P3)

**Goal**: The scorecard list view surfaces per-week notes as footnotes. Weeks with notes show `*` appended to their value (or `—*` if no value). Notes are printed below the table as `* {formatted date}: {note text}`.

**Independent Test**: With at least one note recorded on the team's scorecard, run `/rkit:scorecard` → the table shows `*` on the noted week's cell and a footnote line appears below the table with the note text.

### Implementation for User Story 3

- [x] T008 [US3] In `skills/scorecard/SKILL.md`, update **Flow: List Scorecard — Step 6: Display**. After the existing jq extraction block, add a second jq pass to: (a) build a notes-by-date map from `$m.histories | map(select(.note != null)) | map({(.date): .note}) | add // {}`, (b) for each of the four week columns W1–W4, check if `$notes_map[$wN]` is non-null and append `*` to that cell's display value. Then after printing the table, collect and print all non-null notes as footnotes in the format `* {formatted date}: {note text}`. If no notes exist on any displayed week, print nothing extra. Update the jq command in the existing Step 6 to incorporate these changes — do not add a separate bash loop; keep it in one jq pipeline for consistency with the existing style.

**Checkpoint**: All three user stories functional. Scorecard displays, records, and clears notes end-to-end.

---

## Phase 6: Polish & Cross-Cutting Concerns

**Purpose**: Propagate api-reference.md changes, verify the Error Handling table covers note flows, and confirm end-to-end behavior.

- [x] T009 In `skills/scorecard/SKILL.md`, verify the **Error Handling** table at the bottom covers the note flows. Add any missing rows if needed (the existing table already covers 401, 403, 404, 422, CURL_FAILED, NO_CONFIG — confirm these are sufficient for note operations; they should be).
- [x] T010 Run `/sync-plugin` to copy updated `api-reference.md` from repo root to `skills/scorecard/references/api-reference.md` and all other skill copies, and bump the plugin version.
- [ ] T011 [P] Manually verify end-to-end using the test steps in `specs/001-measure-history-notes/quickstart.md`  ← pending manual test with live API: record a note, view scorecard with `*` marker, clear the note, verify cleared, test >255 char note rejection.
- [x] T012 [P] Close GitHub Issue #23 by running: `gh issue close 23 --repo w3mg/resultkit-skills --comment "Implemented: added \`note\` and \`note clear\` subcommands to \`rkit:scorecard\`, updated history slot display with footnotes, and updated api-reference.md. Synced to all skills via /sync-plugin."`

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1 — blocks all user story phases
- **User Stories (Phases 3–5)**: All depend on Phase 2 completion
  - Phase 3 (US1) and Phase 4 (US2) both modify `SKILL.md` — do them sequentially
  - Phase 5 (US3) also modifies `SKILL.md` — do after Phase 3–4
- **Polish (Phase 6)**: Depends on Phases 3–5 completion

### User Story Dependencies

- **US1 (P1)**: Starts after Phase 2. No dependencies on other stories.
- **US2 (P2)**: Starts after Phase 2. Independent of US1 but modifies same file — do after US1.
- **US3 (P3)**: Starts after Phase 2. Modifies same jq pipeline as US1 display — do after US2.

### Within Each User Story

- T005 (arg parsing) must precede T006 (record flow) since they edit the same file sequentially
- T007 (clear flow) is independent of T006 content but follows it in the file
- T008 (display) builds on the existing jq pipeline in Step 6

### Parallel Opportunities

- T002, T003, T004 (api-reference changes) are in the same file — do sequentially in one editing session
- T011 and T012 (verify + close issue) can run in parallel once T010 completes

---

## Parallel Example: Foundational Phase

```bash
# These are in the same file; run as one editing session:
Task T002: Add endpoint row to api-reference.md
Task T003: Update MeasureHistory fields line
Task T004: Add response shape line
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1: Setup (T001)
2. Complete Phase 2: Foundational (T002–T004) — CRITICAL
3. Complete Phase 3: User Story 1 (T005–T006)
4. **STOP and VALIDATE**: `/rkit:scorecard note "Name" "test"` works end-to-end
5. Continue to Phase 4–6

### Incremental Delivery

1. Setup + Foundational → api-reference.md accurate
2. US1 → note recording works
3. US2 → note clearing works
4. US3 → list view shows notes
5. Polish → sync, verify, close issue

---

## Notes

- All three user stories touch `skills/scorecard/SKILL.md` — edit sequentially, not in parallel
- The api-reference.md (Phase 2) is independent of SKILL.md changes and can be done first in one pass
- After `/sync-plugin` (T010), the updated api-reference.md propagates automatically to all skills — no manual copying needed
- [P] tasks = different files or clearly independent operations
- Each user story phase is independently testable per the quickstart.md test steps
