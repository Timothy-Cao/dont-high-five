extends MeshInstance3D

var tube := ImmediateMesh.new()
var rubber := StandardMaterial3D.new()

func _ready() -> void:
	mesh = tube
	rubber.roughness = 0.66
	material_override = rubber
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func shape_arm(start: Vector3,end: Vector3,slack: float,strain: float,color: Color,bend := Vector3.ZERO,width := 0.034,contacts:Array = []) -> void:
	global_transform = Transform3D.IDENTITY
	rubber.albedo_color = color
	tube.clear_surfaces()
	var path:Array[Vector3]=[start]
	for contact in contacts:path.append(contact)
	path.append(end)
	var delta := end-start
	if delta.length()<0.02: return
	var radius := width/sqrt(1+strain*0.9)
	var sag := minf(0.85,slack*0.33)
	var rings: Array[PackedVector3Array] = []
	var ring_normals:Array[PackedVector3Array]=[]
	var steps:=24 if contacts.is_empty() else 1
	for segment in range(path.size()-1):
		var segment_tangent:Vector3=(path[segment+1]-path[segment]).normalized()
		var segment_side:Vector3=segment_tangent.cross(Vector3.UP).normalized()
		if segment_side.length()<0.01:segment_side=Vector3.RIGHT
		var segment_outward:=segment_side.cross(segment_tangent).normalized()
		for i in range(steps+1):
			var t:=float(i)/steps
			var p:=path[segment].lerp(path[segment+1],t)
			if contacts.is_empty():p+=Vector3.DOWN*(sin(PI*t)*sag)+bend*sin(PI*t)
			var vertices:=PackedVector3Array()
			var normals:=PackedVector3Array()
			for j in 10:
				var a:=TAU*j/10.0
				var n:=segment_side*cos(a)+segment_outward*sin(a)
				normals.append(n);vertices.append(p+n*radius)
			rings.append(vertices);ring_normals.append(normals)
	tube.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in range(rings.size()-1):
		if i%(steps+1)==steps:continue
		for j in 10:
			var k := (j+1)%10
			for pair in [Vector2i(i,j),Vector2i(i+1,j),Vector2i(i+1,k),Vector2i(i,j),Vector2i(i+1,k),Vector2i(i,k)]:
				tube.surface_set_normal(ring_normals[pair.x][pair.y])
				tube.surface_add_vertex(rings[pair.x][pair.y])
	tube.surface_end()
