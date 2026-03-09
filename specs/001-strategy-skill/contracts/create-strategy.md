# Contract: Create Strategy Object

## Endpoint

`POST /teams/{id}/strategy`

## Request Body

| Field | Type | Required | Default | Description |
|-------|------|----------|---------|-------------|
| `name` | string | Yes | — | Object name |
| `description` | string | No | null | Description |
| `status` | string | No | "active" | Initial status |
| `due` | string (YYYY-MM-DD) | No | null | Due date |
| `assignees` | integer[] | No | [] | User IDs to assign |
| `parent_id` | integer | No | null | Parent object ID (omit for root-level) |
| `parent_type` | string | No | null | Parent's `object_type` from GET response |
| `is_focus_area` | boolean | No | false | OKR/4DX: create focus area at root level |

## Response (201)

```json
{
  "data": {
    "id": 42,
    "object_type": "rock"
  }
}
```

## Skill Usage

- Root-level: `POST /teams/{id}/strategy` with `{ "name": "Annual Goal" }`
- As child: `POST /teams/{id}/strategy` with `{ "name": "New Rock", "parent_id": 6520, "parent_type": "yearly_goal" }`
- Focus area: `POST /teams/{id}/strategy` with `{ "name": "Revenue", "is_focus_area": true }`

## Notes

- The API auto-determines the correct `object_type` based on the team's framework and the parent's type.
- `parent_type` uses the `object_type` value from the GET response (e.g., "yearly_goal", "objective").
- The skill resolves parent by name, derives `parent_id` and `parent_type` automatically.
