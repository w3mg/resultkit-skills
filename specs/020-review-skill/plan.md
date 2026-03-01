# Implementation Plan: Review Skill

**Branch**: `020-review-skill` | **Date**: 2026-03-01 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/020-review-skill/spec.md`

## Summary

New `rkit:reviews` skill for viewing, assessing, and managing performance reviews via the ResultMaps V2 API. Covers the full review lifecycle (create → assess → sign-off → archive/void) plus standalone core values ratings. Follows the established SKILL.md + api.sh pattern used by all other rkit skills.

## Technical Context

**Language/Version**: Bash 5.x (api.sh), Markdown (SKILL.md — Claude Code skill runtime)
**Primary Dependencies**: curl, jq, `scripts/api.sh` (shared API caller)
**Storage**: N/A (all data via ResultMaps V2 API)
**Testing**: Manual verification via API calls
**Target Platform**: Claude Code agent runtime (CLI)
**Project Type**: Single (Claude Code skill)
**Performance Goals**: N/A (CLI skill, API-bound)
**Constraints**: Must work from any directory, single config file dependency
**Scale/Scope**: 1 SKILL.md file, 1 api.sh script copy, 1 api-reference.md copy

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| # | Principle | Status | Notes |
|---|-----------|--------|-------|
| I | Claude Code Skill Format | PASS | SKILL.md entry point, api.sh as supporting script |
| II | Self-Contained | PASS | Only depends on ~/.config/resultkit/config.json |
| III | Config-Driven | PASS | Token and defaults from config, nothing hardcoded |
| IV | Confirm Writes | PASS | FR-010 requires confirmation for all POST/PUT/PATCH/DELETE |
| V | Show IDs | PASS | FR-001 requires IDs in all tables and output |
| VI | Framework-Aware | N/A | Reviews don't use framework terminology |
| VII | Direct Execution | PASS | Uses Bash + api.sh directly, no subagents |
| VIII | Graceful Degradation | PASS | FR-009 handles all standard error responses |
| IX | Concise Output | PASS | Tables and short summaries per spec |

All gates pass. No violations to justify.

## Project Structure

### Documentation (this feature)

```text
specs/020-review-skill/
├── spec.md
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── quickstart.md        # Phase 1 output
├── contracts/           # Phase 1 output
│   └── reviews-api.md
├── checklists/
│   └── requirements.md
└── tasks.md             # Phase 2 output (/speckit.tasks)
```

### Source Code (repository root)

```text
skills/reviews/
├── SKILL.md              # Skill entry point (rkit:reviews)
├── scripts/
│   └── api.sh            # Shared API caller (copied from root)
└── references/
    └── api-reference.md  # API reference (copied from root)
```

**Structure Decision**: Standard single-skill layout matching all existing rkit skills. One SKILL.md with all flows defined declaratively. No custom scripts beyond the shared api.sh.

## Key Design Decisions

### Assessment Flow UX

The `assess` and `draft` commands walk the user through template prompts one at a time using AskUserQuestion. Each prompt's `answer_type` determines the input method:

| Answer Type | Input Method |
|-------------|-------------|
| `range` | AskUserQuestion with numeric options derived from `answer_meta_data` |
| `text` | AskUserQuestion with free-form short answer |
| `textarea` | AskUserQuestion with free-form short answer (same UX in CLI) |
| `boolean` | AskUserQuestion with Yes/No options |
| `multiple` | AskUserQuestion with options from `answer_meta_data` |

After all prompts are answered, the skill shows a summary and asks for confirmation before submitting (or saving draft).

### Assessment Visibility

Server-side enforced. The skill renders whatever the API returns in the `self_assessment` and `reviewer_assessment` fields. No client-side filtering needed — the API omits reviewer assessments for reviewees until `signed_off` status.

### Team ID Usage

Team ID is only needed for the `create` flow (looking up users for reviewee/reviewer selection). Reviews, templates, and core values are organization-scoped, not team-scoped. The standard 3-tier resolution applies when team context is needed.

### Scope Boundaries

**In scope**: View reviews, assess, draft, sign-off, create, void, archive, view core values, rate core values.

**Out of scope for initial skill** (can be added later):
- Review template CRUD (admin manages templates via API/web UI)
- Action item creation within reviews
- Attachment upload (marked Beta in API)
- Review notes editing
