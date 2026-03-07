# Data Model: Fix Measure History Display in Scorecard

**Branch**: `001-fix-measure-history` | **Date**: 2026-03-07

## Entities

### Measure

A named weekly KPI belonging to a team's scorecard.

| Field | Type | Notes |
|-------|------|-------|
| `id` | integer | Always non-null |
| `name` | string | Display name |
| `unit` | string | e.g. `"#"`, `"$"`, `"%"` |
| `direction` | `"higher"` \| `"lower"` | Whether higher or lower is better |
| `target_value` | string \| null | Target number as string |
| `owner` | UserSimple \| null | Assigned owner |
| `is_archived` | boolean | Whether archived |
| `histories` | MeasureHistory[] | 52 weekly slots for the requested year |

### MeasureHistory

One week's entry in a measure's history. The skill treats a slot as "recorded" only when both `id` and `value` are non-null.

| Field | Type | Notes |
|-------|------|-------|
| `id` | integer \| null | Non-null when a value has been recorded for this week |
| `date` | string (YYYY-MM-DD) | Always a Monday; 52 entries per year |
| `value` | string \| null | Recorded numeric value as string; null if unrecorded |
| `target_value` | string \| null | Target for this specific week (usually null) |

**State rules**:
- **Recorded**: `id` is non-null AND `value` is non-null → display the value
- **Unrecorded**: `id` is null OR `value` is null → display "—"

### HistoryRecord (POST response)

Returned by `POST /measures/{id}/history` on success.

| Field | Type | Notes |
|-------|------|-------|
| `id` | integer | The `measurable_histories` row ID (always non-null on success) |
| `measure_id` | integer | The parent measure |
| `date` | string (YYYY-MM-DD) | The Monday date of the recorded week |
| `value` | string | The recorded value |
| `target_value` | string \| null | Target (usually null) |

## Display Logic

```
for each history slot h in measure.histories:
  if h.date matches a column week date:
    display h.value if non-null, else "—"
```

Built with jq:
```bash
($m.histories | map({(.date): (.value // "—")}) | add // {}) as $h
```

Lookup per column:
```bash
($h[$w1] // "—")   # "—" if week date not present in map
```
