> Historical iteration record. Paths and tuning values below describe that earlier pass; use README.md and ARENA-DESIGN.md for the current project.

# Pass 3 — research, iteration and critique

Session target: about thirty minutes, prioritizing movement feel over asset breadth. North star: a predictable body with expressive hands. The player should be able to commit to a launch, correct it, stop it deliberately, or convert it into a grapple. Darkness should make hand placement useful before it becomes punitive.

## Evidence and decisions

These are sources read as text/code, not games claimed as played.

- [Minecraft's official control guide](https://www.minecraft.net/article/minecraft-controls): WASD, mouse look and Space jumping transfer directly. Minecraft puts sneak on Shift and sprint on Ctrl, so there is no universal Shift/Ctrl convention to copy indiscriminately. Chosen prototype: Space jump, Ctrl crouch/stone brake, Shift wall grip; expose reassignment instead of pretending every ability key is standard.
- [Minecraft Education's keyboard guide](https://edusupport.minecraft.net/hc/en-us/articles/360047116832-Minecraft-keyboard-and-mouse-controls): corroborates the basic mapping and the difference between its modifier conventions and common shooter conventions. Kept menu Escape and fixed mouse look.
- [Maddy Thorson, Celeste & Forgiveness](https://www.maddymakesgames.com/articles/celeste_and_forgiveness/index.html): ledge grace and buffered presses reduce unfair input loss. Adapted as 100 ms coyote time and 120 ms jump buffering. Did not copy Celeste's exact movement or add its other assists wholesale.
- [Respawn developer interview on Titanfall controls](https://www.gamedeveloper.com/design/designer-interview-getting-i-titanfall-i-s-controls-just-right): stable aiming and deliberate movement feedback informed an upright camera with optional speed FOV. Wall grip is explicit rather than an automatic wall run, because this sandbox needs the player to stop and plan. Article text inspected; image-fetch attempts did not yield a usable gameplay reference, so no claim of visual study or play.
- [id Software's Quake III movement source](https://github.com/id-Software/Quake-III-Arena/blob/master/code/game/bg_pmove.c): separation of grounded friction and airborne acceleration was the useful structural lesson. Our implementation is original vector steering/acceleration code; no GPL code was copied. Unlimited strafe acceleration and bunny-hop speed accumulation were deliberately omitted.
- [Nintendo's Kirby manual](https://www.nintendo.com/eu/media/downloads/games_8/emanuals/nintendo_ds_21/Manual_NintendoDS_KirbyPowerPaintbrush_EN.pdf): Stone is a heavy transformation. Here the transferable idea is an intentional change of movement mode. The prototype zeros horizontal velocity and accelerates descent; it is not a copy of Kirby's exact behavior or animation.
- [Godot input examples](https://docs.godotengine.org/en/stable/tutorials/inputs/input_examples.html), [Control drag/drop API](https://docs.godotengine.org/en/stable/classes/class_control.html): named actions separate abilities from keycodes. The keyboard binder supports dragging and click-then-key assignment, with occupied-key swaps and reserved recovery keys.
- [Riot's movement-accuracy discussion](https://playvalorant.com/en-gb/news/game-updates/valorant-patch-notes-3-0/): establishes why stopping matters in that shooter, but does not establish the movement constants required here. We did not infer exact Valorant acceleration/friction values from it.

## Iteration loops, in ROI order

1. **Baseline diagnosis.** The old controller used gradual velocity matching even for unanchored walking. Replace it with explicit 100 m/s² acceleration/braking, retain separate bounded drive against attached springs. Measure start, stop, reversal and diagonal speed rather than treating a prettier scene as an improvement in feel.
2. **Jump and recovery.** Space jumps; one air jump, buffered landing input and ledge grace. Add stone brake, explicit wall grip, climb and wall jump. Corrected a test fixture that moved the player off a ledge before it had actually landed; then verified genuine coyote behavior.
3. **Air agency.** Initial air steering was too weak in the measured half-second turn. Increased the rate from 28 to 36 m/s²; measured 34.7 degrees of correction from 30 m/s while bounding speed. Untouched launch momentum remains unchanged. Added a separate powered-air state after finding that a released grapple otherwise inherited ordinary-jump drag.
4. **Arm alternatives.** Wheel adjusts relaxed lengths gradually; F reels, with MMB as an alternative so all WASD keys remain reachable. Allow firing hands in flight. Keep launch, reel, cancel and brake distinct. Cancellation now retracts from the glove's actual animated position, avoiding a flash to its distant destination.
5. **Failure-state review.** Stone brake overrides bounce pads instead of producing rapid repeated rebounds. The last constraint audit found that the safe-shortening guard could accidentally pay out arm length at maximum reach. Rewrote it so a blocked shortening cannot increase length, and added an assertion against the original maximum reach. This was more valuable than adding another ability.
6. **Indoor visibility.** Enclose the entire map, remove the active sky, add navigational trim and hand-carried lights. The first render blew out the glove fingers. Separated hero illumination from world lamps, removed self-shadowing from first-person gloves, and added small emissive cuffs. The shaded Air Mail alcove gives sending a glove ahead a concrete visibility purpose.
7. **Menu/control comprehension.** Add an actual keyboard layout, ability cards, collision-safe swaps, saved bindings and feature toggles. HUD prompts and world ability signs follow the new assignments. Inspect all pages at desktop and 4K sizes. A real window was opened, but the user stopped Computer Use before the binder click; no subsequent desktop inputs were issued. Live drag/drop usability remains for human testing.
8. **Performance.** Measure a short 4K frame-interval sample with hand lights active. The result left enough room to retain dynamic lights; no speculative visual downgrade was needed. The measurement is stationary and non-isolated, not a promise about all future content.

## What remains a hypothesis

- More recovery moves may make misses satisfying, or may erase the need to plan a slingshot. The independent ability toggles exist to test this, not because every feature must survive.
- Automatic relaxed length at attachment avoids free energy but can make the arms feel abstract. Adjustable length offers explicit control; whether players prefer it to a fixed-length system remains a playtest question.
- Reel currently targets the midpoint of two attached hands. This is legible mechanically but may feel less precise than selecting one hand to reel. Try one-hand grapples before deciding.
- Current lighting demonstrates light placement and dark space. It is not yet a complete darkness puzzle or polished environment-art pass. The hand mesh is still a static, stylized procedural glove.
- No controller support, movable-object pulling, rope wrapping, multiplayer, persistence beyond bindings, or campaign progression was added.

## Workflow critique

The research changed the input layout, separated walking from elasticity, and justified input forgiveness and a steady camera. Measurement caught weak air control and a hard-limit creep bug. Most value came from short physics/control loops, not more sources. A long generic competitor survey or another sky asset would have had low ROI for this feedback. The failed live UI attempt was preserved as a testing limit rather than being represented as a successful drag test.

Final input audit: [Godot's mouse-motion documentation](https://docs.godotengine.org/en/stable/classes/class_inputeventmousemotion.html) identifies resolution-scaled relative input as a source of inconsistent captured-mouse sensitivity. Replaced it with screen_relative and verified that changing the scaled delta does not change the yaw produced by a fixed raw delta. This is particularly relevant to the requested 4K/fullscreen use.
