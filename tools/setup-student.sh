#!/usr/bin/env bash
# Give your copy of the project its own name and app ID, so your app installs
# next to other students' apps on a shared headset instead of overwriting them.
# Usage: tools/setup-student.sh <your-name> ["My App Title"]
set -euo pipefail
cd "$(dirname "$0")/.."

name="${1:-}"
if [[ -z "$name" ]]; then
  echo "Usage: tools/setup-student.sh <your-name> [\"My App Title\"]"
  exit 1
fi

id_part=$(echo "$name" | tr '[:upper:]' '[:lower:]' | tr -cd 'a-z0-9')
if [[ -z "$id_part" ]]; then
  echo "Name must contain letters or numbers."
  exit 1
fi
app_id="com.ixd.$id_part"
title="${2:-$name VR}"
settings="ProjectSettings/ProjectSettings.asset"

# sed -i differs between macOS and Linux/Git Bash, so write to a temp file.
sed -E \
  -e "s/^(    (Android|Standalone): )com\.[A-Za-z0-9_.]+/\1$app_id/" \
  -e "s/^  productName: .*/  productName: $title/" \
  "$settings" > "$settings.tmp" && mv "$settings.tmp" "$settings"

echo "App ID:  $app_id"
echo "Title:   $title"
echo "Close Unity before running this, then reopen the project."
echo "Next: tools/save.sh \"Set up my project\""
