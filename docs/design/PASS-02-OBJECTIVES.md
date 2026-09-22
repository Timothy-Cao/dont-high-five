# Pass 2 — make the job change how you move

Research run: **2026-09-22 03:39 UTC / 2026-09-21 Pacific**. Documentation only. This follows the user's Fiver-versus-Watcher direction and the now-implemented local pilot, rather than the earlier hidden-traitor recommendation. No game was launched or edited, and no human session was observed.

**Recommendation: deepen one-handed delivery and elevated route repair.** Use rings as the movement-only comparison. Keep healing high-fives as useful encounters along those routes; do not require a partner at every delivery. A good job should give the player an interesting journey and change something they can see, rather than reward standing still at its end.

## Evidence that changes the choice

| New evidence actually read | Design inference for Don’t High Five | Transfer limit |
| --- | --- | --- |
| Valve's 18 August 2015 PASS Time introduction replaces the carrier's weapons with a ball while using passing and movement aids. [S29](SOURCES.md#s29) | Hand occupancy can create a role without making the carrier slow. Give a carrier something enjoyable to do with the free hand. | Our one-hand movement is not TF2's weapon replacement; its initial carrier bonuses are historical, not current rules. |
| Later official PASS Time notes add benefits around teammates and passing, plus recovery from abandoned or monopolized balls. [S30](SOURCES.md#s30), [S31](SOURCES.md#s31) | Physical cooperation needs incentives and failure recovery; a ball does not automatically create teamwork. | Do not import punishment for solitary carriers. Our appeal includes independent exploration. |
| Embark's September 2024 design retrospective describes delivery losing strategic value when nearly all reward arrived at the end; it changed deposit incentives. [S32](SOURCES.md#s32) | Bank completed delivery work. A Watcher can interrupt the next attempt without erasing the entire previous trip. | A many-team cashout game is not our asymmetry. Its payout ratios are not our tuning. |
| Embark's February 2026 change explicitly pairs objective origins and destinations to improve encounter distribution. [S33](SOURCES.md#s33) | Select a meaningful origin–destination route, not two independent random points. | Their distance targets do not transfer to our grapple speeds or enclosed floors. |
| Ghost Ship's October 2020 Refining announcement makes constructed objective infrastructure usable for travel. [S34](SOURCES.md#s34) | Completing maintenance could open a shortcut the team actually uses next. | Do not build an entire pipeline construction system or copy repair downtime. |
| A 5 December 2020 player thread praises task division but disagrees sharply over efficient tunnels versus maneuvering room. [S35](SOURCES.md#s35) | A short route can be tedious or dangerous; distance alone is an inadequate objective metric. | These are conflicting player accounts, not a measured consensus or present-day balance claim. |

The last two references challenge a tempting simplification: neither “more open is better” nor “shortest is best” survives automatically. Our test should record why someone chose a route, not congratulate them only for being fast.

## Six physical objective sketches

All changes in this table are **proposals**, including any map consequences. The current pilot already contains simpler examples of the first five categories; it does not contain the full versions below.

| Sketch | What the hands and body do | Watcher opportunity / High Fiver response | Outcome and verdict |
| --- | --- | --- | --- |
| **1. Carry a service ball** | Grip a ball with one hand, swing around a column with the other, choose an exposed upper crossing or covered ramp. Drop deliberately to regain punch, then recover. | Attack a crossing; carrier ducks into an alcove or an unladen ally disrupts an eye. | Seat the ball and bank one delivery immediately. **Choose first.** It directly tests the user's one-hand premise. |
| **2. Thread a route through rings** | Enter from either side, chain a turn, a rise and a drop; no minimum speed or mandatory trick. | An eye sees one segment, not all three; player chooses entry timing or a second approach. | Each unique ring counts once. **Keep as baseline/optional circuit.** Cheap, but repeated laps must not become the universally safest score farm. |
| **3. Repair an elevated bypass** | Reach a sheltered ledge, then hit three separated world-space contacts from different sightlines. One free hand remains useful for support. | Pressure the approach and exit; allow abandoning the task without losing finished contacts. | Retract a shutter to reveal an existing ceiling lane. **Choose second.** Replaces a detached minigame with a spatial job and visible route payoff. |
| **4. Knock a dummy into its docking bay** | Charge a directional punch while choosing where to stand; approach from above or behind. | Commit to a punch near a visible bay, then recoil into cover. | A dummy seated in the bay completes once. **Defer variant.** More physical than a KO count, but precise target placement may fight a deliberately exuberant punch. Current KO remains the low-cost comparison. |
| **5. High-five at a rendezvous** | Arrive at a two-exit refuge, release traversal hands intentionally, offer/accept, heal, leave by different routes. | Watcher watches the approaches; infiltration complicates trust only in a later condition. | Preserve the user's station-task example, but **do not make it the universal progress gate**. Healthy partners should be allowed to keep moving. Full heal plus lethal impostor remains an unresolved incentive conflict. |
| **6. Retrieve a fallen relay piece** | Descend into a nook, pluck a loose piece from a shelf, carry it back by a different elevation route. | Watcher can zone the return route; another exit prevents a recovery trap. | Return it to a nearby socket. **Merge into delivery placement variety**, not a separate collectible currency or another task system. |

This removes two disguised progress bars: holding interact at a high wall does not become interesting just because reaching it was hard; waiting for a second person inside a station is not automatically cooperation. A short pause can provide welcome breathing room, but should be justified as pacing rather than mislabeled movement gameplay.

## Selected example A: the one-hand courier

Imagine taking a bright ball from a low cubby. The nearest socket is across a tall atrium. You can circle a broad column one-handed and skim the balcony, or take a covered ramp around it. The eye turns toward your crossing. You drop the ball onto an alcove shelf, punch the floor to gain height, and come back for it from above. A teammate can instead draw attention or meet you at the next ledge. The interesting part is deciding when an occupied hand is worth keeping.

Proposed contract:

- No generic carrying speed penalty, forced buddy leash, charge decay or extra carrier damage. One occupied hand is the first constraint to test.
- Allow a fully solo route using the remaining hand. Cooperation buys safer timing or a shorter journey; it is not an invisible lock.
- A committed delivery stays done. A failed attempt leaves recoverable cargo rather than resetting the whole team.
- In a future round, recover genuinely unreachable/lost cargo to a marked shelf after a visible grace period. Do not teleport it out of an active carrier's hand. The exact timer needs testing.
- Do not add throwing yet. First compare carry, deliberate drop and retrieval. The present pilot releases cargo during portals and launch pads; record those events separately because they can masquerade as player mistakes.
- If handoff is added, require receiver intent and exactly one owner. Do not overload a friendly high-five with an undisclosed automatic cargo transfer.

**Failure case:** everyone drops the ball, performs the same punch jump, picks it up, and repeats. That is input tax, not tactical freedom. First revise the route so one-hand swings work; only then consider a transfer or carry rule change. Conversely, if carrying is identical to unladen movement, it may not justify a separate mission type.

## Selected example B: repair the way out

Imagine seeing an attractive ceiling passage behind a shutter. The repair contacts sit on three faces of its support column. You hook above the first, swing around the second, and land in the sheltered third recess. Each contact latches once; the shutter opens visibly onto the route you wanted to use. Another High Fiver benefits without waiting beside you. The Watcher gets a newly important crossing to watch rather than a frozen player to farm.

For the cheapest future implementation, reuse existing maintenance nodes and authored architecture. Spread the contacts spatially; reveal one prebuilt bypass. No construction inventory, simulated wiring or moving bridge physics. Each completed contact remains latched, and the ordinary route remains available before repair. Show the effect from the final contact so the player need not read a task explanation to understand the reward.

**Failure cases:** if the bypass is irrelevant, this is decoration; if it is the only way to finish, the task is a compulsory key hunt; if repairing requires aiming at tiny targets while swinging, it becomes an aiming test rather than route planning. Generous contact surfaces and an optional stable perch let movement skill improve efficiency without being an entry requirement.

## A quota needs more care than seven equal counters

The current seven-point sampler is valuable for visiting mechanics, not a balanced round economy. One nearby ring, a long carry and a partner-dependent high-five have different costs. Do not infer a fair score from the fact that each can increment an integer.

For a future moderated comparison, try a finite board of distinct jobs, with two viable jobs available in different areas. Record useful work per minute and abandoned attempts before setting rewards. Keep team progress shared and completed work persistent in this first comparison. Do not add mandatory task-type quotas simply to force testers to use the least enjoyable activity. If everyone avoids a job, that is evidence to investigate.

The Watcher must have a reason to interrupt unfinished work, but camping one delivery socket must not lock out every remaining job. Whether two destinations, temporary access or another objective solves that is a **pass 3/4 question**, not settled by adding all three now.

## Cheapest next falsifying playtest — proposed, not run

Use the **new local source prototype**, not published v0.2.0, which predates cargo, tasks and role switching. This research run changes neither version.

1. Ask the existing tester to learn one route empty-handed, then repeat it carrying the current ball. Let them choose a covered or exposed approach. No Watcher fire initially. Repeat in reverse order on a second route to reduce practice bias.
2. Compare with the current rings. Record whether cargo causes a deliberate route decision or merely repeated dropping and walking. Offer a choice of one more ring run or one more delivery without a reward difference; ask why.
3. Repeat only after that with optional auto-fire. This checks readable pressure and traversal, **not a human Watcher's fairness**. Log involuntary cargo losses separately from chosen drops.
4. Evaluate the proposed repair variant using a simple drawn sequence and the current elevated maintenance approach. Ask the tester to point out the shortcut and predict what completing contacts would change. A storyboard cannot establish motor feel; defer that claim until implemented.
5. For cooperation, wait for an authorized two-human prototype. A simulated partner can check input cancellation but cannot establish whether people seek or refuse help. No networking is requested by this research note.

Suggested observations, not established thresholds: route completion time; time standing/walking versus arm traversal; intentional versus unexpected drops; recoveries; warnings noticed; reasons for route selection; willingness to repeat. Compare each player to their own empty-handed baseline. A tiny test is qualitative evidence, not a statistically reliable preference survey.

**Stop criteria:** if a tester cannot tell what their free hand can still do, fix ownership feedback before adding jobs. If the route requires repetitive drop–punch–retrieve despite understanding the controls, change the route or cargo constraint. If movement is enjoyable without a job but unpleasant with it, do not solve that by increasing the reward.

## Next pass

Pass 3 should examine pressure windows and counters: what can the Watcher threaten while a carrier has one hand, how can a repairer abort safely, and when can high-five healing become too safe or too risky? Compare the current local warning timings to actual escape actions, without treating the existing 524 automated assertions as evidence of competitive fun.
