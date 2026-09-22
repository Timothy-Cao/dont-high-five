extends Node
func save(name:String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.local/captures/"+name+".png")
	print("REFINEMENT CAPTURE ",name)
func delay(seconds:float) -> void:await get_tree().create_timer(seconds).timeout
func run(lab:Node3D) -> void:
	get_window().size=Vector2i(1440,900);lab.started=true;lab.set_paused(false)
	var p=lab.player;var b=lab.builder;p.testing_input=true;p.set_physics_process(false)
	p.reset_to(Vector3(100,20.05,32));p.rotation.y=.5;p.camera.rotation.x=-.08
	p.damage_feedback.record(12,p.camera.global_position+p.camera.global_basis.x*24-p.camera.global_basis.z*15,"watcher")
	await delay(.3);await save("refinement-hit-direction")
	b.enter();b.load_map("res://assets/maps/workshop-example.json");b.set_physics_process(false)
	b.camera.position=b.ORIGIN+Vector3(12,10,21);b.camera.look_at(b.ORIGIN+Vector3(0,4,0));b.pick_part(0);b.preview.hide()
	await delay(.3);await save("refinement-workshop")
	b.dirty=true;b.save_recovery();lab.set_paused(true);lab.hud.show_page("Build")
	await delay(.3);await save("refinement-recovery-menu")
	get_tree().quit()
