# Data Model: Monthly Measure Entry

**Branch**: `034-monthly-measure-entry-29` | **Date**: 2026-03-10

## Entities

### MeasureHistoryEntry (updated)

A recorded value for a measure at a specific time interval. Now supports two period types.

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Unique history entry ID |
| `measure_id` | integer | ID of the parent measure |
| `date` | string (ISO date) | Canonical date. Weekly: `YYYY-MM-DD` (always a Monday). Monthly: `YYYY-MM-01` (first of month, always normalised by API). |
| `value` | string | Numeric value (stored as string) |
| `target_value` | string \| null | Target value at time of recording (may be null) |
| `period` | `"week"` \| `"month"` | **New optional field** — determines interval type. Defaults to `"week"` when omitted. |
| `note` | string \| null | Optional per-week annotation text (existing; not affected by this change) |

### Period (value type)

| Value | Meaning | Date input format | Date in response |
|-------|---------|-------------------|-----------------|
| `"week"` | Default, existing | `YYYY-MM-DD` (must be a Monday) | `YYYY-MM-DD` (unchanged) |
| `"month"` | New | `YYYY-MM` or `YYYY-MM-01` | `YYYY-MM-01` (always normalised) |

## State Transitions

```
Monthly entry lifecycle:
  (no entry for month) ──POST period=month──► entry with date=YYYY-MM-01
  (entry exists)        ──POST period=month──► entry replaced (upsert)
```

Weekly entry lifecycle is unchanged:
```
  (no entry for week) ──POST (no period)──► entry with date=YYYY-MM-DD (Monday)
  (entry exists)      ──POST (no period)──► entry replaced (upsert)
```

## Validation Rules

| Rule | Period | Enforcement |
|------|--------|------------|
| `value` must be numeric | Both | Server-side (422); also caught client-side |
| `date` must be a Monday when `period` is `"week"` | Week | Server-side (422) |
| `date` format `YYYY-MM` or `YYYY-MM-01` valid | Month | Server-side (422 on bad format) |
| `period` must be `"week"` or `"month"` if provided | Both | Server-side (422) |
| Requester must be team admin | Both | Server-side (403) |

## API Reference Change

The following entry in `api-reference.md` under `## Team Scorecard Measures` needs updating:

**Current**:
> `POST /measures/{id}/history` | Record a weekly value for a measure (body: date*, value*). Upserts by (measure_id, date). Date must be a Monday.

**Updated**:
> `POST /measures/{id}/history` | Record a weekly or monthly value for a measure (body: date*, value*, period?). `period` is optional: `"week"` (default, date must be a Monday) or `"month"` (date as `YYYY-MM` or `YYYY-MM-01`, response normalises to `YYYY-MM-01`). Upserts by (measure_id, date).
