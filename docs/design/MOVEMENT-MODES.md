# Movement modes — decisions, research and limits

2026-09-21. Implementation design for the local Fiver pass. [Full brief](FIVER-WATCHER-BRIEF.md), [staged backlog](IMPLEMENTATION-BACKLOG.md).

## Research that changed the implementation

- **Primary, dated patch:** Blizzard's [April 16, 2024 Overwatch patch notes](https://overwatch.blizzard.com/en-us/news/patch-notes/live/2024/04/) describe Wrecking Ball retracting an attached grapple through a separate held input, with rebinding. Developer comments explicitly seek approachability alongside skill expression. The official search extract was accessible; direct-page retrieval returned 403. We borrow the separation between anchoring and intentional retraction, not its cooldowns or undocumented physics.
- **Primary product description:** the [SpeedRunners developer/publisher Steam page](https://store.steampowered.com/app/207140/SpeedRunners/) describes swinging, competitive traversal, a tutorial and super-speed trails. This supports using speed as a visible state and teaching a few contextual actions. It does not supply a 3D rope equation or prove that our map is fun.
- **Dated player account / counterexample:** [“How do you properly use the grappling hook?”, September 3, 2016](https://steamcommunity.com/app/207140/discussions/2/350540973994535190/) begins with a player mistaking advanced movement for a glitch. Replies discuss timing and vertical-to-horizontal motion, and warn that badly timed repeated input can kill momentum. This is an anecdote about comprehension, not authoritative SpeedRunners source code. Our inference: expose the mode and rope length, avoid hidden speed awards, and teach release timing before adding a second attack mode.
- We did not equate SpeedRunners' opponent-targeting Golden Hook with its terrain grapple. We also did not infer an implementation from the GDC Spider-Man PDF: the web tool could not retrieve the oversized document.

## Two distinct contracts

**Elastic:** existing stretch and slack, stored energy, deliberate reversal through E. Both hands can stay attached. The wheel changes rest length gradually. Ground braking and slow self-propelled acceleration stay intact.

**Fixed:** 1 toggles the mode. A successful attachment starts at the player's current distance, then automatically shortens toward 5 m; closer grips remain short. Alternate clicks alone traverse a ceiling. Manual F/wheel controls apply only to elastic mode. Tangential motion follows an arc at fixed radius. Outward radial velocity is removed, not magically converted into an arbitrary sideways boost. Gravity naturally becomes sideways motion during a pendulum swing. Inward movement can slacken the rope. E releases without changing velocity.

This is a collision-aware arcade constraint, not a full rope simulation: no wrapping around columns, self-collision, catenary solver or rope segments. A straight tether stops a newly obstructed crossing. The body still moves through CharacterBody3D collision. Reeling into an obstruction cannot teleport the body or keep winding an impossible shorter rope.

During alternating ceiling grips, the newly attached hand owns the constraint. The previous hand remains visible for at most 0.3 seconds, then releases. We intentionally wait for a successful attachment rather than dropping the old grip on a miss. The user clarified that manually shortening each grip was unacceptable for ceiling traversal. Automatic acceleration and braking now reach 5 m without an instantaneous snap.

## Input and combat contract

The first individual glove shot is immediate. The first mouse-down records whether any arm was already extended; a second down within 120 ms either recalls those existing arms or starts a charge from idle. This distinction cannot inspect only the second event, because the first event has already fired a glove. A recall chord never falls through into a punch. Both buttons must come up before another chord.

Punches carry no damage. Two parallel fists award at most one additive impulse to each recipient per attack, even if both fists touch it. Nearby geometry/targets still supply one bounded self-recoil budget. Dummies move through collision, visibly compress/tip, then reset after 1.5–3 seconds. The local player exposes the same knockback receiver; no network transport or remote authority is claimed.

Shift anchors on ground and cancels horizontal movement during a fast drop in air. Anchoring blocks incoming punch impulses and automatic launch pads. Ctrl remains the old brake; C takes wall grip. Half damage while anchored is deferred until a real damage model exists.

## Presentation budget

Five-degree speed FOV with its existing comfort toggle; six pooled frozen-pose afterimages with 0.30 s lifetime above 14 m/s; twenty-four maximum 12 s surface stamps. Full charge has subtle fist-only vibration rather than camera shake. Ball arms use shell-level sockets and thicker curved idle forearms. Trails are local cosmetic work; multiplayer replication is future work.

## Cheapest useful human test

1. Enter fixed mode, grapple a high edge while falling, coast under it and release with E. Is the trajectory predictable?
2. Traverse three ceiling grips, miss one replacement on purpose, and let it automatically shorten. Does preserving the old grip feel helpful or too forgiving?
3. Recall both extended arms with a chord, then charge a ground punch. Does the change of meaning surprise you?
4. Punch a nearby dummy, then one farther away. Can you distinguish target boost from self recoil?
5. Try Shift on a pad, then release; compare Ctrl brake and C wall grip. Decide whether all three are worth keeping.

Success is player comprehension and enjoyable chaining, not passing a numerical test. Watcher weapons, high-five healing, objectives, training rooms and an authored tower district are staged next; their balance cannot be inferred from this local pass.
