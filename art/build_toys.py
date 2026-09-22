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

def reset():
    bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
def ring(name,p,r,thick,m,vertical=False):
    bpy.ops.mesh.primitive_torus_add(major_radius=r,minor_radius=thick,major_segments=48,minor_segments=10,location=xyz(p))
    o=bpy.context.object;o.name=name;o.data.materials.append(m)
    if vertical:o.rotation_euler.x=math.pi/2
    for f in o.data.polygons:f.use_smooth=True
    return o
def export(name):
    bpy.ops.object.select_all(action='SELECT')
    bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets'/f'{name}.glb'),export_format='GLB',use_selection=True,export_yup=True,export_apply=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art'/f'{name}.blend'))
pink=mat('Magenta charge',(.76,.17,.56),.4,0,1.2)
blue=mat('Violet charge',(.27,.36,.95),.4,0,1.1)
reset()

egg('weighted_base',(0,.16,0),(1.1,.18,1.1),rubber)
ring('base_trim',(0,.20,0),.94,.035,steel)
box('capacitor_pedestal',(0,.53,0),(1.15,.67,1.15),teal,.16)
for side in [-1,1]:
    for z in [-.37,0,.37]:box('vent',(side*.578,.53,z),(.025,.31,.12),rubber,.015)
ring('top_lip',(0,.87,0),.69,.065,steel)
egg('charging_bowl',(0,.84,0),(.61,.11,.61),visor)
for angle in [0,math.pi/2,math.pi,math.pi*1.5]:
    box('foot',(math.cos(angle)*.87,.14,math.sin(angle)*.87),(.35,.22,.35),steel,.07)
export('power_station')
for kind,color in [('reach',glow),('pull',gold),('speed',pink),('vision',blue),('overdrive',gold)]:
    reset()
    if kind=='reach':
        for x in [-.36,.36]:
            ring('spool',(x,0,0),.15,.043,color,True)
            box('shaft',(x,0,0),(.07,.07,.26),steel,.015)
        for x in [-.17,0,.17]:box('stretch_segment',(x,0,0),(.12,.11,.12),color,.025)
    elif kind=='pull':
        for i,(x,y) in enumerate([(-.11,.24),(.03,0),(.16,-.23)]):
            o=box('lightning_'+str(i),(x,y,0),(.16,.41,.15),color,.025);o.rotation_euler.y=-.52
        ring('field',(0,0,.07),.48,.025,steel,True)
    elif kind=='speed':
        for y in [-.18,.18]:
            for side in [-1,1]:
                o=box('chevron',(side*.16,y,0),(.13,.45,.18),color,.03);o.rotation_euler.y=side*-.75
    elif kind=='vision':
        ring('lens_rim',(0,0,0),.38,.055,steel,True)
        egg('lens',(0,0,0),(.28,.28,.14),color)
        egg('pupil',(0,0,-.14),(.12,.12,.025),visor)
    else:
        egg('core',(0,0,0),(.23,.32,.23),gold)
        ring('orbit_one',(0,0,0),.49,.043,glow,True)
        o=ring('orbit_two',(0,0,0),.49,.043,pink,True);o.rotation_euler.z=.9
        for y in [-.52,.52]:egg('pole',(0,y,0),(.10,.10,.10),gold)
    export('power_'+kind)
reset()
egg('dummy_base',(0,.15,0),(1.03,.16,.88),rubber)
ring('base_band',(0,.22,0),.77,.035,steel)
box('spring_post',(0,.85,0),(.18,1.15,.18),steel,.04)
for y in [.45,.61,.77,.93,1.09]:ring('spring',(0,y,0),.19,.035,steel)
egg('padded_target',(0,1.85,0),(.78,.75,.40),amber)
box('shoulder_bar',(0,2.12,0),(1.72,.23,.33),rubber,.09)
egg('head',(0,2.77,0),(.36,.37,.31),teal)
box('face',(0,2.78,-.28),(.49,.18,.06),visor,.045)
for x in [-.13,.13]:box('eye',(x,2.78,-.319),(.065,.042,.015),pink,.01)
for r in [.39,.22]:ring('target_ring',(0,1.85,-.389),r,.042,glow,True)
egg('bullseye',(0,1.85,-.41),(.10,.10,.032),gold)
export('target_dummy')
print('Built two fists, station, five power silhouettes and spring dummy.')

# Current original soft gloves and matching fists share one source.
import runpy
runpy.run_path(str(ROOT/"art/build_soft_gloves.py"),run_name="__main__")
