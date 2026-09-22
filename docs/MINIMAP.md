# Whole-arena overview

**M** toggles a fixed north-up map of the entire 304 × 240 m arena, with a small margin. Its purpose is relative positions, not precise local navigation.

- Cream triangle: you. Teal dots: living Fivers, including optional moving test bots.
- Numbered red squares: all seven Watcher towers. The piloted tower is gold.
- Fivers on other levels have an up/down tick. All actor levels remain visible together.
- The muted architecture shows the floor beneath your current role; the header identifies that floor. Supporting floor, wall slices and ramps come from actual collision.
- Violet rings mark portals. Tower labels draw over passing bots so their numbers stay readable.
- Blackout dims the overview. This local prototype deliberately shows actors through walls; it is not a final competitive information rule.
- Menus, Training and workshop editing hide it. Workshop playtests show their own layout and player, without actors from the original arena.

One cached 1280 × 1024 2D viewport holds the floor plan. It rebuilds on floor or workshop revision changes; dynamic actor markers use live positions without rebuilding geometry. The view stays fixed as the player moves. The minimap suite now has 25 passing checks, including full coverage, live Fivers, dead-marker removal, selected tower and workshop isolation.

At full-map scale small openings and stacked surfaces are approximate. This is not a clearance or navigation guarantee. Fiver markers are local simulations until networking exists. Rendering was inspected at 2560 × 1440 for Fiver, Watcher and blackout contexts.
