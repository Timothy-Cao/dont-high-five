# Don’t High Five — design notebook

**Research pass: 21 September 2026. These are proposals for discussion, not implemented multiplayer features.**

The strongest pitch is: **Your hands are how you travel, help your friends, and decide whom to trust.** You are stretchy little playground robots trying to restart a closed neon attraction. Someone is making sure it stays closed.

Imagine this moment: you are hanging under a balcony with a charged glove. A friend arrives above you and offers a palm. You can take the quick handoff, climb the slow ramp, or ask them to come down where someone can watch. Later the receiver fails. Was the charge already bad, did your friend switch it, or did the station get sabotaged? Those are actions players can investigate, not arbitrary lies from the game.

**Latest user direction (2026-09-21): Fivers vs Watcher.** Nimble robots complete physical tasks while a powerful opponent controls fixed towers, with occasional blackout/infiltration. This supersedes Blackout Relay as the current working direction; older pages remain research alternatives. Read the [full new brief](FIVER-WATCHER-BRIEF.md), [implementation backlog](IMPLEMENTATION-BACKLOG.md), and [movement decisions and sources](MOVEMENT-MODES.md). The local pilot now includes role switching, tasks, cargo and simulated high-fives. Networking and human reciprocal high-fives remain unimplemented. See [current implementation evidence](../LOCAL-PILOT.md).

## Start here

1. [Three directions and a recommended round](ROUND-DESIGN.md) — objectives, good-player agency, antagonist tools, and why movement belongs in the loop.
2. [High-five experiments](HIGH-FIVE.md) — exact inputs, payoff, consent, counters and rejected versions.
3. [Rooms and toys](ROOMS-AND-TOOLS.md) — twelve spaces with reasons to visit, risks and escape routes.
4. [Research and source ledger](SOURCES.md) — thirteen game references, primary evidence, player criticism and confidence limits.
5. [Playtest kit and failure tests](PLAYTESTS.md) — a short moderated experiment before building a whole online game.
6. [Pass 1: incentives and input conflicts](PASS-01-HIGH-FIVE.md) — new evidence, counterexamples and revisions to the first handoff experiment.
7. [Pass 2: movement-integrated objectives](PASS-02-OBJECTIVES.md) — six physical jobs, two recommended experiments and failure criteria.
8. [Overnight research queue](OVERNIGHT.md) — questions to deepen without turning every idea into a feature.

## Direction contract

| Element | Working choice |
| --- | --- |
| North star | A silly, readable physical interaction becomes a meaningful act of trust |
| Fantasy | Elastic toy robots taking risky shortcuts through an after-hours attraction |
| Primary verb | Place a hand; choose whether to pull, transfer, accept, or let go |
| Pleasure | Controllable movement, a well-timed assist, a narrow escape, a convincing bluff |
| Tension | The person who makes your trip easier may be creating your next problem |
| Payoff | Deliver a real object, save a teammate, catch a sabotage, improvise an escape |
| Initial audience | Friends on keyboard/mouse: mobile Fivers versus one tower-bound Watcher; player count and round length unresolved |
| Tone | Playful suspicion with flashes of danger; avoid horror that punishes exploration |
| Non-goals | Public matchmaking, dozens of roles, perfect disguise simulation, a huge weapon catalogue |

Player count and round duration are starting hypotheses. The present map is a movement playground, not proven six-player level design. It may need a smaller active region for social rounds while remaining fully explorable in free play.

**Fun hypothesis:** When another player offers a useful high-five, accepting it should change a route or objective immediately enough that players actively seek another exchange, while the possibility of tampering creates a decision they can explain afterward. A high-five that merely increments a task counter fails this test.

## What exists today

The [published v0.2.0](../RELEASE-0.2.md) is the stable movement snapshot with afterimages and automatic fixed arms. The newer [local pilot](../LOCAL-PILOT.md) additionally includes cargo, seven task points, simulated healing high-fives, local Fiver/Watcher switching, seven eyes and weapons, optional auto-fire, health/respawn, and nine Training rooms. Its 12 suites / 524 assertions are implementation checks, not evidence of multiplayer enjoyment; this research run did not rerun them.

Networking, human reciprocal input, voice, full round rules, and the new objective consequences in pass 2 remain proposals. Arm/leg suppression zones were removed. The high-five test partners are local simulations; screenshot staging and bots do not imply working multiplayer. The [backlog](IMPLEMENTATION-BACKLOG.md) is the detailed implemented-versus-proposed reference.

## Earlier recommendation — archived alternative

This predates the user’s Fiver/Watcher choice. The current objective recommendation is [one-hand delivery and elevated route repair](PASS-02-OBJECTIVES.md), to discuss and test before expanding match rules. The following remains an alternative, not the active implementation plan.

Begin with **Blackout Relay**: recover and hand off physical charge, complete three circuits, then escape. Keep the first antagonist kit to one tamper action and one conspicuous emergency overclock. Try a pure cooperative version first: if the handoff is not fun when everyone is friendly, hidden roles will not fix it.

The best alternative is a tiny **Hot Potato** party mode. It is less ambitious and tests whether chasing, passing and avoiding a high-five are enjoyable with the current movement. It could become a useful multiplayer test mode even if Relay becomes the main game.

## Decisions changed by research

- **Do not let the first random gun decide the match.** A dated Lockdown player discussion describes precisely this frustration. Start with universal defensive ability and scarce situational tools, then test their agency rather than assuming a gun economy is needed. [Evidence](SOURCES.md#s14)
- **Do not equate map size with quality.** Grapple Tournament’s developers explicitly discuss long-range pursuit and empty-space problems. Keep the large free-play map, but measure contact frequency and chase outcomes before using all of it in six-player rounds. [Evidence](SOURCES.md#s07)
- **Make cooperation physically useful.** PEAK’s rescue premise and Webbed’s manipulable connections suggest hands should change what a partner can accomplish, not just sign off a chore. [Evidence](SOURCES.md#s08)
- **Protect the session after failure.** Clocktower retains meaningful participation after death; our implementation cannot copy its information rules blindly, but early elimination should not mean ten minutes of watching. [Evidence](SOURCES.md#s12)
- **Do not use the red room as a role scanner.** A room that only the killer can escape with arms will be used to inspect everybody. Equipment rules should be public; exceptions should be costly, observable and obtainable by more than one role.

## Reuse from the existing research

The earlier workspace concept *Hidden-Reality Social Horror* supplied two valuable principles: grouping versus splitting should be a repeated choice, and contradictory evidence needs bounded explanations. This project adopts those principles, not its full list of hauntings, body swaps or changing identities. Those mechanics would make our already-fast 3D world harder to read and are deferred. This notebook is self-contained; it does not require the old research repository to run or understand the game.

## Workflow review

The existing conversation already settled camera, tone, movement, engine and first-pass art priorities, so another direction interview would add little. The design skills were useful for separating evidence from hypotheses, keeping the menu small, and treating control loss as a visible state. The danger was scope inflation: a thirteen-game comparison is useful only if it removes features as well as suggesting them. No multiplayer fun or commercial readiness has been validated. Next proof: a two-person handoff and a six-person moderated round, not a longer feature list.

Current implementation: [local Fiver / Watcher review](../LOCAL-PILOT.md), [point-by-point disposition](IMPLEMENTATION-BACKLOG.md), [editable map workflow](../MAP-EDITING.md). Published tester snapshot: [movement release 0.2](../RELEASE-0.2.md).

- [Pre-map refinement roadmap](PRE-MAP-ROADMAP.md): current shipped refinements, ten ROI-ranked next steps, creative experiments and primary sources (2026-09-22).
