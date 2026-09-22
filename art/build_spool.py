"""Original Spool unicycle: rigid shells, suspension, driven tire and eight clips."""
import bpy, math, json
from mathutils import Vector
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
bpy.context.preferences.filepaths.save_version=0
def xyz(p):return(p[0],-p[2],p[1])
def mat(name,c,rough=.6,metal=0,glow=0):
    m=bpy.data.materials.new(name);m.diffuse_color=(*c,1);m.use_nodes=True;p=m.node_tree.nodes.get('Principled BSDF')
    for k,v in [('Base Color',(*c,1)),('Roughness',rough),('Metallic',metal),('Emission Color',(*c,1)),('Emission Strength',glow)]:p.inputs[k].default_value=v
    return m
canvas=mat('Oat padded suit',(.63,.58,.43),.82);teal=mat('Sea glass enamel',(.055,.33,.30),.38)
orange=mat('Apricot enamel',(.73,.29,.085),.4);rubber=mat('Ink rubber joints',(.023,.037,.049),.84)
glass=mat('Smoky visor',(.014,.027,.035),.21,.25);metal=mat('Satin spool metal',(.23,.29,.29),.37,.62)
light=mat('Warm face LEDs',(.75,.91,.72),.4,0,.8);gold=mat('Amber status lamp',(.95,.46,.12),.4,0,1.1)
parts=[]
def part(name,p,size,m,bone,bevel=.05,egg=False):
    if egg:
        bpy.ops.mesh.primitive_uv_sphere_add(segments=24,ring_count=16,location=xyz(p));o=bpy.context.object;o.scale=(size[0],size[2],size[1])
    else:
        bpy.ops.mesh.primitive_cube_add(size=1,location=xyz(p));o=bpy.context.object;o.dimensions=(size[0],size[2],size[1])
    bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    if not egg:
        mod=o.modifiers.new('Molded radii','BEVEL');mod.width=bevel;mod.segments=4;bpy.ops.object.modifier_apply(modifier=mod.name)
    for f in o.data.polygons:f.use_smooth=True
    if not egg:
        mod=o.modifiers.new('Weighted normals','WEIGHTED_NORMAL');mod.keep_sharp=True;bpy.ops.object.modifier_apply(modifier=mod.name)
    o.name=name;o.data.materials.append(m);parts.append((o,bone));return o
def box(*a,**k):return part(*a,**k)
def egg(*a,**k):return part(*a,**k,egg=True)
egg('Padded pear torso',(0,1.02,.02),(.30,.33,.245),canvas,'spine')
box('Hip shell',(0,.85,.02),(.48,.15,.35),teal,'hips',.095)
box('Waist belt',(0,.82,.012),(.47,.075,.38),rubber,'hips',.032)
egg('Neck gasket',(0,1.30,0),(.14,.09,.14),rubber,'spine')
box('Helmet shell',(0,1.53,0),(.65,.49,.49),teal,'head',.135)
box('Visor gasket',(0,1.535,-.235),(.568,.33,.09),rubber,'head',.095)
box('Visor lens',(0,1.55,-.278),(.522,.274,.052),glass,'head',.085)
for s in [-1,1]:
    box('Pill eye',(s*.112,1.585,-.31),(.055,.085,.022),light,'head',.026)
    box('Raised brow',(s*.112,1.655,-.31),(.074,.016,.012),teal,'head',.006)
box('Tiny smile',(0,1.486,-.309),(.077,.018,.018),light,'head',.008)
box('Chin bumper',(0,1.342,-.192),(.27,.085,.14),canvas,'head',.037)
for s,L in [(-1,'L'),(1,'R')]:
    paint=orange if s<0 else teal
    egg('Shoulder gasket '+L,(s*.295,1.16,0),(.07,.105,.105),rubber,'shoulder_'+L)
    egg('Shoulder spool '+L,(s*.355,1.16,0),(.075,.118,.118),paint,'shoulder_'+L)
    egg('Spool hub '+L,(s*.416,1.16,0),(.018,.066,.066),metal,'shoulder_'+L)
    egg('Ear cap '+L,(s*.325,1.535,0),(.027,.087,.087),orange if s<0 else canvas,'head')
