# Fiver / Watcher disposition

Updated 2026-09-21 after the user approved the broader **local role-switching prototype**, optional auto-fire off, and separate Training. Original [brief](FIVER-WATCHER-BRIEF.md) is retained verbatim. The published [v0.2.0 movement build](https://github.com/Timothy-Cao/dont-high-five/releases/tag/v0.2.0) is a frozen earlier snapshot.

## Implemented in current source

| Brief | Local implementation |
| --- | --- |
| Afterimages, FOV, charge feedback, ball arms, imprints | Existing bounded movement effects retained; 47 fixed/Fiver checks still pass. |
| Fixed arms / easy ceiling walking | Automatic pull toward 5 m, momentum-preserving swings, alternating handover and miss safety. No manual reel needed. |
| Recall-before-punch / nonlethal assist | Extended-hand chord recalls; idle chord charges. Nearby self recoil and one impulse per paired hit; partners and dummies retain HP. |
| Anchor / health / respawn | 100 HP, Shift immobilization and 50% damage resistance, three-second test respawn. |
| Punch / zip selector | Key 2. Parallel zip requires two real surfaces, adds limited forward pull, preserves transverse momentum; misses do not create a dash. |
| Tutorial | Nine separate enclosed rooms; visible bindings, marked gaps, R reset and menu skip. No mastery gates. |
| Carrying | Collision-swept cargo occupies one hand; free hand grapples; punch/zip unavailable; drop and delivery. |
| Tasks | Three traversal rings, cargo socket, high-five station, ordered maintenance nodes, one dummy KO. Seven-point local quota and reset. |
| High-five | Cancellable reciprocal **test partner** response, full healing, task payout and impostor kill. No networking. |
| Watcher arsenal | Seven scene-positioned eyes; switching, MG, scope/sniper, bouncing grenade, delayed blast, blackout, thrown mines, infiltration and stationary self-destruct. |
| Counterplay | Eye punch disrupts view/fire, actual occlusion, 0.65 s auto-fire warning, weak ordinary damage, anchor/toughness, cloak acquisition immunity. |
| Auto towers | Opt-in, default OFF. Basic target acquisition and stationary aim sample, half ordinary MG damage. The former all-tower burst has been replaced by manual thrown mines. |
| Map | One maze; other maze regions become broad corridor bays; floor-to-ceiling columns, existing nooks/ramps/hanging perches retained. |
| Power stations | Temporary bonuses only, 30 s recharge; five station positions visible to at least one tower. Extra power types rotate through quadrant stations. |
| Hazard vocabulary | Opt-out slow gate, laser sweep/channel and warning-timed press in one gallery. Deliberately weak prototype damage. |
| Collaborative editing | Scene-native markers for eyes and task locations, plus geometry modules and a measured coverage planner. |

## Deliberately incomplete / needs discussion

- **Networking, voice, human reciprocal input and synchronized remote poses.** The approved scope is local. Bots do not validate deception, teamwork or latency fairness.
- **Full match rules, twenty-second respawn, team task allocation, many dummy objectives and victory/defeat.** Current quota is a replayable sampler, not a competitive round.
- **70–80% tower coverage.** Actual sampled floor visibility improved from about 41% to 60%. Individual eyes cover roughly 7–15% of those floor samples, not the guessed 20–30%. Audit excludes aerial routes and does not model camera direction, human attention, target readability or bullet spread. Keep real refuges until human testing gives a reason to expose more.
- **Arm/leg-disable areas** remain removed as requested. Insulation is a timed, tested future-facing resistance; it currently has no map consumer.
- **Laser river / crusher production versions.** Current channel is floor-mounted, not a carved pit; the press is a visual/damage volume, not a physics platform. Automatic doors and advanced map editing remain later work; a separate modular workshop now supports placement, undo, save/load and playtest. These were a vocabulary list, not mandatory simultaneous hazards.
- **Cargo at very high speed.** It sweeps toward the hand rather than teleporting. Pads and portals now preserve ownership, as do E launches and recall. The same carrying-hand click drops it. Test tight cargo clearance before building more carry tasks.
- **Watcher identity / disguise fairness.** Infiltration has local mechanics; no claim that lethal high-fives are fair or that bots convincingly mimic humans.
- **Spatial audio and richer targets.** Dedicated MG, sniper and blast variants are implemented, but their audio is not yet distance/occlusion-aware. Patrol partners use the existing rig; their behavior is intentionally simple.

## Rejected or changed after critique

- A 5 m attachment teleport, detaching on a missed replacement, repeated paired-punch damage, and free empty-air zip remain rejected.
- Symmetric tower placement looked orderly but covered only about 41% of the sampled floors. Placement now follows occlusion measurements rather than symmetry alone.
- Repeated maze generators obscured long movement routes. One maze remains; the rest are open corridor bays with bypasses and canopy routes.
- A dark, unmarked training floor hid the jump gap. Real ledge lips and a quiet floor grid now show its shape.
- Automatic unavoidable fire is not a valid default for solo traversal testing. Auto-fire is an explicit option with a warning and sampled aim.
- The earlier movement-only backlog deferred nearly all Watcher tools. The user explicitly expanded scope; those tools are now local prototypes, not still deferred under the old plan.

## Later refinement review

See [REFINEMENT-TODO.md](REFINEMENT-TODO.md) for the ranked discussion backlog. The historical arsenal/auto-tower rows above are superseded by [CROWD-AND-TOWER-AI.md](../CROWD-AND-TOWER-AI.md): alternating full-damage weapons, delayed aim, independent grenade/orbital timers, eight optional moving Fivers, and a shared death collapse. These refinements are proposals, not an instruction to implement everything.

## Wheel / workshop follow-up

Implemented: original nine-bone unicycle with eight clips and velocity-driven wheel, Q grenades at 0.25 s with small bounces, R two-minute mines at 2 s, nine reusable Blender modules, empty-shell workshop with snap/rotate/delete/undo/redo/save/load/F7, and main-arena panel/reel identity. See [pass notes](../WHEEL-AND-WORKSHOP.md).

Workshop follow-up implemented: group move/copy/delete, creator-set spawn, working tower/cargo/socket/ring/light/portal parts and pressure presets. See [current iteration](../WORKSHOP-ITERATION.md). Remaining: group rotation/gizmo; load-time geometry validation beyond schema/spawn checks; saved-map launch shortcut; wheel contact on steep slopes; animation LOD and measured triangle/draw-call profiling. Networking remains separate.


Current controls and visual simplification: [Reveal and patrol pass](../REVEAL-AND-PATROL.md). Blackout moved to F7; E is mine, R is reveal; ambient tower patrols default on.
