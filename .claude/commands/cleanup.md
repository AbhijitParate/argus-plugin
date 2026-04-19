Remove orphaned worktrees from completed or abandoned issues.

No arguments required. Scans all worktrees matching the deterministic naming pattern.

## 1. List worktrees

```bash
git worktree list --porcelain
```

Filter for worktrees matching the pattern `worktree-issue-{N}-*` (these are Engineer build worktrees).

Ignore the main worktree and any non-Argus worktrees.

## 2. Check each candidate

For each matching worktree, extract the issue number from the path (`worktree-issue-{N}-*`).

Check the issue status:

```bash
gh issue view {N} --json state,title
```

And check for a merged PR linked to the issue:

```bash
gh pr list --search "closes:#{N}" --state merged --json number,title --limit 1
```

Categorize:
- **Safe to remove** — issue is closed AND/OR PR is merged
- **Possibly abandoned** — issue is open but no recent commits on the worktree branch
- **Active** — issue is open and in progress, skip

## 3. Present candidates

```
## Worktree cleanup

### Safe to remove (issue closed / PR merged)
- ../worktree-issue-42-fix-typo — #42 closed, PR #37 merged
- ../worktree-issue-58-auth — #58 closed, PR #51 merged

### Possibly abandoned (issue open, no recent work)
- ../worktree-issue-99-draft — #99 open, last commit 14 days ago

### Active (skipping)
- ../worktree-issue-105-api — #105 in progress

Remove safe candidates? (y/n)
```

**Never auto-delete.** Always ask for confirmation.

## 4. Remove confirmed worktrees

For each confirmed worktree:

```bash
git worktree remove {path}
```

If removal fails (uncommitted changes), report the error and skip.

## 5. Prune

After all removals:

```bash
git worktree prune
```

## 6. Report

```
Removed N worktrees. M skipped (active or declined).
```
