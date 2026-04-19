Start work on a tracked issue. Creates the feature branch, worktree, and transitions the issue to In Progress.

The issue number is: $ARGUMENTS

If no issue number was provided, ask for one before proceeding.

## 1. Load issue context

```bash
gh issue view $N --json number,title,milestone,projectItems,state,labels
```

- If the issue doesn't exist, stop and report the error.
- Extract the **milestone title** (lowercase) — this is `{milestone}` in branch names.
- If the issue has no milestone, stop: *"Issue #{N} has no milestone assigned. Assign one first."*

## 2. Check project board status

From the `projectItems` field, find the item in Project #13 and read its Status field.

- If the status is **not** `Ready`, stop: *"Issue #{N} is '{current status}', not Ready. It must be in Ready before starting work."*
- If the issue has no project item, warn but continue (the transition step will be skipped).

## 3. Compute names

Compute the **slug** from the issue title:
- Lowercase the title
- Replace any character that isn't `a-z`, `0-9`, or `-` with `-`
- Collapse consecutive dashes into one
- Trim leading/trailing dashes
- Truncate to 40 characters, trim any trailing dash after truncation

Compute:
- **Feature branch**: `m/{milestone}-issue-{N}-{slug}`
- **Worktree path**: `../worktree-issue-{N}-{slug}` (relative to repo root)

## 4. Create or reuse worktree + branch

First, check if the worktree already exists:

```bash
git worktree list --porcelain
```

**If worktree path already exists:**
- `cd` into it
- Verify the checked-out branch matches the expected feature branch
- If it does, report reuse: *"Worktree already exists at {path}, branch {branch}."*
- If the branch doesn't match, stop and report the conflict

**If worktree doesn't exist, check if the branch exists:**

```bash
git branch -a --list "{branch}" --list "remotes/origin/{branch}"
```

- **Branch exists** (handoff case): `git worktree add {worktree-path} {branch}`
- **Branch doesn't exist**: `git worktree add -b {branch} {worktree-path} m/{milestone}`

If `m/{milestone}` doesn't exist locally, fetch and track it first:
```bash
git fetch origin m/{milestone}:m/{milestone}
```

## 5. Transition issue to In Progress

Only if the issue has a project item and is currently `Ready`.

Read project metadata from `.argus/project.json` in the repo root:
- `project.number` — the GitHub Project number
- `project.node_id` — the project ID for `gh project item-edit --project-id`
- `fields.status.field_id` — the Status field ID
- `fields.status.options.in_progress.id` — the option ID for "In progress"
- `owner` — the GitHub owner

```bash
# Get the project item ID
gh project item-list {project.number} --owner {owner} --format json --jq ".items[] | select(.content.number == $N) | .id"
```

Then transition:
```bash
gh project item-edit --project-id {project.node_id} --id {item-id} --field-id {fields.status.field_id} --single-select-option-id {fields.status.options.in_progress.id}
```

## 6. Report

Print a summary:

```
Started issue #{N}: {title}
  Branch:   {branch}
  Worktree: {worktree-path}
  Status:   In Progress

cd {worktree-path} to start building.
```
