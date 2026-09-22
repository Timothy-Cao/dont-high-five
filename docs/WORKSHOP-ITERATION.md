# Workshop iteration — 2026-09-22

The highest-return gap before authoring the map was functional placement. Geometry alone would require rewriting towers, tasks and portals in code later. This pass makes the existing one-map workshop playable and makes repeated assemblies faster to edit. Movement tuning and the restrained wall dots stay unchanged.

- Eight gameplay parts join nine architectural parts: start, tower, cargo, socket, ring, light and two linked portal ends. Real cargo/portal/Watcher implementations are reused. Temporary playtest sessions keep the original arena isolated and restore it when leaving.
- Group selection, move, copy, delete and one-step undo. Placement checks all members before committing, and cancellation never changes layout data. Bounds and spawn clearance still apply.
- Peaceful, One tower, Patrol and Chaos controls. Workshop starts peaceful; the original arena keeps its patrol default. Already-launched attacks finish when changing presets.
- Workshop minimap markers, dynamic objective counts, start direction, paired-portal validation and safe spawn checks. Reloading while testing rebuilds the gameplay session.
- Removed obsolete short orbital-column renderer and unreachable workshop HUD branch. Selection, prop visuals, goals and session lifecycle have separate modules. No source art, historical design research or user layouts are deleted.

## Validation

The new gameplay regression covers actual F6 input, guns/grenades, pressure selection, one-hand cargo, rotated rings, momentum-preserving portals, blocked exits, blackout restoration, repeated edit/play, stable-ID persistence, group transactions and menu construction. Existing workshop coverage includes ramp traversal and old numeric/stable-ID saves.

All 21 suites passed; with the additional held-cargo exit regression, the suite set totals 815 assertions. The targeted workshop suite was rerun after UI and input integration. Authored offscreen renders were reviewed for the compact palette, pressure menu and functional playtest. Static resource/UID/Python-source audit passed. Existing engine certificate/exit-resource diagnostics can still appear; there were no script or assertion failures in the successful runs. No desktop capture or system input was used.

## Next work, by expected return

1. Start/finish timing, peak speed and height measurements for a selected route; compare empty-handed and cargo runs before changing movement numbers.
2. Flash-intensity control retaining danger footprints, opaque orbital beam and hand illumination.
3. Repeatable eight-Fiver/seven-tower stress capture with CPU/GPU frame-time percentiles; optimize observed costs.
4. Group rotation and an axis move gizmo if point-and-place proves limiting during real map building.
5. One high-five benefit tested between two humans before expanding deception or networking scope.

One paired portal connection and up to seven towers are intentional prototype limits. This remains local role switching. Headless checks establish behavior; human play still needs to judge route quality, editing comfort and readability.
