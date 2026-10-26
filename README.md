# IXD VR Starter

A Meta Quest mixed-reality starter built on the [Meta MR Utility Kit](https://developers.meta.com/horizon/documentation/unity/unity-mr-utility-kit-overview) (MRUK). It is based on Meta's official [Unity-MRUtilityKitSample](https://github.com/oculus-samples/Unity-MRUtilityKitSample) and is configured to build an APK and run on a real headset.

## One-time computer setup

Do this once per computer. No terminal needed.

| Your computer | Double-click | What it installs |
| --- | --- | --- |
| Mac | `setup/install-mac.command` | Git, GitHub Desktop (and checks for Unity Hub) |
| Windows | `setup/install-windows.bat` | Git, GitHub Desktop, Unity Hub |

- **Mac:** if macOS says the file can't be opened, right-click it → **Open** → **Open**. A window may ask you to install the Command Line Tools: click **Install** and wait.
- **Windows:** approve the admin prompts. Restart the computer afterwards.
- You also need the Unity editor with **Android Build Support**. Install it from Unity Hub (see [Requirements](#requirements)).
- Finally, open **GitHub Desktop** and sign in with your GitHub account.

The installers only run Apple's and Microsoft's own installers or download from GitHub's official links, and you can read them first. They are in the `setup/` folder.

> The installers don't need this project to exist yet. If you don't have the files, ask your instructor for just the `setup` folder, or download it from the repo page on GitHub.

## Make your own copy

Each student works in their own copy, so nobody's changes collide. You only do this once.

1. On GitHub, open this repo and click **Use this template → Create a new repository**. Name it `ixd-vr-<yourname>` and create it. *(Your instructor must turn on "Template repository" in this repo's Settings first.)*
2. In **GitHub Desktop**, choose **File → Clone repository**, pick your new repo, and clone it somewhere **outside** iCloud, OneDrive and Dropbox. Syncing tools corrupt Unity projects.
3. Click **Open in Unity** in GitHub Desktop, or add the folder in Unity Hub. The first open takes several minutes.
4. In Unity, choose **Team → Save and Restore**, open **First-time setup: name your app**, enter your name and app title, and click **Apply**. Every student needs a different app ID. Otherwise installing your build on a shared headset **overwrites** someone else's app.
5. Click **Save** in the same window.

Your copy has no link to the original. If the instructor adds updates to the template, ask them how to pull those in.

## Saving and restoring your work

Think of a *save* as a checkpoint of the whole project that you can return to. Save often: after something works, before trying something risky, and at the end of every session.

### In Unity: Team → Save and Restore

| I want to... | Do this |
| --- | --- |
| Save my work | Type what you changed, click **Save**. Unity saves your scenes for you |
| See my earlier saves | They're listed in the same window, newest first |
| Go back to an earlier save | Click **Restore** next to it |
| Upload to GitHub | **Save** tries automatically. If it says "Saved on your computer", click **Push origin** in GitHub Desktop (the window opens it for you) |

Restoring never deletes anything. It saves your current work first, then makes the project look like the old save and records that as a new save. Changed your mind? Restore the save you came from.

### In GitHub Desktop

You can do the same things there, and it's the best place to see exactly what changed.

1. The **Changes** tab lists what changed. Type a summary at the bottom left and click **Commit to main**. This is your save.
2. Click **Push origin** at the top. This uploads your save, so a lost or broken laptop doesn't cost you your work.
3. To go back: open the **History** tab, right-click a save, and choose **Revert changes in commit**.

### Rules that prevent most problems

- **Save in Unity first.** Unsaved scene changes aren't on disk, so they aren't in your save. The Save button does this for you.
- **Keep `.meta` files.** Each asset has a `.meta` file next to it. Never delete or exclude them, and never commit just one of the pair.
- **Never commit** `Library/`, `Temp/`, `Builds/` or `.apk` files. They're already ignored, and they're huge.
- **Individual files over 100 MB** are rejected by GitHub. If you add large videos or models, ask your instructor first.
- **Try risky ideas on a branch.** In GitHub Desktop: **Branch → New branch**. If it goes badly, switch back to `main` and nothing is lost.
- **Work on one computer at a time**, and push before switching computers. When you sit down at the other one, click **Fetch origin** and then **Pull**.

### If something goes wrong

| Problem | What to do |
| --- | --- |
| "I broke my scene" | Team → Save and Restore, then **Restore** the last good save |
| "I deleted a file by accident" | Same restore. Or in GitHub Desktop, find it in the Changes tab, right-click → **Discard changes** |
| Unity says "Git is not installed" | Run the setup installer, restart your computer, then restart Unity |
| Save says "Saved on your computer" | Click **Push origin** in GitHub Desktop. You're not signed in to GitHub in the app, or you're offline |
| Push is rejected or says the branch is behind | In GitHub Desktop, click **Fetch origin**, then **Pull**, then push again |
| Unity shows a lot of changes you didn't make | Normal after opening a project in a new Unity version. Save them as one commit |
| Conflict message | Stop and ask your instructor. Don't pick sides blindly in scene or prefab files |

### Terminal alternative

Prefer the command line? The same actions exist as scripts for macOS/Linux and Git Bash:
`tools/save.sh "message"`, `tools/restore.sh`, `tools/restore.sh <id>`, and `tools/setup-student.sh "name"`.

## What's included

A start scene that launches each sample:

| Sample | Shows |
| --- | --- |
| MRUKBase | Visualizing scene data with the EffectMesh prefab |
| Floor Zone | Finding a floor area free of other scene anchors |
| Multi Spawn | Spawning objects at different places in the room |
| Nav Mesh | Building a navigation mesh from scene data |
| Virtual Home | Reskinning the room with the prefab spawner |
| Passthrough Relighting | Virtual shadows and highlights on real surfaces |
| Destructible Mesh | Segmenting the global mesh for destructible environments |
| Environment Panel Placement | Attaching panels to real surfaces with EnvironmentRaycastManager |
| Space Map | Room texture with a colour gradient |
| Keyboard Tracking | Detecting and tracking a physical keyboard |
| Bouncing Ball | Virtual balls bouncing off the real environment |
| QR Code Detection | Detecting QR codes |

Samples live in `Assets/MRUKSamples/`.

## Requirements

- Unity 6 (6000.0.66f2 or newer). Developed against 6000.3.8f1.
- Unity **Android Build Support**, including OpenJDK and Android SDK & NDK Tools
- A Meta Quest 3 or 3S. Quest 2 and Pro lack some features, such as the depth-based samples.
- Developer Mode enabled on the headset, via the Meta Horizon phone app
- A USB-C cable, or ADB over Wi-Fi
- Scene data: run **Space Setup** on the headset first (Settings → Physical Space → Space Setup)

## Run on a headset

1. Open the project in Unity Hub (after [making your own copy](#make-your-own-copy)). The first open resolves packages from `Packages/manifest.json`, which takes a few minutes.
2. **File → Build Profiles**, make sure **Android** is the active platform, and click **Switch Platform** if it isn't.
3. Connect the Quest by USB and accept the *Allow USB debugging* prompt in the headset.
4. Choose **Build → Quest → Build And Run**. The app installs and launches on the device.

To produce an APK without launching it, use **Build → Quest → Build APK**. The output is `Builds/IXDVRStarter.apk`. Install it with either:

```bash
adb install -r Builds/IXDVRStarter.apk
```

or Meta Quest Developer Hub. The app appears in the headset library under **Unknown Sources**.

### Command-line build

```bash
/Applications/Unity/Hub/Editor/<version>/Unity.app/Contents/MacOS/Unity \
  -batchmode -quit -projectPath . -buildTarget Android \
  -executeMethod BuildScript.BuildQuestApk -output Builds/IXDVRStarter.apk
```

### Permissions

On first launch the headset asks for **Spatial Data** permission, which is needed to read the room scene. Grant it, or the samples show nothing. If you declined it earlier, re-enable it in the headset under Settings → Apps → IXD VR Starter → Permissions.

## Project settings of note

- Application ID: `com.ixd.vrstarter` in the template. Students replace it via **Team → Save and Restore**, or in **Project Settings → Player → Android** before publishing.
- Company / product name: `IXD` / `IXD VR Starter`
- Min SDK 32, target SDK 34, IL2CPP, ARM64
- Render pipeline: URP
- XR: OpenXR with the Meta Quest feature group (`com.unity.xr.meta-openxr`) and Meta XR Core SDK

## Troubleshooting

| Problem | Fix |
| --- | --- |
| `adb devices` shows nothing or `unauthorized` | Re-plug the cable and accept the USB debugging prompt in the headset |
| Build fails with SDK/NDK or JDK errors | Install Android Build Support with the OpenJDK and SDK & NDK modules through Unity Hub, and keep **Preferences → External Tools** on the bundled paths |
| App runs but no room geometry | Run Space Setup on the headset, and grant the Spatial Data permission |
| Passthrough is black | Check that the scene has an `OVRManager` with passthrough enabled, and that you're running on-device, not in the editor |
| Package errors on first open | Check your network, then use **Window → Package Manager → Reset Packages to defaults** |

## Credits and licence

Project content comes from Meta's [Unity-MRUtilityKitSample](https://github.com/oculus-samples/Unity-MRUtilityKitSample), which is MIT-licensed (see `LICENSE-MRUK-Sample`). The sample's README also states that Meta's Oculus License applies to the samples, so read both before redistributing. The Meta XR SDKs are governed by Meta's own terms.
