# Contract: rkit:weekly L10 Route Selection (Updated)

The weekly skill dynamically selects routes based on the team's `framework` field.

## Updated L10 Route Selection Table

| Column | EOS Route | Non-EOS Route |
|--------|-----------|---------------|
| next (To-Do) | `GET /teams/{id}/l10/todos` | `GET /teams/{id}/items/next` |
| done | `GET /teams/{id}/l10/done` | `GET /teams/{id}/items/done` |
| blocked (Issues) | `GET /teams/{id}/l10/issues` | `GET /teams/{id}/items/blocked` |
| parked | `GET /teams/{id}/l10/parked` | `GET /teams/{id}/items/parked` |

**Changes from current**: Added EOS routes for `done` and `parked` columns. Previously these used generic routes even for EOS teams.

## Affected Flows

### View Weekly (full board)

When `framework == "eos"`, all four GET calls use L10 routes:

```
GET /teams/{id}/l10/todos?per_page=50
GET /teams/{id}/l10/done?per_page=50
GET /teams/{id}/l10/issues?per_page=50
GET /teams/{id}/l10/parked?per_page=50
```

### View Single Column

When `framework == "eos"` and column is `done` or `parked`:

```
GET /teams/{id}/l10/done?per_page=50     # previously: /items/done
GET /teams/{id}/l10/parked?per_page=50   # previously: /items/parked
```

## Unchanged

Write operations (move, add, remove) continue to use generic routes regardless of framework. This is correct — L10 PUT routes are only used in the L10 skill.
