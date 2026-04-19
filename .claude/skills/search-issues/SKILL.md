Search GitHub Issues by keyword, milestone, label, or state.

The query is: $ARGUMENTS

## Parse the query

Extract any structured filters from the query. Filters can appear in any order, mixed with keywords:

- `milestone:{name}` — filter by milestone (e.g. `milestone:Helios`)
- `label:{name}` — filter by label (e.g. `label:scope:roles`), can appear multiple times
- `state:{open|closed|all}` — filter by state (default: `open`)
- Everything else is a keyword search term

Examples:
- `auth middleware` → keyword search for "auth middleware", open issues
- `milestone:Helios label:feature` → all open Helios features
- `role state:all` → keyword "role" across open and closed issues

## Search strategy

Use the approach that best fits the query:

**If structured filters only (milestone, label, state, no keywords):**

```bash
gh issue list --milestone "{milestone}" --label "{label}" --state {state} \
  --json number,title,state,labels,assignees --limit 30
```

**If keywords are present:**

```bash
gh search issues "{keywords}" --repo {owner}/{repo} \
  --label "{label}" --state {state} \
  --json number,title,state,labels --limit 20
```

Note: `gh search issues` doesn't support `--milestone` filtering. If both keywords and milestone are specified, search by keywords first, then filter results by milestone from issue metadata.

## Present results

Format as a compact table:

```
# | Title | State | Labels | Milestone
```

If no results, say so. If the query was ambiguous, suggest a refined search.

Keep the output concise — the caller wants to scan results quickly, not read paragraphs.
