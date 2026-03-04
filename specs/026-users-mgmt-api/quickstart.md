# Quickstart: New rkit:profile Subcommands

**Feature**: 026-users-mgmt-api

## Prerequisites

- `/rkit:setup` completed (config at `~/.config/resultkit/config.json`)
- Plugin installed: `/plugin marketplace add w3mg/resultkit-skills && /plugin install rkit@resultkit`

## New Subcommands

```bash
# Personal progress dashboard
/rkit:profile progress
/rkit:profile progress week
/rkit:profile progress month

# Scorecard measurables
/rkit:profile measurables
/rkit:profile measurables 42          # another user (must share a team)

# Quarterly rocks
/rkit:profile rocks
/rkit:profile rocks 2025              # by year
/rkit:profile rocks 42               # another user

# Feedback / High5s
/rkit:profile feedback received
/rkit:profile feedback given
/rkit:profile feedback 42 received    # another user's received feedback

# Third-party integrations
/rkit:profile integrations
/rkit:profile integrations set task_management asana
/rkit:profile integrations set task_management none   # disconnect
```

## Expected Outputs

### progress
```
## My Progress

**Strategy**
Rocks realized (all time):         12
Milestones realized (all time):    47
Milestones realized (this quarter): 3

**Practice Streak**
Current streak:   5 days
Longest streak:  22 days
All-time days:   89

**Practice Scorecard** (last 7 days)
Mon 03/03  ✓
Tue 03/04  ✓
...
```

### measurables
```
## My Measurables

| ID  | Name              | Target | Latest | On Track |
|-----|-------------------|--------|--------|----------|
| 101 | Weekly Revenue    | 10000  | 9800   | ✓        |
| 102 | Support Tickets   | <5     | 7      | ✗        |

2 measurables
```

### rocks
```
## My Rocks

| ID  | Rock                          | Status    | Due        | Milestones | Team     |
|-----|-------------------------------|-----------|------------|------------|----------|
| 201 | Launch v2 product             | On Track  | 2026-03-31 | 3/5        | Acme     |
| 202 | Hire senior engineer          | Completed | 2026-03-31 | 2/2        | Acme     |

2 rocks
```

### feedback received
```
## Feedback Received

| ID  | From         | Message                              | Date       |
|-----|--------------|--------------------------------------|------------|
| 301 | Jane Doe     | Great work on the launch prep!       | 2026-02-28 |
| 302 | John Smith   | Really helpful during standup today  | 2026-02-15 |

2 items
```

### integrations
```
## My Integrations

Task Management:   asana  (options: asana, jira, trello, todoist, —)
Sales / RevOps:    —      (options: salesforce, hubspot, —)
Team Comms:        slack  (options: slack, teams, —)
```

## Error Reference

| Error | Message |
|-------|---------|
| Missing config | "Config not found. Run `/rkit:setup` first." |
| 401 | "Unauthorized (401). Run `/rkit:setup` to update your token." |
| 403 (profile) | "Access denied (403). You must share a team with user {id} to view their data." |
| 404 | "User {id} not found (404)." |
| Network error | "Network error. Check your connection." |
