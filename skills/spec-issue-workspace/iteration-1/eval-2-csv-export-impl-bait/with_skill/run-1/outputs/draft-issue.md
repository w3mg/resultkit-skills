# Draft issue (dry run — NOT filed)

**Target repo:** `w3mg/resultmaps-web-ui-2` (frontend)
**Proposed labels:** `question`, `enhancement`
**Issue title:** Users don't discover the CSV export on the measurables scorecard

## Issue body (exactly as it would be filed)

```markdown
## Problem

A request came in to add a CSV export button to the measurables scorecard. Verification against
the current app shows the scorecard already has one: the toolbar of the measurables scorecard
(Components page → Scorecard tab, and the same toolbar in the Scorecard section of a Level 10
meeting) includes a control that downloads the currently displayed measurables and date columns
as `ResultMaps-scorecard.csv`. It has been in place since early March 2026 and its CSV output is
covered by regression tests.

The problem is that the control is not being discovered. It is an icon-only button whose purpose
is conveyed only through a hover tooltip and its accessible name — nothing visible at a glance
says "export" or "CSV". Someone who works in the product daily asked for the feature as if it
didn't exist, which is direct evidence of the gap: users who want their scorecard data in a
spreadsheet and don't find the control give up, retype the data by hand, or file requests for a
feature that already shipped. An export users can't find is functionally missing.

Open question (this issue stays in problem-space on it): once the control is findable, does the
existing export actually cover the need behind the request — or is something about it (what data
it includes, which surfaces offer it) still short? If a real gap remains after the requester can
find and try it, that gap should be specced as its own issue.

## Desired behavior

### Scenario: Finding the export without prior knowledge
- **Given** a user viewing the measurables scorecard with at least one measurable, on any surface
  that shows the scorecard toolbar (Components page Scorecard tab; Level 10 meeting Scorecard
  section)
- **When** they look for a way to get the scorecard data out as a spreadsheet file
- **Then** they can identify the export control from what is visible on screen — without hovering
  to reveal a tooltip — and activating it downloads the displayed scorecard as a CSV file

## Missing tests

Each test below is missing today. For each one, in order: add the test, run it, **watch it fail
for the right reason**, then write whatever makes it pass. Do not start implementation before the
failing test exists.

1. **The scorecard export control's purpose is evident without hover** — asserts a user-visible
   indication that the control exports the scorecard (not only a hover title / accessible name),
   on both surfaces that render the scorecard toolbar. Covers Scenario: Finding the export
   without prior knowledge. Level: component. Suite: `__tests__/components/scorecard/`.
2. **A user can find and complete the export end-to-end** — drives the scorecard page, locates
   the export control by its visible purpose, activates it, and verifies a `.csv` file downloads.
   Covers Scenario: Finding the export without prior knowledge. Level: e2e. Suite: `e2e/`
   (the existing scorecard e2e spec has no export coverage today).

## Done when

Every test above exists and passes, every scenario holds, and the requester confirms the export —
now that it can be found — covers the need behind the original request. If it doesn't, the
remaining gap gets its own spec issue.
```

## Routing and verification notes (not part of the issue body)

- **Why frontend, not api2:** the requested behavior is a user-facing affordance on the scorecard
  UI. Verified current behavior shows the export is entirely client-side; no api2 route exists or
  is implicated. The "add a route in api2" suggestion in the request is an implementation sketch,
  which this skill excludes from issues — and repo routing follows the behavior's surface
  (UI → `w3mg/resultmaps-web-ui-2`).
- **Premise check (skill step 2):** the scorecard CSV export already exists on `main` — commit
  `da5076b0` ("feat(scorecard): add CSV export matching old site", 2026-03-07), with CSV
  regression tests added in `67ed76fe` (T010 date-order) and `5696684e` (#429 alignment). The
  Problem section therefore states the discoverability gap, not a missing feature.
- **"Export button component we already use on the items list":** no items-list export control
  exists in `resultmaps-web-ui-2`; that precedent exists only in the legacy Rails app. Left out
  of the body per the skill's "name the affordance gap, not a component" rule.
- **Duplicate search:** `gh issue list` on `w3mg/resultmaps-web-ui-2` ("csv export", "scorecard
  csv", "export") and `w3mg/resultmaps-api2` ("csv") — no existing issue covers this.
- **Labels:** `question` because the unmet-need portion is still exploratory (skill step 1);
  `enhancement` for the discoverability gap itself.
