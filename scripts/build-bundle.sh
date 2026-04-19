#!/usr/bin/env bash
#
# build-bundle.sh — pack the canonical artifact tree into a release asset.
#
# Usage: scripts/build-bundle.sh <version>
# Example: scripts/build-bundle.sh 0.2.0
#
# Output:
#   dist/argus-plugin-<version>/        — staging directory
#   dist/argus-plugin-<version>/bundle.json
#   dist/argus-plugin-<version>.tar.gz   — release asset
#
# Tarball layout (root-level, no wrapper directory) — the install engine
# extracts straight into the project's working tree:
#   bundle.json
#   .claude/{agents,commands,skills,hooks,settings.json}
#   .github/{workflows,ISSUE_TEMPLATE,PULL_REQUEST_TEMPLATE.md}
#   ARGUS.md
#   CLAUDE.md
#
# bundle.json schema (v0.2.0+, argus#418):
#   files[].mode = "exact" | "stanza" | "hooks-merge" (default: "exact")
#   files[].sha256 = SHA-256 of the **canonical region for that mode**:
#     - exact       → full file bytes
#     - stanza      → bytes from the `stanza.header` line up to (not
#                     including) the next `## ` header (or EOF), trailing
#                     newline included on each captured line
#     - hooks-merge → canonicalized JSON subtree at top-level `merge.key`,
#                     produced via `jq -cS '<key>'` (sorted keys, compact,
#                     no trailing newline). The Argus desktop side uses
#                     `serde_json::to_vec` which produces byte-identical
#                     output (default Map = BTreeMap when preserve_order
#                     is off). A test on the desktop side verifies the
#                     parity continuously.
#   files[].stanza.header — required when mode == "stanza"
#   files[].merge.key     — required when mode == "hooks-merge"
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

# Stanza extraction (matches deploy.sh's awk rule + Argus desktop's
# `bundle::extract_stanza_region`). Output to stdout; caller pipes to shasum.
STANZA_HEADER="## Argus session bootstrap"
extract_stanza() {
  awk -v hdr="$STANZA_HEADER" '
    $0 == hdr { in_stanza = 1 }
    in_stanza && /^## / && $0 != hdr { exit }
    in_stanza { print }
  ' "$1"
}

# Per-file mode + sha. Hard-coded mapping (fewer files than a config file
# would justify; readable at a glance):
#   .claude/settings.json → hooks-merge (key=hooks)
#   CLAUDE.md             → stanza (header=## Argus session bootstrap)
#   everything else       → exact
mode_for() {
  case "$1" in
    .claude/settings.json) echo "hooks-merge" ;;
    CLAUDE.md)             echo "stanza" ;;
    *)                     echo "exact" ;;
  esac
}

NOW="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
TMP_FILES_JSON="$(mktemp)"
trap 'rm -f "$TMP_FILES_JSON"' EXIT

(
  cd "$STAGE"
  find .claude .github ARGUS.md CLAUDE.md -type f 2>/dev/null | LC_ALL=C sort | while IFS= read -r f; do
    mode="$(mode_for "$f")"
    case "$mode" in
      exact)
        sha="$(shasum -a 256 "$f" | awk '{print $1}')"
        printf '    {"path": "%s", "sha256": "%s", "mode": "exact"}\n' "$f" "$sha"
        ;;
      stanza)
        # Canonical region = stanza block. Hash the extracted text directly.
        sha="$(extract_stanza "$f" | shasum -a 256 | awk '{print $1}')"
        printf '    {"path": "%s", "sha256": "%s", "mode": "stanza", "stanza": {"header": "%s"}}\n' \
          "$f" "$sha" "$STANZA_HEADER"
        ;;
      hooks-merge)
        # Canonical region = canonicalized hooks subtree. `jq -cS '.hooks'`
        # emits sorted-key compact JSON; tr -d '\n' strips jq's trailing
        # newline so the hash matches Rust's serde_json::to_vec output
        # byte-for-byte.
        sha="$(jq -cS '.hooks' "$f" | tr -d '\n' | shasum -a 256 | awk '{print $1}')"
        printf '    {"path": "%s", "sha256": "%s", "mode": "hooks-merge", "merge": {"key": "hooks"}}\n' \
          "$f" "$sha"
        ;;
    esac
  done | paste -sd, -
) > "$TMP_FILES_JSON"

cat > "$STAGE/bundle.json" <<EOF
{
  "version": "$VERSION",
  "created_at": "$NOW",
  "files": [
$(cat "$TMP_FILES_JSON")
  ],
  "stanza": { "file": "CLAUDE.md", "header": "$STANZA_HEADER" },
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
echo "modes: $(jq -r '.files | group_by(.mode) | map({(.[0].mode): length}) | add' "$STAGE/bundle.json")"
