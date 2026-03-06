---
description: Commit remaining changes, push branch, merge to main, and push main.
allowed-tools: Bash, Read, Glob, Grep
---

## Ship Current Branch

### 1. Identify the current branch

```bash
git branch --show-current
```

If already on `main`, stop and tell the user there's nothing to merge.

Store the branch name as `BRANCH`.

### 2. Commit and push any remaining changes

Run `git status --porcelain`. If there are uncommitted changes:

1. Stage all changed and untracked files (excluding `.env`, credentials, secrets)
2. Commit with a descriptive message summarizing the changes
3. Push to origin

If clean, skip to step 3.

### 3. Push the branch

```bash
git push origin BRANCH
```

### 4. Checkout main and pull latest

```bash
git checkout main && git pull --rebase origin main
```

### 5. Merge the feature branch

```bash
git merge BRANCH
```

If there are merge conflicts, stop and tell the user.

### 6. Push main

```bash
git push origin main
```

### 7. Close the GitHub issue (if found)

Look for a spec file for this branch:

```bash
SPEC_FILE="specs/BRANCH/spec.md"
```

If the spec file exists, extract the GitHub issue number:

```bash
grep -E 'GitHub Issue' "$SPEC_FILE"
```

Parse the integer N from `GitHub Issue #N`. If found:

1. Verify the issue is open:
   ```bash
   gh issue view N --repo w3mg/resultkit-skills --json state --jq '.state'
   ```
2. If open, comment and close:
   ```bash
   gh issue comment N --repo w3mg/resultkit-skills --body "Completed in branch \`BRANCH\`. Merged to main."
   gh issue close N --repo w3mg/resultkit-skills
   ```

If no spec file or no issue number found, skip silently.

### 8. Report

Print:
- Branch merged: `BRANCH`
- Issue closed: `#N` (if closed), or omit if none found
- Remind user to run `/plugin marketplace update` to get the latest
