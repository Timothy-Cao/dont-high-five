# Reveal, blackout and tower patrol

Current source changes, superseding the earlier automatic night-vision and R-mine controls:

- Trajectory dots and P binding removed. A physics-only landing diagnostic remains for regression tests; normal play neither calculates nor renders that preview.
- F7 toggles blackout in the local arena for either role, without cooldown or automatic night vision. Workshop F7 remains edit/playtest. There is no Fiver-owned power objective yet.
- Watcher E throws the mine: two-second cooldown, two-minute lifetime, small proximity trigger and punch detonation. The visual now has a faceted pressure plate, central sensor, three radial stabilizing tabs and a flashing red ring.
- Watcher R grants five seconds of bright yellow, filled, animated player silhouettes through walls. Cooldown is five seconds from activation, so it can be used again as it expires. Pause freezes timing. The effect is exclusive to the Watcher camera, hides on role change or eye disruption, and remains visible in blackout.
- The old night-vision component is dormant behind an explicit `available=false` flag for future experiments. Blackout never turns it on. Reveal is independent of that flag.
- The High Fiver has a plain cream torso, with zipper, pocket, chest badge, backpack, chin vents and external stabilizers removed. Mesh complexity fell from 58,940 to 38,300 triangles. Both player and simulated-Fiver wheels now use corrected signed rotation. A tread/hub pattern communicates rolling; no physical tire simulation or motion-blur claim.
- All unattended towers run a slow inward-facing laser patrol by default. Real raycasts stop beams at cover. They launch grenades about every 14–24 seconds and attempt orbital strikes every 28–45 seconds, with staggered starts. These are damaging hazards but do not track players. Piloting an eye suppresses its patrol. The existing targeted combat AI remains a separate opt-in toggle and takes precedence over ambient patrol when enabled.
- The workshop now has one working-map save and a 304 × 240 × 44 m shell with a 2048-part cap. The previous `workshop-1.json` filename is preserved to keep existing saves. No map-browser or multiple-map system was added. Creator geometry remains separate from the procedural arena until the authored replacement is ready.

## Implementation and evidence

The reveal uses camera-layer-isolated copies of original assets, synchronized to the live skeleton pose. It changes neither the target's materials nor global light. A depth-independent unshaded shader draws the filled silhouette; bright emission supplies a modest glow. Render modes follow [Godot's official spatial shader reference](https://docs.godotengine.org/en/4.7/tutorials/shaders/shader_reference/spatial_shader.html). This is a local prototype effect, not a networking implementation.

Visual fixtures place an actual solid wall between the Watcher and a High Fiver, comparing reveal off/on, full darkness and expiry. The effect was inspected in Vulkan renders. An initial runtime-node duplication caused null material warnings; instantiating clean source assets instead removed those warnings in the rerender. Simplified robot portraits and the actual-arena patrol view were also inspected. No desktop capture, computer interaction or interactive game launch was used.

The full eighteen-suite run passed **718 assertions**, including a new 21-check reveal/demo suite. Coverage includes F7 from both roles, no automatic night vision after waiting, E/R routing, reveal expiry/reuse, pause, camera isolation, patrol lasers/sweep/intervals, pilot override, disabling patrol, corrected wheel rotation and placement beyond the former workshop bounds. Existing movement, arena, cargo, combat, blackout, crowd and save/load checks also pass. Source audit validates 152 static references plus script UIDs and authoring syntax.

Known limits: ordinary engine certificate-store and shutdown resource warnings remain; unattended hazards need human tuning for demo density. The bright reveal is a filled glowing silhouette, not a postprocessed blur. Very fast wheel patterns can alias at low frame rates. The expanded workshop's maximum-sized layouts still need profiling before we treat the cap as a performance guarantee.
