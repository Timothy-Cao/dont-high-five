# Cheap experiments before a full multiplayer game

No human results are recorded yet. Thresholds below are provisional gates, not validated standards. Keep the ordinary movement playground available regardless of the chosen social mode.

## Experiment A — two friendly players, ten minutes

Build only two networked bodies, wall grapples and a single charge high-five. Disable damage and hidden roles. Put one charge source and two receivers at different heights with a safe ramp connecting them.

Ask players to transfer three charges, then let them choose whether to cooperate or carry alone. Observe the first offer, acceptance, cancellation, miss, repeated click and attempted transfer through a wall. Ask each player to explain the result without coaching.

Record offer-to-accept latency, accidental punches, declined offers, duplicate transfers, unclear ownership, voluntary repeat exchanges, and whether either player felt control was stolen. Try host/client latency conditions separately: local, about 80 ms RTT, and about 150 ms RTT with moderate jitter. These are future test conditions, not completed measurements.

**Advance when:** both players can perform and cancel an exchange unaided, no duplicate charge exists, accidental punch rate is acceptably low, and both choose at least one additional cooperative exchange when a solo route exists. If acceptance remains awkward, test one optional acceptance key before adding another mechanic.

## Experiment B — moderated six-player rules test

This can run on paper, a shared diagram or a moderator-controlled prototype. Do not wait for netcode to test the objective incentives.

### Materials

- Six robot tokens, three circuit cards, three fuse tokens, one transferable charge token per active source.
- Five good-role cards and one saboteur card.
- A route diagram with three districts, an upper/lower shortcut, a wash bay and a red field room.
- Eight-minute visible clock, a public delivery ledger, and private corruption marker held by the moderator.

### Rules to read aloud

“Power three circuits and open the exit before the timer runs out. One of you wants the shutdown to finish. Carry a fuse, get a charge from a partner, and deliver it. You can inspect a charge in the wash bay. A completed circuit stays completed. A failed receiver tells you which object arrived and who last delivered it, but not who tampered with it. You can talk at any time.”

Each travel edge consumes a short, announced interval. The moderator should use identical travel rules for both factions. The saboteur can secretly mark **one charge they actually handle** as corrupted and gets another use only after a public round event; they cannot arbitrarily mark any player’s token. A corrupted deposit fails after a delay and consumes a bounded repair step. Use no player killing in this first test.

Play twice with swapped roles. Round two removes corruption entirely but does not reveal that until the end; do this only with prior consent that the moderator may vary the hostile tool. This compares ordinary route confusion against intentionally planted ambiguity without pretending the results are a controlled study.

### Moderator event record

| Time | Object ID | Actor | Physical action | Public evidence | Private truth | Player explanation afterward |
| --- | --- | --- | --- | --- | --- | --- |
| 01:20 | Charge C2 | Robot B | Receives charge from A | Palm pulse; custody changes | Charge clean | “A helped me reach the receiver” |
| 02:00 | Charge C2 | Robot C | Inspects at wash bay | Cradle busy | No tamper | “C might have delayed us” |

Rows above are illustrative examples, not playtest observations. Record actual events in a separate dated file.

### Ask afterward

What made you choose a partner? Which physical action changed your suspicion? Did you have a useful alternative? Was being good interesting? What were you doing during your least interesting minute? Which moment would you tell someone about? What did you misunderstand that the reveal clarified?

Avoid asking only whether it was “fun.” Look for concrete moments and decisions, then listen to preference.

## Adversarial rounds

Run short attempts at deliberately degenerate strategies:

1. Everybody groups from start to finish.
2. Two strong movers perform everything while others wait.
3. Nobody accepts a high-five.
4. Saboteur does no tasks and camps an exit.
5. Good players attack the first person who looks suspicious.
6. Everyone hides in the suppression room.
7. All players use an external voice channel and share exact locations.

If the game relies on friends pretending not to use an obvious strategy, its rules need work. External voice should weaken proximity information but not make the objective impossible. Dead-player participation must not rely solely on forbidding Discord messages.

## Metrics with interpretation

| Measure | Why record it | Failure signal |
| --- | --- | --- |
| Meaningful encounters per player per minute | Map density | Long travel with nobody to meet |
| Time spent using movement versus standing at task UI | Preserve the current strength | Most progress occurs in menus |
| Longest non-participating interval | Party-game inclusion | A player waits through a substantial part of the round |
| Accepted offers / meaningful offers | High-five value | Refusal is the only sensible choice |
| Accidental attack / intended transfer | Input ambiguity | Friendly interaction damages others often enough to undermine trust |
| Rescues attempted and completed | Good-player agency | Downing is effectively elimination |
| Accusations revised after evidence | Deduction quality | Decisions never change or evidence proves a role immediately |
| Chase duration and escape route variety | Movement balance | Infinite disengagement or unavoidable cornering |
| Objective participation by player | Skill gap | One expert completes everything |
| Replay preference by faction | Majority-role appeal | People only want another round as saboteur |

Do not optimize these in isolation. High encounter count can mean spawn camping; frequent high-fives can mean mandatory chore spam.

## Technical order if the social test earns it

1. Authoritative movement snapshot for two players; remote bodies and palms must read clearly.
2. Atomic, consensual high-five charge ownership with clear cancellation.
3. One physical cargo object, one receiver and one wash station.
4. One private saboteur bit plus one tamper action. Verify it is absent from unrelated client messages.
5. A complete six-player round, reconnect handling, a factual reveal log and minimal lobby.
6. Nonlethal combat/rescue, then one escape tool if necessary.
7. Proximity voice after testing the game with ordinary friend voice; avoid making voice infrastructure the first dependency.

Only then decide whether the entire large map, additional rooms, weapon spawns and more roles earn their cost.
