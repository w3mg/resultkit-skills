# API Contracts: Monthly Measure History

**Branch**: `034-monthly-measure-entry-29` | **Date**: 2026-03-10

These are the upstream ResultMaps API contracts. Skills are consumers, not providers.

---

## POST /api/v2/measures/{id}/history (extended)

Records a value for a measure. Now accepts an optional `period` field.

### Weekly entry (unchanged)

**Request**:
```
POST /api/v2/measures/1/history
Authorization: Bearer TOKEN
Content-Type: application/json

{ "date": "2026-01-05", "value": "42" }
```

- `date`: Monday date in `YYYY-MM-DD` format (required)
- `value`: Numeric string (required)
- `period`: Omit or pass `"week"` (same result)

**Response 200**:
```json
{ "data": { "id": 10, "measure_id": 1, "date": "2026-01-05", "value": "42", "target_value": null } }
```

---

### Monthly entry (new)

**Request**:
```
POST /api/v2/measures/1/history
Authorization: Bearer TOKEN
Content-Type: application/json

{ "date": "2026-03", "value": "87", "period": "month" }
```

- `date`: Month in `YYYY-MM` or `YYYY-MM-01` format (required)
- `value`: Numeric string (required)
- `period`: Must be `"month"` (required to trigger monthly entry)

**Response 200**:
```json
{ "data": { "id": 11, "measure_id": 1, "date": "2026-03-01", "value": "87", "target_value": null } }
```

Note: `date` in response is always normalised to `YYYY-MM-01` for monthly entries.

---

### Error responses

**Response 422** — invalid value:
```json
{ "error": { "message": "Value must be numeric" } }
```

**Response 422** — invalid date format:
```json
{ "error": { "message": "Date format is invalid" } }
```

**Response 422** — date is not a Monday (weekly only):
```json
{ "error": { "message": "Date must be a Monday" } }
```

**Response 422** — invalid period:
```json
{ "error": { "message": "Period must be 'week' or 'month'" } }
```

**Response 403** — non-admin:
Non-admin user attempted to record a value.

---

## Skill Command Contracts

Natural language patterns that `rkit:scorecard` accepts for the extended `record` command:

### Weekly (unchanged)

| Input pattern | Action |
|---------------|--------|
| `record "Name" 42` | Record 42 for current week |
| `record "Name" 42 date=2026-01-05` | Record 42 for specific Monday |

### Monthly (new)

| Input pattern | Action |
|---------------|--------|
| `record "Name" 87 period=month` | Record 87 for current month |
| `record "Name" 87 date=2026-03 period=month` | Record 87 for March 2026 |
| `record "Name" 87 date=2026-03-01 period=month` | Record 87 for March 2026 (alt format) |

**Confirmation required**: Yes — same as weekly, showing period type in prompt:
```
Record value "87" for "Revenue" (ID: 1) for month of 2026-03-01? [y/N]
```

**Post-action output**:
```
Recorded: Revenue — 87 for month of 2026-03-01 (history ID: 11).
```

### Error output examples

**Non-numeric value**:
```
Value must be a number. Got: "n/a"
```

**Invalid month format** (422 from API):
```
Validation error: Date format is invalid
```

**Admin required** (403):
```
You don't have permission to record values for this team.
```
