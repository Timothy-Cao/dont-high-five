extends Node
## Scripted in-engine screenshots. Posed avatars are set dressing, not online players.
var lab: Node3D
var models: Array[Node3D]=[]
func save(title: String) -> void:
	await get_tree().create_timer(0.6).timeout
	await RenderingServer.frame_post_draw
	var img:=get_viewport().get_texture().get_image()
	img.save_png("res://docs/screenshots/"+title+".png")
	print("SHOWCASE ",title," ",img.get_size())
func view(title: String,pos: Vector3,target: Vector3) -> void:
	lab.player.reset_to(pos);lab.player.camera.position.y=1.58;lab.player.camera.look_at(target)
	await save(title)
func courier(pos: Vector3,yaw: float,tint: Color) -> void:
	var model=load("res://assets/courier.glb").instantiate();lab.add_child(model)
	model.position=pos;model.rotation.y=yaw;models.append(model)
	for mesh in model.find_children("*","MeshInstance3D",true,false):
		for surface in mesh.mesh.get_surface_count():
			var material=mesh.get_active_material(surface)
			if material is StandardMaterial3D and "Sea glass" in material.resource_name:
				var copy=material.duplicate();copy.albedo_color=tint;mesh.set_surface_override_material(surface,copy)
	# Give posed couriers the same visible rubber gloves as the real controller.
	for side in [-1,1]:
		var glove=load("res://assets/glove_left.glb" if side<0 else "res://assets/glove_right.glb").instantiate()
		model.add_child(glove);glove.position=Vector3(side*0.42,0.92,-0.20);glove.scale=Vector3.ONE*0.75
		glove.rotation.x=-0.25
func run(world: Node3D) -> void:
	lab=world;get_window().size=Vector2i(3840,2160)
	DirAccess.make_dir_recursive_absolute("res://docs/screenshots")
	var p=lab.player;lab.started=true;lab.set_paused(false);p.testing_input=true;p.set_physics_process(false)
	lab.hud.welcome_time=0;lab.arena.powerups.testing=true
	for station in lab.arena.powerups.stations: station.timer=0
	lab.arena.powerups.tick(0.01)
	courier(Vector3(-2,20,-1),PI+0.28,Color("449e99"))
	courier(Vector3(2.6,20,-2),PI-0.35,Color("ae629d"))
	await view("01-high-five-club",Vector3(0,20.05,5),Vector3(0,21.15,-1.4))
	for model in models: model.hide()
	await view("02-vertical-playground",Vector3(-11,23.05,-9),Vector3(8,12,17))
	await view("03-portal-run",Vector3(-132,0.05,5),Vector3(-140,2.4,0))
	await view("04-red-room",Vector3(111,20.05,-69),Vector3(112,23,-84))
	await view("05-upper-concourse",Vector3(-112,20.05,98),Vector3(40,24,98))
	lab.set_paused(true);lab.hud.show_page("Home");await save("06-menu")
	lab.hud.show_page("Settings");await save("07-settings")
	lab.hud.show_page("Bindings");await save("08-key-bindings")
	get_tree().quit()
