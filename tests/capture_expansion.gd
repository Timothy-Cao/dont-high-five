extends Node
var lab: Node3D
func save(title: String) -> void:
	await get_tree().create_timer(0.5).timeout
	await RenderingServer.frame_post_draw
	var img:=get_viewport().get_texture().get_image()
	img.save_png("res://.local/captures/expansion/"+title+".png")
	print("CAPTURE ",title," ",img.get_size())
func run(world: Node3D) -> void:
	lab=world
	get_window().size=Vector2i(3840,2160)
	DirAccess.make_dir_recursive_absolute("res://.local/captures/expansion")
	var p=lab.player
	lab.started=true;lab.set_paused(false);p.testing_input=true;p.set_physics_process(false)
	for view in [
		["01-west-hall",Vector3(-103,12,-24),Vector3(-133,10,18)],
		["02-west-portal",Vector3(-131,0.05,2),Vector3(-140,2.2,0)],
		["03-directional-pad",Vector3(111,3,-39),Vector3(115,1,-30)],
		["04-high-concourse",Vector3(-66,8.05,-97),Vector3(24,15,-104)]
	]:
		p.reset_to(view[1]);p.camera.position.y=1.58;p.camera.look_at(view[2])
		await save(view[0])
	p.reset_to(Vector3(-114,0.05,8));p.camera.rotation=Vector3(-0.12,0,0);p.toggle_view()
	await save("05-third-person")
	p.launch_from_pad(Vector3(-10,20,-20));p.position=Vector3(-118,10,3)
	await save("06-third-person-ball")
	p.reset_to(Vector3(-114,0.05,8));p.avatar.pose(p,1)
	p.set_process(false);p.avatar.show()
	p.follow_camera.global_position=p.position+Vector3(-1.8,1.35,-3.2)
	p.follow_camera.look_at(p.position+Vector3.UP*0.95)
	for h in p.hands: h.glove.hide();h.cord.hide()
	await save("07-courier-front-asset-inspection")
	lab.set_paused(true);lab.hud.show_page("Audio")
	await save("08-audio-menu")
	lab.hud.show_page("Settings")
	await save("09-settings-menu")
	get_tree().quit()
