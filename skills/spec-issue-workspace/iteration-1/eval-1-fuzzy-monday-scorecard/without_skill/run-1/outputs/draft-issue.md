# Draft GitHub Issue

**Target repo:** resultmaps-web-ui-2

**Proposed labels:** `bug`, `scorecard`, `needs-investigation`

---

## Issue Title

Team scorecard shows stale values on Mondays until manually refreshed

## Issue Body

### Problem

Team members report that scorecard values they updated on Friday are not reflected on the team scorecard the following Monday. The stale values persist until someone manually triggers a refresh (by navigating, reloading, or otherwise "poking" the view). After that poke, the values appear correctly.

This is a trust problem: contributors who update their numbers on Friday have no reason to know they aren't showing, and teammates reviewing the scorecard Monday morning are seeing outdated data.

### Observed behavior

- User updates their individual scorecard value on Friday
- On Monday morning, the team scorecard still displays last week's values
- After some manual interaction (e.g., navigating away and back, hard reload, or editing any value), the correct values appear
- The problem is consistent enough that the team has come to expect it every Monday

### Expected behavior

The team scorecard should reflect the most recently saved values at all times, including across weekend boundaries, without requiring any manual trigger.

### What we don't know yet

The root cause is unknown. Possible areas to investigate:

1. **Stale cache** — client-side or server-side cache that is not invalidated after a scorecard write, or that has a TTL long enough to span a weekend
2. **Data-fetching strategy** — the team scorecard view may not be re-fetching on mount if the route is treated as already-loaded (e.g., Next.js RSC cache, React Query stale-while-revalidate with a long `staleTime`, or SWR with `revalidateOnFocus: false`)
3. **Write path gap** — the individual scorecard write may be succeeding locally but not propagating to whatever aggregate the team scorecard reads from (e.g., a denormalized team rollup that requires a separate update or background job)
4. **Time-zone or week-boundary logic** — if the scorecard aggregation logic uses ISO week or local-date arithmetic, a Friday write near midnight could be bucketed into the wrong week depending on timezone

### Steps to reproduce (as reported)

1. Update one or more scorecard values on a Friday
2. Confirm the values appear correct in your own view on Friday
3. Return Monday morning and view the team scorecard
4. Observe that the Friday values are not shown
5. Perform any navigation or interaction — values now appear correct

### Impact

- Affects all team members who use the team scorecard on Monday mornings
- Reduces confidence in scorecard data accuracy
- May cause teams to re-enter values that were already saved

### Investigation starting points

- Check the data-fetching call in the team scorecard view: is it set to revalidate on mount/focus? What is its cache TTL?
- Check whether individual scorecard writes also update any team-level aggregate or trigger a cache invalidation
- Reproduce by updating a value late in the week and observing team scorecard behavior the next business day (or by simulating with a time-offset test)
- Check API response headers for cache-control directives on the team scorecard endpoint
