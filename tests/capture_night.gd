extends Node
func save(name:String) -> void:
	await get_tree().create_timer(0.25).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.local/captures/"+name+".png")
	print("NIGHT CAPTURE ",name)
func run(lab:Node3D) -> void:
	get_window().size=Vector2i(2560,1440);lab.started=true;lab.set_paused(false)
	var p=lab.player;var w=lab.session.watcher;p.testing_input=true;p.set_physics_process(false)
	w.enter();w.camera.position=Vector3(-10,5,36);w.camera.look_at(Vector3(-18,1.4,26))
	lab.hud.hide();await save("night-watcher-normal")
	w.cut_power();await get_tree().create_timer(1.0).timeout;await save("night-watcher-vision")
	w.explode(Vector3(-18,1.1,26),7,0)
	await get_tree().create_timer(0.065).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.local/captures/night-watcher-flash.png")
	await get_tree().create_timer(1.4).timeout
	w.leave();p.reset_to(Vector3(-10,3.42,36));p.camera.position.y=1.58;p.camera.look_at(Vector3(-18,1.4,26));p.camera.current=true
	await save("night-fiver-gloves")
	w.feedback.pulse_light(Vector3(-18,1.1,26),true);w.explode(Vector3(-18,1.1,26),7,0)
	await get_tree().create_timer(0.065).timeout;await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.local/captures/night-fiver-flash.png")
	await get_tree().create_timer(1.4).timeout
	var warning=w.feedback.strike_visual(Vector3(-18,0.2,26),Vector3.UP)
	await save("night-strike-line");warning.queue_free()
	get_tree().quit()
