# Original art sources

The gloves, rounded block and parcel are original procedural Blender models. Their current `.blend` files are editable here; runtime exports are in `assets/`. Godot loads GLB files and does not require Blender to play or test the game.

With Blender 5.2 installed, regenerate the models from this project root:

```powershell
blender --background --python art/build_parcel_assets.py
```

This rewrites the four GLB exports and their Blender sources. The generator includes the mirrored right-glove normal repair. `repair_glove_normals.py` can also repair/re-export just the existing right glove.

The arena geometry and carpet are procedural game code. Audio is prebuilt by `build_audio.py` from original synthesis and included CC0 recordings. See [the audio design notes](../docs/AUDIO-DESIGN.md). The old outdoor sky and image-generation reference are unused and remain in the pre-migration experiment in the original workspace. No external service, account or API key is required at runtime. All necessary assets are included.

## Courier and sound

`blender --background --python art/build_avatar.py` rebuilds the editable courier and `assets/courier.glb`. Evaluated modifiers must be exported so molded corners survive into Godot.

`python art/build_audio.py` rebuilds the 57 sound assets and measures the five music tracks. This authoring command requires NumPy and FFmpeg. The included Kenney source samples are CC0; music files are the user-supplied originals.
