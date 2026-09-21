# Parcel Pop — Afterglow

Open **Play.cmd** in the project root. Close and reopen an older game window to load the new arena. F11 toggles fullscreen.

Explore a 304 × 240 m glow-in-the-dark building with two main floors, tall ceilings, broad ramps, maze rooms, hiding pockets, portals and launch pads. Haze gradually obscures distant spaces. Five timed power stations and sparse speed pickups give temporary movement advantages. Six spring dummies let you test punches. There is no required route or collection quota.

## Controls

| Input | Action |
| --- | --- |
| WASD + mouse | Move and look |
| F5 | Toggle first-person / third-person test camera |
| Space | Jump; press again for one air jump |
| Left / right mouse | Place or recall that glove |
| Left + right mouse together | Two parallel fists; punch nearby ground to hop |
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

The HUD stays minimal: a reticle, glove state, brief damage feedback, and labels only while temporary bonuses are active. **Explore** in the pause menu offers optional entry shortcuts. The old spark tally and collection trails are removed.

**Controls & bindings** retains the keyboard workbench: drag an ability onto a key, or click it and press a key. Occupied keys swap. Keyboard bindings save to `user://user_bindings.cfg`; other settings remain session-local. **Settings** contains visibility, audio, camera and movement options, including disabling the two-button punch. Advanced spring tuning is still available there.

Regular glove shots reach **25.5 m**. Press LMB and RMB together within 120 ms to fire **two parallel fists** at the same range. Each stops on its first collision and deals 30 damage to a dummy. A nearby ground hit hops you straight up about 2.25 m; ceiling/forward hits do not pull you. Fists take **0.65 s to recover after their flight**. Single clicks, E slingshot and F/MMB reel remain available outside that recovery.

Corner stations grant longer arms, stronger pulling/punches, speed or vision for 18 seconds. The upper-center station grants a stronger 20-second **Overdrive** to all four. Sparse randomly spawned speed symbols grant an eight-second boost. Bonuses show remaining time at the bottom left; repeated pickups refresh without stacking. Pause freezes timers, reset clears boosts, and expired reach never detaches an existing anchor.

Three sheltered perches sit along the atrium, amber shaft and violet galleries. Each has an offset standing entrance, a hidden corner, a low side escape and a usable roof. Behind the lime tunnels is a covered passage with two low hopping barriers and a central crouch shortcut. These add optional hideouts and movement choices around the open routes.

## New travel and music

Arrow pads launch you automatically toward another platform. Hold Ctrl to suppress activation. Round pads remain vertical bouncers. Two glowing portal pairs link opposite ends of the new outer halls; step into their front face. Cyan connects west ground to east high gallery, and pink connects north high gallery to south ground. Momentum follows the exit direction. Attached gloves release; spent jumps and glove recovery persist.

All five songs play in shuffled rotations. Esc → Settings → Audio changes music/effects volume or skips a track. F5 shows the courier prototype and its rolling ball form; networking is not implemented. See [EXPANSION.md](EXPANSION.md) for the layout and four proposed future toys.

## Verification

`Verify.cmd` runs six suites with 272 checks. These cover the controller, physics, menus, arena routes, camera, travel, music, punches, temporary stats, timed generators and both complete ramp walks. All four pad arcs still reach their intended landings. Headless tests and 4K render review are not a substitute for your playtesting.

See [COMBAT-POWER-PASS.md](COMBAT-POWER-PASS.md) for tuning values, implementation decisions and evidence. New captures are in `.local/captures/combat-power/`; older design documents retain earlier iteration history.
