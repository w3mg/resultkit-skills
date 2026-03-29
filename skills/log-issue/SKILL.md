---
name: rkit:log-issue
description: >
  Log a GitHub issue to any ResultMaps project repo. Use this skill whenever the user wants to
  file a bug, log an issue, track a feature request, note a problem, or report something broken
  across any of the ResultMaps repos. Triggers on phrases like "log an issue", "file a bug",
  "create an issue", "track this", "report a bug", "add a ticket", "open an issue",
  "something is broken in...", or when the user describes a problem and wants it recorded.
  Also use when the user says "issue" in the context of any ResultMaps project.
user-invocable: true
allowed-tools: Bash, Read, Glob, Grep, AskUserQuestion
---

# Log Issue

Create GitHub issues in the right ResultMaps repository with the right context.

## Repos

| Shortname | GitHub repo | What lives here |
|---|---|---|
| **frontend** | `w3mg/resultmaps-web-ui-2` | Next.js app — the main UI users see |
| **legacy** | `w3mg/resultmaps` | Rails backend — the original API/server |
| **api2** | `w3mg/resultmaps-api2` | New Next.js API layer |
| **resultkit** | `w3mg/resultkit-skills` | CLI skills for ResultMaps (Claude Code plugin) |
| **mcp** | `w3mg/resultmaps-mcp-server` | MCP server for Claude Desktop integration |
| **masterymaps** | `w3mg/masterymaps` | MasteryMaps Rails app |

## Workflow

### 1. Figure out what the issue is — and what kind it is

Read what the user said and gauge whether they're handing you something **actionable** or something **exploratory**.

**Actionable (default):** The user knows what needs to happen. They give you a clear bug, feature, or task. Log it directly — no extra questions needed beyond the usual (repo, missing details).

- "log a bug: login button broken on mobile" → just log it.
- "add a tooltip to the milestone card" → just log it.

**Exploratory:** The user is describing a business problem, pain point, or rough idea — but hasn't landed on what to do about it. You can tell because:
- They're thinking out loud, not giving instructions
- They describe *what's wrong* or *what they wish were different*, not *what to build*
- There are assumptions baked in that haven't been examined
- The scope is unclear

When you detect this, **don't rush to create the issue.** Instead, shift into a conversational mode:
- Help the user articulate the actual problem
- Surface hidden assumptions ("are we assuming X?")
- Ask what they know vs. what they're guessing
- Tease out who's affected and what good looks like

Once the problem is clear enough to write up, create the issue — but **keep it in problem-space.** The issue body should describe the business problem, context, and constraints. It should NOT prescribe a solution. Requirements discovery is part of the work.

Use the `question` label for exploratory issues when appropriate, in addition to any other relevant labels.

For everything else — bugs, clear features, specific tasks — the existing flow is unchanged:

### 2. Research before logging (REQUIRED)

**Before creating any issue, research what already exists.** This is not optional — skip this and the issue will be wrong.

- **Search for existing issues** — `gh issue list -R w3mg/<repo> --search "<keywords>"` across relevant repos. If an issue already covers the topic, update it instead of creating a duplicate.
- **Search the codebase** — Grep/Glob the relevant repo(s) for related code, models, tables, endpoints, and services. If you're not currently in the target repo, use `gh api` or clone to a temp directory to inspect it.
- **Check the database schema** — If the issue involves data, check what tables and models already exist in the Prisma schema or Rails schema.
- **Check existing endpoints** — If the issue involves API work, check what routes and services already exist.
- **Check existing implementations** — If a similar feature was built for a different entity (e.g., attachments for groups when the issue is about attachments for items), reference that implementation in the issue body.

The issue body must reflect what you found. Reference existing tables, services, patterns, and prior implementations. An issue that assumes greenfield when the data model and half the implementation already exist wastes everyone's time.

**Never log an issue that prescribes "build X from scratch" without first verifying that X doesn't already exist.**

### 3. Pick the right repo

Use context clues to determine the repo:
- UI/component/page/styling/Tailwind/React issues → **frontend**
- Rails/Ruby/database/migration/ActiveRecord issues → **legacy**
- New API endpoints/Next.js API routes/middleware → **api2**
- CLI skills/rkit commands → **resultkit**
- MCP tools/Claude Desktop integration → **mcp**
- MasteryMaps-specific features → **masterymaps**

If ambiguous, ask.  If the user names the repo directly (by shortname or full name), use that.

### 4. Pick labels

Use the standard GitHub labels that exist on these repos:
- `bug` — something is broken
- `enhancement` — new feature or improvement
- `documentation` — docs need updating
- `question` — needs discussion or clarification

Only apply labels that clearly fit. One or two is typical. Don't overthink it.

### 5. Create the issue

Use `gh issue create` via Bash:

```
gh issue create -R w3mg/<repo-name> --title "<title>" --body "<body>" --label "<label>"
```

For the body, write a clear description. Include relevant context the user provided — file paths, error messages, steps to reproduce, screenshots references, etc. Keep it concise but useful for whoever picks it up later.

If the user is currently working in one of these repos and the issue relates to code they're looking at, reference specific files/lines when helpful.

### 6. Confirm

After creating the issue, show the user the issue URL and a one-line summary of what was filed.

## Multiple issues

If the user wants to log several issues at once, create them all. You can batch them in parallel if they're independent.

## Listing / searching issues

If the user asks to see existing issues for a repo, use `gh issue list -R w3mg/<repo-name>`. This skill is primarily for creating issues, but viewing them is a natural companion action.
