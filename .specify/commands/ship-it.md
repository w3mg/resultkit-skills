---
description: Commit all changes, push branch to origin, get Vercel preview URL, and mark GitHub issue ready-for-review
---

1. Run `git branch --show-current` to capture the current branch name. Store it as BRANCH.

2. If BRANCH is `main`, stop and tell the user: "Already on main — nothing to ship. Switch to a feature branch first."

3. **Clean up debug test scaffolding** — delete any leftover debug test files that should never be committed:
   - Run: `find __tests__ -name "test-debug*.test.*" -delete 2>/dev/null; find __tests__ -name "debug*.test.*" -delete 2>/dev/null; find e2e -name "test-debug*.spec.*" -delete 2>/dev/null`
   - These files are always untracked; this is a no-op if none exist.

4. Run `git status` to check for uncommitted changes.

5. If there are staged or unstaged changes (modified/added/deleted files):
   - Stage all tracked changes with `git add -u`
   - Stage any new untracked files that are NOT in .gitignore (use `git add` on specific files — never `git add .` or `git add -A` to avoid secrets)
   - Commit with a descriptive message summarizing the changes

6. Push the branch:
   ```bash
   git push origin $BRANCH
   ```

7. **Get the Vercel preview URL** — poll GitHub Deployments until Vercel posts the preview URL (timeout: 3 minutes):
   ```bash
   # Poll every 10 seconds for up to 18 attempts (3 minutes)
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
   - If `VERCEL_URL` is found: store it for use in step 8.
   - If not found after timeout: set `VERCEL_URL=""` and continue — the issue comment will note that the URL is pending.

8. **Find the GitHub issue number** — extract from BRANCH using this priority order:
   1. **`-gh<N>` suffix** — match `-gh` followed by digits at the end (e.g. `028-gantt-kibo-ui-gh70` → `70`). Canonical format for `/next-issue` branches.
   2. **`fix/<N>-` prefix** — match digits immediately after `fix/` (e.g. `fix/42-null-user-crash` → `42`). Canonical format for quick-fix branches.
   3. **Leading digits (legacy fallback)** — match the leading digits before the first `-` only if neither pattern above matched (e.g. `018-old-style` → `18`). Warn the user that this is a legacy branch name and the issue number may be incorrect.
   - Store as ISSUE_NUMBER. If no number is found, skip steps 9–10 and report: "No GitHub issue number found in branch name — skipping issue update."

9. **Update the GitHub issue**:
   - Build the comment body:
     - If VERCEL_URL is set:
       ```
       Branch `$BRANCH` pushed to Vercel preview.

       **Preview**: $VERCEL_URL

       Ready for review.
       ```
     - If VERCEL_URL is empty:
       ```
       Branch `$BRANCH` pushed. Vercel preview URL not yet available — check the PR/deployments tab.

       Ready for review.
       ```
   - Post the comment: `gh issue comment $ISSUE_NUMBER --body "<comment body>"`
   - Add "ready-for-review" label: `gh issue edit $ISSUE_NUMBER --add-label "ready-for-review"`
   - Remove "in-progress" label (if present): `gh issue edit $ISSUE_NUMBER --remove-label "in-progress"` (ignore errors if label wasn't set)
   - **Do NOT close the issue.**

10. **Exit worktree if applicable** — check if currently in a worktree:
    ```bash
    git rev-parse --git-dir
    ```
    If the output contains `worktrees` in the path, call `ExitWorktree` with `action=keep`. The branch stays on origin for review; the session returns to the main repo root.

11. **Report**:
    ```
    Branch pushed: $BRANCH
    Vercel preview: $VERCEL_URL (or "pending")
    Issue #$ISSUE_NUMBER: labeled ready-for-review
    Worktree: exited (if applicable)
    ```
