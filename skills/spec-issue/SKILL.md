---
name: spec-issue
description: >
  Log a GitHub issue to any ResultMaps project repo as a behavior-driven spec with a test plan.
  Use this skill whenever the user wants to file a bug, log an issue, track a feature request,
  spec out a behavior, note a problem, or report something broken across any of the ResultMaps
  repos. Triggers on phrases like "log an issue", "file a bug", "create an issue", "spec this",
  "track this", "report a bug", "add a ticket", "open an issue", "something is broken in...",
  or when the user describes a problem and wants it recorded. Also use when the user says
  "issue" in the context of any ResultMaps project. Issues produced by this skill are behavior
  specs plus missing-test specs — never implementation plans.
user-invocable: true
allowed-tools: Bash, Read, Glob, Grep, AskUserQuestion
---

# Spec Issue

Create GitHub issues that spec **what should be true**, not **how to build it**.

Every issue this skill produces has two parts: a behavior-driven spec of the problem and desired
behavior, and a list of missing tests that define done. The implementer — human or LLM — picks up
the issue, adds each missing test, watches it fail, then makes it pass. The issue never tells them
how to make it pass.

Why this shape: implementation details written at logging time go stale, constrain the implementer
to the author's first guess, and let "looks done" substitute for "verified done." A failing test is
the only honest statement that something is missing, and a passing one the only honest statement
that it's fixed.

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

### 1. Understand the problem

Gauge whether the user is handing you something **actionable** (a clear bug or feature — spec it
directly) or something **exploratory** (a pain point, rough idea, or thinking-out-loud). For
exploratory problems, don't rush to file. Help the user articulate the actual problem, surface
hidden assumptions, and figure out who's affected and what good looks like. Only file once the
desired behavior is clear enough to write scenarios for — and keep the issue in problem-space.
Use the `question` label for issues that are still exploratory.

### 2. Verify the gap

Before filing, do just enough research to make the spec honest — no more:

- **Search for duplicates**: `gh issue list -R w3mg/<repo> --search "<keywords>"`. If an issue
  already covers this, update it instead of filing a new one.
- **Confirm current behavior**: check that what the user describes is what actually happens, so the
  Problem section states facts, not guesses.
- **Locate the test gap**: glance at the repo's test suite for coverage of this behavior. You need
  this to credibly say a test is *missing* — and to note where the suite for this area lives.

What research is **for**: making scenarios accurate and the missing-test list real. What it is
**not for**: gathering tables, services, components, or prior implementations to cite in the body.
That material turns specs into implementation plans — leave it out.

### 3. Pick the repo

Use context clues: UI/component/styling → **frontend**; Rails/database/migration → **legacy**;
API routes/middleware → **api2**; CLI skills/rkit commands → **resultkit**; MCP tools → **mcp**;
MasteryMaps → **masterymaps**. If the user names a repo, use it. If genuinely ambiguous, ask.

### 4. Write the spec

Title the issue after the behavior, not a solution — "Overdue items keep stale status after
reassignment", not "Add status-refresh hook".

Use this body structure:

```markdown
> **Source of truth:** `<prototype path>` — the built UI must match this prototype exactly.
(Include this callout as the FIRST line only when the issue stems from an HTML prototype or
design-intent file. Never bury the prototype path lower in the body.)

## Problem

What happens today, who it affects, and why it matters. Observed facts in problem-space —
no diagnosis, no architecture commentary.

## Desired behavior

### Scenario: <short name>
- **Given** <starting context>
- **When** <action or event>
- **Then** <observable outcome>

(One scenario per distinct behavior. As many as the problem needs, no more.)

## Missing tests

Each test below is missing today. For each one, in order: add the test, run it, **watch it fail
for the right reason**, then write whatever makes it pass. Do not start implementation before the
failing test exists.

1. **<what the test verifies>** — covers Scenario: <name>. Level: unit / integration / e2e.
   Suite: <existing test directory, if one clearly covers this area>.
2. ...

## Done when

Every test above exists and passes, and every scenario holds.
```

### 5. What never goes in the body

These rules are the point of the skill — they keep the issue a spec instead of a plan:

- **No implementation steps or solution sketches.** Not even "probably just needs X."
- **No test code.** Name what the test verifies; the implementer writes it.
- **No "how to make it pass."** The red→green instruction is the only implementation guidance.
- **Name the affordance gap, not a component.** "User has no way to dismiss the banner" — not
  "use the Toast component." Different surfaces have different rules.
- **Don't endorse the current architecture.** If current behavior might be the wrong default,
  frame that as part of the problem rather than speccing around it.

### 6. Write scenarios users would recognize

Scenarios describe what someone observes, not what the system does internally. For UI behavior,
order the Then-clauses the way the user perceives them — feedback paints first, then the work
kicks off ("Then the row dims immediately, and the save completes in the background").

### 7. File it

Apply the standard labels that fit (`bug`, `enhancement`, `documentation`, `question` — one or two
is typical), then create:

```
gh issue create -R w3mg/<repo> --title "<title>" --body "<body>" --label "<label>"
```

Show the user the issue URL and a one-line summary of what was filed.

## Multiple issues

If the user wants several issues, spec and file them all — batch independent ones in parallel.
Each gets its own scenarios and missing-test list; don't share one vague test list across issues.

## Listing / searching issues

To view existing issues: `gh issue list -R w3mg/<repo>`. This skill is primarily for creating
spec issues, but viewing them is a natural companion action.
