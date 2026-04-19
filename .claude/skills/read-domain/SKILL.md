Load domain knowledge from the Domain category in GitHub Discussions.

The query is: $ARGUMENTS

If no arguments provided, list all available domain briefs.

## 1. Search or list

**If a keyword or domain name is provided:**

```bash
gh api graphql -f query='{ search(query:"repo:{owner}/{repo} is:discussion category:Domain {keywords}", type:DISCUSSION, first:5) { nodes { ... on Discussion { number title body url } } } }'
```

**If no arguments — list all domain briefs:**

```bash
gh api graphql -f query='{ search(query:"repo:{owner}/{repo} is:discussion category:Domain", type:DISCUSSION, first:20) { nodes { ... on Discussion { number title url } } } }'
```

Get `{owner}` and `{repo}` from `.argus/project.json` under the `repository` key, or fall back to parsing the git remote.

## 2. Present results

**For a keyword search:** read the matching Discussion body and present the domain context as a structured summary — definitions, constraints, key concepts, boundaries. This is reference material for speccing, not a document to skim.

**For a listing:** show a compact table of available domain briefs:

```
# | Title | URL
```

If no domain briefs exist in the Domain category, say so — the project may not have documented domain knowledge yet.
