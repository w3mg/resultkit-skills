# Quickstart: Testing V2 Seat API Field Renames

**Feature**: 030-seats-field-renames
**Date**: 2026-03-05

## Prerequisites

- `~/.config/resultkit/config.json` configured with valid token and `default_team_id`
- A team with a seats chart (or ability to create one)

## Test Sequence

### 1. View existing chart (no API writes — safe first check)

```
/rkit:seats
```

Expected: Accountability chart renders with seat owner names displayed correctly.

### 2. Create a root seat (tests `team_id` fix)

Only run this if the team has no existing root seat, or use a test team.

```
/rkit:seats create "Test Root" --team {test_team_id}
```

Expected: Seat created successfully. Previously this would fail with 422 "group_id is not allowed".

### 3. Create a child seat with owner (tests `seat_owner_id` fix)

```
/rkit:seats create "Test Child" --parent {root_seat_id}
```

Then update it with an owner:

```
/rkit:seats update {child_id} --owner {user_id}
```

Expected: Update succeeds. Previously this would fail with 422 "accountability_owner_id is not allowed".

### 4. View seat detail (tests children display)

```
/rkit:seats {seat_id_with_children}
```

Expected: Direct Reports table shows ID and Name columns only (no Owner column).

### 5. Move and restore (verify renamed fields in response)

```
/rkit:seats move {child_id} --parent {other_parent_id}
```

Expected: Displays moved seat with correct `seat_owner` and `parent` object.

## Verifying the Fix

If any operation returns a 422 error with messages like:
- "group_id is not allowed" → `team_id` fix not applied
- "accountability_owner_id is not allowed" → `seat_owner_id` fix not applied

The fix is not working. Check `skills/seats/SKILL.md` for the old field names.
