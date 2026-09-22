extends Node
## Authored offscreen render fixtures, not desktop capture or user input automation.
func save(name:String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.local/captures/"+name+".png")
	print("WATCHER CAPTURE ",name)
func run(lab:Node3D) -> void:
	get_window().size=Vector2i(2560,1440)
	DirAccess.make_dir_recursive_absolute("res://.local/captures")
	lab.started=true;lab.set_paused(false);lab.player.testing_input=true;lab.player.set_physics_process(false)
	var w=lab.session.watcher;w.enter();w.select(1)
	await get_tree().create_timer(0.4).timeout
	await save("watcher-gun-ready")
	w.scope=true;w.camera.look_at(Vector3(103,1,17))
	await get_tree().create_timer(0.5).timeout
	await save("watcher-scope")
	w.manual_fire()
	await save("watcher-sniper-shot")
	var observer:=Camera3D.new();lab.add_child(observer);observer.far=400;observer.position=Vector3(113,6,24);observer.look_at(Vector3(127,8,0));observer.current=true
	lab.hud.hide();await get_tree().create_timer(0.3).timeout
	await save("watcher-laser-world")
	get_tree().quit()
