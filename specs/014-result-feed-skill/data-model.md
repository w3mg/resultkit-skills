# Data Model: rkit:result-feed Skill

**Date**: 2026-02-26

## Entities

### ResultFeed

The user's daily check-in report for a specific date.

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Report ID (CustomContent record ID) |
| date | string (YYYY-MM-DD) | Report date |
| is_completed | boolean | Whether the report has been finalized via submit |
| done | Item[] | Items marked as completed |
| next | Item[] | Items planned for next |
| issues | Item[] | Items that are blocked |

**Identity**: One per user per date. Auto-created on first GET.

**State transitions**:
- `is_completed: false` → `is_completed: true` (via submit endpoint)
- Transition is one-way and idempotent (re-submitting returns 200)

### TeamResultFeed

A ResultFeed that has been shared with a team, including the owning user.

| Field | Type | Description |
|-------|------|-------------|
| *(all ResultFeed fields)* | | |
| user | UserSimple | The user who created and shared this check-in |

### Item (as returned in ResultFeed sections)

Standard V2 Item object. Displayed in ItemSimple format (ID + name) in skill output.

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Item ID |
| name | string | Item name |
| status | string | Current status (not_started, next, blocked, done, etc.) |
| due | string or null | Due date (YYYY-MM-DD) |
| team | TeamSimple or null | Associated team |
| creator | UserSimple | Item creator |
| assignees | UserSimple[] | Assigned users |

### UserSimple

| Field | Type | Description |
|-------|------|-------------|
| id | integer | User ID |
| login | string | Username |
| first_name | string | First name |
| last_name | string | Last name |

### Section (URL param)

Not a stored entity — a URL parameter that maps to internal storage.

| URL Name | Internal Name | Description |
|----------|---------------|-------------|
| done | done | Completed items |
| next | next | Up-next items |
| issues | blocked | Blocked items |

**Constraint**: Skills MUST use URL names (`done`, `next`, `issues`) in API calls, never the internal name `blocked`.

## Relationships

- A **ResultFeed** contains three ordered lists of **Items** (done, next, issues)
- A **TeamResultFeed** extends ResultFeed with a **UserSimple** owner
- **Items** exist independently — adding/removing from a ResultFeed does not create/delete items
- Adding an item to a section triggers a status side-effect on the item (done→realized, next→active, issues→blocked)
- Removing an item from a section does NOT revert the status side-effect

## Config Entity

Not an API entity — local user configuration.

| Field | Type | Description |
|-------|------|-------------|
| api_token | string | Bearer token for API auth |
| default_team_id | integer | Default team for submit sharing and team view |
| api_base | string | API base URL (default: `https://api.resultmaps.com/api/v2`) |
