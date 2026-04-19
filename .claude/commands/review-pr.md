Review another Engineer's PR — load context, evaluate against AC, post verdict.

Note: board transitions (InReview → Done on merge, or back to Ready on close) are handled by the `issue-board-sync` GitHub Action. The `pr-quality-gate` Action validates structural issues (missing "Closes #N", empty AC coverage) before you review.

The PR number is: $ARGUMENTS

If no PR number was provided, ask for one before proceeding.

## 1. Load PR context

```bash
gh pr view $N --json number,title,body,baseRefName,headRefName,url,state,mergeable,statusCheckRollup
```

Extract the linked issue number from the PR body (look for "Closes #N", "Fixes #N", or "Resolves #N").

## 2. Load issue and AC

```bash
gh issue view {issue_number} --json number,title,body,labels,comments
```

Extract the acceptance criteria from the issue body or comments. If no AC found, this is an escalation trigger — notify the Architect.

## 3. Load the diff

```bash
gh pr diff $N
```

For large diffs, scan file names first to understand scope, then read sections relevant to the AC.

## 4. Review checklist

Evaluate the PR against each criterion:

### AC coverage
For each acceptance criterion, check: does the diff implement it? Map each AC item to specific files/lines in the diff.

### Scope drift
Does the diff change anything NOT covered by the AC? Unrelated refactors, extra features, or cosmetic changes that weren't asked for.

### Correctness
Does the code do what the AC says? Look for: off-by-one errors, missing error handling at system boundaries, race conditions, null/undefined paths.

### Test coverage
Are there tests for the new behavior? Do they test the AC, not just implementation details?

## 5. Form verdict

**Approve** if:
- All AC items are covered by the diff
- No scope drift beyond trivial cleanup
- No correctness issues found
- Tests exist (or testing is impractical and noted)

**Request changes** if:
- Any AC item is not covered
- Correctness bugs found
- Significant scope drift
- Missing tests for testable behavior

## 6. Post the review

**Approve path:**

```bash
gh pr review $N --approve --body "{summary}"
```

Then verify CI is green:

```bash
gh pr checks $N
```

If CI is green, merge:

```bash
gh pr merge $N --squash --delete-branch
```

If CI is red, do NOT merge — note the failing checks and post as a request-changes instead.

**Request-changes path:**

Post inline comments on specific files/lines:

```bash
gh api repos/{owner}/{repo}/pulls/$N/reviews --method POST -f body="{summary}" -f event="REQUEST_CHANGES" -f comments='[{"path":"{file}","line":{line},"body":"{comment}"}]'
```

## 7. Report

Post status back to whoever sent the review task:
- Approve: "PR #N reviewed: approved and merged"
- Request changes: "PR #N reviewed: requesting changes (N blockers)"
