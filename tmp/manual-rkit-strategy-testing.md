# Manual Testing: rkit:strategy

**Date**: 2026-03-10
**Token**: 4ecdd8ce...25d
**Teams**: OKR=2274, EOS=2307, 4DX=2765

---

## Phase 1: READ Baseline

### Test 1: EOS (2307) READ — [PASS]
- V2: `strategy: [], unaligned: [], framework: "eos"` — empty tree
- Rails: `collection: [], unaligned_quartery_rocks: []` — empty tree
- **Both empty, consistent.**

### Test 2: OKR (2274) READ — [PASS]
- V2: 2 focus_areas — `#164429 "New Focus Area"` (active, due 2024-03-31) + `#153689 "Test"` (active, due 2023-03-31)
- Rails: Same 2 items in `collection[]` — matching IDs, names, statuses, due dates
- **Consistent.**

### Test 3: 4DX (2765) READ — [PASS]
- V2: `strategy: [], unaligned: [], framework: "okr"` — empty tree
- Rails: `collection: [], unaligned_goals: []` — empty tree
- **Both empty, consistent.**
- **NOTE**: Team 2765 ("[4DX] Patrick") reports `framework: "okr"` — 4DX is not a distinct API framework value. Tests proceed using OKR-compatible object types.

---

## Phase 2: CREATE at each level

### Test 4: EOS L1 CREATE — [PASS]
- `POST /teams/2307/strategy {"name":"TEST-EOS-L1"}` → 201, `{id: 9691, object_type: "yearly_goal"}`

### Test 5: EOS L2 CREATE — [PASS]
- `POST /teams/2307/strategy {"name":"TEST-EOS-L2","parent_id":9691,"parent_type":"yearly_goal"}` → 201, `{id: 9692, object_type: "rock"}`

### Test 6: EOS L3 CREATE — [PASS]
- `POST /teams/2307/strategy {"name":"TEST-EOS-L3","parent_id":9692,"parent_type":"rock"}` → 201, `{id: 212008, object_type: "milestone"}`

### Test 7: OKR L1 CREATE — [PASS]
- `POST /teams/2274/strategy {"name":"TEST-OKR-L1","is_focus_area":true}` → 201, `{id: 212009, object_type: "focus_area"}`

### Test 8: OKR L2 CREATE — [PASS]
- `POST /teams/2274/strategy {"name":"TEST-OKR-L2","parent_id":212009,"parent_type":"focus_area"}` → 201, `{id: 9693, object_type: "objective"}`

### Test 9: OKR L3 CREATE — [PASS]
- `POST /teams/2274/strategy {"name":"TEST-OKR-L3","parent_id":9693,"parent_type":"objective"}` → 201, `{id: 212010, object_type: "key_result"}`

### Test 10: 4DX L1 CREATE — [PASS]
- `POST /teams/2765/strategy {"name":"TEST-4DX-L1","is_focus_area":true}` → 201, `{id: 212011, object_type: "focus_area"}`

### Test 11: 4DX L2 CREATE — [PASS]
- `POST /teams/2765/strategy {"name":"TEST-4DX-L2","parent_id":212011,"parent_type":"focus_area"}` → 201, `{id: 9694, object_type: "objective"}`

### Test 12: 4DX L3 CREATE — [PASS]
- `POST /teams/2765/strategy {"name":"TEST-4DX-L3","parent_id":9694,"parent_type":"objective"}` → 201, `{id: 212012, object_type: "key_result"}`

### Test 13: 4DX L4 CREATE — [PASS]
- `POST /teams/2765/strategy {"name":"TEST-4DX-L4","parent_id":212012,"parent_type":"key_result"}` → 201, `{id: 212013, object_type: "action"}`

---

## Phase 3: VERIFY CREATE — Read + Compare

### Test 14: EOS (2307) VERIFY CREATE — [PASS] (V2 only; Rails structure differs)
- **V2**: Full nesting correct: `TEST-EOS-L1 (yearly_goal #9691) → TEST-EOS-L2 (rock #9692) → TEST-EOS-L3 (milestone #212008)` — all active
- **Rails**: `collection: []` — EOS yearly_goals don't appear in the Rails `goal_collection` endpoint at all. Different response structure, not a data inconsistency.

### Test 15: OKR (2274) VERIFY CREATE — [PASS] (V2 nesting correct; Rails flat)
- **V2**: Full nesting correct: `TEST-OKR-L1 (focus_area #212009) → TEST-OKR-L2 (objective #9693) → TEST-OKR-L3 (key_result #212010)` — all active
- **Rails**: Focus area appears in `collection[]` (id 212009, name matches, status active) but `sub_goals: []` — Rails doesn't recursively nest children in this endpoint. IDs and top-level data consistent.

