# Feature Specification: Collapse Redundant Confirmations

**Feature Branch**: `018-collapse-confirmations`
**Created**: 2026-03-01
**Status**: Complete
**Input**: GitHub Issue #3: Eliminate redundant confirmations in skills

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Frictionless Sequential Workflows (Priority: P1)

A user runs a skill that involves multiple sequential steps (e.g., selecting a team, then writing config). Today, the skill asks for confirmation at each step separately, even when the user's initial "yes" clearly covers the entire intent. After this change, the skill presents one confirmation that covers all sequential steps, and then proceeds without further interruption.

**Why this priority**: This is the core problem — redundant confirmations slow users down and create unnecessary friction in every skill interaction.

**Independent Test**: Can be tested by running any multi-step skill (e.g., `/rkit:setup`) and verifying that sequential steps are covered by a single confirmation.

**Acceptance Scenarios**:

1. **Given** a skill with two or more sequential confirmation points that serve the same intent, **When** the user confirms the first prompt, **Then** the remaining sequential steps execute without additional confirmation prompts.
2. **Given** a skill with a confirmation that summarizes all upcoming sequential actions, **When** the user declines, **Then** the entire sequence is aborted — no partial execution occurs.

---

### User Story 2 - Distinct Actions Still Require Separate Confirmation (Priority: P2)

A user runs a skill that involves genuinely distinct decisions (e.g., choosing which team to operate on, then choosing whether to overwrite existing data). These are not sequential steps toward the same goal — they represent separate choices. After this change, these distinct decision points still receive separate confirmations.

**Why this priority**: Collapsing confirmations must not eliminate necessary decision points. Users must retain control over genuinely separate choices.

**Independent Test**: Can be tested by running a skill with distinct decision branches and verifying each branch still prompts independently.

**Acceptance Scenarios**:

1. **Given** a skill with two confirmation points that represent different decisions (e.g., "which team?" vs. "overwrite existing config?"), **When** the user reaches each decision point, **Then** each is presented as a separate confirmation.
2. **Given** a skill where the user confirms one decision, **When** the next prompt represents a genuinely different choice, **Then** the previous confirmation does not automatically cover it.

---

### Edge Cases

- What happens when a skill has only one confirmation point? No change needed — it already behaves correctly.
- What happens when sequential steps have a conditional branch mid-sequence (e.g., step 2 might fail and require a different path)? The confirmation should cover the happy path; if the flow diverges due to an error, the skill should inform the user and handle it gracefully without re-prompting for the original intent.
- What happens when a user runs a skill with `--yes` or similar auto-confirm behavior? The collapsed confirmation pattern should be compatible — auto-confirm still covers the full sequence.

## Requirements *(mandatory)*

### Functional Requirements

- **FR-001**: Each skill MUST present no more than one confirmation prompt per sequential action chain (a series of steps that serve a single user intent).
- **FR-002**: A single confirmation MUST clearly summarize all actions that will be taken in the sequence before the user confirms.
- **FR-003**: If the user declines a combined confirmation, the entire sequence MUST be aborted with no partial side effects.
- **FR-004**: Genuinely distinct decisions (different intents, branching choices) MUST retain separate confirmation prompts.
- **FR-005**: All `rkit:*` skills MUST be audited and updated to follow the collapsed confirmation pattern.
- **FR-006**: Skills MUST NOT introduce new confirmation prompts for steps that are clearly continuations of an already-confirmed intent.
- **FR-007**: Each skill's `allowed-tools` frontmatter MUST include all tools the skill routinely uses for non-destructive operations, eliminating system-level permission prompts for those tools.
- **FR-008**: Skills MUST consolidate sequential `AskUserQuestion` calls that serve a single intent into one combined confirmation prompt.
- **FR-009**: Each skill MUST replace blanket `Bash` permission with scoped `Bash(command *)` patterns that explicitly enumerate only the commands the skill needs (e.g., `Bash(scripts/api.sh *)`, `Bash(jq *)`, `Bash(date *)`, `Bash(mkdir -p *)`).
- **FR-010**: The scoped Bash pattern list for each skill MUST be determined by auditing actual command usage within that skill's instructions and scripts.
- **FR-011**: All skills MUST include `Glob` and `Grep` in `allowed-tools` to permit non-destructive file discovery without permission prompts.
- **FR-012**: Skills MUST retain exactly one confirmation prompt before executing any batch of mutating API calls (POST/PUT/PATCH/DELETE), summarizing all planned changes in a single prompt.

## Success Criteria *(mandatory)*

### Measurable Outcomes

- **SC-001**: The total number of confirmation prompts across all `rkit:*` skills is reduced by at least 30% compared to current state.
- **SC-002**: No skill presents more than one confirmation prompt for a single sequential workflow (e.g., "select team then write config" = one confirmation, not two).
- **SC-003**: Users can complete any single-intent skill workflow with exactly one confirmation interaction.
- **SC-004**: All genuinely distinct decision points retain their separate prompts — zero regressions in user control over branching choices.

## Clarifications

### Session 2026-03-01

- Q: Should this be solved via frontmatter `allowed-tools` expansion, skill instruction changes, or both? → A: Both — expand frontmatter `allowed-tools` to cover missing read-only tools AND collapse sequential `AskUserQuestion` calls in SKILL.md instructions.
- Q: Should Bash permissions remain blanket or be scoped to specific command patterns? → A: Scoped — replace blanket `Bash` with explicit patterns like `Bash(scripts/api.sh *)`, `Bash(jq *)`, `Bash(cat *)`, `Bash(date *)`, etc. Be good security actors.
- Q: Should Glob and Grep be added to all skills' allowed-tools? → A: Yes — add both read-only tools to all skills to eliminate unnecessary permission prompts for file discovery.
- Q: Should mutating API calls still require explicit user confirmation? → A: Yes — keep one confirmation before any mutating API call batch. Summarize all planned changes and ask once. No per-call prompts.

## Assumptions

- "Sequential" means steps that serve a single user intent and would naturally follow from a single "yes" (e.g., pick team → write config).
- "Distinct" means steps that represent different decisions a user needs to make independently (e.g., which team vs. whether to overwrite).
- Two distinct confirmation mechanisms exist: (1) Claude Code system-level permission prompts controlled by `allowed-tools` frontmatter, and (2) skill-instructed confirmations via `AskUserQuestion` calls in SKILL.md.
- Both mechanisms will be addressed: frontmatter gaps for read-only tools, and redundant AskUserQuestion patterns in skill instructions.

## Dependencies

- Requires access to all `rkit:*` skill SKILL.md files for auditing.
- No external dependencies — this is an internal documentation/instruction change.
