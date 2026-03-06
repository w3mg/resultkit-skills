# Data Model: Scorecard Skill (rkit:scorecard)

**Branch**: `001-scorecard-skill` | **Date**: 2026-03-05

All data is read from and written to the ResultMaps V2 API. No local storage.

---

## Measure

A KPI tracked weekly on a team's scorecard.

| Field | Type | Notes |
|-------|------|-------|
| `id` | integer | Unique measure identifier. Always shown in output. |
| `name` | string | Display name. Required. Case-insensitive for resolution. |
| `description` | string \| null | Optional description. |
| `target_value` | string \| null | Numeric string target. Null if not set. |
| `unit` | string | Display unit (e.g., `"#"`, `"$"`, `"%"`). Default `""`. |
| `direction` | `"higher"` \| `"lower"` | Whether higher or lower values are better. Default `"higher"`. |
| `owner` | UserSimple \| null | Assigned owner. Null if unowned. |
| `is_archived` | boolean | If true, excluded from default list. |
| `histories` | MeasureHistory[] | Weekly value slots for the requested year. 52 slots. |

**Validation**:
- `name` must not be blank (API returns 422 if missing).
- `direction` must be `"higher"` or `"lower"`.

---

## MeasureHistory

A single weekly value entry for a measure.

| Field | Type | Notes |
|-------|------|-------|
| `id` | integer \| null | Null if the week has no recorded value. |
| `date` | string (YYYY-MM-DD) | The Monday date for this week slot. |
| `value` | string \| null | Numeric string. Null if not recorded. |
| `target_value` | string \| null | Per-week target override. Null if using measure-level target. |

**Upsert key**: (measure_id, date). Submitting the same date twice updates the existing entry.

**Validation**:
- `value` must be numeric (e.g., `"42"`, `"3.5"`). Empty string is rejected by API (422).
- `date` must be a valid ISO date; the API expects Monday dates.

---

## UserSimple

Embedded user reference on a measure's `owner` field.

| Field | Type |
|-------|------|
| `id` | integer |
| `first_name` | string |
| `last_name` | string |
| `login` | string |

---

## Response Envelopes

**List measures**: `{ "data": Measure[], "meta": { "year": int, "date_range": { "start": string, "end": string } } }`
**Create/Update/Archive measure**: `{ "data": Measure }` (no `histories` on PATCH/DELETE)
**Record history**: `{ "data": { "id": int, "measure_id": int, "date": string, "value": string, "target_value": string | null } }`

---

## State Transitions

```text
Measure
  Active (is_archived: false)
    → record history    → POST /measures/:id/history
    → update fields     → PATCH /measures/:id
    → archive           → DELETE /measures/:id  or  PATCH { archived: true }
  Archived (is_archived: true)
    → restore           → PATCH { archived: false }
    → update fields     → PATCH /measures/:id
```
