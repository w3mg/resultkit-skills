# Contract: Measure History Note Endpoint

**Source**: ResultMaps V2 API — confirmed in GitHub Issue #23

---

## POST /api/v2/measures/:id/history/note

Record or clear a per-week note for a scorecard measure.

### Request

```
POST /api/v2/measures/{id}/history/note
Authorization: Token <api_token>
Content-Type: application/json
```

**Path params**:

| Param | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | integer | yes | The measure ID |

**Body**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `date` | string (YYYY-MM-DD) | yes | Monday date of the target week |
| `note` | string \| null | yes | Note text (≤ 255 chars); `null` or `""` to clear |

**Record example**:
```json
{ "date": "2026-01-05", "note": "Holiday week — results skewed" }
```

**Clear example**:
```json
{ "date": "2026-01-05", "note": null }
```

---

### Responses

**200 OK — note recorded**:
```json
{
  "data": {
    "id": 42,
    "measure_id": 736,
    "date": "2026-01-05",
    "note": "Holiday week — results skewed"
  }
}
```

**200 OK — note cleared**:
```json
{
  "data": {
    "id": null,
    "measure_id": 736,
    "date": "2026-01-05",
    "note": null
  }
}
```

**422 Unprocessable Entity** — validation failure:
```json
{ "error": { "message": "Note is too long (maximum is 255 characters)" } }
```

**401 Unauthorized** — invalid or missing token.

**403 Forbidden** — user does not have `canEditGroup` permission for this measure's team.

**404 Not Found** — measure ID does not exist.

---

## GET /api/v2/teams/:id/measures — updated history slot shape

History slots now include `note`. No other changes.

**Updated slot shape**:
```json
{
  "id": 12345,
  "date": "2026-01-05",
  "value": "3",
  "target_value": null,
  "note": "Holiday week — results skewed"
}
```

**Slot with no note**:
```json
{
  "id": null,
  "date": "2026-01-12",
  "value": null,
  "target_value": null,
  "note": null
}
```

---

## Skill Command Interface

### Record a note

```
/rkit:scorecard note "Measure Name" "Note text" [date=YYYY-MM-DD]
```

| Arg | Required | Description |
|-----|----------|-------------|
| Measure Name | yes | Name of the measure (resolved via name matching) |
| Note text | yes | Text to record (max 255 chars) |
| `date=YYYY-MM-DD` | no | Target week (Monday); defaults to current week's Monday |

**Confirmation prompt**:
```
Record note for "{MEASURE_NAME}" (ID: {MEASURE_ID}) for week of {DATE}:
  "{NOTE_TEXT}"
[y/N]
```

**Success output**:
```
Noted: {MEASURE_NAME} (ID: {MEASURE_ID}) — week of {DATE}
  "{NOTE_TEXT}"
```

---

### Clear a note

```
/rkit:scorecard note clear "Measure Name" [date=YYYY-MM-DD]
```

**Confirmation prompt**:
```
Clear note for "{MEASURE_NAME}" (ID: {MEASURE_ID}) for week of {DATE}? [y/N]
```

**Success output**:
```
Note cleared: {MEASURE_NAME} (ID: {MEASURE_ID}) — week of {DATE}
```

---

### Scorecard list — note display

Notes are surfaced as footnotes below the main table:

```
ID   Name           Unit  Dir     Target  ...  Jan 5   Jan 12  Jan 19  Jan 26
──   ─────────────  ────  ──────  ──────  ...  ──────  ──────  ──────  ──────
736  # Proposals    #     higher  5            3*      —       4       5

* Jan 5: Holiday week — results skewed
```

Weeks with notes show `*` appended to the value (or `—*` if no value). Notes are printed as `* {date}: {note text}` after the table.
