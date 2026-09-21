# Don’t High Five — playground 0.1

The standalone project now has its own name and GitHub home. The playable build remains a single-player movement prototype; social deduction, networked players and high-five exchanges are design proposals.

## This pass

- Replaced the large pause navigation with Play/Resume, Settings and Quit.
- Replaced the visual keyboard workbench with an action/key list. Click a key, press its replacement; occupied bindings swap and Esc cancels.
- Music and sound effects are directly in Settings, defaulting to 50%. Music receives ×0.25 gain. Both zero positions truly mute their buses.
- Added persistent audio, sensitivity, brightness, camera-motion and fullscreen preferences with validation. Existing keyboard bindings remain compatible.
- Added an upper-northeast red suppression room. Powered arms are disabled inside; fields block incoming hands, while both doors permit walking. There is no killer exception.
- Added original in-engine 4K gallery images, including two posed character models, and a research notebook separating proposed multiplayer rules from implemented features.
- Added a pinned, checksum-verified Godot setup script and seven-suite GitHub verification workflow.

## Verification

Local Godot 4.7.2: controller 37/37, movement 43/43, polish 24/24, arena 70/70, expansion 54/54, combat/powers 44/44, settings/room 27/27. **299/299 assertions pass.** No script errors or failed assertions in the final local run. Windows certificate-store and shutdown resource warnings remain in this sandbox.

Eight 4K captures were inspected. New tests exercise actual UI signals, volume-to-bus gain, zero mute, preference reload and invalid values, key swaps/cancellation, field entry, anchor cancellation, both physical exits, and incoming glove/punch interception. No desktop automation or system input injection was used. No human multiplayer test occurred.

## Package

`DontHighFive-standalone.zip` contains one `dont-high-five/` project with source, assets, authoring files and the Windows Godot runtime. Caches, credentials, personal settings, logs and old workspace experiments are excluded. Source clones can install the same pinned runtime with `tools/Setup-Godot.ps1`.
