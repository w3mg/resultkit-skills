---
allowed-tools: Bash, Read, Glob, Grep
---

## Close the GitHub Issue for the Most Recently Completed Feature

### 1. Determine the issue number

If the user provided an argument, use it as the issue number:

```
$ARGUMENTS
```

If `$ARGUMENTS` is empty or blank, auto-detect by finding the most recently modified spec with "Complete" status:

```bash
SPEC_FILE=$(grep -rl '^\*\*Status\*\*: Complete' specs/*/spec.md 2>/dev/null | xargs -r ls -t 2>/dev/null | head -1)
echo "$SPEC_FILE"
```

If no completed spec found, stop and tell the user: "No completed spec found. Pass the issue number: `/close-issue 9`"

### 2. Extract issue number and branch from spec

```bash
grep -E '(GitHub Issue|Feature Branch)' "$SPEC_FILE"
```

Parse:
- **Issue number**: from `GitHub Issue #N` in the `**Input**` line → extract the integer N
- **Branch name**: from `**Feature Branch**: \`NNN-name\`` → extract the string inside backticks

If no issue number found, stop and tell the user.

### 3. Verify the issue is open

```bash
gh issue view ISSUE_NUMBER --repo w3mg/resultkit-skills --json state --jq '.state'
```

If already `CLOSED`, tell the user "Issue #N is already closed." and stop.

### 4. Comment and close

```bash
gh issue comment ISSUE_NUMBER --repo w3mg/resultkit-skills --body "Completed in branch \`BRANCH_NAME\`. Merged to main."
gh issue close ISSUE_NUMBER --repo w3mg/resultkit-skills
```

### 5. Report

Print:
- Closed: Issue #N
- Branch: BRANCH_NAME
