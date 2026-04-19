# argus-plugin

Versioned artifact bundles for [Argus](https://github.com/AbhijitParate/argus) — installed by the Argus desktop app on first project open.

## What's in a release

Each tagged release publishes a single asset: `argus-plugin-{version}.tar.gz`. Extract it and you get:

- `bundle.json` — manifest declaring the version, file list, per-file SHA-256, the `CLAUDE.md` stanza locator, and any legacy paths to clean up
- `.claude/agents/` — role files (Engineer, Manager, Architect, …)
- `.claude/commands/` — slash commands (start-issue, finish-issue, review-pr, …)
- `.claude/skills/` — skill packs
- `.claude/hooks/` — hook scripts (executable bit preserved)
- `.claude/settings.json` — hook config (merged into target's settings, not overwritten)
- `.github/workflows/` — board sync, PR gates, etc.
- `.github/ISSUE_TEMPLATE/` + `PULL_REQUEST_TEMPLATE.md`
- `ARGUS.md` — bootstrap router for member sessions
- `CLAUDE.md` — contains the `## Argus session bootstrap` stanza, extracted on install

## Who consumes this

The Argus desktop app fetches the latest release on first project open and installs the bundle into the project's working tree. See [Argus #405](https://github.com/AbhijitParate/argus/issues/405) for the install-flow spec.

## Building a release locally

```sh
scripts/build-bundle.sh 0.1.0
```

Produces `dist/argus-plugin-0.1.0.tar.gz` and prints the asset SHA-256. Upload the tarball as the release asset.

## Versioning

Semver. Breaking changes to the bundle layout (new categories, removed files, schema bumps to `bundle.json`) bump the major version; additive content bumps the minor; fixes bump the patch.
