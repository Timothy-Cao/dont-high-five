extends Node
## Preserve originals, then extinguish both lit and unshaded decorative materials.
var lab:Node3D
var active:=false
var materials:Dictionary={}
var lamps:Dictionary={}
var labels:Dictionary={}
var carpet:Dictionary={}
var background:=Color.BLACK
var fog_energy:=0.0
var scan_clock:=0.0
func exempt(node:Node) -> bool:
	var at:Node=node
	while at and at!=lab:
		if at.get_meta("blackout_exempt",false):return true
		at=at.get_parent()
	return false
func remember_material(mat:Material) -> void:
	if mat is StandardMaterial3D and not materials.has(mat.get_instance_id()):
		materials[mat.get_instance_id()]={"mat":mat,"emission":mat.emission_enabled,"energy":mat.emission_energy_multiplier,"mode":mat.shading_mode}
	elif mat is ShaderMaterial and mat.shader.resource_path=="res://shaders/carpet.gdshader" and not carpet.has(mat.get_instance_id()):
		carpet[mat.get_instance_id()]={"mat":mat,"power":mat.get_shader_parameter("power")}
func scan() -> void:
	for node in lab.find_children("*","Node",true,false):
		if exempt(node):continue
		if node is Light3D and not lamps.has(node.get_instance_id()):lamps[node.get_instance_id()]={"node":node,"energy":node.light_energy}
		if node is Label3D and not labels.has(node.get_instance_id()):labels[node.get_instance_id()]={"node":node,"visible":node.visible}
		if node is GeometryInstance3D:
			remember_material(node.material_override)
			if node is MeshInstance3D and node.mesh:
				for surface in node.mesh.get_surface_count():remember_material(node.get_active_material(surface))
func enforce() -> void:
	lab.environment.ambient_light_energy=0
	lab.environment.background_color=Color.BLACK;lab.environment.fog_light_energy=0
	for item in materials.values():
		item.mat.emission_enabled=false;item.mat.emission_energy_multiplier=0;item.mat.shading_mode=BaseMaterial3D.SHADING_MODE_PER_PIXEL
	for item in carpet.values():item.mat.set_shader_parameter("power",0.0)
	for item in lamps.values():
		if is_instance_valid(item.node):item.node.light_energy=0
	for item in labels.values():
		if is_instance_valid(item.node):item.node.hide()
	if lab.arena and lab.arena.rave:
		for node in lab.arena.rave.beams+lab.arena.rave.spots:node.hide()
func set_active(value:bool) -> void:
	if active==value:return
	active=value
	if active:
		background=lab.environment.background_color;fog_energy=lab.environment.fog_light_energy
		scan();enforce()
	else:
		lab.environment.background_color=background;lab.environment.fog_light_energy=fog_energy;lab.environment.ambient_light_energy=lab.visibility_fill
		for item in materials.values():item.mat.emission_enabled=item.emission;item.mat.emission_energy_multiplier=item.energy;item.mat.shading_mode=item.mode
		for item in carpet.values():item.mat.set_shader_parameter("power",item.power)
		for item in lamps.values():
			if is_instance_valid(item.node):item.node.light_energy=item.energy
		for item in labels.values():
			if is_instance_valid(item.node):item.node.visible=item.visible
		materials.clear();lamps.clear();labels.clear();carpet.clear()
		if lab.arena and lab.arena.rave:
			for node in lab.arena.rave.beams:node.show()
			lab.arena.rave.update_installation()
func _process(dt:float) -> void:
	if not active:return
	scan_clock-=dt
	if scan_clock<=0:scan();scan_clock=0.2
	enforce()
