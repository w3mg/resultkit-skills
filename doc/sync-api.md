# Sync API Reference

Update `api-reference.md` from the live ResultMaps OpenAPI spec.

## Usage

```bash
# 1. Fetch the live spec
bash scripts/fetch-openapi.sh > /tmp/openapi-v2.json

# 2. List all endpoints
jq '.paths | keys[]' /tmp/openapi-v2.json

# 3. Compare against current reference and update api-reference.md
```

## Exclusions

These endpoints exist in the live spec but are **excluded by project decision** — do not add them to `api-reference.md`:

- `/projects` and all `/projects/{id}/*` routes (top-level project CRUD)
- `/teams/{id}/projects/next`
- `/teams/{id}/projects/done`
- `/teams/{id}/projects/issues`

## Workflow

1. Run `scripts/fetch-openapi.sh` to pull the live spec
2. Compare paths, params, and schemas against `api-reference.md`
3. Update `api-reference.md` with changes (respecting exclusions)
4. Run `scripts/deploy.sh` to sync and install

## Useful jq queries

```bash
# All endpoint paths
jq '.paths | keys[]' /tmp/openapi-v2.json

# Methods for a specific path
jq '.paths["/items"]' /tmp/openapi-v2.json

# All schema names
jq '.components.schemas | keys[]' /tmp/openapi-v2.json

# A specific schema
jq '.components.schemas.Item' /tmp/openapi-v2.json
```
