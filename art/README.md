# Original art sources

The gloves, rounded block and parcel are original procedural Blender models. Their current `.blend` files are editable here; runtime exports are in `assets/`. Godot loads GLB files and does not require Blender to play or test the game.

With Blender 5.2 installed, regenerate the models from this project root:

```powershell
blender --background --python art/build_parcel_assets.py
```

This rewrites the four GLB exports and their Blender sources. The generator includes the mirrored right-glove normal repair. `repair_glove_normals.py` can also repair/re-export just the existing right glove.

The arena geometry and carpet are procedural game code. Audio is synthesized by the game. The old outdoor sky and image-generation reference are unused and remain in the pre-migration experiment in the original workspace. No external model service, account, API key or downloaded asset is required by this project.
