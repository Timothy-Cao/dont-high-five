import bpy, math, bmesh
from pathlib import Path
from mathutils import Vector

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / 'assets'
ASSETS.mkdir(exist_ok=True)

def material(name, color, rough=.55, metal=0):
    m=bpy.data.materials.new(name)
    m.diffuse_color=(*color,1)
    m.use_nodes=True
    p=m.node_tree.nodes.get('Principled BSDF')
    p.inputs['Base Color'].default_value=(*color,1)
    p.inputs['Roughness'].default_value=rough
    p.inputs['Metallic'].default_value=metal
    return m

ink=material('Charcoal rubber',(.045,.075,.085),.8)
paper=material('Warm cotton',(.64,.61,.47),.72)
stitch=material('Cotton stitching',(.86,.75,.49),.7)
metal=material('Brushed buckle',(.22,.29,.29),.32,.6)
amber=material('Apricot glove',(.63,.30,.105),.48)
teal=material('Seafoam glove',(.08,.36,.32),.48)

def clear():
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.delete(use_global=False)

def finish(o,name,mat):
    o.name=name
    o.data.materials.append(mat)
    return o

def box(name, p, size, mat, bevel=.015):
    bpy.ops.mesh.primitive_cube_add(size=1,location=p)
    o=bpy.context.object
    o.scale=size
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    b=o.modifiers.new('Rounded stitched construction','BEVEL')
    b.width=bevel;b.segments=5
    o.modifiers.new('Weighted normals','WEIGHTED_NORMAL')
    return finish(o,name,mat)

def ellipsoid(name,p,size,mat):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=32,ring_count=20,location=p)
    o=bpy.context.object;o.scale=size
    for poly in o.data.polygons:poly.use_smooth=True
    return finish(o,name,mat)

def segment(name,a,b,r,mat):
    a,b=Vector(a),Vector(b)
    o=ellipsoid(name,(a+b)*.5,(r,r,(b-a).length*.5+r*.45),mat)
    o.rotation_euler=(b-a).to_track_quat('Z','Y').to_euler()
    return o

def ring(name,p,r,thickness,mat,rotation=(0,0,0)):
    bpy.ops.mesh.primitive_torus_add(major_segments=48,minor_segments=12,location=p,major_radius=r,minor_radius=thickness,rotation=rotation)
    o=bpy.context.object
    for poly in o.data.polygons:poly.use_smooth=True
    return finish(o,name,mat)

def export(name):
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.object.convert(target='MESH')
    # Bake reflected transforms before joining/exporting; keep outward normals.
    for o in list(bpy.context.scene.objects):
        if o.type=='MESH' and o.matrix_world.determinant()<0:
            bpy.ops.object.select_all(action='DESELECT')
            o.select_set(True)
            bpy.context.view_layer.objects.active=o
            bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
            bm=bmesh.new();bm.from_mesh(o.data)
            bmesh.ops.recalc_face_normals(bm,faces=list(bm.faces))
            bm.to_mesh(o.data);bm.free()
    groups={}
    for o in list(bpy.context.scene.objects):
        if o.type=='MESH':groups.setdefault(o.data.materials[0].name,[]).append(o)
    for name_mat,items in groups.items():
        bpy.ops.object.select_all(action='DESELECT')
        for o in items:o.select_set(True)
        bpy.context.view_layer.objects.active=items[0]
        bpy.ops.object.join();items[0].name=name_mat
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.export_scene.gltf(filepath=str(ASSETS/(name+'.glb')),export_format='GLB',use_selection=True,export_yup=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art'/(name+'.blend')))

clear()
box('Soft modular block',(0,0,0),(1,1,1),paper,.045)
export('rounded_block')

clear()
box('Cardboard parcel',(0,0,.5),(1.2,.9,1),paper,.055)
box('Longitudinal packing tape',(0,0,.505),(.13,.914,1.02),amber,.008)
box('Cross packing tape',(0,0,.508),(1.215,.11,1.025),amber,.008)
box('Shipping label',(.30,-.458,.68),(.32,.008,.22),stitch,.01)
for x in [.21,.25,.28,.32,.345,.38]:
    box('Barcode stripe',(x,-.466,.65),(.009,.004,.085),ink,.001)
export('parcel')

# Use the current original padded glove source, also shared with the fist builder.
import runpy
runpy.run_path(str(ROOT/"art/build_soft_gloves.py"),run_name="__main__")
