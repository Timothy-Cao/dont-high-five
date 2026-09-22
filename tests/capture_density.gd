extends Node
func run(lab:Node3D) -> void:
	get_window().size=Vector2i(2560,1440)
	DirAccess.make_dir_recursive_absolute("res://.local/captures/density")
	lab.started=true;lab.set_paused(false);lab.player.testing_input=true;lab.player.set_physics_process(false)
	lab.hud.welcome_time=0;lab.arena.powerups.testing=true
	var views=[
		["upper-maze",Vector3(-31,30,-30),Vector3(-54,24,-52)],
		["terraces",Vector3(-31,23,71),Vector3(-51,27,48)],
		["covered-loop",Vector3(96,0.05,42),Vector3(112,6,65)],
		["bridge-bay",Vector3(-96,26.1,48),Vector3(-120,30,20)],
		["blue-concourse",Vector3(-121,20.05,-103),Vector3(-68,25,-106)],
		["maze-inside",Vector3(34.75,20.05,34.75),Vector3(46,24,49)]
	]
	for view in views:
		lab.player.reset_to(view[1]);lab.player.camera.position.y=1.58;lab.player.camera.look_at(view[2])
		await get_tree().create_timer(0.5).timeout
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://.local/captures/density/"+view[0]+".png")
		print("DENSITY CAPTURE ",view[0])
	get_tree().quit()
