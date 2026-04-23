# Data Model: Fix 1on1 Skill API Endpoints

**Feature**: 001-fix-1on1-endpoints-gh97  
**Date**: 2026-04-22

No new data model introduced. This is a bug fix that corrects existing data parsing. The entities below document the **actual** API shapes to replace the incorrect assumptions in the current skill.

## Entities

### OneOnOneMeeting (list item — `GET /1-on-1`)

```
id            integer     Unique meeting ID
type          string      Always "one_on_one"
date          string|null ISO date string or null
human_name    string      Pre-formatted display name
can_edit      boolean
can_view      boolean
can_edit_notes boolean
persons       object      Nested — see Persons below
```

### Persons (nested on meeting)

```
person1       object      { id, login, first_name, last_name }
person2       object      { id, login, first_name, last_name }
```

Display name resolution: `first_name + " " + last_name`; fall back to `login` if names are empty.

### MeetingDetail (single meeting — `GET /1-on-1/{id}`)

All fields from OneOnOneMeeting, plus:

```
items         object      Nested item columns — see MeetingItems below
notes         object|null Meeting notes
measures      array       Associated measures
goals         array       Associated goals
attachments   array       File attachments
assistants    array       Collaborators
```

### MeetingItems (nested on MeetingDetail)

```
next          Item[]      Items in "next" column   (status: active)
done          Item[]      Items in "done" column   (status: realized)
issues        Item[]      Items in "blocked" column
```

Column mapping for display:
- `items.next` → **Next** column
- `items.done` → **Done** column
- `items.issues` → **Blocked** column

### MeetingItem

```
id            integer     Item ID
name          string      Item text
status        string      "active" | "realized" | "blocked" | "archived"
creator       object      { id, login, first_name, last_name }
due_date      string|null ISO date or null
```

Archived items (`status == "archived"`) are excluded from display.

## State Transitions (Move Item)

```
active    ──→  realized   (move to done)
active    ──→  blocked    (move to blocked)
realized  ──→  active     (move back to next)
blocked   ──→  active     (unblock)
```

Move is performed via `PATCH /items/{id}` with `{ "status": "<new_status>" }`.  
⚠️ Verify that the 1on1 context accepts these status values (see research.md Decision 5).

## API Endpoint Summary

| Method | Path | Purpose |
|--------|------|---------|
| GET    | `/1-on-1` | List meetings (param: `group_id`) |
| GET    | `/1-on-1/{id}` | Meeting detail with nested items |
| GET    | `/1-on-1/{id}/items` | Items (param: `status`?) — verify |
| GET    | `/1-on-1/{id}/done` | Done/realized items — verify |
| POST   | `/1-on-1/{id}/items` | Create new item in meeting |
| PUT    | `/1-on-1/{id}/items/{item_id}` | Attach existing item — verify |
| DELETE | `/1-on-1/{id}/items/{item_id}` | Remove item from meeting — verify |
| PATCH  | `/items/{id}` | Update item status (move between columns) |
