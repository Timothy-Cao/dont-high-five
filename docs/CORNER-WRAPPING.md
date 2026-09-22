# Corner wrapping and scoped sensitivity

## Cause and change

Both arm modes had a straight-line obstruction guard. When the predicted chest-to-hand line intersected cover but the current line did not, it cancelled horizontal movement; fixed mode also replaced the carried velocity with zero. This created the invisible angle barrier reported when orbiting a column.

`arm_route.gd` replaces that guard with a bounded contact polyline per hand. It finds a short collision-clear detour around expanded box bounds in the plane of travel. Thus a horizontal orbit gets contacts along the column's sides, rather than at its roof. Rotated boxes preserve their collision transform; cylindrical cover uses a conservative box approximation. Contacts are stored relative to their collider. Clear shortcuts unwrap, recall/reset discard contacts, and freed obstacles cannot leave stale anchors.

Fixed integration uses the nearest contact as the sphere center and deducts the remaining path from available length. Elastic tension, stored energy, maximum stretch, reeling direction and visual cords use the same route. CharacterBody collision remains responsible for moving the player. Neither the new route nor its visibility query zeros player velocity as an angle gate. A short arm can still run out of usable length around a wide obstacle.

Scope now applies a 0.5 sensitivity multiplier to **both yaw and pitch**. Previously it applied 0.4 only to yaw, leaving vertical look at full speed.

## Limits and cost

This is approximate wrapping around common arena collision shapes, not a cloth/rope solver. Contacts do not continuously slide along every mesh edge. Unsupported concave/mesh colliders can still visually clip; they do not reintroduce the angle stop. Twelve contacts per arm, two insertions per physics tick and a retry delay bound route work. Multiple cover pieces resolve incrementally. Unusual deeply obstructed configurations need further playtesting.

## Verification

- Complete thirteen-suite regression: **584/584** checks. Source audit: **106** resource references, UIDs and authoring syntax passed.
- Corner regression: **14/14**, covering a 270-degree column path, unwrapping, actual movement in both modes, no injected speed, fixed-length accounting, recall, rotated cover, removed cover, two obstacles and exact 50% scoped sensitivity.
- In the fixed CharacterBody scenario, a 12 m/s entry retained **11.93 m/s** after one second, traveled behind the column, and used exactly **10.05 m** of routed arm length.
- Existing fixed/ceiling traversal suite: **47/47**. Six alternating ceiling grips still cover **27.42 m** without reel input.
- Updated two stale assertions: a blocked reel may now navigate around a slab while retaining body collision; practice targets have supported Watcher firearm reactions since the earlier weapons pass, so the punch check now tests actual nonlethal knockout/recovery behavior.

Tests run inside Godot without desktop control or an interactive launch. These are deterministic mechanical checks, not a claim of a human playtest or arbitrary-mesh rope simulation.
