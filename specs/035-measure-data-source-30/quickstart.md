# Quickstart: Measure Data Source Fields

**Feature**: 035-measure-data-source-30

## What Changes

1. **`api-reference.md`** — The measures section gains documentation for `data_source_type` (always present on measures) and the roll-up fields (`roll_up_type`, `roll_up_measure_ids`) on GET, POST, and PATCH endpoints.

2. **`skills/scorecard/SKILL.md`** — Two behaviour changes:
   - **List view**: Roll-up measures display `[roll-up: sum]` or `[roll-up: avg]` inline with the measure name.
   - **Record value**: If the target measure has `data_source_type=3`, the skill blocks entry with an informational message.

3. **Plugin sync** — Updated `api-reference.md` is copied to all skill `references/` directories.

## Files Modified

| File | Change |
|------|--------|
| `api-reference.md` | Add `data_source_type` to Measure fields; add roll-up fields to GET/POST/PATCH docs |
| `skills/scorecard/SKILL.md` | List view: add roll-up badge; Record flow: add roll-up guard after name resolution |
| `skills/*/references/api-reference.md` | Synced automatically via `/sync-plugin` |

## No New Endpoints

All changes are to existing endpoints. No new routes, no schema migrations, no new skill files.

## Testing

1. **List view with roll-up measure**: Run `/rkit:scorecard` on a team with a roll-up measure → expect `[roll-up: sum]` or `[roll-up: avg]` badge on that measure row.
2. **List view without roll-up measures**: Run `/rkit:scorecard` normally → output unchanged.
3. **Record value on roll-up measure**: Run `/rkit:scorecard record "Total Revenue" 500` where "Total Revenue" is `data_source_type=3` → expect informational block, no API call.
4. **Record value on manual measure**: Unchanged — proceeds through confirmation and API call as before.
5. **api-reference.md review**: Open the file and confirm the Measure fields section and POST/PATCH bodies document all three new fields with valid values.
