"""Original padded toy gloves. Godot +X is the left glove's inward/thumb side.
Both meshes use positive transforms; closed silhouette is sized from the open palm.
"""
import bpy,math,json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
bpy.context.preferences.filepaths.save_version=0
def mat(name,c,rough=.65,glow=0):
 m=bpy.data.materials.new(name);m.diffuse_color=(*c,1);m.use_nodes=True;p=m.node_tree.nodes.get('Principled BSDF')
 p.inputs['Base Color'].default_value=(*c,1);p.inputs['Roughness'].default_value=rough;p.inputs['Emission Color'].default_value=(*c,1);p.inputs['Emission Strength'].default_value=glow
 return m
oat=mat('Oat soft cuff',(.68,.65,.52));ink=mat('Deep teal rubber',(.025,.06,.075),.85)
amber=mat('Apricot toy glove',(.72,.35,.12));teal=mat('Sea glass toy glove',(.085,.43,.39))
lamp=mat('Soft mint indicator',(.35,.80,.68),.55,.65)
def xyz(p):return(p[0],-p[2],p[1])
def shape(name,p,size,m,roundness=.02,egg=False):
 if egg:
  bpy.ops.mesh.primitive_uv_sphere_add(segments=24,ring_count=16,location=xyz(p));o=bpy.context.object;o.scale=(size[0],size[2],size[1])
 else:
  bpy.ops.mesh.primitive_cube_add(size=1,location=xyz(p));o=bpy.context.object;o.dimensions=(size[0],size[2],size[1])
 bpy.ops.object.transform_apply(location=False,rotation=False,scale=True)
 if not egg:
  mod=o.modifiers.new('Soft molded radius','BEVEL');mod.width=roundness;mod.segments=5;bpy.ops.object.modifier_apply(modifier=mod.name)
 for f in o.data.polygons:f.use_smooth=True
 if not egg:
  mod=o.modifiers.new('Weighted normals','WEIGHTED_NORMAL');bpy.ops.object.modifier_apply(modifier=mod.name)
 o.name=name;o.data.materials.append(m);return o
def box(*a,**k):return shape(*a,**k)
def egg(*a,**k):return shape(*a,**k,egg=True)
report={}
for name,sign,paint in [('left',1,amber),('right',-1,teal)]:
 for closed in [False,True]:
  bpy.ops.object.select_all(action='SELECT');bpy.ops.object.delete(use_global=False)
  if not closed:
   box('Padded palm',(0,0,0),(.218,.224,.112),paint,.048)
   for i,(x,length) in enumerate([(-.081,.115),(-.027,.160),(.028,.178),(.081,.150)]):
    egg('Soft finger '+str(i),(sign*x,.091+length*.45,-.009),(.031,length*.60,.049),paint)
   thumb=egg('Inward thumb',(sign*.132,.015,-.009),(.044,.078,.05),paint)
   thumb.rotation_euler.y=sign*-.32
   egg('Palm cushion',(0,-.006,-.053),(.070,.074,.009),paint)
   box('Cuff',(0,-.147,0),(.177,.082,.108),oat,.025)
   box('Socket',(0,-.192,0),(.111,.032,.073),ink,.012)
   badge_y=-.006;badge_z=.061
  else:
   # Approx. half the previous fist width, with a compact curled-finger silhouette.
   box('Closed palm',(0,-.014,0),(.223,.184,.169),paint,.052)
   for i,x in enumerate([-.078,-.026,.026,.078]):
    egg('Soft knuckle '+str(i),(x,.055,-.052),(.031,.050,.049),paint)
   egg('Tucked inward thumb',(sign*.105,-.028,-.049),(.040,.065,.052),paint)
   box('Cuff',(0,-.131,.014),(.177,.068,.105),oat,.023)
   box('Socket',(0,-.173,.014),(.111,.03,.073),ink,.011)
   badge_y=-.017;badge_z=.089
  # One molded double-bar spool badge replaces stitches, screws and bony plates.
  box('Spool badge',(0,badge_y,badge_z),(.092,.082,.014),oat,.026)
  for x in [-.017,.017]:box('Badge spool',(x,badge_y,badge_z+.010),(.014,.038,.008),paint,.006)
  box('Wrist light',(0,-.145 if not closed else -.13,.058),(.085,.012,.009),lamp,.004)
  bpy.ops.object.select_all(action='SELECT')
  # Keep named parts for orientation and silhouette tests; shared materials batch in engine.
  filename=('fist_' if closed else 'glove_')+name
  bpy.ops.export_scene.gltf(filepath=str(ROOT/'assets'/f'{filename}.glb'),export_format='GLB',use_selection=True,export_yup=True,export_apply=True)
  bpy.ops.wm.save_as_mainfile(filepath=str(ROOT/'art'/f'{filename}.blend'))
  report[filename]={'thumb_x':sign*(.105 if closed else .132),'approx_width_m':.29,'positive_scale':True,'style':'Original soft molded toy; no finger joints or nail-like plates'}
(ROOT/'art/soft-gloves-report.json').write_text(json.dumps(report,indent=2));print(report)
