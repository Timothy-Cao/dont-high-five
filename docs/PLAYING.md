# Don’t High Five

Open **Play.cmd** in the project root. Close and reopen an older game window to load the new arena. F11 toggles fullscreen.

Explore a 304 × 240 m glow-in-the-dark building with two main floors, tall ceilings, broad ramps, one maze and corridor bays, hiding pockets, portals and launch pads. Haze gradually obscures distant spaces. Five timed power stations and sparse speed pickups give temporary movement advantages. Six spring dummies let you test punches. The local objective sampler has seven tasks; there is no match timer. Use Esc → Local playtest → Visit a task for testing shortcuts.

## Controls

| Input | Action |
| --- | --- |
| WASD + mouse | Move and look |
| F6 | Switch Fiver / Watcher role |
| M | Toggle the local floor-aware minimap |
| F7 | Toggle arena blackout for either role; in workshop, edit/playtest instead |
| 2 | Toggle punch / parallel zip |
| V | Calibrate the indicated maintenance node |
| F5 | Toggle first-person / third-person test camera |
| Space | Jump; press again for one air jump |
| Left / right mouse | Place or recall that glove |
| Left + right mouse together | Recall extended arms; from idle, hold to charge and release either to punch |
| E | Elastic: slingshot. Fixed: release while keeping velocity |
| Hold F or middle mouse | Reel elastic arms; fixed mode pulls automatically |
| Hold Ctrl | Lower suspension on the ground; wheel brake in the air |
| Hold Shift | Anchor / fast drop; resist punch knockback |
| Hold C near a wall | Grip; WASD climbs/shimmies, Space jumps away |
| Mouse wheel | Shorten / lengthen elastic arms |
| Q / Backspace | Recall both gloves |
| R | Restore the last manually stretched slingshot setup |
| T | Return to the selected entry point |
| 1 | Toggle elastic / fixed arm mode |
| Esc / Tab | Menu; back out of a detail page |

Walls, floors and platforms accept gloves. Ringed pads bounce. Low escape slots admit the robot with its suspension lowered; elevated openings offer slingshot shortcuts. All main regions connect, and the continuous ground floor lets you recover from missed jumps without restarting.

The HUD stays minimal: reticle, glove state, brief impact feedback, the arm mode, and temporary bonus timers. The pause menu contains Resume, Settings and Quit. Settings → Controls → Key bindings opens a simple action list: click a key and press its replacement. Occupied keys swap; Esc cancels. Bindings and ordinary settings save automatically. Music and effects both default to 50%; music has an additional ×0.25 multiplier (12.5% bus gain at the default). Volume zero fully mutes the corresponding bus. Fog distance adjusts haze from 50–250 m (default 100 m); lower means thicker fog. Changes apply live and save automatically.

The upper northeast equipment bay retains its covered geometry, but its disabling field and invisible projectile barrier are removed.

Regular gloves reach **25.5 m**. In fixed mode each grip automatically pulls you smoothly toward a **5 m arm length** (closer grips stay short). Aim farther along the ceiling and alternate **LMB, RMB, LMB, RMB**; no movement keys, F or wheel adjustments are required. The pull accelerates and eases to a stop, preserving sideways swing momentum. E lets go. A successful replacement grip releases the old hand after **0.3 s**; misses preserve the old grip. Elastic mode keeps its previous slack, stretch and two-hand slingshot.

With idle hands, press LMB and RMB within 120 ms to charge. Release either button to fire. A tap reaches **4.5 m** with **9 m/s** impulse; holding **1.1 s** reaches **25.5 m** with **24 m/s** impulse. Punches cause **no damage**. Both parallel fists share one impulse per recipient. Nearby hits also push you away; distant hits only knock the target. Dummies recover after 1.5–3 s. If either hand was already extended before the chord, it recalls both hands instead; start a fresh chord to punch.

The reticle ring and physical wind-up show charge. Maximum charge gently shakes the fists. Speed changes FOV by at most 5 degrees (disable under Settings); afterimages and temporary surface stamps provide feedback without filling the view with lines.

A nearby surface hit adds recoil away from that surface. Full charge supplies a 24 m/s impulse, producing about 11.9 m of rise from rest on flat ground. Tap recoil is 9 m/s. Walls push outward, corners combine contact directions, and incoming momentum is preserved. Recoil fades out from 3 to 4.5 m; distant hits do not propel you. Grounded horizontal wall punches get a small floor-clearance pop. Space preserves stronger upward momentum, so pad launches, punches and bunny hops chain. Fists take **0.65 s to recover after flight**. Normal glove shots stay instant; when starting from idle, the second click converts that shot into a wind-up.

