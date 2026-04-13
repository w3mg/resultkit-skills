---
model: claude-opus-4-6
description: Perform a cross-artifact consistency and quality analysis across spec.md, plan.md, and tasks.md after task generation, then automatically fix all issues found. Questions needed to resolve ambiguous fixes are asked in a single batch at the end before writing any files.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Goal

Identify inconsistencies, duplications, ambiguities, and underspecified items across the three core artifacts (`spec.md`, `plan.md`, `tasks.md`) before implementation, then **automatically fix all issues found**. This command MUST run only after `/speckit.tasks` has successfully produced a complete `tasks.md`.

## Operating Constraints

**ANALYZE THEN FIX**: Produce the analysis report, then apply fixes to the artifact files. Do not ask for approval to run — fixes are applied automatically. Questions are only asked when a fix genuinely requires a user decision that cannot be inferred from existing artifacts; all such questions are batched into a single interactive step at the end of analysis, before any files are written.

**Constitution Authority**: The project constitution (`.specify/memory/constitution.md`) is **non-negotiable** within this analysis scope. Constitution conflicts are automatically CRITICAL and require adjustment of the spec, plan, or tasks—not dilution, reinterpretation, or silent ignoring of the principle. If a principle itself needs to change, that must occur in a separate, explicit constitution update outside `/speckit.analyze`.

## Execution Steps

### 1. Initialize Analysis Context

Run `.specify/scripts/bash/check-prerequisites.sh --json --require-tasks --include-tasks` once from repo root and parse JSON for FEATURE_DIR and AVAILABLE_DOCS. Derive absolute paths:

- SPEC = FEATURE_DIR/spec.md
- PLAN = FEATURE_DIR/plan.md
- TASKS = FEATURE_DIR/tasks.md

Abort with an error message if any required file is missing (instruct the user to run missing prerequisite command).
For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

### 2. Load Artifacts (Progressive Disclosure)

Load only the minimal necessary context from each artifact:

**From spec.md:**

- Overview/Context
- Functional Requirements
- Non-Functional Requirements
- User Stories
- Edge Cases (if present)

**From plan.md:**

- Architecture/stack choices
- Data Model references
- Phases
- Technical constraints

**From tasks.md:**

- Task IDs
- Descriptions
- Phase grouping
- Parallel markers [P]
- Referenced file paths

**From constitution:**

- Load `.specify/memory/constitution.md` for principle validation

### 3. Build Semantic Models

Create internal representations (do not include raw artifacts in output):

- **Requirements inventory**: Each functional + non-functional requirement with a stable key (derive slug based on imperative phrase; e.g., "User can upload file" → `user-can-upload-file`)
- **User story/action inventory**: Discrete user actions with acceptance criteria
- **Task coverage mapping**: Map each task to one or more requirements or stories (inference by keyword / explicit reference patterns like IDs or key phrases)
- **Constitution rule set**: Extract principle names and MUST/SHOULD normative statements

### 4. Detection Passes (Token-Efficient Analysis)

Focus on high-signal findings. Limit to 50 findings total; aggregate remainder in overflow summary.

#### A. Duplication Detection

- Identify near-duplicate requirements
- Mark lower-quality phrasing for consolidation

#### B. Ambiguity Detection

- Flag vague adjectives (fast, scalable, secure, intuitive, robust) lacking measurable criteria
- Flag unresolved placeholders (TODO, TKTK, ???, `<placeholder>`, etc.)

#### C. Underspecification

- Requirements with verbs but missing object or measurable outcome
- User stories missing acceptance criteria alignment
- Tasks referencing files or components not defined in spec/plan

#### D. Constitution Alignment

- Any requirement or plan element conflicting with a MUST principle
- Missing mandated sections or quality gates from constitution

#### E. Coverage Gaps

- Requirements with zero associated tasks
- Tasks with no mapped requirement/story
- Non-functional requirements not reflected in tasks (e.g., performance, security)

#### F. Inconsistency

- Terminology drift (same concept named differently across files)
- Data entities referenced in plan but absent in spec (or vice versa)
- Task ordering contradictions (e.g., integration tasks before foundational setup tasks without dependency note)
- Conflicting requirements (e.g., one requires Next.js while other specifies Vue)

### 5. Severity Assignment

Use this heuristic to prioritize findings:

