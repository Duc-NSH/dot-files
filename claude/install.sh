#!/usr/bin/env bash
# Symlink Claude Code user configuration from this repo into ~/.claude.
# Safe to re-run: existing correct symlinks are left alone, existing real
# files/dirs are backed up with a .bak suffix before being replaced.

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR"

link() {
  local src="$REPO_DIR/$1"
  local dst="$CLAUDE_DIR/$1"

  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "ok:      $dst"
    return
  fi

  if [ -e "$dst" ] || [ -L "$dst" ]; then
    echo "backup:  $dst -> $dst.bak"
    mv "$dst" "$dst.bak"
  fi

  ln -s "$src" "$dst"
  echo "linked:  $dst -> $src"
}

link settings.json
link rules
link skills

echo
echo "Done. Remaining manual steps on a new machine:"
echo "  1. Run 'claude' and log in (auth is per-machine)."
echo "  2. Approve plugin/marketplace installs when prompted on first launch."
