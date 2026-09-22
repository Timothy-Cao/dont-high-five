extends Node
## Authored in-engine frames, no desktop capture or input automation.
var lab:Node3D
func save(name:String) -> void:
	await get_tree().create_timer(0.15).timeout
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.local/captures/"+name+".png")
	print("FIVER CAPTURE ",name)
func run(world:Node3D) -> void:
	lab=world;get_window().size=Vector2i(2560,1440)
	DirAccess.make_dir_recursive_absolute("res://.local/captures")
	lab.started=true;lab.set_paused(false);lab.hud.welcome_time=0
	var p=lab.player;p.testing_input=true;p.set_physics_process(false)
	p.reset_to(Vector3(0,20.05,5));p.camera.position.y=1.58;p.camera.look_at(Vector3(0,21.4,-12))
	p.combat.start_charge();p.combat.charge_time=1.1
	await save("fiver-charge")
	p.reset_to(Vector3(0,20.05,5));p.set_ball(true);p.third_person=true
	p.follow_camera.current=true;p.camera.current=false;p.combat.start_charge();p.combat.charge_time=1.1
	await get_tree().create_timer(0.2).timeout
	# Side angle to inspect actual shell sockets, not just the rear follow view.
	p.set_process(false);var review:=Camera3D.new();lab.add_child(review)
	review.position=p.position+Vector3(1.6,1.25,-2.1);review.look_at(p.position+Vector3(0,0.3,-0.1));review.fov=52;review.current=true
	p.avatar.show();await save("fiver-ball-charge")
	p.combat.cancel();p.reset_to(Vector3(0,20.05,5));p.set_ball(false)
	p.third_person=true;p._process(0.016);p.avatar.show()
	p.velocity=Vector3(30,0,0)
	p.movement_fx.set_process(false)
	for i in 6:
		p.position.x=-2.8+i*0.55;p.avatar.pose(p,0.05);p.movement_fx.emit_ghost()
	for i in 6: p.movement_fx.ghosts[i].mat.albedo_color.a=0.02+0.016*i
	review.position=Vector3(3,23,0);review.look_at(Vector3(-1,21,5));review.fov=58
	await save("fiver-afterimages")
	p.velocity=Vector3.ZERO;p.set_process(true);p.third_person=false;p.camera.current=true
	p.reset_to(Vector3(0,20.05,5));p.camera.position.y=1.58;p.camera.look_at(Vector3(0,20,-0.2))
	for i in 2: p.movement_fx.stamp(Vector3(-0.25 if i==0 else 0.25,20.01,2.5),Vector3.UP,p.hands[i].color,1)
	await save("fiver-imprints")
	get_tree().quit()
