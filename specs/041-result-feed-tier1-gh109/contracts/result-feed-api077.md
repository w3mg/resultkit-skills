# API Contracts: Result Feed API 077 Changes

**Branch**: `041-result-feed-tier1-gh109`
**Date**: 2026-04-28

## Changed Endpoints

### POST /result-feed/{date}/reactions *(was: /react)*

Toggle a high-five reaction on a report.

```
POST /api/v2/result-feed/{date}/reactions
Authorization: Bearer {token}
Content-Type: application/json

Body (optional):
{ "user_id": 5 }          // Whose report to react to; defaults to authenticated user

Response 200:
{ "data": { "reacted": true, "count": 3 } }
```

Call again to unreact → `{ "reacted": false, "count": 2 }`

---

### GET /result-feed/{date}/reactions *(new)*

Get the reaction state on a report without toggling.

```
GET /api/v2/result-feed/{date}/reactions?user_id=5
Authorization: Bearer {token}

Response 200:
{ "data": { "reacted": false, "count": 2 } }
```

---

### PUT /result-feed/{date}/{section}/{item_id} *(extended)*

Add existing item to section. Now also accepts optional notes and attachments.

```
PUT /api/v2/result-feed/{date}/{section}/{item_id}
Authorization: Bearer {token}
Content-Type: application/json

Body (all optional):
{
  "notes": "Finished the login flow. Needs QA.",
  "attachment_ids": [101, 102]
}

Valid sections: done | review | next | blocked

Response 200: { "data": { ...item } }
```

---

### POST /result-feed/{date}/attachments *(new)*

Upload a file attachment for a result-feed report.

```
POST /api/v2/result-feed/{date}/attachments
Authorization: Bearer {token}
Content-Type: multipart/form-data

Body: file=<binary>   // Max 4.5 MB

Response 201:
{ "data": { "id": 101, "filename": "screenshot.png", "content_type": "image/png", "filesize": 45000 } }

Error 400: { "error": "file is required" }
Error 413: { "error": "file too large (max 4.5 MB)" }
```

---

### POST /result-feed/{date}/push-to-slack *(body param changed)*

```
POST /api/v2/result-feed/{date}/push-to-slack
Authorization: Bearer {token}
Content-Type: application/json

Body:
{
  "group_context_id": 42,          // Required (was: team_id)
  "exclude_item_ids": [5, 7]       // Optional
}

Response 200: { "data": { "pushed": true } }
Error 422: No webhook configured or report not submitted
Error 502: Webhook delivery failed
Error 403: Not authorized (not a member)
```

---

### POST /result-feed/{date}/push-to-discord *(body param changed)*

Same as push-to-slack but targets Discord webhook:

```
POST /api/v2/result-feed/{date}/push-to-discord
Body: { "group_context_id": 42, "exclude_item_ids": [5, 7] }
```

---

## GET Response Shape (confirmed current)

`GET /result-feed/{date}` sections are structured objects (not flat arrays):

```json
{
  "done":    { "items": [...], "notes": "string|null", "attachments": [...] },
  "review":  { "items": [...], "notes": null,          "attachments": [] },
  "next":    { "items": [...], "notes": null,          "attachments": [] },
  "blocked": { "items": [...], "notes": null,          "attachments": [] }
}
```

---

## Comments Response (field name clarified)

```json
// GET /result-feed/{date}/comments?user_id=N
{ "data": [{ "id": 99, "comment": "text here", "user_id": 1, "created_at": "..." }] }

// POST /result-feed/{date}/comments
// Body: { "body": "comment text", "user_id": 5 }
// Response 201: { "data": { "id": 99, "comment": "comment text", "user_id": 1, "created_at": "..." } }
```

Note: Request body uses field `body`; response object uses field `comment`.
