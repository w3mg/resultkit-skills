# Data Model: Result Feed API 077 Tier 1 Update

**Branch**: `041-result-feed-tier1-gh109`
**Date**: 2026-04-28

## Updated Schemas

### ResultFeedSection

All four sections (`done`, `review`, `next`, `blocked`) follow this shape:

```json
{
  "items": [Item, ...],
  "notes": "Free-text notes or null",
  "attachments": [
    { "id": 42, "filename": "spec.pdf", "url": "https://..." }
  ]
}
```

**Change from prior state**: `review` section is now included (was omitted).

---

### TeamResultFeed

```json
{
  "id": 42,
  "date": "2026-04-26",
  "is_completed": true,
  "user": { "id": 1, "login": "pat", "first_name": "Pat", "last_name": "A" },
  "done":    { "items": [...], "notes": "string or null", "attachments": [...] },
  "review":  { "items": [...], "notes": null, "attachments": [] },
  "next":    { "items": [...], "notes": null, "attachments": [] },
  "blocked": { "items": [...], "notes": null, "attachments": [] }
}
```

**Change from prior state**: `review` section added.

---

### Reaction

```json
{
  "reacted": true,
  "count": 3
}
```

**Change from prior state**: Fields renamed from `user_has_reacted` / `high_five_count`.

---

### Attachment (Upload Response)

```json
{
  "id": 101,
  "filename": "screenshot.png",
  "content_type": "image/png",
  "filesize": 45000
}
```

**New in API 077**: Returned by `POST /result-feed/{date}/attachments`.

---

### Comment

```json
{
  "id": 99,
  "comment": "Great work on the auth ticket!",
  "user_id": 1,
  "created_at": "2026-04-26T14:00:00Z"
}
```

**Change from prior state**: Text field is `comment` (not `body`).

---

## Valid Section Names

| Name | Description |
|------|-------------|
| `done` | Items completed |
| `review` | Items awaiting manager sign-off (NEW) |
| `next` | Items planned for next period |
| `blocked` | Items blocked |

## Endpoint Parameters

### POST /result-feed/{date}/reactions

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `user_id` | integer | no | Whose report to react to; defaults to authenticated user |

### POST /result-feed/{date}/push-to-slack
### POST /result-feed/{date}/push-to-discord

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `group_context_id` | integer | yes | Team/group ID to push to |
| `exclude_item_ids` | integer[] | no | Items to exclude from the push |

### PUT /result-feed/{date}/{section}/{item_id}

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `notes` | string | no | Free-text notes for the item |
| `attachment_ids` | integer[] | no | IDs of uploaded documents to attach |
