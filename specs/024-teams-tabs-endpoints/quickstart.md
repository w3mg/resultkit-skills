# Quickstart: Teams Tabs API Endpoints

**Branch**: `024-teams-tabs-endpoints` | **Date**: 2026-03-03

## Verification Scenarios

### US1: API Reference Updated

**Scenario 1**: All new endpoints documented
```
Read api-reference.md → Verify Teams section includes:
- GET /teams/{id}/activity-logs (with ActivityLogEntry fields)
- GET/POST/PATCH/DELETE /teams/{id}/labels (with Label fields)
- GET/POST/PATCH/DELETE /teams/{id}/integrations (with Integration fields)
- PATCH /teams/{id}/members/{user_id} (role change, with response fields)
- POST /teams/{id}/logo (with multipart/form-data note)
```

**Scenario 2**: Glossary entries present
```
Read api-reference.md → Glossary section includes:
- "activity logs", "team history", "membership changes" → /teams/{id}/activity-logs
- "team labels", "team tags" → /teams/{id}/labels
- "slack integration", "team webhook", "team integration" → /teams/{id}/integrations
- "change role", "make admin", "promote to admin", "demote member" → PATCH /teams/{id}/members/{user_id}
```

---

### US2: Change Member Role

**Scenario 3**: Successful role change
```
User: /rkit:teams role 42 admin
Expected: Confirm → "Change Jane Doe (ID: 42) from member to admin on team #345?"
         → Yes → "Changed role: Jane Doe (ID: 42) is now admin on team #345."
```

**Scenario 4**: Successful demotion
```
User: /rkit:teams role 42 member
Expected: Confirm → "Change Jane Doe (ID: 42) from admin to member on team #345?"
         → Yes → "Changed role: Jane Doe (ID: 42) is now member on team #345."
```

**Scenario 5**: Non-admin attempt
```
User: /rkit:teams role 42 admin (user is not admin)
Expected: 403 → "Access denied (403). Only team admins can change roles."
```

**Scenario 6**: Invalid role value
```
User: /rkit:teams role 42 superadmin
Expected: "Invalid role 'superadmin'. Use 'admin' or 'member'."
```

**Scenario 7**: No args
```
User: /rkit:teams role
Expected: "Usage: `/rkit:teams role {user_id} {role} [team_id]`
  Example: `/rkit:teams role 42 admin`"
```

**Scenario 8**: Explicit team ID
```
User: /rkit:teams role 42 admin 100
Expected: Uses team 100 instead of default team
```

---

### US3: View Activity Logs

**Scenario 9**: Successful log view
```
User: /rkit:teams logs
Expected: Table of activity log entries:
  | Date | Action | Target | Actor |
  |------|--------|--------|-------|
  | 2026-02-15 | member_added | Jane Doe (42) | Admin (1) |
  | 2026-02-10 | role_changed | John Smith (55) | Admin (1) |
  3 entries
```

**Scenario 10**: No activity
```
User: /rkit:teams logs
Expected: "No activity logs found for team #345."
```

**Scenario 11**: Explicit team ID
```
User: /rkit:teams logs 100
Expected: Activity logs for team 100
```

**Scenario 12**: Non-member access denied
```
User: /rkit:teams logs 999 (not a member)
Expected: 403 → "Access denied (403). You must be a team member to view activity logs."
```

**Scenario 13**: Team not found
```
User: /rkit:teams logs 99999
Expected: 404 → "Team 99999 not found (404)."
```
