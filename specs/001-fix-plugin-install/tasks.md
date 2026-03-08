# Tasks: Fix Plugin Install Failure

**Input**: Design documents from `/specs/001-fix-plugin-install/`
**Prerequisites**: plan.md ✅ spec.md ✅ research.md ✅

**Organization**: 2 user stories. The fix is a single config change. Tasks reflect the true minimal scope.

## Format: `[ID] [P?] [Story] Description`

---

## Phase 1: Setup

**Purpose**: No project initialization needed — this is a config file change in an existing repo.

- [x] T001 Read `.claude-plugin/marketplace.json` to confirm current broken state matches research findings

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Understand the fix before applying it.

- [x] T002 Verify `.claude-plugin/marketplace.json` `plugins[0].source` uses `{ "source": "github", "repo": "..." }` (the broken format)
- [x] T003 Confirm no other files reference the `"source": "github"` format that also need updating

**Checkpoint**: Root cause confirmed, scope bounded — proceed to user story implementation

---

## Phase 3: User Story 1 - Fresh Plugin Install Succeeds (Priority: P1) 🎯 MVP

**Goal**: The `/plugin install rkit@resultkit` command completes successfully, placing files in `~/.claude/plugins/cache/resultkit/rkit/<version>/` and registering the install in `installed_plugins.json`.

**Independent Test**: On a clean environment, run `/plugin marketplace add w3mg/resultkit-skills` then `/plugin install rkit@resultkit` — install must succeed without errors and `rkit:*` skills must be available.

### Implementation for User Story 1

- [x] T004 [US1] Update `plugins[0].source` in `.claude-plugin/marketplace.json` from `{ "source": "github", "repo": "w3mg/resultkit-skills" }` to `{ "source": "url", "url": "https://github.com/w3mg/resultkit-skills.git" }`
- [x] T005 [US1] Add `"$schema": "https://anthropic.com/claude-code/marketplace.schema.json"` to the top level of `.claude-plugin/marketplace.json` to match the official marketplace format
- [x] T006 [US1] Bump version in `.claude-plugin/plugin.json` (patch bump) to ensure users see an update and the fix propagates
- [ ] T007 [US1] Commit and push the fix to `main` so the updated `marketplace.json` is live on GitHub (required for the install system to fetch the corrected config)

**Checkpoint**: Fix is live. The install system will now use the `url` format source and correctly fetch/cache the plugin.

---

## Phase 4: User Story 2 - Plugin Update Works After Initial Install (Priority: P2)

**Goal**: Existing users who applied the manual workaround can run `/plugin marketplace update` to get a working official install at the new version.

**Independent Test**: Have an existing manual-workaround install at 1.2.37. Run `/plugin marketplace update`. Verify the installed version updates and `rkit:*` skills still work.

### Implementation for User Story 2

- [ ] T008 [US2] Update the workaround documentation in the GitHub issue (#24) — add a comment confirming the fix is live, explain that users should run `/plugin marketplace update` to migrate from manual workaround to official install, and confirm whether reinstall is needed
- [ ] T009 [US2] Close GitHub issue #24 once the fix is confirmed working

**Checkpoint**: Both user stories complete. All users can install and update via official commands.

---

## Phase 5: Polish & Cross-Cutting Concerns

- [ ] T010 [P] Verify the fix by testing `/plugin install rkit@resultkit` on a local clean environment (remove `~/.claude/plugins/cache/resultkit/` first if it exists, then reinstall)
- [ ] T011 [P] Update `CLAUDE.md` or project docs if any installation instructions need updating to reflect the fix
- [ ] T012 Instruct users to run `/plugin marketplace update` (print update instructions)

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **Foundational (Phase 2)**: Depends on Phase 1
- **User Story 1 (Phase 3)**: Depends on Phase 2 — this is the blocker fix
- **User Story 2 (Phase 4)**: Depends on Phase 3 being live (T007 pushed)
- **Polish (Phase 5)**: Depends on all stories being complete

### User Story Dependencies

- **User Story 1 (P1)**: Independent — no dependency on US2
- **User Story 2 (P2)**: Depends on US1 fix being pushed to GitHub (T007)

### Within Each User Story

- T004 and T005 are independent of each other [P] — both edit `marketplace.json` but different fields (check before running in parallel)
- T006 follows T004/T005 (version bump signals the change)
- T007 (push) must follow T004, T005, T006

---

## Parallel Example: User Story 1

```bash
# T004 and T005 edit the same file — run sequentially:
Task: T004 — update source format in marketplace.json
Task: T005 — add $schema to marketplace.json

# T006 follows:
Task: T006 — bump version in plugin.json

# T007 follows:
Task: T007 — commit and push
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Complete Phase 1 + Phase 2: Read and confirm the broken state (T001–T003)
2. Complete Phase 3: Apply the one-line fix, bump version, push (T004–T007)
3. **STOP and VALIDATE**: Test install on clean environment
4. Proceed to Phase 4 once confirmed working

### Total Task Count

| Phase | Tasks | Story |
|-------|-------|-------|
| Setup | 1 | — |
| Foundational | 2 | — |
| US1 (P1) | 4 | US1 |
| US2 (P2) | 2 | US2 |
| Polish | 3 | — |
| **Total** | **12** | |

---

## Notes

- This is a configuration-only change. No skill files, no scripts, no API changes.
- The entire fix is 1 JSON field + 1 JSON field addition in `.claude-plugin/marketplace.json`
- The version bump in `plugin.json` is required so the update propagates to existing users
- T007 (pushing to GitHub) is critical — the install system fetches `marketplace.json` live from GitHub
