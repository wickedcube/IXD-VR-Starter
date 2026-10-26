# IXD VR Starter

A starter project for building VR apps in Unity using OpenXR and the XR Interaction Toolkit. Clone it, open it in Unity, and you have a working VR rig with teleport locomotion and grabbable objects.

## Requirements

- Unity 6 (6000.x) or later, with **Android Build Support** if targeting Meta Quest
- A VR headset (Meta Quest, Valve Index, HTC Vive, etc.) or the XR Device Simulator
- Git and Git LFS (for large assets)

## Getting Started

```bash
git clone <your-repo-url> IXD-VR-Starter
cd IXD-VR-Starter
git lfs install
```

1. Open **Unity Hub** → **Add** → select this folder.
2. Open the project with the matching Unity version.
3. Open `Assets/Scenes/SampleScene.unity`.
4. Press **Play** with your headset connected (Link / Air Link / SteamVR), or use the XR Device Simulator.

## Project Setup

If you are building the project up from scratch, install these via **Window → Package Manager**:

- **XR Plugin Management**
- **OpenXR Plugin**
- **XR Interaction Toolkit**
  - Import the *Starter Assets* and *XR Device Simulator* samples

Then:

1. **Edit → Project Settings → XR Plug-in Management** → enable **OpenXR** (on both the PC and Android tabs).
2. Under **OpenXR**, add the interaction profile for your headset (e.g. *Oculus Touch Controller Profile*).
3. Switch to the Universal Render Pipeline and run **Window → Rendering → Render Pipeline Converter** if needed.

## Suggested Structure

```
Assets/
├── Scenes/        # Scenes (SampleScene)
├── Scripts/       # Gameplay and interaction code
├── Prefabs/       # XR Origin, interactables, UI
├── Materials/
├── Models/
├── Audio/
└── Settings/      # URP and XR settings assets
```

## Features

- [ ] XR Origin with tracked head and controllers
- [ ] Teleport and snap-turn locomotion
- [ ] Grab, throw and poke interactions
- [ ] World-space UI
- [ ] Desktop testing via XR Device Simulator

## Building for Meta Quest

1. **File → Build Profiles** → switch to **Android**.
2. Set **Texture Compression** to ASTC, and **Minimum API Level** to 29 or higher.
3. Enable developer mode on the headset and connect via USB.
4. **Build and Run**.

## Troubleshooting

| Problem | Fix |
| --- | --- |
| Headset not tracking in Play mode | Check that OpenXR is enabled and your runtime (Oculus/SteamVR) is set as the active OpenXR runtime |
| Controllers don't appear | Add the correct interaction profile under OpenXR settings |
| Pink materials | Convert materials to URP via the Render Pipeline Converter |
| Input not working | Make sure the XR Interaction Toolkit Starter Assets input actions are assigned |

## Contributing

1. Create a feature branch: `git checkout -b feature/my-feature`
2. Commit your changes, keeping `.meta` files with their assets
3. Open a pull request

## License

Add your license here (e.g. MIT).
