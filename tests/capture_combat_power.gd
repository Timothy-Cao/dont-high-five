extends Node
var lab:Node3D
func save(title: String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.local/captures/combat-power/"+title+".png")
	print("CAPTURE ",title)
func view(title: String,pos:Vector3,target:Vector3) -> void:
	lab.player.reset_to(pos);lab.player.camera.position.y=1.58;lab.player.camera.look_at(target)
	await get_tree().create_timer(0.35).timeout
	await save(title)
func run(world:Node3D) -> void:
	lab=world;get_window().size=Vector2i(3840,2160)
	DirAccess.make_dir_recursive_absolute("res://.local/captures/combat-power")
	lab.started=true;lab.set_paused(false)
	var p=lab.player;p.testing_input=true;p.set_physics_process(false)
	lab.arena.powerups.testing=true
	for station in lab.arena.powerups.stations: station.timer=0
	lab.arena.powerups.tick(0.01)
	await view("01-upper-floor-haze",Vector3(-120,20.05,98),Vector3(130,23,98))
	await view("02-long-ramp",Vector3(-139,0.05,85),Vector3(-20,20,85))
	await view("03-central-overdrive",Vector3(0,20.05,5.5),Vector3(0,21.65,0))
	await view("04-corner-station",Vector3(-132,0.05,-97),Vector3(-136,1.5,-101))
	await view("05-dummy",Vector3(-4,0.05,23),Vector3(-4,1.8,17))
	p.combat.begin();p.combat.tick(0.038)
	await get_tree().create_timer(0.08).timeout
	await save("06-parallel-fists")
	p.cancel_hands();p.hand_recovery=0
	await view("07-lower-atrium",Vector3(-14,0.05,23),Vector3(0,18,0))
	await view("08-vision-baseline",Vector3(-120,20.05,98),Vector3(130,23,98))
	p.grant_buff("vision",18)
	await get_tree().create_timer(0.35).timeout
	await save("09-vision-boost")
	lab.set_paused(true);lab.hud.show_page("Controls")
	await get_tree().create_timer(0.15).timeout
	await save("10-controls")
	get_tree().quit()
