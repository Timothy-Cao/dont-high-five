# Local High Fiver / Watcher pilot

2026-09-21. This source build follows the user's expanded notes and approved choices: local role switching, automatic towers off by default, and separate Training. The published [v0.2.0 release](https://github.com/Timothy-Cao/dont-high-five/releases/tag/v0.2.0) remains the earlier verified movement snapshot, so the external tester can use that build while this prototype develops.

## Try it

Open `Play.cmd` after closing an older game instance. **Arena** enters directly; **Training** offers nine short, individually selectable rooms. **F6** switches High Fiver / Watcher. Esc → Local playtest contains auto-fire, the hazard toggle, round reset and task shortcuts. **2** selects punch / parallel zip. Existing automatic fixed-arm traversal remains on **1**.

The local High Fiver can carry with one hand, use the other to traverse, heal with an explicitly simulated reciprocal partner, complete rings and maintenance, and knock down dummies. Watcher tests cover seven cameras, MG/sniper, a bouncing grenade, delayed area strike, blackout, full-auto burst and impostor deployment. The quota is seven tasks; it can be reset and does not end in a competitive match result.

![Local high-five test partner, with readable face under the glove lights](screenshots/pilot-fiver.png)

## Changes that mattered in review

- **Input ownership:** carrying occupies one hand and blocks two-handed attacks. Extended gloves recall before a punch; a pending high-five cancels when the player recalls or attacks. Zip needs both parallel rays to hit real geometry and cannot create empty-air speed.
- **Recovery:** High Fivers have 100 HP and a three-second local respawn. Shift halves incoming damage and rejects knockback; temporary toughness is independent. Eye disruption blocks firing and darkens the current view for four seconds. Task/partner reset restores collision as well as health.
- **Training readability:** first render hid the floor gap. Added actual ledge markings, a quiet grid and ceiling grip panels. Every room has a reset and skip path; no strict mastery checks. The anchor pulse has a countdown.
- **Local partners:** reuse the original rig with idle/walk animations and short elastic forearms. A proximity-facing idle makes the social partner readable. Visor material was softened after a render showed the glove lights producing a white rectangle over its face.
- **Map coherence:** kept one northwest ground maze. Other maze patches became wide corridor bays with end bypasses, through-windows and canopy routes. Existing pad arcs, broad ramps, portals and hanging refuges remain. Main structural columns reach the roof.
- **Exposure:** symmetric eye positions covered only about 41% of supported floor samples. A greedy candidate audit informed revised positions. Final measured coverage is **220 / 368 samples, 59.8%**, with per-eye counts **55, 43, 30, 34, 32, 27, 35**. All five power generators are visible to an eye. This is real occlusion/range evidence, not human targeting or balance evidence; the user's 70–80% hypothesis is not yet met.
- **Blackout:** ambient light, arena lamps, imported emissive surfaces, floor flecks and rave beams dim or switch off; exact shared material values restore. Hand lights remain available. Task cues and attack warnings remain readable. There is no voice system to disable.

![Watcher view from the first eye](screenshots/pilot-watcher.png)

![Separate ceiling-traversal Training room](screenshots/pilot-ceiling-room.png)

## What the prototype does not prove

The partners are deterministic local simulations, not remote players. Auto-fire is basic acquisition plus a visible 0.65-second warning and a shot at the recorded position. It does not simulate human tracking, team pressure or a believable impostor. No network authority, voice, matchmaking, full round rules or 20-second match respawn exists.

Hazards are a small opt-out gallery, not final level-wide placement: a slowing gate, floor laser channel/sweep and warning-timed visual press. The channel is not a carved pit and the press is not a moving physics platform. Arm/leg-disable fields stay removed; insulation is a future-facing resistance with no active map consumer. Temporary cloak hides the player body and avoids automated acquisition; hand lighting and interaction effects remain clues.

Cargo uses physical sweeps toward its occupied hand and can lag at high speed. Portals and launch pads release cargo with other attachments. That behavior needs player feedback before expanding cargo objectives. Maintenance is a deliberately small aim-and-confirm sequence; the dummy objective is one KO, not a whole quest chain.

## Validation and artifacts

Actual in-engine rendering was reviewed at **2560 × 1440** for the High Fiver, Watcher, blackout, Training and menus. These are authored camera fixtures, not footage of a human finishing the game. No desktop capture or system input automation was used. The build was not interactively launched for the user.

The focused integration suite checks hand occupancy, healing/cancellation, health, respawn, buffs, zip, eye disruption, weapons, blackout restoration, infiltration, default-off/opt-in fire, Training, shortcuts and station exposure. The fixed-arm suite still measures six alternate clicks moving **27.42 m** without WASD or reel input. The final full run passed **12 suites / 524 assertions**, including **87 local-pilot checks** and **47 fixed-arm checks**. No script errors or failed assertions were reported. The source audit passed 90 static resource references, unique script UIDs and authoring syntax checks.

Known environment noise: the engine reports certificate-store and shutdown ObjectDB/resource warnings in this sandbox. Do not describe these logs as warning-free. Source paths, script UIDs, authoring syntax and release ZIP integrity are audited separately.

The code is organized under `scripts/gameplay/`; marker placements are in `scenes/playtest_layout.tscn`. See [map editing](MAP-EDITING.md), [point-by-point disposition](design/IMPLEMENTATION-BACKLOG.md) and [source ledger S25–S28](design/SOURCES.md). No competitor art was used.

## Next human questions

1. After Training, can you traverse the ceiling through alternating clicks without thinking about reeling?
2. Does carrying create a useful route choice, or just make movement frustrating?
3. With auto-fire enabled, can you identify the warning and escape using movement or cover?
4. From the Watcher view, are robots recognizable before you scope? Which eyes feel pointless?
5. Did a chord, recall or high-five ever do something you did not intend?

These answers should determine the next iteration before networking or additional weapons.

Latest local revision: [Watcher weapon fixes, short cooldowns, aiming laser and dedicated sounds](WATCHER-WEAPONS.md). This later focused pass supersedes the weapon tuning and coverage figures above.
