# Quickstart: Update Skills to Reflect Latest Endpoints

## What's Changing

Two skills get updates:

1. **`skills/level10/SKILL.md`** — Add parked/done/remove flows + switch all PUT routes to L10-specific
2. **`skills/weekly/SKILL.md`** — Update L10 Route Selection table for done/parked EOS routes

## Implementation Order

### Step 1: Update `rkit:level10` SKILL.md

Modify `skills/level10/SKILL.md`:

1. **View L10 Board flow** — Add `DONE` and `PARKED` fetches alongside existing `TODOS`, `ISSUES`, `HEADLINES`. Update display to show 5 sections in order: To-Dos, Done, Issues, Parked, Headlines.

2. **Argument Parsing table** — Add rows:
   - `done` → View Done Only
   - `parked` → View Parked Only
   - `move {item_id} parked` → Move Item to Parked
   - `remove {item_id}` → Remove from L10 Board

3. **View Single Section flow** — Add `done` and `parked` to the supported sections.

4. **Flow: Move Item** — Add `parked` as a valid target. Update all PUT routes from generic to L10:
   - `todos` → `PUT /teams/{id}/l10/todos/{item_id}`
   - `issues` → `PUT /teams/{id}/l10/issues/{item_id}`
   - `parked` → `PUT /teams/{id}/l10/parked/{item_id}`

5. **Flow: Mark Done** — Change route from `PUT /teams/{id}/items/done/{item_id}` to `PUT /teams/{id}/l10/done/{item_id}`.

6. **New Flow: Remove from L10 Board** — Add flow using `DELETE /teams/{id}/l10/items/{item_id}`.

7. **Edge Cases** — Add entries for parked-related and remove-related edge cases.

### Step 2: Update `rkit:weekly` SKILL.md

Modify `skills/weekly/SKILL.md`:

1. **L10 Route Selection table** — Add EOS routes for done and parked:
   - done: `GET /teams/{id}/l10/done`
   - parked: `GET /teams/{id}/l10/parked`

2. **View Weekly flow (EOS branch)** — Update bash example to use L10 routes for done and parked.

3. **View Single Column flow** — Update the conditional to include done and parked for EOS L10 route selection.

### Step 3: Sync and Test

1. Run `/sync-plugin` to propagate api-reference.md to all skills
2. Test each new flow manually via `/rkit:level10` and `/rkit:weekly`
3. Verify existing flows still work

## Files Touched

| File | Change Type |
|------|-------------|
| `skills/level10/SKILL.md` | Modified (add flows, update routes) |
| `skills/weekly/SKILL.md` | Modified (update route table) |

## Validation

After implementation, verify:
- `/rkit:level10` shows 5 sections (To-Dos, Done, Issues, Parked, Headlines)
- `/rkit:level10 parked` shows only parked items
- `/rkit:level10 done` shows only done items
- `/rkit:level10 move {id} parked` parks an item
- `/rkit:level10 remove {id}` removes from board
- `/rkit:weekly` on EOS team uses L10 routes for all 4 columns
- All existing flows unchanged
