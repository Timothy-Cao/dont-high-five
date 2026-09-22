extends Node
func save(name:String) -> void:
	await get_tree().create_timer(.4).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.local/captures/"+name+".png")
	print("MINIMAP CAPTURE ",name)
func run(lab:Node3D) -> void:
	get_window().size=Vector2i(2560,1440);lab.started=true;lab.set_paused(false)
	var p=lab.player;var map=lab.hud.minimap;p.testing_input=true;p.set_physics_process(false)
	lab.session.objectives.set_moving_fivers(true)
	p.reset_to(Vector3(-16.5,.05,29));p.camera.rotation.x=-.10
	await save("minimap-ground")
	print("ARENA MINIMAP BUILD ",map.last_build_usec," us / ",map.shapes.size()," shapes")
	p.reset_to(Vector3(48,20.05,45));p.rotation.y=PI*.65;map.invalidate()
	await save("minimap-upper")
	lab.session.watcher.enter();await save("minimap-watcher");lab.session.watcher.leave()
	lab.session.watcher.cut_power();await save("minimap-blackout");lab.session.watcher.cut_power()
	lab.builder.enter();lab.builder.load_map("res://assets/maps/workshop-example.json");lab.builder.toggle_test()
	await save("minimap-workshop")
	get_tree().quit()
