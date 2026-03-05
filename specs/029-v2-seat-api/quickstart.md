# Quickstart: V2 Seat API Integration

**Feature**: 029-v2-seat-api
**Date**: 2026-03-05

## What's Changing

This feature updates the existing `rkit:seats` skill to match the finalized V2 Seat API. The skill already exists and is largely correct — these are targeted fixes and additions.

## Files to Modify

| File | Change Type | What Changes |
|------|-------------|-------------|
| `skills/seats/SKILL.md` | Modify | Field names, new commands, enhanced messaging |
| `api-reference.md` | Modify (master) | Field name corrections, `include_archived` param |
| `skills/seats/references/api-reference.md` | Auto-synced | Via `/sync-plugin` after master update |

## Changes to `skills/seats/SKILL.md`

### 1. Argument parsing table — add two rows

Add `--include-archived` flag and `update-link` command to the table.

### 2. Chart view flow — add `include_archived` support

When `--include-archived` is present:
- Append `?include_archived=true` to the `GET /teams/{id}/seats` call
- In tree rendering, check `seat.archived === true` and append `[archived]` to the line

### 3. Create seat flow — fix `group_id`

Change POST body from:
```json
{"name":"NAME","team_id":TEAM_ID,"parent_id":PARENT_ID}
```
to:
```json
// Root seat (no parent):
{"name":"NAME","group_id":TEAM_ID}
// Child seat:
{"name":"NAME","parent_id":PARENT_ID}
```

### 4. Update seat flow — fix `accountability_owner_id`

Change the flag mapping from:
```
--owner {uid} → "seat_owner_id": {uid}
```
to:
```
--owner {uid} → "accountability_owner_id": {uid}
```

Also add note in confirmation message: "Note: changing the owner will reassign all aligned measures and goals to the new owner."

### 5. Delete seat flow — enhance confirmation

Change confirmation from:
> "Archive seat [ID: {id}]? This will remove it from the chart."

To:
> "Archive seat [ID: {id}]? This will archive this seat AND all its descendants."

### 6. Restore seat flow — add non-recursive note

Change confirmation from:
> "Restore seat [ID: {id}]?"

To:
> "Restore seat [ID: {id}]? Only this seat will be restored — descendant seats remain archived and must be restored individually."

### 7. New flow: Update Link

Add after "Flow: Add Link" section:

**Triggered when**: first arg is `update-link`.

1. Parse seat ID, `--link {lid}`, and optional `--url "..."` / `--title "..."` from args
2. Confirm: "Update link [ID: {lid}] on seat [ID: {id}]: {list of changes}?"
3. Execute: `PATCH /seats/{SEAT_ID}/links/{LID}` with `{"url":"...","title":"..."}`
4. Handle: 200 → show updated link (ID, Title, URL). Other errors → error table.

### 8. Schemas section — update field names

In the "Seat (tree node)" schema, note `accountability_owner_id` for writes. The response field remains `seat_owner` (read field names don't change, only write field names change).

## Changes to `api-reference.md`

1. Seat CREATE row: change body docs from `team_id` to `group_id` for root seats
2. Seat UPDATE row: change `seat_owner_id` to `accountability_owner_id`
3. Tree endpoint row: confirm `include_archived=true` is a supported query param (remove `?` uncertainty)

## Verification Steps

After implementing, verify with a live config:

1. `scripts/api.sh GET /teams/{team_id}/seats` — confirm tree structure
2. `scripts/api.sh POST /seats '{"name":"Test Root","group_id":TEAM_ID}'` — confirm `group_id` works
3. `scripts/api.sh PATCH /seats/{id} '{"accountability_owner_id":USER_ID}'` — confirm field name
4. `scripts/api.sh GET /teams/{team_id}/seats?include_archived=true` — confirm archived seats appear
5. `scripts/api.sh PATCH /seats/{id}/links/{lid} '{"title":"Updated"}'` — confirm link update

## Running `/sync-plugin` After Changes

After updating `api-reference.md`:
```
/sync-plugin
```
This copies the master api-reference.md to `skills/seats/references/api-reference.md` and bumps the plugin version.
