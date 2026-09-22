extends Node
func save(name:String) -> void:
	await get_tree().create_timer(.25).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.local/captures/"+name+".png")
	print("REVEAL CAPTURE ",name)
func run(lab:Node3D) -> void:
	get_window().size=Vector2i(2560,1440);lab.started=true;lab.set_paused(false)
	var p=lab.player;var w=lab.session.watcher;p.testing_input=true;p.set_physics_process(false)
	var partner=lab.session.objectives.partners[0];partner.set_physics_process(false);partner.position=Vector3(0,140,0);partner.rotation.y=0
	lab.box(Vector3(0,139.5,0),Vector3(30,1,30),lab.INK)
	lab.box(Vector3(0,142,4),Vector3(7,4,.4),lab.MINT)
	w.enter();w.camera.position=Vector3(0,142,10);w.camera.look_at(Vector3(0,141,0));lab.hud.hide()
	await save("reveal-cover-before")
	w.reveal_players();await save("reveal-cover-active")
	w.cut_power();await save("reveal-blackout")
	w.reveal_left=0;await save("reveal-blackout-expired")
	w.cut_power();w.leave();p.reset_to(Vector3(0,20.05,8));p.camera.look_at(Vector3(-28,16,-35));p.camera.current=true
	w.demo_patrol=true;await get_tree().create_timer(1.0).timeout
	await save("reveal-patrol-demo")
	get_tree().quit()
