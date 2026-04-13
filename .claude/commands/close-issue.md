---
model: claude-sonnet-4-6
allowed-tools: Bash, Read, Glob, Grep
---

## Close the GitHub Issue for the Most Recently Completed Feature

### 1. Determine the issue number

If the user provided an argument, use it as the issue number:

```
$ARGUMENTS
```

If `$ARGUMENTS` is empty or blank, try these sources in order:

**a. Extract from the current branch name** (preferred — branches are named `NNN-short-name-ISSUE`):

```bash
git branch --show-current | grep -oE '[0-9]+$'
```

**b. Fall back to parsing the most recently modified completed spec**:

```bash
SPEC_FILE=$(grep -rl '^\*\*Status\*\*: Complete' specs/*/spec.md 2>/dev/null | xargs -r ls -t 2>/dev/null | head -1)
grep -E 'GitHub Issue' "$SPEC_FILE"
```

Parse the integer N from `GitHub Issue #N`.

If no issue number found by any method, stop and tell the user: "No issue number found. Pass it directly: `/close-issue 9`"

### 2. Identify the branch

```bash
BRANCH=$(git branch --show-current)
```

If the spec file was used in step 1, also parse:
- **Branch name**: from `**Feature Branch**: \`NNN-name\`` → extract the string inside backticks

### 3. Verify the issue is open

```bash
gh issue view ISSUE_NUMBER --repo w3mg/resultkit-skills --json state --jq '.state'
```

If already `CLOSED`, tell the user "Issue #N is already closed." and stop.

### 4. Comment and close

```bash
gh issue comment ISSUE_NUMBER --repo w3mg/resultkit-skills --body "Completed in branch \`BRANCH\`. Merged to main."
gh issue close ISSUE_NUMBER --repo w3mg/resultkit-skills
```

### 5. Report

Print:
- Closed: Issue #N
- Branch: BRANCH
