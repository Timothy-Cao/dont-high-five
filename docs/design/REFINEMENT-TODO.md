# Refinement candidates — discussion backlog

**Superseded priorities (2026-09-22):** see [the pre-map roadmap](PRE-MAP-ROADMAP.md) for implemented audio/workshop refinements and the next ranked work. The older proposals below retain historical context; leg/ball poses no longer apply to the wheel robot.

These are proposals, not approved implementation scope. Based on the current local build, recent authored captures, the original High Fiver/Watcher brief, and the primary references below. No gameplay or assets changed for this brainstorm.

## Recommended next slice

Finish one representative arena bay: a lower corridor, an exposed crossing, an upper perch, a Watcher sightline and a cargo socket. Give it final-looking materials, lighting and traversal contacts. Add positional combat sound and polish the existing High Fiver's hand/body reactions. Use that slice to decide the visual standard before spreading it across the map.

## Ranked candidates

| Priority | Work | Concrete result | How to judge it |
| --- | --- | --- | --- |
| 1 | Lighting and material hierarchy | Dark navy solid surfaces, selective cyan/amber light strips, broad soft light pools, restrained bloom; full blackout remains hands-only | Identify a landing surface and doorway while moving, at 1080p and 4K; no blown-out attack silhouettes |
| 1 | Spatial combat audio | Distance-aware tower shots, directional bullet passes, muffling behind walls, different room tails; punch/grapple contact layers | Locate an attack without looking at its source; distinguish warning, firing and impact |
| 1 | High Fiver animation and hand contact | Palm-to-wall alignment, torso hanging from shoulder load, legs trailing in flight, landing compression, deliberate curl to ball, two convincing fist silhouettes | Third-person playback makes attach, charge, carry and release distinguishable without UI |
| 1 | Attack readability | Distinct shape/motion/sound for each attack; an explicit warning-to-impact transition; optional reduced flash/shake | Players explain what hit them, where it came from and what they could have done |
| 1 | Route quality | Three authored traversal loops with exposure, alternate line, refuge and reconnect; smooth collision at seams | Travel each with empty hands and cargo, in both directions, without accidental snags |
| 1 | High-five prototype with people | Test moving reciprocal contact, clear offer/accept feedback and cooperative benefit; compare bounded betrayal rules | People willingly attempt high-fives; failures are understandable; betrayal does not suppress every interaction |
| 2 | Short complete round | A proposed 3–5 minute cargo/ring/team-action round with an escape objective, simple result and immediate restart | Both roles know their next decision and can describe why a round ended |
| 2 | Thin networking experiment | Two peers synchronizing hands, attachment anchors, movement, carried object and reciprocal high-five | Measure correction/jitter and disputed contact under simulated latency before expanding to a full lobby |
| 2 | Original modular arena kit | Bevelled wall/pillar/window/ramp/perch/ceiling pieces with shared palette and simple collision | One kit produces cohesive rooms without blocking movement with decorative trim |
| 2 | Landmark districts | Coil Hall, Drum Room, Cable Loft and Service Burrows, each with one obvious silhouette and route purpose | Players can give useful voice directions without opening a map |
| 2 | High Fiver silhouette pass | Preserve the small maintenance-robot identity; round housing, chunky soles, readable spool mechanism and mitten gloves | Recognizable at tower distance and in monochrome; skins keep comparable visibility |
| 2 | Watcher choreography | Iris tracks aim, housing compresses before a sniper shot, MG has mechanical cadence, grenade hatch opens, orbital charge travels through tower | Observer can identify attack preparation without relying solely on HUD cooldowns |
| 2 | Objective props | Carryable energy core, receiving cradle, physical maintenance controls and team contact station | Object shape demonstrates grab, destination and completion state |
| 2 | Repeatable encounter presets | Retain full-power chaos mode; add controlled traversal/aim scenarios and adjustable AI delay for testing | Compare stationary, walking and slingshot survival; distinguish weapon feel from seven-tower saturation |
| 2 | Performance and accessibility | Shadow/light/effect budgets, LODs, instancing/pooling where profiling justifies it; low-flash options | Measure frame-time spikes with eight bots, all towers and blackout; visibility rules agree across presets |
| 3 | Living arena details | One slow scanning installation, occasional vent mist, machinery reacting to restored power, distant mechanical silhouettes | Space feels inhabited without masking enemy warnings or adding collision clutter |
| 3 | Richer death/KO | Clear nonlethal stagger versus death collapse; optional tethered head wobble or head pop; interruptible recovery | Can distinguish temporarily disabled teammate from dead teammate at a glance |
| 3 | Better test bots | A few authored grapple/hop/carry paths and bait/escape behaviors | Repeatable real traversal targets rather than a costly general-purpose competitive AI |
| 3 | Maintenance | Refresh stale feature tables, improve module boundaries as touched, investigate shutdown/dummy-renderer warnings, keep public stable release distinct | Current docs match the shipped local behavior; clean imports and meaningful regression checks |

