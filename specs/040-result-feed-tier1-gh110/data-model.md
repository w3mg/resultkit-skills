# Data Model: Daily Update API v2 — Tier 1 Backend Gap Coverage

**Date**: 2026-04-27 | **Branch**: `040-result-feed-tier1-gh110`

## Entity Changes

### ResultFeedSection (CHANGED)

Previously a flat array of Items. Now an object:

| Field | Type | Description |
|-------|------|-------------|
| `items` | Item[] | Items in this section |
| `notes` | string \| null | Free-text notes for this section |
| `attachments` | Attachment[] | Files attached to this section |

### Attachment (NEW)

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Attachment ID |
| `filename` | string | Original filename |
| `url` | string | Download URL |

### ResultFeed (CHANGED)

| Field | Type | Change |
|-------|------|--------|
| `done` | ResultFeedSection | Was Item[], now object |
| `next` | ResultFeedSection | Was Item[], now object |
| `blocked` | ResultFeedSection | Was Item[], now object |

All other fields unchanged: `id`, `date`, `is_completed`.

### Comment (NEW)

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Comment ID |
| `body` | string | Comment text (≤ 10,000 chars) |
| `user_id` | integer | Author's user ID |
| `created_at` | ISO 8601 | Creation timestamp |

### Reaction (NEW — response-only)

Not a persisted entity; returned from the react endpoint:

| Field | Type | Description |
|-------|------|-------------|
| `high_five_count` | integer | Total reactions on the report |
| `user_has_reacted` | boolean | Whether the caller has reacted |

### Team (CHANGED)

| Field | Type | Change |
|-------|------|--------|
| `has_slack_webhook` | boolean | NEW — team has a Slack webhook configured |
| `has_discord_webhook` | boolean | NEW — team has a Discord webhook configured |

## State Transitions

### Reaction Toggle

```
No reaction → POST /react → user_has_reacted: true, count +1
Has reaction → POST /react → user_has_reacted: false, count -1
```

### Section Notes

```
No notes → PUT /section { notes: "text" } → notes: "text"
Has notes → PUT /section { notes: null } → notes: null (cleared)
Has notes → PUT /section { notes: "new" } → notes: "new" (replaced)
```
