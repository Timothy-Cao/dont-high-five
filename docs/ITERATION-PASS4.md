> Historical iteration record. Paths and tuning values below describe that earlier pass; use README.md and ARENA-DESIGN.md for the current project.

# Pass 4 — shadows, quiet menus, quick zip

## User direction

Preserve the improved movement. Remove enormous glove shadows, simplify menus, and try simultaneous left/right click as a fast two-hand launch. Kept the dark cartoon depot and existing spring/reel movement.

## Iteration and critique

1. Audited the attached screenshot against current lighting code. Glove geometry was already marked shadow-off on disk, but the light's shadow-caster mask still included every layer and the first-person ball rim still cast shadows. Explicitly isolated all viewmodel pieces on layer 2 and limited glove shadow casters to world layer 1. World occlusion remains enabled. Added a small 0.18 m light size for softer world shadows.
2. Replaced the permanent six-page sidebar with a compact home menu. Details appear only after choosing Controls, Practice, or Settings; tuning and experimental abilities sit under Settings. Back and Escape follow the parent page. Removed the branded HUD card, always-visible control strips, and redundant area-entry notification. A single context hint, speed when relevant, anchor tension, and a tiny zip cooldown arc remain.
3. Implemented a 120 ms, order-independent click chord. First click fires immediately; the second upgrades it into a zip only when both parallel traces find valid grip surfaces. Catch travel is 95 m/s followed by a 55 ms catch beat, then a capped 28 m/s impulse. A level grounded shot receives a small lift so friction does not consume the launch. Normal spring shots remain stronger at full draw (up to 40 m/s), while reel remains slower and sustained (14 m/s).
4. Checked cancellation, release/hold debouncing, missed rays, near cover, cooldown, and a level launch. Corrected a bad test fixture whose supposedly missed ray actually hit another valid surface. Replaced it with a narrow isolated pad and explicitly verified exactly one ray hits.
5. Rendered 4K captures. Floor shadows were clean, but the right glove was still visibly dark. Traced this to mirrored mesh transforms/normals in the Blender asset. Baked scale and recalculated outward normals, exported the repaired right glove, and fixed the generator to avoid repeating it. A second render confirmed both hands now shade coherently.
6. Added an opt-out for the mouse chord under Movement abilities and made held brake cancel a pending catch even while grounded. Rechecked actual floor launch movement.

## Evidence

- Engine suites: 37 sandbox, 43 movement, 33 polish checks. See the pass4 logs and Verify.cmd.
- Movement remains 7 m/s, 75 ms stop, 0.217 m stopping drift, 1.367 m normal jump apex.
- Actual overhead zip catches/launches in under 375 ms in the test fixture; both glove ray directions agree to dot product > 0.99999. The 28 m/s bound is tested at launch. Gravity subsequently changes speed normally.
- Rendered and reviewed 3840 × 2160: home, controls, settings, keyboard binder, downward shadow view, zip travel. Captures are in captures/. No image mockups substituted for engine output.
- The small menu restores after visiting a wide keyboard page. Existing menu settings and practice-area actions still work through their engine signals.
- Windows certificate/user-cache warnings and shutdown ObjectDB resource warnings remain environment/cleanup limitations; no assertion or script errors in the final test runs. Human drag-and-drop and subjective enjoyment still need hands-on feedback. No native desktop input was sent in this pass.

## References and implementation rationale

- [Godot Light3D documentation](https://docs.godotengine.org/en/4.7/classes/class_light3d.html): light influence and shadow-caster masks are separate. Explicitly excluding viewmodels from shadow casters prevents close point lights from magnifying glove silhouettes while retaining wall occlusion.
- Local Design Atlas game-UI guidance: prioritize immediate traversal information; hide reference detail behind deliberate navigation; verify real rendered states and input paths.
- Existing movement research is recorded in ITERATION-PASS3.md. Zip timing/speed are original prototype tuning, not claimed measurements from Spider-Man or Attack on Titan.

## Current limits

- This is a fast catch-and-release launch, not a full swing system. Hands do not wrap around corners.
- A near-simultaneous two-click gesture is intentionally different from independent placement. Disable Quick zip if that distinction feels intrusive.
- R continues to restore the last manually stretched slingshot setup; T returns to the current practice area's start.
- Only keyboard bindings persist across runs. No new art purchases, external publishing, or paid model-generation services were used.
