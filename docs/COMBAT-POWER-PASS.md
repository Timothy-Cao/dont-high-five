# Haze, upper floor, punches and timed power-ups

September 21, 2026. This pass replaces quick zip and the old spark trails. Manual glove anchoring, E slingshot, held F/MMB reel, double jump, stone brake, wall grip, travel pads, portals and F5 camera testing remain.

## Punch

Press LMB and RMB together within 120 ms, in either order. Single clicks still place/recall an ordinary glove immediately. The chord switches to original Blender fist models and fires two projectiles along the same camera-forward direction, 0.74 m apart. They do not converge on the crosshair. The punch needs no attachment target and never pulls the player toward a hit.

Each fist travels at 70 m/s, reaches the same distance as the regular glove (25.5 m before bonuses), and stops at its first solid contact. A 0.22 m sphere sweep prevents tunnelling and gives the fist a physical width. Initial overlaps are checked separately, following the behavior documented for [Godot's direct physics queries](https://docs.godotengine.org/en/4.7/classes/class_physicsdirectspacestate3d.html). Damage applies once per fist, not every frame of overlap. Walls block damage. Both fists return before gloves can be used again; recovery lasts 0.65 s after the projectiles finish. Recall cannot bypass it, and pause freezes recovery.

A downward strike on a nearby upward-facing surface (within 3.2 m of the feet) gives exactly one vertical impulse per attack, even if both fists hit. It stops horizontal momentum, producing a measured 2.25 m hop at base power. Air jump budget is not replenished. Distant floor hits and ceiling hits cannot launch the player. Stronger pull bonuses also increase this hop.

Six original spring-mounted dummies have 100 HP, four visible health pips, impact wobble, a deflated defeated state and an eight-second recharge. Each normal fist deals 30 damage; a clean two-fist hit deals 60. Overdrive raises each to 52.5, enough to topple a full-health dummy with one dual hit. These are stationary damage targets; player health, enemy AI and network combat are future work.

## Temporary boosts

The center station is on the new 20 m atrium stage. Four weaker stations sit near the building's ground-floor corners. Their colored charging rings, floating 3D symbols and local light show their state without world text. A small HUD label shows each active bonus and remaining seconds.

| Source | Effect | Duration | Generation |
| --- | --- | --- | --- |
| NW corner: long arms | 1.25× new glove/punch range, about 31.9 m | 18 s | First at 4 s; 30 s after collection |
| NE corner: power | 1.35× reel speed, sling speed cap, punch damage; stronger ground hop | 18 s | First at 10 s; 32 s after collection |
| SE corner: speed | 1.3× walking speed, 9.1 m/s, plus air steering | 18 s | First at 16 s; 34 s after collection |
| SW corner: vision | 1.6× fog visibility scale and glove light range | 18 s | First at 22 s; 36 s after collection |
| Center: Overdrive | 1.5× range, 1.75× power, 1.45× speed, 1.8× vision | 20 s | First at 22 s; 65 s after collection |
| Random speed symbols | Same 1.3× speed bonus | 8 s | One spawn attempt every 7–13 s; maximum eight alive |

Random symbols use collision-validated positions on both floors, stay at least 20 m apart, avoid spawning within 8 m of the player and expire after 65 seconds. The old 278-item trail is gone. Every pickup now has a temporary effect; there is no empty score collection.

Repeated pickups refresh a duration, never multiply the bonus. Overdrive and individual bonuses have independent timers, so a weaker pickup does not downgrade or prolong the stronger bonus. All bonuses stop counting down while paused. Reset/retry clears them. A range bonus expiring leaves already attached gloves in place; the reduced reach applies to subsequent shots. Collection sweeps movement and respects walls, so fast players can collect without taking items through cover.

## Two main floors and haze

The 304 × 240 m building now has a broad main upper floor at 20 m and a roof at 44 m. Lower-floor headroom is about 19.2 m; upper rooms have about 23.5 m. The old atrium, climbing shafts and galleries remain as openings through that slab. Additional openings preserve the four launch-pad trajectories and portal approaches. New upper dividing walls use offset doors and high windows; two more sheltered upper rooms provide hiding corners.

Two 12 m-wide ramps climb 20 m over a 120 m horizontal run, about 9.5°. Both were traversed end to end using only normal walking. The new slab originally blocked two long pad arcs; dedicated openings and aligned upper doors fixed both routes. All four pads again land on their intended platforms. The carpet emission is limited to upward-facing surfaces, keeping ceiling undersides dark and plain.

Exponential fog density is 0.018, with a dark blue haze color; base ambient fill drops from 0.25 to 0.17. Using the exponential attenuation model, scene contribution is about 64% at 25 m, 17% at 100 m and 7% at 150 m. This makes roughly half-map distances hard to read without introducing a hard clipping boundary. Emissive landmarks can remain faintly detectable farther away. Vision bonuses reduce fog density and extend the real glove lights, rather than only brightening the whole screen. See [Godot's Environment reference](https://docs.godotengine.org/en/4.6/classes/class_environment.html).

## Evidence and limits

Six suites cover the retained controller, movement, UI, arena, travel/audio and new combat/power behavior. New checks include parallel fist paths, visible fist state, no dash on misses, bounded ground hop, damage through real dummy collision, shielding, respawn, stronger Overdrive damage, actual boosted movement/reeling/reach, expiry, station regeneration, sparse spawn limits, collection occlusion, pause and full ramp walks. Reports are in `.local/reports/`.

4K engine captures are in `.local/captures/combat-power/`. Review corrected coplanar orbit rings on the center asset, oriented the dummies toward the common approach, and removed emissive carpet flecks from ceiling undersides. The fist image is a staged snapshot of the actual projectile simulation; it is not a recording of human play.

All nine new GLB assets have editable Blender sources. Rebuild with `blender --background --python art/build_toys.py`. No purchased assets or external model service are needed. The new mechanics are a first balancing pass, not proof of multiplayer fairness or human-tested fun.
