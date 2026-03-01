# Tasks: Collapse Redundant Confirmations

**Input**: Design documents from `/specs/018-collapse-confirmations/`
**Prerequisites**: plan.md (required), spec.md (required), research.md, quickstart.md

**Tests**: Not requested — no test tasks generated.

**Organization**: Tasks grouped by user story to enable independent implementation.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2)
- Include exact file paths in descriptions

---

## Phase 1: Setup

**Purpose**: Amend the constitution to authorize the new confirmation pattern before modifying skills.

- [x] T001 Amend Principle IV in .specify/memory/constitution.md to add batch confirmation and scoped `allowed-tools` language per plan.md Constitution Amendment section; bump constitution version from 1.1.0 to 1.1.1 (PATCH — clarification); verify plan-template, spec-template, and tasks-template remain compatible

---

## Phase 2: User Story 1 — Frictionless Sequential Workflows (Priority: P1) 🎯 MVP

**Goal**: Reduce confirmation friction by scoping `allowed-tools` frontmatter and collapsing sequential prompts.

**Independent Test**: Run any multi-step skill (e.g., `/rkit:today add "Test item"`) and verify: (1) no system-level permission prompts for Bash/Read/Glob/Grep, (2) mutating actions show exactly one confirmation, (3) declining aborts the full sequence.

### Frontmatter Updates

- [x] T002 [P] [US1] Update frontmatter for Category B skills (API, no date): replace `allowed-tools: Bash, Read, AskUserQuestion` with `allowed-tools: Bash(scripts/api.sh *), Bash(jq *), Read, Glob, Grep, AskUserQuestion` in skills/1on1/SKILL.md, skills/board/SKILL.md, skills/headlines/SKILL.md, skills/projects/SKILL.md, skills/level10/SKILL.md, skills/result-feed/SKILL.md, skills/teams/SKILL.md, skills/weekly/SKILL.md
- [x] T003 [P] [US1] Update frontmatter for Category A skills (API + date): replace `allowed-tools: Bash, Read, AskUserQuestion` with `allowed-tools: Bash(scripts/api.sh *), Bash(jq *), Bash(date *), Read, Glob, Grep, AskUserQuestion` in skills/braindump/SKILL.md, skills/result-update/SKILL.md, skills/today/SKILL.md
- [x] T004 [P] [US1] Update frontmatter for setup skill: replace `allowed-tools: Bash, Read, Write` with `allowed-tools: Bash(curl *), Bash(jq *), Bash(mkdir -p *), Read, Glob, Grep, Write, AskUserQuestion` in skills/setup/SKILL.md
- [x] T005 [P] [US1] Update frontmatter for concepts skill: add `allowed-tools: Read, Glob, Grep` to skills/concepts/SKILL.md

### Instruction Changes

- [x] T006 [US1] Collapse rkit:board Remove flow in skills/board/SKILL.md: merge the 2 sequential confirmations (remove from projects + add to day plan) into a single combined confirmation prompt per plan.md Instruction Changes section
- [x] T007 [US1] Standardize confirmation wording in all write-capable skills: ensure each skill's confirm-writes rule says "summarize all planned changes in a single prompt; batch related mutations under one confirmation" — update instruction text in skills/1on1/SKILL.md, skills/board/SKILL.md, skills/braindump/SKILL.md, skills/headlines/SKILL.md, skills/projects/SKILL.md, skills/level10/SKILL.md, skills/result-update/SKILL.md, skills/weekly/SKILL.md, skills/today/SKILL.md, skills/setup/SKILL.md

**Checkpoint**: All skills have scoped frontmatter and standardized confirmation patterns. US1 is independently testable.

---

## Phase 3: User Story 2 — Distinct Actions Still Require Separate Confirmation (Priority: P2)

**Goal**: Verify that genuinely distinct decision points (different intents, branching choices) retain separate confirmation prompts.

**Independent Test**: Run a skill with distinct decisions (e.g., `/rkit:board` with a remove that offers multiple options) and verify each distinct choice still prompts independently.

- [x] T008 [US2] Audit all write-capable skills — PASS: all 10 skills verified, distinct decision points preserved to verify distinct decision points are preserved — review each skill's AskUserQuestion calls and confirm that separate-intent prompts were NOT collapsed; document findings as comments in this task. Skills to audit: skills/1on1/SKILL.md, skills/board/SKILL.md, skills/braindump/SKILL.md, skills/headlines/SKILL.md, skills/projects/SKILL.md, skills/level10/SKILL.md, skills/result-update/SKILL.md, skills/weekly/SKILL.md, skills/today/SKILL.md, skills/setup/SKILL.md

**Checkpoint**: All distinct decision points verified intact. No regressions in user control.

---

## Phase 4: Polish & Cross-Cutting Concerns

**Purpose**: Version bump and final sync.

- [x] T009 Bump patch version in .claude-plugin/plugin.json and gemini-extension.json
- [x] T010 Update spec status from Draft to Complete in specs/018-collapse-confirmations/spec.md

---

## Dependencies & Execution Order

### Phase Dependencies

- **Setup (Phase 1)**: No dependencies — start immediately
- **US1 (Phase 2)**: Depends on T001 (constitution amendment must be in place before modifying skills)
- **US2 (Phase 3)**: Depends on Phase 2 completion (audit happens after changes are made)
- **Polish (Phase 4)**: Depends on all prior phases

### User Story Dependencies

- **US1 (P1)**: Depends on Setup only. Can be implemented immediately after T001.
- **US2 (P2)**: Depends on US1 completion. Audit verifies US1 changes didn't break distinct confirmations.

### Within US1

- T002, T003, T004, T005 are all [P] — update different files, can run in parallel
- T006 depends on T002 (board frontmatter should be updated first)
- T007 depends on T002–T005 (standardize wording after all frontmatter is updated)

### Parallel Opportunities

```
# All frontmatter updates can run in parallel:
T002 (8 Category B skills)  ─┐
T003 (3 Category A skills)  ─┤── all [P], different files
T004 (setup)                ─┤
T005 (concepts)             ─┘
                              │
T006 (board collapse)       ──┘ after T002
T007 (standardize wording)  ──  after T002–T005
```

---

## Implementation Strategy

### MVP First (US1 Only)

1. Complete Phase 1: Constitution amendment (T001)
2. Complete Phase 2: All frontmatter + instruction changes (T002–T007)
3. **STOP and VALIDATE**: Test several skills to verify friction reduction
4. Commit and push if ready — users get immediate benefit

### Incremental Delivery

1. T001 → Constitution updated
2. T002–T005 → All frontmatter scoped (biggest security + UX win)
3. T006–T007 → Instruction-level refinements
4. T008 → Verification pass
5. T009–T010 → Ship it

---

## Notes

- All frontmatter patterns come from quickstart.md — copy-paste the correct line per category
- The board Remove flow (T006) is the only confirmed sequential redundancy found in the audit
- T007 is a wording standardization pass, not a logic change — most skills already confirm once per action
- No shared files (api.sh, api-reference.md) are modified, so /sync-plugin is not needed
