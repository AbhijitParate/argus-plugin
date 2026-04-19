Load strategic context: Vision, Roadmap, and the active version Discussion.

Optional argument: $ARGUMENTS (a version name like "Helios" — defaults to active milestone)

## 1. Determine the version

If `$ARGUMENTS` names a version (e.g. "Helios"), use that as the search term.
Otherwise, read `.argus/project.json` to find the active or upcoming milestone title.

## 2. Read project config

Read `.argus/project.json` to get:
- `{owner}` and `{repo}` from the `owner` and `repo` keys
- Vision discussion number from `discussions.strategic.vision.number`
- Roadmap discussion number from `discussions.strategic.roadmap.number`

If the strategic discussion numbers are not configured, search for them by title in the Product category instead.

## 3. Fetch the three strategic documents

Read these GitHub Discussions in parallel:

**Vision:**
```bash
gh api graphql -f query='{ repository(owner:"{owner}", name:"{repo}") { discussion(number:{vision_number}) { title body } } }'
```

**Roadmap:**
```bash
gh api graphql -f query='{ repository(owner:"{owner}", name:"{repo}") { discussion(number:{roadmap_number}) { title body } } }'
```

**Version Discussion** (search by version name):
```bash
gh api graphql -f query='{ search(query:"repo:{owner}/{repo} is:discussion category:Versions {version_name}", type:DISCUSSION, first:1) { nodes { ... on Discussion { number title body } } } }'
```

## 4. Present a summary

For each document, extract the key points:

- **Vision** — what the product is, who it's for, where it's headed
- **Roadmap** — which features land in which version, the progression
- **Version** — what's in scope for this version, its goals, what's NOT in scope

Present as a concise structured summary — not the raw Discussion body. The caller is loading context for planning or speccing, not reading the document itself.

If a Discussion is missing or empty, note it and continue with what's available.
