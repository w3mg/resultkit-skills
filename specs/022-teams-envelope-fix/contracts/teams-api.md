# API Contract: GET /teams Response Change

**Branch**: `022-teams-envelope-fix` | **Date**: 2026-03-01

## Endpoint

| Method | Path | Change Type |
|--------|------|-------------|
| GET | `/teams` | BREAKING — response format changed |

## Before (bare array)

```json
[
  { "id": 10, "name": "Engineering", "framework": "eos", "is_default": true, ... },
  { "id": 20, "name": "Product", "framework": "okr", "is_default": false, ... }
]
```

## After (data envelope)

```json
{
  "data": [
    { "id": 10, "name": "Engineering", "framework": "eos", "is_default": true, ... },
    { "id": 20, "name": "Product", "framework": "okr", "is_default": false, ... }
  ]
}
```

## Impact on Skills

### rkit:teams (SKILL.md)

| Location | Before | After |
|----------|--------|-------|
| Step 3 parsing | Access `body` directly as array | Access `body.data` as array |
| Documentation | "flat JSON array (not wrapped in data/meta)" | "standard data envelope" |

### rkit:setup (SKILL.md)

| Location | Before | After |
|----------|--------|-------|
| Step 4 (first-time) | Parse curl response body as bare array | Parse `data` field from response body |
| Option 2 (reconfigure) | Parse curl response body as bare array | Parse `data` field from response body |
| Documentation | "flat JSON array (not wrapped in data)" | "standard data envelope" |

## New Error Code

| Status | Code | Response |
|--------|------|----------|
| 500 | `internal_error` | `{ "error": { "code": "internal_error", "message": "Internal server error" } }` |

Applies to: `GET /reviews`, `GET /review-templates`, `GET /core-values`, `GET /teams`.
