Write a structured spec for a GitHub issue, making it ready for an Engineer to build from.

The issue number is: $ARGUMENTS

If no issue number was provided, ask for one before proceeding.

## 1. Load issue context

```bash
gh issue view $N --json number,title,body,labels,milestone,comments
```

If the issue doesn't exist, stop.

## 2. Research

Load related context to inform the spec. Use these skills as needed:

- `/search-discussions` — find related specs, decisions, prior art
- `/search-issues` — find related or blocking issues
- `/read-domain` — load domain knowledge if the issue touches a specific area
- `/read-vision` — load strategic context if the issue is scoped to a version goal

Also read relevant source code (Read, Grep, Glob) to understand what exists today.

## 3. Write the spec

Draft a structured spec with these sections:

### Context
What exists today, why this change is needed. Reference specific code, discussions, or decisions.

### What
The concrete work, broken into steps. Not "improve auth" but specific, actionable items.
Each step should be implementable by an Engineer without further clarification.

### Acceptance criteria
Testable statements in Given/When/Then or equivalent form. Each criterion must be:
- **Specific** — names the exact behavior, not "works correctly"
- **Testable** — an Engineer can verify pass/fail
- **Complete** — together they cover the full scope of the change

### Dependencies
Issues that must be complete before this one can start, if any.

### Out of scope
What this issue explicitly does NOT cover, to prevent scope creep.

## 4. Update the issue

Post the spec as a comment on the issue:

```bash
gh issue comment $N --body "{spec_content}"
```

If the issue body is a stub (just a title or one-liner from the Manager), also update the issue body with the Context and What sections:

```bash
gh issue edit $N --body "{updated_body}"
```

## 5. Transition to Ready

Move the issue to Ready on the project board. Read `.argus/project.json` for field IDs:

```bash
# Get the project item ID
gh project item-list {project_number} --owner {owner} --format json --jq ".items[] | select(.content.number == $N) | .id"
```

```bash
gh api graphql -f query='
  mutation($project: ID!, $item: ID!, $field: ID!, $value: String!) {
    updateProjectV2ItemFieldValue(input: {
      projectId: $project
      itemId: $item
      fieldId: $field
      value: { singleSelectOptionId: $value }
    }) { projectV2Item { id } }
  }' -f project="{project_node_id}" -f item="{item_id}" -f field="{status_field_id}" -f value="{ready_option_id}"
```

Note: the `issue-readiness` GitHub Action will automatically validate that the issue has AC, labels, and a real description when it lands in Ready. If anything is missing, the Action posts a comment.

## 6. Report

Confirm the spec is posted and the issue is marked Ready. Mention the issue number so the caller can notify the Manager or delegate to an Engineer.
