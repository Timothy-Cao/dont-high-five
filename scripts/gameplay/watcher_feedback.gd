extends Node3D
## Bounded world effects. Scope uses persistent meshes, never one allocation per frame.
const P=preload("res://scripts/gameplay/props.gd")
var watcher:Node3D
var laser:MeshInstance3D
var core:MeshInstance3D
var dot:MeshInstance3D
var muzzle_light:OmniLight3D
var flash_left:=0.0
var endpoint:=Vector3.ZERO
var bursts:Array[Node3D]=[]
var impact_lights:Array[Dictionary]=[]
func _ready() -> void:
	laser=P.beam(self,Vector3.ZERO,Vector3.UP,Color("fa3149"),0.065)
	core=P.beam(self,Vector3.ZERO,Vector3.UP,Color("ffb19f"),0.018)
	dot=P.orb(self,Vector3.ZERO,0.16,Color("ff604d"),2.0)
	for node in [laser,core,dot]:
		node.material_override.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
		node.material_override.disable_fog=true
		node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	laser.material_override=beam_material(Color(1.0,0.10,0.17,0.24))
	core.material_override=beam_material(Color(1.0,0.32,0.20,0.85))
	muzzle_light=OmniLight3D.new();muzzle_light.light_color=Color("ffa776");muzzle_light.omni_range=9;muzzle_light.shadow_enabled=false;add_child(muzzle_light)
	for i in 10:
		var lamp:=OmniLight3D.new();lamp.shadow_enabled=false;lamp.light_energy=0;add_child(lamp)
		impact_lights.append({"node":lamp,"life":0.0,"energy":0.0})
	hide_scope()
func pulse_light(at:Vector3,sniper:bool) -> void:
	var chosen:Dictionary=impact_lights[0]
	for item in impact_lights:
		if item.life<chosen.life:chosen=item
	chosen.node.global_position=at;chosen.node.omni_range=8 if sniper else 5
	chosen.node.light_color=Color("ff3545") if sniper else Color("ffad55")
	chosen.energy=3.5 if sniper else 2.0;chosen.life=0.16;chosen.node.light_energy=chosen.energy
func beam_material(color:Color) -> ShaderMaterial:
	var material:=ShaderMaterial.new();material.shader=load("res://shaders/watcher_beam.gdshader");material.set_shader_parameter("tint",color);return material
func hide_scope() -> void:
	for node in [laser,core,dot]:
		if is_instance_valid(node):node.hide()
func place_beam(node:MeshInstance3D,a:Vector3,b:Vector3) -> void:
	var up:Vector3=(b-a).normalized()
	if up.length_squared()<0.5:node.hide();return
	var right:=up.cross(Vector3.FORWARD).normalized()
	if right.length()<0.5:right=Vector3.RIGHT
	node.mesh.height=maxf(a.distance_to(b),0.01)
	node.global_position=(a+b)*0.5;node.global_basis=Basis(right,up,right.cross(up)).orthonormalized();node.show()
func update_scope() -> void:
	if not watcher.active or not watcher.scope or watcher.lab.paused or watcher.towers[watcher.selected].blind>0:
		hide_scope();return
	var hit:Dictionary=watcher.aim();endpoint=hit.position
	var cam:Camera3D=watcher.camera
	var from:Vector3=cam.global_position-cam.global_basis.z*1.8+cam.global_basis.x*0.55-cam.global_basis.y*0.3
	# Offset gives the operator a visible beam; clip again so it cannot leak through nearby cover.
	var clip:=get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(from,endpoint,19,[watcher.lab.player.get_rid()]))
	if not clip.is_empty():endpoint=clip.position
	place_beam(laser,from,endpoint);place_beam(core,from,endpoint)
	dot.visible=hit.has("collider") or not clip.is_empty();dot.global_position=endpoint
