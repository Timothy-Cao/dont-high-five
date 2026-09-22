# Pass 1 — Make the offered palm worth considering

Research date: **21 September 2026**. Documentation only. No multiplayer, interaction, input or balance change was implemented or tested in this pass.

## What changed my mind

**The high-five needs a reason to exist, but that reason need not always be a buff.** Valve's Portal 2 achievement descriptions explicitly celebrate cooperative gestures, including a high-five. That is a useful counterexample to our earlier absolute claim that the gesture must transfer a resource. It establishes a celebratory use, not evidence that an emote alone supports our proposed deception game. Keep a harmless celebration condition in the experiment rather than designing every friendly touch as a transaction. [Valve achievement definitions](https://steamcommunity.com/stats/Portal2/achievements/)

**Our strongest input hazard is already visible in local code.** `scripts/player.gd` fires the first glove immediately; a second button within 120 ms starts the charged punch. A contextual high-five cannot commit on that first click and then promise that a later punch cancels it: ownership may already have changed. Delaying every glove shot would compromise a movement property the user explicitly likes. This is a design contradiction in the previous proposal, not a bug in the current single-player game.

**A generic upward assist may already be redundant.** The current charged recoil reaches roughly 11.9 m from rest, preserves incoming speed and works alongside a double jump. The arena now has many 4–6 m increments. An eight-second stored jump is not automatically a useful favor. Its value must be compared against this actual controller, not a hypothetical character that cannot climb alone. [Local recoil evidence](../RECOIL-RAVE-PASS.md), [current arena](../ARENA-INFILL.md)

## New external evidence, with counterexamples

