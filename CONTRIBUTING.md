# Working on Don’t High Five

Open `project.godot` in Godot 4.7.2. On Windows, `tools/Setup-Godot.ps1` installs the pinned engine from the official Godot release and verifies its SHA-256 digest. It does not install anything globally. `Play.cmd`, `Edit.cmd`, and `Verify.cmd` then work from this directory, including paths with spaces.

## Project map

| Directory | Responsibility |
| --- | --- |
| `scripts/` | Controller, combat, travel, power-ups, audio, menus and world orchestration |
| `scripts/world/` | Arena geometry, districts, workshop placement/group editing and isolated workshop gameplay |
| `scripts/gameplay/` | Local session, Watcher, training, cargo, tasks, test partners and hazards |
| `scenes/` | Main scene and editable playtest placement markers |
| `shaders/` | Carpet and portal shaders |
| `assets/` | Runtime models and audio |
| `art/` | Original editable Blender files and rebuild scripts |
| `tests/` | Deterministic in-engine tests and screenshot staging |
| `docs/design/` | Research, proposals and playtest plans |
| `docs/screenshots/` | Actual engine captures; original gallery is 4K, latest review views are 2560 × 1440 |
| `licenses/` | Engine and asset provenance |
| `.local/`, `.godot/`, `dist/` | Ignored generated output |

## Verify

```powershell
./tools/Run.ps1 -Mode Verify
```

Twenty-one suites cover controller feel, collisions, arena routes, audio/settings, fixed arms, character animation, High Fiver/Watcher systems, minimap and workshop gameplay/editing. Script errors and failed assertions stop verification. Tests isolate settings writes and never capture the desktop or inject system input. Current workshop results and limits are in `docs/WORKSHOP-ITERATION.md`.

`tests/capture_showcase.gd` uses authored cameras and posed models to reproduce the gallery with `-- --showcase`. It requires a rendering-capable Godot instance; headless verification uses the dummy renderer. Screenshot characters are cosmetic staging, not connected clients. There is no multiplayer implementation yet.

## Asset changes

Keep editable originals in `art/`, export runtime GLBs into `assets/`, and retain provenance. Blender is required only to rebuild models; playing and testing use the committed exports. Do not commit import caches, backup `.blend1` files, personal settings, API keys or the bundled Godot binaries.

Historical pass notes under `docs/` explain earlier experiments. Current controls are in `docs/PLAYING.md`; current design proposals begin at `docs/design/README.md`. Proposals are not shipped features.

## Distribution

`tools/Package.ps1` produces `dist/DontHighFive-standalone.zip`: a portable Windows source/development package containing Godot and the full game. It is not a production export. GitHub source clones omit the engine; use the setup script or an installed Godot editor.

The internal user-data directory retains the old `ParcelPop` identifier so existing key bindings survive the rename. It is not a runtime dependency on another project.

## Keeping changes contained

New arena structures belong in `scripts/world/districts.gd` or the relevant existing district builder. Reuse `arena.gd` platform, wall, window, ramp and batching helpers. Reserve the broad ramps, portal exit volumes and directional-pad arcs; the traversal suites execute those routes.

`tests/runner.gd` is the explicit command-line registry. Add a suite there and in `tools/Run.ps1`; do not add another dispatch branch to `lab.gd`. Capture staging belongs in `tests/capture_*.gd`. The legacy movement bays are still used by the controller, movement and polish regressions, so their fixture geometry and parcel asset are not dead code.

Run `python tools/Audit-Source.py` after moving resources or editing asset generators. It checks literal resource paths, duplicate script UIDs and Python syntax; engine tests cover dynamically constructed asset paths. Move a script's `.uid` together with its source. Keep historical screenshots/notes labeled with their pass; they are not current feature documentation.

For map edits, start with [the map authoring guide](docs/MAP-EDITING.md). The in-game workshop saves architecture and working gameplay parts together; the original arena remains in the district builders and Godot marker scene.
