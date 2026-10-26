#!/usr/bin/env bash
# One-time setup for students on macOS.
#   1. GitHub Desktop (includes Git)
#   2. Unity Hub
#   3. Unity editor + Android build tools (downloads in the background while you do the next steps)
#   4. Make and download your own copy of the project
#   5. Open the Meta developer page (needed to enable Developer Mode on the Quest)
# Safe to run again: anything already installed is skipped.
# Set DRY_RUN=1 to print what would happen without installing anything.
set -u

# Keep in sync with ProjectSettings/ProjectVersion.txt
UNITY_VERSION="6000.3.8f1"
UNITY_CHANGESET="1c7db571dde0"
TEMPLATE="wickedcube/IXD-VR-Starter"   # the template students copy
TOTAL=5
n=0
names=(); results=()
LOG="$(mktemp -t unity-install).log"
UNITY_PID=""

bold()   { printf '\n\033[1m%s\033[0m\n' "$*"; }
step()   { n=$((n+1)); bold "[$n/$TOTAL] $1"; }
record() { names+=("$1"); results+=("$2"); }
run()    { if [ "${DRY_RUN:-0}" = "1" ]; then echo "[dry run] $*"; else "$@"; fi; }
fail()   { echo "  Problem: $1"; }

case "$(uname -m)" in
  arm64) ARCH="arm64"; GH_PLATFORM="darwin-arm64"; HUB_DMG="UnityHubSetup-arm64.dmg" ;;
  *)     ARCH="x86_64"; GH_PLATFORM="darwin";      HUB_DMG="UnityHubSetup-x64.dmg" ;;
esac
HUB="/Applications/Unity Hub.app/Contents/MacOS/Unity Hub"
EDITOR_DIR="/Applications/Unity/Hub/Editor/$UNITY_VERSION"

bold "== IXD VR Starter: Mac setup =="
echo "This installs GitHub Desktop, Unity Hub and Unity $UNITY_VERSION with Android support."
echo "Unity is several GB, so expect 20 to 40 minutes on a good connection. Keep this window open."


# ---- 1. GitHub Desktop
step "GitHub Desktop"
gh_app=""
for dir in /Applications "$HOME/Applications"; do [ -d "$dir/GitHub Desktop.app" ] && gh_app="$dir/GitHub Desktop.app"; done
if [ -n "$gh_app" ]; then
  echo "  Already installed."; record "GitHub Desktop" "already installed"
else
  tmp="$(mktemp -d)"; target="/Applications"; [ -w "$target" ] || { target="$HOME/Applications"; mkdir -p "$target"; }
  echo "  Downloading (about 500 MB)..."
  if run curl -fL --progress-bar -o "$tmp/gh.zip" "https://central.github.com/deployments/desktop/desktop/latest/$GH_PLATFORM" \
     && run ditto -x -k "$tmp/gh.zip" "$tmp/unzipped" \
     && run rm -rf "$target/GitHub Desktop.app" \
     && run mv "$tmp/unzipped/GitHub Desktop.app" "$target/"; then
    gh_app="$target/GitHub Desktop.app"; echo "  Installed."; record "GitHub Desktop" "installed"
  else
    fail "GitHub Desktop did not install. Check your internet connection and run this again."; record "GitHub Desktop" "FAILED"
  fi
  run rm -rf "$tmp"
fi

# ---- 2. Unity Hub
step "Unity Hub"
if [ -x "$HUB" ]; then
  echo "  Already installed."; record "Unity Hub" "already installed"
else
  tmp="$(mktemp -d)"; target="/Applications"; [ -w "$target" ] || { target="$HOME/Applications"; mkdir -p "$target"; HUB="$target/Unity Hub.app/Contents/MacOS/Unity Hub"; }
  echo "  Downloading (about 170 MB)..."
  if run curl -fL --progress-bar -o "$tmp/hub.dmg" "https://public-cdn.cloud.unity3d.com/hub/prod/$HUB_DMG" \
     && run hdiutil attach -nobrowse -quiet -mountpoint "$tmp/mnt" "$tmp/hub.dmg" \
     && run ditto "$tmp/mnt/Unity Hub.app" "$target/Unity Hub.app"; then
    echo "  Installed."; record "Unity Hub" "installed"
  else
    fail "Unity Hub did not install."; record "Unity Hub" "FAILED"
  fi
  run hdiutil detach -quiet "$tmp/mnt" 2>/dev/null
  run rm -rf "$tmp"
fi

# ---- 3. Unity editor + Android modules (background)
step "Unity $UNITY_VERSION with Android support"
need_unity=1
if [ -d "$EDITOR_DIR" ]; then
  pe="$EDITOR_DIR/PlaybackEngines/AndroidPlayer"
  if [ -d "$pe/SDK" ] && [ -d "$pe/NDK" ] && [ -d "$pe/OpenJDK" ]; then
    need_unity=0; echo "  Already installed with Android support."; record "Unity $UNITY_VERSION" "already installed"
  else
    echo "  Unity is installed but is missing Android tools. Adding them in the background."
    UNITY_CMD=("$HUB" -- --headless install-modules --version "$UNITY_VERSION" -m android android-sdk-ndk-tools android-open-jdk)
  fi
