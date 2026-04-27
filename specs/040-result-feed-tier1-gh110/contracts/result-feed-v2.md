# API Contracts: Result Feed Tier 1 Endpoints

## Changed Endpoints

### GET /api/v2/result-feed/{date}

**Change**: Section fields (`done`, `next`, `blocked`) changed from `Item[]` to `{ items: Item[], notes: string|null, attachments: Attachment[] }`.

**Response** (200):
```json
{
  "data": {
    "id": 42,
    "date": "2026-04-27",
    "is_completed": false,
    "done": {
      "items": [{ "id": 1, "name": "..." }],
      "notes": "Shipped the auth refactor.",
      "attachments": [{ "id": 42, "filename": "spec.pdf", "url": "https://..." }]
    },
    "next": { "items": [], "notes": null, "attachments": [] },
    "blocked": { "items": [], "notes": null, "attachments": [] }
  }
}
```

### GET /api/v2/teams/{id} (additive)

**Change**: Response now includes `has_slack_webhook` and `has_discord_webhook` booleans.

---

## New Endpoints

### PUT /api/v2/result-feed/{date}/{section}

Update section-level metadata.

**Request**:
```json
{ "notes": "Free text or null to clear", "attachment_ids": [42, 57] }
```

**Response** (200):
```json
{ "data": { "success": true } }
```

### POST /api/v2/result-feed/{date}/push-to-slack

Push check-in to team's Slack webhook.

**Request**:
```json
{ "team_id": 5, "exclude_item_ids": [101, 102] }
```

**Responses**: 200 (success), 422 (no webhook), 502 (webhook error), 403 (not a member)

### POST /api/v2/result-feed/{date}/push-to-discord

Same contract as push-to-slack, targets Discord.

### POST /api/v2/result-feed/{date}/react

Toggle high-five reaction. No request body.

**Response** (200):
```json
{ "data": { "high_five_count": 3, "user_has_reacted": true } }
```

### GET /api/v2/result-feed/{date}/comments

List comments on a report.

**Response** (200):
```json
{
  "data": [
    { "id": 12, "body": "Nice work!", "user_id": 7, "created_at": "2026-04-26T14:00:00Z" }
  ]
}
```

### POST /api/v2/result-feed/{date}/comments

Add a comment.

**Request**:
```json
{ "body": "Nice work!" }
```

**Response** (201): Created comment object.

**Validation**: `body` required, non-empty, ≤ 10,000 characters.

### GET /api/v2/teams/{id}/result-feed/{date}/{user_id}

View a specific user's report for a date.

**Response** (200):
```json
{
  "data": {
    "report": { "...same shape as GET /result-feed/{date}..." },
    "is_quiet": false
  }
}
```

**Responses**: 403 (not a member), 404 (no report)

### POST /api/v2/users/me/group-context

Set active group context.

**Request**:
```json
{ "group_id": 5 }
```

**Response** (200):
```json
{ "data": { "success": true } }
```
