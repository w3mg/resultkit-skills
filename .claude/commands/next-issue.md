---
model: claude-sonnet-4-6
description: Grab the oldest open GitHub issue and triage it — handoff docs get noted, features/bugs start /speckit:specify
---

## Goal

Fetch the oldest open GitHub issue, classify it, and take the appropriate action.

## Steps

### 0. Preflight — verify not already in a worktree

Run:
```bash
git rev-parse --git-dir
```

If the output contains `worktrees` in the path (e.g. `.claude/worktrees/issue-42/.git`), **stop immediately** and tell the user:

> You are already inside a worktree for another ticket. Open a new terminal session, `cd` to the main repository root, and run `/next-issue` from there. Each ticket needs its own fresh Claude session.

Do not fetch any issue, apply any label, or do any work. Exit the command entirely.

**Ensure required labels exist** — run once before touching any issue:
```bash
gh label list --json name --jq '.[].name' | grep -q "^in-progress$" \
  || gh label create "in-progress" --color "0075ca" --description "Being actively worked on"
```

This is a no-op if the label already exists.

### 1. Fetch the target issue

**If an issue number was passed as an argument** (i.e., `$ARGUMENTS` is non-empty and contains a number):
- Use that specific issue:
  ```
  gh issue view <number> --json number,title,body,labels,comments
  ```
- Store it as ISSUE.

**Otherwise** (no argument — default behavior):
- Run:
  ```
  gh issue list --state open --json number,title,body,labels --limit 100 -S "sort:created-asc"
  ```
- Parse the JSON. Skip any issues that have the **"Needs clarification"** label (awaiting owner input), the **"in-progress"** label (being worked on in another terminal), or the **"ready-for-review"** label (already done, awaiting human review). The **oldest eligible issue** is the one with the **lowest `number`** that has none of these labels. Store it as ISSUE.
- Then fetch the full issue with comments:
  ```
  gh issue view <number> --json number,title,body,labels,comments
  ```

Display a summary:
```
Issue #<number>: <title>
```

Apply the **in-progress** label immediately:
```
gh issue edit <number> --add-label "in-progress"
```

### 2. Classify the issue

There are three kinds of issues:

**A. API Handoff Document** — recognized by:
- Title contains `[API Change]` or `API Change Handoff`
- Body contains `## API Change Handoff` or `## What Each Developer Needs to Do`
- Body contains `## Breaking Changes`

**B. API Fix Resolution** — recognized by:
- Title contains `[API Fix]`
- Body contains `## API Fix Summary` or `## Frontend Impact`
- Body references an API repo issue (e.g., `https://github.com/w3mg/resultmaps-api2/issues/`)
- These are responses from the API team to issues we filed via `/open-issue:api-engineer`

**C. Feature Request / Bug** — everything else (feature requests, bug reports, improvements, etc.)

Report the classification:
```
Classification: API Handoff | API Fix Resolution | Feature/Bug
```

### 3. Handle based on classification

#### 3A. API Handoff

1. Read the issue body and look for the `## Breaking Changes` section.
2. **If the section is missing, says "None", or lists no actual breaking changes** — treat as non-breaking:
   - Scan the `## New Endpoints` and `## Key Behaviors` sections for the endpoint paths.
   - Search the codebase (`lib/hooks/`, `specs/`, `ai-docs/`) for those endpoint paths to check if already consumed.
   - **Already consumed** (endpoints exist in hooks or contracts): close the issue.
     ```
     gh issue comment <number> --body "Consumed — endpoints are already integrated in the frontend. No action needed."
     gh issue close <number>
     ```
   - **New endpoints not yet consumed**: update the relevant contract docs in `specs/` and `ai-docs/` to note the new endpoints. Commit the doc update. Then close the issue.
     ```
     gh issue comment <number> --body "Documented new endpoints in specs/ and ai-docs/. No breaking changes — no code changes required yet."
     gh issue close <number>
     ```
   - **Always close the issue** when there are no breaking changes. Handoffs with no breaking changes never require feature work.
3. **If there ARE breaking changes** (existing endpoints changed behavior, renamed fields, removed endpoints, changed response shapes):
   - Report: `Breaking changes detected — starting /speckit:specify`
   - Proceed to Step 3C (same as Feature/Bug flow) with the breaking change details as the feature description.

#### 3B. API Fix Resolution

These are responses from the API team after we filed a bug via `/open-issue:api-engineer`. Evaluate what changed and whether the frontend needs updating.

1. Read the issue body. Look for:
   - `## Frontend Impact` section — tells you if frontend changes are needed
   - `## Affected Endpoints` — lists what changed
   - `## What Was Fixed` — explains the server-side fix
   - References to the original frontend issue (e.g., "originally reported in issue #8")

2. **Check if frontend changes are needed**:
   - If the body says "No frontend changes required" or the fix is purely auth/server-side logic: **no action needed**.
   - If endpoint signatures, response shapes, or field names changed: evaluate if frontend code needs updating.
   - If new fields were added to responses that the frontend should use: treat as a quick fix.

