# Editing this map together

## Empty-shell workshop

Open **Esc → Build workshop → Enter / continue workshop**. The new workspace starts empty in a separate 304 × 240 × 44 m indoor shell. Editing it does not change the main arena. The optional **Load example course** adds a small traversal layout and can be undone.

| Input | Build action |
| --- | --- |
| WASD / mouse | Fly / look |
| Space / C / Shift | Up / down / fly faster |
| B | Switch Architecture / Gameplay palette (also in the Build menu) |
| 1–9 or mouse wheel | Choose a part in the palette / cycle all parts |
| LMB / RMB | Place / delete the indicated part |
| Middle mouse | Pick an existing part and copy its rotation |
| Ctrl+LMB | Add/remove a part from the selection |
| X / Ctrl+D | Move / duplicate the selected group; point and LMB to confirm |
| Delete | Delete the selected group |
| Esc during group placement | Cancel without changing the layout; Esc again clears selection |
| R | Rotate 90 degrees |
| G | Cycle 0.5, 1 and 2 m snapping |
| Page Up / Page Down | Offset placement vertically by one grid step |
| Ctrl+Z / Ctrl+Y | Undo / redo |
| Ctrl+S / Ctrl+L | Save / load your arena |
| F7 | Playtest from placed start (or entrance) / return to editing |
| F6 during playtest | Switch Fiver / a placed Watcher tower |
| Shift+F7 | Playtest from the pointed walkable surface (requires clear headroom) |
| R during playtest | Retry at the current test start |
| Esc | Menu, return to main arena |

Green preview means valid; red means blocked. Parts snap against the surface under the crosshair. Placement protects the spawn and shell boundaries and uses conservative bounds to reject overlap. F7 uses the actual Fiver controller, arms and collision; pads launch you. Shift+F7 chooses a nearby working start on the surface under your crosshair; R retries there. Returning to edit preserves your working camera. Edit lighting is brighter than the playtest lighting.

One working arena saves versioned JSON under `user://maps/workshop-1.json` (the existing filename is retained for compatibility); on Windows this is inside the game's Godot app-data folder. Each replacement preserves a `.bak`; unsaved work also writes `workshop-autosave.json` every 60 active seconds and on leaving. Use **Recover autosave** in the Build menu to restore it; recovery is undoable and keeps the unsaved marker until you save the main layout. No recovery write overwrites the main layout. Invalid files preserve the current layout. The 2048-part limit and 64 undo steps keep this first pass bounded.

`assets/arena_kit/catalog.json` defines stable part IDs, metre dimensions, simple collision and launch-pad behavior. GLBs live beside it; editable Blender sources are `art/kit_*.blend`. `art/build_arena_kit.py` regenerates all nine. Keep IDs stable as art improves so saved layouts remain usable. Bottom-center pivots and 90-degree rotations make pieces predictable to assemble.

The Gameplay palette contains Player start, Watcher tower, Carry core, Cargo socket, Traversal ring, Soft light, Portal A and Portal B. These become real gameplay objects in F7 playtests. A placed start includes its rotation. Rings count crossings in either direction and respect rotation; each socket accepts one core. Portals carry momentum and reject blocked exits. Place both ends of the one portal pair, at most one start, and at most seven towers. Save files retain stable IDs for all parts.

**Tower pressure** in Build / Local playtest offers Peaceful (default in workshop), One tower (selected tower AI), Patrol (lasers and occasional hazards), or Chaos (all tower AI). Blackout is available in Local playtest; F7 remains reserved for edit/play in workshop. The overview shows placed towers and portal locations. Ending a playtest resets temporary cargo/task/weapon state while preserving the saved layout; returning to the original arena restores its session and your health.

Group moves and copies preserve spacing and existing rotations. Blocked placements leave the original group untouched; each confirmed edit or group deletion takes one undo step. No arbitrary scaling, group rotation, axis gizmo or multiplayer editing yet. The example course is optional; loading a map replaces the workshop layout, not the authored arena.

## Existing arena placements

Open `scenes/playtest_layout.tscn` in Godot. Its fourteen ordinary Marker3D nodes place the seven Watcher eyes, three traversal rings, cargo, delivery socket, high-five station and maintenance panel. Move a marker, save, then restart play. Marker positions are metres in arena coordinates. No plugin or Blender is required.

Keep the eye IDs `Eye01` through `Eye07`: the numbered controls refer to them. Their `base_y` metadata specifies the supporting floor; do not float a base at 20 m over an upper-floor opening. The `kind` metadata groups the other markers. Rings currently face the Z direction and should span a traversable passage. The task shortcuts in `scripts/gameplay/session.gd` must be reviewed if markers move; they are authored test positions, not a navigation solver.

The bulk architecture remains in `scripts/world/`: `arena.gd` provides batched walls, platforms, ramps and window cut-outs; `upper_floor.gd` specifies slab openings; `districts.gd` makes corridors, terraces and sheltered loops; `annex.gd` contains outer-hall connections. The northwest ground maze is the only recursive maze. Do not add full walls across the broad ramps, tested pad trajectories or portal exits.

For our next layout conversation, mark a region on a screenshot and describe one movement moment: for example, “turn around this column, cross an exposed gap, then land behind overhead cover.” Include the intended floor/height and a slower walking route. That gives us something more useful to test than an object-count target.

Run `Verify.cmd` after a layout edit. `-- --plan-coverage` samples candidate eye locations against real geometry and writes `.local/reports/coverage-proposal.json`. It is a greedy suggestion, not an optimizer for fun. `-- --pilot-verify` records visibility from the actual eyes, tests each station's exposure and checks infiltration/task shortcut clearance. Current floor sampling does not cover every aerial path or account for human aiming and attention.

The existing arena still uses those scene markers and geometry modules. The workshop is a separate first step toward replacing manual layout code with reusable data-driven parts.

F7 belongs to edit/playtest while the workshop is open; the arena's F7 blackout test does not intercept it. The workflow targets one large authored map, not a multi-map browser. The main procedural arena remains separate while you build and test your replacement.
