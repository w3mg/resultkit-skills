# Data Model: Measure History Notes

**Branch**: `001-measure-history-notes` | **Date**: 2026-03-07

## Updated Entities

### MeasureHistory (updated)

Weekly history slot for a scorecard measure. Returned inside each `Measure` from `GET /teams/:id/measures`.

| Field | Type | Notes |
|-------|------|-------|
| `id` | integer \| null | null if no value recorded for this week |
| `date` | string (YYYY-MM-DD) | Always a Monday |
| `value` | numeric string \| null | The recorded weekly value |
| `target_value` | numeric string \| null | Target for this week |
| `note` | string \| null | **NEW** — Per-week contextual note; null if no note recorded |

**Key invariants**:
- A slot can have a `note` with no `value`, or a `value` with no `note`, or both, or neither.
- A slot's `id` pertains to the value row only; the note is stored independently.
- `note` is always present in the response (never absent); null means no note exists.

### NoteEntry (new)

Response body from `POST /measures/:id/history/note`.

| Field | Type | Notes |
|-------|------|-------|
| `id` | integer \| null | null when note was cleared (no row exists) |
| `measure_id` | integer | The measure this note belongs to |
| `date` | string (YYYY-MM-DD) | The Monday date of the week |
| `note` | string \| null | The note text; null when cleared |

## State Transitions

### Note lifecycle

```
[No note] --record note--> [Has note]
[Has note] --record note--> [Has note (updated)]
[Has note] --clear note--> [No note]
[No note] --clear note--> [No note (no-op)]
```

Note state is independent of value state on the same slot.

## Validation Rules

| Rule | Constraint |
|------|------------|
| `date` | Required. Must be a valid ISO 8601 date. |
| `note` | Must be string or null. Numbers return 422. |
| `note` length | Maximum 255 characters when non-null. |
| Clear semantics | Send `null` or `""` to delete; clearing non-existent note is a no-op. |
