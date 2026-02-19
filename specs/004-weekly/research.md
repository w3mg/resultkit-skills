# Research: rkit:weekly

**Date**: 2026-02-15 | **Spec**: [spec.md](./spec.md)

## R1: Team Weekly API Endpoints

**Decision**: Use column-specific GET/PUT endpoints for viewing and moving.
Use DELETE for removing from weekly.

**Findings**:
- `GET /teams/{id}/items/next?per_page=50` — items with status=next
- `GET /teams/{id}/items/done?per_page=50` — items with status=done
- `GET /teams/{id}/items/issues?per_page=50` — items with status=blocked
- `GET /teams/{id}/items/parked?per_page=50` — items with status=parked
- `PUT /teams/{id}/items/{column}/{item_id}` — add to weekly + set status
- `DELETE /teams/{id}/items/{item_id}` — remove from weekly (keeps item)

## R2: Weekly Item Response Shape

**Decision**: Team weekly endpoints return item fields including owner/assignee data inline.

## R3: Framework Terminology Mapping

**Decision**: Mapping table in SKILL.md. Fetch team `framework` from `GET /teams/{id}`.

| Column (API) | Default | EOS | OKR | 4DX | V2MOM | SRT |
|-------------|---------|-----|-----|-----|-------|-----|
| next | Next | To-Do | Next | WIG Actions | Next | Next |
| done | Done | Done | Done | Done | Done | Done |
| issues | Issues | Issues | Blockers | Blockers | Obstacles | Issues |
| parked | Parked | Parked | Deferred | Parked | Parked | Parked |

## R4: Detecting Current Column for Move Validation

**Decision**: Fetch single item (`GET /items/{id}`), check `status`, map to column.

## R5: api.sh Query Parameter Support

**Decision**: Include query params in PATH argument. No api.sh changes needed.

## R6: Synonym Skill (rkit:level10)

**Decision**: Install same SKILL.md under both `rkit:weekly` and `rkit:level10` directory names.
