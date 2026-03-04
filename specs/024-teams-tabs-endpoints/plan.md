# Implementation Plan: Teams Tabs API Endpoints

**Branch**: `024-teams-tabs-endpoints` | **Date**: 2026-03-03 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/024-teams-tabs-endpoints/spec.md`

## Summary

New team-scoped endpoints for activity logs, labels, integrations, member role change, and logo upload are added to the API reference. The `rkit:teams` skill is extended with two new flows: change member role (PATCH write, confirmation required) and view activity logs (GET read). Labels, integrations, and logo upload are documented only — no skill flows.

## Technical Context

**Language/Version**: Bash 5.x (api.sh), Markdown (SKILL.md — Claude Code skill runtime)
**Primary Dependencies**: `scripts/api.sh` (shared API caller), curl, jq
**Storage**: N/A (all data via ResultMaps V2 API)
**Testing**: N/A (manual verification via skill invocation)
**Target Platform**: Claude Code CLI + Gemini CLI
**Project Type**: Plugin skill suite (Markdown + Bash)
**Performance Goals**: N/A (fire-and-forget API calls)
**Constraints**: N/A
**Scale/Scope**: 1 api-reference.md update + 1 SKILL.md edit (add 2 flows)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | PASS | Editing existing SKILL.md |
| II. Self-Contained | PASS | No new dependencies |
| III. Config-Driven | PASS | No config changes |
| IV. Confirm Writes | PASS | Role change is PATCH (write) — confirmation required; activity logs is GET — no confirmation |
| V. Show IDs | PASS | User IDs, team IDs, and member IDs shown in all output |
| VI. Framework-Aware | PASS | Role change and activity logs operate on IDs, no framework mapping needed |
| VII. Direct Execution | PASS | Uses api.sh via Bash |
| VIII. Graceful Degradation | PASS | Handles 401, 403, 404, 422 for both new flows |
| IX. Concise Output | PASS | Tables for activity logs and role change result |

**Gate result**: PASS — no violations.

## Project Structure

### Documentation (this feature)

```text
specs/024-teams-tabs-endpoints/
├── plan.md              # This file
├── research.md          # Phase 0: Decisions
├── quickstart.md        # Phase 1: Verification scenarios
├── contracts/           # Phase 1: API contracts
│   └── teams-new-endpoints-api.md  # All new team endpoints
└── tasks.md             # Phase 2 output (/speckit:tasks)
```

### Source Code (repository root)

```text
api-reference.md                # Update: add all 12 new team endpoints + glossary
skills/teams/SKILL.md           # Update: add role-change flow + activity-logs flow
```

**Structure Decision**: No new files created. Two existing files edited in-place. Role change and activity logs are added to the teams skill (already handles list teams, list members). Labels, integrations, and logo upload are reference-only.

## Complexity Tracking

No violations — table not needed.
