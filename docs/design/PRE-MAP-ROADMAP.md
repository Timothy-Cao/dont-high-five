# Refinement before the hand-built map

2026-09-22. Ranked for this specific local prototype. Benefit/cost estimates are design judgments, not measured player preferences. Preserve the successful movement, wheel silhouette and neon indoor identity. Let the user author the arena.

## What shipped in this pass

- **Hear where danger is.** Unpiloted gunfire, blasts and orbital audio now use actual world positions and distance attenuation. Manual gunfire stays immediate for the operator. A bounded pool reserves eight of its 32 voices for impacts, protecting blasts from machine-gun saturation. Orbital keeps its quieter gain. This is positional stereo; no claim of HRTF or room acoustics.
- **Understand an actual hit.** A small orange bearing arc lasts 0.85 s; repeated hits from one source refresh it. At most four appear. It remembers where the attack came from, never tracks the attacker or reveals everyone behind walls. Retry clears it. Looking up at a ceiling keeps the bearing stable.
- **Test the part you are building.** Middle-click picks an existing module and its rotation. Shift+F7 tests from the pointed walkable surface if the robot fits. R retries there; F7 returns to the working camera. Standard F7 still starts at the entrance.
- **Recover work.** Dirty workshop work gets a separate recovery file every 60 active seconds and on leaving. The menu can restore it with undo support. Recovery does not overwrite the main layout or clear its unsaved marker. Scripted tests use a separate recovery path.

## Ranked next work

Update 2026-09-22: the functional palette, group move/copy/delete, and pressure presets below are implemented locally. Group rotation remains deferred. See `docs/WORKSHOP-ITERATION.md` for verification and current limitations. Next ROI is traversal measurements, flash controls, then a measured stress test before adding dense art.

| Order | Candidate / concrete outcome | Return and cost | Acceptance before calling it done |
| --- | --- | --- | --- |
| 1 | **Functional workshop palette:** place start points, Watcher eyes, rings, cargo/socket, lights and linked portal endpoints using stable IDs | Very high; medium. Nine architectural pieces alone cannot author the complete game | Save/reload every prop, reject unpaired portals, preserve undo, play the user's one map with real roles and goals |
| 2 | **Move and duplicate assemblies:** select a few pieces, move/rotate on grid, duplicate a bay, cancel safely | Very high during map construction; medium | Move an overhead perch and wall together; undo once; reject overlap without losing the originals |
| 3 | **Traversal measuring tools:** temporary height/reach marks, start/finish timers and a local ghost of the last run | High for tuning; medium | Compare a crossing with one-hand cargo against empty hands, showing seconds and peak speed; all guides disappear in ordinary play |
| 4 | **Controlled pressure presets:** Calm / One eye / Patrol / Chaos, preserving the existing manual switches | High; small–medium | Repeat the same crossing with reproducible threat settings instead of accidentally testing seven threats at once |
| 5 | **Comfort controls:** separate flash intensity and camera motion; keep danger footprints and blackout rules intact | High; small–medium | Reduced flashes retain a readable orbital warning and opaque active beam; fast movement remains legible without camera effects |
| 6 | **Audio second pass:** smooth wall obstruction, nearby bullet-pass cues, dedicated mine/strike warning timbres | High; medium | With headphones, distinguish a threat left/right and nearby/far while music plays; walls soften sound without making an imminent blast silent |
| 7 | **Character action poses:** hanging shoulder load, one-hand cargo lean, wheel landing compression, glove contact alignment | Medium–high; medium | A distant observer identifies hanging, charging and carrying from silhouette; bone edits leave hand collision untouched |
| 8 | **Reusable light/finish palette:** matte wall/floor variants and a few broad ceiling fixtures, under the same kit IDs | Medium–high; medium | Distinguish floor, wall and opening at speed; lights obey blackout; no trim creates collision snags |
| 9 | **Performance budgets:** a repeatable eight-bot / seven-tower / explosion test with frame-time percentiles | High before a dense map; medium | Profile CPU/GPU first, then optimize observed spikes; do not pool or rewrite everything speculatively |
| 10 | **Two-person handshake experiment:** one moving high-five benefit with visible offer/accept, then latency trials | Essential for the eventual premise; larger and needs human sessions | Both players understand a failed contact; reward makes accepting worthwhile before adding betrayal powers |

