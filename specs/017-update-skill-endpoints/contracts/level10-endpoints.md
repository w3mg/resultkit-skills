# Contract: rkit:level10 Endpoint Usage

All endpoints below use L10-specific routes. Team ID is resolved via `--team` flag or `default_team_id` config.

## Read Operations (no confirmation needed)

### View Full L10 Board

Fetches 5 sections in sequence:

```
GET /teams/{team_id}/l10/todos
GET /teams/{team_id}/l10/done
GET /teams/{team_id}/l10/issues
GET /teams/{team_id}/l10/parked
GET /teams/{team_id}/l10/headlines
```

Section display order: To-Dos, Done, Issues, Parked, Headlines.

### View Single Section

```
GET /teams/{team_id}/l10/todos     # arg: "todos"
GET /teams/{team_id}/l10/done      # arg: "done"
GET /teams/{team_id}/l10/issues    # arg: "issues"
GET /teams/{team_id}/l10/parked    # arg: "parked"
GET /teams/{team_id}/l10/headlines # arg: "headlines"
```

### Pre-Flight (all flows)

```
GET /teams/{team_id}               # Check framework == "eos"
```

### Item Lookup (move/done/remove flows)

```
GET /items/{item_id}               # Get current status and on_weekly flag
```

## Write Operations (confirmation required)

### Create To-Do

```
POST /teams/{team_id}/l10/todos
Body: { "name": "...", "due": "YYYY-MM-DD" (optional) }
```

### Create Issue

```
POST /teams/{team_id}/l10/issues
Body: { "name": "...", "due": "YYYY-MM-DD" (optional) }
```

### Create Headline

```
POST /teams/{team_id}/l10/headlines
Body: { "text": "...", "expires_at": "YYYY-MM-DD" (optional) }
```

### Mark Done

```
PUT /teams/{team_id}/l10/done/{item_id}
```

### Move to To-Dos

```
PUT /teams/{team_id}/l10/todos/{item_id}
```

### Move to Issues

```
PUT /teams/{team_id}/l10/issues/{item_id}
```

### Move to Parked (NEW)

```
PUT /teams/{team_id}/l10/parked/{item_id}
```

### Remove from L10 Board (NEW)

```
DELETE /teams/{team_id}/l10/items/{item_id}
```

### Archive Headline

```
DELETE /teams/{team_id}/headlines/{headline_id}
```

### Update Headline

```
PATCH /teams/{team_id}/headlines/{headline_id}
Body: { "text": "..." (optional), "expires_at": "YYYY-MM-DD" (optional) }
```
