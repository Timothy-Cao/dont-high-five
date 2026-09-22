"""Original Spool robot: rigid shells, skeletal joints, six in-place clips. Blender 5.2."""
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
box('Hip shell',(0,.74,.02),(.43,.23,.35),teal,'hips',.095)
box('Waist belt',(0,.82,.012),(.47,.075,.38),rubber,'hips',.032)
box('Zip channel',(0,1.075,-.221),(.025,.32,.023),rubber,'spine',.008)
box('Chest pocket',(.116,.98,-.233),(.17,.155,.045),orange,'spine',.026)
box('Pocket flap',(.116,1.055,-.258),(.18,.035,.012),canvas,'spine',.01)
box('Chest badge',(-.115,1.12,-.228),(.13,.09,.025),teal,'spine',.018)
for x in [-.15,-.11,-.07]:box('Status light',(x,1.12,-.244),(.018,.027,.01),gold,'spine',.005)
egg('Neck gasket',(0,1.30,0),(.14,.09,.14),rubber,'spine')
box('Helmet shell',(0,1.53,0),(.65,.49,.49),teal,'head',.135)
box('Visor gasket',(0,1.535,-.235),(.568,.33,.09),rubber,'head',.095)
box('Visor lens',(0,1.55,-.278),(.522,.274,.052),glass,'head',.085)
for s in [-1,1]:
    box('Pill eye',(s*.112,1.585,-.31),(.055,.085,.022),light,'head',.026)
    box('Raised brow',(s*.112,1.655,-.31),(.074,.016,.012),teal,'head',.006)
box('Tiny smile',(0,1.486,-.309),(.077,.018,.018),light,'head',.008)
box('Chin bumper',(0,1.342,-.192),(.27,.085,.14),canvas,'head',.037)
for x in [-.07,0,.07]:box('Chin vent',(x,1.348,-.266),(.026,.038,.014),rubber,'head',.009)
box('Crown seam',(0,1.777,0),(.07,.013,.24),rubber,'head',.006)
for s,L in [(-1,'L'),(1,'R')]:
    paint=orange if s<0 else teal
    egg('Shoulder gasket '+L,(s*.295,1.16,0),(.07,.105,.105),rubber,'shoulder_'+L)
    egg('Shoulder spool '+L,(s*.355,1.16,0),(.075,.118,.118),paint,'shoulder_'+L)
    egg('Spool hub '+L,(s*.416,1.16,0),(.018,.066,.066),metal,'shoulder_'+L)
    egg('Ear cap '+L,(s*.325,1.535,0),(.027,.087,.087),orange if s<0 else canvas,'head')
    egg('Hip joint '+L,(s*.165,.73,.015),(.108,.11,.105),rubber,'thigh_'+L)
    box('Padded thigh '+L,(s*.165,.59,.012),(.175,.28,.19),canvas,'thigh_'+L,.077)
    egg('Knee hinge '+L,(s*.165,.45,0),(.09,.081,.081),rubber,'shin_'+L)
    box('Shin guard '+L,(s*.165,.33,-.006),(.155,.23,.16),paint,'shin_'+L,.061)
    egg('Ankle seal '+L,(s*.165,.205,-.01),(.083,.075,.08),rubber,'foot_'+L)
    box('Boot '+L,(s*.18,.135,-.073),(.245,.235,.38),paint,'foot_'+L,.08)
    box('Boot sole '+L,(s*.18,.045,-.074),(.251,.09,.386),rubber,'foot_'+L,.028)
    box('Toe bumper '+L,(s*.18,.114,-.253),(.185,.062,.035),canvas,'foot_'+L,.018)
    box('Heel tab '+L,(s*.18,.185,.111),(.078,.07,.028),canvas,'foot_'+L,.013)
box('Twin spool backpack',(0,1.02,.262),(.40,.43,.15),rubber,'spine',.065)
box('Pack cover',(0,1.02,.342),(.345,.35,.08),teal,'spine',.055)
for s in [-1,1]:
    egg('Rear winding cassette',(s*.09,1.04,.397),(.068,.068,.025),metal,'spine')
    box('Cassette grip',(s*.09,1.04,.42),(.016,.085,.015),orange if s<0 else light,'spine',.006)
box('Carry handle',(0,1.277,.278),(.22,.048,.082),canvas,'spine',.017)
arm=bpy.data.armatures.new('Spool skeleton');rig=bpy.data.objects.new('SpoolRig',arm);bpy.context.collection.objects.link(rig)
bpy.context.view_layer.objects.active=rig;rig.select_set(True);bpy.ops.object.mode_set(mode='EDIT')
bones=[('root',(0,0,0),(0,.2,0),None),('hips',(0,.74,0),(0,.91,0),'root'),('spine',(0,.86,0),(0,1.25,0),'hips'),('head',(0,1.30,0),(0,1.72,0),'spine')]
for s,L in [(-1,'L'),(1,'R')]:
    bones.extend([('shoulder_'+L,(s*.29,1.16,0),(s*.44,1.16,0),'spine'),('thigh_'+L,(s*.165,.74,0),(s*.165,.45,0),'hips'),('shin_'+L,(s*.165,.45,0),(s*.165,.205,0),'thigh_'+L),('foot_'+L,(s*.165,.205,0),(s*.165,.205,-.22),'shin_'+L)])
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
clips={'Idle':60,'Walk':24,'Air':30,'Charge':30,'Punch':12,'Land':12}
def aim_bone(name,head,tail):
    b=rig.pose.bones[name];rest=arm.bones[name]
    q=(rest.tail_local-rest.head_local).rotation_difference(tail-head)
    matrix=q.to_matrix().to_4x4() @ rest.matrix_local.to_quaternion().to_matrix().to_4x4()
    matrix.translation=head;b.matrix=matrix
    bpy.context.view_layer.update()
