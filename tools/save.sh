#!/usr/bin/env bash
# Save your work: commit everything and upload it to GitHub.
# Usage: tools/save.sh "what I changed"
set -euo pipefail
cd "$(dirname "$0")/.."

msg="${1:-Save $(date '+%Y-%m-%d %H:%M')}"

git add -A
if git diff --cached --quiet; then
  echo "Nothing new to save."
else
  git commit -q -m "$msg"
  echo "Saved locally: $msg"
fi

if git remote | grep -q .; then
  if git push -q -u origin HEAD; then echo "Uploaded to GitHub."; else echo "Could not upload (offline or not signed in?). Your work is safe on your computer; run this again later."; fi
else
  echo "No GitHub remote set up yet, so this save is only on your computer."
fi
