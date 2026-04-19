Hand off partial work on an issue to an Engineer. Commits selected changes to the feature branch, pushes, and posts a note on the issue.

This command runs from the **project session** (Interface), not from an Engineer worktree.

The issue number is: $ARGUMENTS

If no issue number was provided, ask for one before proceeding.

## 1. Load issue context

```bash
gh issue view $N --json number,title,milestone
```

- Extract the **milestone title** (lowercase).
- If the issue has no milestone, stop: *"Issue #{N} has no milestone. Assign one first."*

## 2. Verify there's something to hand off

```bash
git status --porcelain
```

If there are no uncommitted changes (working tree clean, nothing staged), stop: *"Nothing to hand off — working tree is clean."*

## 3. Compute names

Compute the **slug** from the issue title:
- Lowercase the title
- Replace any character that isn't `a-z`, `0-9`, or `-` with `-`
- Collapse consecutive dashes into one
- Trim leading/trailing dashes
- Truncate to 40 characters, trim any trailing dash after truncation

Compute:
- **Feature branch**: `m/{milestone}-issue-{N}-{slug}`

## 4. Save current branch

```bash
git branch --show-current
```

Save this as `{original-branch}` — you'll return to it at the end.

## 5. Create or check out the feature branch

Check if the branch exists:

```bash
git branch -a --list "{branch}" --list "remotes/origin/{branch}"
```

- **Branch exists**: `git checkout {branch}`
- **Branch doesn't exist**: `git checkout -b {branch} m/{milestone}`

If `m/{milestone}` doesn't exist locally, fetch it first.

## 6. Select files to stage

Show the changed files:

```bash
git diff --stat
git diff --cached --stat
git status --short
```

**Ask the human which files to include.** List them and let the human confirm or select. Never auto-stage everything — there may be secrets, scratch files, or unrelated changes.

If the human selects no files (or cancels), abort: *"No files selected. Handoff cancelled."* and return to the original branch.

## 7. Commit and push

Stage the selected files:

```bash
git add {selected-files...}
```

Commit with a descriptive message:

```bash
git commit -m "partial work for #{N}: {brief summary of what's included}"
```

Push:

```bash
git push -u origin {branch}
```

## 8. Post issue comment

```bash
gh issue comment $N --body "Partial work pushed to \`{branch}\`. Engineer should start from there."
```

## 9. Return to original branch

```bash
git checkout {original-branch}
```

## 10. Report

```
Handed off partial work for issue #{N}: {title}
  Branch:  {branch}
  Commit:  {short sha}
  Comment: posted on #{N}

To assign an Engineer: "Hey {name}, work on issue #{N}"
```
