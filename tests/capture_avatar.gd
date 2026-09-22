extends Node
## Authored render harness: no desktop capture or input automation.
var world: Node3D
var model: Node3D
var camera: Camera3D
var gloves:Array[Node3D]=[]
var cords:Array[Node3D]=[]
func save(name: String) -> void:
	await get_tree().create_timer(0.2).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.local/captures/"+name+".png")
	print("AVATAR CAPTURE ",name)
func view(name: String,yaw: float,clip: String,phase: float) -> void:
	model.rotation.y=yaw
	model.animator.play(model.clips[clip]);model.animator.seek(phase,true)
	model.skeleton.force_update_all_bone_transforms()
	for i in 2:
		var wrist:=model.to_global(Vector3(-0.45 if i==0 else 0.45,1.03,-0.23))
		gloves[i].global_position=wrist;gloves[i].global_basis=model.global_basis;gloves[i].scale=Vector3.ONE*0.7
		cords[i].shape_arm(model.shoulder_position(i),wrist-gloves[i].global_basis.y*0.17,0.1,0,Color("c88240") if i==0 else Color("488f83"))
	await save(name)
func run(lab: Node3D) -> void:
	world=lab;get_window().size=Vector2i(1920,1920)
	DirAccess.make_dir_recursive_absolute("res://.local/captures")
	lab.started=true;lab.set_paused(false);lab.player.set_physics_process(false);lab.player.set_process(false);lab.hud.hide()
	lab.set_process(false);lab.arena.hide()
	for h in lab.player.hands:h.glove.hide();h.fist.hide();h.cord.hide();h.lamp.hide()
	lab.environment.background_mode=Environment.BG_COLOR;lab.environment.background_color=Color("111e2b")
	lab.environment.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR;lab.environment.ambient_light_color=Color("9eb5bf");lab.environment.ambient_light_energy=0.65
	lab.environment.fog_enabled=false
	model=load("res://scripts/avatar.gd").new();lab.add_child(model);model.position=Vector3(0,80,0)
	for i in 2:
		var glove=load("res://assets/glove_left.glb" if i==0 else "res://assets/glove_right.glb").instantiate();lab.add_child(glove);gloves.append(glove)
		var cord=load("res://scripts/elastic_arm.gd").new();lab.add_child(cord);cords.append(cord)
	var floor=MeshInstance3D.new();var plane=PlaneMesh.new();plane.size=Vector2(200,200);floor.mesh=plane
	floor.material_override=lab.mat(Color("192937"));floor.position=Vector3(0,79.997,0);lab.add_child(floor)
	var key:=DirectionalLight3D.new();lab.add_child(key);key.rotation_degrees=Vector3(-35,-145,0);key.light_energy=1.3;key.shadow_enabled=true
	camera=Camera3D.new();lab.add_child(camera);camera.projection=Camera3D.PROJECTION_ORTHOGONAL;camera.size=2.55
	camera.position=Vector3(2.6,81.7,-4.5);camera.look_at(Vector3(0,80.88,0));camera.current=true
	await view("spool-front",0,"Idle",0.5)
	await view("spool-back",PI,"Idle",0.5)
	await view("spool-walk",0,"Walk",0.2)
	await view("spool-charge",0,"Charge",1.0)
	await view("spool-air",0,"Air",0.5)
	# Sample the complete authored stride for contact/loop inspection.
	DirAccess.make_dir_recursive_absolute("res://.local/captures/stride")
	for frame in 24:
		await view("stride/spool-%02d"%frame,0,"Walk",frame/30.0)
	# Record the real F5 presentation in the actual dark arena, with its normal fog.
	model.hide();floor.hide();key.hide()
	for i in 2:gloves[i].hide();cords[i].hide()
	lab.arena.show();lab.set_process(true);lab.environment.fog_enabled=true
	lab.environment.ambient_light_energy=lab.visibility_fill
	lab.player.set_process(true);lab.player.set_physics_process(true);lab.player.testing_input=true
	lab.hud.show();get_window().size=Vector2i(1920,1080)
	lab.player.reset_to(Vector3(0,20.05,5));lab.player.rotation.y=PI;lab.player.camera.rotation.x=-0.08
	for i in 12: await get_tree().physics_frame
	lab.player.toggle_view();await save("spool-third-person")
	lab.player.toggle_view();lab.player.combat.start_charge();lab.player.combat.charge_time=1.1
	await save("spool-charge-first-person")
	get_tree().quit()
