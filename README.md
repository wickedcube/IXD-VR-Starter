# IXD VR Starter

A Meta Quest mixed-reality starter built on the [Meta MR Utility Kit](https://developers.meta.com/horizon/documentation/unity/unity-mr-utility-kit-overview) (MRUK). It is based on Meta's official [Unity-MRUtilityKitSample](https://github.com/oculus-samples/Unity-MRUtilityKitSample) and is configured to build an APK and run on a real headset.

## Make your own copy

Each student works in their own copy, so nobody's changes collide. You only do this once.

1. On GitHub, click **Use this template → Create a new repository**. Name it `ixd-vr-<yourname>`, set it to **Private** (or Public if your instructor asks), and create it. *(Your instructor must turn on "Template repository" in this repo's Settings first.)*
2. Install [GitHub Desktop](https://desktop.github.com/) and sign in. Choose **File → Clone repository**, pick your new repo, and clone it somewhere **outside** iCloud, OneDrive and Dropbox. Syncing tools corrupt Unity projects.
3. Open the folder in Unity Hub (see [Requirements](#requirements)). The first open takes several minutes.
4. Give your app its own name and ID. Close Unity, then run this from the project folder:

   ```bash
   tools/setup-student.sh "yourname" "My App Title"
   ```

   This sets an app ID like `com.ixd.yourname`. Every student needs a different ID. Otherwise installing your build on a shared headset **overwrites** someone else's app. Windows users can run the script from **Git Bash**, which is installed with Git, or edit **Project Settings → Player** by hand.
5. Save it: `tools/save.sh "Set up my project"`.

Your copy has no link to the original. If the instructor adds updates to the template, ask them how to pull those in.

## Saving and restoring your work

Think of a *save* as a checkpoint of the whole project that you can return to. Save often: after something works, before trying something risky, and at the end of every session.

### Quickest way: the helper scripts

Run these from the project folder in Terminal (macOS/Linux) or Git Bash (Windows).

| I want to... | Run |
| --- | --- |
| Save my work and upload it to GitHub | `tools/save.sh "what I changed"` |
| See my earlier saves | `tools/restore.sh` |
| Go back to an earlier save | `tools/restore.sh <id>` using an id from the list |

Restoring never deletes anything. It first saves your current work, then makes the project look like the old save and records that as a new save. Changed your mind? Restore the save you came from.

### Using GitHub Desktop instead

1. Unity writes changes to disk when you press **File → Save** (Ctrl/Cmd+S). Do that first.
2. In GitHub Desktop, the **Changes** tab lists what changed. Type a short summary in the box at the bottom left and click **Commit to main**. This is your save.
3. Click **Push origin** at the top. This uploads your save to GitHub, so a lost or broken laptop doesn't cost you your work.
4. To go back: open the **History** tab, right-click a save, and choose **Revert changes in commit**. Alternatively, right-click → **Create Branch from Commit** to try the old version without touching your current one.

### Rules that prevent most problems

- **Save Unity first.** Unsaved scene changes are not on disk, so they are not in your save.
- **Close Unity before restoring**, and reopen it after.
- **Keep `.meta` files.** Each asset has a `.meta` file next to it. Never delete or exclude them, and never commit just one of the pair.
- **Never commit** `Library/`, `Temp/`, `Builds/` or `.apk` files. They are already ignored, and they are huge.
- **Individual files over 100 MB** are rejected by GitHub. If you add large videos or models, ask your instructor first.
- **Try risky ideas on a branch.** In GitHub Desktop: **Branch → New branch**. If it goes badly, switch back to `main` and nothing is lost.
- **Work on one computer at a time**, and push before switching computers. When you sit down at the other one, click **Fetch origin** and then **Pull**.

### If something goes wrong

| Problem | What to do |
| --- | --- |
| "I broke my scene" | `tools/restore.sh`, pick the last good save, then `tools/restore.sh <id>` |
| "I deleted a file by accident" | Same restore. Or in GitHub Desktop, find it in the Changes tab, right-click → **Discard changes** |
| Push is rejected or says the branch is behind | Click **Fetch origin**, then **Pull**, then push again |
| Unity shows a lot of changes you didn't make | Normal after opening a project in a new Unity version. Save them as one commit |
| Conflict message | Stop and ask your instructor. Don't pick sides blindly in scene or prefab files |

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

- Application ID: `com.ixd.vrstarter` in the template. Students replace it with `tools/setup-student.sh`, or in **Project Settings → Player → Android** before publishing.
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
