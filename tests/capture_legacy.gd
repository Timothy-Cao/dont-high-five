extends Node
var lab:Node3D
func run(world:Node3D) -> void:
	lab=world
	lab.started=true
	if "--4k" in OS.get_cmdline_user_args(): get_window().size = Vector2i(3840,2160)
	await get_tree().process_frame
	await get_tree().process_frame
	lab.set_paused(false)
	if "--benchmark" in OS.get_cmdline_user_args():
		await get_tree().create_timer(1).timeout
		var intervals: Array[float]=[]
		var previous:=Time.get_ticks_usec()
		var end:=previous+3000000
		while Time.get_ticks_usec()<end:
			await get_tree().process_frame
			var now:=Time.get_ticks_usec()
			intervals.append((now-previous)/1000.0)
			previous=now
		intervals.sort()
		var total:=0.0
		for interval in intervals: total+=interval
		var report:={"resolution":str(get_window().size),"frames":intervals.size(),"mean_frame_ms":total/intervals.size(),"median_frame_ms":intervals[intervals.size()/2],"p95_frame_ms":intervals[int(intervals.size()*0.95)],"scenario":"standing in first-class bay, glove lights on, other desktop apps running"}
		print("RENDER BENCHMARK ",JSON.stringify(report))
		var file:=FileAccess.open("res://.local/reports/render-metrics.json",FileAccess.WRITE)
		file.store_string(JSON.stringify(report,"  "))
	await get_tree().create_timer(0.3).timeout
	DirAccess.make_dir_recursive_absolute("res://.local/captures")
	get_viewport().get_texture().get_image().save_png("res://.local/captures/01-sandbox.png")
	lab.player.camera.rotation.x=-0.55
	await get_tree().create_timer(0.2).timeout
	get_viewport().get_texture().get_image().save_png("res://.local/captures/08-shadow-check.png")
	lab.player.camera.rotation.x=0
	lab.player.attach_fixture(Vector3(-4,7,5),Vector3(4,7,5))
	lab.player.testing_input = true
	lab.player.input_override = Vector2(0,1)
	await get_tree().create_timer(5).timeout
	get_viewport().get_texture().get_image().save_png("res://.local/captures/02-drawn.png")
	lab.player.launch()
	lab.player.input_override = Vector2.ZERO
	await get_tree().create_timer(0.45).timeout
	get_viewport().get_texture().get_image().save_png("res://.local/captures/03-flight.png")
	lab.set_paused(true)
	await get_tree().process_frame
	await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png("res://.local/captures/04-tuning.png")
	lab.hud.show_page("Physics")
	await get_tree().process_frame
	await get_tree().process_frame
	get_viewport().get_texture().get_image().save_png("res://.local/captures/05-physics.png")
	for page_name in ["Controls","Bindings","Abilities","Settings"]:
		lab.hud.show_page(page_name)
		await get_tree().process_frame
		await get_tree().process_frame
		get_viewport().get_texture().get_image().save_png("res://.local/captures/"+page_name.to_lower()+".png")
	lab.set_paused(false)
	lab.goto_station(3)
	lab.player.camera.rotation.x=0.3
	await get_tree().create_timer(0.2).timeout
	get_viewport().get_texture().get_image().save_png("res://.local/captures/06-vertical-lab.png")
	lab.player.camera.look_at(Vector3(0,17,27))
	lab.player.fire_hand(0)
	await get_tree().create_timer(0.5).timeout
	lab.player.action_override={"reel":true}
	await get_tree().create_timer(0.8).timeout
	get_viewport().get_texture().get_image().save_png("res://.local/captures/07-grapple.png")
	lab.player.action_override={}
	lab.goto_station(3)
	await get_tree().create_timer(0.1).timeout
	lab.player.camera.look_at(Vector3(0,17,27))
	lab.player.combat.begin()
	await get_tree().create_timer(0.1).timeout
	get_viewport().get_texture().get_image().save_png("res://.local/captures/09-punch-extension.png")
	await get_tree().create_timer(0.3).timeout
	get_viewport().get_texture().get_image().save_png("res://.local/captures/10-punch-recovery.png")
	get_tree().quit()