**Recommendation:** implement the functional palette and group editing before a long map-building session. They prevent recreating the map in code afterward. Test one little room with its objective and Watcher, then expand the same saved arena. Avoid building a multi-map browser, marketplace or scripting language for this project.

## Small creative experiments worth discussing

These are proposals, not implemented rules or requirements for the map.

1. **Hot-potato cargo relay.** Pass the core by high-fiving with the free hand; passing refreshes a short delivery bonus. A real choice: take the safe long route alone or expose your free hand to another player to save time. First experiment uses cooperative local partners; betrayal should wait until accepting is useful.
2. **Catch me.** An offered palm briefly catches a fast teammate and slings them through an opening. Use an explicit held offer, never the same tap used for grabbing a wall. Prototype two bodies on one clear ledge before considering rescue penalties or deception.
3. **Tower tells.** The eye contracts before a sniper shot, a hatch opens before a grenade, and a vertical energy sweep signals an orbital mark. This turns the tower into a readable character and gives art/rigging a gameplay purpose. Never add extra unrequested weapon cooldowns to achieve it.
4. **Run ghosts.** A translucent recording of your own previous traversal is visible only in workshop testing. Race your own cargo route, then remove the ghost in the real match. Helps evaluate movement without filling the arena with objectives or bots.
5. **A hand-powered blackout station.** Holding a palm on a physical breaker cuts the local lights while occupying that hand. It creates an escape/support decision naturally tied to traversal. It changes blackout ownership and needs discussion; retain F7 testing in the current build.

## Rejected or deferred this pass

- More weapons, larger explosions and more collectibles: the arsenal already provides more variety than we can currently compare clearly.
- Another character redesign: recent simplification is coherent. Contact, suspension and readable poses are better returns than extra detail or replacement meshes.
- Rebalancing speed, recoil and arm reach: user feedback supports the current direction; collect route observations before changing the core feel again.
- Permanent enemy radar/through-wall arrows: undermines the Watcher reveal and hiding. The new incoming-hit cue is brief, reactive and positional.
- Full room reverb simulation: spatial position is the missing first step. Obstruction/reverb should follow auditioning and final kit boundaries.
- Expanding the example arena: the user will build the map. Refine reusable tools and feedback instead.

## Primary research and how it applies

Sources checked 2026-09-22. These support principles, not a claim that copying another game's settings guarantees fun.

- Riot, [How the VALORANT Arsenal was built](https://playvalorant.com/en-us/news/dev/how-the-valorant-arsenal-was-built/): weapon feel is assembled from differentiated visual and sound layers; the developers describe third-person weapon audio changing with firing direction. Application here: separate the operator's immediate shot feedback from other players hearing its world source. Our first pass does not implement their directional emission system.
- Godot, [AudioStreamPlayer3D](https://docs.godotengine.org/en/stable/classes/class_audiostreamplayer3d.html): provides listener-relative position, attenuation, filtering and a maximum distance. Application: use native positional playback and a capped voice budget; keep the effects slider and pause behavior authoritative. These are building blocks, not automatic room acoustics.
- Halo Support, [Forge overview](https://support.halowaypoint.com/hc/en-us/articles/10581874119828-Halo-Infinite-Forge-Overview): editing, testing and playing are distinct modes; solo undo/redo supports iteration. Application: shorten our edit/test cycle and keep recovery reversible. Our Shift+F7 choice is a project-specific inference, not a claimed Forge binding.
- Riot, [VALORANT Shaders and Gameplay Clarity](https://www.riotgames.com/en/news/valorant-shaders-and-gameplay-clarity): art and technical decisions serve gameplay visibility. Application: preserve the landing route and center view, use temporary feedback, and treat brighter effects as a readability tradeoff.
- Game Accessibility Guidelines, [Avoid flickering images and repetitive patterns](https://gameaccessibilityguidelines.com/avoid-flickering-images-and-repetitive-patterns/): reduce problematic effects and describe options concretely. Application: propose a flash-intensity control while keeping warning geometry, rather than a misleading blanket safety preset.

## Cheapest human comparison

Play High Fiver for two minutes with patrol enabled and music at your usual level: can you identify a nearby blast's direction and tell a distant one apart? In workshop, build a platform, middle-click it, Shift+F7 onto it, R retry and F7 back. Spend five minutes on one cargo crossing before deciding which movement numbers to touch. This pass has engine tests and rendered review; enjoyment and headphone clarity still need that human check.
