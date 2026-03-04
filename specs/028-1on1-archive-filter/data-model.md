# Data Model: 1on1 Skill — Filter Archived Items

**Feature**: 028-1on1-archive-filter

## Entities

### Meeting (unchanged)

Returned by `GET /meetings/{id}`.

| Field | Type | Notes |
|-------|------|-------|
| id | integer | Meeting ID |
| type | string | `one_on_one` or `project` |
| next | Item[] | **Contains archived items — must be filtered** |
| done | Item[] | **Contains archived items — must be filtered** |
| blocked | Item[] | **Contains archived items — must be filtered** |
| person1 | UserSimple | |
| person2 | UserSimple | |

---

### Item (no schema change)

Items already have a `status` field. No new fields added.

| Field | Type | Notes |
|-------|------|-------|
| id | integer | Item ID |
| name | string | Display name |
| status | string | `next`, `done`, `blocked`, `archived`, `not_started`, `parked`, `draft` |
| creator | UserSimple | |
| due | ISO date \| null | |

**Filter rule**: Exclude items where `status == "archived"` before rendering in any column.

---

## State / Filter Logic

| Flow | Endpoint | Archived Behavior | Fix Required |
|------|----------|-------------------|--------------|
| View Detail | `GET /meetings/{id}` | Returns archived items in arrays | **Yes — client-side filter** |
| View Single Column | `GET /meetings/{id}/items/{section}` | Excludes archived by default | No — API handles it |
