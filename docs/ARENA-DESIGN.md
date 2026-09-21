# Standalone project note

The design and validation record below describes the current game. Runtime code now lives in `scripts/`, tests in `tests/`, and generated output in `.local/`. Historical captures and `checkpoints/pass5` remain in the pre-migration experiment in the original workspace; they are not needed by this project. Baseline measurement files are retained alongside this document with a `baseline-` prefix.

# Afterglow arena

## Spatial plan

A 152 × 152 m enclosed building, 35 m high, with a continuous ground floor. The macro layout is authored; six local labyrinths use fixed random seeds. This makes the layout reproducible and lets the main rooms retain distinct movement purposes. No instructional world text, timers, finish line, mandatory sequence, or required pickup count.

| Space | Shape and feel | Vertical routes |
| --- | --- | --- |
| Central atrium | Open sightlines, hanging rings, large framed portals | Crossing bridges at 8.5 and 16 m, a 23 m perch, ramp, bounce pads, grapple ribs |
| West / amber | Tall shaft with staggered supported shelves | Five shelves from 3.5 to 21.5 m, 26 m overlook, high bounce pad, wall grip |
| East / violet | Broad galleries interrupted by windows | Offset decks from 4 to 14.2 m, elevated narrow slot, high exit at 21 m |
| North / blue | Deep room divided by perforated screens | Galleries at 8.5, 16 and 22 m, high connecting windows, rising bounce route |
| South / lime | Low sheltered passages with taller space above | 1.25 m-high ball/crouch windows, 3.2 m approach ledges, roofs at 5 and 7.2 m |
| Four corners | 7 × 7 mazes with 5.5 m cell pitch | NW and SE have second labyrinths at 8.5 m, two bounce shafts each, external ramps |

Maze generation starts with a depth-first spanning tree, then adds cross-links at a fixed seeded probability. The result has loops and shortcuts instead of being only a sequence of dead ends. Corner mazes have open perimeter access into the adjoining main rooms and exterior circulation corridors. Upper shafts remain open through the floor and are marked by rings.

The ground floor provides recovery beneath demanding routes. All four corners and the central hall connect on foot in the collision sampling test. Elevated pickups remain optional challenges. No fall damage or checkpoint reset is added.

## Nonverbal language

- Colored caps, floor edges and aperture outlines give each region an identity.
- Concentric rings with a cross mark the padded bounce surfaces.
- Amber floating sparks mark optional trails, high ledges, windows and hidden corners.
- Pickup feedback is a chime and a short reticle pulse. The only collection tally is inside Explore in the pause menu, with no denominator or quota.
- There are no GRIP labels, bay names, persistent instructional strips, or in-world signs in the arena. Controls remain available in the pause menu.
- Matte blue-black architecture, original procedural blacklight carpet flecks, sparse wall marks, padded cylinders, soft glove illumination and colored local fill retain the indoor laser-tag feel.

## Implementation

`arena.gd` owns the layout, seeded maze builder, instanced architecture and pickup system. Static architecture shares a single grippy body with primitive collision shapes; bounce pads have individual bodies and launch strengths. Visible structural meshes are instanced by mesh/material, producing 59 architecture batches rather than thousands of individual draw nodes. Sparks use one MultiMesh and share a material.

Pickup detection sweeps between physics positions, includes wall occlusion, ignores large teleport segments, and pays each spark only once. Current collection is session-local; closing the game restores pickups.

The original bays are retained only as deterministic test fixtures under `--verify`, `--metrics`, `--polish` and the old `--capture` flag. Normal play and `--arena-verify` use the new arena. Movement remains the existing controller, with two necessary integrations: per-pad bounce strength and bounds expanded beyond the old 70 m reset limit.

## Review and fixes