3. **If no frontend changes needed**:
   - Find the **original frontend issue** referenced in the body (e.g., "originally reported in issue #8").
   - Update the original issue with a resolution comment explaining how the API fix resolved it:
     ```
     gh issue comment <original-issue-number> --body "Resolved by API fix: <summary>. API issue: <api-issue-url>. Frontend issue: #<this-issue-number>. No frontend changes were needed — the fix was server-side."
     ```
   - Close the current API fix issue:
     ```
     gh issue comment <number> --body "Acknowledged — no frontend changes needed. Updated original issue #<original> with resolution."
     gh issue close <number>
     ```

4. **If frontend changes ARE needed**: proceed to the quick fix or full feature path (Step 3C) based on scope.

#### 3C. Feature Request / Bug

0. **Check comments for unresolved QA/reviewer feedback** — BEFORE reading the body or sizing the work:
   - Read all comments on the issue (`comments` field from Step 1).
   - Look for any comment from a human reviewer or QA person that describes a problem, visual bug, incorrect behavior, or change request.
   - A comment is **unresolved** if it describes a problem AND no subsequent "Resolved in..." or "Fixed in..." comment appears after it.
   - **If unresolved QA/reviewer feedback exists**:
     - Report what the feedback says.
     - **If the feedback is vague or unclear** (e.g., ambiguous description, no reproducible steps, unclear visual reference):
       - Post a comment on the issue directed at the feedback author asking targeted clarifying questions:
         ```
         gh issue comment <number> --body "<comment — see template below>"
         ```
       - Add the **"Needs clarification"** label and remove **"in-progress"**:
         ```
         gh issue edit <number> --add-label "Needs clarification"
         gh issue edit <number> --remove-label "in-progress"
         ```
       - Report: `Asked reviewer on Issue #<number> for clarification. Added "Needs clarification" label.`
       - Stop — do not size or implement anything.

       **Comment template for unclear QA feedback:**
       ```
       Hi @<feedback-author>! Thanks for the feedback. We have a few questions before we can address it:

       1. <question 1>
       2. <question 2>
       ...

       Once you've clarified, please remove the **"Needs clarification"** label so this gets picked up in the next cycle. Thank you!
       ```
     - **If the feedback is clear and actionable**: treat it as the issue to fix — it takes priority over the original body. Size it (quick fix vs. full feature) and proceed accordingly. Do not re-run speckit for the original feature; address the feedback directly.
   - **If no unresolved feedback**: continue to step 1 below.

1. Read the full issue body.
2. **If the issue is confusing or unclear, ask the user (you, the developer) before proceeding.** Do not guess intent or make assumptions. Ask targeted questions — one message, all questions at once. Examples of when to ask:
   - The desired behavior is ambiguous or contradictory
   - The issue references UI, flows, or data you cannot identify from the codebase
   - The acceptance criteria are missing or vague
   - You are unsure whether this is a bug or an intentional behavior
   - The scope is unclear (e.g., "improve X" without saying how)

   **Wait for the user's response.** You have two options depending on their reply:
   - **If the user answers the questions**: use their answers to proceed with sizing and implementation.
   - **If the user can't answer** (says "ask owner", "don't know", "post to GitHub", or similar): post the questions as a comment on the issue and label it for follow-up (see **"Ask Owner" flow** below), then stop. Do not implement anything.

3. **Size the work** — determine if this is a **quick fix** or a **full feature**:

   **Quick fix** (do it directly, skip speckit) — ALL of these must be true:
   - Touches 1-3 files
   - Change is obvious from the issue description (no ambiguity, no design decisions)
   - No new pages, routes, hooks, or components needed
   - Examples: remove a UI element, fix a typo, change a label, fix a CSS issue, toggle a visibility flag

   **Full feature** (use speckit) — ANY of these is true:
   - Touches 4+ files
   - Requires new pages, routes, hooks, or components
   - Has architectural decisions or multiple valid approaches
   - Needs clarification or has ambiguous requirements
   - Involves new API integration

