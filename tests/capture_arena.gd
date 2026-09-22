extends Node
var lab:Node3D
func run(world:Node3D) -> void:
	lab=world
	lab.started=true
	if "--4k" in OS.get_cmdline_user_args(): get_window().size=Vector2i(3840,2160)
	lab.started=true
	lab.set_paused(false)
	lab.player.testing_input=true
	lab.player.set_physics_process(false)
	DirAccess.make_dir_recursive_absolute("res://.local/captures/arena")
	var views:=[
		["01-arrival",Vector3(-14,0.05,23),Vector3(0,12,-12)],
		["02-upper-atrium",Vector3(-10,23.05,-8.3),Vector3(3,12,17)],
		["03-amber-shaft",Vector3(-48,0.05,19),Vector3(-48,17,-4)],
		["04-violet-galleries",Vector3(62,4.05,-17),Vector3(45,11,18)],
		["05-low-tunnels",Vector3(0,0.05,32),Vector3(0,2,62)],
		["06-maze",Vector3(-65,0.05,-65),Vector3(-42,2,-50)],
		["07-upper-maze",Vector3(32.75,8.55,32.75),Vector3(32.75,10,43)],
		["08-north-galleries",Vector3(-17,16.05,-68),Vector3(14,16,-30)]
	]
	var performance_report:={}
	if "--balance-capture" in OS.get_cmdline_user_args():
		views=[
			["09-atrium-refuge",Vector3(-11,10.05,-12),Vector3(-16,11.7,-22)],
			["10-inside-refuge",Vector3(-14,10.05,-23),Vector3(-18,11.4,-18)],
			["11-amber-refuge",Vector3(-54,14.05,19),Vector3(-64.5,13.5,14)],
			["12-violet-refuge",Vector3(56,14.25,16),Vector3(64,11.5,18)],
			["13-hopping-passage",Vector3(-7,0.05,71.4),Vector3(7,1.4,71.4)]
		]
	for view in views:
		lab.player.reset_to(view[1])
		lab.player.camera.position.y=1.58
		lab.player.camera.look_at(view[2])
		await get_tree().create_timer(0.3).timeout
		if "--benchmark" in OS.get_cmdline_user_args():
			var intervals:Array[float]=[]
			var previous:=Time.get_ticks_usec()
			for frame in 60:
				await get_tree().process_frame
				var now:=Time.get_ticks_usec()
				intervals.append((now-previous)/1000.0)
				previous=now
			intervals.sort()
			performance_report[view[0]]={"median_ms":intervals[30],"p95_ms":intervals[57],"samples":60}
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://.local/captures/arena/"+view[0]+".png")
	print("ARENA CAPTURES: ",views.size(),"; collision boxes=",lab.arena.shapes,"; draw batches=",lab.arena.batches.size())
	if not performance_report.is_empty():
		var file:=FileAccess.open("res://.local/reports/arena-render-metrics.json",FileAccess.WRITE)
		file.store_string(JSON.stringify({"resolution":str(get_window().size),"views":performance_report,"scenario":"60 frame stationary samples across "+str(views.size())+" arena viewpoints; other desktop apps may be running"},"  "))
		print("ARENA RENDER METRICS ",JSON.stringify(performance_report))
	if "--balance-capture" in OS.get_cmdline_user_args():
		lab.goto_station(0)
		lab.player.set_physics_process(true)
		await get_tree().create_timer(0.15).timeout
		lab.player.camera.look_at(Vector3(-14,7.8,11))
		var did_punch:bool=lab.player.combat.begin()
		for tick in 180:
			await get_tree().physics_frame
			if lab.player.hand_recovery>0: break
		print("RECOVERY CAPTURE started=",did_punch," recovery=",lab.player.hand_recovery)
		lab.player.camera.rotation.x=0
		for shot in [["14-gloves-returning",0.12],["15-gloves-winding",0.65],["16-gloves-readying",1.05]]:
			await get_tree().create_timer(shot[1]).timeout
			await RenderingServer.frame_post_draw
			get_viewport().get_texture().get_image().save_png("res://.local/captures/arena/"+shot[0]+".png")
		lab.set_paused(true)
		lab.hud.show_page("Controls")
		await get_tree().process_frame
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png("res://.local/captures/arena/17-controls-balance.png")
	get_tree().quit()
