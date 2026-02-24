# API Contracts: rkit:headlines

All calls go through `scripts/api.sh METHOD PATH [BODY]`.

## US1 — View Headlines

| Step | Method | Path | Body | Response |
|------|--------|------|------|----------|
| Fetch team detail | GET | `/teams/{team_id}` | — | `{ data: { id, name, framework, ... } }` |
| Fetch headlines | GET | `/teams/{team_id}/headlines?per_page=100` | — | `{ data: [Headline], meta: { page, per_page, total, total_pages } }` |

**Notes**: Team detail fetch is needed to display team name and confirm EOS framework. If team is not EOS, the headlines endpoint returns 422.

## US2 — Add Headline

| Step | Method | Path | Body | Response |
|------|--------|------|------|----------|
| Create headline | POST | `/teams/{team_id}/headlines` | `{"text": "...", "expires_at": "YYYY-MM-DD"}` | `{ data: Headline }` (status 201) |

**Notes**: `expires_at` defaults to 7 days from today if not provided by user. `text` is required, non-empty.

## US3 — Archive Headline

| Step | Method | Path | Body | Response |
|------|--------|------|------|----------|
| Archive headline | DELETE | `/teams/{team_id}/headlines/{headline_id}` | — | `204 No Content` |

**Notes**: Sets `expires_at` to user's local today. Returns 403 if user is not creator or team admin. Returns 404 if headline doesn't exist or belongs to a different team.

## US4 — Update Headline

| Step | Method | Path | Body | Response |
|------|--------|------|------|----------|
| Update headline | PATCH | `/teams/{team_id}/headlines/{headline_id}` | `{"text": "...", "expires_at": "YYYY-MM-DD"}` | `{ data: Headline }` (status 200) |

**Notes**: At least one field required. Returns 422 if empty body. Returns 403 if user is not creator or team admin.

## Shared: Team ID Resolution

| Condition | Action |
|-----------|--------|
| `--team {id}` flag in args | Use that team ID |
| `default_team_id` in config | Use that |
| Neither | "No default team configured. Run `/rkit:setup` first." |

## Shared: Error Responses

| Status | Meaning | User Message |
|--------|---------|-------------|
| 401 | Unauthorized | "Unauthorized (401). Run `/rkit:setup` to update your token." |
| 403 | Forbidden | Show API error message (permission denied) |
| 404 | Not found | "Team/Headline not found." |
| 422 | Validation error | Show API error (non-EOS team, blank text, invalid date, etc.) |

## Headline Object Shape

```json
{
  "id": 201,
  "text": "New client signed",
  "creator": {
    "id": 1,
    "login": "jsmith",
    "first_name": "John",
    "last_name": "Smith"
  },
  "expires_at": "2026-03-03",
  "created_at": "2026-02-24T16:00:00.000Z",
  "updated_at": "2026-02-24T16:00:00.000Z"
}
```