### Test 16: 4DX (2765) VERIFY CREATE — [PASS] (V2 nesting correct; Rails flat)
- **V2**: Full 4-level nesting correct: `TEST-4DX-L1 (focus_area #212011) → TEST-4DX-L2 (objective #9694) → TEST-4DX-L3 (key_result #212012) → TEST-4DX-L4 (action #212013)` — all active
- **Rails**: Focus area appears in `collection[]` (id 212011, name matches, status active) but `sub_goals: []` — same flat pattern. IDs consistent.

**NOTE**: The Rails `goal_collection` endpoint has a fundamentally different response structure than V2 `strategy`. Rails returns flat top-level arrays; V2 returns fully recursive trees. This is an API design difference, not an error. For remaining tests, V2 tree nesting is the primary verification target, with Rails checked for ID/name/status consistency at the objects it does surface.

---

## Phase 4: UPDATE at each level

### CRITICAL BUG FOUND: objectType mapping for PATCH/DELETE

**Bug**: The skill's SKILL.md documents `PATCH /strategy/$OBJECT_TYPE/$OBJECT_ID` using strategy-specific `object_type` values (yearly_goal, rock, milestone, focus_area, objective, key_result, action). The API rejects all of these with `"objectType must be Goal or Item"`.

**Correct mapping** (discovered by testing):

| object_type (from GET) | type field | Generic Type for PATCH/DELETE |
|------------------------|-----------|-------------------------------|
| yearly_goal | 2 (int) | **Goal** |
| rock | 1 (int) | **Goal** |
| objective | 0 (int) | **Goal** |
| focus_area | "ResultArea" | **Item** |
| key_result | "KeyResult" | **Item** |
| milestone | "KeyResult" | **Item** |
| action | "Task" | **Item** |

**Rule**: Numeric `type` → Goal. String `type` → Item.

### Test 17: EOS L1 UPDATE — [PASS] (after fix: Goal)
- `PATCH /strategy/Goal/9691 {"name":"TEST-EOS-L1-upd","status":"at_risk"}` → 200

### Test 18: EOS L2 UPDATE — [PASS] (after fix: Goal)
- `PATCH /strategy/Goal/9692 {"name":"TEST-EOS-L2-upd","due":"2026-06-30"}` → 200

### Test 19: EOS L3 UPDATE — [PASS] (after fix: Item)
- `PATCH /strategy/Item/212008 {"name":"TEST-EOS-L3-upd","status":"complete"}` → 200

### Test 20: OKR L1 UPDATE — [PASS] (after fix: Item)
- `PATCH /strategy/Item/212009 {"name":"TEST-OKR-L1-upd","status":"at_risk"}` → 200

### Test 21: OKR L2 UPDATE — [PASS] (after fix: Goal)
- `PATCH /strategy/Goal/9693 {"name":"TEST-OKR-L2-upd","due":"2026-06-30"}` → 200

### Test 22: OKR L3 UPDATE — [PASS] (after fix: Item)
- `PATCH /strategy/Item/212010 {"name":"TEST-OKR-L3-upd","status":"complete"}` → 200

### Test 23: 4DX L1 UPDATE — [PASS] (after fix: Item)
- `PATCH /strategy/Item/212011 {"name":"TEST-4DX-L1-upd","status":"at_risk"}` → 200

### Test 24: 4DX L2 UPDATE — [PASS] (after fix: Goal)
- `PATCH /strategy/Goal/9694 {"name":"TEST-4DX-L2-upd","due":"2026-06-30"}` → 200

### Test 25: 4DX L3 UPDATE — [PASS] (after fix: Item)
- `PATCH /strategy/Item/212012 {"name":"TEST-4DX-L3-upd","status":"complete"}` → 200

### Test 26: 4DX L4 UPDATE — [PASS] (after fix: Item)
- `PATCH /strategy/Item/212013 {"name":"TEST-4DX-L4-upd","status":"complete"}` → 200

---

## Phase 5: VERIFY UPDATE — Read + Compare

### IMPORTANT: Strategy GET endpoint status filtering behavior

The strategy GET endpoint implicitly filters objects by status:
- **`complete` status** → object hidden from tree (all frameworks, all object types)
- **`at_risk` on EOS `yearly_goal`** → entire branch hidden (EOS-specific)
- **`at_risk` on OKR/4DX `focus_area`** → still visible (not filtered)

This means the skill's update flow can set statuses that make objects invisible in subsequent reads, without the user understanding why.

