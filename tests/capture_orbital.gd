extends Node
func save(name:String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.local/captures/"+name+".png")
	print("ORBITAL CAPTURE ",name)
func delay(seconds:float) -> void:await get_tree().create_timer(seconds).timeout
func run(lab:Node3D) -> void:
	get_window().size=Vector2i(2560,1440);lab.started=true;lab.set_paused(false);lab.hud.hide()
	var p=lab.player;var w=lab.session.watcher;p.testing_input=true;p.set_physics_process(false)
	w.enter();w.camera.position=Vector3(-10,5,36);w.camera.look_at(Vector3(-18,1.4,26));await delay(0.2)
	w.cut_power();await delay(0.2);await save("orbital-night-dark-beat")
	await delay(0.36);await save("orbital-night-boot")
	await delay(0.55);await save("orbital-night-ready")
	w.cut_power()
	var observer:=Camera3D.new();lab.add_child(observer);observer.position=Vector3(99,12,33);observer.far=400;observer.look_at(Vector3(124,12,0));observer.current=true
	var center:=Vector3(124,0.2,0)
	var warning=w.feedback.strike_visual(center,Vector3.UP);await delay(0.2);await save("orbital-warning");warning.queue_free()
	w.begin_orbital(center);await delay(0.45);await save("orbital-burning")
	w.cut_power();await delay(0.5);await save("orbital-blackout")
	await delay(4.1);await save("orbital-after")
	w.cut_power();w.leave();observer.current=true
	lab.set_fog_distance(250);await delay(0.2);await save("fog-clear")
	lab.set_fog_distance(100);await delay(0.2);await save("fog-default")
	lab.hud.show();lab.set_paused(true);lab.hud.show_page("Settings");await delay(0.2);await save("fog-settings")
	get_tree().quit()
