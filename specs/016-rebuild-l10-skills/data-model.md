# Data Model: rkit:level10 Skill

No new entities are introduced. The level10 skill provides an EOS-specific interface to existing API objects.

## Entity → L10 Terminology Mapping

| API Entity | L10 Term | Status | L10 Route (GET/POST) | Generic Fallback (PUT/DELETE/PATCH) |
|-----------|----------|--------|----------------------|-------------------------------------|
| Item (status=next) | To-Do | next | `/teams/{id}/l10/todos` | `PUT /teams/{id}/items/{section}/{item_id}` |
| Item (status=blocked) | Issue | blocked | `/teams/{id}/l10/issues` | `PUT /teams/{id}/items/{section}/{item_id}` |
| Item (status=done) | Done To-Do | done | — (no L10 done route) | `PUT /teams/{id}/items/done/{item_id}` |
| Headline | Headline | — | `/teams/{id}/l10/headlines` | `DELETE/PATCH /teams/{id}/headlines/{id}` |

## State Transitions (L10 Context)

```
┌──────────┐    move     ┌──────────┐
│  To-Do   │◄──────────►│  Issue   │
│ (next)   │            │(blocked) │
└────┬─────┘            └────┬─────┘
     │ done                  │ done
     ▼                       ▼
┌──────────┐            ┌──────────┐
│   Done   │            │   Done   │
│  (done)  │            │  (done)  │
└──────────┘            └──────────┘
```

Transitions use `PUT /teams/{id}/items/{section}/{item_id}`:
- To-Do → Issue: `PUT .../items/blocked/{item_id}`
- Issue → To-Do: `PUT .../items/next/{item_id}` (auto-sets 7-day due if null)
- To-Do → Done: `PUT .../items/done/{item_id}`
- Issue → Done: `PUT .../items/done/{item_id}`

## Response Shapes

**L10 To-Dos / Issues** (paginated Item list):
```json
{
  "data": [
    {
      "id": 415,
      "name": "Review Q1 plan",
      "status": "next",
      "due": "2026-03-07",
      "on_weekly": true,
      "creator": { "id": 1, "login": "pat", "first_name": "Pat", "last_name": "A" },
      "assignees": [],
      "team": { "id": 42, "name": "Leadership" },
      "parent_id": null,
      "created_at": "2026-02-28T10:00:00Z",
      "updated_at": "2026-02-28T10:00:00Z"
    }
  ],
  "meta": { "page": 1, "per_page": 100, "total": 5, "total_pages": 1 }
}
```

**L10 Headlines** (paginated Headline list):
```json
{
  "data": [
    {
      "id": 201,
      "text": "New client signed",
      "creator": { "id": 1, "login": "pat", "first_name": "Pat", "last_name": "A" },
      "expires_at": "2026-03-07",
      "created_at": "2026-02-28T10:00:00Z",
      "updated_at": "2026-02-28T10:00:00Z"
    }
  ],
  "meta": { "page": 1, "per_page": 100, "total": 3, "total_pages": 1 }
}
```

## EOS Framework Gate

The level10 skill requires `team.framework == "eos"`. Checked via `GET /teams/{id}` response field `framework`. Non-EOS teams receive: "Level 10 is only available for teams using the EOS framework. Use `/rkit:weekly` instead."