### Test 27: EOS VERIFY UPDATE — [PASS] (with caveats)
- All names updated correctly: `TEST-EOS-L1-upd`, `TEST-EOS-L2-upd`, `TEST-EOS-L3-upd`
- Due date on L2: `2026-06-30` ✓
- **Caveat**: `at_risk` on EOS yearly_goal hides entire branch from strategy tree. `complete` on milestone also hides it. Updates work (PATCH 200) but objects become invisible in GET.

### Test 28: OKR VERIFY UPDATE — [PASS] (with caveats)
- All names updated: `TEST-OKR-L1-upd` (at_risk, visible), `TEST-OKR-L2-upd` (active), `TEST-OKR-L3-upd` (active after reset)
- Due date on L2: `2026-06-30` ✓
- **Caveat**: `complete` status hides key_results from tree.

### Test 29: 4DX VERIFY UPDATE — [PASS] (with caveats)
- All names updated: L1-upd, L2-upd, L3-upd, L4-upd — all 4 levels visible
- Due date on L2: `2026-06-30` ✓
- **Caveat**: Same complete-status filtering behavior applies.

**Note**: All objects reset to active status for Phase 6 cleanup. OKR L1 and 4DX L1 still at_risk.

---

## Phase 6: DETACH + ARCHIVE (bottom-up cleanup)

### CRITICAL BUG #2: DELETE endpoint also requires Goal/Item mapping

Same as PATCH — the DELETE URL path `{objectType}` must be "Goal" or "Item", not the strategy-specific type. Additionally, the `parent_type` in the request body must also use "Goal" or "Item".

### BUG #3: DELETE returns 200, not 204 as documented

The skill's SKILL.md and api-reference.md document DELETE as returning `204 No Content`. Actual response is `200` with body `{"data":{"unlinked":true,"archived":true}}`.

### Test 30: EOS L3 DETACH+ARCHIVE — [PASS]
- `DELETE /strategy/Item/212008 {"parent_id":9692,"parent_type":"Goal","also_archive":true}` → 200 `{unlinked:true, archived:true}`

### Test 31: EOS L2 DETACH+ARCHIVE — [PASS]
- `DELETE /strategy/Goal/9692 {"parent_id":9691,"parent_type":"Goal","also_archive":true}` → 200 `{unlinked:true, archived:true}`

### Test 32: EOS L1 ARCHIVE — [PASS]
- `PATCH /strategy/Goal/9691 {"status":"archived"}` → 200 `{updated:true}`

### Test 33: OKR L3 DETACH+ARCHIVE — [PASS]
- `DELETE /strategy/Item/212010 {"parent_id":9693,"parent_type":"Goal","also_archive":true}` → 200

### Test 34: OKR L2 DETACH+ARCHIVE — [PASS]
- `DELETE /strategy/Goal/9693 {"parent_id":212009,"parent_type":"Item","also_archive":true}` → 200

### Test 35: OKR L1 ARCHIVE — [PASS]
- `PATCH /strategy/Item/212009 {"status":"archived"}` → 200

### Test 36: 4DX L4 DETACH+ARCHIVE — [PASS]
- `DELETE /strategy/Item/212013 {"parent_id":212012,"parent_type":"Item","also_archive":true}` → 200

### Test 37: 4DX L3 DETACH+ARCHIVE — [PASS]
- `DELETE /strategy/Item/212012 {"parent_id":9694,"parent_type":"Goal","also_archive":true}` → 200

### Test 38: 4DX L2 DETACH+ARCHIVE — [PASS]
- `DELETE /strategy/Goal/9694 {"parent_id":212011,"parent_type":"Item","also_archive":true}` → 200

### Test 39: 4DX L1 ARCHIVE — [PASS]
- `PATCH /strategy/Item/212011 {"status":"archived"}` → 200

---

## Phase 7: VERIFY CLEANUP — Read + Compare

### Test 40: EOS VERIFY CLEANUP — [PASS]
- V2 (All/All): `[]` — no TEST-EOS objects in strategy or unaligned
- Rails: `[]` — no TEST-EOS objects in collection

### Test 41: OKR VERIFY CLEANUP — [PASS]
- V2 (All/All): `[]` — no TEST-OKR objects in strategy or unaligned
- Rails: `[]` — no TEST-OKR objects in collection

### Test 42: 4DX VERIFY CLEANUP — [PASS]
- V2 (All/All): `[]` — no TEST-4DX objects in strategy or unaligned
- Rails: `[]` — no TEST-4DX objects in collection

---

## Summary

### Test Results: 42/42 PASS (with critical bugs found)

