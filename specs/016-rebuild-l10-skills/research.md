# Research: Rebuild Skills with Skill Creator & L10 Route Coverage

## R1: L10 Route Behavior vs Generic Routes

**Decision**: L10 routes are direct aliases — identical request/response shapes.

**Rationale**: The API reference (lines 154-166) explicitly states: "EOS-friendly URL aliases for the team weekly board. These endpoints return the same data as their generic V2 counterparts but use Level 10 terminology." Confirmed by examining the route mapping:

| L10 Route | Generic Equivalent | Params | Response |
|-----------|-------------------|--------|----------|
| `GET /teams/{id}/l10/todos` | `GET /teams/{id}/items/next` | page, per_page, q, all | Same paginated Item[] |
| `POST /teams/{id}/l10/todos` | `POST /teams/{id}/items` + status=next | name, description, due | Same Item (status=next, due auto-set 7d) |
| `GET /teams/{id}/l10/issues` | `GET /teams/{id}/items/blocked` | page, per_page, q | Same paginated Item[] |
| `POST /teams/{id}/l10/issues` | `POST /teams/{id}/items` + status=blocked | name, description, due | Same Item (status=blocked) |
| `GET /teams/{id}/l10/headlines` | `GET /teams/{id}/headlines` | page, per_page | Same paginated Headline[] |
| `POST /teams/{id}/l10/headlines` | `POST /teams/{id}/headlines` | text, expires_at | Same Headline |

**Alternatives considered**: Using only generic routes (rejected — misses the opportunity to use API's EOS-specific interface).

## R2: Operations Requiring Generic Route Fallback

**Decision**: Four operations fall back to generic routes since L10 endpoints only offer GET and POST.

| Operation | Route Used | Reason |
|-----------|-----------|--------|
| Mark to-do done | `PUT /teams/{id}/items/done/{item_id}` | No L10 "done" endpoint |
| Move to-do ↔ issue | `PUT /teams/{id}/items/{section}/{item_id}` | No L10 move endpoint |
| Archive headline | `DELETE /teams/{id}/headlines/{headline_id}` | No L10 archive endpoint |
| Update headline | `PATCH /teams/{id}/headlines/{headline_id}` | No L10 update endpoint |

**Rationale**: These are the same routes `rkit:weekly` and `rkit:headlines` already use. The data model is identical.

**Alternatives considered**: Omitting these operations from level10 (rejected per clarification — user wants full workflow without skill-switching).

## R3: EOS Framework Detection Strategy

**Decision**: Fetch team detail via `GET /teams/{id}` and check `framework` field equals `"eos"`.

**Rationale**: All skills that need framework awareness already do this (e.g., `rkit:weekly` uses it for the Framework Terminology table). The level10 skill adds a hard gate — non-EOS teams get an error rather than degraded behavior.

**Alternatives considered**: Client-side config flag for "is EOS" (rejected — framework is a team-level property in the API, not a user preference).

## R4: Skill Creator Rebuild Strategy

**Decision**: Process each skill through `/skill-creator` one at a time, using the existing SKILL.md as input. Preserve all current logic/flows. Run evals to verify quality.

**Rationale**: Constitution Section X mandates Skill Creator for authoring. The existing skills are well-written but were created before the mandate. Running them through Skill Creator standardizes structure without rewriting logic.

**Processing order** (by dependency/risk):
1. `setup` — foundation skill, test Skill Creator workflow
2. `teams` — read-only, low risk
3. `today` — day plan CRUD, moderate complexity
4. `board` — board view, moderate complexity
5. `weekly` — team board + L10 route update (P2+P3 combined)
6. `headlines` — headlines + L10 route update (P2+P3 combined)
7. `1on1` — meetings CRUD
8. `projects` — team projects
9. `result-feed` — read-only feed viewer
10. `result-update` — check-in composer
11. `braindump` — parsing skill (unique pattern, highest risk)
12. `level10` — NEW skill (created fresh via Skill Creator)

**Alternatives considered**: Batch rebuild of all 11 simultaneously (rejected — too risky for regression detection; sequential allows comparing each before/after).

## R5: Plugin Manifest Update

**Decision**: Add level10 skill directory. The plugin manifest (`plugin.json`) uses `"skills": "./skills/"` which auto-discovers all skill directories. No manifest change needed beyond version bump.

**Rationale**: Existing skills are discovered by directory convention. Adding `skills/level10/SKILL.md` is sufficient.

**Alternatives considered**: Explicit skill registration in manifest (rejected — discovery-based pattern already works for all 11 skills).

## R6: Shared File Sync for New Skill

**Decision**: Run `/sync-plugin` after creating level10 to copy `scripts/api.sh` and `api-reference.md` into the new skill directory.

**Rationale**: Standard pattern per CLAUDE.md — master copies live at repo root, each skill gets its own copy for plugin self-containment.

**Alternatives considered**: Symlinks (rejected — plugin distribution requires actual files).
