extends MeshInstance3D

var tube := ImmediateMesh.new()
var rubber := StandardMaterial3D.new()

func _ready() -> void:
	mesh = tube
	rubber.roughness = 0.66
	material_override = rubber
	cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF

func shape_arm(start: Vector3,end: Vector3,slack: float,strain: float,color: Color,bend := Vector3.ZERO,width := 0.034) -> void:
	global_transform = Transform3D.IDENTITY
	rubber.albedo_color = color
	tube.clear_surfaces()
	var delta := end-start
	if delta.length()<0.02: return
	var radius := width/sqrt(1+strain*0.9)
	var tangent := delta.normalized()
	var side := tangent.cross(Vector3.UP).normalized()
	if side.length()<0.01: side=Vector3.RIGHT
	var outward := side.cross(tangent).normalized()
	var sag := minf(0.85,slack*0.33)
	var rings: Array[PackedVector3Array] = []
	var normals := PackedVector3Array()
	for j in 10:
		var a := TAU*j/10.0
		normals.append(side*cos(a)+outward*sin(a))
	for i in 25:
		var t := i/24.0
		var p := start.lerp(end,t)+Vector3.DOWN*(sin(PI*t)*sag)+bend*sin(PI*t)
		var vertices := PackedVector3Array()
		for n in normals: vertices.append(p+n*radius)
		rings.append(vertices)
	tube.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	for i in 24:
		for j in 10:
			var k := (j+1)%10
			for pair in [Vector2i(i,j),Vector2i(i+1,j),Vector2i(i+1,k),Vector2i(i,j),Vector2i(i+1,k),Vector2i(i,k)]:
				tube.surface_set_normal(normals[pair.y])
				tube.surface_add_vertex(rings[pair.x][pair.y])
	tube.surface_end()
