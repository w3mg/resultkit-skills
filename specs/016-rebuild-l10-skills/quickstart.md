# Quickstart: Rebuild Skills with Skill Creator & L10 Route Coverage

## Prerequisites

- ResultKit plugin installed (`/plugin install rkit@resultkit`)
- Config set up (`/rkit:setup`) with an EOS team as default
- `/skill-creator` skill available

## Build Order

### Phase 1: Create rkit:level10 (P1)

1. Sync shared files to the scaffolded `skills/level10/` directory:
   ```
   /sync-plugin
   ```

2. Use Skill Creator to build the level10 skill:
   ```
   /skill-creator create rkit:level10
   ```
   Feed it the interface contract from `specs/016-rebuild-l10-skills/contracts/level10-interface.md` and the constitution from `constitution.md`.

3. Run evals:
   ```
   /skill-creator eval rkit:level10
   ```

4. Test manually against a live EOS team:
   ```
   /rkit:level10
   /rkit:level10 todos
   /rkit:level10 add todo "Test item"
   /rkit:level10 done {item_id}
   ```

### Phase 2: Rebuild Existing Skills (P2)

For each skill (in order from research.md R4):

1. Run Skill Creator on the existing skill:
   ```
   /skill-creator improve rkit:{skill_name}
   ```

2. Run evals to verify quality:
   ```
   /skill-creator eval rkit:{skill_name}
   ```

3. Manual smoke test with known inputs to confirm behavioral equivalence.

### Phase 3: L10 Route Awareness (P3)

For `rkit:weekly` and `rkit:headlines`, the Skill Creator rebuild (Phase 2) should incorporate L10 route awareness for EOS teams. Provide the route mapping from `data-model.md` as context during the rebuild.

## Verification

- All 12 skills pass Skill Creator evals
- `/rkit:level10` handles full workflow on EOS team
- `/rkit:weekly` uses L10 routes when team framework is EOS
- `/rkit:headlines` uses L10 routes when team framework is EOS
- No regressions in any existing skill behavior
