#!/usr/bin/env bash
# Go back to an earlier save without losing anything.
# Usage:
#   tools/restore.sh                 list recent saves
#   tools/restore.sh <number>        restore the whole project to that save
#   tools/restore.sh <number> <path> restore one file or folder from that save
# Close Unity before restoring.
set -u
cd "$(dirname "$0")/.."

saves=()
while IFS= read -r line; do
  saves+=("$line")
done < <(git log -n 20 --format='%h|%ad|%s' --date=format:'%a %d %b %H:%M')
if [ "${#saves[@]}" -eq 0 ]; then echo "No saves found yet."; exit 1; fi

if [ $# -eq 0 ]; then
  echo "Recent saves (1 is the newest):"
  i=1
  for s in "${saves[@]}"; do
    IFS='|' read -r h d m <<< "$s"
    printf "%3d  %s  %s\n" "$i" "$d" "$m"
    i=$((i+1))
  done
  echo
  echo "To restore: tools/restore.sh <number>"
  exit 0
fi

n="$1"
if ! [[ "$n" =~ ^[0-9]+$ ]] || [ "$n" -lt 1 ] || [ "$n" -gt "${#saves[@]}" ]; then
  echo "Pick a number between 1 and ${#saves[@]}. Run tools/restore.sh to see the list."
  exit 1
fi
IFS='|' read -r hash date msg <<< "${saves[$((n-1))]}"

# Keep the current state first so a restore can always be undone.
git add -A
if ! git diff --cached --quiet; then
  git commit -q -m "Auto-save before restore ($(date '+%Y-%m-%d %H:%M'))"
  echo "Your current work was saved first, so nothing is lost."
fi

if [ $# -ge 2 ]; then
  git checkout "$hash" -- "$2" || exit 1
  if git commit -q -m "Restore $2 from: $msg"; then
    echo "Restored $2 to how it was on $date."
  else
    echo "$2 is already the same as in that save, so nothing changed."
    exit 0
  fi
else
  git read-tree --reset -u "$hash" || exit 1
  git commit -q --allow-empty -m "Restore project to: $msg ($hash)"
  echo "Project restored to how it was on $date ($msg)."
fi
echo "To undo this restore, run tools/restore.sh and pick the save just below the restore."