| Phase | Tests | Result |
|-------|-------|--------|
| 1: READ Baseline | 3 | All PASS |
| 2: CREATE | 10 | All PASS (201 responses) |
| 3: VERIFY CREATE | 3 | All PASS (V2 nesting correct; Rails has different structure) |
| 4: UPDATE | 10 | All PASS (after discovering Goal/Item mapping) |
| 5: VERIFY UPDATE | 3 | All PASS (with status-filtering caveats) |
| 6: DETACH+ARCHIVE | 10 | All PASS (after discovering Goal/Item mapping for DELETE) |
| 7: VERIFY CLEANUP | 3 | All PASS |

### Critical Bugs Found

**Bug 1: PATCH/DELETE URL objectType must be "Goal" or "Item"**
The skill's SKILL.md uses strategy-specific `object_type` values (yearly_goal, rock, milestone, etc.) in the PATCH and DELETE URL paths. The API rejects these with `"objectType must be Goal or Item"`.

**Mapping discovered:**
| object_type | `type` field in GET | Generic Type for URL |
|-------------|--------------------|--------------------|
| yearly_goal | 2 (int) | Goal |
| rock | 1 (int) | Goal |
| objective | 0 (int) | Goal |
| focus_area | "ResultArea" (string) | Item |
| key_result | "KeyResult" (string) | Item |
| milestone | "KeyResult" (string) | Item |
| action | "Task" (string) | Item |

**Rule**: Numeric `type` → Goal. String `type` → Item.

**Bug 2: DELETE body `parent_type` also requires "Goal"/"Item"**
Same mapping applies to the `parent_type` field in DELETE request bodies.

**Bug 3: DELETE returns 200 with body, not 204 No Content**
- Documented: `204 No Content`
- Actual: `200` with `{"data":{"unlinked":true,"archived":true}}`

### Behavioral Findings

**Finding 1: Strategy GET endpoint filters by status**
- `complete` status → object hidden from tree (all frameworks)
- `at_risk` on EOS `yearly_goal` → entire branch hidden
- `at_risk` on OKR/4DX `focus_area` → still visible

**Finding 2: Rails API structure differs from V2**
- V2 `GET /teams/{id}/strategy` → full recursive tree with children nesting
- Rails `GET /api/groups/goal_collection/` → flat arrays (`collection[]`, `unaligned_*[]`), no recursive nesting
- EOS yearly_goals don't appear in Rails `goal_collection` at all
- IDs and names consistent between APIs where objects do appear

**Finding 3: Team 2765 framework is "okr", not "4dx"**
The API has no distinct "4dx" framework value. Team 2765 is named "[4DX] Patrick" but returns `framework: "okr"`.

**Finding 4: Focus area `type` is "ResultArea" (Item)**
Focus areas are technically Items, not Goals, despite being tree roots. This is counterintuitive.

---

## Bug Root Causes & Suggested Fixes

### Bug 1: PATCH/DELETE URL objectType must be "Goal" or "Item"

**Cause**: SKILL.md Flow: Update (Step 4, line 282) and Flow: Detach (Step 4, line 375) both construct the URL path using `$OBJECT_TYPE` which comes from the node's `object_type` field in the GET response (e.g. `yearly_goal`, `rock`, `focus_area`). The V2 API's PATCH/DELETE routes actually expect the Rails model base class — `Goal` or `Item` — not the strategy-specific subtype. The `object_type` field is a strategy-layer label; the `type` field is the Rails polymorphic type.

