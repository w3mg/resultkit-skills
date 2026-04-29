# Data Model: Update Result-Feed Skill for Tier 1 Backend API Changes

**Date**: 2026-04-28

## Entities

### TeamResultFeed (updated)

Represents a user's daily check-in report.

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Report ID |
| date | string (YYYY-MM-DD) | Report date |
| is_completed | boolean | Whether report has been submitted |
| user | User | Report author |
| done | ResultFeedSection | Completed items |
| review | ResultFeedSection | Items awaiting manager sign-off (**NEW**) |
| next | ResultFeedSection | Upcoming items |
| blocked | ResultFeedSection | Blocked items |
| shared_team_id | integer | Team the report was shared to |
| shared_item_ids | integer[] | Item IDs shared with team |

### ResultFeedSection (updated)

Each section is a structured object (not a flat array).

| Field | Type | Description |
|-------|------|-------------|
| items | Item[] | Items in this section |
| notes | string \| null | Free-text notes for this section |
| attachments | Attachment[] | Files attached to this section |

### Attachment (updated schema)

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Attachment/document ID |
| filename | string | Original filename |
| content_type | string | MIME type (e.g., "image/png") |
| size | integer | File size in bytes |

**Note**: Previous schema had `{ id, filename, url }`. Updated to match API response.

### Reaction

| Field | Type | Description |
|-------|------|-------------|
| reacted | boolean | Whether the current user has reacted |
| count | integer | Total reaction count |

**Note**: Previous schema had `high_five_count` and `user_has_reacted`. Updated to match API response.

### Comment

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Comment ID |
| comment | string | Comment text (body) |
| user_id | integer | Author user ID |
| created_at | string (ISO 8601) | Creation timestamp |

**Note**: The text field is `comment`, not `body`, in the API response.

### UploadedDocument (new)

Returned by `POST /result-feed/:date/attachments`.

| Field | Type | Description |
|-------|------|-------------|
| id | integer | Document ID (use as attachment_id) |
| filename | string | Original filename |
| content_type | string | MIME type |
| filesize | integer | File size in bytes |
| parent_object_type | string | Always "CustomContent" |

## Relationships

- A **TeamResultFeed** has exactly 4 sections: done, review, next, blocked
- Each **ResultFeedSection** has 0+ items, optional notes, 0+ attachments
- **Reactions** and **Comments** are per-report (scoped by date + user_id)
- **UploadedDocument** IDs feed into section `attachment_ids` via PUT

## Valid Sections

Previous: `done`, `next`, `blocked`
Updated: `done`, `review`, `next`, `blocked`
