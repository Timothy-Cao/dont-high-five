"""Original rigid-part courier model. Blender 5.2; Godot-space dimensions in meters."""
import bpy, math
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
bpy.ops.object.select_all(action='SELECT'); bpy.ops.object.delete(use_global=False)

def mat(name,c,rough=.65,metal=0,glow=0):
    m=bpy.data.materials.new(name);m.diffuse_color=(*c,1);m.use_nodes=True
    p=m.node_tree.nodes.get('Principled BSDF');p.inputs['Base Color'].default_value=(*c,1);p.inputs['Roughness'].default_value=rough;p.inputs['Metallic'].default_value=metal
    p.inputs['Emission Color'].default_value=(*c,1);p.inputs['Emission Strength'].default_value=glow
    return m
cream=mat('Warm canvas',(.56,.53,.39));rubber=mat('Dark padded rubber',(.035,.055,.07),.85)
teal=mat('Sea glass shell',(.055,.38,.34),.42);amber=mat('Apricot shell',(.65,.30,.09),.42)
visor=mat('Ink faceplate',(.012,.023,.033),.22,.3);steel=mat('Brushed hardware',(.20,.25,.26),.33,.65)
glow=mat('Mint display',(.20,.82,.67),.35,0,1.5);gold=mat('Amber display',(.94,.53,.13),.35,0,1.2)
def xyz(p):return (p[0],-p[2],p[1])
def box(name,p,size,m,bevel=.05):
    bpy.ops.mesh.primitive_cube_add(size=1,location=xyz(p));o=bpy.context.object;o.name=name;o.dimensions=(size[0],size[2],size[1]);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    o.data.materials.append(m)
    mod=o.modifiers.new('Soft molded corners','BEVEL');mod.width=bevel;mod.segments=5
    o.modifiers.new('Weighted normals','WEIGHTED_NORMAL')
    return o
def egg(name,p,scale,m):
    bpy.ops.mesh.primitive_uv_sphere_add(segments=32,ring_count=20,location=xyz(p));o=bpy.context.object;o.name=name;o.scale=(scale[0],scale[2],scale[1]);o.data.materials.append(m)
    for f in o.data.polygons:f.use_smooth=True
    return o
egg('torso',(0,.94,0),(.31,.44,.24),cream)
box('waist_seal',(0,.59,0),(.53,.10,.40),rubber,.045)
box('chest_panel',(0,1.01,-.224),(.31,.25,.045),teal,.04)
for i in range(3):box('chest_lamp_'+str(i),(-.09+i*.09,1.04,-.253),(.035,.055,.01),gold,.007)
box('head',(0,1.49,-.01),(.58,.43,.43),teal,.11)
box('visor',(0,1.50,-.235),(.49,.28,.075),visor,.085)
for x in [-.105,.105]:box('eye',(x,1.54,-.28),(.060,.072,.022),glow,.017)
box('mouth',(0,1.44,-.283),(.10,.018,.012),glow,.007)
for side in [-1,1]:
    egg('shoulder_'+str(side),(side*.325,1.17,0),(.09,.115,.11),amber if side<0 else teal)
    box('leg_'+str(side),(side*.16,.40,.025),(.10,.26,.105),steel,.03)
    egg('knee_'+str(side),(side*.16,.42,-.035),(.08,.085,.07),rubber)
    box('left_foot' if side<0 else 'right_foot',(side*.17,.145,-.055),(.23,.25,.39),amber if side<0 else teal,.085)
    box('sole_'+str(side),(side*.17,.065,-.065),(.235,.09,.385),rubber,.035)
box('backpack',(0,.99,.265),(.43,.47,.17),rubber,.065)
box('pack_trim',(0,.99,.36),(.33,.35,.055),teal,.055)
for side in [-1,1]:
    egg('spool_'+str(side),(side*.11,1.01,.398),(.075,.075,.026),steel)
    box('spool_glint_'+str(side),(side*.11,1.01,.426),(.013,.085,.01),gold if side<0 else glow,.004)
box('top_seam',(0,1.722,0),(.19,.018,.20),rubber,.008)
bpy.ops.object.select_all(action='SELECT')
bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets/courier.glb'),export_format='GLB',use_selection=True,export_yup=True,export_apply=True)
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/courier.blend'))
print('Exported original 1.74 m courier with separate animated rigid parts.')
