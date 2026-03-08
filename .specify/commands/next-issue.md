---
description: Pull the oldest open GitHub issue and kick off a spec with /speckit.specify.
---

## Next Issue

### 1. Fetch the oldest open issue

Run:

```bash
gh issue list --repo w3mg/resultkit-skills --state open --json number,title,body,labels --limit 30 --jq 'sort_by(.number) | .[0]'
```

If no issues are returned, tell the user there are no open issues and stop.

### 2. Build the feature description

From the JSON output, construct a feature description string:

```
GitHub Issue #<number>: <title>

<body>
```

### 3. Hand off to speckit:specify

Run `/speckit:specify` with the feature description from step 2 as the argument. Follow that skill's full workflow — branch creation, spec writing, validation, and all.

**Note**: Because the description starts with `GitHub Issue #N:`, speckit:specify will automatically embed the issue number at the end of the branch name (e.g., `032-fix-something-26`). This allows `/ship-it` and `/close-issue` to recover the issue number directly from the branch name without parsing spec files.

### 4. Add a kickoff commit on the new branch

After `/speckit:specify` completes and the new branch exists, stage any spec files created under `specs/` and commit with:

```
Start: <feature title> (branch: <branch-name>, issue: #<number>)
```

This ensures the branch has a traceable kickoff commit in the log linking it to the GitHub issue.
