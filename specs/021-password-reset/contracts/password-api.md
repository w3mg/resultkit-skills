# API Contracts: Password Reset Skill

**Branch**: `021-password-reset` | **Date**: 2026-03-01

## Endpoints

### Used by Skill

| Method | Path | Spec Ref | User Story |
|--------|------|----------|------------|
| POST | `/passwords/reset` | FR-001 | US1: Admin triggers password reset |

### Documented Only (not used by skill)

| Method | Path | Spec Ref | User Story |
|--------|------|----------|------------|
| PUT | `/passwords` | FR-005 | US2: API reference documentation |

## Request/Response Contracts

### POST /passwords/reset

**Auth**: Required (Bearer token). Caller must have admin role.

**Body**:
```json
{
  "user_id": 42
}
```

**Response** (200):
```json
{
  "data": {
    "message": "Password reset email sent"
  }
}
```

**Error Responses**:

| Status | Cause | Skill Message |
|--------|-------|---------------|
| 401 | Invalid/expired token | "Unauthorized (401). Run `/rkit:setup` to update your token." |
| 403 | Caller is not admin | "Admin access required." |
| 422 | Invalid user_id, user not in account, user has no email | Show validation error from response body |

### PUT /passwords (documented only)

**Auth**: None (unauthenticated). Reset token serves as authentication.

**Body**:
```json
{
  "token": "abc123def456...",
  "password": "newSecurePassword"
}
```

**Response** (200):
```json
{
  "data": {
    "message": "Password updated successfully"
  }
}
```

**Error Responses**:

| Status | Cause |
|--------|-------|
| 422 | Invalid/expired token, missing token or password |
