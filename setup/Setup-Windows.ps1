# One-time setup for students on Windows.
#   1. GitHub Desktop (includes Git)
#   2. Unity Hub
#   3. Unity editor + Android build tools (downloads in the background while you do the next steps)
#   4. Make and download your own copy of the project
#   5. Open the Meta developer page (needed to enable Developer Mode on the Quest)
# Safe to run again: anything already installed is skipped.
# Set $env:DRY_RUN = "1" to print what would happen without installing anything.
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"   # makes Invoke-WebRequest much faster
$dry = $env:DRY_RUN -eq "1"

# Keep in sync with ProjectSettings/ProjectVersion.txt
$UnityVersion = "6000.3.8f1"
$UnityChangeset = "1c7db571dde0"
$Template = "wickedcube/IXD-VR-Starter"   # the template students copy
$Total = 5
$script:n = 0
$results = New-Object System.Collections.Generic.List[string]

function Step($title) { $script:n++; Write-Host "`n[$($script:n)/$Total] $title" -ForegroundColor Cyan }
function Record($name, $result) { $results.Add(("  {0,-24} {1}" -f $name, $result)) }
function Problem($msg) { Write-Host "  Problem: $msg" -ForegroundColor Yellow }
function Download($url, $out, $label) {
    Write-Host "  Downloading $label..."
    if ($dry) { Write-Host "  [dry run] download $url"; return $true }
    try { Invoke-WebRequest -Uri $url -OutFile $out; return $true } catch { return $false }
}

$ghExe     = Join-Path $env:LOCALAPPDATA "GitHubDesktop\GitHubDesktop.exe"
$hubExe    = Join-Path $env:ProgramFiles "Unity Hub\Unity Hub.exe"
$editorDir = Join-Path $env:ProgramFiles "Unity\Hub\Editor\$UnityVersion"
$androidPE = Join-Path $editorDir "Editor\Data\PlaybackEngines\AndroidPlayer"

Write-Host "`n== IXD VR Starter: Windows setup ==" -ForegroundColor Cyan
Write-Host "This installs GitHub Desktop, Unity Hub and Unity $UnityVersion with Android support."
Write-Host "Unity is several GB, so expect 20 to 40 minutes on a good connection. Keep this window open."
Write-Host "Windows may ask for permission (administrator) a few times. Click Yes."

# ---- 1. GitHub Desktop
Step "GitHub Desktop"
if (Test-Path $ghExe) {
    Write-Host "  Already installed."; Record "GitHub Desktop" "already installed"
} else {
    $ok = $false
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "  Installing with winget..."
        if ($dry) { Write-Host "  [dry run] winget install --id GitHub.GitHubDesktop -e"; $ok = $true }
        else { winget install --id GitHub.GitHubDesktop -e --accept-package-agreements --accept-source-agreements; $ok = Test-Path $ghExe }
    }
    if (-not $ok) {
        $tmp = Join-Path $env:TEMP "GitHubDesktopSetup.exe"
        if (Download "https://central.github.com/deployments/desktop/desktop/latest/win32" $tmp "GitHub Desktop (about 270 MB)") {
            if (-not $dry) { Start-Process -FilePath $tmp -Wait }
            $ok = $dry -or (Test-Path $ghExe)
        }
    }
    if ($ok) { Write-Host "  Installed."; Record "GitHub Desktop" "installed" }
    else { Problem "GitHub Desktop did not install. Check your internet connection and run this again."; Record "GitHub Desktop" "FAILED" }
}

# ---- 2. Unity Hub
Step "Unity Hub"
if (Test-Path $hubExe) {
    Write-Host "  Already installed."; Record "Unity Hub" "already installed"
} else {
    $ok = $false
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-Host "  Installing with winget..."
        if ($dry) { Write-Host "  [dry run] winget install --id Unity.UnityHub -e"; $ok = $true }
        else { winget install --id Unity.UnityHub -e --accept-package-agreements --accept-source-agreements; $ok = Test-Path $hubExe }
    }
    if (-not $ok) {
        $tmp = Join-Path $env:TEMP "UnityHubSetup.exe"
        $arch = if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") { "arm64" } else { "x64" }
        if (Download "https://public-cdn.cloud.unity3d.com/hub/prod/UnityHubSetup-$arch.exe" $tmp "Unity Hub (about 190 MB)") {
            if (-not $dry) { Start-Process -FilePath $tmp -ArgumentList "/S" -Wait }
            $ok = $dry -or (Test-Path $hubExe)
        }
    }
    if ($ok) { Write-Host "  Installed."; Record "Unity Hub" "installed" }
    else { Problem "Unity Hub did not install."; Record "Unity Hub" "FAILED" }
}

