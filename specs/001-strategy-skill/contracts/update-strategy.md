# Contract: Update Strategy Object

## Endpoint

`PATCH /strategy/{objectType}/{objectId}`

## URL Parameters

| Param | Type | Description |
|-------|------|-------------|
| `objectType` | string | The node's `object_type` from GET response (e.g., "rock", "yearly_goal") |
| `objectId` | integer | The node's `id` |

## Request Body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | No | New name |
| `description` | string | No | New description |
| `status` | string | No | New status (active, complete, archived, deferred, etc.) |
| `due` | string (YYYY-MM-DD) | No | New due date |
| `assignees` | integer[] | No | Replaces all assignees (send full list, `[]` to clear) |

## Response (200)

Success response (exact shape TBD — no body structure documented; treat as acknowledgment).

## Skill Usage

- The skill resolves the object by name, extracts `object_type` and `id` from the tree, then calls `PATCH /strategy/{object_type}/{id}`.
- User never specifies `objectType` directly.
- For assignees, the skill can resolve user names to IDs via `GET /teams/{id}/members` if needed.

## Notes

- Inherited nodes (inherited: true) will return 403 — the skill blocks these before calling.
- At least one field must be provided in the body.
