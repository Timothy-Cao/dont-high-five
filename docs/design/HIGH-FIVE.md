# What does a high-five actually do?

**Proposals, not implemented.** This is the initial hypothesis. [Pass 1](PASS-01-HIGH-FIVE.md) refines it: celebration can be valuable without a buff; a stored spring must compete with the current powerful recoil; and the current immediate glove shot conflicts with accepting on the first mouse press. The input table below is an experiment to compare, not an approved default. The pass also removes the proposed donor-recharge rebate from the first spring trial.

## Recommended first experiment: pass the charge

An open-palm contact transfers a visible charge between two consenting robots. The receiver gets something they can immediately use: energize cargo, feed a door, or briefly extend an arm. The sender visibly loses it. The same action can pass a corrupted charge, but corruption has a bounded effect and a way to inspect or clean it.

Do not combine healing, item trading, shared stamina, infection, a social score and a dash into the first high-five. It will be impossible to tell which payoff made the action worthwhile.

### Input contract

| Phase | Initial proposed rule |
| --- | --- |
| Offer | Aim at another robot within 6 m and hold either single mouse button; an open palm reaches toward that player |
| Recipient sees | Offered palm plus sender identity at close range, the charge symbol and a brief acceptance affordance |
| Accept | Aim toward that palm and press either single mouse button within a generous 1.2 s offer window |
| Contact | Server checks both intents, range, clear path and free hands; it commits exactly one exchange |
| Feedback | Palm clap, ring travelling from donor to recipient, wrist icon changes on both bodies |
| Cancel | Release offer, look away deliberately, leave range, enter suppression or receive a punch; charge stays with donor |
| Recovery | Short shared animation, no camera snap, neither player forcibly dragged |
| Reuse | Requires a new press; holding does not repeat exchanges |

The 6 m limit is distinct from the current 25.5 m wall shot. It creates a readable encounter without demanding pixel-perfect airborne collisions. It is a proposal to test at both close and intermediate distances.

**Important conflict:** LMB+RMB currently punches. A pending high-five must be cancelled when a punch chord is recognized, before the exchange commits. Do not allow a “high-five” that damages someone because the second click arrived slightly late. Prototype a dedicated optional acceptance key if the chord remains unreliable at ordinary latency. Preserve single-click wall shots when there is no offered palm/recipient in the interaction cone.

**Accessibility:** accepting either hand should work. Do not require matched anatomical left/right hands across facing avatars. Show action plus bound key when appropriate; color alone cannot identify an incoming exchange. Begin with generous timing and no precision combo bonus.

### State that must be authoritative later

One offer ID, two player IDs, giver hand, receiver hand, charge ID, creation time, expiry and terminal result. Charge ownership changes atomically. Duplicate packets cannot create charge or apply a second benefit. Only the server knows secret corruption until a rule permits disclosure. Clients can predict the arm animation but not the hidden-role result.

Reject exchanges through walls, with suppressed arms, during recovery, after disconnect, or against an already-consumed offer. Define simultaneous offers deterministically. Store replay facts for the post-round reveal; do not broadcast the hidden corruption bit in general player state.

## Five variants worth discussing

| Variant | Delight | Social possibility | Failure mode | Priority |
| --- | --- | --- | --- | --- |
| **Charge relay** | Catch a bright pulse and immediately power something | Ask who handled it; choose safe inspection or speed | Becomes bureaucratic battery delivery | First |
| **Alley-oop** | A friend converts a hand contact into an upward assist | Rescue with a cost; suspiciously convenient help | Griefing through forced movement | Second, recipient chooses launch direction |
| **Temporary shared tether** | One anchors while another swings across | Trust someone to hold while you carry valuable cargo | Skilled player dominates; release becomes trolling | Later two-player co-op test |
| **Bad Battery** | A strong temporary perk is also a ticking burden | Negotiate who should take it next | Everyone refuses; instant death feels arbitrary | Separate party mode, public timer |
| **Transferable access stamp** | Borrow entry to one room without a new inventory UI | Permission chains create alibis and theft opportunities | Role confirmation, gate camping, key bookkeeping | Later objective variant |

### An alley-oop without stealing control

The high-five gives the recipient an eight-second stored spring. They choose when to spend it with Jump and keep steering. The initial idea gave the helper a small recharge bonus; pass 1 defers that bonus because reciprocal handoffs could become a boost farm. This captures a rescue fantasy without another player yanking the camera unexpectedly. It also permits betrayal through a bad route recommendation rather than an unavoidable forced fall. Test this before physical body-to-body tethering.

### Bad Battery, repaired after critique

Naive version: pass a bomb by high-five. Critique: informed players refuse, so the core gesture disappears. Better experiment: the battery gives a strong movement benefit; the current carrier scores by crossing lit gates, while an accepted pass splits a small reward. A receiver sees the remaining fuse and can refuse. An unaccepted throw drops a neutral pickup instead of forcing infection. If this still creates refusal, change it into a public chase-tag mode and stop pretending it is a trust game.

## Versions I would reject for now

- **Every high-five might instantly kill you.** The rational response is never to participate; delayed, recoverable sabotage gives the gesture room to remain useful.
- **High-fives reveal alignment.** Players will line up at spawn and solve the social game mechanically.
- **Touching any body transfers the curse automatically.** At grapple speeds this is difficult to consent to or read.
- **Killer-only color or animation.** A visual tell may be learnable and healthy when used as an expensive escape, but not as a hidden passive difference advertised as deception.
- **Unbounded contagious corruption.** One event could invalidate all evidence and create arbitrary late-round failures.
- **A permanent trust meter.** It would summarize the interesting social judgment for the player, and griefers could manipulate it.

## Decisive question

After ten ordinary friendly exchanges, would players still want to high-five? If the answer is no, test the stored alley-oop before adding betrayal. The game’s title should create anticipation, not make its central verb feel like a mistake.
