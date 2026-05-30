# Quickstart: Testing Result Feed API 077 Updates

**Branch**: `041-result-feed-tier1-gh109`
**Date**: 2026-04-28

## Prerequisites

- ResultKit installed: `/plugin install rkit@resultkit`
- Config set up: `/rkit:setup`
- Active result-feed report for today (or a known date)

## Test Checklist

### 1. React endpoint

```bash
# Should call POST /result-feed/today/reactions (not /react)
/rkit:result-feed high-five today's check-in

# Should call GET /result-feed/today/reactions?user_id=<id>
/rkit:result-feed show reactions on today's check-in
```

**Expected**: Response shows `reacted: true/false` and `count: N` (not `high_five_count`).

---

### 2. Review section

```bash
# Should accept "review" without "invalid section" error
/rkit:result-feed add item 42 to review section
/rkit:result-feed set notes on review section: "waiting for approval"
```

**Expected**: API call succeeds with section=review.

---

### 3. File upload

```bash
/rkit:result-feed attach file to today's check-in
```

**Expected**: Skill asks for file, calls `POST /result-feed/today/attachments`, returns document ID.

---

### 4. Push to Slack

```bash
/rkit:result-feed push to slack
```

**Expected**: Request body contains `group_context_id` (not `team_id`).

---

### 5. api-reference.md audit

After implementation, verify:

```bash
# Should return 0 matches (old path removed)
grep -n "/result-feed/.*react[^i]" api-reference.md

# Should return 0 matches (old field names removed)
grep -n "high_five_count\|user_has_reacted" api-reference.md

# Should return 0 matches (old push body param)
grep -n "team_id\*\|team_id:" api-reference.md | grep -i "push\|slack\|discord"
```

## api.sh Manual Tests

```bash
APIRC="scripts/api.sh"
DATE=$(date +%Y-%m-%d)

# Test GET reactions
"$APIRC" GET "/result-feed/$DATE/reactions"

# Test POST reactions (toggle)
"$APIRC" POST "/result-feed/$DATE/reactions" '{}'

# Test review section item add
"$APIRC" PUT "/result-feed/$DATE/review/42"
```
