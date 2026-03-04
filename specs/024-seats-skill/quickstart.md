# Quickstart: rkit:seats Skill

**Date**: 2026-03-04 | **Branch**: `024-seats-skill`

## Prerequisites

- `/rkit:setup` completed (config exists with valid token and default_team_id)
- Team has at least one seat in the accountability chart

## Quick Reference

### View the accountability chart
```
/rkit:seats
/rkit:seats --team 345
```

### View a specific seat
```
/rkit:seats 11
```

### Create a seat
```
/rkit:seats create "VP Engineering" --parent 11
/rkit:seats create "CEO"  (root seat, no parent)
```

### Update a seat
```
/rkit:seats update 42 --name "VP of Engineering"
/rkit:seats update 42 --owner 5
/rkit:seats update 42 --notes "Responsible for all engineering"
```

### Delete / Move / Restore
```
/rkit:seats delete 42
/rkit:seats move 42 --parent 15
/rkit:seats restore 42
```

### Manage measures, goals, links
```
/rkit:seats align-measure 42 --measure 793
/rkit:seats remove-measure 42 --measure 793
/rkit:seats align-goal 42 --goal 7315
/rkit:seats remove-goal 42 --goal 7315
/rkit:seats add-link 42 --url "https://example.com" --title "Wiki"
/rkit:seats remove-link 42 --link 2078
```

## Expected Output Examples

### Tree View
```
Accountability Chart — ResultMaps Incorporated [Team: 345]

├── Visionary (Scott Levy) [ID: 11]
│   ├── Executive Assistant (Mary Mejia) [ID: 1138]
│   ├── Integrator (TK) [ID: 12]
│   │   ├── Engineering Lead (Vacant) [ID: 45]
│   │   └── Product Lead (Pat) [ID: 46]
│   └── Test Child Seat (Vacant) [ID: 1463]
```

### Seat Detail
```
## Visionary [ID: 11]
**Owner**: Scott Levy (@scottilevy) [ID: 1]
**Parent**: None (root)
**Team**: ResultMaps Incorporated [ID: 345]
**Associated Team**: W3mG [ID: 1]

**Accountabilities**:
- Strategic direction
- this
- that
- the other

**Notes**: None

**Measures** (6):
| ID   | Name                                |
|------|-------------------------------------|
| 1526 | Connect Points/Sell                 |
| 793  | Scott ConnectPoints/Week            |

**Goals** (11):
| ID   | Name                                |
|------|-------------------------------------|
| 7315 | Be everywhere our prospects are     |
| 7561 | Close 20 Ideal Profile Deals        |

**Links**: None

**Direct Reports** (3):
| ID   | Name                | Owner      |
|------|---------------------|------------|
| 1138 | Executive Assistant | Mary Mejia |
| 12   | Integrator          | TK         |
| 1463 | Test Child Seat     | Vacant     |
```

## Integration Scenarios

1. **View chart → drill into seat**: User runs `/rkit:seats`, spots seat ID 42, then runs `/rkit:seats 42` for details.
2. **Create seat under existing**: User runs `/rkit:seats create "New Role" --parent 42`, confirms, sees new seat ID.
3. **Reassign seat owner**: User runs `/rkit:seats update 42 --owner 5`, confirms, sees updated owner.
4. **Reorganize chart**: User runs `/rkit:seats move 42 --parent 15`, confirms, verifies with `/rkit:seats`.
5. **Align KPI to seat**: User runs `/rkit:seats align-measure 42 --measure 793`, confirms, sees updated measures list.
