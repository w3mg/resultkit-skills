# Quickstart: Goals, Rocks & Milestones API Migration

**Branch**: `038-goals-rocks-api-40` | **Date**: 2026-03-18

## What Changed

The ResultMaps API replaced the generic strategy mutation endpoints with typed CRUD endpoints for goals, rocks, and milestones (EOS only). The read endpoint was renamed from `strategy` to `targets`.

## Files to Modify

1. **`api-reference.md`** — Replace the Strategy section: rename GET endpoint, remove 7 old mutation endpoints, add 14 new typed endpoints, update glossary entries
2. **`skills/strategy/SKILL.md`** — Update all API calls in the 5 flows (view, create, update, align, detach)
3. **All skill copies** — Run `/sync-plugin` to propagate api-reference.md changes

## Endpoint Migration Map

| Old Endpoint | New Endpoint(s) |
|-------------|-----------------|
| `GET /teams/{id}/strategy` | `GET /teams/{id}/targets` |
| `POST /teams/{id}/strategy` | `POST /teams/{id}/goals`, `/rocks`, `/milestones` |
| `PATCH /strategy/{type}/{id}` | `PATCH /goals/{id}`, `/rocks/{id}`, `/milestones/{id}` |
| `DELETE /strategy/{type}/{id}` | `DELETE /goals/{id}`, `/rocks/{id}`, `/milestones/{id}` (archives) |
| `PUT /strategy/align` | `PUT /rocks/{id}`, `PUT /milestones/{id}` (set parent_id) |

## SKILL.md Flow Changes

### View: No logic change, just URL
```bash
# Old
"$API_SH" GET "/teams/$TEAM_ID/strategy?year=$YEAR&quarter=$QUARTER"
# New
"$API_SH" GET "/teams/$TEAM_ID/targets?year=$YEAR&quarter=$QUARTER"
```

### Create: Route by type
```bash
# Old (single endpoint, auto-inferred type)
"$API_SH" POST "/teams/$TEAM_ID/strategy" '{"name":"...","parent_id":PID}'
# New (typed endpoints)
"$API_SH" POST "/teams/$TEAM_ID/goals" '{"name":"...","achieve_by":"..."}'
"$API_SH" POST "/teams/$TEAM_ID/rocks" '{"name":"...","parent_id":GID}'
"$API_SH" POST "/teams/$TEAM_ID/milestones" '{"name":"...","parent_id":RID,"due":"..."}'
```

### Update: Route by object_type
```bash
# Old
"$API_SH" PATCH "/strategy/$OBJECT_TYPE/$OBJECT_ID" '{"name":"..."}'
# New
"$API_SH" PATCH "/goals/$ID" '{"name":"..."}'    # if object_type == yearly_goal
"$API_SH" PATCH "/rocks/$ID" '{"name":"..."}'    # if object_type == rock
"$API_SH" PATCH "/milestones/$ID" '{"name":"..."}' # if object_type == milestone
```

### Align: Simplified
```bash
# Old (4 params)
"$API_SH" PUT "/strategy/align" '{"object_id":OID,"object_type":"...","parent_id":PID,"parent_type":"..."}'
# New (just parent_id)
"$API_SH" PUT "/rocks/$RID" '{"parent_id":GID}'         # align rock to goal
"$API_SH" PUT "/milestones/$MID" '{"parent_id":RID}'    # align milestone to rock
```

### Detach: Split into unlink vs archive
```bash
# Old (single endpoint with also_archive flag)
"$API_SH" DELETE "/strategy/$TYPE/$ID" '{"parent_id":PID,"parent_type":"...","also_archive":false}'
# New: unlink (move to unaligned)
"$API_SH" PATCH "/rocks/$ID" '{"parent_id":null}'       # or /goals or /milestones
# New: archive
"$API_SH" DELETE "/rocks/$ID"                             # or /goals or /milestones
```

## Gotchas

1. **EOS only**: All new CRUD endpoints return 422 for non-EOS teams. View still works for all frameworks.
2. **Milestone filters**: Do NOT use `?year=&quarter=` — use `?parent_id=ROCK_ID` instead (known bug).
3. **Field names**: Use `type` (not `goal_type`) and `color` (not `progress_color`).
4. **No `updated_at` on milestones**: Milestone responses omit this field.
5. **DELETE = archive**: No more "unlink" option on DELETE. To unlink, use PATCH with `parent_id: null`.