- **Hands can be the route itself.** Heave Ho's official description puts gripping friends and forming swinging chains at the center of traversal. That supports trying a physically legible assist; it does not establish that first-person camera control, hidden betrayal or our network conditions can tolerate forced body movement. Its explicit versus option also cautions against combining all social tones into one ruleset. [Official game description](https://store.steampowered.com/app/905340/Heave_Ho/)
- **Cooperation can create a shortcut rather than certify a task.** In a 17 February 2020 developer post, the Moving Out team describes adding cooperative throwing after testers tried to throw a large object over a balcony. Their 11 May instructions make the shared preparation and release observable. Adapt the opportunity to bypass architecture, not their precise timing or controls. [Developer playtesting account](https://store.steampowered.com/news/posts/?appids=996770&enddate=1584360589), [developer interaction instructions](https://store.steampowered.com/news/posts/?appids=996770&enddate=1591615244&feed=steam_community_announcements)
- **A friendly interaction can fail through input arbitration, not malice.** A PEAK thread opened 28 December 2025 reports a repeated hand/wall grab loop; a January reply describes holding the two relevant inputs while stamina repeatedly drains. A developer requests details and later says the report will be passed along. This is a dated report plus acknowledgement, not a reproduced bug or proof of its present status. For us: one press must resolve to one interaction, and a failed offer must not repeatedly consume anything. [Player report and developer replies](https://steamcommunity.com/app/3527290/discussions/2/687493456811011663/)
- **Do not mistake complaints for consensus.** A separate 19 August 2025 PEAK discussion contains both a proposed helping-hand change and a reply defending its current function. The indexed thread text was available; direct opening failed. This weak counterevidence prevents concluding that players broadly dislike physical helping. No prevalence is inferred. [Dated disagreement](https://steamcommunity.com/app/3527290/discussions/0/605290750430845669/)
- **Holding can be optional.** Moving Out's 6 April 2020 developer post describes hold/throw toggles and remapping. For us, a persistent offer mode should be cancellable with a second press rather than requiring a sustained hold as the only option. [Developer accessibility account](https://store.steampowered.com/news/posts/?appids=996770&enddate=1586857128&feed=steam_community_announcements)

These pages were read as text. Linked gameplay videos and animated images were not watched or measured. No claim about exact animation duration, aim assistance or current competitor netcode follows from this research.

## Why accept, once you know betrayal is possible?

An original decision model: accept when the immediate useful result exceeds the coordination cost, expected bounded sabotage loss and the value of the solo alternative. This is a way to ask questions, not a measured equation. Players need to see what they receive, understand what can go wrong, and retain an escape from the deal. More rewards will not repair an interaction whose consequences are incomprehensible.

| Candidate, tested separately | Why a cautious recipient might accept | Why the donor participates | Counterexample / failure test | Current judgment |
| --- | --- | --- | --- | --- |
| **Charge relay** | They already have a receiver or useful delivery route; a donor brings a resource they would otherwise retrieve | Their existing route crosses a partner's route, saving a round trip for the team | If the same expert can carry everything faster, or accepting is only a mandatory lockout rule, the gesture is paperwork | Best fit for deduction, conditional on a genuine route advantage |
| **Stored spring** | A clearly visible, recipient-triggered recovery helps finish a particular airborne approach | They rescue a teammate or share a route; start without a personal rebate | Compare against full recoil + double jump. If the recipient could do the same thing with no rendezvous, the offer is unnecessary | Best cooperative feel probe; not yet a superior movement option |
| **Bad Battery** | They deliberately bid for a visible remaining opportunity to score, with enough time to use it | They transfer both opportunity and a known burden | Refusal near expiry can be correct. If consensual passing stops, accept that result rather than silently making touch compulsory | Keep as a separate public-risk party experiment |
| **Celebration control** | It acknowledges a rescue or shared success without changing combat state | Same social payoff | Could be delightful but irrelevant to objectives; do not mistake applause for a deduction system | Include to test whether the literal gesture earns its complexity |

For **charge relay**, let a corrupt charge fault the destination equipment, not secretly invert movement or disable the recipient's controls. A handoff is proof of custody, never proof of alignment. Bound the repair loss, preserve completed progress, and let both factions make clean transfers. Do not create a universal partner tax merely to increase the number of claps.

For **spring**, do not steal a wall anchor or overwrite Space's existing jump queue. Test spending it on an otherwise exhausted airborne jump, with the recipient choosing the moment. That is a provisional trial condition, not a recommendation to add a third permanent jump. Also test whether people reserve it forever or spam reciprocal offers. Give no donor recharge rebate in the first test: the earlier rebate proposal could fund a stationary two-player boost farm.

For **Bad Battery**, an explicit acceptance cannot guarantee a pass at the last second. A neutral drop does not automatically solve this: it may let a losing carrier discard all consequence. The paper rules must state what cost remains with the carrier on expiry or discard, and whether a fresh receiver has any realistic scoring opportunity. Do not tune an infection mechanic before settling this incentive problem.

## Input experiments that preserve intentional movement

The user's mouse-hand fantasy remains the target, but input schemes must be compared rather than assumed safe.

**A — Mouse-first reciprocal offer.** Aim at an already-visible offered palm and use a fresh single-button action. Delay only the possible social commit until the local punch-chord window has resolved; ordinary wall shots remain immediate. The cost is contextual behavior: a player attempting a wall grapple behind a palm might be intercepted. An unresolved or cancelled social click must be consumed, never replayed as a punch or grapple. This experiment must earn its way past overlap tests before becoming a default.

**B — Explicit social intent, preferred safety baseline.** A rebindable Offer/Accept action (V is currently unused in the default bindings) raises a free palm or accepts the specifically aimed offer. Test a press-to-toggle version as well as hold-to-offer. Hand selection can preserve left/right visual identity without reusing the attack chord. It adds a key and weakens the literal click-to-high-five fantasy; that is its honest trade-off. Never release a planted hand automatically to make an offer.

**Reject for both:** using E to accept while E launches; using Space to accept while Space maintains bunny hops; auto-accept from a held climb/reel input; committing the handoff on the first mouse press and trying to undo it later; making every normal glove wait 120 ms.

Proposed state boundaries:

1. Offer contains a donor, one available hand, one visible token or explicitly empty palm, and an expiry. The receiver does not become attached simply by being targeted.
2. A **new** acceptance input selects exactly one offer. Repeated frames, held buttons and retransmitted messages cannot reapply it.
3. Commit validates range, clear path, arm availability and the token's unchanged ownership. No forced camera turn, teleport or velocity replacement accompanies it.
4. Failure changes no ownership or resource count. Leaving range, suppression, disconnect and explicit cancellation retire the offer.
5. A social-mode click is never deferred into a later attack. Re-arm the mouse only after the relevant buttons return to neutral. Do not retroactively cancel a completed transaction because an attack packet arrived later.

This is a proposed interaction contract, not a completed network specification. Start the first test at 3 m, compare 6 m afterward, and treat a readable stationary handoff as the baseline before testing crossing flight paths. Neither distance is justified by the marketing references.

## Cheapest next evidence

**First, a 15-minute rules-and-input storyboard with two people**, requiring no code changes: six approach situations, each presented with both schemes. Include a wall behind the offered palm, one hand already anchored, both buttons pressed, holding Jump during a landing, a cancelled offer and two donors offering at once. Ask what action each press should produce before explaining the intended rule. Disagreement identifies semantic risk; it cannot validate latency or feel.

**Then, only if the choices remain promising, a two-person interaction slice** with no hidden roles, one upper destination and a usable solo route. Run charge, spring and celebration as separate conditions, swapping their order and player jobs. Teach one exchange, then stop instructing players to cooperate. Ask whether they voluntarily repeat it and what it saved. Introduce one announced, bounded cargo fault only after ordinary cooperation works.

Record mistaken action, unclear ownership, voluntary repeats, rendezvous time versus solo route time, and unrequested velocity changes. Test local and simulated 80/150 ms RTT separately. Require zero duplicate ownership and zero unrequested movement in the scripted cases; these are correctness requirements, not player-preference statistics. Stop adding incentives if the failure is input ambiguity. Stop adding sabotage if the failure is absent friendly value.

**Decision for pass 2:** Keep Relay as the deduction candidate, but replace the mandatory alternating-operator justification with a concrete route advantage to test. Consider cooperative assistance a serious alternative. Carry forward the question: can a delivery create a useful rendezvous without penalizing the fun of solo movement?