def planted_leg(L,ankle,height):
    s=-1 if L=='L' else 1
    hip=Vector(xyz((s*.165,.74+height,0)));end=Vector(xyz(ankle))
    delta=end-hip;d=min(delta.length,.5349);u=delta.normalized()
    along=(.29**2-.245**2+d*d)/(2*d)
    forward=Vector((0,1,0));bend=(forward-u*forward.dot(u)).normalized()
    knee=hip+u*along+bend*math.sqrt(max(0,.29**2-along**2))
    aim_bone('thigh_'+L,hip,knee);aim_bone('shin_'+L,knee,end)
    foot=arm.bones['foot_'+L].matrix_local.copy();foot.translation=end;rig.pose.bones['foot_'+L].matrix=foot
    bpy.context.view_layer.update()
for name,last in clips.items():
    action=bpy.data.actions.new(name);rig.animation_data.action=action
    for frame in range(1,last+2):
        t=(frame-1)/last;a=t*math.tau;r={};height=0
        if name=='Idle':r={'spine':(.018*math.sin(a),0,0),'head':(0,.025*math.sin(a),.025*math.sin(a))};height=.008*math.sin(a)
        elif name=='Walk':
            r={'spine':(.045,0,.035*math.sin(a)),'head':(-.025,0,-.02*math.sin(a))};height=-.015+.018*math.cos(a*2)
            for s,L in [(-1,'L'),(1,'R')]:
                phase=a+(math.pi if s>0 else 0);swing=.48*math.sin(phase);knee=-.55*max(0,math.cos(phase))
                r['thigh_'+L]=(swing,0,0);r['shin_'+L]=(knee,0,0);r['foot_'+L]=(-swing-knee,0,0)
                r['shoulder_'+L]=(.02*math.sin(phase),.08*math.sin(phase),0)
        elif name=='Air':r={'spine':(-.09,0,0),'head':(.09,0,0),'thigh_L':(.35,0,-.08),'thigh_R':(-.12,0,.08),'shin_L':(-.6,0,0),'shin_R':(-.4,0,0),'foot_L':(.25,0,0),'foot_R':(.4,0,0)}
        elif name in ['Charge','Land']:
            k=t if name=='Charge' else math.sin(math.pi*t);height=-.04*k
            r={'spine':(-.12*k if name=='Charge' else .1*k,0,0),'head':(.09*k,0,0)}
            for L in ['L','R']:r['thigh_'+L]=(.2*k,0,0);r['shin_'+L]=(-.4*k,0,0);r['foot_'+L]=(.2*k,0,0)
        elif name=='Punch':
            k=math.sin(t*math.pi)*math.exp(-t*2);r={'spine':(.23*k,0,0),'head':(-.12*k,0,0)}
        if name!='Air':height-=.025
        if name=='Walk':height=-.085+.008*math.cos(a*2)
        for b in rig.pose.bones:
            b.rotation_mode='XYZ';b.rotation_euler=r.get(b.name,(0,0,0));b.location=(0,height if b.name=='hips' else 0,0)
        bpy.context.view_layer.update()
        # Baked two-bone IK: stance soles stay flat; swing toes lift cleanly.
        if name!='Air':
            for s,L in [(-1,'L'),(1,'R')]:
                phase=(t+(0.5 if s>0 else 0))%1;z=0;lift=0
                if name=='Walk':
                    if phase<.5:z=-.24+.48*phase/.5
                    else:
                        swing=(phase-.5)/.5;z=.24-.48*(.5-.5*math.cos(math.pi*swing));lift=.115*math.sin(math.pi*swing)
                planted_leg(L,(s*.165,.205+lift,z),height)
        for b in rig.pose.bones:
            b.keyframe_insert(data_path='rotation_euler',frame=frame,group=b.name);b.keyframe_insert(data_path='location',frame=frame,group=b.name)
    track=rig.animation_data.nla_tracks.new();track.name=name;track.strips.new(name,1,action);track.mute=True
rig.animation_data.action=None
for b in rig.pose.bones:b.rotation_euler=(0,0,0);b.location=(0,0,0)
scene.frame_set(1);bpy.ops.object.select_all(action='DESELECT');rig.select_set(True);body.select_set(True);bpy.context.view_layer.objects.active=rig
bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets/courier.glb'),export_format='GLB',use_selection=True,export_yup=True,export_animations=True,export_animation_mode='ACTIONS',export_force_sampling=True,export_apply=False)
bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art/courier.blend'))
report={'bones':len(bones),'vertices':len(body.data.vertices),'triangles':sum(len(p.vertices)-2 for p in body.data.polygons),'clips':list(clips),'height_m':1.784,'representation':'Original skeletal rigid-shell robot; all vertices weighted; no root motion'}
(ROOT/'art/courier-report.json').write_text(json.dumps(report,indent=2));print(report)

