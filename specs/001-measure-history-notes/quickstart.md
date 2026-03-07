# Quickstart: Measure History Notes

**Branch**: `001-measure-history-notes` | **Date**: 2026-03-07

## What's changing

Two files are modified; no new files are created:

1. **`skills/scorecard/SKILL.md`** — new `note` subcommand, updated list display
2. **`api-reference.md`** (master) — new endpoint + updated history slot shape
3. **`skills/scorecard/references/api-reference.md`** — updated automatically via `/sync-plugin`

## Implementation checklist

### 1. Update `api-reference.md` (master)

In the **Team Scorecard Measures** section:

- Add to the endpoint table:
  ```
  | POST | `/measures/{id}/history/note` | Record or clear a per-week text note (body: date*, note). Upserts; send null/empty to clear. | "add note", "record note", "annotate week", "note this week", "clear note", "remove note" | — |
  ```
- Update `MeasureHistory fields` line to include `note` field:
  ```
  MeasureHistory fields: `id` (integer | null), `date` (YYYY-MM-DD, Monday), `value` (numeric string | null), `target_value` (numeric string | null), `note` (string | null — null if no note recorded).
  ```
- Add response shape for the new endpoint:
  ```
  - `POST /measures/{id}/history/note` → `{ "data": { "id": int|null, "measure_id": int, "date": string, "note": string|null } }` (200, upsert; id is null when note cleared)
  ```

### 2. Update `skills/scorecard/SKILL.md`

**Argument Parsing table** — add row:
```
| `note "NAME" "TEXT" [date=YYYY-MM-DD]` | Record a note for a measure's week |
| `note clear "NAME" [date=YYYY-MM-DD]`  | Clear the note for a measure's week |
```

**New section: Flow: Record / Clear Note** — add after `Flow: Record Value`, before `Flow: Create Measure`:
- Parse args (NAME, TEXT or `clear` subcommand, optional date)
- Client-side validate: NAME required, TEXT required for record, TEXT ≤ 255 chars
- Resolve date (same logic as `record`)
- Resolve measure name (same Measure Name Resolution)
- Confirm (per constitution IV)
- Execute via api.sh: `POST "/measures/$MEASURE_ID/history/note"` with `{"date":"$DATE","note":"$NOTE_TEXT"}` or `{"date":"$DATE","note":null}`
- Handle response (200 success, 401/403/404/422 errors)

**Flow: List Scorecard — Step 6: Display** — update jq extraction:
- Map notes by date alongside values
- Append `*` to value cells that have a note
- Print footnotes after the table

### 3. Run `/sync-plugin`

Propagates updated `api-reference.md` from master to all skill copies and bumps plugin version.

## Testing

```bash
# Record a note
/rkit:scorecard note "# Proposals" "Holiday week — results skewed" date=2026-01-05

# Verify in list (should show * on Jan 5 column)
/rkit:scorecard

# Clear the note
/rkit:scorecard note clear "# Proposals" date=2026-01-05

# Verify cleared (no * on Jan 5)
/rkit:scorecard
```

Edge case tests:
- Note > 255 chars → rejected before API call
- Missing date → defaults to current Monday
- Non-existent measure name → "No measure found matching '...'"
- Clear on week with no note → succeeds silently