import sys
sys.path.insert(0,str(ROOT/'art'))
from spool_wheel import build_wheel
build_wheel(parts,box,xyz,rubber,metal,teal,orange,gold,light)
arm=bpy.data.armatures.new('Spool skeleton');rig=bpy.data.objects.new('SpoolRig',arm);bpy.context.collection.objects.link(rig)
bpy.context.view_layer.objects.active=rig;rig.select_set(True);bpy.ops.object.mode_set(mode='EDIT')
bones=[('root',(0,0,0),(0,.2,0),None),('hips',(0,.74,0),(0,.91,0),'root'),('spine',(0,.86,0),(0,1.25,0),'hips'),('head',(0,1.30,0),(0,1.72,0),'spine')]
for side,L in [(-1,'L'),(1,'R')]:
    bones.extend([('shoulder_'+L,(side*.29,1.16,0),(side*.44,1.16,0),'spine'),('brake_'+L,(side*.34,.5,.04),(side*.34,.25,.04),'root')])
bones.append(('wheel',(0,.43,0),(0,.63,0),'root'))
for name,head,tail,parent in bones:
    b=arm.edit_bones.new(name);b.head=xyz(head);b.tail=xyz(tail)
    if parent:b.parent=arm.edit_bones[parent]
bpy.ops.object.mode_set(mode='OBJECT')
for o,bone in parts:
    vg=o.vertex_groups.new(name=bone);vg.add(list(range(len(o.data.vertices))),1,'REPLACE');o.parent=rig
    mod=o.modifiers.new('Spool skin','ARMATURE');mod.object=rig
bpy.ops.object.select_all(action='DESELECT')
for o,_ in parts:o.select_set(True)
bpy.context.view_layer.objects.active=parts[0][0];bpy.ops.object.join();body=bpy.context.object;body.name='SpoolCourier'
rig.show_in_front=True;rig.animation_data_create();scene=bpy.context.scene;scene.render.fps=30
clips={'Idle':60,'Walk':30,'Air':30,'Charge':30,'Punch':12,'Land':18,'Brake':18,'Hang':30}
for name,last in clips.items():
    action=bpy.data.actions.new(name);rig.animation_data.action=action
    for frame in range(1,last+2):
        t=(frame-1)/last;a=t*math.tau;r={};height=0
        if name=='Idle':r={'spine':(.012*math.sin(a),0,0),'head':(0,.025*math.sin(a),0)};height=.006*math.sin(a)
        elif name=='Walk':r={'spine':(.055,0,0),'head':(-.04,0,0)};height=.004*math.cos(a*2)
        elif name=='Air':r={'spine':(-.10,0,0),'head':(.07,0,0)};height=.045
        elif name=='Hang':r={'spine':(-.13,0,0),'head':(.16,0,0)};height=.06
        elif name in ['Charge','Land','Brake']:
            k=t if name in ['Charge','Brake'] else math.sin(math.pi*t)
            height=-.10*k;r={'spine':(-.16*k if name=='Charge' else .08*k,0,0),'head':(.07*k,0,0)}
        elif name=='Punch':
            k=math.sin(t*math.pi)*math.exp(-t*2);r={'spine':(.23*k,0,0),'head':(-.12*k,0,0)}
        for b in rig.pose.bones:
            b.rotation_mode='XYZ';b.rotation_euler=r.get(b.name,(0,0,0));b.location=(0,height if b.name=='hips' else 0,0)
            if b.name.startswith('brake_'):b.rotation_euler.x=-2.4 if name!='Brake' else -2.4*(1-t)
            b.keyframe_insert(data_path='rotation_euler',frame=frame,group=b.name);b.keyframe_insert(data_path='location',frame=frame,group=b.name)
    track=rig.animation_data.nla_tracks.new();track.name=name;track.strips.new(name,1,action);track.mute=True
rig.animation_data.action=None
for b in rig.pose.bones:b.rotation_euler=(0,0,0);b.location=(0,0,0)
scene.frame_set(1);bpy.ops.object.select_all(action='DESELECT');rig.select_set(True);body.select_set(True);bpy.context.view_layer.objects.active=rig
bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets/courier.glb'),export_format='GLB',use_selection=True,export_yup=True,export_animations=True,export_animation_mode='ACTIONS',export_force_sampling=True,export_apply=False)
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/courier.blend'))
report={'bones':len(bones),'vertices':len(body.data.vertices),'triangles':sum(len(p.vertices)-2 for p in body.data.polygons),'clips':list(clips),'height_m':1.784,'representation':'Original nine-bone unicycle; independently driven wheel and brakes; no root motion'}
(ROOT/'art/courier-report.json').write_text(json.dumps(report,indent=2));print(report)
