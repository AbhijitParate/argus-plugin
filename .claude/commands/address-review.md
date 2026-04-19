Set up a round-2 build from PR review comments. Fetches the review digest, prepares the worktree, and prints the feedback into your context.

The PR number is: $ARGUMENTS

If no PR number was provided, ask for one before proceeding.

## 1. Load PR context

```bash
gh pr view $PR --json number,body,headRefName,url
```

## 2. Extract linked issue

Parse the PR body for a `Closes #N` or `Fixes #N` link (case-insensitive). Extract `N`.

If no linked issue is found, stop: *"PR #{PR} has no 'Closes #N' link in the body. Can't determine the linked issue."*

Then load the issue:

```bash
gh issue view $N --json number,title,milestone
```

## 3. Fetch review comments

Fetch **review-level comments** (summary verdicts):

```bash
gh pr view $PR --json reviews --jq '.reviews[] | {author: .author.login, state: .state, body: .body}'
```

Fetch **inline comments** (file/line-level feedback). Read `owner` and `repo` from `.argus/project.json` in the repo root:

```bash
gh api repos/{owner}/{repo}/pulls/{PR}/comments --jq '.[] | {path: .path, line: .line, author: .user.login, body: .body, created_at: .created_at}'
```

## 4. Format the review digest

Print a readable digest grouped by file:

```
## Review digest for PR #{PR}

### Summary reviews
- @{reviewer} ({state}): {body}

### Inline comments

**{file-path}** (line {line})
@{reviewer}: {comment body}

**{file-path}** (line {line})
@{reviewer}: {comment body}

---
{count} inline comments, {count} summary reviews
```

If there are no comments at all, report: *"PR #{PR} has no review comments yet."* and stop.

## 5. Set up worktree

Compute the **slug** from the issue title:
- Lowercase the title
- Replace any character that isn't `a-z`, `0-9`, or `-` with `-`
- Collapse consecutive dashes into one
- Trim leading/trailing dashes
- Truncate to 40 characters, trim any trailing dash after truncation

Compute:
- **Feature branch**: `m/{milestone}-issue-{N}-{slug}`
- **Worktree path**: `../worktree-issue-{N}-{slug}`

Check if the worktree already exists (`git worktree list --porcelain`):
- **Exists**: `cd` into it, `git pull` to get latest
- **Doesn't exist**: `git worktree add {worktree-path} {branch}`

## 6. Report

```
Ready for round 2 on issue #{N}: {title}
  Worktree: {worktree-path}
  Branch:   {branch}

Address the comments above, then run /finish-issue {N} when done.
```

Do **not** transition the issue — it stays in In Review for the entire multi-round cycle.
