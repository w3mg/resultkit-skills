# Quickstart: Daily Update API v2 — Tier 1 Backend Gap Coverage

## What's Changing

1. **Breaking**: Result-feed sections (`done`/`next`/`blocked`) are now objects, not arrays
2. **New**: 8 new endpoints for section metadata, reactions, comments, webhook push, team detail, group context
3. **Changed**: Team endpoint now returns webhook presence flags

## Files to Modify

| File | Change |
|------|--------|
| `api-reference.md` | Update result-feed section docs, add 8 new endpoints, add team webhook flags |
| `skills/result-feed/SKILL.md` | Fix section parsing, add new tool routes for all new endpoints |
| `skills/today/SKILL.md` | No changes needed (uses day-plan endpoints, not result-feed) |

## Implementation Order

1. Update `api-reference.md` with all new/changed endpoint docs
2. Fix `skills/result-feed/SKILL.md` section parsing (breaking change)
3. Add new tool routes to `skills/result-feed/SKILL.md`
4. Run `/sync-plugin` to copy api-reference.md to all skills
5. Test against live API

## Key Decisions

- All new endpoints go in `rkit:result-feed` (not `rkit:today`)
- `rkit:today` is NOT affected by the breaking change (it uses `/day-plans/` endpoints)
- Webhook push checks team flags before attempting
