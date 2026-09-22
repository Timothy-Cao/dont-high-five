extends Node3D
## A group edit is one validated transaction; cancellation never mutates layout data.
var builder:Node3D
var indices:Array[int]=[]
var pending:=false
var duplicating:=false
var valid:=false
var offset:=Vector3.ZERO
var visuals:Node3D
var material:StandardMaterial3D
func _ready() -> void:
	visuals=Node3D.new();add_child(visuals)
	material=StandardMaterial3D.new();material.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	material.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;material.albedo_color=Color(.25,.95,.8,.14)
func clear() -> void:
	indices.clear();pending=false;valid=false;offset=Vector3.ZERO
	visuals.position=Vector3.ZERO
	for child in visuals.get_children():child.queue_free()
func toggle(index:int) -> void:
	if index<0 or index>=builder.entries.size() or pending:return
	if index in indices:indices.erase(index)
	else:indices.append(index)
	refresh()
func refresh() -> void:
	for child in visuals.get_children():visuals.remove_child(child);child.queue_free()
	for index in indices:
		var entry:Dictionary=builder.entries[index];var spec:Dictionary=builder.specs[entry.part]
		var box:=MeshInstance3D.new();var mesh:=BoxMesh.new();mesh.size=builder.Kit.vector(spec.bounds)+Vector3.ONE*.06
		box.mesh=mesh;box.material_override=material;box.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		visuals.add_child(box);box.position=builder.ORIGIN+builder.Kit.vector(entry.pos)+Vector3.UP*mesh.size.y/2;box.rotation.y=entry.yaw*PI/2
	material.albedo_color=Color(.25,.95,.8,.14)
	builder.status="%d selected · X move · Ctrl+D duplicate · Delete remove · Esc clear"%indices.size()
func excluded() -> Array[RID]:
	var result:Array[RID]=[]
	for node in builder.pieces.get_children():
		if node.get_meta("entry") in indices and node is CollisionObject3D:result.append(node.get_rid())
	return result
func begin(copy:bool) -> bool:
	if indices.is_empty():return false
	if copy and builder.entries.size()+indices.size()>builder.LIMIT:builder.status="Part limit reached";return false
	pending=true;duplicating=copy;valid=false;offset=Vector3.ZERO
	builder.status="Point at destination · LMB confirm · Esc cancel";return true
func can_transform(delta:Vector3) -> bool:
	var exclude:Array[RID]=[]
	if not duplicating:exclude=excluded()
	for index in indices:
		var entry:Dictionary=builder.entries[index]
		if not builder.can_place(builder.Kit.vector(entry.pos)+delta,entry.part,entry.yaw,exclude):return false
	return true
func update() -> void:
	if not pending:return
	builder.preview.hide()
	var hit:Dictionary=builder.ray(excluded());valid=false
	if not hit.is_empty():
		var entry:Dictionary=builder.entries[indices[0]];var bounds:Vector3=builder.Kit.vector(builder.specs[entry.part].bounds)
		var extents:Vector3=(Basis(Vector3.UP,entry.yaw*PI/2)*bounds).abs()/2
		var at:Vector3=hit.position-builder.ORIGIN+hit.normal*hit.normal.abs().dot(extents)-Vector3.UP*bounds.y/2
		at.y+=builder.elevation
		offset=(at-builder.Kit.vector(entry.pos)).snapped(Vector3.ONE*builder.grid);valid=can_transform(offset)
	visuals.position=offset;material.albedo_color=Color(.25,.95,.8,.28) if valid else Color(1,.15,.2,.3)
func commit() -> bool:
	if not pending or not can_transform(offset):builder.status="Group blocked · choose a clear destination";return false
	builder.snapshot()
	for index in indices:
		var entry:Dictionary=builder.entries[index].duplicate(true);var at:Vector3=builder.Kit.vector(entry.pos)+offset
		entry.pos=[at.x,at.y,at.z]
		if duplicating:builder.entries.append(entry)
		else:builder.entries[index]=entry
	var copied:=duplicating
	clear();visuals.position=Vector3.ZERO;builder.rebuild();builder.status="Group duplicated" if copied else "Group moved"
	return true
func remove() -> void:
	if indices.is_empty():return
	builder.snapshot();indices.sort();indices.reverse()
	for index in indices:builder.entries.remove_at(index)
	clear();builder.rebuild();builder.status="Group removed · Ctrl+Z to restore"
func cancel() -> void:
	pending=false;offset=Vector3.ZERO;visuals.position=Vector3.ZERO;refresh()
