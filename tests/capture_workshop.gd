extends Node
func save(name:String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.local/captures/"+name+".png")
	print("WORKSHOP CAPTURE ",name)
func delay(seconds:float) -> void:await get_tree().create_timer(seconds).timeout
func run(lab:Node3D) -> void:
	get_window().size=Vector2i(2560,1440);lab.started=true;lab.set_paused(false)
	var p=lab.player;var b=lab.builder;p.testing_input=true;b.enter()
	await delay(.3);await save("workshop-empty")
	b.load_map("res://assets/maps/workshop-example.json");b.set_physics_process(false);b.preview.hide()
	b.camera.position=b.ORIGIN+Vector3(18,12,24);b.camera.look_at(b.ORIGIN+Vector3(0,3,0))
	lab.hud.hide();await delay(.3);await save("workshop-kit")
	b.toggle_test();p.reset_to(b.ORIGIN+Vector3(0,.05,17));p.rotation.y=0;p.camera.rotation.x=-.10;p.toggle_view()
	await delay(.3);await save("wheel-in-workshop")
	b.leave();lab.set_paused(false);lab.hud.hide();p.set_physics_process(false);p.set_process(false)
	var camera:=Camera3D.new();lab.add_child(camera);camera.position=Vector3(130,22,34);camera.look_at(Vector3(151,22,0));camera.current=true
	await delay(.3);await save("arena-reel-hall")
	var w=lab.session.watcher;w.enter();w.cooldowns.mine=0;w.throw_mine();var mine=w.mines.back()
	mine.position=Vector3(132,.12,34);mine.velocity=Vector3.ZERO
	camera.position=Vector3(133,1.2,36);camera.look_at(mine.position);camera.current=true
	await delay(.85);mine.age=1.31;await delay(.03);await save("watcher-mine")
	get_tree().quit()
