# Quickstart: Users Management API Endpoints

**Branch**: `025-users-management-api` | **Date**: 2026-03-04

## Verification Scenarios

### US1: API Reference Updated

**Scenario 1**: All new endpoints documented
```
Read api-reference.md → Verify Users section includes all 14 endpoints:
- GET /users/{id}/stats (with response fields)
- GET /users/{id}/measurables (with periodic data note)
- GET /users/{id}/rocks (with milestone progress note)
- GET /users/{id}/feedback (given/received)
- GET /users/me/preferences (with all 20+ field names)
- PATCH /users/me/preferences (partial update, with field list)
- GET /users/check-login?login= (availability check)
- GET /users/me/accounts (with is_owner field)
- GET /accounts/{id}/members (with is_owner field)
- DELETE /accounts/{id}/members/{user_id} (owner-only, 204)
- POST /users/me/password (with current_password? note for OAuth users)
- GET /users/me/progress (documented, no skill flow)
- GET /users/me/integrations (documented, no skill flow)
- PATCH /users/me/integrations (documented, no skill flow)
```

**Scenario 2**: Glossary entries present
```
Read api-reference.md → Glossary section includes:
- "my stats", "my wins", "my score", "wins given", "wins received" → /users/{id}/stats
- "my preferences", "my settings", "my profile" → /users/me/preferences
- "update preferences", "change timezone", "toggle notifications", "turn off digest" → PATCH /users/me/preferences
- "change password", "update password", "reset password" → POST /users/me/password
- "my accounts", "account list" → /users/me/accounts
- "account members", "who's in my account" → /accounts/{id}/members
- "remove account member", "remove from account" → DELETE /accounts/{id}/members/{user_id}
```

**Scenario 3**: Key behaviors documented
```
Read api-reference.md Users section:
- "me" alias supported for {id} on profile endpoints ✓
- Team-sharing permission required for other users' profile data ✓
- Notification booleans inverted from DB (should_suppress=true → API: false) ✓
- Account member removal is owner-only; cannot remove owner ✓
- OAuth users can set password without current_password ✓
```

---

### US2: View My Stats

**Scenario 4**: Self stats (no args)
```
User: /rkit:profile
Expected:
  ## My Stats (Jane Doe, ID: 42)
  Wins given:       12
  Wins received:     8
  Goals aspired:     5
  Goals realized:    3
  Actions done:     47
```

**Scenario 5**: Stats with explicit "me"
```
User: /rkit:profile stats
Expected: Same as Scenario 4
```

**Scenario 6**: Another user's stats (shared team)
```
User: /rkit:profile stats 55
Expected:
  ## Stats for John Smith (ID: 55)
  Wins given: ...
  [same format]
```

**Scenario 7**: Another user's stats (no shared team)
```
User: /rkit:profile stats 999
Expected: "Access denied (403). You must share a team with user 999 to view their stats."
```

---

### US3: View and Update Preferences

**Scenario 8**: View preferences
```
User: /rkit:profile prefs
Expected:
  ## My Preferences
  Login:            jdoe
  Name:             Jane Doe
  Email:            jane@company.com
  Timezone:         Eastern Time (US & Canada)
  Preferred team:   42
  Notifications:
    Morning day-ahead:   ON
    End-of-day digest:   ON
    Weekly digest (Fri): ON
    Week-ahead (Sun):    OFF
  Update frequency: every_change
  Startup view:     Personal Dashboard (6)
  Slack username:   jdoe
```

**Scenario 9**: Update a single preference
```
User: /rkit:profile prefs set time_zone "Pacific Time (US & Canada)"
Expected: Confirm prompt →
  "Update preferences?
    time_zone: 'Eastern Time (US & Canada)' → 'Pacific Time (US & Canada)'
  Confirm? (yes/no)"
  → Yes → "Preferences updated."
  → No → "Cancelled."
```

**Scenario 10**: Toggle notification off
```
User: /rkit:profile prefs set notifications.morning_day_ahead false
Expected: Confirm → "Update preferences?
    notifications.morning_day_ahead: ON → OFF
  Confirm? (yes/no)"
  → Yes → "Preferences updated."
```

**Scenario 11**: Unknown field
```
User: /rkit:profile prefs set nonexistent_field value
Expected: "Unknown preference field 'nonexistent_field'. Run `/rkit:profile prefs` to see available fields."
```

---

### US4: Change Password

**Scenario 12**: Successful password change
```
User: /rkit:profile password
Expected: Prompts for current password, new password, confirmation →
  Confirm → "Change account password for jane@company.com?" → Yes →
  "Password changed successfully."
```

**Scenario 13**: Wrong current password
```
User: /rkit:profile password (enters wrong current password)
Expected: 422 → "Current password is incorrect."
```

**Scenario 14**: Passwords don't match
```
User: /rkit:profile password (new password ≠ confirmation)
Expected: "Password confirmation does not match." (before API call)
```

**Scenario 15**: OAuth user sets first password
```
User: /rkit:profile password (leaves current_password blank, enters new password + confirm)
Expected: "Password set successfully."
```

---

### US5: Account Members

**Scenario 16**: List account members
```
User: /rkit:profile account members
Expected:
  ## Account Members — Acme Corp (ID: 5)
  | Name        | Email                | ID  | Owner |
  |-------------|----------------------|-----|-------|
  | Jane Doe    | jane@company.com     | 42  | Yes   |
  | John Smith  | john@company.com     | 55  | No    |
  2 members
```

**Scenario 17**: Remove a non-owner member
```
User: /rkit:profile account members remove 55
Expected: Confirm → "Remove John Smith (john@company.com, ID: 55) from account Acme Corp (ID: 5)?
  This cannot be undone. Confirm? (yes/no)"
  → Yes → "John Smith (ID: 55) removed from account."
  → No → "Cancelled."
```

**Scenario 18**: Attempt to remove owner
```
User: /rkit:profile account members remove 42 (owner)
Expected: 422 → "Cannot remove the account owner."
```

**Scenario 19**: Non-owner attempts removal
```
User: /rkit:profile account members remove 55 (user is not owner)
Expected: 403 → "Access denied (403). Only the account owner can remove members."
```

**Scenario 20**: No accounts
```
User: /rkit:profile account
Expected: "No accounts found."
```
