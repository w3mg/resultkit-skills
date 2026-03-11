# Data Model: Measure Data Source Fields

**Feature**: 035-measure-data-source-30

## Updated Entity: Measure

The `Measure` object returned by `GET /teams/{id}/measures` gains new fields.

### All Measures (existing + new)

| Field | Type | Always Present | Notes |
|-------|------|---------------|-------|
| `id` | integer | ✅ | |
| `name` | string | ✅ | |
| `description` | string \| null | ✅ | |
| `unit` | string | ✅ | e.g. `"#"`, `"$"`, `"%"` |
| `direction` | `"higher"` \| `"lower"` | ✅ | |
| `target_value` | numeric string \| null | ✅ | |
| `owner` | UserSimple \| null | ✅ | |
| `is_archived` | boolean | ✅ | |
| `histories` | MeasureHistory[] | ✅ | 52 weekly slots |
| **`data_source_type`** | integer (0–3) | ✅ **NEW** | 0=manual, 1=google_sheets, 2=other_api, 3=roll_up |

### Roll-up Measures Only (`data_source_type=3`)

| Field | Type | Present When | Notes |
|-------|------|-------------|-------|
| **`roll_up_type`** | `"sum"` \| `"average"` | `data_source_type=3` **NEW** | Aggregation method |
| **`roll_up_measure_ids`** | integer[] | `data_source_type=3` **NEW** | Source measure IDs on same team |

### `data_source_type` Values

| Value | Label | Meaning |
|-------|-------|---------|
| `0` | manual | Value entered manually; history entries accepted |
| `1` | google_sheets | Value sourced from Google Sheets integration |
| `2` | other_api | Value sourced from external API integration |
| `3` | roll_up | Value auto-calculated from other measures; no manual entries |

## Validation Rules (from API)

- `data_source_type` must be one of `{0, 1, 2, 3}` — 422 otherwise
- `roll_up_type` must be `"sum"` or `"average"` — 422 if invalid (only checked when `data_source_type=3`)
- `roll_up_measure_ids` must all belong to the same team — 422 if cross-team
- A measure may not include itself in `roll_up_measure_ids` — 422 (self-reference)
- Circular references (A→B→A) — 422

## Skill-side Logic Changes

### List Scorecard

- After extracting each measure row, check `data_source_type`.
- If `data_source_type=3`, append `[roll-up: sum]` or `[roll-up: avg]` to the measure name (following the `[archived]` pattern already in SKILL.md).

### Record Value (entry guard)

- After resolving the measure name (Step 4), read `data_source_type` from the matched measure object.
- If `data_source_type=3`:
  - Print: `"{MEASURE_NAME}" is a roll-up measure (auto-calculated from other measures). Manual value entry is not supported.`
  - Stop — do not confirm or call the API.
