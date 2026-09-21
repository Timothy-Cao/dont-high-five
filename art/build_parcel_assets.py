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

for side,paint in [('left',amber),('right',teal)]:
    clear()
    # Palm, padded heel, dark side gusset and a contrasting stitched back patch.
    ellipsoid('Soft rubber glove', (0,0,0),(.112,.05,.125),paint)
    ellipsoid('Palm grip pad',(0,.044,-.006),(.082,.016,.089),ink)
    box('Back of hand patch',(0,-.048,.015),(.125,.014,.11),paper,.024)
    for x in [-.047,.047]:
        for z in [-.025,0,.025,.05]:
            segment('Visible stitch',(x,-.060,z),(x,-.060,z+.009),.0018,stitch)
    # Raised parcel emblem: a small box with tape, no baked text.
    box('Parcel emblem',(0,-.06,.013),(.047,.008,.038),paint,.004)
    box('Parcel tape',(0,-.066,.013),(.007,.004,.038),paper,.001)
    # Four individually articulated digits with different lengths and gentle curl.
    for idx,(x,length) in enumerate([(-.076,.15),(-.026,.19),(.028,.178),(.079,.135)]):
        z=.087
        spread=(idx-1.5)*.009
        a=(x,0,z)
        b=(x+spread,.008,z+length*.48)
        c=(x+spread*1.4,.032,z+length*.81)
        d=(x+spread*1.4,.060,z+length)
        radius=.026 if idx<3 else .024
        segment('Finger base',a,b,radius,paint)
        segment('Finger middle',b,c,radius*.94,paint)
        segment('Finger tip',c,d,radius*.9,paint)
        ellipsoid('Knuckle reinforcement',(b[0],b[1]-.025,b[2]),(.022,.009,.026),paper)
        ellipsoid('Fingertip grip',(d[0],d[1]+.008,d[2]-.012),(.018,.011,.027),ink)
        ring('Finger flex seam',b,radius*.96,.0023,ink,rotation=(math.pi/2,0,0))
    segment('Thumb root',(-.082,0,-.052),(-.145,.012,-.005),.038,paint)
    segment('Thumb tip',(-.145,.012,-.005),(-.16,.050,.062),.031,paint)
    ellipsoid('Thumb grip',(-.167,.067,.044),(.021,.012,.03),ink)
    box('Canvas wrist cuff',(0,0,-.133),(.173,.105,.09),paper,.025)
    box('Wrist cinch',(0,-.060,-.133),(.18,.017,.032),ink,.008)
    box('Buckle',(0.053,-.071,-.133),(.038,.01,.040),metal,.007)
    box('Buckle center',(0.053,-.078,-.133),(.019,.004,.021),ink,.003)
    ring('Arm socket',(0,0,-.18),.056,.013,ink)
    if side=='right':
        for o in list(bpy.context.scene.objects):
            o.location.x*=-1
            o.scale.x*=-1
    export('glove_'+side)

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