else
  echo "  Downloading and installing in the background (log: $LOG)."
  UNITY_CMD=("$HUB" -- --headless install --version "$UNITY_VERSION" --changeset "$UNITY_CHANGESET" --architecture "$ARCH" -m android android-sdk-ndk-tools android-open-jdk)
fi
if [ "$need_unity" = "1" ]; then
  if [ ! -x "$HUB" ] && [ "${DRY_RUN:-0}" != "1" ]; then
    fail "Unity Hub is missing, so Unity can't be installed."; record "Unity $UNITY_VERSION" "FAILED"; need_unity=0
  elif [ "${DRY_RUN:-0}" = "1" ]; then
    echo "[dry run] ${UNITY_CMD[*]}"
  else
    "${UNITY_CMD[@]}" > "$LOG" 2>&1 &
    UNITY_PID=$!
    echo "  Started. You can keep going while it downloads."
  fi
fi

# ---- 4. Student's own copy of the project
step "Your own copy of the project"
if [ -n "${gh_app:-}" ]; then run open "$gh_app"; fi
echo "  Sign in to GitHub Desktop with your GitHub account (free). It opens now."
echo "  A GitHub page will open next. Sign in if asked, name the copy ixd-vr-<yourname>,"
echo "  choose Private, and click Create repository."
read -r -p "  Press Enter to open the page... " _
run open "https://github.com/$TEMPLATE/generate"
echo "  When your copy exists, copy its address from the browser."
read -r -p "  Paste your repo address (https://github.com/yourname/ixd-vr-yourname) or press Enter to skip: " repo
repo="${repo%.git}"; repo="${repo%/}"
if [ -z "$repo" ]; then
  record "Your project copy" "skipped (use File > Clone repository in GitHub Desktop)"
else
  case "$repo" in
    https://github.com/*/*) run open "x-github-client://openRepo/$repo"
      echo "  In GitHub Desktop, choose where to save it and click Clone."; record "Your project copy" "clone window opened" ;;
    *) echo "  That doesn't look like a GitHub address, so I skipped it."; record "Your project copy" "skipped (use File > Clone repository)" ;;
  esac
fi

# ---- 5. Meta Quest developer mode
step "Meta Quest developer mode"
echo "  To install apps on a Quest you need a free Meta developer account and Developer Mode."
echo "  The page opens next. Create an organization if asked, then turn on Developer Mode in the"
echo "  Meta Horizon phone app (Menu > Devices > your headset > Headset Settings > Developer Mode)."
read -r -p "  Press Enter to open the Meta developer page... " _
run open "https://developers.meta.com/horizon/manage"
record "Quest developer mode" "developer page opened"

# ---- wait for Unity
if [ -n "$UNITY_PID" ]; then
  bold "Waiting for the Unity download to finish..."
  echo "  (This is the slow part. Latest progress is shown below.)"
  spin='|/-\'; i=0
  while kill -0 "$UNITY_PID" 2>/dev/null; do
    last="$(tail -n 1 "$LOG" 2>/dev/null | tr -d '\r' | cut -c1-70)"
    printf '\r  %s %-72s' "${spin:i++%4:1}" "$last"
    sleep 2
  done
  printf '\r%-80s\r' ""
  wait "$UNITY_PID"; code=$?
  if [ -d "$EDITOR_DIR/PlaybackEngines/AndroidPlayer/SDK" ] && [ -d "$EDITOR_DIR/PlaybackEngines/AndroidPlayer/OpenJDK" ]; then
    echo "  Unity $UNITY_VERSION is installed."; record "Unity $UNITY_VERSION" "installed"
  else
    fail "Unity did not finish installing (exit code $code). Run this script again to resume. Details: $LOG"
    record "Unity $UNITY_VERSION" "FAILED (run again)"
  fi
fi

# ---- summary
bold "== Summary =="
i=0; while [ $i -lt ${#names[@]} ]; do printf '  %-24s %s\n' "${names[$i]}" "${results[$i]}"; i=$((i+1)); done

bold "== What to do next =="
cat <<NEXT
  1. GitHub Desktop: sign in, then clone your project copy (File > Clone repository) if you haven't yet.
  2. Unity Hub: open it, sign in with a Unity account, and activate a free Personal license
     (Preferences > Licenses > Add > Get a free personal license).
  3. In Unity Hub choose Add > Add project from disk and pick the folder you cloned. Open it
     with Unity $UNITY_VERSION. The first open takes a few minutes.
  4. In Unity: open the project, wait for the first import, and check the app's package name under
     Edit > Project Settings > Player > Other Settings. It is set for you from your GitHub account.
  5. Switch the platform to Android in File > Build Profiles. Full details are in the README.
  6. On your Quest: run Space Setup (Settings > Physical Space), connect it by USB-C cable, and
     choose Allow USB debugging in the headset.
NEXT
echo
if [ "${DRY_RUN:-0}" != "1" ]; then
  read -r -p "Open Unity Hub now? (y/N) " ans
  case "$ans" in [yY]*) open "/Applications/Unity Hub.app" 2>/dev/null || open "$HOME/Applications/Unity Hub.app" ;; esac
fi
read -r -p "Press Enter to close."
