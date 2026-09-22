# Original art sources

The gloves, rounded block and parcel are original procedural Blender models. Their current `.blend` files are editable here; runtime exports are in `assets/`. Godot loads GLB files and does not require Blender to play or test the game.

With Blender 5.2 installed, regenerate the models from this project root:

```powershell
blender --background --python art/build_parcel_assets.py
```

This rebuilds the rounded block, parcel, both gloves and both fists, with their Blender sources. The generator calls `build_soft_gloves.py` for the current original padded gloves and matching fists. Both sides are generated with positive scales and inward thumbs; the superseded reflection-repair script has been removed.

The arena geometry and carpet are procedural game code. Audio is prebuilt by `build_audio.py` from original synthesis and included CC0 recordings. See [the audio design notes](../docs/AUDIO-DESIGN.md). The old outdoor sky and image-generation reference are unused and remain in the pre-migration experiment in the original workspace. No external service, account or API key is required at runtime. All necessary assets are included.

## Courier and sound

`blender --background --python art/build_spool.py` rebuilds `courier.blend`, `courier-report.json` and `assets/courier.glb`.

Spool is an original 1.78 m maintenance robot: rounded visor, padded canvas torso, asymmetric boots and shoulder spools. The asset has 12 bones, 24,660 triangles and eight shared material surfaces. Every vertex belongs to a rigid shell with one bone weight; gaskets conceal mechanical joint pivots. Bevels and normals are applied before skinning. Six in-place clips are exported: Idle, Walk, Air, Charge, Punch and Land. The walk uses baked two-bone IK for flat stance feet and clear swing lift. No external rig/animation service or copied character assets are used.

Godot manually advances and blends the clips so pause freezes them. Walk rate follows travel speed, reverse input reverses the gait, and strafing turns the body. Charging while moving preserves the gait and adds torso wind-up. Elastic cords attach to skeletal shoulder positions; gloves and fists stay independently driven by projectile physics. Runtime collision remains the controller capsule. There is no slope foot-placement solver or humanoid retargeting rig yet.

`python art/build_audio.py` rebuilds the 61 sound assets (including the four original recoil pops from `build_blast_audio.py`) and measures the five music tracks. This authoring command requires NumPy and FFmpeg. The included Kenney source samples are CC0; music files are the user-supplied originals.

## Fists, generators and dummies

`blender --background --python art/build_toys.py` exports two closed fists, a charge pedestal, five distinct floating power symbols and the spring target dummy, with all nine editable Blender files alongside the script. Their geometry and materials are original.

## Soft gloves

`blender --background --python art/build_soft_gloves.py` rebuilds both gloves and both compact fists. Source axes are Godot X-right, Y-up, Z-backward; left thumb is +X, right thumb -X. Rounded continuous digits and a molded spool badge replace joint plates and stitching. `soft-gloves-report.json` records orientation. Both older asset entry points invoke this shared generator.
