Record a design decision as a GitHub Discussion in the Decisions category.

The decision title or topic is: $ARGUMENTS

If no arguments provided, ask what decision needs recording.

## 1. Check for duplicates

Search existing decisions to avoid recording the same one twice:

```bash
gh api graphql -f query='{ search(query:"repo:{owner}/{repo} is:discussion category:Decisions {keywords}", type:DISCUSSION, first:5) { nodes { ... on Discussion { number title url } } } }'
```

Get `{owner}` and `{repo}` from `.argus/project.json` under the `repository` key.

If a similar decision already exists, show it and ask whether to update the existing one or create a new one.

## 2. Gather the decision

Ask the user (or derive from context) the four parts of a decision:

- **Context** — what situation or question prompted this decision
- **Options considered** — the alternatives evaluated, with brief tradeoffs
- **Decision** — which option was chosen and why
- **Consequences** — what follows from this choice (positive and negative)

## 3. Create the Discussion

Read the Decisions category ID from `.argus/project.json` at `discussions.categories.decisions.id`.

Read the repository node ID from `.argus/project.json` at `repository.id`.

```bash
gh api graphql -f query='
  mutation {
    createDiscussion(input: {
      repositoryId: "{repo_id}"
      categoryId: "{decisions_category_id}"
      title: "{title}"
      body: "{body}"
    }) {
      discussion { number url }
    }
  }'
```

The body should be formatted as:

```markdown
## Context
{context}

## Options considered
{options with tradeoffs}

## Decision
{chosen option and reasoning}

## Consequences
{what follows — positive and negative}
```

## 4. Link back

If this decision was prompted by a specific issue, post a comment on that issue linking to the new Discussion:

```bash
gh issue comment {issue_number} --body "Decision recorded: {discussion_url}"
```

## 5. Report

Show the Discussion number and URL so the caller can reference it.