WASD tops out at **3.5 m/s**, half the earlier speed, with **12 m/s²** acceleration (about 0.29 s to full speed). Braking stays crisp. Air input can generate only that walking speed, but it can turn faster momentum earned from hands or launch pads without adding speed. A **100 ms landing grace window** lets a buffered or well-timed Space press carry momentum into a bunny hop. Missing the hop lets ground braking settle you. Ctrl remains the deliberate immediate air brake.

Every station replenishes **30 s after collection**. Four exposed quadrant stations cycle through longer arms, stronger pulling/punches, speed, vision, fast charging, invisibility, toughness, maximum charge and insulation for 18 seconds. Insulation has no live disablement field to counter yet. The upper-center station grants a stronger 20-second **Overdrive** to all four. Sparse randomly spawned speed symbols grant an eight-second boost. Bonuses show remaining time at the bottom left; repeated pickups refresh without stacking. Pause freezes timers, reset clears boosts, and expired reach never detaches an existing anchor.

Three sheltered perches sit along the atrium, amber shaft and violet galleries. Each has an offset standing entrance, a hidden corner, a low side escape and a usable roof. Behind the lime tunnels is a covered passage with two low hopping barriers and a central crouch shortcut. These add optional hideouts and movement choices around the open routes.

## New travel and music

Arrow pads launch you automatically toward another platform. Hold Ctrl or Shift to suppress activation. Round pads remain vertical bouncers. Two glowing portal pairs link opposite ends of the new outer halls; step into their front face. Cyan connects west ground to east high gallery, and pink connects north high gallery to south ground. Momentum follows the exit direction. Attached gloves release; spent jumps and glove recovery persist.

All five songs play in shuffled rotations. Esc → Settings changes music and sound-effects volume. F5 shows the rigged Spool unicycle robot; launches keep its full silhouette and collision; networking is not implemented. See [EXPANSION.md](EXPANSION.md) for the layout and four proposed future toys.

## Verification

`Verify.cmd` runs nineteen suites. See [the latest pass](FIVER-MOVEMENT-PASS.md) for current results. These cover the controller, physics, menus, arena routes, camera, travel, music, punches, temporary stats, timed generators and both complete ramp walks. All four pad arcs still reach their intended landings. Headless tests and 4K render review are not a substitute for your playtesting.

See [CHARGE-AND-SPOOL.md](CHARGE-AND-SPOOL.md) for the latest movement and character pass. See [COMBAT-POWER-PASS.md](COMBAT-POWER-PASS.md) for tuning values, implementation decisions and evidence. The public gallery is in [screenshots/README.md](screenshots/README.md); older design documents retain earlier iteration history. See [RELEASE-0.1.md](RELEASE-0.1.md) for this pass.

The atrium now has a slowly rotating mirrorball, two sweeping laser fans and moving light patches. It is a sparse central installation, not a map-wide strobe. See [RECOIL-RAVE-PASS.md](RECOIL-RAVE-PASS.md) for this iteration.

The upper floor has open corridor bays, terrace stacks and annex bridges. A single ground maze remains in the northwest. Covered ground loops and upper concourse alcoves provide cover between open movement lanes. See [the arena infill notes](ARENA-INFILL.md).

## Local Fiver / Watcher pilot

The source build extends the released movement build. **Training** is a separate menu entry with nine selectable rooms. **Arena** remains directly accessible. R retries the current training room; reaching its ring advances. You can skip without proving mastery.

Fivers have 100 HP and a three-second test respawn. Shift halves incoming damage; punches remain non-damaging. Click a cargo ball to occupy one hand. Click that same hand again to drop it; recall and E retain it. The free hand can grapple, stretch for an E slingshot, or repeatedly regrip the ceiling in fixed mode. Two-handed attacks remain unavailable. Pads preserve cargo; portals transfer it if both cargo and player fit at the exit. Bring it to its amber socket.

At the pink station, click the local partner to offer a high-five. Its automatic reciprocal response heals both and completes one task. Recall or attack cancels a pending exchange. This partner is a simulation, not a second player. Three rings, one delivery, one high-five, one maintenance panel and one dummy KO make the seven-task sampler. Maintenance is an aim-and-confirm sequence: press your Interact key (default V) while aiming at the enlarged node.

F6 switches roles. Watcher controls: 1–7 or A/D select eyes; LMB fires the machine gun; hold RMB to scope for sniper shots at 50% look sensitivity on both axes; Q lobs a low-rebound grenade that explodes one second after landing; W marks a sustained orbital strike with a pulsing circle covering the full impact area; E throws a flashing proximity mine; R reveals Fiver silhouettes through walls for five seconds; F7 toggles full arena blackout; S deploys an impostor robot. Unattended auto-fire is **off by default**, configurable in Local playtest. Auto-fire warns for 0.65 seconds and shoots the recorded position rather than tracking instantly.

The impostor can lethally high-five test partners. Stay completely still on the ground for ten seconds to self-destruct, or return to a tower base; F6 returns to the original Fiver. Punching an eye disrupts it for four seconds. Blackout affects lighting, not voice chat: there is no voice system yet.

