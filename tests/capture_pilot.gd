extends Node
## Self-terminating authored render review; no desktop inspection or input control.
var lab:Node3D
func save(name:String) -> void:
	await get_tree().create_timer(0.3).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.local/captures/"+name+".png")
	print("PILOT CAPTURE ",name)
func run(world:Node3D) -> void:
	lab=world;get_window().size=Vector2i(2560,1440)
	DirAccess.make_dir_recursive_absolute("res://.local/captures")
	lab.started=true;lab.set_paused(false)
	var p=lab.player;p.testing_input=true;p.set_physics_process(false)
	p.reset_to(Vector3(-16.5,0.05,29));p.camera.position.y=1.58;p.camera.look_at(Vector3(-18,1.15,26))
	await save("pilot-fiver")
	lab.session.watcher.enter();lab.session.watcher.select(0)
	await save("pilot-watcher")
	lab.session.watcher.cut_power();await save("pilot-blackout")
	lab.session.watcher.set_dark(false);lab.session.watcher.blackout=0
	lab.session.watcher.leave();lab.session.training.choose(0);p.set_physics_process(false)
	await save("pilot-training")
	lab.session.training.choose(8);p.set_physics_process(false)
	await save("pilot-ceiling-room")
	lab.set_paused(true);await save("pilot-menu")
	lab.hud.show_page("Playtest");await save("pilot-playtest-menu")
	get_tree().quit()
