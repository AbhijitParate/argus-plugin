Search GitHub Discussions by keyword and optional category filter.

The query is: $ARGUMENTS

## Parse the query

Extract any structured filters from the query:

- `category:{name}` — filter by Discussion category (e.g. `category:Decisions`, `category:Specs`)
- Everything else is a keyword search term

Available categories: Decisions, Specs, Ideas, Domain, Versions, Scenarios, Product

Examples:
- `role architecture` → search all categories for "role architecture"
- `auth category:Decisions` → search Decisions category for "auth"
- `category:Specs` → list all Specs discussions

## Search

Use the GitHub GraphQL search API:

```bash
gh api graphql -f query='
{
  search(
    query: "repo:{owner}/{repo} is:discussion {keywords} {category_filter}"
    type: DISCUSSION
    first: 20
  ) {
    nodes {
      ... on Discussion {
        number
        title
        category { name }
        url
        body
      }
    }
  }
}'
```

**Category filter:** if a `category:{name}` filter was specified, append `category:"{name}"` to the search query string.

**If no keywords and no category** — list recent discussions instead:

```bash
gh api graphql -f query='
{
  repository(owner: "{owner}", name: "{repo}") {
    discussions(first: 20, orderBy: {field: UPDATED_AT, direction: DESC}) {
      nodes {
        number
        title
        category { name }
        url
      }
    }
  }
}'
```

## Present results

Format as a compact table:

```
# | Title | Category | URL
```

For each result, show the first 1-2 sentences of the body as a snippet if the caller needs context to decide which to read in full.

If no results, say so and suggest alternative keywords or categories.

Keep the output concise — the caller wants to scan and pick, not read full discussions.
