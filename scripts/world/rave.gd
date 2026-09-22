extends Node3D
## Shared mirrorball and distributed, ray-clipped laser fans; bounded visual budget.
var lab: Node3D
var time:=0.0
var mirror: Node3D
var beams:Array[MeshInstance3D]=[]
var emitters:Array[Vector3]=[]
var beam_ends:Array[Vector3]=[]
var spots:Array[MeshInstance3D]=[]
var tick_count:=0
const CENTER:=Vector3(0,30,0)
# position, forward vector, colour, maximum beam length; no gameplay collision.
const FANS=[
    [Vector3(-131,32,3),Vector3(0.8,-0.10,0.45),Color("3fcabd"),52.0],
    [Vector3(137,33,-28),Vector3(-0.65,-0.1,1),Color("c266c6"),52.0],
    [Vector3(-97,34,-111),Vector3(1,-0.12,0.15),Color("7395ef"),54.0],
    [Vector3(127,12,69),Vector3(-1,-0.18,-0.15),Color("62cda9"),44.0]
]

func material(color:Color,glow:float) -> StandardMaterial3D:
	var m:=StandardMaterial3D.new();m.albedo_color=color;m.roughness=0.35
	m.emission_enabled=true;m.emission=color;m.emission_energy_multiplier=glow
	return m

func mesh_node(mesh:Mesh,mat:Material,pos:Vector3,parent:Node3D=self) -> MeshInstance3D:
	var node:=MeshInstance3D.new();node.mesh=mesh;node.material_override=mat
	node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;parent.add_child(node);node.position=pos
	return node

func _ready() -> void:
	mirror=Node3D.new();add_child(mirror);mirror.position=CENTER
	var sphere:=SphereMesh.new();sphere.radius=2.3;sphere.height=4.6;sphere.radial_segments=48;sphere.rings=24
	mesh_node(sphere,material(Color("152537"),0.1),Vector3.ZERO,mirror)
	var tiles:=MultiMesh.new();tiles.transform_format=MultiMesh.TRANSFORM_3D;tiles.use_colors=true
	var tile:=BoxMesh.new();tile.size=Vector3(0.35,0.265,0.035);tiles.mesh=tile;tiles.instance_count=640
	var tile_mat:=material(Color.WHITE,0.065);tile_mat.vertex_color_use_as_albedo=true;tile_mat.metallic=0.62
	var cluster:=MultiMeshInstance3D.new();cluster.multimesh=tiles;cluster.material_override=tile_mat;mirror.add_child(cluster)
	cluster.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	for row in 20:
		var latitude:=lerpf(-1.35,1.35,row/19.0)
		for col in 32:
			var angle:=TAU*col/32.0
			var n:=Vector3(cos(latitude)*cos(angle),sin(latitude),cos(latitude)*sin(angle))
			var b:=Basis.looking_at(-n,Vector3.UP).scaled_local(Vector3(cos(latitude),1,1))
			tiles.set_instance_transform(row*32+col,Transform3D(b,n*2.325))
			tiles.set_instance_color(row*32+col,[Color("85d8d0"),Color("bc91d6"),Color("c8d8dc")][(row+col)%3])
	var ring:=TorusMesh.new();ring.inner_radius=2.65;ring.outer_radius=2.72;ring.rings=72
	mesh_node(ring,material(Color("64cfc6"),1.3),Vector3.ZERO,mirror)
	var suspension:=CylinderMesh.new();suspension.top_radius=0.06;suspension.bottom_radius=0.06;suspension.height=11.7
	mesh_node(suspension,material(Color("3d4a5c"),0),Vector3(0,38.1,0))
	var solid:=StaticBody3D.new();add_child(solid);solid.position=CENTER;solid.set_meta("grippy",true)
	var collision:=CollisionShape3D.new();var shape:=SphereShape3D.new();shape.radius=2.34;collision.shape=shape;solid.add_child(collision)
	var lamp:=OmniLight3D.new();add_child(lamp);lamp.position=CENTER+Vector3(0,-3,1)
	lamp.light_color=Color("b4e4eb");lamp.light_energy=0.85;lamp.omni_range=13;lamp.shadow_enabled=false
	for spec in FANS:
		var emitter:Vector3=spec[0]
		var housing:=BoxMesh.new();housing.size=Vector3(1.2,0.7,0.9)
		mesh_node(housing,material(Color("243145"),0),emitter)
		for fan in 5:
			var beam:=CylinderMesh.new();beam.top_radius=0.023;beam.bottom_radius=0.045;beam.height=1;beam.radial_segments=8
			var m:=material(spec[2],1.4);m.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
			beams.append(mesh_node(beam,m,emitter));emitters.append(emitter);beam_ends.append(emitter)
	# Floor/wall flecks are actual ray-clipped patches, not dozens of dynamic lights.
	for i in 28:
		var patch:=QuadMesh.new();patch.size=Vector2(0.45,0.45)
		var m:=material(Color("568c91") if i%2 else Color("846a96"),0.65);m.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
		m.cull_mode=BaseMaterial3D.CULL_DISABLED
		spots.append(mesh_node(patch,m,CENTER))
	update_installation()

func trace(a:Vector3,b:Vector3) -> Dictionary:
	var q:=PhysicsRayQueryParameters3D.create(a,b,1)
	return get_world_3d().direct_space_state.intersect_ray(q)

func update_installation() -> void:
	mirror.rotation.y=time*0.13
	for i in beams.size():
		var spec:Array=FANS[i/5]
		var spread:float=(i%5-2)*0.12
		var sweep:=sin(time*0.22+float(i/5))*0.24
		var direction:Vector3=spec[1].normalized().rotated(Vector3.UP,spread+sweep)
		direction.y+=0.06*sin(time*0.31+i*.15);direction=direction.normalized()
		var a:Vector3=emitters[i];var end:Vector3=a+direction*float(spec[3])
		var hit:=trace(a,end)
		if not hit.is_empty(): end=hit.position
		beam_ends[i]=end
		var delta:=end-a;var b:=Basis.looking_at(delta.normalized(),Vector3.UP)*Basis(Vector3.RIGHT,PI/2)
		beams[i].transform=Transform3D(b.scaled_local(Vector3(1,delta.length(),1)),(a+end)*0.5)
	for i in spots.size():
		var angle:=i*TAU/spots.size()+time*0.075
		var direction:=Vector3(cos(angle)*0.62,-0.8+0.12*sin(i*2.7),sin(angle)*0.62).normalized()
		var start:=CENTER+direction*2.5;var hit:=trace(start,start+direction*52)
		spots[i].visible=not hit.is_empty()
		if not hit.is_empty():
			var n:Vector3=hit.normal
			spots[i].global_transform=Transform3D(Basis.looking_at(-n,Vector3.FORWARD if absf(n.y)>0.9 else Vector3.UP),hit.position+n*0.025)

func _physics_process(dt:float) -> void:
	if lab.paused or (lab.session and lab.session.watcher.blackout>0): return
	time+=dt;tick_count+=1
	# Visual sweeps update at 30 Hz; no new nodes or shadow maps per frame.
	if tick_count%4==0: update_installation()
