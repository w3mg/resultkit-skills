# Contract: Align (Link) Strategy Object

## Endpoint

`PUT /strategy/align`

## Request Body

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `object_id` | integer | Yes | ID of the object to link |
| `object_type` | string | Yes | Object's `object_type` from GET response |
| `parent_id` | integer | Yes | ID of the parent to link to |
| `parent_type` | string | Yes | Parent's `object_type` from GET response |

## Response (200)

Success response.

## Skill Usage

- The skill resolves both object and parent by name from the tree.
- Derives `object_type` and `parent_type` from the matched nodes automatically.
- Typically used to move unaligned items into the tree or re-parent existing items.

## Notes

- Both object and parent must exist in the same team's strategy.
- The correct link type (e.g., GoalToGoal, GoalToItem) is determined automatically by the API.
- `object_type` and `parent_type` accept the `object_type` values from GET (e.g., "rock", "yearly_goal", "key_result"). Also accepts generic "Goal" and "Item".
