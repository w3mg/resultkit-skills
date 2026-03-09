# Contract: Detach Strategy Object

## Endpoint

`DELETE /strategy/{objectType}/{objectId}`

## URL Parameters

| Param | Type | Description |
|-------|------|-------------|
| `objectType` | string | The node's `object_type` from GET response |
| `objectId` | integer | The node's `id` |

## Request Body

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `parent_id` | integer | Yes | — | ID of the parent to detach from |
| `parent_type` | string | Yes | — | Parent's `object_type` from GET response |
| `also_archive` | boolean | No | false | When true, also archive the object after unlinking |

## Response (204 No Content)

Empty body.

## Skill Usage

- The skill resolves both the object and parent by name from the tree.
- Derives `objectType`, `objectId`, `parent_id`, and `parent_type` automatically.
- User specifies `--archive` flag to set `also_archive: true`.

## Notes

- The object is kept after detaching — it appears in the "unaligned" list.
- With `also_archive: true`, the object is archived (won't appear even in unaligned).
- Inherited nodes return 403 — the skill blocks these before calling.
