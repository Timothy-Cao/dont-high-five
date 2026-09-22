extends RefCounted
## Shared catalogue for the in-game builder and authored arena dressing.
static func catalogue() -> Array:
	var entries:Array=JSON.parse_string(FileAccess.get_file_as_string("res://assets/arena_kit/catalog.json"))
	entries.append_array(preload("res://scripts/world/workshop_props.gd").catalogue());return entries
static func vector(values:Array) -> Vector3:return Vector3(values[0],values[1],values[2])
static func make(spec:Dictionary,collidable:=true) -> Node3D:
	if spec.get("gameplay",false):return preload("res://scripts/world/workshop_props.gd").make(spec,collidable)
	var root:Node3D=StaticBody3D.new() if collidable else Node3D.new()
	root.set_meta("grippy",true);root.set_meta("kit_id",spec.id)
	root.add_child(load("res://assets/arena_kit/"+str(spec.id)+".glb").instantiate())
	if collidable:
		for box in spec.boxes:
			var col:=CollisionShape3D.new();var shape:=BoxShape3D.new();shape.size=vector(box[1]);col.shape=shape;col.position=vector(box[0]);root.add_child(col)
		if spec.has("convex"):
			var col:=CollisionShape3D.new();var shape:=ConvexPolygonShape3D.new();var points:=PackedVector3Array()
			for point in spec.convex:points.append(vector(point))
			shape.points=points;col.shape=shape;root.add_child(col)
	return root