- **CRITICAL**: Violates constitution MUST, missing core spec artifact, or requirement with zero coverage that blocks baseline functionality
- **HIGH**: Duplicate or conflicting requirement, ambiguous security/performance attribute, untestable acceptance criterion
- **MEDIUM**: Terminology drift, missing non-functional task coverage, underspecified edge case
- **LOW**: Style/wording improvements, minor redundancy not affecting execution order

### 6. Produce Compact Analysis Report

Output a Markdown report (no file writes) with the following structure:

## Specification Analysis Report

| ID | Category | Severity | Location(s) | Summary | Recommendation |
|----|----------|----------|-------------|---------|----------------|
| A1 | Duplication | HIGH | spec.md:L120-134 | Two similar requirements ... | Merge phrasing; keep clearer version |

(Add one row per finding; generate stable IDs prefixed by category initial.)

**Coverage Summary Table:**

| Requirement Key | Has Task? | Task IDs | Notes |
|-----------------|-----------|----------|-------|

**Constitution Alignment Issues:** (if any)

**Unmapped Tasks:** (if any)

**Metrics:**

- Total Requirements
- Total Tasks
- Coverage % (requirements with >=1 task)
- Ambiguity Count
- Duplication Count
- Critical Issues Count

### 7. Categorize Findings for Remediation

For each finding from Step 4, assign a remediation class:

- **AUTO-FIX**: The correct edit is unambiguous given existing artifacts and the constitution. Apply directly without asking the user.
  - Adding a terminology note to spec.md codifying a naming convention already used in plan/tasks
  - Adding a missing task for an uncovered requirement when the correct implementation path is clear from other tasks
  - Clarifying a vague task description using specifics already present in plan.md or spec.md
  - Adding a "not in scope" note for an out-of-scope assumption in the spec
  - Adding a display format detail to a task description derived from the spec's acceptance criteria

- **DECISION-REQUIRED**: The correct fix requires a user preference or judgment that cannot be inferred from existing artifacts.
  - Choosing between two valid architectural approaches (e.g., client-side vs. API-param filtering)
  - Deciding whether an edge case is in or out of scope when the spec is silent
  - Resolving a conflicting requirement where both phrasings have merit
  - Determining how a success criterion should be measured or tested

### 8. Batch All Decision Questions (Final Interactive Step)

**Before writing any files**, collect every DECISION-REQUIRED finding and ask all questions in a single `AskUserQuestion` call (up to 4 questions per call; chain if more than 4).

- Do NOT ask yes/no approval questions — ask specific choice questions that directly unblock the fix
- Do NOT ask about auto-fixable issues — only ask for genuine decisions
- If there are zero DECISION-REQUIRED findings, skip this step entirely and proceed directly to Step 9

### 9. Apply All Fixes

After receiving answers (or immediately if no decisions are needed), apply all fixes using the Edit tool:

- Apply every AUTO-FIX directly against the affected artifact (spec.md, plan.md, or tasks.md)
- Apply DECISION-REQUIRED fixes based on the user's answers
- Prefer targeted Edit calls over full file rewrites — change only the affected sections
- For each file modified, output a brief summary: which findings were addressed and what changed

End with a final status line: `Applied N fixes across X files. N issues remain (severity list).`

If zero issues were found, emit: `No issues found. All artifacts are consistent.`

### 10. Auto-advance to Implementation

After the fix summary, immediately run `/speckit:implement` — do not ask the user first.

- If unfixed CRITICAL issues remain: warn the user before invoking `/speckit:implement`, but still invoke it
- Note any deferred findings explicitly so `/speckit:implement` has full context

## Operating Principles

### Context Efficiency

- **Minimal high-signal tokens**: Focus on actionable findings, not exhaustive documentation
- **Progressive disclosure**: Load artifacts incrementally; don't dump all content into analysis
- **Token-efficient output**: Limit findings table to 50 rows; summarize overflow
- **Deterministic results**: Rerunning without changes should produce consistent IDs and counts

### Analysis Guidelines

- **Apply fixes with targeted edits** — use the Edit tool on specific sections, not full rewrites
- **NEVER hallucinate missing sections** (if absent, report them accurately)
- **Prioritize constitution violations** (these are always CRITICAL)
- **Use examples over exhaustive rules** (cite specific instances, not generic patterns)
- **Report zero issues gracefully** (emit success report with coverage statistics)
- **Batch questions** — never ask about one issue at a time; collect all decision points first, then ask once

## Context

$ARGUMENTS
