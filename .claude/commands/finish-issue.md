Finish work on a tracked issue. Pushes the branch and opens a PR (round 1) or pushes updates (round 2).

Note: the board transition to In Review is handled automatically by the `issue-board-sync` GitHub Action when the PR opens.

The issue number is: $ARGUMENTS

If no issue number was provided, ask for one before proceeding.

## 1. Load issue context

```bash
gh issue view $N --json number,title,milestone,projectItems,state
```

- Extract the **milestone title** (lowercase).
- If the issue has no milestone, stop: *"Issue #{N} has no milestone. Can't determine the target branch."*

## 2. Compute names

Compute the **slug** from the issue title:
- Lowercase the title
- Replace any character that isn't `a-z`, `0-9`, or `-` with `-`
- Collapse consecutive dashes into one
- Trim leading/trailing dashes
- Truncate to 40 characters, trim any trailing dash after truncation

Compute:
- **Feature branch**: `m/{milestone}-issue-{N}-{slug}`
- **Milestone branch**: `m/{milestone}`

## 3. Verify current branch

```bash
git branch --show-current
```

If the current branch does **not** match the expected feature branch, stop: *"You're on '{current}', expected '{feature-branch}'. cd into the correct worktree or run /start-issue {N} first."*

## 4. Push the branch

```bash
git push -u origin {branch}
```

## 5. Open PR or report push (round detection)

Check if a PR already exists for this branch:

```bash
gh pr list --head {branch} --json number,url --jq '.[0]'
```

**Round 1 (no existing PR):**

Read the issue's acceptance criteria from the issue body or comments.

Open a new PR targeting the milestone branch, populating the PR template:

```bash
gh pr create \
  --base m/{milestone} \
  --title "{issue title}" \
  --body "## Closes #{N}

## What changed

{brief summary of the diff — what was added/changed/removed}

## AC coverage

{for each AC item from the issue, create a checkbox}
- [ ] {AC item 1}
- [ ] {AC item 2}

## Test plan

{how it was verified}

## Notes for reviewer

{any tradeoffs or open questions, or 'None'}
"
```

**Round 2 (PR already exists):**

Skip PR creation. The push already updated the PR.

## 6. Report

**Round 1:**
```
Finished issue #{N}: {title}
  PR:     {pr-url}
  Target: m/{milestone}
  Status: In Review
```

**Round 2:**
```
Pushed updates to issue #{N}: {title}
  PR: {existing-pr-url}
  (Round 2 — issue stays In Review)
```
