# Quickstart: Measure chart_type Field

**Branch**: `036-measure-chart-type-31` | **Date**: 2026-03-13

## What's changing

The API now returns `chart_type` on every measure. Two skills need updating:

1. **scorecard** — display `chart_type` in listings; accept `chart_type=...` on `add` and `update`
2. **seats** — display `chart_type` in post-alignment measure listings
3. **api-reference.md** — document `chart_type` on 4 endpoints (propagated via `/sync-plugin`)

## Scorecard skill changes

### Display (list view)

Add `chart_type` as a column in the measure table. Show value when non-null; show `—` when null. Column is rightmost and lowest priority — can be omitted if terminal is narrow.

### Add command

```
/rkit:scorecard add "Revenue" [chart_type=progress_bar]
```

- Parse `chart_type=VALUE` from args.
- Validate against enum before API call.
- Include in create body only when provided.

### Update command

```
/rkit:scorecard update "Revenue" [chart_type=trend]
/rkit:scorecard update "Revenue" [chart_type=null]   ← clears preference
```

- Parse `chart_type=VALUE` or `chart_type=null` from args.
- Validate against enum (skip validation for `null`).
- Include in PATCH body only when explicitly provided (omit key entirely otherwise).
- Add `chart_type` to valid update fields list in usage/error messages.

## Seats skill changes

The seats skill displays a measures list after `align-measure` and `remove-measure` operations. Update that table to include a `chart_type` column when the endpoint returns full measure objects with `chart_type`.

## api-reference.md changes

Add `chart_type?` to:
- `POST /teams/{id}/measures` request body description
- `PATCH /measures/{id}` request body description
- `GET /teams/{id}/measures` and `GET /seats/{id}/measures` response shape notes

Add validation note: `chart_type` must be one of `pie`, `progress_circle`, `progress_bar`, `trend`, `bar_chart` or null (422 otherwise).

## Propagation

After updating `api-reference.md`, run `/sync-plugin` to copy to all skill reference directories and bump plugin version.
