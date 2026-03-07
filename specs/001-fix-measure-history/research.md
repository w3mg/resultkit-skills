# Research: Fix Measure History Display in Scorecard

**Branch**: `001-fix-measure-history` | **Date**: 2026-03-07

## Research Questions

### Q1: Does the existing display code handle non-null history values?

**Decision**: Yes — no changes needed to the display path.

**Rationale**: The jq expression in Step 6 of the List Scorecard flow builds a date→value map using `(.value // "—")`. When `value` is non-null, the actual value is stored in the map. When `value` is null, "—" is substituted. The column lookup `($h[$w1] // "—")` then retrieves the correct value for each week column. This logic was always correct — it just never received non-null data. Now that the API returns real values, it will display them without modification.

**Code confirmed**:
```bash
($m.histories | map({(.date): (.value // "—")}) | add // {}) as $h |
...
($h[$w1] // "—"),
```

**Alternatives considered**: None — the existing code is correct.

---

### Q2: Does the record success message need updating?

**Decision**: Yes — the Step 7 success message must be updated to include the history entry `id`.

**Rationale**: Constitution §V (Show IDs) requires that every response referencing an entity include its numeric ID. The API returns `{ "data": { "id": int, "measure_id": int, "date": string, "value": string, "target_value": string|null } }` on successful record. The current message does not extract or display the `id`. Previously `id` was always null (API bug), making this moot; now it is a real integer.

**Updated message**:
```
Recorded: {MEASURE_NAME} — {VALUE} for week of {RECORD_DATE} (history ID: {ID}).
```

Extract `ID` with:
```bash
HISTORY_ID=$(echo "$RESPONSE" | jq -r '.body.data.id // "?"')
```

**Alternatives considered**: Could show ID only when non-null — rejected because the API fix guarantees a real ID on every successful record; always showing it is simpler and consistent.

---

### Q3: Are there any API response shape changes that affect the skill?

**Decision**: No — response shape is unchanged. Only the data content changed.

**Rationale**: Per the API change handoff, response shapes for both endpoints are identical before and after the fix. The `histories` array still contains 52 entries per year with the same fields (`id`, `date`, `value`, `target_value`). Unrecorded weeks still have `id: null` and `value: null`. Recorded weeks now have real non-null values.

**API reference confirmed**:
- `GET /teams/{id}/measures` → `{ "data": Measure[], "meta": {...} }` (unchanged shape)
- `POST /measures/{id}/history` → `{ "data": { "id": int, ... } }` (unchanged shape)

**Alternatives considered**: None — no breaking changes per handoff doc.

---

### Q4: Does the api-reference.md need updating?

**Decision**: No — the existing api-reference.md already documents `id: int|null` for MeasureHistory, which was always the correct spec.

**Rationale**: The api-reference.md documents MeasureHistory with `id: int|null` and notes that unrecorded weeks have `id: null` and `value: null`. This was always the documented behavior; the API was just buggy. No documentation change required.

## Summary of Changes Required

| File | Change | Reason |
|------|--------|--------|
| `skills/scorecard/SKILL.md` | Update Step 7 success message to include history `id` | Constitution §V requires showing entity IDs |

No other files need changes. The display code, error handling, and API reference are all correct.
