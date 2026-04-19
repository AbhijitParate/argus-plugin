#!/usr/bin/env bash
#
# build-bundle.sh — pack the canonical artifact tree into a release asset.
#
# Usage: scripts/build-bundle.sh <version>
# Example: scripts/build-bundle.sh 0.1.0
#
# Output:
#   dist/argus-plugin-<version>/        — staging directory
#   dist/argus-plugin-<version>/bundle.json
#   dist/argus-plugin-<version>.tar.gz   — release asset (tarball root has bundle.json + categories)
#
# Tarball layout (root-level, no wrapper directory) — the install engine
# extracts straight into the project's working tree:
#   bundle.json
#   .claude/{agents,commands,skills,hooks,settings.json}
#   .github/{workflows,ISSUE_TEMPLATE,PULL_REQUEST_TEMPLATE.md}
#   ARGUS.md
#   CLAUDE.md
#
set -euo pipefail

VERSION="${1:-}"
if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>" >&2
  exit 1
fi

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DIST="$ROOT/dist"
STAGE="$DIST/argus-plugin-$VERSION"

rm -rf "$DIST"
mkdir -p "$STAGE"

# Copy the 9 categories from repo root → staging (mirror layout).
for path in \
  ".claude/agents" \
  ".claude/commands" \
  ".claude/skills" \
  ".claude/hooks" \
  ".claude/settings.json" \
  ".github/workflows" \
  ".github/ISSUE_TEMPLATE" \
  ".github/PULL_REQUEST_TEMPLATE.md" \
  "ARGUS.md" \
  "CLAUDE.md" \
; do
  src="$ROOT/$path"
  if [ ! -e "$src" ]; then
    echo "warn: source missing, skipping: $path" >&2
    continue
  fi
  mkdir -p "$STAGE/$(dirname "$path")"
  cp -R "$src" "$STAGE/$path"
done

# bundle.json: every staged file (NOT bundle.json itself), sorted, with sha256.
NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
TMP_FILES_JSON="$(mktemp)"
trap 'rm -f "$TMP_FILES_JSON"' EXIT

(
  cd "$STAGE"
  find .claude .github ARGUS.md CLAUDE.md -type f 2>/dev/null | LC_ALL=C sort | while IFS= read -r f; do
    hash="$(shasum -a 256 "$f" | awk '{print $1}')"
    printf '    {"path": "%s", "sha256": "%s"}\n' "$f" "$hash"
  done | paste -sd, -
) > "$TMP_FILES_JSON"

cat > "$STAGE/bundle.json" <<EOF
{
  "version": "$VERSION",
  "created_at": "$NOW",
  "files": [
$(cat "$TMP_FILES_JSON")
  ],
  "stanza": { "file": "CLAUDE.md", "header": "## Argus session bootstrap" },
  "legacy_paths_to_remove": [
    ".claude/roles",
    ".claude/agent-protocol.md",
    ".claude/commands/argus.md"
  ]
}
EOF

# Validate bundle.json parses
if ! python3 -m json.tool "$STAGE/bundle.json" > /dev/null 2>&1; then
  echo "error: bundle.json is not valid JSON" >&2
  cat "$STAGE/bundle.json" >&2
  exit 1
fi

# Pack tarball with no wrapper directory (BSD tar on macOS uses -C to chdir).
ASSET="$DIST/argus-plugin-$VERSION.tar.gz"
tar -C "$STAGE" -czf "$ASSET" bundle.json .claude .github ARGUS.md CLAUDE.md

# Print the asset's SHA-256 for the release pin.
ASSET_SHA="$(shasum -a 256 "$ASSET" | awk '{print $1}')"
echo
echo "asset:  $ASSET"
echo "sha256: $ASSET_SHA"
echo
echo "files in bundle: $(jq '.files | length' "$STAGE/bundle.json")"
