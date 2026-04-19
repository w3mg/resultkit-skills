---
model: claude-sonnet-4-6
description: Merge the current feature branch into main, bump the plugin version, commit all pending changes, push, post an implementation summary on the GitHub issue, and close it.
---

Merge the current feature branch to main, bump the plugin version, push, and close the GitHub issue. Run all steps automatically — no pausing, no asking.

1. Run `git branch --show-current` to capture the current branch name. Store it as BRANCH.

2. If BRANCH is `main`, stop and tell the user: "Already on main — nothing to ship. Switch to a feature branch first."

3. **Find the GitHub issue number** — extract from BRANCH using this priority order:
   1. **`-gh<N>` suffix** — match `-gh` followed by digits at the end (e.g. `028-gantt-kibo-ui-gh70` → `70`).
   2. **`fix/<N>-` prefix** — match digits immediately after `fix/` (e.g. `fix/42-null-user-crash` → `42`).
   3. **Leading digits (legacy fallback)** — match leading digits before the first `-` (e.g. `018-old-style` → `18`). Warn the user.
   - Store as ISSUE_NUMBER. If no number found, skip the issue comment/close steps and note it in the final report.

4. **Commit any remaining changes on the feature branch**:
   - Run `git status` to check for uncommitted changes.
   - If there are staged or unstaged changes:
     - `git add -u` to stage all tracked changes.
     - Stage any new untracked files that belong to the feature (never `git add .` or `git add -A`).
     - Commit with a descriptive message referencing the issue.

5. **Exit worktree if in one**:
   ```bash
   git rev-parse --git-dir
   ```
   If the path contains `worktrees`, call `ExitWorktree` with `action=keep`. Wait until the session is back in the main repo root before continuing.

6. **Merge the feature branch into main**:
   ```bash
   git checkout main
   git pull origin main
   ```
   If the merge would be blocked by untracked files (git reports "would be overwritten by merge"), clean them:
   ```bash
   git clean -f <specific conflicting file paths listed by git>
   ```
   Then merge:
   ```bash
   git merge $BRANCH --no-edit
   ```

7. **Stage all pending changes** — there may be unstaged modifications left over (e.g. api-reference sync files modified before the session started):
   ```bash
   git add -u
   ```

8. **Bump the plugin version** — read `.claude-plugin/plugin.json`, increment the patch version (e.g. `1.2.90` → `1.2.91`), write it back. Then stage it:
   ```bash
   git add .claude-plugin/plugin.json
   ```

9. **Commit everything** with a message that references the issue and new version:
   ```bash
   git commit -m "$(cat <<'EOF'
   <summary of what was done> (closes #ISSUE_NUMBER); bump vX.Y.Z
   
   Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
   EOF
   )"
   ```
   If `git status` shows nothing to commit (all changes were already in the merge commit), skip this step.

10. **Push main**:
    ```bash
    git stash   # only if git pull --rebase fails due to unstaged changes
    git pull --rebase origin main
    git stash pop   # if stashed
    git push origin main
    ```

11. **Post implementation summary on the GitHub issue** (skip if no ISSUE_NUMBER):
    - Gather: `git log origin/main~2..HEAD --oneline` — recent commits on this branch.
    - Write a comment:
      ```
      ## Implemented

      <1–3 sentence summary of what was built>

      **Commits**:
      - <each commit, one per line>
      ```
    - Post it: `gh issue comment $ISSUE_NUMBER --body "$(cat <<'EOF' ... EOF)"`

12. **Close the issue** (skip if no ISSUE_NUMBER):
    ```bash
    gh issue close $ISSUE_NUMBER
    ```

13. **Report**:
    ```
    Merged: $BRANCH → main
    Version: vX.Y.Z
    Issue #$ISSUE_NUMBER: comment posted, issue closed
    Next: run `/plugin marketplace update`
    ```
