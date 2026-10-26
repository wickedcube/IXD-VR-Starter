# IXD VR Starter

A Meta Quest mixed-reality starter built on the [Meta MR Utility Kit](https://developers.meta.com/horizon/documentation/unity/unity-mr-utility-kit-overview) (MRUK). It is based on Meta's official [Unity-MRUtilityKitSample](https://github.com/oculus-samples/Unity-MRUtilityKitSample) and is configured to build an APK and run on a real headset.

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

1. Open the project in Unity Hub. The first open resolves packages from `Packages/manifest.json`, which takes a few minutes.
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

- Application ID: `com.ixd.vrstarter`. Change it in **Project Settings → Player → Android** before publishing.
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
