# More routes inside the same building

21 September 2026. Local iteration after the recoil/glove pass; the published v0.1 download is an older snapshot.

The 304 × 240 m shell and two main floors remain. This pass fills previously bare upper-floor quadrants and outer halls, while reserving the central vertical flight lane, long ramps, portal exits and launch-pad trajectories.

## Places to explore

| Area | New structure | Movement choice |
| --- | --- | --- |
| Four outer ground bays, near X ±112 / Z ±65 | Covered loops with four doorways, offset baffles, split roofs, ramps and high canopies | Run around the cover, duck out of sight, or climb onto the roofs |
| Upper northwest and southeast | Two seeded 6 × 6 looping mazes with broad overhead ribbons and elevated windows | Take the sheltered floor route or launch/reel across the maze tops |
| Upper southwest and northeast | Three terrace levels at 24, 28 and 32 m, with underpasses and window walls | Chain short climbs or approach from the opposing height |
| Tall west/east annex voids | Bridge loops at 26 m and perches at 32 m | Land on the perimeter or cross the open shaft through a window |
| Upper north/south concourses | Eight roofed alcoves with offset doors and high apertures | Follow a wide slalom, use cover, or skip across roofs |

The new layouts reuse the existing collision and instancing helpers. Their 496 additional architectural shapes are authored, deterministic infill rather than scattered obstacles. Two landing platforms initially had a window wall cutting through their center; collision testing caught this and the wall moved to the rear edge.

## Light as an area landmark

The mirrorball remains an atrium landmark. Its laser fans move to four separate outer spaces: the amber bridge bay, violet bridge bay, upper blue concourse and lower southeast loop. Twenty total beams sweep slowly and terminate at solid walls. Local cyan, lime, amber and violet light pools mark the new structures. Motion is ambient choreography, not soundtrack beat synchronization; there are no strobes or laser damage rules.

The 28 moving mirror patches remain around the atrium. No additional shadow-casting lights were introduced. These are bounded scene changes, not a measured frame-rate improvement.

![Upper maze, roofs and window shortcuts](screenshots/infill-upper-maze.png)

![Terraces with a sheltered crossing beneath them](screenshots/infill-terraces.png)

## Evidence and limits

All ten in-engine suites pass: **400 assertions**. Existing checks still execute complete launch-pad flights, both long ramp climbs, all portal transfers, normal movement, charged recoil and settings flows. The new 48-check suite covers 18 standing passages, 24 supported landing spots, cover density, the retained vertical lane and laser clipping. Maze graph checks now include both added upper mazes.

The cover audit compares the same 1,504 clear, supported samples on both main floors with new architectural colliders enabled and disabled. Twelve horizontal rays per sample look up to 40 m away. Average distance to the nearest sampled wall decreases **10.90 → 9.23 m**, about **15.4%**. The share with cover within 10 m increases **51.5% → 61.6%**. This is a spatial proxy; it does not prove fun, complete navigability at every coordinate, or multiplayer balance. It excludes points occupied by the new structures, uses the current floor samples, and leaves bounce-pad bodies present in both measurements. Results are in `arena-infill-metrics.json`.

Six unretouched 2560 × 1440 engine views were reviewed. Local lighting was added after the first review to help identify upper structures; the overall dark-room treatment remains. Human movement testing and hardware performance profiling are still needed. Headless runs retain the existing certificate/user-directory and resource-at-shutdown warnings documented in the preceding pass.

## Repository cleanup

- Level-specific sources and their stable `.uid` files now live under `scripts/world/`.
- Removed the unused spark/trail generator, obsolete collectible counters and unreachable pickup-flash HUD branch. Timed power-up stations and useful speed pickups remain.
- Removed the superseded glove-normal repair script and the redundant avatar-generator wrapper; `build_soft_gloves.py` and `build_spool.py` are the maintained sources.
- Moved the older render harnesses out of `lab.gd` into `tests/capture_arena.gd` and `tests/capture_legacy.gd`.
- Replaced repeated test/capture dispatch branches and wrappers with the explicit `tests/runner.gd` registry. More than 200 lines of tooling moved out of the live orchestrator.
- Added `tools/Audit-Source.py` for static resource references, duplicate script UIDs and Python authoring syntax. Dynamic model/audio paths remain covered by engine tests.

The legacy movement bays, parcel asset and historical design notes are retained intentionally: the first three regression suites still use those fixtures, and the notes document earlier decisions. This cleanup does not discard the user's earlier work.

For lighting limits and renderer distinctions, see the [official Godot lighting documentation](https://docs.godotengine.org/en/stable/tutorials/3d/lights_and_shadows.html). No renderer or batching change was made based on an assumed per-object limit.
