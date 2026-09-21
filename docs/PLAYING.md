# Parcel Pop — Afterglow

Open **Play.cmd** in the project root. Close and reopen an older game window to load the new arena. F11 toggles fullscreen.

The training bays have been replaced by a connected, glow-in-the-dark indoor playground: a 304 × 240 m building, tall atrium, overlapping bridges, six maze layers, low tunnels, high galleries, jump-through windows, circular openings and bounce shafts. Routes rise to 26 m. Explore freely and collect 278 glowing sparks for the sound and movement; there is no required route, timer, finish line or collection quota.

## Controls

| Input | Action |
| --- | --- |
| WASD + mouse | Move and look |
| F5 | Toggle first-person / third-person test camera |
| Space | Jump; press again for one air jump |
| Left / right mouse | Place or recall that glove |
| Left + right mouse together | Quick zip: parallel catches, then a fast launch |
| E | Tuck and slingshot from stretched arms |
| Hold F or middle mouse | Reel toward attached gloves |
| Hold Ctrl | Crouch on the ground; stone brake in the air |
| Hold Shift near a wall | Grip; WASD climbs/shimmies, Space jumps away |
| Mouse wheel | Shorten / lengthen attached arms |
| Q / Backspace | Recall both gloves |
| R | Restore the last manually stretched slingshot setup |
| T | Return to the selected entry point |
| 1–4 | Optional entry-point shortcuts |
| P | Toggle trajectory prediction |
| Esc / Tab | Menu; back out of a detail page |

Walls, floors and platforms accept gloves. Ringed pads bounce. Small windows admit the tucked ball or crouched body; elevated openings offer slingshot shortcuts. All main regions connect, and the continuous ground floor lets you recover from missed jumps without restarting.

The HUD has no written instructions or objective text during exploration. Pickup feedback is a chime and a brief reticle pulse. **Explore** in the pause menu offers optional entry shortcuts and your current spark tally, without a target number. Collection lasts for the current session and resets when the game restarts.

**Controls & bindings** retains the keyboard workbench: drag an ability onto a key, or click it and press a key. Occupied keys swap. Keyboard bindings save to `user://user_bindings.cfg`; other settings remain session-local. **Settings** contains visibility, audio, camera and movement options, including disabling the two-click zip. Advanced spring tuning is still available there.

Regular glove shots reach **25.5 m**. Quick zip accepts either click order within 120 ms, while the first click fires immediately. Both parallel rays need valid surfaces **3–17 m** away. A successful catch launches at up to 28 m/s, then both gloves spend **2 seconds retracting and winding back into position**. Shots, another zip and wall grip are unavailable until the hands return; air steering, jump and brake still work. The small rings beside the reticle follow each glove’s recovery. Recall cannot skip recovery, and pausing freezes it. Returning to an entry or retrying a setup resets the player normally.

If a surface is beyond zip range but within regular reach, the clicks remain ordinary glove shots. Brake, recall or opening the menu cancels a pending zip before launch. Manual slingshots keep their quick glove return: full stretch can reach 40 m/s; sustained reeling is capped at 14 m/s.

Three sheltered perches sit along the atrium, amber shaft and violet galleries. Each has an offset standing entrance, a hidden corner, a low side escape and a usable roof. Behind the lime tunnels is a covered passage with two low hopping barriers and a central crouch shortcut. These add optional hideouts and movement choices around the open routes.

## New travel and music

Arrow pads launch you automatically toward another platform. Hold Ctrl to suppress activation. Round pads remain vertical bouncers. Two glowing portal pairs link opposite ends of the new outer halls; step into their front face. Cyan connects west ground to east high gallery, and pink connects north high gallery to south ground. Momentum follows the exit direction. Attached gloves release; spent jumps and glove recovery persist.

All five songs play in shuffled rotations. Esc → Settings → Audio changes music/effects volume or skips a track. F5 shows the courier prototype and its rolling ball form; networking is not implemented. See [EXPANSION.md](EXPANSION.md) for the layout and four proposed future toys.

## Verification

`Verify.cmd` runs five suites: 60 arena checks, 127 controller/physics/menu checks, and 54 travel/camera/audio checks (241 total). The original bays remain test fixtures only; ordinary play opens the new arena.

The new tests check physical ground connectivity, every pickup's clearance, pickup occlusion and fast collection, standing versus ball-sized openings, spawn safety, bounce/brake, zip, reel, wall grip, ramp walking, expanded recovery bounds and menu layout. 2,382 of 2,383 sampled clear ground positions connect without jumping; the remaining sample lies between the hopping barriers. A separate real movement test traverses that passage with two normal jumps. Complete human traversal of every elevated route has not been verified.

Original feel measurements remain: 7 m/s walking, 75 ms stopping time, 0.217 m stopping drift, and a 1.367 m normal jump apex. See `../.local/reports/movement-metrics.json` (generated by Verify; prior measurements are in `baseline-movement-metrics.json`).

The pre-migration engine screenshots are preserved with the old experiment in the workspace archive. New engine captures go into `.local/captures/arena/`. The original eight short stationary performance samples are in `baseline-arena-render-metrics.json`; they predate the added hideaways and do not guarantee frame rates throughout a full play session. Views 09–17 show the hideaways, actual zip recovery and updated controls at 4K. Test logs still contain environment certificate-store and shutdown resource warnings, separate from gameplay assertions.

See **docs/ARENA-DESIGN.md** for the spatial plan, generator structure, critique, fixes and evidence. Earlier iteration notes and checkpoints preserve the development history. The arena uses original procedural geometry and a procedural carpet shader alongside the existing original Blender gloves. No new asset purchases or computer-control automation were used.
