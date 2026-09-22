# Movement playtest release 0.2

Published 2026-09-21 at https://github.com/Timothy-Cao/dont-high-five/releases/tag/v0.2.0 after the user requested a stable build for another tester.

- Tag: `v0.2.0`, source commit `ff5930a`.
- Asset: `DontHighFive-v0.2.0-Windows.zip`, 139,051,747 bytes.
- SHA-256: `1e493e41a2743c8dddeb225d88f17c18fb0332f73782b708c15501b101cb5533`.
- GitHub's uploaded asset digest matches the local checksum; accompanying checksum file uploaded.
- The 393-entry saved package was extracted into an isolated checkout and all eleven suites passed: **444 assertions**. Every release source file came from that snapshot; the unfinished `scripts/gameplay/` module was absent.
- Includes automatic fixed arms, ceiling handover, afterimages, nonlethal punches, recoil, revised Spool/glove models, arena infill, soundtrack and settings.
- Excludes the later local role-switching/training/task prototype. The main working directory was preserved throughout. Only the release tag was pushed; the current development work was not published.

The portable ZIP bundles Godot. Extract the whole ZIP and use `Play.cmd`. The first launch imports assets. It is a development package, not a production export. The validation environment reports certificate-store and resource-teardown warnings, but no script errors or failed checks.
