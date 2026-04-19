Create a GitHub Discussion for specs, ideas, or domain topics.

The topic is: $ARGUMENTS

If no arguments provided, ask what topic to discuss.

## 1. Determine the category

Parse the arguments for an explicit category prefix, or infer from context:

- `spec: {topic}` or `spec {topic}` — Specs category
- `idea: {topic}` or `idea {topic}` — Ideas category
- `domain: {topic}` or `domain {topic}` — Domain category
- `scenario: {topic}` or `scenario {topic}` — Scenarios category
- No prefix — ask the user which category fits

Available categories and their purposes:

| Category | Use for |
|----------|---------|
| Specs | What was designed vs what was built — technical specifications |
| Ideas | Feature ideas, improvements, future possibilities |
| Domain | Domain briefs — patterns, gotchas, conventions per area |
| Scenarios | Test scenarios per flow — expected outcomes, validation |

Decisions have their own skill (`/decide`) — don't create Decisions here.

## 2. Check for existing discussions

Search for duplicates in the target category:

```bash
gh api graphql -f query='{ search(query:"repo:{owner}/{repo} is:discussion category:{category} {keywords}", type:DISCUSSION, first:5) { nodes { ... on Discussion { number title url } } } }'
```

Get `{owner}` and `{repo}` from `.argus/project.json` under the `repository` key.

If a similar discussion exists, show it and ask whether to update or create new.

## 3. Draft the body

Structure depends on the category:

**Specs:** Context, Current behavior, Proposed design, Open questions
**Ideas:** Motivation, Proposal, Tradeoffs, Open questions
**Domain:** Overview, Key concepts, Constraints, Gotchas
**Scenarios:** Preconditions, Steps, Expected outcome, Failure modes

## 4. Create the Discussion

Read the category ID from `.argus/project.json` at `discussions.categories.{key}.id` where `{key}` maps as: Specs=`specs`, Ideas=`friction`, Domain=`domains`, Scenarios=`scenarios`.

Read the repository node ID from `.argus/project.json` at `repository.id`.

```bash
gh api graphql -f query='
  mutation {
    createDiscussion(input: {
      repositoryId: "{repo_id}"
      categoryId: "{category_id}"
      title: "{title}"
      body: "{body}"
    }) {
      discussion { number url }
    }
  }'
```

## 5. Report

Show the Discussion number, category, and URL.
