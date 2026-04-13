---
model: claude-sonnet-4-6
description: Commit all changes, push branch to origin, post implementation summary comment on GitHub issue, and close the issue
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

7. **Find the GitHub issue number** — extract from BRANCH using this priority order:
   1. **`-gh<N>` suffix** — match `-gh` followed by digits at the end (e.g. `028-gantt-kibo-ui-gh70` → `70`). Canonical format for `/next-issue` branches.
   2. **`fix/<N>-` prefix** — match digits immediately after `fix/` (e.g. `fix/42-null-user-crash` → `42`). Canonical format for quick-fix branches.
   3. **Leading digits (legacy fallback)** — match the leading digits before the first `-` only if neither pattern above matched (e.g. `018-old-style` → `18`). Warn the user that this is a legacy branch name and the issue number may be incorrect.
   - Store as ISSUE_NUMBER. If no number is found, skip steps 8–9 and report: "No GitHub issue number found in branch name — skipping issue update."

8. **Post implementation summary comment on the GitHub issue**:
   - Build the comment by gathering:
     - `git log main..HEAD --oneline` — commits on this branch
     - The feature spec at `specs/*/spec.md` matching this branch (by leading issue number or branch name)
     - Completed tasks from that spec's `tasks.md` (lines matching `- [x]`)
   - Write a comment in this format:
     ```
     ## Implemented

     <1–3 sentence summary of what was built, derived from the spec overview and completed tasks>

     **Commits**:
     - <each commit from git log, one per line>

     **Tasks completed**: <count of [x] items> / <total tasks>
     ```
   - Post it: `gh issue comment $ISSUE_NUMBER --body "$(cat <<'EOF' ... EOF)"`

9. **Close the issue**:
   - `gh issue close $ISSUE_NUMBER`

10. **Exit worktree if applicable** — check if currently in a worktree:
    ```bash
    git rev-parse --git-dir
    ```
    If the output contains `worktrees` in the path, call `ExitWorktree` with `action=keep`. The branch stays on origin for review; the session returns to the main repo root.

11. **Report**:
    ```
    Branch pushed: $BRANCH
    Issue #$ISSUE_NUMBER: comment posted, issue closed
    Worktree: exited (if applicable)
    ```
