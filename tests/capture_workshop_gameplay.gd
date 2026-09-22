extends Node
func capture(label:String) -> void:
	await get_tree().create_timer(.3).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.local/captures/"+label+".png")
func run(lab:Node3D) -> void:
	get_window().size=Vector2i(1440,900);lab.started=true;lab.set_paused(false);lab.message_time=0
	var b=lab.builder;var p=lab.player;p.testing_input=true;p.set_physics_process(false)
	b.enter();b.load_map("res://assets/maps/workshop-example.json")
	for row in [["tower",[-15,0,-15]],["spawn",[0,0,15]],["cargo",[-7,0,10]],["socket",[10,0,-12]],["ring",[0,7,-12]],["portal_a",[-20,0,6]],["portal_b",[20,0,-14]],["light",[0,12,0]]]:
		for i in b.specs.size():
			if b.specs[i].id==row[0]:b.entries.append({"part":i,"pos":row[1],"yaw":0})
	b.rebuild();await get_tree().physics_frame
	b.camera.position=b.ORIGIN+Vector3(23,14,30);b.camera.look_at(b.ORIGIN+Vector3(0,5,-6));b.set_physics_process(false);b.preview.hide()
	await capture("workshop-functional-build")
	b.toggle_test();p.position=b.ORIGIN+Vector3(16,7,22);p.camera.look_at(b.ORIGIN+Vector3(-1,4,-8));lab.session.watcher.set_pressure("Patrol")
	await capture("workshop-functional-play")
	lab.set_paused(true);lab.hud.show_page("Playtest");await capture("workshop-pressure-menu")
	b.toggle_test();b.select_palette(1);lab.hud.show_page("Build")
	await capture("workshop-gameplay-palette")
	get_tree().quit()
