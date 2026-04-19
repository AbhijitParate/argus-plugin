Validate that a milestone's issues are ready for execution — assess spec quality, identify blockers, and suggest next actions.

Note: structural checks (missing labels, missing AC, stub descriptions) are caught automatically by the `issue-readiness` GitHub Action. This command focuses on the judgment calls: is the spec *good enough* to build from, are there hidden blockers, and what should happen next.

The milestone name is: $ARGUMENTS

If no milestone name was provided, ask for one before proceeding.

## 1. List milestone issues

```bash
gh issue list --milestone "{milestone}" --state open --json number,title,body,labels,assignees,comments --limit 50
```

Get `{owner}` and `{repo}` from `.argus/project.json` under the `repository` key.

Also fetch project board status for each issue:

```bash
gh project item-list {project_number} --owner {owner} --format json --limit 100
```

Match issues to their board status by issue URL or number.

## 2. Evaluate each issue

For each issue, check:

| Check | How | Pass |
|-------|-----|------|
| Has description | body is not empty / stub | More than a title |
| Has AC | body or comments contain "acceptance criteria" or a checklist | Testable criteria exist |
| Has size label | labels include `size:*` | Any size label present |
| Has scope label | labels include `scope:*` | Any scope label present |
| Has type label | labels include `feature`, `chore`, or `bug` | Any type label present |
| Board status | project board field | Has a status assigned |
| Blockers | comments mention "blocked" or "ESCALATION" | No unresolved blockers |

Categorize each issue:
- **Ready** — all checks pass, can be handed to an Engineer
- **Needs spec** — missing AC or description is a stub
- **Needs sizing** — missing size label
- **Needs labels** — missing scope or type labels
- **Blocked** — has unresolved blocker comments

## 3. Report

Post a structured grooming report:

```
## Milestone Groom: {milestone}

| Status | Count |
|--------|-------|
| Ready | N |
| Needs spec | N |
| Needs sizing | N |
| Needs labels | N |
| Blocked | N |

### Ready
- #N: {title} (size)

### Needs spec
- #N: {title} — missing AC
- #N: {title} — description is a stub

### Needs sizing
- #N: {title}

### Blocked
- #N: {title} — {blocker reason}

### Suggested actions
- Send #N, #N to Architect for speccing
- Add size labels to #N, #N
- Resolve blocker on #N
```

## 4. Offer to delegate

If there are issues needing specs and the caller is a Manager with access to Architects, offer to send spec tasks:

"Want me to send these to an Architect? I'll use `/search-issues` to check dependencies first."

Do not auto-delegate — wait for confirmation.
