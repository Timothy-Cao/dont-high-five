extends RefCounted
static func material(color:Color,glow:=0.0) -> StandardMaterial3D:
	var m:=StandardMaterial3D.new();m.albedo_color=color;m.roughness=0.62
	if glow>0: m.emission_enabled=true;m.emission=color;m.emission_energy_multiplier=glow
	return m
static func mesh(parent:Node3D,shape:Mesh,pos:Vector3,color:Color,glow:=0.0) -> MeshInstance3D:
	var m:=MeshInstance3D.new();m.mesh=shape;m.material_override=material(color,glow);parent.add_child(m);m.position=pos;return m
static func box(parent:Node3D,pos:Vector3,size:Vector3,color:Color,solid:=true) -> Node3D:
	var node:Node3D=StaticBody3D.new() if solid else Node3D.new();parent.add_child(node);node.position=pos;node.set_meta("grippy",true)
	var shape:=BoxMesh.new();shape.size=size;mesh(node,shape,Vector3.ZERO,color)
	if solid:
		var c:=CollisionShape3D.new();var b:=BoxShape3D.new();b.size=size;c.shape=b;node.add_child(c)
	return node
static func ring(parent:Node3D,pos:Vector3,radius:float,color:Color,vertical:=false) -> MeshInstance3D:
	var t:=TorusMesh.new();t.inner_radius=radius-0.07;t.outer_radius=radius+0.07;t.rings=48;t.ring_segments=8
	var m:=mesh(parent,t,pos,color,1.4)
	if vertical: m.rotation.x=PI/2
	m.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;return m
static func orb(parent:Node3D,pos:Vector3,radius:float,color:Color,glow:=0.0) -> MeshInstance3D:
	var shape:=SphereMesh.new();shape.radius=radius;shape.height=radius*2;shape.radial_segments=24;shape.rings=12
	return mesh(parent,shape,pos,color,glow)
static func beam(parent:Node3D,a:Vector3,b:Vector3,color:Color,width:=0.04) -> MeshInstance3D:
	var shape:=CylinderMesh.new();shape.top_radius=width;shape.bottom_radius=width;shape.height=maxf(0.01,a.distance_to(b));shape.radial_segments=8
	var m:=mesh(parent,shape,(a+b)/2,color,1.5)
	var up:Vector3=(b-a).normalized();var right:=up.cross(Vector3.FORWARD).normalized()
	if right.length()<0.5:right=Vector3.RIGHT
	m.basis=Basis(right,up,right.cross(up)).orthonormalized();m.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;return m

static func soften_visor(root:Node3D) -> void:
	# Hand lamps must not turn the dark face screen into a white specular rectangle.
	for node in root.find_children("*","MeshInstance3D",true,false):
		for surface in node.mesh.get_surface_count():
			var source:Material=node.get_active_material(surface)
			if source is StandardMaterial3D and "Smoky visor" in source.resource_name:
				var mat:StandardMaterial3D=source.duplicate();mat.roughness=0.82;mat.metallic=0;mat.metallic_specular=0.08
				node.set_surface_override_material(surface,mat)

static func glowing_glove(root:Node3D,energy:=0.7) -> void:
	root.set_meta("blackout_exempt",true)
	for node in root.find_children("*","MeshInstance3D",true,false):
		for surface in node.mesh.get_surface_count():
			var source:Material=node.get_active_material(surface)
			if source is StandardMaterial3D:
				var mat:StandardMaterial3D=source.duplicate()
				mat.emission_enabled=true;mat.emission=mat.albedo_color;mat.emission_energy_multiplier=maxf(mat.emission_energy_multiplier if source.emission_enabled else 0,energy)
				node.set_surface_override_material(surface,mat)
