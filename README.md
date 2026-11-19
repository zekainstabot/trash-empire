# Trash Empire

A 3D, third-person recycling simulator for Android, built with Unity.

## Current prototype
- Third-person character movement (keyboard/gamepad fallback and mobile touch joystick)
- Collectible trash with limited carrying capacity
- Recycling drop-off zone and cash rewards
- Upgradeable movement speed and carrying capacity
- Runtime-generated prototype environment (no imported art required)

## Unity
- Unity 6 (6000.0.XXf1)
- Android Build Support (SDK & NDK Tools + OpenJDK)
- Project is designed to be edited in Unity Editor, while source and Android builds can be managed through GitHub.

## Open locally
1. Install Unity Hub and Unity 6 with Android Build Support.
2. Clone this repository.
3. Open the repository folder in Unity Hub.
4. Open the generated **Trash Empire** scene (or press Play; the bootstrap creates the prototype world).

## GitHub Actions Android build
The workflow at `.github/workflows/android-build.yml` uses GameCI. Add the Unity license secrets to the repository before running it:
- `UNITY_LICENSE` — the contents of your Unity license file (Personal license activation file or serial-based license file, as appropriate).
- For serial-based licenses, also configure `UNITY_EMAIL`, `UNITY_PASSWORD`, and `UNITY_SERIAL` as repository secrets.

Then open **Actions → Build Android APK → Run workflow**. The APK is uploaded as a workflow artifact.

> Unity licensing and build availability depend on your Unity plan and current Unity terms. Never commit license files, passwords, serials, keystores, or signing credentials.

## Prototype controls
- Desktop: WASD / arrow keys to move; E to collect nearby trash; Space to interact with the recycling station.
- Mobile: use the on-screen joystick; tap **COLLECT** near trash and **SELL** in the recycling area.
- Upgrade buttons spend in-game cash.

## Project layout
- `Assets/TrashEmpire/Scripts` — gameplay code
- `Assets/TrashEmpire/Editor` — editor build setup
- `ProjectSettings` — Unity project configuration
- `.github/workflows` — CI build workflow
