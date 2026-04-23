# Data Model: rkit:1on1

## Entities

### OneOnOne (list response)

```
id: integer
type: "one_on_one"
date: string (YYYY-MM-DD) | null
human_name: string (pre-formatted display name)
persons:
  person1: UserSimple { id, login, first_name, last_name }
  person2: UserSimple { id, login, first_name, last_name }
can_edit: boolean
can_view: boolean
```

### OneOnOne (detail response)

Extends list fields plus:

```
items:
  next: Item[]
  done: Item[]
  issues: Item[]        # "blocked" in skill terminology
notes: string | null
can_edit_notes: boolean
measures: array
goals: array
attachments: array
assistants: array
```

### Item (within meeting sections)

```
id: integer
name: string
status: string (next | done | blocked | archived | ...)
due: string (YYYY-MM-DD) | null
creator: UserSimple { id, login, first_name, last_name }
```

## Key Differences from Current Skill Assumptions

| Aspect | Skill assumes | Actual |
|---|---|---|
| Endpoint prefix | `/meetings` | `/1-on-1` |
| Team filter param | `team_id` | `group_id` |
| Person fields | top-level `person1`, `person2` | nested under `persons` |
| Section arrays | top-level `blocked`, `done`, `next` | nested under `items`; blocked = `issues` |
| Done items endpoint | `GET /meetings/{id}/items/done` | `GET /1-on-1/{id}/done` (dedicated) |
| Display name | constructed from first/last | `human_name` available |
