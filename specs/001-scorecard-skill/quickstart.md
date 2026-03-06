# Quickstart: Testing rkit:scorecard

**Branch**: `001-scorecard-skill` | **Date**: 2026-03-05

Use these scenarios to manually test the scorecard skill end-to-end.

## Prerequisites

- `~/.config/resultkit/config.json` configured with a valid token and `default_team_id`
- The team has at least one measure (or test create first)

---

## Scenario 1: View scorecard (US1)

```
/rkit:scorecard
```

**Expected**: Table of active measures with name, unit, direction, target, owner, and last 4 weeks of history. If no measures, friendly empty-state message.

```
/rkit:scorecard --year 2025
```

**Expected**: Same table but history from 2025.

```
/rkit:scorecard --include-archived
```

**Expected**: Archived measures appear in the table (visually marked, e.g., strikethrough or `[archived]` label).

---

## Scenario 2: Record a weekly value (US2)

```
/rkit:scorecard record "Weekly Signups" 47
```

**Expected**: Confirmation prompt → on `y` → "Recorded: Weekly Signups — 47 for week of [current Monday]."

```
/rkit:scorecard record "Weekly Signups" 47 date=2026-01-05
```

**Expected**: Same but for the specified date.

```
/rkit:scorecard record "Weekly Signups" abc
```

**Expected**: Error — "Value must be a number." No API call made.

---

## Scenario 3: Create a measure (US3)

```
/rkit:scorecard add "New KPI"
```

**Expected**: Confirmation → on `y` → "Created: New KPI (ID: N, unit: none, direction: higher)."

```
/rkit:scorecard add "Revenue" unit="$" direction=higher target=50000
```

**Expected**: Confirmation → on `y` → "Created: Revenue (ID: N, unit: $, direction: higher, target: 50000)."

```
/rkit:scorecard add
```

**Expected**: Error — "Measure name is required."

---

## Scenario 4: Update a measure (US4)

```
/rkit:scorecard update "New KPI" target=100
```

**Expected**: Confirmation → on `y` → "Updated: New KPI — target set to 100."

```
/rkit:scorecard update "New KPI" name="Renamed KPI" unit="#"
```

**Expected**: Confirmation → on `y` → "Updated: Renamed KPI."

---

## Scenario 5: Archive a measure (US4)

```
/rkit:scorecard archive "Renamed KPI"
```

**Expected**: Confirmation → on `y` → "Archived: Renamed KPI (ID: N). It will no longer appear in the default scorecard view."

Verify by running `/rkit:scorecard` — measure should be gone from default view.
Run `/rkit:scorecard --include-archived` — measure should still appear with `[archived]` label.

---

## Scenario 6: Error handling

```
/rkit:scorecard record "Nonexistent Measure" 42
```

**Expected**: "No measure found matching 'Nonexistent Measure'."

```
/rkit:scorecard archive "Sign"   # matches "Weekly Signups" and "Signups Rate"
```

**Expected**: Disambiguation list — "Multiple measures match 'Sign'. Which did you mean? 1. Weekly Signups, 2. Signups Rate"