# ---- 3. Unity editor + Android modules (background)
Step "Unity $UnityVersion with Android support"
$unityProc = $null
$logOut = Join-Path $env:TEMP "unity-install.log"
$logErr = Join-Path $env:TEMP "unity-install-err.log"
$needUnity = $true
$hubArgs = $null
if ((Test-Path $editorDir) -and (Test-Path "$androidPE\SDK") -and (Test-Path "$androidPE\NDK") -and (Test-Path "$androidPE\OpenJDK")) {
    $needUnity = $false; Write-Host "  Already installed with Android support."; Record "Unity $UnityVersion" "already installed"
} elseif (Test-Path $editorDir) {
    Write-Host "  Unity is installed but is missing Android tools. Adding them in the background."
    $hubArgs = @("--", "--headless", "install-modules", "--version", $UnityVersion, "-m", "android", "android-sdk-ndk-tools", "android-open-jdk")
} else {
    Write-Host "  Downloading and installing in the background (log: $logOut)."
    $hubArgs = @("--", "--headless", "install", "--version", $UnityVersion, "--changeset", $UnityChangeset, "-m", "android", "android-sdk-ndk-tools", "android-open-jdk")
}
if ($needUnity) {
    if ($dry) { Write-Host "  [dry run] `"$hubExe`" $($hubArgs -join ' ')" }
    elseif (-not (Test-Path $hubExe)) { Problem "Unity Hub is missing, so Unity can't be installed."; Record "Unity $UnityVersion" "FAILED"; $needUnity = $false }
    else {
        $unityProc = Start-Process -FilePath $hubExe -ArgumentList $hubArgs -PassThru -WindowStyle Hidden -RedirectStandardOutput $logOut -RedirectStandardError $logErr
        Write-Host "  Started. You can keep going while it downloads."
    }
}

# ---- 4. Student's own copy of the project
Step "Your own copy of the project"
if (-not $dry -and (Test-Path $ghExe)) { Start-Process $ghExe }
Write-Host "  Sign in to GitHub Desktop with your GitHub account (free). It opens now."
Write-Host "  A GitHub page will open next. Sign in if asked, name the copy ixd-vr-<yourname>,"
Write-Host "  choose Private, and click Create repository."
Read-Host "  Press Enter to open the page"
if ($dry) { Write-Host "  [dry run] open https://github.com/$Template/generate" } else { Start-Process "https://github.com/$Template/generate" }
Write-Host "  When your copy exists, copy its address from the browser."
$repo = Read-Host "  Paste your repo address (https://github.com/yourname/ixd-vr-yourname) or press Enter to skip"
$repo = $repo.Trim().TrimEnd("/") -replace "\.git$", ""
if (-not $repo) { Record "Your project copy" "skipped (use File > Clone repository)" }
elseif ($repo -match "^https://github\.com/[^/]+/[^/]+$") {
    if ($dry) { Write-Host "  [dry run] open x-github-client://openRepo/$repo" } else { Start-Process "x-github-client://openRepo/$repo" }
    Write-Host "  In GitHub Desktop, choose where to save it and click Clone."
    Record "Your project copy" "clone window opened"
} else {
    Write-Host "  That doesn't look like a GitHub address, so I skipped it."
    Record "Your project copy" "skipped (use File > Clone repository)"
}

# ---- 5. Meta Quest developer mode
Step "Meta Quest developer mode"
Write-Host "  To install apps on a Quest you need a free Meta developer account and Developer Mode."
Write-Host "  The page opens next. Create an organization if asked, then turn on Developer Mode in the"
Write-Host "  Meta Horizon phone app (Menu > Devices > your headset > Headset Settings > Developer Mode)."
Read-Host "  Press Enter to open the Meta developer page"
if ($dry) { Write-Host "  [dry run] open https://developers.meta.com/horizon/manage" } else { Start-Process "https://developers.meta.com/horizon/manage" }
Record "Quest developer mode" "developer page opened"

# ---- wait for Unity
if ($unityProc) {
    Write-Host "`nWaiting for the Unity download to finish..." -ForegroundColor Cyan
    Write-Host "  (This is the slow part. Latest progress is shown below.)"
    while (-not $unityProc.HasExited) {
        $last = ""
        if (Test-Path $logOut) { $last = (Get-Content $logOut -Tail 1 -ErrorAction SilentlyContinue) }
        if ($last.Length -gt 70) { $last = $last.Substring(0, 70) }
        Write-Host ("`r  {0,-72}" -f $last) -NoNewline
        Start-Sleep -Seconds 3
    }
    Write-Host ""
    if ((Test-Path "$androidPE\SDK") -and (Test-Path "$androidPE\OpenJDK")) {
        Write-Host "  Unity $UnityVersion is installed."; Record "Unity $UnityVersion" "installed"
    } else {
        Problem "Unity did not finish installing. Run this script again to resume. Details: $logOut and $logErr"
        Record "Unity $UnityVersion" "FAILED (run again)"
    }
}

# ---- summary
Write-Host "`n== Summary ==" -ForegroundColor Cyan
$results | ForEach-Object { Write-Host $_ }

Write-Host "`n== What to do next ==" -ForegroundColor Cyan
@"
  1. GitHub Desktop: sign in, then clone your project copy (File > Clone repository) if you haven't yet.
  2. Unity Hub: open it, sign in with a Unity account, and activate a free Personal license
     (Preferences > Licenses > Add > Get a free personal license).
  3. In Unity Hub choose Add > Add project from disk and pick the folder you cloned. Open it
     with Unity $UnityVersion. The first open takes a few minutes.
  4. In Unity: open the project, wait for the first import, and check the app's package name under
     Edit > Project Settings > Player > Other Settings. It is set for you from your GitHub account.
  5. Switch the platform to Android in File > Build Profiles. Full details are in the README.
  6. On your Quest: run Space Setup (Settings > Physical Space), connect it by USB-C cable, and
     choose Allow USB debugging in the headset.
"@ | Write-Host

if (-not $dry -and (Test-Path $hubExe)) {
    $ans = Read-Host "`nOpen Unity Hub now? (y/N)"
    if ($ans -match "^[yY]") { Start-Process $hubExe }
}
Read-Host "Press Enter to close"
