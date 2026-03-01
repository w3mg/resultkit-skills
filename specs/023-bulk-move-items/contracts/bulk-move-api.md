# API Contract: PATCH /items/bulk-move

**Branch**: `023-bulk-move-items` | **Date**: 2026-03-01

## Endpoint

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| PATCH | `/items/bulk-move` | Bearer token | Move up to 1000 items under a target parent |

## Request Body

```json
{
  "item_ids": [1, 2, 3, 4, 5],
  "parent_id": 100
}
```

| Field | Type | Required | Constraints |
|-------|------|----------|-------------|
| `item_ids` | integer[] | Yes | 1–1000 items |
| `parent_id` | integer | Yes | Must exist, user must have view access |

## Response (200)

```json
{
  "data": {
    "moved": 4,
    "failed": 1,
    "errors": [
      { "id": 3, "reason": "forbidden" }
    ]
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `moved` | integer | Count of successfully moved items |
| `failed` | integer | Count of items that could not be moved |
| `errors` | array | Per-item failure details |
| `errors[].id` | integer | Item ID that failed |
| `errors[].reason` | string | Failure reason: `not_found`, `forbidden`, `self_reference` |

## Error Responses

| Status | Code | Cause | Skill Message |
|--------|------|-------|---------------|
| 401 | `unauthorized` | Invalid/expired token | "Unauthorized (401). Run `/rkit:setup` to update your token." |
| 403 | `forbidden` | User cannot access target parent | "Access denied to parent item (403)." |
| 404 | `not_found` | Target parent not found | "Parent item not found (404)." |
| 422 | `validation_error` | Empty item_ids, exceeds 1000, or missing parent_id | Show validation error from response body |

## Behavior Notes

- Items already under the target parent are silently counted as `moved` (no-op).
- Duplicate `item_ids` are deduplicated server-side.
- If `parent_id` is in `item_ids`, that item is rejected with `self_reference`.
- Items are removed from ALL weekly board placements after being moved.
