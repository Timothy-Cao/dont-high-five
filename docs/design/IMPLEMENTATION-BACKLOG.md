# Fiver / Watcher implementation backlog

Updated 2026-09-21. Source: [user brief](FIVER-WATCHER-BRIEF.md). The priority is the Fiver's traversal experience. These are staged decisions, not promises of a complete multiplayer game.

## This pass — movement contract and feedback

- Fixed arm mode: attachment automatically pulls from actual distance toward 5 m, with acceleration and braking. Alternate clicks alone traverse ceilings; no F/wheel management. No abrupt teleport. Separate geometric rope constraint from elastic force. E releases fixed anchors while retaining velocity. Alternate grips, with at most 0.3 s overlap after a successful new attachment; a miss preserves the old grip.
- Two-button chord recalls pre-existing extended hands; a fresh chord with idle hands charges a punch. No timing delay on individual shots.
- Nonlethal punches: additive knockback, one recipient impulse per paired attack, nearby self recoil. Dummies visibly topple and recover. This is a local interaction contract, not networking.
- Shift anchor; Ctrl keeps the existing brake; C wall grip. Ground anchor is immovable, airborne anchor drops quickly. Damage reduction waits for real health/damage.
- Charge wind-up, restrained full-charge fist vibration, ball shoulder sockets/curved forearms, bounded surface marks and speed afterimages. Small optional speed FOV.
- Disablement fields parked; station replenishment standardized to 30 s. Large map changes deferred.

## Next — a small teachable route and objective slice

1. One enclosed training route with four connected rooms: movement/jump; fixed rope/reel/ceiling transfer; elastic gap/ground punch; knockback dummy/anchor. Show ability and current binding only. Allow skipping and retrying. Build only after the controls settle.
2. One carryable ball: one hand occupied, free hand grapples, no two-hand punch while carrying. Start with a simple drop-off rather than a full quest system. Test whether carrying feels like an interesting traversal constraint or a punishment.
3. One Watcher tower, manual role switch, telegraphed delayed area strike plus basic aim. Stationary practice targets/Fiver route first. Measure exposure and escape time before adding weapons.
4. One coherent map district: thick structural walls, continuous floor-to-ceiling columns, suspended cover, one fast lane and a covered alternate. Consolidate to one maze during an authored layout pass, not by indiscriminately deleting existing routes.
5. Power stations and task shrines positioned against measured tower views. 20–30% per tower and 70–80% union are user hypotheses, not validated balance targets. Sample playable surfaces, including vertical routes; distinguish visible from actually shootable.

## Later — depends on multiplayer and playtests

- Reciprocal high-five: clear consent/input arbitration, healing and two-person station task. Avoid replacing a needed grapple accidentally. Full heal and lethal impostor high-five need a fairness playtest together.
- Watcher: 4–7 towers, A/D and number selection; sniper/MG; grenades; delayed blast; temporary blackout; auto towers; eye disruption; robot infiltration. Introduce one weapon at a time, then counterplay. Automatic unavoidable fire plus movement-constraining tasks is a red flag.
- Fiver HP, weak initial damage, three-second test respawn / twenty-second match respawn; anchor damage resistance. Respawn timing is a test parameter, not a settled penalty.
- Toggle 2 punch/zip: deliberately deferred because it doubles chord meaning while recall/punch is changing. First establish whether fixed reel already supplies the useful movement role.
- Laser rivers/sweeps, slow gates, crushers; arm/leg restrictions; invisibility/toughness/anti-disable powerups. No stacking all hazards before testing readable movement lanes.
- Maintenance minigames, ring objectives, shared team quota, dummy task, task discovery.
- Editor-friendly modular map kit / scene-authored district roots. Collaborate using a top-down blockout + height levels + desired movement moments before dressing it.
- Network authority, synchronization, remote pose/trails, latency-safe punches/high-fives. Local dummies do not validate multiplayer fairness.

## Rejected for this pass

- Instantly enforcing a 5 m rope on a 25 m attachment: teleports or a violent unearned acceleration.
- Detaching the old ceiling grip when the replacement misses: unnecessarily punishes aiming and makes traversal unreliable.
- Adding sniper, grenades, blackout, AI towers and impostor simultaneously: too many reasons a traversal playtest might fail.
- Dense first-person speed lines: wait to see whether 5 degrees of FOV and world-space afterimages communicate speed well enough.
- Rebuilding the whole arena before the new rope is measured: the resulting layout would encode untested traversal assumptions.