func shot(from:Vector3,to:Vector3,sniper:bool,hit:Dictionary) -> void:
	var tracer=P.beam(watcher,from,to,Color("ffe0ad") if sniper else Color("ffad63"),0.09 if sniper else 0.045)
	tracer.material_override=beam_material(Color(1.0,0.015,0.07,0.95) if sniper else Color(1.0,0.35,0.07,0.85))
	watcher.add_effect(tracer,0.19 if sniper else 0.055)
	var flash=P.orb(watcher,from,0.45 if sniper else 0.22,Color("ffcf89"),3)
	flash.layers=8 # World flash stays visible to Fivers without filling the scoped operator view.
	flash.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	watcher.add_effect(flash,0.075)
	muzzle_light.global_position=from;flash_left=0.09;muzzle_light.light_energy=3 if sniper else 1.4
	if not hit.is_empty():
		var at:Vector3=hit.position+hit.normal*0.12
		pulse_light(at,sniper)
		for i in (6 if sniper else 3):
			var tangent:Vector3=Vector3(sin(i*2.4),cos(i*1.7),sin(i*1.3))
			var tip:Vector3=at+(hit.normal*0.5+tangent*0.25)*(1.3 if sniper else 0.5)
			watcher.add_effect(P.beam(watcher,at,tip,Color("ffc88a"),0.018),0.13)
func explosion(pos:Vector3,radius:float) -> void:
	bursts=bursts.filter(func(node):return is_instance_valid(node))
	if bursts.size()>=8:bursts.pop_front().queue_free()
	var burst=load("res://scripts/gameplay/neon_burst.gd").new();burst.lab=watcher.lab;burst.radius=radius;add_child(burst);burst.global_position=pos;bursts.append(burst)
func grenade_visual(pos:Vector3) -> Node3D:
	var root:=Node3D.new();root.set_meta("blackout_exempt",true);watcher.add_child(root);root.position=pos
	var core=P.orb(root,Vector3.ZERO,0.22,Color("ffbd60"),7)
	for i in 3:
		var shape:=BoxMesh.new();shape.size=Vector3(0.60,0.085,0.34)
		var fin=P.mesh(root,shape,Vector3.ZERO,Color("ff234b"),4);fin.rotation=Vector3(i*PI/3,i*PI/3,0)
	return root
func strike_visual(pos:Vector3,_normal:Vector3) -> Node3D:
	var root:=Node3D.new();root.set_meta("blackout_exempt",true);watcher.add_child(root);root.position=pos
	var circle:=MeshInstance3D.new();var plane:=PlaneMesh.new()
	plane.size=Vector2.ONE*preload("res://scripts/gameplay/orbital_strike.gd").RADIUS*2
	circle.mesh=plane;circle.position.y=.035;circle.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF;root.add_child(circle)
	var mat:=ShaderMaterial.new();mat.shader=load("res://shaders/orbital_warning.gdshader");circle.material_override=mat
	root.set_meta("warning_material",mat)
	return root
func strike_column(pos:Vector3) -> void:
	var end:=pos+Vector3.UP*30
	var hit:=get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(pos+Vector3.UP*0.2,end,1))
	if not hit.is_empty():end=hit.position
	var column=P.beam(watcher,pos,end,Color("ff1544"),0.24);column.material_override=beam_material(Color(1,0.01,0.04,1));watcher.add_effect(column,0.28)
	var core=P.beam(watcher,pos,end,Color("fff1ce"),0.06);core.material_override=beam_material(Color(1,0.65,0.42,1));watcher.add_effect(core,0.17)
func _process(dt:float) -> void:
	if watcher.lab.paused:
		muzzle_light.light_energy=0;hide_scope();return
	for item in impact_lights:
		item.life=maxf(0,item.life-dt);item.node.light_energy=item.energy*item.life/0.16
	flash_left=maxf(0,flash_left-dt)
	if flash_left<=0:muzzle_light.light_energy=0
	update_scope()
