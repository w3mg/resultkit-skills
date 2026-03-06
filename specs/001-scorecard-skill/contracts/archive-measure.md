# Contract: Archive Measure

**Endpoint**: `DELETE /api/v2/measures/:id`
**User Story**: US4 — Update or Archive a Measure
**Auth**: canEditGroup

## Request

```bash
bash scripts/api.sh DELETE "/measures/$MEASURE_ID"
```

**Behavior**: Soft-deletes the measure (`is_archived = true`). Idempotent — archiving an already-archived measure succeeds.

## Response (200)

```json
{
  "data": {
    "id": 1,
    "name": "Weekly Signups",
    "is_archived": true
  }
}
```

Note: Response does NOT include `histories`.

## Alternative: PATCH with archived flag

The same effect can be achieved via `PATCH /measures/:id` with `{ "measure": { "archived": true } }`.
The skill uses `DELETE` for the `archive` subcommand (cleaner semantics) and exposes restore via `update --restore`.

## Skill Flow

1. Resolve measure name → measure ID.
2. Show confirmation: `Archive "Weekly Signups" (ID: 1)? It will be hidden from the default scorecard view. [y/N]`
3. On confirm: DELETE, show confirmation message.

## Error Handling

| Code | Meaning | Skill Response |
|------|---------|----------------|
| 404 | Measure not found | "Measure ID {id} not found." |
| 403 | No edit access | "You don't have permission to archive this measure." |
