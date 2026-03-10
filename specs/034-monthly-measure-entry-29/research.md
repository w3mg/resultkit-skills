# Research: Monthly Measure Entry

**Branch**: `034-monthly-measure-entry-29` | **Date**: 2026-03-10

## Summary

No unknowns requiring external research. The API change handoff (issue #29) is authoritative and complete. The existing scorecard skill implementation is fully readable. All decisions are documented below.

---

## Decision 1: How is `period` passed to the API?

**Decision**: `POST /measures/{id}/history` accepts an optional `period` field in the JSON body: `"week"` or `"month"`. Omitting it defaults to `"week"` (existing behaviour unchanged).

**Source**: Issue #29 — "The default behaviour when `period` is omitted is identical to before."

**API request shape (monthly)**:
```json
{ "date": "2026-03", "value": "87", "period": "month" }
```

**API request shape (weekly — unchanged)**:
```json
{ "date": "2026-01-05", "value": "42" }
```

---

## Decision 2: What date formats are accepted for monthly entries?

**Decision**: Both `YYYY-MM` and `YYYY-MM-01` are accepted as input for monthly `date`. The API response always normalises `date` to `YYYY-MM-01`.

**Source**: Issue #29 — "Both `2026-03` and `2026-03-01` are accepted for the monthly date."

**Implication for skill**: The skill can pass `YYYY-MM` (shorter, natural for users). The confirmed response will always show `YYYY-MM-01`, which the skill displays as-is.

---

## Decision 3: How does the skill argument pattern extend for monthly?

**Decision**: Extend the existing `record` command with an optional `period=month` flag. When present, `date` is interpreted as `YYYY-MM` and sent with `period: "month"`.

**New argument pattern**:
```
record "NAME" VALUE [date=YYYY-MM-DD|YYYY-MM] [period=month]
```

**Rationale**:
- Minimal change to existing command surface — users who don't use `period=month` see no difference.
- Consistent with existing `date=...` key=value flag style already used in the skill.
- A separate `record monthly` subcommand was considered but rejected — it duplicates most of the `record` flow and splits the UX surface unnecessarily.

**Alternative considered**: Add `record monthly "NAME" VALUE month=YYYY-MM` as a distinct subcommand. Rejected — more surface area, same outcome, inconsistent with `record note` vs `note` split (which is intentionally different).

---

## Decision 4: How should date resolution work for monthly entries?

**Decision**:
- If `date=YYYY-MM` is provided: use directly as the monthly date.
- If `date=YYYY-MM-DD` is provided with `period=month`: truncate to `YYYY-MM` (take first 7 chars).
- If no `date` is provided and `period=month` is present: default to the **current month** (`date +%Y-%m`).

**Rationale**: Analogous to how the weekly flow defaults to the current Monday when no date is given. Monthly default to current month is the most natural equivalent.

---

## Decision 5: Does the existing weekly flow need any changes?

**Decision**: No. The existing `Flow: Record Value` passes no `period` field, so it continues to work exactly as before. The API change is additive and backward-compatible.

**Scope**: Only the `Flow: Record Value` section of `skills/scorecard/SKILL.md` needs changes — plus updating the argument table row and `api-reference.md`.

---

## Decision 6: Where do weekly-specific date validations land?

**Decision**: The existing client-side check that `VALUE` is numeric applies to both weekly and monthly flows. The existing server-side 422 for bad dates also applies to both. No new client-side date validation needed — the API handles invalid `YYYY-MM` format.

**Rationale**: Consistent with the existing approach of relying on server-side 422 for date validation and only doing client-side validation for numeric value check (which is already in the skill).

---

## Decision 7: What files change?

| File | Change |
|------|--------|
| `api-reference.md` | Update `POST /measures/{id}/history` row to document `period` field and monthly date format |
| `skills/scorecard/SKILL.md` | Update argument table; update `Flow: Record Value` to handle `period=month` |
| `skills/scorecard/references/api-reference.md` | Synced copy (via `/sync-plugin`) |

No new files needed. No new skill. The scorecard skill description and rules need a minor update to mention monthly support.
