# Overnight research queue

Initial notebook created 2026-09-21. Continue research and critique while the user sleeps; preserve the current playable build. Record genuine additions, rejected assumptions and direct sources. Do not turn every proposal into gameplay or publish an untested multiplayer claim.

## Focused passes

| Pass | Question | Deliverable |
| --- | --- | --- |
| 1. High-five | Why would a cautious player accept after learning sabotage exists? | Compare charge relay, stored spring and hot potato with explicit incentive/failure cases |
| 2. Objectives | What jobs naturally use one free hand, vertical routes and another player? | Six physical objective sketches; choose two; remove any that are disguised progress bars |
| 3. Antagonist | How can a discovered saboteur remain interesting without simply becoming a better shooter? | One stealth-to-chase transition and a counterplay matrix |
| 4. Spaces | Which room arrangements create witnesses, brief isolation and rescue paths? | A compact three-district social layout using the existing map |
| 5. Synthesis | Which idea survives criticism, and what should we test next? | Short morning discussion brief, strongest three choices and the cheapest falsifying test |

Use primary game descriptions and developer material for mechanics. Seek both positive player accounts and failure cases, date them, and distinguish anecdotes from established rules. Inspect official gameplay sequences when accessible; do not invent observations from marketing text. No need to contact anyone or use the user’s desktop.

## Hard questions still open

- Is accepting a charged hand useful enough without making the transfer mandatory?
- Is a six-metre interaction range readable while both players are airborne?
- Does the current punch chord conflict with friendly acceptance?
- Should any sabotage affect a player directly, or only their carried object?
- What is the smallest honest clue that makes a bad handoff investigable?
- Can a victim return quickly without revealing everything they saw?
- Can the game remain good when the group uses Discord?
- Does the large map become lonely at six players even with portals?
- Does requiring cargo to occupy a hand add a decision or just remove the fun movement?
- Is the high-five stronger as cooperative assistance than as betrayal? Be willing to change the recommended mode.

## Future run log

Append dated results below or add a short linked file per pass. Do not label a pass complete until it has new evidence or a reasoned revision. Keep this notebook’s proposed-versus-implemented distinction intact.

## Pass log

### Pass 1 complete — 2026-09-21, run triggered 09:22 UTC

Deliverable: [Make the offered palm worth considering](PASS-01-HIGH-FIVE.md). New source entries: S18–S24, covering Heave Ho, three dated Moving Out developer posts, PEAK player/developer thread evidence and Portal 2's gesture achievements. Primary text and explicitly limited player accounts were used; no video timing or gameplay observation is claimed.

Substantial revisions:

- A high-five can have celebratory value without granting a buff. Include that counterexample instead of treating resource transfer as a universal requirement.
- Existing code fires the first glove immediately and recognizes a second-button punch chord within 120 ms. Immediate friendly commit plus later chord cancellation is contradictory. Compare mouse-context acceptance with explicit social intent; preserve immediate ordinary glove fire.
- Current 11.9 m recoil and double jump may make a generic stored spring redundant. Test against the actual controller. Defer the donor recharge rebate to avoid reciprocal farming.
- Charge relay needs a real route advantage, not a forced alternating-operator interlock. Consensual hot potato still has an unresolved late-fuse/refusal/discard incentive problem.
- Added a cheap input storyboard, separate payoff conditions and concrete duplicate-commit/failed-offer failure tests. These are proposed tests, not human findings.

Only design documentation changed in this run. No gameplay edits, launches, desktop/browser control, messages, installs, publication or push. Current implementation evidence was read from prior local pass documentation; it was not rerun.

**Series status: 1 / 5 passes complete.** Next run: pass 2, movement-integrated objectives. Start from the open question of how a useful cargo rendezvous can preserve enjoyable solo movement; do not repeat the high-five survey. Remaining afterward: antagonist/counterplay, compact social spaces, morning synthesis. End the bounded series after pass 5 or completed synthesis.

### User steering after pass 1 — notes for tomorrow, not another completed pass

Read [TOMORROW-DISCUSSION.md](TOMORROW-DISCUSSION.md) before the remaining research passes. The user proposes movement quests (hoops, items, dummies, ball delivery), carrying a ball with one hand while retaining the other for pulling but losing two-handed punching, and a powerful antagonist with possible rifles, flight, delayed area explosions and laser vision. Good players use speed, hiding and nonlethal punches that knock out the antagonist.

Pass 2 should compare these concrete quest types; pass 3 should examine their asymmetric tools and counterplay. Treat a revealed hunter as a legitimate alternative to the earlier hidden traitor. Do not assume the complete arsenal, high-five purpose, win conditions or knockout rules are decided. Keep all work documentation-only. This steering does not increment the five-pass count.

## New steering — 2026-09-21 High Fiver / Watcher brief

The user has now selected an overt Fiver-versus-Watcher working direction, with optional infiltration during blackouts. Read [the new brief](FIVER-WATCHER-BRIEF.md) and [backlog](IMPLEMENTATION-BACKLOG.md) before the next pass. Movement implementation is being handled in the active development turn; the overnight series remains research/documentation only. Do not count this implementation pass as another overnight research pass.

Pass 2 should compare carry-one-hand, rings, elevated maintenance, dummy knockback, and a cooperative high-five station under tower pressure. Pass 3 should test readable counterplay against fixed-tower fire, delayed zoning and infiltration, including why an overloaded arsenal could feel unavoidable. Pass 4 should evaluate sightlines, refuge-to-refuge routes, exposed stations and layered cover; tower coverage percentages are hypotheses. Pass 5 should synthesize three variants within the user's High Fiver / Watcher direction, not silently revert to a hidden-saboteur-only game.

### Pass 2 complete — 2026-09-22, run triggered 03:39 UTC

Deliverable: [Make the job change how you move](PASS-02-OBJECTIVES.md). New sources S29–S35: primary PASS Time possession/incentive changes, Embark's cashout incentive and route-pairing explanations, Ghost Ship's objective/traversal integration, and a dated DRG player thread with genuine disagreement. Failed Reddit retrievals and absent gameplay observation are disclosed.

Compared six objective sketches and selected **one-hand delivery plus elevated route repair**. Rings remain the movement-only baseline; station high-fives remain optional encounters rather than a universal gate; dummy docking is deferred; loose collection becomes delivery variety. Rejected extra carry slowdown, forced partner proximity, all-or-nothing task resets, hold-to-repair disguised as movement, and treating seven equal counters as a balanced economy.

The playtest proposal explicitly distinguishes the published movement-only v0.2.0 release, current local task prototype, and unimplemented route-repair consequences. No study was conducted. The existing cargo drop behavior around pads/portals is an identified confound, not silently accepted balance. Proposed observations prioritize intentional route choices and movement pleasure over speed alone.

Documentation only: no gameplay edits, engine runs, desktop/browser control, messages, installation, publication or push. Updated the notebook index to remove stale claims about the earlier suppression room and unimplemented local roles.

**Series status: 2 / 5 passes complete.** Next: pass 3, Watcher advantages and High Fiver counterplay, especially one-hand carrier escape options, repair interruption, and healing versus lethal infiltration. Then compact social spaces and morning synthesis. Do not count the intervening implementation/release work as overnight passes. Stop after pass 5 or completed synthesis.
