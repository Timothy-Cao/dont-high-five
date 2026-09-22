# Don’t High Five

Open **Play.cmd** in the project root. Close and reopen an older game window to load the new arena. F11 toggles fullscreen.

Explore a 304 × 240 m glow-in-the-dark building with two main floors, tall ceilings, broad ramps, maze rooms, hiding pockets, portals and launch pads. Haze gradually obscures distant spaces. Five timed power stations and sparse speed pickups give temporary movement advantages. Six spring dummies let you test punches. There is no required route or collection quota.

## Controls

| Input | Action |
| --- | --- |
| WASD + mouse | Move and look |
| F5 | Toggle first-person / third-person test camera |
| Space | Jump; press again for one air jump |
| Left / right mouse | Place or recall that glove |
| Left + right mouse together | Recall extended arms; from idle, hold to charge and release either to punch |
| E | Elastic: tuck and slingshot. Fixed: release while keeping velocity |
| Hold F or middle mouse | Reel elastic arms; fixed mode pulls automatically |
| Hold Ctrl | Crouch on the ground; stone brake in the air |
| Hold Shift | Anchor / fast drop; resist punch knockback |
| Hold C near a wall | Grip; WASD climbs/shimmies, Space jumps away |
| Mouse wheel | Shorten / lengthen elastic arms |
| Q / Backspace | Recall both gloves |
| R | Restore the last manually stretched slingshot setup |
| T | Return to the selected entry point |
| 1 | Toggle elastic / fixed arm mode |
| P | Toggle trajectory prediction |
| Esc / Tab | Menu; back out of a detail page |

Walls, floors and platforms accept gloves. Ringed pads bounce. Small windows admit the tucked ball or crouched body; elevated openings offer slingshot shortcuts. All main regions connect, and the continuous ground floor lets you recover from missed jumps without restarting.

The HUD stays minimal: reticle, glove state, brief impact feedback, the arm mode, and temporary bonus timers. The pause menu contains Resume, Settings and Quit. Settings → Controls → Key bindings opens a simple action list: click a key and press its replacement. Occupied keys swap; Esc cancels. Bindings and ordinary settings save automatically. Music and effects both default to 50%; music has an additional ×0.25 multiplier (12.5% bus gain at the default). Volume zero fully mutes the corresponding bus.

The upper northeast equipment bay retains its covered geometry, but its disabling field and invisible projectile barrier are removed.

Regular gloves reach **25.5 m**. In fixed mode each grip automatically pulls you smoothly toward a **5 m arm length** (closer grips stay short). Aim farther along the ceiling and alternate **LMB, RMB, LMB, RMB**; no movement keys, F or wheel adjustments are required. The pull accelerates and eases to a stop, preserving sideways swing momentum. E lets go. A successful replacement grip releases the old hand after **0.3 s**; misses preserve the old grip. Elastic mode keeps its previous slack, stretch and two-hand slingshot.

With idle hands, press LMB and RMB within 120 ms to charge. Release either button to fire. A tap reaches **4.5 m** with **9 m/s** impulse; holding **1.1 s** reaches **25.5 m** with **24 m/s** impulse. Punches cause **no damage**. Both parallel fists share one impulse per recipient. Nearby hits also push you away; distant hits only knock the target. Dummies recover after 1.5–3 s. If either hand was already extended before the chord, it recalls both hands instead; start a fresh chord to punch.

The reticle ring and physical wind-up show charge. Maximum charge gently shakes the fists. Speed changes FOV by at most 5 degrees (disable under Settings); afterimages and temporary surface stamps provide feedback without filling the view with lines.

A nearby surface hit adds recoil away from that surface. Full charge supplies a 24 m/s impulse, producing about 11.9 m of rise from rest on flat ground. Tap recoil is 9 m/s. Walls push outward, corners combine contact directions, and incoming momentum is preserved. Recoil fades out from 3 to 4.5 m; distant hits do not propel you. Grounded horizontal wall punches get a small floor-clearance pop. Space preserves stronger upward momentum, so pad launches, punches and bunny hops chain. Fists take **0.65 s to recover after flight**. Normal glove shots stay instant; when starting from idle, the second click converts that shot into a wind-up.

WASD tops out at **3.5 m/s**, half the earlier speed, with **12 m/s²** acceleration (about 0.29 s to full speed). Braking stays crisp. Air input can generate only that walking speed, but it can turn faster momentum earned from hands or launch pads without adding speed. A **100 ms landing grace window** lets a buffered or well-timed Space press carry momentum into a bunny hop. Missing the hop lets ground braking settle you. Ctrl remains the deliberate immediate air brake.

Every station replenishes **30 s after collection**. Corner stations grant longer arms, stronger pulling/punches, speed or vision for 18 seconds. The upper-center station grants a stronger 20-second **Overdrive** to all four. Sparse randomly spawned speed symbols grant an eight-second boost. Bonuses show remaining time at the bottom left; repeated pickups refresh without stacking. Pause freezes timers, reset clears boosts, and expired reach never detaches an existing anchor.

Three sheltered perches sit along the atrium, amber shaft and violet galleries. Each has an offset standing entrance, a hidden corner, a low side escape and a usable roof. Behind the lime tunnels is a covered passage with two low hopping barriers and a central crouch shortcut. These add optional hideouts and movement choices around the open routes.

## New travel and music

Arrow pads launch you automatically toward another platform. Hold Ctrl or Shift to suppress activation. Round pads remain vertical bouncers. Two glowing portal pairs link opposite ends of the new outer halls; step into their front face. Cyan connects west ground to east high gallery, and pink connects north high gallery to south ground. Momentum follows the exit direction. Attached gloves release; spent jumps and glove recovery persist.

All five songs play in shuffled rotations. Esc → Settings changes music and sound-effects volume. F5 shows the rigged Spool courier and its rolling ball form; networking is not implemented. See [EXPANSION.md](EXPANSION.md) for the layout and four proposed future toys.

## Verification

`Verify.cmd` runs eleven suites. See [the latest pass](FIVER-MOVEMENT-PASS.md) for current results. These cover the controller, physics, menus, arena routes, camera, travel, music, punches, temporary stats, timed generators and both complete ramp walks. All four pad arcs still reach their intended landings. Headless tests and 4K render review are not a substitute for your playtesting.

See [CHARGE-AND-SPOOL.md](CHARGE-AND-SPOOL.md) for the latest movement and character pass. See [COMBAT-POWER-PASS.md](COMBAT-POWER-PASS.md) for tuning values, implementation decisions and evidence. The public gallery is in [screenshots/README.md](screenshots/README.md); older design documents retain earlier iteration history. See [RELEASE-0.1.md](RELEASE-0.1.md) for this pass.

The atrium now has a slowly rotating mirrorball, two sweeping laser fans and moving light patches. It is a sparse central installation, not a map-wide strobe. See [RECOIL-RAVE-PASS.md](RECOIL-RAVE-PASS.md) for this iteration.

The upper floor now has two additional looping mazes, terrace stacks and annex bridges. Covered ground loops and upper concourse alcoves provide cover between open movement lanes. See [the arena infill notes](ARENA-INFILL.md).
