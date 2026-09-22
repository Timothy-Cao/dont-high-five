extends Node
func save(name:String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.local/captures/"+name+".png")
	print("SENTINEL CAPTURE ",name)
func settle() -> void:
	await get_tree().create_timer(0.3).timeout
func run(lab:Node3D) -> void:
	get_window().size=Vector2i(2560,1440);lab.started=true;lab.set_paused(false);lab.hud.hide()
	var p=lab.player;p.testing_input=true;p.set_physics_process(false)
	var w=lab.session.watcher;w.enter();w.select(1)
	var observer:=Camera3D.new();lab.add_child(observer);observer.far=400;observer.position=Vector3(118,6,15);observer.look_at(Vector3(132,7,0));observer.current=true
	await settle();await save("sentinel-tower")
	w.scope=true;w.camera.look_at(Vector3(103,1,17));await settle();await save("sentinel-laser")
	var target:=Vector3(126,1.4,6)
	observer.position=Vector3(113,7,22);observer.look_at(target+Vector3.UP*3)
	var warning=w.feedback.strike_visual(target,Vector3.UP);await settle();await save("sentinel-warning")
	warning.queue_free();w.explode(target,7,0);w.feedback.strike_column(target)
	await get_tree().create_timer(0.075).timeout;await save("sentinel-explosion-flash")
	await get_tree().create_timer(0.18).timeout;await save("sentinel-explosion-shards")
	await get_tree().create_timer(1.4).timeout
	w.cut_power();w.scope=false;w.feedback.hide_scope();w.explode(target,10,0);w.feedback.strike_column(target)
	await get_tree().create_timer(0.075).timeout;await save("sentinel-blackout-explosion")
	await get_tree().create_timer(1.4).timeout;w.cut_power()
	w.leave();p.reset_to(Vector3(-16.5,0.05,29));p.camera.position.y=1.58;p.camera.look_at(Vector3(-18,1.15,26));p.camera.current=true
	w.cut_power();await settle();await save("sentinel-blackout-hands")
	p.set_process(false)
	for hand in p.hands:hand.lamp.light_energy=0;hand.glove.hide();hand.fist.hide();hand.cord.hide()
	await settle();await save("sentinel-blackout-control")
	w.cut_power();await settle();await save("sentinel-power-restored")
	get_tree().quit()
