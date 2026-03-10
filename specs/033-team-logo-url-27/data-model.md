# Data Model: Team Logo URL Support

**Branch**: `033-team-logo-url-27` | **Date**: 2026-03-09

## Entities

### Team (updated)

Represents a ResultMaps team. The `logo_url` field is new.

| Field | Type | Description |
|-------|------|-------------|
| `id` | integer | Unique team identifier |
| `name` | string | Team display name |
| `organization_name` | string | Parent organization name |
| `organization_id` | integer | Parent organization ID |
| `framework` | string \| null | Management framework (`eos`, `okr`, `4dx`, `v2mom`, `srt`, `svep`) |
| `description` | string \| null | Team description |
| `is_default` | boolean | Whether this is the user's default team |
| `is_muted` | boolean | Whether the current user has muted this team |
| `logo_url` | string \| null | **NEW** — Filestack CDN URL for the team logo, or `null` if none set |
| `creator` | UserSimple | User who created the team |
| `created_at` | ISO 8601 string | Creation timestamp |
| `updated_at` | ISO 8601 string | Last updated timestamp |

`logo_url` format: `https://cdn.filestackcontent.com/{handle}` — always starts with this prefix when not null.

### TeamLogo (operation result)

Returned by `POST /teams/:id/logo` and `DELETE /teams/:id/logo`.

| Field | Type | Description |
|-------|------|-------------|
| `logo_url` | string \| null | The updated logo URL after the operation |

Response envelope: `{ "data": { "logo_url": "..." } }`

## State Transitions

```
Team logo state:
  null  ──POST /logo──►  "https://cdn.filestackcontent.com/{handle}"
  "url" ──POST /logo──►  "https://cdn.filestackcontent.com/{new_handle}"  (upsert)
  "url" ──DELETE /logo──► null
  null  ──DELETE /logo──► null  (idempotent, still 200)
```

## Validation Rules

| Rule | Enforcement |
|------|------------|
| `logo_url` must start with `https://cdn.filestackcontent.com/` | Server-side, returns 422 on violation |
| Empty string is not valid | Server-side, returns 422 |
| HTTP (not HTTPS) URL is not valid | Server-side, returns 422 |
| Wrong domain is not valid | Server-side, returns 422 |
| Only team admins can set or remove logo | Server-side, returns 403 for non-admins |

## API Reference Additions

The following entries need to be added to `api-reference.md` under the Teams section:

1. Add `logo_url` to the field list for `GET /teams` and `GET /teams/:id` responses
2. Add `POST /teams/{id}/logo` — set logo (JSON body)
3. Add `DELETE /teams/{id}/logo` — remove logo
