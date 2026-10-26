#!/usr/bin/env bash
# Save a snapshot of your work (a git commit) and back it up to GitHub if possible.
# Usage: tools/save.sh ["what you changed"]
set -u
cd "$(dirname "$0")/.."

if [ -z "$(git config user.name)" ] || [ -z "$(git config user.email)" ]; then
  echo "First time setup: git needs to know who you are."
  read -r -p "Your name: " name
  read -r -p "Your email (the one on your GitHub account): " email
  git config user.name "$name"
  git config user.email "$email"
fi

msg="${1:-}"
if [ -z "$msg" ]; then
  read -r -p "Describe this save (or press Enter to skip): " msg
fi
[ -z "$msg" ] && msg="Save $(date '+%Y-%m-%d %H:%M')"

git add -A
if git diff --cached --quiet; then
  echo "Nothing new to save. Your work is already saved."
else
  git commit -q -m "$msg" && echo "Saved: $msg"
fi

if git remote | grep -q .; then
  echo "Backing up to GitHub..."
  if git push -q 2>/dev/null || git push -q -u origin HEAD 2>/dev/null; then
    echo "Backed up to GitHub."
  else
    echo "Could not reach GitHub (offline, or not signed in)."
    echo "Your work is still saved on this computer. Run this again later to back it up."
  fi
else
  echo "No GitHub copy connected yet, so this save is only on this computer."
fi
