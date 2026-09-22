# Don’t High Five

**Stretch your arms. Trust your landing. Be careful who you help.**

A first-person Godot movement playground inside an enormous glow-in-the-dark attraction. Fire sticky gloves, stretch into a slingshot, reel around corners, and charge a floor punch to blast upward.

![First-person gloves, central power station and two posed robot models](docs/screenshots/01-high-five-club.png)

**Current build: single-player prototype.** Multiplayer, social deduction and player-to-player high-fives are being designed; they are not implemented. The two robots above are staged character models, not connected players.

## Play

[**Download the portable Windows playground**](https://github.com/Timothy-Cao/dont-high-five/releases/tag/v0.1.0-playground) · [Controls](docs/PLAYING.md) · [Design notebook](docs/design/README.md) · [Screenshot gallery](docs/screenshots/README.md)

Extract `DontHighFive-standalone.zip` into a writable folder and open **Play.cmd**. This development package includes Godot 4.7.2, the game and editable source assets. The first launch imports assets and can take longer. It is a source/development package, not an optimized production export.

For a source clone, open `project.godot` in **Godot 4.7.2**, or on Windows run:

```powershell
./tools/Setup-Godot.ps1
./Play.cmd
```

The setup script downloads the pinned official engine and verifies its SHA-256. No Blender installation, service account, API key or sibling workspace is needed to play. Blender is only needed to rebuild models.

## In the playground

- Two main floors, tall ceilings, broad ramps, maze corridors and hiding nooks across a 304 × 240 m building.
- Elastic and fixed-rope gloves, slingshots, pendulum swings, reels, wall grip, double jump and anchoring.
- Nonlethal charge-and-release parallel punches with additive surface recoil and six regenerating targets.
- Directional launch pads and linked portals connecting distant spaces.
- Five timed power stations, sparse speed pickups, distance haze and vision boosts.
- Charge feedback, brief speed afterimages and fading punch imprints; six knockback dummies.
- Original Blender models, an F5 test camera, five-track soundtrack and layered effects.
- Saved settings and simple click-to-rebind keys.

| Vertical playground | Sheltered upper routes |
| --- | --- |
| ![Upper and lower traversal routes](docs/screenshots/02-vertical-playground.png) | ![Covered upper terraces](docs/screenshots/infill-terraces.png) |

## Controls

| Input | Action |
| --- | --- |
| WASD / mouse | Move / look |
| Space | Jump / double jump |
| LMB / RMB | Fire or recall that glove |
| LMB + RMB together | Recall extended hands; from idle, hold to charge and release to punch |
| 1 | Toggle elastic / fixed arms |
| E | Elastic slingshot / fixed-rope release |
| Hold F / MMB | Elastic reel; fixed mode pulls automatically |
| Ctrl | Crouch / stop horizontal momentum in the air |
| Shift | Anchor / drop quickly; resist knockback |
| C | Grip a wall; Space jumps away |
| Q | Recall gloves |
| F5 / Esc | Camera / menu |

Full controls: [Playing](docs/PLAYING.md). **Music and effects default to 50%; music has an additional ×0.25 gain**, giving 12.5% music bus gain before per-track matching and pause ducking.

## Where this could go

The working direction is **Fivers vs Watcher**: nimble robots complete physical tasks while a powerful opponent controls stationary towers. Blackouts may allow infiltration, making high-fives a moment of trust. The [new brief and staged backlog](docs/design/IMPLEMENTATION-BACKLOG.md) separate this direction from implemented local movement.

The [research notebook](docs/design/README.md) compares related games and challenges the ideas. It includes faction objectives, high-five input rules, special rooms, weapons/counterplay and a small first multiplayer test.

## Development

This repository is self-contained. [CONTRIBUTING.md](CONTRIBUTING.md) covers layout, assets, testing and packaging. `Edit.cmd` opens the editor; `Verify.cmd` runs eleven suites. See the [latest movement pass](docs/FIVER-MOVEMENT-PASS.md) for verification results. These checks verify mechanics and layout, not human enjoyment or online balance.

Git excludes engine binaries, caches, personal settings, logs and generated release packages. Editable Blender files and runtime assets are included. The old internal `ParcelPop` user-data identifier is retained so existing key bindings survive the rename; earlier pass documents are historical notes.

See [licenses and asset provenance](licenses/README.md). Godot and Kenney notices do not license the original game code or the five user-supplied songs; no blanket open-source license has been selected for this project.

Latest local iteration: [click-only ceiling traversal](docs/AUTO-CEILING.md). Previous iteration: [fixed arms and nonlethal Fiver movement](docs/FIVER-MOVEMENT-PASS.md). Previous iteration: [denser districts, distributed lighting and source cleanup](docs/ARENA-INFILL.md). Earlier passes cover [the charged punch and Spool courier](docs/CHARGE-AND-SPOOL.md) and [surface recoil and soft gloves](docs/RECOIL-RAVE-PASS.md). The v0.1.0 download remains the original published snapshot.
