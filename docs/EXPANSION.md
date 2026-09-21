# Outer halls, travel and courier — September 21, 2026

Historical expansion record. [The subsequent combat/power pass](COMBAT-POWER-PASS.md) replaces spark trails and quick zip, adds the second main floor, and raises the roof to 44 m.

The building is now 304 × 240 m, with the original 152 m square maze inside it. The 35 m ceiling remains. A continuous ground floor connects amber and violet side halls, long blue concourses, intermediate shelves, window walls and covered perimeter pockets. The original dense maze remains the place for tight movement; the annex gives fast movement room to breathe. There are 278 optional sparks, 1,406 collision boxes and 66 shared architecture batches.

## Travel

Four arrow pads launch automatically when stepped onto. Hold Ctrl to suppress them. Unlike round bounce pads, they set a deliberate forward/upward velocity and tuck the player into a ball. Air steering, brake and grapples remain available. Two pads connect the side-hall floor to 17 m galleries; two carry players 60 m along the upper concourses. Default-gravity controller tests land within 0.20 m of the target centers. Changing gravity in Advanced tuning changes these trajectories.

Two bidirectional pairs of teleport gates connect the far ends. They are deliberately sparse:

| Pair | Entrance | Partner |
| --- | --- | --- |
| Cyan, one top marker | West hall, ground floor, x = −140 | East gallery, 17 m high, x = 140 |
| Pink, two top markers | North gallery, 18 m high, z = −108 | South concourse, ground floor, z = 108 |

Enter the face pointing into the arena. Crossings sweep the body's movement rather than depending on an overlap at one frame. Velocity and heading rotate into the exit's frame, while jump budget and glove recovery persist. Attached gloves release, the camera cuts to the new place, and the pickup sweep resets so it cannot collect objects across the entire map. An obstructed destination rejects the crossing. A short retrigger guard prevents immediate return. These are animated teleport surfaces, without recursive views of the destination.

## Player prototype

F5 switches between first person and a camera behind the player. The original first-person camera still owns aim and hand reach, so changing views cannot shoot from around a corner. The display camera sweeps a 0.28 m sphere against the world, retracts immediately at obstructions, and eases outward when clear. The body hides when the camera is too close. This follows the collision principles described in [Godot's third-person camera guide](https://docs.godotengine.org/en/stable/tutorials/3d/spring_arm.html).

The original Blender courier prototype, nicknamed **Spool**, has a rounded rubber body, teal faceplate, mismatched boots and two backpack spools that echo the glove colors. Boots and soles use a small procedural walk cycle; crouching compresses the body. Slingshots show a compact rolling rubber shell. This is an editable visual prototype for testing. Multiplayer networking and a production skeletal animation rig are not implemented.

## Validation and critique

- All 241 assertions across five suites pass: controller 37, movement 43, polish 47, arena 60, expansion 54.
- Expansion tests run full pad flights against real collision, all four portal directions, blocked exits, speed preservation, ability budgets, camera collision, F5 switching, audio sequencing, mute and UI bounds.
- Moved two sparks that intersected the new concourse ramps.
- Reviewed nine 3840 × 2160 engine renders. The first avatar export lost Blender bevel modifiers; exporting evaluated meshes restored them. Portal transparency exposed a bright light behind the surface; the center is now opaque.
- The new halls have less obstacle density than the old core. Test whether their long lanes remain engaging; add traversal toys selectively rather than filling every open space.
- Render review does not establish a minimum frame rate or replace a human playtest. First-person control remains the primary experience; the third-person mode is a test view.

Run `Verify.cmd` for repeatable tests. Reports are in `.local/reports/`; 4K inspection images are in `.local/captures/expansion/`. The asset-inspection front view is a staged camera; the other third-person images use the gameplay camera.

## Four ideas for review — not implemented

1. **Moving grapple anchors.** Slow ceiling trolleys carry glowing handles along short rails. Catch one, ride it, then release or slingshot at the right moment. This adds moving targets with the same mouse/grapple inputs. First prototype: one loop over an open hall; do not turn the whole map into timed platforming.
2. **Angled rebound walls.** A few padded wall faces redirect a flying ball while retaining most of its speed. Aim a bank shot through a window or around a corner; Ctrl remains the escape from an unwanted rebound. Clear striping should distinguish these from ordinary grippable walls. Watch for uncontrollable repeated ricochets.
3. **Light bridges held by a glove.** Stick one luminous hand into a socket to reveal a temporary crossing; use the other hand to move across it. The bridge stays while that glove remains attached, so the challenge is hand allocation rather than a surprise timer. Provide a safe floor below and a readable fade before disabling collision.
4. **A carryable glow core.** Pick up a soft glowing orb with one hand to illuminate dark routes. Move with the remaining grapple, toss the core through a shortcut, then catch up. It trades mobility for visibility and could later support cooperative passing or playful keep-away. First prototype needs reliable pickup/throw behavior and recovery if the orb falls somewhere inaccessible.

My first choice is **angled rebound walls**: they build directly on the current ball, brake and air steering, make the new spacious halls useful, and need no extra binding. Moving anchors would be my next experiment.
