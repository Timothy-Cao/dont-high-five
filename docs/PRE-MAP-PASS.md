# Pre-map refinement verification

2026-09-22. See [the ranked roadmap and research](design/PRE-MAP-ROADMAP.md) for decisions and remaining work.

Before editing, the exact previous standalone package was copied into the parent workspace's `archive/dont-high-five-stable-20260922-001542/`. All 638 package entries matched the then-current source byte-for-byte; ZIP CRC verification passed. SHA-256: `9520af99d3c8d0f3261035ab781218b492c876725643082a9e56ed2f0850c768`. Current user preferences were copied alongside it. No workshop map was present in the custom user directory. This archive is separate from the subsequently refreshed standalone package.

## Implemented and verified

- Positional world combat audio, operator feedback retained, 32 pooled world voices with eight reserved for blasts, quieter spatial orbital field audio.
- Brief yaw-relative incoming-hit cue. Repeated-source merging, expiry and retry cleanup; no persistent target tracking.
- Workshop middle-click picking, safe Shift+F7 test start, local retry, edit-camera restoration, separate periodic recovery and undoable recovery loading.
- Test recovery paths are isolated from user files. Existing map format remains version 1; temporary test starts do not alter saved maps.

`tools/Run.ps1 -Mode Verify`: **20 suites, 769 passing assertions**, including 26 new refinement checks. Fresh import and source audit passed (162 resource references). Existing engine certificate-store, teardown and dummy-renderer warnings remain; no script/test failures were reported. Updated CI includes the new suite.

Actual 1440×900 engine renders were inspected for hit-direction placement, workshop instructions and the recovery menu:

- [Incoming-hit cue](screenshots/refinement-hit-direction.png)
- [Workshop](screenshots/refinement-workshop.png)
- [Recovery menu](screenshots/refinement-recovery-menu.png)

Captures were self-terminating authored render fixtures, without desktop control. No interactive human playtest or headphone listening session was performed. Sound direction uses native engine spatialization, and routing/limits/pause were tested; perceived mix quality still needs listening. The main arena geometry, movement balance and character assets were preserved.

## Known bounds

Recovery runs every 60 unpaused workshop seconds, plus on leaving; it is not continuous per-edit crash protection. Middle-click picks a reusable module, not a move/group tool. Test-here needs visible walkable ground and clear capsule headroom. World audio currently has distance filtering but no wall obstruction, binaural HRTF or room reverb. Full functional prop placement and group editing are the recommended next investments before a long hand-built map session.
