# Don’t High Five 0.3 — Watcher playground

The latest local Fiver / Watcher prototype, packaged for Windows with Godot 4.7.2. Extract the ZIP and run **Play.cmd**; first launch imports assets. Multiplayer is not implemented.

- Full-arena north-up overview: living Fivers, seven numbered towers, selected Watcher eye and floor-height cues. M toggles it.
- Minimal wall texture using the original tiny, sparse floor flecks; no circuit patterns. Wall flecks are dimmer and switch off with blackout.
- Charge punches, automatic fixed-arm ceiling traversal, the wheel robot and expanded Watcher arsenal.
- Opaque orbital beam after a full-footprint warning; adjustable fog and quieter positional orbital audio.
- Positional tower/blast sound and brief incoming-hit bearings.
- Empty-shell workshop with nine parts, middle-click picking, Shift+F7 test-here, undo/redo and separate recovery autosaves.
- Minimal README using the three user-supplied playtest screenshots.

F5 changes camera, F6 switches role, F7 toggles arena blackout; Esc opens settings and workshop. Workshop F7 enters/exits playtesting. Full bindings: [Playing](PLAYING.md).

This is a portable source/development package rather than an optimized production export. It contains editable assets and the five authorized soundtrack files. The overview currently shows actor positions through walls as a local testing aid; stacked architecture remains approximate. Earlier 0.2 downloads remain available unchanged.

Validation: all 20 suites passed (775 assertions); source audit passed. Fiver/Watcher overview and blackout were inspected in engine renders. Known engine certificate/teardown diagnostics remain.
