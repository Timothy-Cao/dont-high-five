"""Original reusable laser-tag architecture. Metres, Y-up export, bottom-centre pivots."""
import bpy, math, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/arena_kit';OUT.mkdir(exist_ok=True)
bpy.context.preferences.filepaths.save_version=0
def xyz(p):return(p[0],-p[2],p[1])
def material(name,c,roughness,metal=0,emission=0):
    m=bpy.data.materials.new(name);m.diffuse_color=(*c,1);m.use_nodes=True
    n=m.node_tree.nodes.get('Principled BSDF')
    for k,v in [('Base Color',(*c,1)),('Roughness',roughness),('Metallic',metal),('Emission Color',(*c,1)),('Emission Strength',emission)]:n.inputs[k].default_value=v
    return m
navy=material('Midnight powder coat',(.055,.083,.105),.65,.15)
rubber=material('Impact rubber',(.022,.032,.039),.92)
teal=material('Sea glass enamel',(.075,.26,.27),.4,.1)
ivory=material('Safety cream',(.55,.49,.34),.65)
glow=material('Inset turquoise light',(.13,.65,.62),.35,0,2)
amber=material('Amber marker',(.8,.34,.07),.5,0,1.2)
catalog=[]
def box(name,p,size,mat,bevel=.06,rotation=0):
    bpy.ops.mesh.primitive_cube_add(size=1,location=xyz(p));o=bpy.context.object;o.name=name
    o.dimensions=(size[0],size[2],size[1]);bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
    mod=o.modifiers.new('Moulded edges','BEVEL');mod.width=min(bevel,min(size)*.24);mod.segments=3;bpy.ops.object.modifier_apply(modifier=mod.name)
    mod=o.modifiers.new('Weighted normals','WEIGHTED_NORMAL');bpy.ops.object.modifier_apply(modifier=mod.name)
    o.rotation_euler.x=rotation;o.data.materials.append(mat);return o
def begin():bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
def finish(key,title,bounds,boxes,extra=None):
    bpy.ops.object.select_all(action='SELECT');bpy.context.view_layer.objects.active=bpy.context.selected_objects[0];bpy.ops.object.join()
    obj=bpy.context.object;obj.name=key;bpy.context.scene.cursor.location=(0,0,0);bpy.ops.object.origin_set(type='ORIGIN_CURSOR')
    bpy.ops.export_scene.gltf(filepath=str(OUT/(key+'.glb')),export_format='GLB',use_selection=True,export_yup=True)
    bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art'/('kit_'+key+'.blend')))
    row={'id':key,'name':title,'bounds':bounds,'boxes':boxes}
    if extra:row.update(extra)
    catalog.append(row)
def slab(key,title,w,d,h=.5):
    begin();box('Padded deck',(0,h/2,0),(w,h,d),navy)
    box('Rubber running surface',(0,h-.02,0),(w-.18,.08,d-.18),rubber,.02)
    for side in [-1,1]:box('Recessed lane edge',(side*(w/2-.10),h+.012,0),(.045,.024,d-.24),amber,.008)
    finish(key,title,[w,h,d],[[[0,h/2,0],[w,h,d]]])
slab('floor','Deck 4 x 4',4,4)
begin();box('Wall core',(0,2,0),(4,4,.5),navy)
for side in [-1,1]:
    box('Impact panel',(0,1.7,side*.26),(3.6,2.8,.09),teal)
    box('Rubber kick rail',(0,.3,side*.3),(3.8,.35,.16),rubber)
    box('Upper light slot',(0,3.75,side*.27),(3.45,.045,.035),glow,.01)
    for x in [-1.75,1.75]:box('Corner bumper',(x,2,side*.3),(.20,3.4,.16),rubber)
finish('wall','Padded wall', [4,4,.8],[[[0,2,0],[4,4,.8]]])
begin();box('Spool column',(0,4,0),(1.4,8,1.4),navy,.2)
for y in [.25,3.9,7.75]:
    box('Collar',(0,y,0),(1.55,.3,1.55),teal,.10)
    box('Status stripe',(0,y+.12,0),(1.57,.035,1.57),glow,.01)
finish('pillar','Swing column',[1.6,8,1.6],[[[0,4,0],[1.6,8,1.6]]])
begin()
# Ramp low at +Z, high at -Z; side walls stay below its running surface.
points=[(-2,0,-4),(2,0,-4),(-2,0,4),(2,0,4),(-2,4,-4),(2,4,-4)]
mesh=bpy.data.meshes.new('Ramp wedge');mesh.from_pydata([xyz(v) for v in points],[],[(0,1,3,2),(0,4,5,1),(0,2,4),(1,5,3),(2,3,5,4)]);mesh.update()
o=bpy.data.objects.new('Smooth ramp',mesh);bpy.context.collection.objects.link(o);o.data.materials.append(teal)
for side in [-1,1]:box('Ramp lane',(side*1.87,2.015,0),(.065,.04,math.sqrt(80)),amber,.008,math.atan(.5))
finish('ramp','Gentle ramp 4 m rise',[4,4,8],[],{'convex':points})
begin()
walls=[([ -3,3,0],[2,6,.8]),([3,3,0],[2,6,.8]),([0,5.3,0],[4,1.4,.8])]
for p,size in walls:box('Window frame',p,size,navy,.12)
for x in [-2.05,2.05]:box('Window rubber lip',(x,2.3,-.43),(.13,4.6,.09),teal)
box('Overhead aperture light',(0,4.65,-.44),(3.9,.06,.06),glow,.01)
finish('window','Vault window',[8,6,1],walls)
slab('perch','Perch 4 x 2',4,2)
begin();box('Suspended baffle',(0,2,0),(.6,4,6),navy,.10)
box('Baffle lower bumper',(0,.15,0),(.7,.3,6),rubber)
box('Baffle light',(0,.035,0),(.72,.04,5.6),glow,.008)
finish('fin','Ceiling fin',[.8,4,6],[[[0,2,0],[.8,4,6]]])
slab('canopy','Canopy 8 x 8',8,8,.5)
begin();box('Launch cassette',(0,.16,0),(4,.32,4),navy)
box('Launch mat',(0,.32,0),(3.6,.05,3.6),teal)
for z in [-1,0,1]:
    for side in [-1,1]:
        o=box('Launch chevron',(side*.5,.355,z),(.1,.025,1.35),amber,.008);o.rotation_euler.z=side*.65
finish('pad','Launch pad',[4,.4,4],[[[0,.16,0],[4,.32,4]]],{'launch':24})
(OUT/'catalog.json').write_text(json.dumps(catalog,indent=2))
print('KIT:',len(catalog),'reusable modules')