4. **Quick fix path (TDD)**:
   a. **Enter a worktree**: Call `EnterWorktree` with `name=issue-<number>` (e.g. `issue-42`). Wait for it to be ready before continuing.
   b. Create a short-lived branch from main, embedding the GitHub issue number:
      ```
      git checkout main
      git pull origin main
      git checkout -b fix/<issue>-<short-slug>
      ```
      Where `<issue>` is the GitHub issue number and `<short-slug>` is a kebab-case summary (max 4 words). Example: `fix/42-null-user-crash`.
   c. **Investigate**: Find the relevant file(s), read them, understand the bug or missing behavior.
   d. **Write a failing test FIRST** (Red phase):
      - Determine the right test type:
        - **Component/unit test** (`__tests__/`): if the bug is in rendering, props, state, or logic within a single component
        - **E2E test** (`e2e/`): if the bug is about user flow, navigation, or requires a real API call
      - Write a test that **reproduces the bug** — it should FAIL with the current code.
      - The test name should describe the expected (correct) behavior, e.g., `"handles null user in activity log entry"`
      - Run the test to confirm it fails:
        ```
        npx jest <test-file> 2>&1 | tail -20
        ```
      - If the test passes (bug wasn't reproducible in test), that's OK — keep the test as a regression guard and proceed.
   e. **Fix the code** (Green phase):
      - Make the minimal change to fix the bug.
      - Run the test again to confirm it now passes.
   f. **Verify everything** (Refactor phase):
      - Run `npm run build` to verify no build errors.
      - Run `npm test` to verify all tests pass (no regressions).
   g. **Commit both test and fix together** with message referencing the issue: `Fix #<number>: <description>`
   h. Push the branch and mark the issue ready for review — do **NOT** merge to main or close the issue:
      ```
      git push origin fix/<issue>-<short-slug>
      ```
      Then poll GitHub Deployments for the Vercel preview URL (same as `/ship-it` — 3 min timeout, 10 s interval):
      ```bash
      BRANCH="fix/<issue>-<short-slug>"
      VERCEL_URL=""
      for i in $(seq 1 18); do
        DEPLOYMENT_ID=$(gh api "repos/w3mg/resultmaps-web-ui-2/deployments?ref=$BRANCH&per_page=5" \
          --jq '[.[] | select(.environment | test("Preview|preview"))][0].id // empty' 2>/dev/null)
        if [ -n "$DEPLOYMENT_ID" ]; then
          VERCEL_URL=$(gh api "repos/w3mg/resultmaps-web-ui-2/deployments/$DEPLOYMENT_ID/statuses?per_page=1" \
            --jq '[.[] | select(.state == "success")][0].environment_url // empty' 2>/dev/null)
          [ -n "$VERCEL_URL" ] && break
        fi
        echo "Waiting for Vercel deployment... ($i/18)"
        sleep 10
      done
      ```
      Build the comment (include Vercel URL if found, note pending if not):
      ```
      gh issue comment <number> --body "Fix pushed for review.

      **Branch**: [fix/<issue>-<short-slug>](<repo-url>/tree/fix/<issue>-<short-slug>)
      **Commit**: [<short-SHA>](<repo-url>/commit/<full-SHA>)
      **Preview**: <VERCEL_URL or 'Pending — check the deployments tab'>
      **What was done**: <commit subject line>"
      ```
      Update labels:
      ```
      gh issue edit <number> --add-label "ready-for-review"
      gh issue edit <number> --remove-label "in-progress"
      ```
   i. **Exit the worktree**: Call `ExitWorktree` with `action=keep`. The branch stays on origin for review; the session returns to the main repo root.
   j. Skip to Step 5 (Report).

5. **Full feature path** (speckit):
   a. Prepare the user input for `/speckit:specify` by composing a description that includes:
      - The issue title
      - The issue body (summarized if very long)
      - A tracking line: `**GitHub Issue**: #<number> — <title>`
      - If it's a bug: prefix with "Bug fix: "
      - If it's a feature: prefix with "Feature: "
   b. Run `/speckit:specify` with that composed description as the user input.
      - `/speckit:specify` will handle branch creation. Because the description includes `**GitHub Issue**: #<number>`, it will automatically append `-gh<number>` to the branch name (e.g. `019-item-detail-sidebar-gh52`). No manual branch creation needed here.

### "Ask Owner" flow

When the user can't answer the clarification questions (says "ask owner", "don't know", "post to GitHub", or similar):

1. Format the questions as a numbered list.
2. Post them as a comment on the issue:
   ```
   gh issue comment <number> --body "<comment body — see template below>"
   ```
3. Add the **"Needs clarification"** label:
   ```
   gh issue edit <number> --add-label "Needs clarification"
   ```
4. Report to the user:
   ```
   Asked owner on Issue #<number>. Added "Needs clarification" label. Issue will be skipped on future /next-issue runs until the label is removed.
   ```
5. Stop — do not size or implement anything.

**Comment template:**

```
Hi! We have a few questions before we can start work on this issue:

1. <question 1>
2. <question 2>
...

Once you've answered, please remove the **"Needs clarification"** label from this issue so it gets picked up in the next development cycle. Thank you!
```

### 4. Issue tracking in spec

When `/speckit:specify` runs (full feature path only), ensure the spec includes this metadata near the top:

```markdown
**GitHub Issue**: #<number> — <title>
**Issue URL**: https://github.com/<owner>/<repo>/issues/<number>
```

This ensures we can close the issue when the feature ships.

### 5. Report

After completing all steps, display:
```
Next issue: Issue #<number> — <title>
Classification: API Handoff | API Fix Resolution | Quick Fix | Full Feature
Action taken: <what was done>
Branch: <branch name if created>
Next step: <what the developer should do next>
```
