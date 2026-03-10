# API Contracts: Team Logo Endpoints

**Branch**: `033-team-logo-url-27` | **Date**: 2026-03-09

These are the upstream ResultMaps API contracts that this feature integrates with.
Skills are consumers of these endpoints, not providers.

---

## GET /api/v2/teams (updated)

Returns a list of teams. Now includes `logo_url` field on every team object.

**Response 200**:
```json
{
  "data": [
    {
      "id": 42,
      "name": "Product Team",
      "organization_name": "Acme Corp",
      "organization_id": 1,
      "is_default": true,
      "is_muted": false,
      "framework": "eos",
      "description": null,
      "logo_url": "https://cdn.filestackcontent.com/abc123handle",
      "creator": { "id": 5, "display_name": "Alice" },
      "created_at": "2024-01-01T00:00:00.000Z",
      "updated_at": "2026-01-10T12:00:00.000Z"
    }
  ],
  "meta": { "page": 1, "per_page": 100, "total": 1, "total_pages": 1 }
}
```

`logo_url` is `null` when no logo is set.

---

## GET /api/v2/teams/:id (updated)

Returns a single team's detail. Now includes `logo_url`.

**Response 200**:
```json
{
  "data": {
    "id": 42,
    "name": "Product Team",
    "framework": "eos",
    "logo_url": "https://cdn.filestackcontent.com/abc123handle",
    "creator": { "id": 5, "display_name": "Alice" },
    "members": [...]
  }
}
```

---

## POST /api/v2/teams/:id/logo (breaking change)

Sets or replaces the team logo URL. **Upsert** — submitting again replaces the existing URL.

**Request**:
```
POST /api/v2/teams/42/logo
Authorization: Bearer TOKEN
Content-Type: application/json

{ "logo_url": "https://cdn.filestackcontent.com/abc123handle" }
```

**Response 200**:
```json
{ "data": { "logo_url": "https://cdn.filestackcontent.com/abc123handle" } }
```

**Response 422** (validation failure):
```json
{ "errors": { "logo_url": ["is invalid"] } }
```
Triggered when `logo_url` does not start with `https://cdn.filestackcontent.com/`.

**Response 403**: Non-admin user attempted the operation.

**Authorization**: Admin-only.

---

## DELETE /api/v2/teams/:id/logo (new)

Removes the team logo URL. Idempotent — returns 200 even if no logo was stored.

**Request**:
```
DELETE /api/v2/teams/42/logo
Authorization: Bearer TOKEN
```

**Response 200**:
```json
{ "data": { "logo_url": null } }
```

**Response 403**: Non-admin user attempted the operation.

**Authorization**: Admin-only.

---

## Skill Command Contracts

These are the natural language patterns the `rkit:teams` skill will accept for logo operations.

### Set Logo

| Input pattern | Action |
|---------------|--------|
| `logo set {team_id} {url}` | Set logo for specified team |
| `logo set {url}` | Set logo for default team |
| `set logo {team_id} {url}` | Alias |
| `set logo {url}` | Alias using default team |

**Confirmation required**: Yes — show team name, ID, and URL before executing.

**Post-action output**:
```
Logo set for team #42 (Product Team): https://cdn.filestackcontent.com/abc123handle
```

### Remove Logo

| Input pattern | Action |
|---------------|--------|
| `logo remove {team_id}` | Remove logo for specified team |
| `logo remove` | Remove logo for default team |
| `remove logo {team_id}` | Alias |
| `remove logo` | Alias using default team |

**Confirmation required**: Yes — show team name, ID before executing.

**Post-action output**:
```
Logo removed for team #42 (Product Team).
```
