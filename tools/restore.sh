#!/usr/bin/env bash
# Go back to an earlier save without losing anything.
#   tools/restore.sh            list recent saves
#   tools/restore.sh <id>       make the project look like save <id>
# Your current work is saved first, and the restore becomes a new save,
# so you can always undo it by restoring the save you came from.
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ $# -eq 0 ]]; then
  echo "Recent saves (newest first). Pick an id from the first column:"
  git log -n 20 --date=format:'%a %d %b %H:%M' --pretty=format:'%h  %ad  %s'
  echo
  echo
  echo "Then run: tools/restore.sh <id>"
  exit 0
fi

target="$1"
git rev-parse --verify -q "$target^{commit}" >/dev/null || { echo "No save with id '$target'."; exit 1; }

echo "Close Unity first. Press Enter to continue, Ctrl+C to cancel."
read -r

git add -A
git diff --cached --quiet || git commit -q -m "Auto-save before restoring $target"

git restore --source="$target" --staged --worktree -- .
git add -A
git commit -q -m "Restore project to $target" || echo "Already identical to $target."
echo "Restored to $target. Reopen Unity."
