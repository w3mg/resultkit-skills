# Quickstart: Strategy API Phase 2 Update

## What this feature does

Updates `api-reference.md` to document strategy endpoints (Phase 2 contract) and integrates the `rkit:strategy` skill into the plugin distribution.

## Key changes

### api-reference.md additions

A new **Strategy** section will be added covering:
- `GET /teams/{id}/strategy` — fetch strategy tree (no `?cascade=`)
- `POST /teams/{id}/strategy` — create object (no `object_type` in body)
- `PUT /strategy/align` — team-less align (no `link_type`)
- `PATCH /strategy/{type}/{id}` — team-less update
- `DELETE /strategy/{type}/{id}` — team-less detach (`parent_id`+`parent_type` required in body)

### Strategy skill integration

The `rkit:strategy` skill from `origin/001-strategy-skill` is merged into the main plugin. It is already Phase 2 compliant. No changes to SKILL.md required.

## Verification

After implementation, confirm:
1. `api-reference.md` contains a Strategy section with all 8 endpoints
2. `skills/strategy/` exists on main
3. `.claude-plugin/plugin.json` lists `strategy` in skills
4. `/sync-plugin` has been run (all skill copies updated)
5. No deprecated params (`cascade`, `object_type` in POST body, `link_type`, `?action=`) appear in skill SKILL.md

## Usage (after install)

```
/rkit:strategy                    # View team strategy tree
/rkit:strategy create "Rock" under "Annual Goal"
/rkit:strategy align "Rock" under "Annual Goal"
/rkit:strategy detach "Rock" from "Annual Goal"
/rkit:strategy detach "Rock" from "Annual Goal" --archive
/rkit:strategy update "Rock" status=complete
```