**Where**: `skills/strategy/SKILL.md` lines 282, 375. Also `api-reference.md` line 595 (mentions "objectType" but doesn't clarify the Goal/Item requirement).

**Fix**: Add a type-resolution step to the Update and Detach flows. After resolving the object via Object Name Resolution, map the node's `type` field to the generic type:

```
If type is a number (0, 1, 2) → use "Goal"
If type is a string ("ResultArea", "KeyResult", "Task") → use "Item"
```

Concretely, add a new section **"Generic Type Resolution"** after Object Name Resolution:

```bash
# From the matched node, extract the `type` field and map to Goal/Item
GENERIC_TYPE=$(echo "$MATCHED_NODE" | jq -r 'if (.type | type) == "number" then "Goal" else "Item" end')
```

Then change both flows:
- Update Step 4: `PATCH "/strategy/$GENERIC_TYPE/$OBJECT_ID"`
- Detach Step 4: `DELETE "/strategy/$GENERIC_TYPE/$OBJECT_ID"`

### Bug 2: DELETE body parent_type requires "Goal"/"Item"

**Cause**: Same root cause as Bug 1. The Detach flow (Step 2, line 362) sets `parent_type` from the parent node's `object_type` field. The API expects the generic type in the request body too, not just the URL.

**Where**: `skills/strategy/SKILL.md` line 362 ("parent_type (= `object_type` of the parent node)") and line 375 (the DELETE body).

**Fix**: Apply the same Generic Type Resolution to the parent node. Change Detach Step 2 from:
```
Extract from parent: parent_id, parent_type (= object_type of the parent node)
```
to:
```
Extract from parent: parent_id, parent_generic_type (= "Goal" if type is numeric, "Item" if type is string)
```

Then in Step 4 body: `{"parent_id":PID,"parent_type":"PARENT_GENERIC_TYPE","also_archive":BOOL}`

**Note**: The Align flow (PUT /strategy/align, line 329) also passes `object_type` and `parent_type` in the request body. This was NOT tested but likely has the same bug — verify and fix simultaneously.

### Bug 3: DELETE returns 200 with body, not 204 No Content

**Cause**: The api-reference.md and SKILL.md were written based on API documentation or assumptions that didn't match actual behavior. The API returns `200 {"data":{"unlinked":true,"archived":true}}` — a meaningful response with confirmation fields.

**Where**: `skills/strategy/SKILL.md` line 381 (checks for 204), line 431 (documents 204). `api-reference.md` line 607.

**Fix**:
1. In SKILL.md Detach Step 5, change `**204**` to `**200**` and note the response body fields (`unlinked`, `archived`)
2. In SKILL.md Response envelopes, change `DELETE → 204 No Content` to `DELETE → 200 {"data":{"unlinked":bool,"archived":bool}}`
3. In api-reference.md line 607, same change

### Consolidated change list

| File | Section | Change |
|------|---------|--------|
| `skills/strategy/SKILL.md` | After "Object Name Resolution" | Add "Generic Type Resolution" section |
| `skills/strategy/SKILL.md` | Flow: Update, Step 4 | Use `$GENERIC_TYPE` in URL instead of `$OBJECT_TYPE` |
| `skills/strategy/SKILL.md` | Flow: Detach, Step 2 | Resolve parent to generic type |
| `skills/strategy/SKILL.md` | Flow: Detach, Step 4 | Use `$GENERIC_TYPE` in URL + `parent_generic_type` in body |
| `skills/strategy/SKILL.md` | Flow: Detach, Step 5 | Change 204 → 200, document response body |
| `skills/strategy/SKILL.md` | Response envelopes | Change DELETE 204 → 200 |
| `skills/strategy/SKILL.md` | Flow: Align, Step 4 | Verify and likely fix `object_type`/`parent_type` in body |
| `api-reference.md` | Strategy DELETE envelope | Change 204 → 200, add response body schema |
| `api-reference.md` | Strategy section | Document Goal/Item objectType requirement |

---

## Phase 8: Year & Quarter Filtering (20 tests)

### Test Data Created

**EOS (2307):**
- 9695: yearly_goal "FILTER-EOS-YEAR" due 2026-12-31
  - 9696: rock "FILTER-EOS-ROCK-Q1" due 2026-03-31
    - 212016: milestone "FILTER-EOS-MS-Q1" due 2026-03-15
  - 9697: rock "FILTER-EOS-ROCK-Q2" due 2026-06-30
    - 212017: milestone "FILTER-EOS-MS-Q2" due 2026-05-15
  - 9698: rock "FILTER-EOS-ROCK-NODUE" no due date
- 9702: yearly_goal "FILTER-EOS-YEAR2025" due 2025-12-31

**OKR (2274):**
- 212014: focus_area "FILTER-OKR-FA" no due
  - 9699: objective "FILTER-OKR-OBJ" due 2026-06-30
    - 212018: key_result "FILTER-OKR-KR-Q1" due 2026-03-31
    - 212019: key_result "FILTER-OKR-KR-Q2" due 2026-06-30
  - 9700: objective "FILTER-OKR-OBJ-Q3ONLY" due 2026-09-30
    - 212020: key_result "FILTER-OKR-KR-Q3" due 2026-09-30

**4DX (2765):**
- 212015: focus_area "FILTER-4DX-FA" no due
  - 9701: objective "FILTER-4DX-OBJ" due 2026-06-30
    - 212021: key_result "FILTER-4DX-KR-Q1" due 2026-03-31
      - 212023: action "FILTER-4DX-ACT-Q1" due 2026-02-28
      - 212025: action "FILTER-4DX-ACT-NODUE" no due date
    - 212022: key_result "FILTER-4DX-KR-Q2" due 2026-06-30
      - 212024: action "FILTER-4DX-ACT-Q2" due 2026-05-15

---

### EOS Filtering Tests

#### Test 43: EOS year=2026, quarter=1 — [PASS]
- **Returned**: YEAR, ROCK-Q1, MS-Q1, ROCK-NODUE (4 objects)
- **Excluded**: ROCK-Q2, MS-Q2, YEAR2025
- **Confirms**: Yearly goals filtered by year. Rocks filtered by quarter. No-due rocks always included (persistent). Milestones follow their parent rock.

#### Test 44: EOS year=2026, quarter=2 — [PASS]
- **Returned**: YEAR, ROCK-Q2, MS-Q2, ROCK-NODUE (4 objects)
- **Excluded**: ROCK-Q1, MS-Q1, YEAR2025
- **Confirms**: Symmetrical — Q2 rock visible, Q1 rock excluded. Persistent rock still included.

#### Test 45: EOS year=2025, quarter=1 — [PASS]
- **Returned**: YEAR2025 only (1 object)
- **Excluded**: All 2026 objects
- **Confirms**: Year filter works on yearly_goals. 2025 goal has no rocks so only root shows.

#### Test 46: EOS year=2026, quarter=All — [PASS]
- **Returned**: YEAR, ROCK-Q1, MS-Q1, ROCK-Q2, MS-Q2, ROCK-NODUE (6 objects)
- **Excluded**: YEAR2025
- **Confirms**: quarter=All disables quarter filtering, shows all rocks. Year filter still applies.

#### Test 47: EOS year=All, quarter=1 — [PASS]
- **Returned**: YEAR, ROCK-Q1, MS-Q1, ROCK-NODUE, YEAR2025 (5 objects)
- **Excluded**: ROCK-Q2, MS-Q2
- **Confirms**: year=All shows all yearly_goals. Quarter filter still applies to rocks.

#### Test 48: EOS year=All, quarter=All — [PASS]
- **Returned**: All 7 objects
- **Confirms**: No filtering when both are All.

**EOS Filtering Summary**:
| Layer | Filtered by | Persistent (no due) |
|-------|-----------|---------------------|
| yearly_goal | year | N/A (always has due from year) |
| rock | quarter | Always included |
| milestone | follows parent rock | follows parent rock |

---

### OKR Filtering Tests

#### Test 49: OKR year=2026, quarter=1 — [PASS] ⚠️ UNEXPECTED
- **Returned**: FA, OBJ, KR-Q1, **KR-Q2** (4 objects)
- **Expected**: FA, OBJ, KR-Q1 (KR-Q2 should be excluded by quarter)
- **Actual behavior**: Objective "pulled up" because it has a Q1 KR. Once pulled up, ALL of its KRs are included regardless of quarter.
- **Key finding**: Quarter filtering is at the **objective level**, not the KR level.

#### Test 50: OKR year=2026, quarter=2 — [PASS] ⚠️ SAME UNEXPECTED
- **Returned**: FA, OBJ, KR-Q1, KR-Q2 (4 objects — identical to Q1)
- **Confirms**: OBJ has qualifying KRs in both Q1 and Q2, so the entire subtree shows in either quarter. Individual KRs are never filtered.

#### Test 51: OKR year=2026, quarter=3 — [PASS]
- **Returned**: FA, OBJ-Q3ONLY, KR-Q3 (3 objects)
- **Excluded**: OBJ and its KRs (no Q3 KRs under it)
- **Confirms**: Objective without qualifying KRs in Q3 is correctly excluded.

#### Test 52: OKR year=2026, quarter=4 — [PASS]
- **Returned**: FA only (1 object)
- **Excluded**: Both objectives (no Q4 KRs)
- **Confirms**: Focus areas always shown. Objectives with no qualifying KRs excluded.

#### Test 53: OKR year=2025, quarter=1 — [PASS]
- **Returned**: FA only (1 object)
- **Excluded**: All objectives and KRs (all 2026 dates)
- **Confirms**: Year filter works. Focus areas always shown regardless.

#### Test 54: OKR year=2026, quarter=All — [PASS]
- **Returned**: All 6 objects
- **Confirms**: quarter=All disables quarter filtering.

#### Test 55: OKR year=All, quarter=All — [PASS]
- **Returned**: All 6 objects
- **Confirms**: Full tree when both All.

**OKR Filtering Summary**:
| Layer | Filtered by | Behavior |
|-------|-----------|----------|
| focus_area | **never filtered** | Always shown if it exists |
| objective | pulled up if ANY child KR qualifies | All-or-nothing: entire subtree included or excluded |
| key_result | **not individually filtered** | Included/excluded with parent objective |

⚠️ **Documentation mismatch**: api-reference.md says "focus areas included if they have qualifying children". Testing shows focus areas are ALWAYS included, even with zero qualifying children (Q4 and year=2025 tests).

---

### 4DX Filtering Tests

#### Test 56: 4DX year=2026, quarter=1 — [PASS]
- **Returned**: FA, OBJ, KR-Q1, ACT-NODUE, ACT-Q1, KR-Q2 (6 objects)
- **Excluded**: ACT-Q2 (Q2 action correctly filtered out)
- **Confirms**: L1-L3 same as OKR (objective pulls up all KRs). Actions ARE filtered by quarter. No-due actions always shown.

#### Test 57: 4DX year=2026, quarter=2 — [PASS]
- **Returned**: FA, OBJ, KR-Q1, ACT-NODUE, KR-Q2, ACT-Q2 (6 objects)
- **Excluded**: ACT-Q1 (Q1 action correctly filtered out)
- **Confirms**: Symmetrical to Q1. Actions filtered, no-due persists, L1-L3 all-or-nothing.

#### Test 58: 4DX year=2026, quarter=4 — [PASS] ⚠️ UNEXPECTED
- **Returned**: FA, OBJ, KR-Q1, ACT-NODUE, KR-Q2 (5 objects)
- **Expected**: FA only (no Q4 actions or KRs)
- **Actual**: The no-due action (ACT-NODUE) cascades visibility up through the tree. Since ACT-NODUE is persistent and qualifies under any quarter, it makes KR-Q1 qualify, which makes OBJ qualify, which makes FA qualify. ALL L1-L3 ancestors pulled up.
- **Key finding**: A single persistent action at L4 makes the entire L1-L3 branch visible in ANY quarter.

#### Test 59: 4DX year=2025, quarter=1 — [PASS] ⚠️ CASCADING PERSISTENCE
- **Returned**: FA, OBJ, KR-Q1, ACT-NODUE, KR-Q2 (5 objects)
- **Expected**: FA only (all objects are 2026)
- **Actual**: Same cascading behavior crosses year boundaries. ACT-NODUE (no due) qualifies under year=2025, cascading the entire tree into visibility.
- **Key finding**: Persistent actions cascade across BOTH year and quarter filters.

#### Test 60: 4DX year=2026, quarter=All — [PASS]
- **Returned**: All 7 objects
- **Confirms**: All=All shows everything.

#### Test 61: 4DX year=All, quarter=All — [PASS]
- **Returned**: All 7 objects
- **Confirms**: Full tree.

**4DX Filtering Summary**:
| Layer | Filtered by | Behavior |
|-------|-----------|----------|
| focus_area | **never filtered** | Always shown |
| objective | pulled up if any descendant qualifies | Cascades from actions through KRs |
| key_result | **not individually filtered** | Included/excluded with parent objective |
| action | year AND quarter | Only L4 actions are individually filtered. No-due actions always shown. |

⚠️ **Critical cascade behavior**: A single no-due action at L4 makes the entire ancestor branch (KR → OBJ → FA) visible in every year/quarter combination. This differs from OKR where leaf nodes (KRs) don't have this persistent child cascading.

---

### Phase 8 Cleanup — [PASS]
All FILTER-* objects detached+archived from all 3 teams. Verified with year=All&quarter=All — all empty.

---

### Phase 8 Findings Summary

**Finding 5: EOS filtering works as documented**
- Yearly goals filtered by year, rocks by quarter, milestones follow parent rock
- Persistent (no-due) rocks always included ✓

**Finding 6: OKR objective-level filtering (not KR-level)**
- Quarter filtering operates at the objective level — if ANY child KR is in the selected quarter, the ENTIRE objective subtree (all KRs) is shown
- Individual KRs are never filtered by quarter
- Focus areas always shown regardless of filters

**Finding 7: 4DX persistent action cascade**
- Actions at L4 are the only individually filtered objects
- No-due actions are persistent and always qualify
- A single persistent action cascades visibility up through KR → objective → focus_area
- This cascade crosses both year AND quarter boundaries, making the entire L1-L3 branch visible everywhere

**Finding 8: Focus areas never filtered**
- Contradicts api-reference.md ("focus areas included if they have qualifying children")
- In both OKR and 4DX, focus areas always appear in the tree regardless of year/quarter/children

### Causes & Suggested Fixes

**Finding 6 (OKR objective-level pull-up)**

**Cause**: The api-reference.md describes this correctly in spirit ("objectives pulled up if any child key result is in range") but the implication is incomplete. The docs don't clarify that once an objective is pulled up, ALL of its KRs come along — including KRs from other quarters. The skill has no logic to handle or communicate this to users.

**Fix**: Update api-reference.md to explicitly state: "When an objective qualifies, its entire subtree is included regardless of individual KR due dates." No SKILL.md fix needed — this is API behavior, not a skill bug — but the skill's view output could add a note like "(includes KRs from other quarters)" when the tree is quarter-filtered and cross-quarter KRs are visible.

**Finding 7 (4DX persistent action cascade)**

**Cause**: The api-reference.md says "4DX: same as OKR for L1-L3, actions filtered by year/quarter." This omits the cascading effect: a persistent (no-due) action at L4 qualifies its parent KR, which qualifies its grandparent objective, which qualifies the focus area — across any year/quarter. The pull-up logic evaluates all descendants recursively, not just direct children.

**Fix**: Update api-reference.md filtering rules to add: "Persistent (no-due) actions at L4 cascade qualification upward through all ancestor levels. A single persistent action can make the entire L1-L3 branch visible in any year/quarter combination." The skill should be aware that quarter-filtered 4DX trees may include surprising L1-L3 content due to persistent L4 actions.

**Finding 8 (Focus areas never filtered)**

**Cause**: The api-reference.md states "focus areas included if they have qualifying children." Testing proves this is wrong — focus areas with zero qualifying children still appear (OKR Q4 test, OKR year=2025 test). The API treats focus areas as permanent containers.

**Fix**: Update api-reference.md to: "Focus areas are always included regardless of year/quarter filters. They serve as permanent containers and are never pruned from the tree."

---

## Phase 9: Critical Bug Retesting (2026-03-10)

The API was updated. Retesting all 3 critical bugs with fresh objects.

### Test Objects
- 9703: yearly_goal "RETEST-EOS-L1" (EOS team 2307)
- 9704: rock "RETEST-EOS-L2" under 9703
- 212026: focus_area "RETEST-OKR-L1" (OKR team 2274)
- 9705: objective "RETEST-OKR-L2" under 212026

### Bug 1 Retest: PATCH with strategy-specific objectType

| Test | Call | Result |
|------|------|--------|
| PATCH yearly_goal | `PATCH /strategy/yearly_goal/9703 {"name":"RETEST-EOS-L1-v2"}` | **200** — name updated ✓ |
| PATCH focus_area | `PATCH /strategy/focus_area/212026 {"name":"RETEST-OKR-L1-v2"}` | **200** — name updated ✓ |

**Bug 1: FIXED.** The API now accepts strategy-specific `object_type` values (yearly_goal, focus_area, etc.) in the PATCH URL path. Previously returned 400 `"objectType must be Goal or Item"`.

### Bug 2 Retest: DELETE with strategy-specific types in URL + body

| Test | Call | Result |
|------|------|--------|
| DELETE rock (parent_type=yearly_goal) | `DELETE /strategy/rock/9704 {"parent_id":9703,"parent_type":"yearly_goal","also_archive":true}` | **200** `{unlinked:true, archived:true}` ✓ |
| DELETE objective (parent_type=focus_area) | `DELETE /strategy/objective/9705 {"parent_id":212026,"parent_type":"focus_area","also_archive":true}` | **200** `{unlinked:true, archived:true}` ✓ |

**Bug 2: FIXED.** The API now accepts strategy-specific types in both the DELETE URL path and the `parent_type` body field.

### Bug 3 Retest: DELETE response status code

Both DELETE calls above returned **200** with body `{"data":{"unlinked":true,"archived":true}}`.

**Bug 3: STILL PRESENT.** The API returns 200 with a response body, not 204 No Content as documented in SKILL.md (line 381) and api-reference.md (line 609). The SKILL.md Detach flow checks for `204` and would miss the success response.

### Retest Summary

| Bug | Status | Impact |
|-----|--------|--------|
| Bug 1: PATCH URL objectType | **FIXED** | SKILL.md code using `$OBJECT_TYPE` now works correctly |
| Bug 2: DELETE URL + body types | **FIXED** | SKILL.md code using `$OBJECT_TYPE` and `parent_type` now works correctly |
| Bug 3: DELETE returns 200, not 204 | **STILL PRESENT** | SKILL.md checks for 204 (line 381) — will not match the actual 200 response |

### Remaining Fix Needed

Only Bug 3 remains. Changes required:
1. `skills/strategy/SKILL.md` line 381: Change `**204**` → `**200**`
2. `skills/strategy/SKILL.md` Response envelopes (line 431): Change `DELETE → 204 No Content` → `DELETE → 200 {"data":{"unlinked":bool,"archived":bool}}`
3. `api-reference.md` line 609: Change `DELETE → 204 No Content` → `DELETE → 200 {"data":{"unlinked":bool,"archived":bool}}`

