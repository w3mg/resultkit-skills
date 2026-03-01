# Quickstart: Teams Envelope Fix & Error Handling Update

**Branch**: `022-teams-envelope-fix` | **Date**: 2026-03-01

## Verification Scenarios

### US1: Teams Skill Handles Data Envelope

**Scenario 1**: List teams
```
User: /rkit:teams
Expected: Teams displayed in table grouped by organization with ID, Name, Framework columns. Default team marked.
```

**Scenario 2**: List teams with muted
```
User: /rkit:teams all
Expected: All teams including muted ones displayed. Muted teams marked with (muted).
```

**Scenario 3**: Search teams
```
User: /rkit:teams q "eng"
Expected: Only teams matching "eng" displayed.
```

**Scenario 4**: List members
```
User: /rkit:teams members
Expected: Members of default team displayed (uses GET /teams/{id}/members — already uses data envelope, should work unchanged).
```

### US2: Setup Skill Handles Data Envelope

**Scenario 5**: First-time setup team selection
```
User: /rkit:setup (with valid token, no config)
Expected: After token verification, teams listed in numbered table for selection. Default team pre-selected.
```

**Scenario 6**: Reconfigure default team
```
User: /rkit:setup → Option 2 (with existing config)
Expected: Teams listed with current default marked as (current). User can select new default.
```

### US3: API Reference Updated

**Scenario 7**: Documentation check
```
Read api-reference.md → Verify:
- GET /teams no longer says "bare array" or "flat array"
- Teams section mentions standard data envelope
- Error Responses table includes 500 | internal_error | Internal server error
```

### Error Handling

**Scenario 8**: 500 internal error
```
If API returns 500 with { "error": { "code": "internal_error", "message": "Internal server error" } }
Expected: Skill shows "Internal server error (500)." — covered by existing "Other non-200" handler.
```
