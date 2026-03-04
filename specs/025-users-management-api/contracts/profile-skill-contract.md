# Contract: rkit:profile Skill

**Branch**: `025-users-management-api` | **Date**: 2026-03-04

## Argument Parsing

| Input | Behavior |
|-------|----------|
| *(no args)* | Show stats for the current user (same as `stats`) |
| `stats` | Show personal performance stats for current user |
| `stats {user_id}` | Show stats for another user (must share a team) |
| `prefs` | View all current preferences |
| `prefs set {field} {value}` | Update a single preference field (with confirmation) |
| `password` | Interactively change account password |
| `account` | Show current user's accounts with ownership status |
| `account members [{account_id}]` | List account members (uses first account if not specified) |
| `account members remove {user_id} [{account_id}]` | Remove a member from an account (owner-only, with confirmation) |

## API Endpoints Used

### Stats

```
GET /api/v2/users/{id}/stats
  id: numeric user ID or "me"
  Response: { data: { wins_given, wins_received, goals_aspired, goals_realized, actions_done } }
```

### Preferences

```
GET /api/v2/users/me/preferences
  Response: { data: { login, first_name, last_name, email, secondary_email, time_zone,
              notifications: { morning_day_ahead, end_of_day_digest, weekly_digest_friday, week_ahead_sunday },
              update_frequency, unsubscribe_all, startup_view_code, startup_view_label,
              preferred_team_id, slack_username, api_token, is_coach, profile_photo_thumb_path } }

PATCH /api/v2/users/me/preferences
  Body: { <only changed fields> }
  Response: { data: { ...full preferences object } }
```

### Password

```
POST /api/v2/users/me/password
  Body: { current_password?, password, password_confirmation }
  Response: { data: { success: true } }
  Errors: 422 { errors: { current_password?, password?, password_confirmation? } }
```

### Accounts

```
GET /api/v2/users/me/accounts
  Response: { data: [ { id, name, is_owner, ... } ] }

GET /api/v2/accounts/{id}/members
  Response: { data: [ { id, first_name, last_name, email, is_owner, ... } ] }

DELETE /api/v2/accounts/{id}/members/{user_id}
  Response: 204 No Content
  Errors: 403 (not owner), 422 (cannot remove owner)
```

## Output Formats

### Stats Output

```
## My Stats

Wins given:       12
Wins received:     8
Goals aspired:     5
Goals realized:    3
Actions done:     47
```

### Preferences Output (view)

```
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

### Account Members Output

```
## Account Members — Acme Corp (ID: 5)

| Name           | Email                  | ID  | Owner |
|----------------|------------------------|-----|-------|
| Jane Doe       | jane@company.com       | 42  | Yes   |
| John Smith     | john@company.com       | 55  | No    |
| Alice Wang     | alice@company.com      | 78  | No    |

3 members
```

## Error Handling

| Status | Message |
|--------|---------|
| 401    | "Unauthorized (401). Run `/rkit:setup` to update your token." |
| 403    | "Access denied (403). [Context-specific message]" |
| 404    | "[Resource] not found (404)." |
| 422    | Show validation error messages from `errors` object |
| NO_CONFIG | "Config not found. Run `/rkit:setup` first." |

## Confirmation Prompts

### Preferences Update

```
Update preferences?
  time_zone: "Pacific Time (US & Canada)" → "Eastern Time (US & Canada)"
  notifications.morning_day_ahead: true → false
Confirm? (yes/no)
```

### Password Change

```
Change account password for jane@company.com?
Confirm? (yes/no)
```

### Account Member Removal

```
Remove John Smith (john@company.com, ID: 55) from account Acme Corp (ID: 5)?
This cannot be undone. Confirm? (yes/no)
```
