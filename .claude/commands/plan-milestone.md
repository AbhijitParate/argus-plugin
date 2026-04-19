Break a version goal into a structured milestone with issues on GitHub.

The milestone name is: $ARGUMENTS

If no milestone name was provided, ask for one before proceeding.

## 1. Load strategic context

Use these skills to build understanding of what this milestone should deliver:

- `/read-vision` with the milestone name — loads Vision, Roadmap, and version Discussion
- `/search-discussions` with the milestone name — finds related specs and decisions
- `/search-issues` with `milestone:{name} state:all` — finds existing issues (avoid duplicates)

Also read the milestone description if it exists:

```bash
gh api repos/{owner}/{repo}/milestones --jq '.[] | select(.title=="{milestone}") | .description'
```

Get `{owner}` and `{repo}` from `.argus/project.json` under the `repository` key.

## 2. Draft the plan

Break the goal into issues. For each proposed issue:

- **Title** — short, actionable (e.g. "Add token-refresh middleware")
- **Description** — enough context for an Architect to spec (2-3 sentences)
- **Labels** — `scope:{area}` + type (`feature`, `chore`, or `bug`) + `v:{version}`
- **Size** — XS (trivial), S (single file), M (multi-file), L (cross-component), XL (needs further breakdown)
- **Dependencies** — which other proposed issues must finish first, if any

Guidelines:
- Each issue should be completable by one Engineer in one session
- Minimize dependencies — parallel work is faster
- XL issues should be broken down further

## 3. Present for approval

Present the plan to the human via `send_message` (if in a member session) or directly (if Interface). Structured as a numbered list with titles, sizes, and dependency notes.

Wait for the human to approve, request changes, or reject.

If changes requested, revise and re-present.

## 4. Create issues

Once approved, create each issue:

```bash
gh issue create --title "{title}" --body "{description}" --milestone "{milestone}" --label "{labels}" --assignee ""
```

Then add each issue to the project board in Backlog status. Read project board IDs from `.argus/project.json`:

```bash
gh project item-add {project_number} --owner {owner} --url {issue_url}
```

## 5. Create milestone branch

Check if the milestone branch exists:

```bash
git branch -a --list "m/{milestone}" --list "remotes/origin/m/{milestone}"
```

If not, read the integration branch from `.argus/project.json` (usually `dev`) and create:

```bash
git branch "m/{milestone}" {integration_branch}
git push -u origin "m/{milestone}"
```

## 6. Report

List all created issues with numbers, titles, and sizes. Note the milestone branch name. Suggest next steps: "groom with `/groom-milestone`" or "send issues to Architect for speccing."
