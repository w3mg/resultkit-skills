# Implementation Plan: Fix Measure History Display in Scorecard

**Branch**: `001-fix-measure-history` | **Date**: 2026-03-07 | **Spec**: [spec.md](spec.md)
**Input**: Feature specification from `/specs/001-fix-measure-history/spec.md`

## Summary

The ResultMaps V2 API bug that caused weekly scorecard history values to always be null has been fixed server-side. The `rkit:scorecard` skill's display logic already handles non-null values correctly (jq `.value // "—"` expression). The one real gap: the record success message does not show the `id` returned by the API — required by Constitution §V (Show IDs). This plan updates that message and verifies the display path end-to-end.

## Technical Context

**Language/Version**: Bash 5.x
**Primary Dependencies**: jq, curl, `scripts/api.sh` (shared API caller)
**Storage**: N/A — all data via ResultMaps V2 API
**Testing**: Manual via live API call
**Target Platform**: Claude Code skill runtime (Linux/macOS)
**Project Type**: Single skill (SKILL.md modification)
**Performance Goals**: N/A
**Constraints**: Must not break existing display, record, add, update, or archive flows
**Scale/Scope**: One file change — `skills/scorecard/SKILL.md` (record success message, Step 7)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

| Principle | Status | Notes |
|-----------|--------|-------|
| I. Claude Code Skill Format | PASS | Change is within SKILL.md only |
| II. Self-Contained | PASS | No new external dependencies |
| III. Config-Driven | PASS | No config changes |
| IV. Confirm Writes | PASS | Record flow already confirms before POST |
| V. Show IDs | **FIX REQUIRED** | Record success message does not currently show the returned history `id` |
| VI. Framework-Aware | PASS | No change to terminology logic |
| VII. Direct Execution | PASS | api.sh used throughout |
| VIII. Graceful Degradation | PASS | Error handling unchanged |
| IX. Concise Output | PASS | One-line success message with ID added |

**Violation**: V. Show IDs — record success message must include the history entry ID from the API response.

## Project Structure

### Documentation (this feature)

```text
specs/001-fix-measure-history/
├── plan.md              # This file
├── research.md          # Phase 0 output
├── data-model.md        # Phase 1 output
├── contracts/           # Phase 1 output (no new endpoints)
└── tasks.md             # Phase 2 output (/speckit:tasks — not created here)
```

### Source Code (repository root)

```text
skills/scorecard/
└── SKILL.md             # Only file changed — record flow Step 7 success message
```

## Complexity Tracking

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| V. Show IDs (record message) | Record success must show history entry ID per constitution | Current message omits it — trivial one-line fix, no alternative needed |
