# Quickstart: Password Reset Skill

**Branch**: `021-password-reset` | **Date**: 2026-03-01

## Verification Scenarios

### US1: Admin Triggers Password Reset

**Scenario 1**: Successful reset
```
User (admin): /rkit:password-reset 42
Expected: Confirm prompt → "Send password reset email to user #42?" → Yes → "Password reset email sent to user #42."
```

**Scenario 2**: No user ID
```
User: /rkit:password-reset
Expected: "Usage: `/rkit:password-reset {user_id}`"
```

**Scenario 3**: Non-admin
```
User (non-admin): /rkit:password-reset 42
Expected: 403 → "Admin access required."
```

**Scenario 4**: Invalid user
```
User (admin): /rkit:password-reset 99999
Expected: 422 → Show validation error (user not found / not in account)
```

**Scenario 5**: User has no email
```
User (admin): /rkit:password-reset 42 (user has no email)
Expected: 422 → Show validation error (user has no email)
```

### US2: API Reference

**Scenario 6**: Documentation check
```
Read api-reference.md → Verify "Passwords" section exists with both endpoints:
- POST /passwords/reset (admin auth, body: user_id)
- PUT /passwords (unauthenticated, body: token + password)
```
