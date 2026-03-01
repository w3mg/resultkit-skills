---
description: Pull the oldest open GitHub issue and kick off a spec with /speckit.specify.
---

## Next Issue

### 1. Fetch the oldest open issue

Run:

```bash
gh issue list --repo w3mg/resultkit-skills --state open --sort created --json number,title,body,labels --limit 1 --jq '.[0]'
```

If no issues are returned, tell the user there are no open issues and stop.

### 2. Build the feature description

From the JSON output, construct a feature description string:

```
GitHub Issue #<number>: <title>

<body>
```

### 3. Hand off to speckit.specify

Run `/speckit:specify` with the feature description from step 2 as the argument. Follow that skill's full workflow — branch creation, spec writing, validation, and all.
