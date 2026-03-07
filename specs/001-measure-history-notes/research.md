# Research: Measure History Notes

**Branch**: `001-measure-history-notes` | **Date**: 2026-03-07

No external unknowns required research — the API change handoff document (GitHub Issue #23) provides complete endpoint specifications and the existing `rkit:scorecard` skill provides all necessary implementation patterns.

## Decisions

### 1. Note subcommand interface

**Decision**: Add a `note` subcommand to `rkit:scorecard` following the existing `record` pattern.

```
/rkit:scorecard note "Measure Name" "note text" [date=YYYY-MM-DD]
/rkit:scorecard note clear "Measure Name" [date=YYYY-MM-DD]
```

**Rationale**: Consistent with the existing `record` subcommand. `note clear` mirrors `archive` in using a verb+object form for the destructive variant.

**Alternatives considered**:
- `note --clear` flag: Rejected — mixing positional subcommand with flags inconsistently.
- `note delete` instead of `note clear`: Rejected — "clear" better conveys the no-op behavior on missing notes.
- Separate `/rkit:scorecard-note` skill: Rejected — the note feature is tightly coupled to the scorecard skill; a separate skill would violate the self-contained principle unnecessarily.

### 2. Note display in list view

**Decision**: Display notes as footnote-style markers in the scorecard list table. Weeks with notes show a `*` in the value cell; notes are listed below the table as numbered footnotes.

**Rationale**: Notes are contextual and verbose. Inline text in table cells would break alignment. Footnotes keep the table scannable while surfacing note content.

**Alternatives considered**:
- Inline note text in table cell: Rejected — breaks column alignment.
- Separate "show notes" subcommand only: Rejected — notes in list view is a spec requirement (SC-003).
- No display in list (only when explicitly asked): Rejected — violates FR-005.

### 3. Date handling for note subcommand

**Decision**: Reuse the same date resolution logic as `record`: if `date=YYYY-MM-DD` is provided use it; otherwise default to the current week's Monday.

**Rationale**: Identical pattern to `record`. Users already understand this convention. The API enforces Monday-only dates.

**Alternatives considered**: No alternatives — direct parity with `record` is the simplest and most consistent approach.

### 4. Validation before API call

**Decision**: Validate note length (≤ 255 chars) client-side before calling the API.

**Rationale**: Gives immediate feedback without a round-trip; mirrors the existing numeric validation for `record`.

**Alternatives considered**: Let the API return 422 — simpler but slower feedback. Client validation costs one line of bash and is the established pattern.

### 5. Confirmation prompt for clear

**Decision**: `note clear` requires confirmation, same as any other POST.

**Rationale**: Constitution IV requires confirmation for all POST/PUT/PATCH/DELETE. Clearing a note is a POST with `note: null`.

## API Behavior Confirmed (from Issue #23 spec)

- `POST /api/v2/measures/:id/history/note` — upserts note for a (measure, date) pair
- Clear: send `note: null` or `note: ""`; no-op if note doesn't exist
- Validation: `date` required (ISO 8601), `note` string or null (numbers → 422), max 255 chars
- `GET /api/v2/teams/:id/measures` now includes `note: string | null` on every history slot
- Response shape for POST: `{ "data": { "id": int|null, "measure_id": int, "date": string, "note": string|null } }`

No API testing required — the change handoff document is authoritative and the behavior is straightforward.
