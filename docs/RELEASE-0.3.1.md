# Don’t High Five 0.3.1 — Workshop playtest

The player role is now **High Fiver** throughout the menus, HUD and documentation.

- Build a playable layout with starts, Watcher towers, cargo/socket goals, traversal rings, lights and linked portals.
- Ctrl+click selects a group; X moves, Ctrl+D duplicates, Delete removes. Undo restores the whole operation.
- Choose Peaceful, One tower, Patrol or Chaos pressure. Workshop starts peaceful.
- Compact Build palette, local tower/portal overview, safer edit/play transitions and recovery saves.

Extract the Windows ZIP and run **Play.cmd**. This is the full portable source/development package with Godot and editable assets. First launch imports assets. Local role switching only; multiplayer is not implemented.

Esc → Build workshop opens the editor. B switches part palettes; F7 tests/edits; F6 switches High Fiver/Watcher while testing. Portal A and B form one linked pair; up to seven towers are supported.

Validation: 21 suites / 815 checks passed for the workshop update; targeted UI/workshop/minimap checks passed after the rename. Existing engine certificate/exit-resource diagnostics remain. The previous 0.3.0 release is retained.
