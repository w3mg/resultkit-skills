# Quickstart: Monthly Measure Entry

**Branch**: `034-monthly-measure-entry-29` | **Date**: 2026-03-10

## What Changes

Two files change. Everything else stays the same.

| File | Change |
|------|--------|
| `api-reference.md` | Update `POST /measures/{id}/history` entry to document `period` field and monthly date format |
| `skills/scorecard/SKILL.md` | Update argument table and `Flow: Record Value` to handle `period=month` |

After updating, run `/sync-plugin` to copy `api-reference.md` to all skill reference directories and bump the plugin version.

---

## Step 1: Update api-reference.md

In the **Team Scorecard Measures** section, update the `POST /measures/{id}/history` row:

**Current**:
```
| POST | `/measures/{id}/history` | Record a weekly value for a measure (body: date*, value*). Upserts by (measure_id, date). Date must be a Monday. | ...
```

**Updated**:
```
| POST | `/measures/{id}/history` | Record a weekly or monthly value (body: date*, value*, period?). period: "week" (default, date must be Monday) or "month" (date: YYYY-MM or YYYY-MM-01, response normalises to YYYY-MM-01). Upserts. | ...
```

---

## Step 2: Update skills/scorecard/SKILL.md

**2a. Update argument table**: Extend the `record` row to show `[period=month]` option:

```markdown
| `record "NAME" VALUE [date=YYYY-MM-DD|YYYY-MM] [period=month]` | Record a value for a measure (weekly by default; add period=month for monthly entry) |
```

**2b. Update Flow: Record Value**:

In Step 1 (Parse args), also extract `PERIOD` from `period=...` flag (default: `"week"`).

In Step 3 (Compute date), add monthly branch:
- If `PERIOD == "month"`: default date to `date +%Y-%m` (current month) instead of current Monday.
- If `date=YYYY-MM-DD` was provided with `period=month`: strip to `YYYY-MM` (first 7 chars).

In Step 5 (Confirm), show period type:
- Weekly: `"for week of {RECORD_DATE}"`
- Monthly: `"for month of {RECORD_DATE}"`

In Step 6 (Execute), include `period` in body only when monthly:
```bash
if [ "$PERIOD" = "month" ]; then
  BODY="{\"date\": \"$RECORD_DATE\", \"value\": \"$VALUE\", \"period\": \"month\"}"
else
  BODY="{\"date\": \"$RECORD_DATE\", \"value\": \"$VALUE\"}"
fi
RESPONSE=$("$API_SH" POST "/measures/$MEASURE_ID/history" "$BODY")
```

In Step 7 (Handle response 200), show period in confirmation:
- Weekly: `"Recorded: {name} — {value} for week of {date} (history ID: {id})."`
- Monthly: `"Recorded: {name} — {value} for month of {date} (history ID: {id})."`

---

## Step 3: Sync and ship

```bash
# Sync master files to all skill directories + bump version
/sync-plugin

# Verify weekly still works (existing behaviour)
scripts/api.sh GET "/teams/TEAM_ID/measures?year=2026" | jq '.body.data[0].histories[0]'

# Record a monthly entry
scripts/api.sh POST "/measures/MEASURE_ID/history" '{"date":"2026-03","value":"87","period":"month"}'
# Expect: 200 with date "2026-03-01"

# Commit and push
/ship-it
```

---

## Testing

### Verify weekly still works (no regression)
```bash
scripts/api.sh POST "/measures/MEASURE_ID/history" '{"date":"2026-01-05","value":"42"}'
# Expect: 200, date "2026-01-05"
```

### Record a monthly entry
```bash
scripts/api.sh POST "/measures/MEASURE_ID/history" '{"date":"2026-03","value":"87","period":"month"}'
# Expect: 200, date "2026-03-01"
```

### Record monthly with YYYY-MM-01 format
```bash
scripts/api.sh POST "/measures/MEASURE_ID/history" '{"date":"2026-03-01","value":"87","period":"month"}'
# Expect: 200, date "2026-03-01"
```

### Verify 422 on non-numeric value
```bash
scripts/api.sh POST "/measures/MEASURE_ID/history" '{"date":"2026-03","value":"n/a","period":"month"}'
# Expect: 422
```

### Verify 422 on invalid period
```bash
scripts/api.sh POST "/measures/MEASURE_ID/history" '{"date":"2026-03","value":"87","period":"quarter"}'
# Expect: 422
```
