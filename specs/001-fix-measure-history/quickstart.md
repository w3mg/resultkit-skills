# Quickstart: Fix Measure History Display in Scorecard

**Branch**: `001-fix-measure-history` | **Date**: 2026-03-07

## What's Changing

One line change in `skills/scorecard/SKILL.md` — the record success message now includes the history entry ID.

## The Change

**File**: `skills/scorecard/SKILL.md`
**Section**: Flow: Record Value → Step 7: Handle response

**Before**:
```
- **200**: "Recorded: {MEASURE_NAME} — {VALUE} for week of {RECORD_DATE}."
```

**After**:
```bash
HISTORY_ID=$(echo "$RESPONSE" | jq -r '.body.data.id // "?"')
```
```
- **200**: "Recorded: {MEASURE_NAME} — {VALUE} for week of {RECORD_DATE} (history ID: {HISTORY_ID})."
```

## Verification

1. Run `/rkit:scorecard` for a team — confirm recorded weeks show real values (not all "—").
2. Run `/rkit:scorecard record "Measure Name" 5` — confirm success message includes `(history ID: <int>)`.
3. Run `/rkit:scorecard` again — confirm the just-recorded value appears in the current week column.

## Why Display Already Works

The jq expression `.value // "—"` was always correct. When the API returned all-null values, every slot showed "—". Now that real values arrive, they display automatically — no code change needed for the display path.
