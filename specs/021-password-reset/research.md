# Research: Password Reset Skill

**Branch**: `021-password-reset` | **Date**: 2026-03-01

## Finding 1: Only POST /passwords/reset Needed for Skill

**Decision**: The skill only wraps `POST /api/v2/passwords/reset` (admin-triggered reset). The `PUT /api/v2/passwords` endpoint (complete reset with token) is documented in api-reference.md but excluded from the skill.

**Rationale**: The PUT endpoint is unauthenticated — it uses a reset token from an email link. Users complete this flow in their browser, not from a CLI. No practical CLI use case exists.

**Alternatives considered**:
- Include both endpoints in skill — rejected, PUT flow is browser-based and requires a token from email.

## Finding 2: No New Patterns Needed

**Decision**: The skill follows the exact same pattern as all other rkit skills (SKILL.md + api.sh).

**Rationale**: This is the simplest possible skill — one command, one API call, one confirmation. No template prompts, no state management, no pagination, no team context. The existing api.sh handles auth and error responses.
