"""Original Sentinel tower kit. Blender source and glTF, metres, Godot Y up."""
import bpy, math, json
from pathlib import Path
from mathutils import Vector
ROOT=Path(__file__).resolve().parents[1]
bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
def xyz(p):return (p[0],-p[2],p[1])
def mat(name,c,metal=.0,rough=.4,emission=0):
 m=bpy.data.materials.new(name);m.diffuse_color=(*c,1);m.use_nodes=True;p=m.node_tree.nodes.get('Principled BSDF')
 for key,val in [('Base Color',(*c,1)),('Metallic',metal),('Roughness',rough),('Emission Color',(*c,1)),('Emission Strength',emission)]:p.inputs[key].default_value=val
 return m
armor=mat('Sentinel obsidian ceramic',(.027,.045,.065),.45,.32)
edge=mat('Sentinel graphite bevels',(.12,.17,.21),.7,.28)
black=mat('Sentinel recessed carbon',(.006,.009,.014),.1,.65)
red=mat('Sentinel ruby power channels',(1,.015,.047),.2,.25,4)
orange=mat('Sentinel molten iris',(1,.12,.025),.15,.25,5)
white=mat('Sentinel hot pupil edge',(1,.53,.22),.1,.2,7)
def finish(o,name,m):
 o.name=name;o.data.materials.append(m)
 bevel=o.modifiers.new('Machined edge highlights','BEVEL');bevel.width=.035;bevel.segments=3
 o.modifiers.new('Weighted corner normals','WEIGHTED_NORMAL')
 return o
def box(name,pos,size,m,angle=0):
 bpy.ops.mesh.primitive_cube_add(size=1,location=xyz(pos));o=bpy.context.object;o.dimensions=(size[0],size[2],size[1]);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 o.rotation_euler.y=angle;return finish(o,name,m)
def prism(name,polygon,depth,m):
 verts=[xyz((x,y,z)) for z in [-depth/2,depth/2] for x,y in polygon];n=len(polygon)
 faces=[tuple(range(n-1,-1,-1)),tuple(range(n,2*n))]+[(i,(i+1)%n,(i+1)%n+n,i+n) for i in range(n)]
 mesh=bpy.data.meshes.new(name);mesh.from_pydata(verts,[],faces);mesh.update();o=bpy.data.objects.new(name,mesh);bpy.context.collection.objects.link(o);return finish(o,name,m)
def line(name,a,b,width,m):
 a=Vector(xyz(a));b=Vector(xyz(b));bpy.ops.mesh.primitive_cylinder_add(vertices=8,radius=width,depth=(b-a).length,location=(a+b)/2);o=bpy.context.object;o.rotation_euler=(b-a).to_track_quat('Z','Y').to_euler();return finish(o,name,m)
def export(name):
 bpy.ops.object.select_all(action='SELECT');bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art'/f'{name}.blend'))
 bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets'/f'{name}.glb'),export_format='GLB',export_yup=True,export_apply=True)
 triangles=sum(len(o.data.polygons) for o in bpy.context.scene.objects if o.type=='MESH')
 print(name,triangles,'source faces')
 bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
# Base module: grounded, layered octagonal housing and four chamfered feet.
for y,r,d,m in [(.12,1.85,.24,black),(.34,1.63,.22,edge),(.57,1.5,.27,armor),(.75,1.26,.12,edge)]:
 bpy.ops.mesh.primitive_cylinder_add(vertices=8,radius=r,depth=d,location=xyz((0,y,0)));finish(bpy.context.object,'Octagonal foundation',m)
for side in [-1,1]:
 box('Front power inlet',(side*.72,.52,-1.37),(.13,.26,.04),red)
 box('Foot clamp',(side*1.35,.25,0),(.4,.5,.9),armor)
export('watcher_base')
# Repeatable shaft section; no baked tall-tower stretch details.
box('Central load spine',(0,.5,0),(1.65,1,1.5),armor)
for x in [-.87,.87]:
 box('Armour rib',(x,.5,0),(.16,.98,1.7),edge)
for z in [-.77,.77]:
 box('Inset conduit',(0,.5,z),(.65,1,.06),black)
 for x in [-.23,.23]:box('Ruby conduit',(x,.5,z*1.03),(.045,1,.025),red)
box('Panel seam',(0,.03,-.81),(1.35,.035,.025),edge)
export('watcher_shaft')
# Crown: split angular fork, protected lens cradle and engraved light rails.
for sign in [-1,1]:
 poly=[(sign*x,y) for x,y in [(1.05,-2.3),(2.5,-.6),(2.7,2.8),(2.18,2.1),(1.98,.1),(.78,-1.7)]]
 prism('Swept split crown',poly,1.12,armor)
 line('Fork outer machined spine',(sign*2.53,-.55,-.58),(sign*2.7,2.7,-.58),.075,edge)
 line('Fork ruby inset',(sign*1.28,-1.67,-.58),(sign*2.14,-.2,-.58),.038,red)
 line('Fork upper channel',(sign*2.14,-.2,-.58),(sign*2.35,1.83,-.58),.028,red)
 for y in [-1.1,-.8,-.5]:box('Cooling louver',(sign*1.78,y,.57),(.4,.10,.12),edge)
box('Neck saddle',(0,-2.15,0),(1.75,.52,1.55),edge)
prism('Lower chevron',[(-1.0,-1.85),(0,-2.4),(1,-1.85),(0,-2.04)],.13,red)
export('watcher_crown')
# Floating eye: thick faceted almond frame, layered lens, vertical slit.
outer=[(-1.98,0),(-1.05,.89),(0,1.04),(1.05,.89),(1.98,0),(1.05,-.89),(0,-1.04),(-1.05,-.89)]
for i,a in enumerate(outer):
 b=outer[(i+1)%len(outer)];line('Armoured eye bezel',(a[0],a[1],0),(b[0],b[1],0),.16,edge)
 line('Hot inner eyelid',(a[0]*.91,a[1]*.91,-.19),(b[0]*.91,b[1]*.91,-.19),.037,red)
for r,dep,offset,m in [(1.03,.35,0,black),(.85,.27,-.22,orange),(.64,.29,-.35,red)]:
 bpy.ops.mesh.primitive_uv_sphere_add(segments=32,ring_count=16,location=xyz((0,0,offset)));o=bpy.context.object;o.scale=(r,dep,r*.88);o.data.materials.append(m);o.name='Layered reactor lens'
 for f in o.data.polygons:f.use_smooth=True
prism('Vertical pupil',[(-.10,-.73),(-.23,0),(-.1,.73),(.1,.73),(.23,0),(.1,-.73)],.12,black).location.y=.74
for side in [-1,1]:line('Pupil hot lip',(side*.12,-.64,-.82),(side*.12,.64,-.82),.018,white)
for i in range(20):
 a=i*math.tau/20;r=.76
 line('Iris radial engraving',(math.cos(a)*r,math.sin(a)*r*.88,-.62),(math.cos(a)*(r+.11),math.sin(a)*(r+.11)*.88,-.62),.013,white)
export('watcher_eye')
