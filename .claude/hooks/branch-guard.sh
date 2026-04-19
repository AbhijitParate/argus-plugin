#!/usr/bin/env bash
#
# branch-guard.sh — PreToolUse hook that blocks file edits on protected
# branches (main, dev, bare milestone branches). Only allows edits on
# feature branches matching m/{milestone}-issue-{N}-*.
#
# Scoping: if ARGUS_MEMBER is not set, the hook allows everything
# (Interface sessions edit on dev freely). When ARGUS_MEMBER is set
# (bounded-role sessions spawned by the desktop app), the guard enforces.
#
set -euo pipefail

# If not a bounded-role session, allow everything
if [ -z "${ARGUS_MEMBER:-}" ]; then
  exit 0
fi

# Read hook input from stdin, extract cwd
INPUT=$(cat)
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

if [ -z "$CWD" ]; then
  # Can't determine working directory — allow to avoid false blocks
  exit 0
fi

# Get current branch
BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null || true)

if [ -z "$BRANCH" ]; then
  # Detached HEAD or not a git repo — allow
  exit 0
fi

# Allow: feature branches (m/{milestone}-issue-{N}-{slug})
if echo "$BRANCH" | grep -qE '^m/[a-z]+-issue-[0-9]+-'; then
  exit 0
fi

# Block: main, dev, or bare milestone branches (m/{name} without -issue-)
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "dev" ] || echo "$BRANCH" | grep -qE '^m/[a-z]+$'; then
  echo "Branch guard: you're on '$BRANCH', which is a protected branch. Run /start-issue {N} first to create a feature branch and worktree." >&2
  exit 2
fi

# Any other branch — allow (user-created branches, etc.)
exit 0
