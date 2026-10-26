# IXD VR Starter

A Unity 6 project for **mixed reality on Meta Quest**, built on the [Meta MR Utility Kit](https://developers.meta.com/horizon/documentation/unity/unity-mr-utility-kit-overview) (MRUK). It is based on Meta's official [Unity-MRUtilityKitSample](https://github.com/oculus-samples/Unity-MRUtilityKitSample) and is set up to build an APK and run on a real headset.

## What's included

A start scene that launches each sample (in `Assets/MRUKSamples/`):

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

## Requirements

- Unity **6000.3.8f1** (Unity 6), with **Android Build Support** (SDK, NDK, OpenJDK). The student setup script installs this for you; a free Unity Personal license is activated in Unity Hub
- A **Meta Quest 3 or 3S**. Quest 2 and Pro lack some features, such as the depth-based samples
- A free [Meta developer account](https://developers.meta.com/horizon/manage) and **Developer Mode** turned on for the headset (Meta Horizon phone app → Menu → Devices → your headset → Headset Settings → Developer Mode)
- A USB-C cable

## Get your own copy

Each student works in their **own copy** so nobody overwrites anyone else's work. You only use GitHub Desktop (a normal app with buttons). You never need to type git commands.

### One-time setup

1. **Download the setup file for your computer.** You only need this one file; the script makes your copy of the project for you in step 4. Open the file's GitHub page and click the download icon (**Download raw file**) at the top right of the code box:
   - **Mac:** [Setup-Mac.command](https://github.com/wickedcube/IXD-VR-Starter/blob/main/setup/Setup-Mac.command)
   - **Windows:** [Setup-Windows.bat](https://github.com/wickedcube/IXD-VR-Starter/blob/main/setup/Setup-Windows.bat) (it fetches the rest by itself)

   Your teacher may also hand you the file directly. Every copy of the project also contains it in the `setup` folder.
2. **Run it:**
   - **Mac:** find the file in your Downloads folder, right-click `Setup-Mac.command`, choose **Open**, then **Open** again.
     If macOS says you don't have permission to run it (browsers remove that permission from downloads), open the **Terminal** app, paste the line below, and press Enter. It runs the same script without needing the download:

     ```bash
     bash <(curl -fsSL https://raw.githubusercontent.com/wickedcube/IXD-VR-Starter/main/setup/Setup-Mac.command)
     ```

   - **Windows:** double-click `Setup-Windows.bat` in your Downloads folder. If Windows warns you, click **More info > Run anyway**.

   The script shows its progress as **[1/5] ... [5/5]** and installs **GitHub Desktop** (it includes Git), **Unity Hub**, and **Unity 6000.3.8f1 with Android build support**. Unity is several GB, so it downloads in the background (about 20 to 40 minutes) while the script walks you through making your copy (steps 4 and 5) and opens the Meta developer page (used for Developer Mode). At the end it prints a summary of what was installed and a list of what to do next. Windows may ask for administrator permission; click **Yes**. It is safe to run again if something fails: it skips what's already installed and resumes the rest.
3. **Sign in** to GitHub Desktop with your GitHub account (free at [github.com](https://github.com/signup)). The account also supplies your name and email for saves.
4. **Make your copy.** The script opens the template's **Create a new repository** page. Name your copy `ixd-vr-<yourname>`, choose **Private**, and click **Create repository**. You can also reach that page with the green **Use this template** button on this repo's GitHub page.
5. **Download your copy to your computer.** Paste your repo address when the setup script asks (it opens the clone window for you), or in GitHub Desktop choose **File > Clone repository > URL**, paste the address, and click **Clone**. Clone it somewhere **outside** iCloud, OneDrive and Dropbox, because syncing tools corrupt Unity projects.
6. In **Unity Hub** choose **Add > Add project from disk** and pick the cloned folder. The first open takes several minutes while Unity imports everything.

> **Teacher, once:** tick **Settings > General > Template repository** on this repo's GitHub page. The repo must be public so students can download the setup file and use the template without extra access; each student's own copy is private.

**No template?** Click **Fork** at the top right of the repo page instead and clone the fork. **No GitHub at all?** Copy the whole project folder and rename it `IXD-VR-<yourname>`. You lose online backup, so copy the folder to a cloud drive or USB stick now and then.

### Make it yours

Do this once in your copy:

- [ ] Open the project in Unity and check **Edit > Project Settings > Player > Other Settings > Package Name**. It is set for you from your GitHub account and repo name (for example `com.ixd.yourname.ixdvryourname`), so several students can install on the **same headset** without overwriting each other. Builds are blocked if it still shows the template's name. To pick your own, use **Team > Save and Restore > First-time setup**.
- [ ] Change **Company Name** and **Product Name** in the same Player settings.
- [ ] Save your scene as `Assets/Scenes/<YourName>_Main.unity` and keep your own work in your own folders.
- [ ] Edit the title and first paragraph of this README so it describes **your** project.
- [ ] Save and back up your changes (see below).

## Setup

1. If you haven't already, open the folder in Unity Hub with Unity 6000.3.8f1.
2. Switch the platform to **Android** in **File > Build Profiles**.
3. Put the headset on and run **Space Setup** (Settings > Physical Space > Space Setup), so there is a room for the samples to use.

The project settings are already prepared: IL2CPP, ARM64, minimum API 32, target API 34, URP, and OpenXR with the Meta Quest feature group.

## Build and run on a Quest

1. Connect the Quest by USB-C and choose **Allow USB debugging** in the headset.
2. Choose **Build > Quest > Build And Run**. The app installs and launches on the headset.

To produce an APK without launching it, use **Build > Quest > Build APK**. The output is `Builds/IXDVRStarter.apk`. Install it with Meta Quest Developer Hub, or run `adb install -r Builds/IXDVRStarter.apk`. The app appears in the headset library under **Unknown Sources**.

On first launch the headset asks for **Spatial Data** permission, which the samples need to read the room. Grant it. If you declined it earlier, re-enable it under Settings > Apps > your app > Permissions.

Command-line build, for scripts and CI:

```bash
/Applications/Unity/Hub/Editor/6000.3.8f1/Unity.app/Contents/MacOS/Unity \
  -batchmode -quit -projectPath . -buildTarget Android \
  -executeMethod BuildScript.BuildQuestApk -output Builds/IXDVRStarter.apk
```

## Saving and restoring your work

A "save" is a **commit**: a snapshot you can return to. Save often, such as after each thing that works.

### In Unity: Team > Save and Restore

| I want to... | Do this |
| --- | --- |
| Save my work | Type what you changed and click **Save**. Unity saves your scenes for you |
| See earlier saves | They're listed in the same window, newest first |
| Go back to an earlier save | Click **Restore** next to it |
| Back up to GitHub | **Save** tries automatically. If it says "Saved on your computer", click **Push origin** in GitHub Desktop (the window opens it for you) |

### In GitHub Desktop

1. In Unity choose **File > Save Project** (changes that aren't written to disk won't be saved).
2. In GitHub Desktop, the **Changes** tab lists what changed. Type a short summary in the box at the bottom left, such as "added the cube", and click **Commit to main**. This is the save.
3. Click **Push origin** at the top. This is the backup to GitHub. If it says "Fetch origin" or "Pull origin" instead, click that first, then push.

Save before risky changes (upgrading a package, deleting things) and at the end of every session.

### Go back

| I want to... | Do this in GitHub Desktop |
| --- | --- |
| Throw away changes I haven't saved yet | **Changes** tab > right-click the file(s) > **Discard Changes**. |
| Undo my latest save | **History** tab > right-click the save > **Revert Changes in Commit**, then **Push origin**. This adds a new save that cancels the old one; nothing is lost. |
| Undo several saves | Revert them one at a time, newest first. |
| Look at an old version and maybe keep working from it | **History** tab > right-click the old save > **Create Branch from Commit**, name it `old-version`, and click Create. Your project folder now matches that save. To return, use **Current Branch > main**. |

Close Unity before going back, then reopen it so it re-imports.

### Mac shortcuts (optional)

Double-click these in the project folder if you prefer: **`Save My Work.command`** saves and backs up, and **`Restore My Work.command`** shows a numbered list of earlier saves and goes back to the one you pick. They need Git on your Mac, which macOS offers to install the first time. Restoring never deletes anything: your current work is saved first. If macOS refuses to open one, right-click it and choose **Open**.

For terminal users, `./tools/save.sh "message"` and `./tools/restore.sh [number] [path]` do the same.

### Good habits

- Unity's `Library/` folder is not saved because it is rebuilt automatically.
- Never delete a `.meta` file or commit one without its asset.
- Working in a pair on one repo? Each person should use their own branch (**Branch > New branch**) and merge only when you both stop editing the same scene. Scenes and prefabs merge badly.

### Something went wrong?

| Problem | What to do |
| --- | --- |
| "I broke my scene" | Close Unity, then **Discard Changes** (if unsaved) or **Revert Changes in Commit** (if saved). Or use **Team > Save and Restore**. |
| Push says "rejected" or asks you to sign in | Sign in under **File > Options > Accounts** (Windows) or **GitHub Desktop > Settings > Accounts** (Mac), then try again. Your work is still saved on your computer. |
| Push says a file is too big | GitHub blocks files over 100 MB. Keep huge source files (raw video, big scans) out of the project folder, or compress them. |
| Unity says Git is not installed | Run the setup script again, restart your computer, then restart Unity. |
| The project opens slowly the first time | Normal. Unity is rebuilding `Library/`. |

## Project structure

```
Assets/
  MRUKSamples/            The sample scenes and their scripts
  Editor/                 BuildScript (Build > Quest menu), TeamSaveWindow (Team menu),
                          AppIdGuard (unique package name per student)
Packages/                 Package manifest (Meta XR SDKs come from the Unity registry)
ProjectSettings/
setup/                    One-time installers for GitHub Desktop, Unity Hub and Unity (Mac and Windows)
tools/                    save.sh and restore.sh (used by the Mac .command shortcuts)
Save My Work.command      Mac shortcut: save and back up
Restore My Work.command   Mac shortcut: go back to an earlier save
```

## Troubleshooting

- **`adb devices` shows nothing or `unauthorized`:** re-plug the cable and accept the USB debugging prompt in the headset.
- **Build fails with SDK, NDK or JDK errors:** install Android Build Support with all three modules through Unity Hub, and keep **Preferences > External Tools** on the bundled paths.
- **Build stops about the package name:** open **Team > Save and Restore > First-time setup** and click **Apply**.
- **App runs but no room geometry:** run Space Setup on the headset and grant the Spatial Data permission.
- **Passthrough is black:** check that the scene has an `OVRManager` with passthrough enabled, and that you're running on the headset, not in the editor.
- **Package errors on first open:** check your network, then use **Window > Package Manager > Reset Packages to defaults**.

## Resources

- [Meta MR Utility Kit](https://developers.meta.com/horizon/documentation/unity/unity-mr-utility-kit-overview)
- [Original MRUK sample project](https://github.com/oculus-samples/Unity-MRUtilityKitSample)

## License

Project content comes from Meta's [Unity-MRUtilityKitSample](https://github.com/oculus-samples/Unity-MRUtilityKitSample), which is MIT-licensed (see `LICENSE-MRUK-Sample`). The sample's README also states that Meta's Oculus License applies to the samples, so read both before redistributing. The Meta XR SDKs are governed by Meta's own terms. Add a license of your own for your additions.
