# Parcel Pop — Afterglow

A standalone Godot project: a first-person playground of stretchy gloves, slingshots, grapples and glowing indoor mazes. This folder contains the current game, original assets, editable Blender sources, tests and a portable Windows Godot runtime. It does not depend on the old experiments workspace.

## Start

- **Play.cmd** runs the game in a visible window. The first run imports the assets automatically.
- **Edit.cmd** opens this project in the bundled Godot editor.
- **Verify.cmd** runs all six automated suites, then shows the result.
- You can also open **project.godot** in Godot **4.7.2**. Other engine versions have not been verified for this project.

WASD moves, mouse looks, Space jumps/double-jumps, LMB/RMB place gloves, both clicks together punch, E slingshots, F/MMB reels, Ctrl brakes/crouches, and Shift grips walls. F5 toggles first/third person. Esc opens the menu and keyboard binder. Full controls and movement details are in [docs/PLAYING.md](docs/PLAYING.md).

## Project layout

| Folder | Contents |
| --- | --- |
| `scenes/` | Main scene |
| `scripts/` | Player, arena, HUD, bindings and world setup |
| `shaders/` | Procedural blacklight carpet and animated portals |
| `assets/` | Runtime GLB assets, music, effects and import settings |
| `art/` | Original Blender sources and rebuild scripts |
| `tests/` | Controller, movement, UI and arena verification |
| `docs/` | Controls, arena design, development notes and baseline measurements |
| `tools/` | Launch/test script, packaging script and bundled Windows engine |
| `licenses/` | Bundled engine notices and project asset provenance |
| `.local/` | Generated logs, reports and screenshots; not packaged or committed |

The working folder has its own Git repository on `main`; the portable ZIP omits Git metadata. `.gitignore` excludes import caches, local output and the bundled engine; `.gdignore` keeps authoring files and tooling out of Godot's asset scan. No project source license has been selected on your behalf.

## Development

The main scene uses `scripts/lab.gd` as its bootstrap; ordinary play builds `scripts/arena.gd`. The old training bays survive only as deterministic regression fixtures. They are not a second playable project. The expanded building is 304 × 240 m, with two main floors, broad ramps, dark distance haze, four directional launch pads and two distant portal pairs. Parallel fist punches replace quick zip. Five timed power stations and sparse temporary speed pickups replace the old spark trails. Six damageable dummies provide combat targets. See [docs/COMBAT-POWER-PASS.md](docs/COMBAT-POWER-PASS.md). An original courier prototype supports F5 camera testing. All five supplied music tracks rotate with crossfades, alongside the new effects library. See [docs/EXPANSION.md](docs/EXPANSION.md) and [docs/AUDIO-DESIGN.md](docs/AUDIO-DESIGN.md).

Run tests without opening a console prompt at the end:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File tools/Run.ps1 -Mode Verify
```

Tests cover 272 assertions. They run headlessly. Windows certificate-store and shutdown resource warnings can appear in engine logs; script errors and failed assertions fail verification.

Keybindings are stored in Godot's user data directory (`user://user_bindings.cfg`). They are personal data, outside the source package. Collection progress is session-local.

See [art/README.md](art/README.md) to rebuild source assets and [docs/ARENA-DESIGN.md](docs/ARENA-DESIGN.md) for layout and balance decisions. Earlier demos are archived in the original workspace. The pre-migration experiment retains old sky art, checkpoints and captures; Windows held that directory open during cleanup. None of that history is a runtime dependency.

## Portable package

Run `tools/Package.ps1` to create `dist/ParcelPop-standalone.zip`. It uses an explicit list of source directories and bundled runtime files, excluding personal data, logs, caches, old experiments and credentials. Extract the archive anywhere writable and open its `parcel-pop/Play.cmd`. This is a complete source/development package with Godot included, rather than an exported release build.
