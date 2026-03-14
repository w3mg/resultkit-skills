# Research: Measure chart_type Field

**Branch**: `036-measure-chart-type-31` | **Date**: 2026-03-13

## R1 — GET /teams/{id}/measures response

**Decision**: `chart_type` is present in all measure objects returned by this endpoint.

**Rationale**: Explicitly documented in API change spec (issue #31). Example response:

```json
{ "id": 90010, "name": "Revenue", "chart_type": "progress_bar" }
```

`chart_type` is `string | null`. Measures that predate this feature return `chart_type: null`.

**Alternatives considered**: N/A — field is already live.

---

## R2 — GET /seats/{id}/measures response

**Decision**: `chart_type` is also present in seat measure responses. The endpoint is explicitly listed in the API change table: "Response: `chart_type` added to every measure object."

**Rationale**: The seat detail response (`measures: [{id, name, description}]`) does not include `chart_type` — that is the embedded summary shape. But the full `GET /seats/{id}/measures` list endpoint returns full measure objects including `chart_type`.

**Impact**: The `seats` skill's `align-measure` and `remove-measure` flows post-operation display an "updated measures list" — this should be updated to show `chart_type`. The seat detail view (embedded measures) does not need updating as it uses a simpler shape without `chart_type`.

---

## R3 — PATCH preserves chart_type when key omitted

**Decision**: Omitting `chart_type` entirely from the PATCH body leaves the existing value unchanged. Sending `chart_type: null` clears it.

**Rationale**: Explicitly documented in API spec:
- Omit key → preserve existing value
- Send `null` → clear preference
- Send valid string → update to new value

**Implementation note**: The scorecard `update` command already uses a partial PATCH body pattern (builds `$FIELDS` string with only provided keys). `chart_type` must follow the same pattern — only included in the body when the user explicitly passes `chart_type=...` or `chart_type=null`.

---

## R4 — 422 error format for invalid chart_type

**Decision**: API returns `{"error": "Invalid chart_type value. Must be one of: pie, progress_circle, progress_bar, trend, bar_chart"}` for invalid values.

**Rationale**: Documented in API change spec. Valid enum: `pie`, `progress_circle`, `progress_bar`, `trend`, `bar_chart`.

**Implementation note**: Client-side validation in the skill should check against this enum before calling the API. If the skill presents the error, it should display the valid values from this enum. If the API returns 422, fall back to showing the API error message.

---

## Summary of Touch Points

| File | Change Type | Reason |
|------|-------------|--------|
| `api-reference.md` (master) | Update | Add `chart_type` to 4 endpoints + validation note |
| `skills/scorecard/SKILL.md` | Update | Display, add, update `chart_type` |
| `skills/seats/SKILL.md` | Update | Display `chart_type` in seat measure listings (post align/remove) |
| `skills/*/references/api-reference.md` | Propagate | Via `/sync-plugin` after master update |

No new files. No new skills. No new API calls.
