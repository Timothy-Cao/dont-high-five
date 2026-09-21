# Don’t High Five

**Stretch your arms. Trust your landing. Be careful who you help.**

A first-person Godot movement playground inside an enormous glow-in-the-dark attraction. Fire sticky gloves, stretch into a slingshot, reel around corners, and punch the floor to hop.

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
- Independent elastic gloves, slingshots, reels, wall grip, double jump and an air brake.
- Parallel fist attacks with a ground-punch hop and six regenerating targets.
- Directional launch pads and linked portals connecting distant spaces.
- Five timed power stations, sparse speed pickups, distance haze and vision boosts.
- A red hologram room that suppresses arm abilities, with two walkable exits.
- Original Blender models, an F5 test camera, five-track soundtrack and layered effects.
- Saved settings and simple click-to-rebind keys.

| Vertical playground | Red suppression room |
| --- | --- |
| ![Upper and lower traversal routes](docs/screenshots/02-vertical-playground.png) | ![Red scanning field with gloves in view](docs/screenshots/04-red-room.png) |

## Controls

| Input | Action |
| --- | --- |
| WASD / mouse | Move / look |
| Space | Jump / double jump |
| LMB / RMB | Fire or recall that glove |
| LMB + RMB together | Parallel punch; nearby ground hit gives an upward hop |
| E | Slingshot from stretched arms |
| Hold F / MMB | Reel in |
| Ctrl | Crouch / stop horizontal momentum in the air |
| Shift | Grip a wall; Space jumps away |
| Q | Recall gloves |
| F5 / Esc | Camera / menu |

Full controls: [Playing](docs/PLAYING.md). **Music and effects default to 50%; music has an additional ×0.25 gain**, giving 12.5% music bus gain before per-track matching and pause ducking.

## Where this could go

The working social-game idea is **Blackout Relay**: recover physical charge, negotiate high-fives, restart circuits, and decide whether a helpful teammate is sabotaging handoffs. Alternatives include a hot-potato party mode and cooperative movement assists. These are hypotheses awaiting playtests.

The [research notebook](docs/design/README.md) compares related games and challenges the ideas. It includes faction objectives, high-five input rules, special rooms, weapons/counterplay and a small first multiplayer test.

## Development

This repository is self-contained. [CONTRIBUTING.md](CONTRIBUTING.md) covers layout, assets, testing and packaging. `Edit.cmd` opens the editor; `Verify.cmd` runs seven suites. Current local verification passed **299 assertions**, followed by a 4K render review. These checks verify mechanics and layout, not human enjoyment or online balance.

Git excludes engine binaries, caches, personal settings, logs and generated release packages. Editable Blender files and runtime assets are included. The old internal `ParcelPop` user-data identifier is retained so existing key bindings survive the rename; earlier pass documents are historical notes.

See [licenses and asset provenance](licenses/README.md). Godot and Kenney notices do not license the original game code or the five user-supplied songs; no blanket open-source license has been selected for this project.
