extends Node3D
## A universal equipment field, not an alignment detector. Walking remains free.
const CENTER := Vector3(112,20,-82)
const BOUNDS := AABB(Vector3(101,20,-91),Vector3(22,12,18))
var arena: Node3D

func contains(point: Vector3) -> bool:
	return BOUNDS.has_point(point)

func build(a: Node3D) -> void:
	arena=a
	var red:=Color("f45d79")
	var doors:Array[Rect2]=[Rect2(-3,0,6,5)]
	for x in [-11,11]: a.wall(CENTER+Vector3(x,6,0),Vector3(0.6,12,18.6),red)
	for z in [-9,9]:
		a.window_wall(CENTER+Vector3(0,0,z),22,12,doors,red)
		var field:=MeshInstance3D.new();var plane:=QuadMesh.new();plane.size=Vector2(6,5)
		field.mesh=plane;field.position=CENTER+Vector3(0,2.5,z)
		var mat:=ShaderMaterial.new();mat.shader=load("res://shaders/suppression.gdshader")
		field.material_override=mat;field.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;add_child(field)
		# Layer 8 blocks glove/punch rays, but not the walking character (layer 1).
		var body:=StaticBody3D.new();body.collision_layer=8;body.collision_mask=0
		body.set_meta("grippy",false);body.position=field.position;add_child(body)
		var collision:=CollisionShape3D.new();var shape:=BoxShape3D.new();shape.size=Vector3(6,5,0.12)
		collision.shape=shape;body.add_child(collision)
		for x in [-3.1,3.1]: a.stripe(CENTER+Vector3(x,2.5,z),Vector3(0.12,5,0.12),red)
	a.block(CENTER+Vector3(0,12,0),Vector3(22.6,0.5,18.6),a.WALL)
	for z in [-7,7]: a.stripe(CENTER+Vector3(0,0.04,z),Vector3(19,0.04,0.12),red)
	a.light_pool(CENTER+Vector3(0,8,0),red,15)
	# Sparse padded cover, with a straight, walkable path between two exits.
	for x in [-7,7]: a.wall(CENTER+Vector3(x,1.3,0),Vector3(3,2.6,6),red)
