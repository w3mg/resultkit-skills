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

### 2. Extract the GitHub issue number from the branch name

Branches linked to GitHub issues are named `NNN-short-name-ISSUE` (e.g., `031-remove-speckit-25`). Extract the trailing number:

```bash
ISSUE_NUMBER=$(echo "BRANCH" | grep -oE '[0-9]+$')
```

This returns the issue number if present, or empty string if the branch has no trailing issue number.

### 3. Commit any remaining changes

Run `git status --porcelain`. If there are uncommitted changes:

1. Stage all changed and untracked files (excluding `.env`, credentials, secrets)
2. Commit with a descriptive message summarizing the changes

If clean, skip to step 4.

### 4. Add a completion commit on the branch

Look for a spec file at `specs/BRANCH/spec.md`. If it exists:

1. Extract the feature title (first `# ` heading after the frontmatter)
2. Look for `specs/BRANCH/tasks.md` — if it exists, mark any remaining `- [ ]` tasks as `- [X]` and stage it
3. Commit with:
   ```
   Complete: <feature title> (branch: BRANCH, closes #ISSUE_NUMBER)
   ```
   Omit `closes #ISSUE_NUMBER` if ISSUE_NUMBER is empty. Use `git commit --allow-empty` if no file changes remain, to ensure the completion marker always lands in the log.

If no spec file exists but ISSUE_NUMBER is non-empty, still emit an empty completion commit: `Complete: BRANCH (closes #ISSUE_NUMBER)`.

### 5. Push the branch

```bash
git push origin BRANCH
```

### 6. Checkout main and pull latest

```bash
git checkout main && git pull --rebase origin main
```

### 7. Merge the feature branch

```bash
git merge BRANCH
```

If there are merge conflicts, stop and tell the user.

### 8. Push main

```bash
git push origin main
```

### 9. Close the GitHub issue (if found)

Use ISSUE_NUMBER from step 2. If it is non-empty:

1. Verify the issue is open:
   ```bash
   gh issue view ISSUE_NUMBER --repo w3mg/resultkit-skills --json state --jq '.state'
   ```
2. If open, comment and close:
   ```bash
   gh issue comment ISSUE_NUMBER --repo w3mg/resultkit-skills --body "Completed in branch \`BRANCH\`. Merged to main."
   gh issue close ISSUE_NUMBER --repo w3mg/resultkit-skills
   ```

If ISSUE_NUMBER is empty, skip silently.

### 10. Report

Print:
- Branch merged: `BRANCH`
- Issue closed: `#ISSUE_NUMBER` (if closed), or omit if none found
- Remind user to run `/plugin marketplace update` to get the latest
