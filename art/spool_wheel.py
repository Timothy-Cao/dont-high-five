"""Original moulded unicycle assembly for build_spool.py; Blender authoring helper."""
import bpy, math

def build_wheel(parts, box, xyz, rubber, metal, teal, orange, gold, light):
    def cylinder(name, p, radius, depth, material, bone):
        bpy.ops.mesh.primitive_cylinder_add(vertices=48, radius=radius, depth=depth,
            location=xyz(p), rotation=(0, math.pi/2, 0))
        o=bpy.context.object; o.name=name
        bevel=o.modifiers.new('Machined edge','BEVEL'); bevel.width=.016; bevel.segments=3
        bpy.ops.object.modifier_apply(modifier=bevel.name)
        for f in o.data.polygons: f.use_smooth=True
        mod=o.modifiers.new('Face normals','WEIGHTED_NORMAL'); bpy.ops.object.modifier_apply(modifier=mod.name)
        o.data.materials.append(material); parts.append((o,bone)); return o
    cylinder('Wide rounded tire',(0,.43,0),.415,.46,rubber,'wheel')
    for side in [-1,1]:
        cylinder('Tire sidewall',(side*.225,.43,0),.372,.045,rubber,'wheel')
        cylinder('Recessed rim',(side*.255,.43,0),.285,.027,metal,'wheel')
        cylinder('Hub enamel',(side*.275,.43,0),.22,.018,teal if side>0 else orange,'wheel')
        cylinder('Axle boss',(side*.297,.43,0),.095,.035,metal,'wheel')
        for i in range(8):
            a=i*math.tau/8
            o=box('Radial spoke',(side*.285,.43+math.cos(a)*.156,math.sin(a)*.156),(.014,.12,.036),rubber,'wheel',.008)
            o.rotation_euler.x=a
        for i in range(6):
            a=i*math.tau/6
            o=box('Inset hub tick',(side*.28,.43+math.cos(a)*.251,math.sin(a)*.251),(.018,.03,.043),gold if side<0 else light,'wheel',.007)
            o.rotation_euler.x=a
    for i in range(16):
        a=i*math.tau/16
        for side in [-1,1]:
            o=box('Tire chevron',(side*.116,.43+math.cos(a)*.419,math.sin(a)*.419),(.22,.026,.055),rubber,'wheel',.009)
            o.rotation_euler.x=a; o.rotation_euler.z=side*.22
    verts=[]; faces=[]
    for j in range(25):
        a=-.95+j*1.9/24
        for x,rad in [(-.29,.455),(.29,.455),(-.29,.482),(.29,.482)]:
            verts.append(xyz((x,.43+math.cos(a)*rad,math.sin(a)*rad)))
    for j in range(24):
        q=j*4; n=q+4
        faces.extend([(q,q+1,n+1,n),(q+2,n+2,n+3,q+3),(q,n,n+2,q+2),(q+1,q+3,n+3,n+1)])
    faces.extend([(0,2,3,1),(96,97,99,98)])
    mesh=bpy.data.meshes.new('Fender mould'); mesh.from_pydata(verts,[],faces); mesh.update()
    o=bpy.data.objects.new('Wheel fender',mesh); bpy.context.collection.objects.link(o)
    o.data.materials.append(teal); parts.append((o,'root'))
    for polygon in o.data.polygons: polygon.use_smooth=True
    for side,L in [(-1,'L'),(1,'R')]:
        box('Suspension fork',(side*.327,.65,.04),(.055,.42,.075),metal,'hips',.02)
        cylinder('Fixed axle cap',(side*.337,.43,0),.077,.043,teal if side>0 else orange,'root')
        box('Shock sleeve',(side*.22,.88,.13),(.08,.23,.085),rubber,'hips',.03)
