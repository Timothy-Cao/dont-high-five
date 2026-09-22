# Automatic ceiling traversal

2026-09-21 follow-up to the High Fiver movement pass. The user clarified that fixed mode must support LMB / RMB / LMB / RMB ceiling traversal without reeling each grip.

- **1** selects fixed mode. Each successful attachment pulls automatically toward **5 m**; a closer attachment stays short rather than pushing the player away.
- The motor accelerates up to 14 m/s and brakes near its target. Only its own added inward velocity is removed during braking; existing tangential swing momentum is retained. Releasing with **E** retains current velocity.
- Old grips release after the existing 0.3 s overlap. A click on a retiring hand can immediately reuse it, so fast alternation is not swallowed as a recall.
- Misses still leave the previous grip intact. A deliberate two-button chord still recalls both hands.
- F / middle mouse and wheel adjustment remain elastic-mode controls. Fixed mode needs no length management. The HUD reads **FIXED · AUTO**.
- Existing collision constraints still prevent automatic pulling through walls/ceilings.

## Verification

The focused High Fiver suite passes **47/47** assertions, including automatic lift, braking to rest at 5 m, release momentum, blocked reeling, fast hand reuse, and existing swing/input/knockback checks.

A real controller test shoots six alternating gloves at a collision ceiling, with no WASD or reel input. All six attach; it traverses **27.42 m** in about **2.25 s**, with the player's lowest position only **0.51 m** below the starting height. This is a controlled headless scenario, not a claim about subjective feel or all arena routes.

The earlier manual 8 m/s fixed-winch design is superseded. The elastic slingshot and ordinary grapple remain available in the other mode.