1. First rendered pass had poor distant surface readability. Added low local fill lights, longer-range hall lights, stronger ambient fill, subtle floor texture and curved silhouettes. Reduced pickup emission to keep the yellow color instead of white bloom.
2. Pickup collision audit found an upper bridge terminated inside the north wall. Moved the high opening to align with the bridge, fixing both the blocked route and embedded pickup.
3. Replaced an upper-maze capture position that sat too close to a partition with a cell-center view.
4. The zip integration assertion originally sampled before the expected height was reached. At 0.5 s from firing, the actual run records y=2.756 m and one completed zip; no controller tuning was changed to make the assertion pass.

## Verification and limits

- 60 arena checks: real collision sampling, generated connectivity, pickup clearance/occlusion/sweep, low aperture clearance, expanded bounds, menu layout, spawn safety, bounce/brake, zip, reel, wall grip and ramp traversal.
- 2,382 of 2,383 sampled clear ground positions belong to one connected region without jumping. The remaining position is inside the new hopping passage; an actual two-jump traversal test crosses it. This is sampled clearance evidence, not proof of every possible continuous route.
- Every one of 184 pickup centers passes a 0.2 m collision clearance probe. Complete human collection of every elevated pickup has not been verified.
- 127 controller/menu/physics checks run against the preserved test bays; they are distinct from the new arena tests.
- Seventeen actual-engine 3840 × 2160 views are in `captures/arena/`; the original eight per-view short timing samples are in `arena-render-metrics.json` and predate the hideaway additions. These samples are not a whole-session frame-rate guarantee.
- No desktop automation, app activation, mouse input or keyboard input was used. Testing and rendering were scripted engine subprocesses. No new paid or downloaded assets.
- Existing certificate-store and ObjectDB shutdown warnings remain in test logs. No gameplay script errors remain in successful final runs.
- The space is intentionally a movement/exploration prototype. Subjective feel, hand occlusion near walls, and the best collectible density still need player feedback.

## Balance and hideaway pass

Regular shot reach is now 25.5 m (75% of the old 34 m), while quick zip reaches 17 m (half the old range, measured from each hand socket). The burst remains 28 m/s. A two-second shared hand recovery replaces the separate 650 ms zip cooldown: the gloves return from their actual catches over 0.45 seconds, settle with a small winding motion, then rise during the final 0.35 seconds. They remain visible while tucked in the ball. Small arcs around the existing hand markers show recovery with no added gameplay text.

During recovery, firing, zip and wall grip are blocked. Air steering, jumping and braking still work. Recall does not bypass the timer; pause freezes it; normal retry/entry reset clears it. Manual slingshot recoil and ordinary glove return are unchanged, giving the deliberate stretch-and-release move a different cost from quick zip. Range does not cap attached rope payout: wheel adjustment and the existing spring equilibrium still operate after a legitimate catch.

Three compact refuges sit at (-16, 10, -22), (-64.5, 12, 14) and (64, 10, 18). Each has an offset 2.5 m-wide standing entrance, a corner concealed from a frontal sightline, a 1.15 m-high side escape, and a roof that can be landed on. The eastern roof sits beside a gallery, the western pocket overlooks the bounce shaft, and the atrium pocket hangs against its north wall. Seven extra sparks reward these spaces and the low passage; they remain optional.

The southern cross-passage has two full-height entrances, a crouch shortcut and two 0.55 m-high hurdles. Its 3.6 m ceiling clearance permits the existing normal jump. Scripted movement crosses both hurdles successfully; this is not a new auto-hop or bunny-hop acceleration mechanic.

Review: the first recovery render lowered the gloves too far and the ball rim crossed their wrists. Raised the recovery pose and lowered the rim during winding. Engine captures show the actual return, winding and readying phases. The new geometry adds 68 collision boxes (897 total) while reusing the existing 59 architecture draw batches. The original wide routes and gallery openings still pass traversal tests.

Verification totals: 37 spring/slingshot checks, 43 movement/menu checks, 47 input/recovery/polish checks and 60 arena checks. Roof reach tests reject a floor-to-ceiling shot but accept it after gaining height. Snapshot `checkpoints/pass5` preserves the previous arena and controller. Player feedback is still needed on whether the two-second commitment feels right during real chained routes.