## Specific art direction

A closed-after-hours robotic laser-tag attraction: oversized friendly safety hardware beneath severe Watcher eyes. Rounded High Fiver forms contrast with sharp tower silhouettes. Rubberized ramps, matte powder-coated panels, smoked plastic windows and a small number of glowing conduits give the building a physical identity. Avoid covering every contour in equal neon intensity. Keep ceiling spaces authored because they are playable surfaces.

Build precision hero parts, gloves, articulated towers and collision-critical modules in Blender. Meshy can be explored for decorative prop silhouettes or noncritical background machinery; any accepted output still needs scale, topology, materials, UVs, collision, LOD and licensing review. Rig quality depends on deliberate pivots, weights, poses and transitions, not simply a more detailed mesh. Try extending the existing courier before replacing it.

Normal lighting and blackout have different contracts. Normal mode should reveal surface depth while preserving hiding spots. Blackout must continue removing ambient fill and decorative outlines; any new rim lighting, reflections, baked illumination or emissive asset must be checked against that rule. Do not add a role-revealing outline to a disguised Watcher.

## Important design questions

- Is high-five healing an emergency regroup action, a moving relay, or a task interaction? Test one main use before stacking rewards.
- If betrayal can instantly kill the recipient, what information or escape window makes accepting worthwhile? Candidate experiments: a delayed marked-hand effect, limited sabotage charges, or a cooperative charge that benefits both participants. These alternatives change the brief and need discussion.
- How many Watcher attacks should threaten a single crossing at once? Keep current full-power testing available while measuring exposure and escape time.
- The current orbital visual extends through upper openings but damage respects cover/ceilings. Should it remain cover-safe or eventually penetrate floors? Its presentation must communicate whichever rule is chosen.
- Are glowing hands allowed to reveal a hiding player's exact location indefinitely? Decide deliberately before further stealth polish.
- How much task time should be stationary versus moving? One-handed cargo is especially promising because it naturally changes traversal decisions.

## Research used as principles, not copied mechanics

- Riot, *The Art of VALORANT Map Environments*: materials, lighting and detail should support legibility of playable space. https://playvalorant.com/en-us/news/dev/the-art-of-valorant-map-environments/
- Riot, *VALORANT Shaders and Gameplay Clarity* (2020): consider art, performance and competitive visibility together; character and environment shading can serve different purposes. Our blackout/deception rules require adapting this rather than copying permanent character highlights. https://www.riotgames.com/en/news/valorant-shaders-and-gameplay-clarity
- Valve, *Illustrative Rendering in Team Fortress 2* (2007): silhouette and shaped shading support stylized character recognition. https://steamcdn-a.akamaihd.net/apps/valve/2007/NPAR07_IllustrativeRenderingInTeamFortress2.pdf
- Godot, *AudioStreamPlayer3D*: positional playback, attenuation and Doppler are available building blocks; room acoustics and obstruction still require deliberate implementation. https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer3d.html
