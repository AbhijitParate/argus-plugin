Report structured progress on a milestone — issues by status, blockers, completion percentage.

The milestone name is: $ARGUMENTS

If no milestone name was provided, ask for one before proceeding.

## 1. Fetch milestone issues

```bash
gh issue list --milestone "{milestone}" --state all --json number,title,state,labels,assignees --limit 50
```

Get `{owner}` and `{repo}` from `.argus/project.json` under the `repository` key.

## 2. Fetch board status

```bash
gh project item-list {project_number} --owner {owner} --format json --limit 100
```

Match each issue to its board status. Categorize into:
- **Backlog** — not started, may need spec
- **Ready** — specced, waiting for an Engineer
- **In Progress** — Engineer is building
- **In Review** — PR open, awaiting review
- **Done** — PR merged, issue closed

## 3. Report

```
## Milestone: {milestone}

Progress: {done_count}/{total_count} ({percentage}%)

| Status | Count | Issues |
|--------|-------|--------|
| Done | N | #1, #2, #3 |
| In Review | N | #4 |
| In Progress | N | #5 |
| Ready | N | #6, #7 |
| Backlog | N | #8 |

### In flight
- #5: {title} — assigned to {assignee}, in progress
- #4: {title} — PR open, awaiting review

### Blocked
- #N: {title} — {reason}

### Missing AC
- #N: {title} — needs spec before it can move to Ready
```

If there are no blocked or missing-AC issues, omit those sections.

## 4. Summary line

End with a one-line assessment:

- "On track — N of M done, no blockers"
- "At risk — N blocked, M need specs before Engineers can start"
- "Stalled — no issues in progress or review"
