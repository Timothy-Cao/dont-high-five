"""Repair the saved mirrored glove without regenerating unrelated assets."""
import bpy,bmesh
from pathlib import Path
root=Path(__file__).resolve().parents[1]
bpy.ops.wm.open_mainfile(filepath=str(root/'art/glove_right.blend'))
for o in list(bpy.context.scene.objects):
    if o.type!='MESH': continue
    bpy.ops.object.select_all(action='DESELECT')
    o.select_set(True)
    bpy.context.view_layer.objects.active=o
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    bm=bmesh.new();bm.from_mesh(o.data)
    bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
    bm.to_mesh(o.data);bm.free()
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=str(root/'assets/glove_right.glb'),export_format='GLB',use_selection=True,export_yup=True)
bpy.ops.wm.save_as_mainfile(filepath=str(root/'art/glove_right.blend'))
