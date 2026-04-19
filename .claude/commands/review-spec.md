Validate that a GitHub issue's spec is buildable — complete enough for an Engineer to start work.

The issue number is: $ARGUMENTS

If no issue number was provided, ask for one before proceeding.

## 1. Load issue context

```bash
gh issue view $N --json number,title,body,labels,milestone,comments
```

If the issue doesn't exist, stop.

## 2. Load related context

Search for linked decisions and specs that the issue references or should reference:

```bash
gh api graphql -f query='{ search(query:"repo:{owner}/{repo} is:discussion {issue_title_keywords}", type:DISCUSSION, first:5) { nodes { ... on Discussion { number title category { name } url } } } }'
```

## 3. Evaluate the spec

Check each criterion and form an opinion:

### AC testability
For each acceptance criterion: is it a testable statement? Can an Engineer verify pass/fail?
- **Pass:** "Given X, when Y, then Z" or equivalent specific statement
- **Fail:** "Works correctly", "Handles edge cases", "Is performant"

### Scope clarity
Is the "What" section specific enough? Could two Engineers read it and build the same thing?
- **Pass:** concrete steps, named files/components, clear boundaries
- **Fail:** vague directives, multiple interpretations possible

### Decision consistency
Do the spec and any linked decisions agree? No contradictions between what the spec says and what prior decisions established?

### Dependency completeness
Are blocking issues identified? If the spec references components from other issues, are those issues linked?

### Out of scope
Is there an explicit out-of-scope section? Does it prevent the obvious scope creep vectors?

## 4. Post review

Post a structured review comment on the issue:

```bash
gh issue comment $N --body "{review_content}"
```

Format the review as:

```markdown
## Spec Review

| Criterion | Verdict | Notes |
|-----------|---------|-------|
| AC testability | PASS/FAIL | {details} |
| Scope clarity | PASS/FAIL | {details} |
| Decision consistency | PASS/FAIL | {details} |
| Dependencies | PASS/FAIL | {details} |
| Out of scope | PASS/FAIL | {details} |

**Overall: READY / NEEDS WORK**

{summary — what's good, what needs fixing}
```

## 5. Transition (if passing)

If all criteria pass, transition the issue to Ready on the project board (same mutation as `/spec-issue` step 5).

If any criterion fails, do NOT transition. The spec needs revision first.

## 6. Report

Confirm the review is posted. If READY, the issue can be handed to an Engineer. If NEEDS WORK, note what the Architect should fix.
