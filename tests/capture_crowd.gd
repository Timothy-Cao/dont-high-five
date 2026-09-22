extends Node
func save(name:String) -> void:
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png("res://.local/captures/"+name+".png")
	print("CROWD CAPTURE ",name)
func delay(seconds:float) -> void:await get_tree().create_timer(seconds).timeout
func run(lab:Node3D) -> void:
	get_window().size=Vector2i(2560,1440);lab.started=true;lab.set_paused(false);lab.hud.hide()
	var p=lab.player;var w=lab.session.watcher;p.testing_input=true;p.set_physics_process(false)
	p.position=Vector3(-10,0,40)
	var camera:=Camera3D.new();lab.add_child(camera);camera.position=Vector3(-14,2.8,31);camera.look_at(Vector3(-18,0.8,25));camera.current=true
	var actor=lab.session.objectives.partners[0];actor.set_physics_process(false);actor.position=Vector3(-18,0.05,25);actor.rotation.y=0
	await delay(0.2);await save("crowd-standing")
	actor.take_damage(100,Vector3(-18,0,30));await delay(0.7);await save("crowd-collapse")
	await delay(2.4)
	lab.session.objectives.set_moving_fivers(true)
	lab.hud.show();lab.set_paused(true);lab.hud.show_page("Playtest");await delay(0.1);await save("crowd-menu")
	get_tree().quit()
