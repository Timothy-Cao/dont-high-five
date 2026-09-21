# Working on Don’t High Five

Open `project.godot` in Godot 4.7.2. On Windows, `tools/Setup-Godot.ps1` installs the pinned engine from the official Godot release and verifies its SHA-256 digest. It does not install anything globally. `Play.cmd`, `Edit.cmd`, and `Verify.cmd` then work from this directory, including paths with spaces.

## Project map

| Directory | Responsibility |
| --- | --- |
| `scripts/` | Controller, combat, arena, travel, power-ups, audio and menus |
| `scenes/` | Main scene |
| `shaders/` | Carpet, portal and suppression-field shaders |
| `assets/` | Runtime models and audio |
| `art/` | Original editable Blender files and rebuild scripts |
| `tests/` | Deterministic in-engine tests and screenshot staging |
| `docs/design/` | Research, proposals and playtest plans |
| `docs/screenshots/` | Actual 4K engine captures |
| `licenses/` | Engine and asset provenance |
| `.local/`, `.godot/`, `dist/` | Ignored generated output |

## Verify

```powershell
./tools/Run.ps1 -Mode Verify
```

Seven suites cover controller, movement, UI, level traversal, travel/audio, punches/power-ups, settings and the suppression room. Script errors and failed assertions stop verification. Tests isolate settings writes and never capture the desktop or inject system input.

`tests/capture_showcase.gd` uses authored cameras and posed models to reproduce the gallery with `-- --showcase`. It requires a rendering-capable Godot instance; headless verification uses the dummy renderer. Screenshot characters are cosmetic staging, not connected clients. There is no multiplayer implementation yet.

## Asset changes

Keep editable originals in `art/`, export runtime GLBs into `assets/`, and retain provenance. Blender is required only to rebuild models; playing and testing use the committed exports. Do not commit import caches, backup `.blend1` files, personal settings, API keys or the bundled Godot binaries.

Historical pass notes under `docs/` explain earlier experiments. Current controls are in `docs/PLAYING.md`; current design proposals begin at `docs/design/README.md`. Proposals are not shipped features.

## Distribution

`tools/Package.ps1` produces `dist/DontHighFive-standalone.zip`: a portable Windows source/development package containing Godot and the full game. It is not a production export. GitHub source clones omit the engine; use the setup script or an installed Godot editor.

The internal user-data directory retains the old `ParcelPop` identifier so existing key bindings survive the rename. It is not a runtime dependency on another project.
