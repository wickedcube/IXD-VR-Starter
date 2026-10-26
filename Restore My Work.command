#!/usr/bin/env bash
# Double-click to see earlier saves and go back to one. Close Unity first.
cd "$(dirname "$0")" && ./tools/restore.sh
echo
read -r -p "Type the number to restore (or press Enter to cancel): " n
[ -n "$n" ] && ./tools/restore.sh "$n"
echo; read -r -p "Press Enter to close."
