# Skill Command Contracts: rkit:seats

**Feature**: 029-v2-seat-api
**Date**: 2026-03-05

This document defines the complete command interface and API call contracts for the `rkit:seats` skill after V2 integration. Changes from the current SKILL.md are marked **[V2 CHANGE]** or **[NEW]**.

---

## Argument Parsing Table (complete)

| Input | Behavior |
|-------|----------|
| *(no args)* | View accountability chart tree for default team |
| `--include-archived` | Include archived seats in chart view **[NEW]** |
| `{id}` | View seat detail by ID |
| `--team {id}` | Use specified team instead of default |
| `create "NAME" [--parent {id}]` | Create a new seat |
| `update {id} [--name "..."] [--owner {uid}] [--notes "..."] [--accountabilities "..."] [--associated-team {tid}]` | Update seat fields |
| `delete {id}` | Archive a seat (recursive — all children also archived) |
| `move {id} --parent {id}` | Move seat to new parent |
| `restore {id}` | Restore an archived seat (non-recursive) |
| `align-measure {id} --measure {mid}` | Align a measure to a seat |
| `remove-measure {id} --measure {mid}` | Remove a measure from a seat |
| `align-goal {id} --goal {gid}` | Align a goal to a seat |
| `remove-goal {id} --goal {gid}` | Remove a goal from a seat |
| `add-link {id} --url "..." [--title "..."]` | Add a link to a seat |
| `update-link {id} --link {lid} [--url "..."] [--title "..."]` | Update an existing link **[NEW]** |
| `remove-link {id} --link {lid}` | Remove a link from a seat |

---

## API Call Contracts

### Chart View

```
GET /teams/{team_id}/seats
GET /teams/{team_id}/seats?include_archived=true   (when --include-archived flag present)
```

**Response**: `{ "data": [ Seat, ... ] }` — recursive tree of root seats.
**Display**: Archived seats (where `archived: true`) shown with `[archived]` suffix.

---

### Seat Detail

```
GET /seats/{seat_id}
```

**Response**: `{ "data": { ...Seat } }`

---

### Create Seat

```
POST /seats
Body (root seat):   { "name": "...", "group_id": TEAM_ID }
Body (child seat):  { "name": "...", "parent_id": PARENT_SEAT_ID }
Optional fields: accountability_owner_id, accountabilities, notes, associated_team_id
```

**[V2 CHANGE]**: Root seat creation uses `group_id` (not `team_id`).
**Response**: `{ "data": { ...Seat } }` — status 201.

---

### Update Seat

```
PATCH /seats/{seat_id}
Body: { "name"?: "...", "accountability_owner_id"?: N, "notes"?: "...", "accountabilities"?: "...", "associated_team_id"?: N }
```

**[V2 CHANGE]**: Owner field is `accountability_owner_id` (not `seat_owner_id`).
**Response**: `{ "data": { ...Seat } }` — status 200.
**Side effect**: Owner change reassigns aligned measures and goals to the new owner. Confirm message must note this.

---

### Delete Seat (Archive)

```
DELETE /seats/{seat_id}
```

**Behavior**: Archives the seat AND all descendants recursively.
**Cannot archive**: Root seat (API returns 422).
**Response**: 204 no content.
**Confirmation message must say**: "This will archive seat [ID: {id}] and ALL its descendants."

---

### Move Seat

```
PUT /seats/{seat_id}/move
Body: { "parent_id": NEW_PARENT_ID }
```

**Cannot move**: Root seat (API returns 422).
**Response**: `{ "data": { ...Seat } }` — status 200.

---

### Restore Seat

```
PUT /seats/{seat_id}/restore
```

**Behavior**: Restores ONLY the target seat. Children remain archived.
**Response**: `{ "data": { ...Seat } }` — status 200.
**Confirmation must say**: "Only this seat will be restored. Descendant seats remain archived."

---

### List Measures

```
GET /seats/{seat_id}/measures
```

**Response**: `{ "data": [ Measure, ... ] }`

---

### Align Measure

```
PUT /seats/{seat_id}/measures
Body: { "measure_id": MID }
```

**Response**: `{ "data": [ Measure, ... ] }` — full updated list, status 200.

---

### Remove Measure

```
DELETE /seats/{seat_id}/measures/{measure_id}
```

**Response**: 204 no content.

---

### List Goals

```
GET /seats/{seat_id}/goals
```

**Response**: `{ "data": [ Goal, ... ] }`

---

### Align Goal

```
PUT /seats/{seat_id}/goals
Body: { "goal_id": GID }
```

**Response**: `{ "data": [ Goal, ... ] }` — full updated list, status 200.

---

### Remove Goal

```
DELETE /seats/{seat_id}/goals/{goal_id}
```

**Response**: 204 no content.

---

### List Links

```
GET /seats/{seat_id}/links
```

**Response**: `{ "data": [ Link, ... ] }`

---

### Add Link

```
POST /seats/{seat_id}/links
Body: { "url": "https://...", "title"?: "..." }
```

Title defaults to URL if omitted.
**Response**: `{ "data": { ...Link } }` — status 201.

---

### Update Link **[NEW]**

```
PATCH /seats/{seat_id}/links/{link_id}
Body: { "url"?: "https://...", "title"?: "..." }
```

Set title to null to reset it to the URL value.
**Response**: `{ "data": { ...Link } }` — status 200.

---

### Remove Link

```
DELETE /seats/{seat_id}/links/{link_id}
```

**Response**: 204 no content.

---

## Error Handling (unchanged)

| Status | Response |
|--------|----------|
| `error: NO_CONFIG` | "Config not found. Run `/rkit:setup` first." |
| `error: NO_TOKEN` | "No API token. Run `/rkit:setup` to configure." |
| `error: CURL_FAILED` | "Network error. Check your connection." |
| `status: 401` | "Unauthorized. Run `/rkit:setup` to update your token." |
| `status: 403` | "Not authorized for this team/seat. Check your team membership." |
| `status: 404` | "Not found. Check the ID and try again." |
| `status: 422` | Show the validation error message from the response body. |
| Other non-200 | Show status code and error message. |