The south gallery contains a slowing gate, jumpable sweep, damaging laser channel and warning-timed press. Disable the gallery in Local playtest. Arm/leg-disable zones remain absent. All these systems are a local mechanics sampler, not a balanced multiplayer match. See [the review and limitations](LOCAL-PILOT.md).

### Watcher weapon update

LMB fires immediately and holds for a 30-shot/second machine gun with twice the previous spread. Hold RMB to expose the scoped aiming laser and fire a 55-damage sniper shot every 0.4 seconds. Q repeats every 0.25 s with modest bounces and a one-second fuse from first floor contact; W every 5 s; E throws a mine every 2 s. R reveals players for 5 s with a 5 s cooldown measured from activation. F7 is the immediate test blackout toggle for both roles. Blackout grants no night vision. Fiver hands stay emissive, and shots/explosions briefly light nearby surfaces. See [current carry and night-vision pass](CARRY-NIGHT-PASS.md). Restart the local source game to load changes; the GitHub v0.2.0 snapshot predates the Watcher prototype.

### Arms around cover

Attached arms now bend around the arena's box-shaped walls and columns in both fixed and elastic modes. The nearest contact becomes the swing/pull pivot; the rest of the bent path consumes arm length. Move back into clear line of sight to unwrap, or recall normally to clear the whole path. The old invisible angle stop is removed. Body collision and arm reach still limit movement. This uses approximate collision-bound contacts, not a full soft-rope simulation.

The orbital strike has an **18 m radius** and burns for **4 seconds** after its **2.8-second warning**. When the warning ends, a fully opaque animated energy column fills that footprint and extends vertically through the building; solid cover blocks its damage. Leave the marked area or get behind cover.

## Moving targets and automated opponents

Esc → Local playtest has separate **8 moving Fivers · mixed speeds** and **Tower AI · guns + abilities** switches (both initially off). Automated towers alternate sniper/machine gun, use grenades and orbital strikes, and aim about 0.6 seconds behind visible targets. See [simulation details](CROWD-AND-TOWER-AI.md).

## Wheel robot and workshop

The Fiver now always rides one broad wheel. It leans while steering, compresses its suspension to brake, and retains its body during flight, charging and hanging. There are no legs or ball transformation. Low arena shortcuts have been raised to fit its 1.62 m braking capsule; normal height remains 1.8 m.

Watcher E mines last 120 seconds, settle before arming after 0.7 seconds, and flash to advertise their roughly one-metre trigger. Punch one from beyond its four-metre blast radius to clear it; the blast can still hurt nearby players. Two parallel fists share crosshair targeting without converging. Mines expire quietly if unused.

**Esc → Build workshop → Enter / continue workshop** opens the separate empty shell. Choose parts with 1–9 or the wheel, LMB places, RMB deletes, R rotates, Ctrl+Z/Y undoes/redoes, Ctrl+S/L saves/loads, and F7 swaps between editing and real movement testing. The optional example course is undoable. See [workshop instructions](MAP-EDITING.md) and [this pass](WHEEL-AND-WORKSHOP.md).

## Current demo behavior

Unpiloted towers sweep red scoped lasers by default. Each periodically throws a grenade (roughly 14–24 s apart) and attempts an orbital strike (28–45 s apart), with staggered starts. These attacks can hurt; they follow the patrol direction rather than tracking you. Esc → Local playtest → Tower demo disables this ambient behavior. The separate Tower AI toggle enables the more aggressive delayed-targeting opponent. Piloting an eye replaces its autonomous patrol.

R reveal shows a filled yellow animated silhouette, visible through cover and in darkness, only for the Watcher. It lasts five seconds; the five-second cooldown begins on activation, allowing immediate reuse after expiry. Punch disruption temporarily hides the reveal from the blinded eye.

The trajectory indicator and P binding are removed. The robot torso is now plain, the external stabilizers and backpack are gone, and the tire spins in the corrected direction.


The optional local minimap shows the current floor, nearby walls, gaps, ramps, pads and portals. It stays north-up, preserves its floor during jumps, and dims in blackout. It contains no player/enemy radar. M toggles it; the setting saves. See [minimap behavior and limitations](MINIMAP.md).

Unpiloted tower shots, explosions and orbital strikes now have positional sound and distance attenuation. A brief orange arc indicates the bearing of an actual incoming hit; it fades after 0.85 seconds and does not track enemies. Workshop middle-click picks a part and its rotation; Shift+F7 tests from a clear pointed surface; R retries there. See [the pre-map refinement roadmap](design/PRE-MAP-ROADMAP.md).

**Arena overview (M):** fixed whole-map scale, cream player arrow, teal Fiver dots and seven numbered red towers. The active Watcher tower is gold. All actors appear across floors with height ticks; architecture follows the current floor. This is prototype radar, including through walls.
