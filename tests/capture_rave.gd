extends Node
var lab:Node3D
func save(name:String,pos:Vector3,target:Vector3,charge:=false) -> void:
	var p=lab.player
	p.reset_to(pos);p.camera.position.y=1.58;p.camera.look_at(target)
	if charge:p.combat.start_charge();p.combat.charge_time=1.1
	await get_tree().create_timer(0.6).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.local/captures/"+name+".png")
	print("RAVE CAPTURE ",name)
func run(world:Node3D) -> void:
	lab=world;get_window().size=Vector2i(2560,1440)
	DirAccess.make_dir_recursive_absolute("res://.local/captures")
	lab.started=true;lab.set_paused(false);lab.player.testing_input=true;lab.player.set_physics_process(false)
	lab.hud.welcome_time=0;lab.arena.powerups.testing=true
	await save("rave-upper",Vector3(0,20.05,19),Vector3(0,28,-3))
	await save("rave-floor",Vector3(10,0.05,16),Vector3(0,27,0))
	await save("soft-gloves",Vector3(0,20.05,5),Vector3(0,21.4,-12))
	await save("soft-fists",Vector3(0,20.05,5),Vector3(0,21.4,-12),true)
	get_tree().quit()
