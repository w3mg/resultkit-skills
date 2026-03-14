# Data Model: Measure chart_type Field

**Branch**: `036-measure-chart-type-31` | **Date**: 2026-03-13

## Measure (updated)

The `Measure` entity gains one new optional field.

| Field | Type | Notes |
|-------|------|-------|
| `id` | integer | Existing |
| `name` | string | Existing |
| `chart_type` | string \| null | **New**. One of: `pie`, `progress_circle`, `progress_bar`, `trend`, `bar_chart`. `null` = no preference set. |

### chart_type Enum

| Value | Display Label |
|-------|--------------|
| `pie` | Pie |
| `progress_circle` | Progress Circle |
| `progress_bar` | Progress Bar |
| `trend` | Trend |
| `bar_chart` | Bar Chart |
| `null` | *(omit or show "—")* |

### Validation Rules

- `chart_type` is optional on create and update.
- Valid values: `pie`, `progress_circle`, `progress_bar`, `trend`, `bar_chart`.
- `null` is valid (clears preference).
- Invalid string → API returns 422. Skill should validate before calling API.
- Omitting the key on PATCH → existing value preserved (do not send the key at all).

## State Transitions

```
null (no preference)
  → set valid string  [via POST or PATCH]
  → change to another valid string  [via PATCH]
  → clear to null  [via PATCH with chart_type: null]
```
