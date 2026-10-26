#!/usr/bin/env bash
# Double-click this file to install Git and GitHub Desktop on a Mac.
# Safe to run more than once: anything already installed is skipped.
set -u

echo "== IXD VR Starter: Mac setup =="
echo

# 1. Git (comes with Apple's Command Line Tools)
if xcode-select -p >/dev/null 2>&1; then
  echo "[ok] Git is already installed."
else
  echo "Installing Git. A window will pop up: click Install and wait for it to finish."
  xcode-select --install >/dev/null 2>&1
  until xcode-select -p >/dev/null 2>&1; do sleep 5; done
  echo "[ok] Git installed."
fi

# 2. GitHub Desktop
if [ -d "/Applications/GitHub Desktop.app" ] || [ -d "$HOME/Applications/GitHub Desktop.app" ]; then
  echo "[ok] GitHub Desktop is already installed."
else
  if [ "$(uname -m)" = "arm64" ]; then
    url="https://central.github.com/deployments/desktop/desktop/latest/darwin-arm64"
  else
    url="https://central.github.com/deployments/desktop/desktop/latest/darwin"
  fi
  tmp="$(mktemp -d)"
  echo "Downloading GitHub Desktop..."
  if curl -fL --progress-bar -o "$tmp/ghd.zip" "$url" && ditto -x -k "$tmp/ghd.zip" "$tmp"; then
    dest="/Applications"
    [ -w "$dest" ] || { dest="$HOME/Applications"; mkdir -p "$dest"; }
    rm -rf "$dest/GitHub Desktop.app"
    mv "$tmp/GitHub Desktop.app" "$dest/" && echo "[ok] GitHub Desktop installed in $dest."
  else
    echo "[!] Download failed. Get it from https://desktop.github.com and drag it to Applications."
  fi
  rm -rf "$tmp"
fi

# 3. Unity Hub
if [ -d "/Applications/Unity Hub.app" ]; then
  echo "[ok] Unity Hub is already installed."
else
  echo "[!] Unity Hub is not installed. Get it from https://unity.com/download"
fi

echo
echo "Next steps:"
echo "  1. Open GitHub Desktop and sign in with your GitHub account."
echo "  2. Clone your project repo (File > Clone repository)."
echo "  3. Open the folder in Unity Hub, then use the Team menu in Unity to save your work."
echo
read -r -p "Press Return to close this window."
