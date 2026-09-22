# Wheel robot and empty-shell workshop

This source pass replaces the legged High Fiver with an original unicycle, adds thrown mines and builds the first creator workshop. The published v0.2.0 release is unchanged.

## Character

Spool keeps the friendly monitor face, cream torso and mismatched shoulder spools. One thick 0.83 m diameter, 0.46 m wide rubber tire carries the body. A curved fender, fork, suspension sleeves, inset hubs, shallow tread and folding stabilizers establish a coherent mechanical silhouette. Editable source: `art/courier.blend`; regeneration: `art/build_spool.py` plus `art/spool_wheel.py`.

The nine-bone rig exports Idle, Walk, Air, Charge, Punch, Land, Brake and Hang. Signed local velocity drives the wheel independently of body animation. Steering, hanging, carrying and braking have separate body responses. Afterimages, moving partners and toppled corpses use the new model. Death remains a scripted collapse, not a physical ragdoll.

Launching retains the full 1.8 m controller capsule and normal eye height; there is no ball transformation. Ctrl lowers suspension to a 1.62 m capsule. The former ball escape slots are now 1.75 m high so those shortcuts remain usable. The old internal launch-state flag remains named `ball` for now, but no longer selects a sphere mesh or tiny collision shape.

## Watcher tuning

| Mechanic | Current behavior |
| --- | --- |
| Q grenade | 0.25 s cooldown; retained tangential travel, modest bounce capped at 3.2 m/s normal velocity; fuse starts at first floor contact and detonates after 1 s even if still bouncing |
| R mine | 2 s cooldown; 120 s maximum lifetime including flight; settles, then arms after 0.7 s |
| Mine trigger | Approximately 1 m, swept target position with line-of-sight check |
| Mine blast | 4 m radius, maximum 65 damage with existing cover/falloff rules |
| Mine counterplay | Either physical fist can detonate it, including before arming; paired impacts cannot trigger it twice |

The mine has a raised luminous ring, pulsing red lamp and low puck profile. Its indicator stays dimly visible between flashes. Expiry is silent. Pause freezes its timers. Optional tower AI retains guns, grenades and orbital strikes; it does not autonomously plant mines.

A real projectile test exposed lowered hand origins hitting the floor short of a crosshair-targeted mine. The punch pair now shares one aim direction from its midpoint toward the crosshair hit. The fists still travel parallel; this corrects close/low targeting without converging the arms. Existing surface-recoil, charge and combat suites pass with the correction.

## Building and workflow

The main arena gains manufactured padded panels, large reel insignias and restrained wall washes. The palette is midnight metal, rubber, teal enamel and recessed cyan/amber light. Main travel routes remain in place; perimeter panels have real collision rather than visual surfaces the player can enter.

The separate **Build workshop** starts empty, as requested. Its 96 × 80 × 36 m shell uses a free edit camera, brighter edit lighting and the real player controller for F7 playtesting. The main arena's simulation is suspended while editing. Returning restores the arena and saved player position.

Nine Blender modules share metre dimensions, bottom-center pivots and simple authored collision: floor, wall, pillar, ramp, window, perch, fin, canopy and launch pad. The example course is optional and undoable. Stable catalogue IDs are stored in versioned JSON; assets can improve without rewriting saved mesh paths. See [controls and save behavior](MAP-EDITING.md).

The workflow follows the reusable-mesh, grid-placement and separate-collision principles described by [Godot's GridMap documentation](https://docs.godotengine.org/en/4.7/classes/class_gridmap.html). This implementation uses ordinary scene bodies and a catalogue, which allows functional parts such as launch pads; it does not use GridMap internally. Blender exports follow the [official glTF workflow](https://docs.blender.org/manual/en/5.0/addons/import_export/scene_gltf2.html). These are implementation references, not evidence that a layout is fun.

## Verification and critique

All seventeen suites passed across the final applicable runs: base 37, movement 43, polish 24, arena 65, expansion 54, combat/power 44, settings 24, charge 32, recoil 19, density 48, fixed arms 47, local pilot 134, wrapping 14, carrying/night 23, orbital 22, crowd 24 and workshop 43: **697 assertions**. The workshop suite includes actual fist flight against a mine, expiry, proximity damage, cooldowns, pause, role isolation, placement, undo/redo, atomic save replacement, invalid-file rejection and walking the sample ramp with the real controller. Source audit passed 148 static resource references, unique script UIDs and Python authoring syntax.

Engine-rendered images were inspected after iteration. The first workshop was too dark to edit comfortably, so edit-only fill and directional lighting were added. The first facade panels sat behind the enclosing wall; they were moved inward and given collision. The wheel fender received smooth shading, brake pads were folded farther back, and the mine received a visible low phase between pulses. Final renders are in `docs/screenshots/`: `wheel-fiver-front.png`, `wheel-workshop-kit.png`, `wheel-workshop-play.png`, `wheel-reel-hall.png` and `wheel-watcher-mine.png`.

Verification used headless tests and authored offscreen render fixtures, not desktop access or human playtesting. Known engine certificate-store and shutdown resource warnings remain. The model is approximately 59k triangles before separate gloves; multiplayer-scale LOD/draw-call profiling remains necessary. Wheel rotation is velocity-driven rather than a physical tire simulation, and steep-slope contact needs human review.

The workshop is intentionally a first usable pass: conservative bounds may reject creatively overlapping parts; there is no selection gizmo, duplicate/group editing, configurable spawn, arbitrary scaling, tower/task/portal placement or network sharing. Those are the next creator-workflow improvements, rather than more one-off arena code.
