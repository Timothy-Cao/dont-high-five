extends Node
var checks:=0
var failures:=0
func check(ok: bool,message: String) -> void:
	checks+=1
	if not ok: failures+=1
	print(("PASS  " if ok else "FAIL  ")+message)
func frames(n: int) -> void:
	for i in n: await get_tree().physics_frame
func clear(p: Node3D,shape: Shape3D,pos: Vector3) -> bool:
	var q:=PhysicsShapeQueryParameters3D.new()
	q.shape=shape;q.transform.origin=pos;q.collision_mask=1
	return p.get_world_3d().direct_space_state.intersect_shape(q,1).is_empty()
func run(lab: Node3D) -> void:
	var p=lab.player
	var t=lab.arena.travel
	var audio=lab.audio_service
	p.testing_input=true;lab.started=true;lab.set_paused(false)
	await frames(5)
	p.set_physics_process(false)
	check(t.portals.size()==4 and t.launch_pads.size()==4,"two sparse portal pairs and four directional pads exist")
	for i in t.portals.size():
		var src:Dictionary=t.portals[i]
		var dest:Dictionary=t.portals[i+1 if i%2==0 else i-1]
		p.reset_to(src.base+src.xf.basis.z*0.4+Vector3.UP*0.06)
		var origin:Vector3=p.position
		p.velocity=-src.xf.basis.z*24+Vector3.UP*3
		p.air_jumps=0;p.hand_recovery=0.4
		p.position-=src.xf.basis.z*0.8
		var count:int=t.portal_count
		t.update_player(p,origin,1.0/120)
		check(t.portal_count==count+1 and p.position.distance_to(origin)>200,"swept crossing travels to distant partner "+str(i))
		check(p.velocity.distance_to(dest.xf.basis.z*24+Vector3.UP*3)<0.01,"portal preserves speed and rotates exit direction "+str(i))
		check(clear(p,p.collider.shape,p.position+p.collider.position),"portal exit is clear for a standing body "+str(i))
		check(p.air_jumps==0 and is_equal_approx(p.hand_recovery,0.4),"portal preserves spent air jump and hand recovery "+str(i))
	# Return crossings and obstructed destinations must not trap or teleport the player.
	p.reset_to(t.portals[0].base+Vector3.UP*0.05)
	var exit:Vector3=t.portals[1].base+t.portals[1].xf.basis.z*1.2
	var blocker=lab.box(exit+Vector3.UP,Vector3(3,3,3),lab.INK)
	await frames(2)
	var before:Vector3=p.position
	check(not t.transfer(p,0,1,Vector3(0,-1.25,0)) and p.position==before,"occupied exit rejects teleport without moving player")
	blocker.queue_free();await frames(2)
	var src:Dictionary=t.portals[0]
	p.reset_to(src.base-src.xf.basis.z*0.4+Vector3.UP*0.05)
	before=p.position;p.position+=src.xf.basis.z*0.8
	var count:int=t.portal_count
	t.update_player(p,before,0.016)
	check(t.portal_count==count,"walking through the back does not immediately return the player")
	# Execute each complete trajectory using the actual controller and level collision.
	for i in t.launch_pads.size():
		var pad:Dictionary=t.launch_pads[i]
		p.reset_to(pad.pos+Vector3.UP*0.05);p.set_physics_process(true)
		var launched:=false
		for tick in 12:
			await frames(1)
			if p.ball and p.velocity.y>10: launched=true;break
		check(launched,"walking onto launch pad fires without pressing a button "+str(i))
		var landed:=false
		for tick in 380:
			await frames(1)
			if p.is_on_floor() and p.flight_time>0.2:
				landed=true;break
		print("PAD LANDING ",i," ",p.position," target=",pad.target)
		check(landed and absf(p.position.y-pad.target.y)<0.3 and Vector2(p.position.x-pad.target.x,p.position.z-pad.target.z).length()<9,"pad arc reaches its intended platform without hitting a wall "+str(i))
		p.set_physics_process(false)
	p.reset_to(t.launch_pads[0].pos+Vector3.UP*0.05);p.action_override={"brake":true}
	t.update_player(p,p.position,0.016)
	check(not p.ball and p.velocity.length()<0.1,"holding brake lets player stand on a launch pad")
	p.action_override={}
	# F5 is an in-game event, not desktop input injection.
	p.reset_to(Vector3(-115,0.05,0));p.velocity=Vector3(4,2,1)
	var key:=InputEventKey.new();key.keycode=KEY_F5;key.physical_keycode=KEY_F5;key.pressed=true
	p._unhandled_input(key)
	check(p.third_person and p.follow_camera.current and p.avatar.visible,"F5 selects third-person camera and shows courier")
	check(p.velocity==Vector3(4,2,1),"switching camera preserves momentum")
	check(not lab.controls.permitted(KEY_F5),"camera key cannot be assigned to a movement ability")
	check(p.avatar.skeleton.get_bone_count()==9 and p.avatar.clips.size()>=6,"courier has a 9-bone unicycle skeleton and eight imported animation clips")
	var wall=lab.box(p.position+Vector3(0,2,2),Vector3(8,4,0.5),lab.INK)
	await frames(2);p.update_camera(0.016)
	check(p.camera_distance<1.8 and clear(p,p.follow_shape,p.follow_camera.global_position),"follow camera retracts before colliding with a nearby wall")
	wall.queue_free();await frames(2)
	p.set_ball(true);p.avatar.pose(p,0.016)
	check(p.avatar.body.visible and p.collider.shape==p.stand_shape,"slingshot retains the unicycle body and full collider")
	p._unhandled_input(key)
	check(not p.third_person and p.camera.current and not p.avatar.visible,"F5 returns to unobstructed first-person view")
	# Playlist bag properties across many complete rotations.
	audio.set_process(false)
	check(audio.playlist.size()==5,"all five supplied tracks are available")
	for track in audio.playlist:
		var stream:AudioStream=load("res://assets/audio/music/"+track.file)
		check(absf(stream.get_length()-float(track.seconds))<1 and not stream.loop,"music duration matches analysis and each track can finish: "+track.title)
	audio.bag.clear();audio.current_track=-1
	var last:=-1;var shuffled:=true
	for cycle in 12:
		var seen:Dictionary={}
		for i in 5:
			var next:int=audio.next_track()
			if seen.has(next) or next==last: shuffled=false
			seen[next]=true;audio.current_track=next;last=next
	check(shuffled,"twelve shuffled cycles play every track once without boundary repeats")
	audio.start_track(false)
	var first:int=audio.current_track
	audio.start_track()
	check(first!=audio.current_track and audio.decks[0].playing and audio.decks[1].playing,"next song overlaps the previous song on a second deck")
	audio.update_mix(0.7)
	check(audio.decks[0].volume_db>-25 and audio.decks[1].volume_db>-25,"both decks have audible equal-power midpoint gains")
	audio.update_mix(0.8)
	check(not audio.decks[1-audio.active_deck].playing and audio.decks[audio.active_deck].playing,"old deck stops when crossfade completes")
	first=audio.current_track
	audio.decks[audio.active_deck].seek(audio.decks[audio.active_deck].stream.get_length()-0.6)
	await get_tree().create_timer(0.1).timeout
	audio.update_mix(0.016)
	check(audio.current_track!=first,"near-end playback automatically advances the playlist")
	var variants:=true
	for kind in audio.samples:
		var previous:=-1
		for i in 12:
			audio.play(kind)
			if audio.last_variant[kind]==previous: variants=false
			previous=audio.last_variant[kind]
	check(variants,"repeated effects avoid immediate duplicate samples")
	for kind in audio.loops:
		var stream:AudioStreamWAV=audio.loops[kind].stream
		check(stream.loop_mode==AudioStreamWAV.LOOP_FORWARD and stream.loop_end>100000,"ambient layer loops its full prebuilt sample: "+kind)
	lab.audio_enabled=false;audio.update_mix(0.01)
	check(AudioServer.is_bus_mute(audio.music_bus) and AudioServer.is_bus_mute(audio.effects_bus) and AudioServer.is_bus_mute(audio.ambience_bus),"master sound toggle mutes music and all effects")
	lab.audio_enabled=true;lab.set_paused(true);audio.update_mix(0.01)
	check(not AudioServer.is_bus_mute(audio.music_bus) and AudioServer.is_bus_mute(audio.effects_bus),"pause ducks music and silences movement effects")
	lab.hud.show_page("Audio")
	await get_tree().process_frame;await get_tree().process_frame
	check(lab.hud.menu.get_global_rect().encloses(lab.hud.page_scroll.get_global_rect()),"audio controls fit the existing minimal menu")
	print("EXPANSION RESULT: ",checks-failures,"/",checks)
	var report:=FileAccess.open("res://.local/reports/expansion-metrics.json",FileAccess.WRITE)
	report.store_string(JSON.stringify({"checks":checks,"failures":failures,"collision_boxes":lab.arena.shapes,"architecture_batches":lab.arena.batches.size(),"portals":t.portals.size(),"launch_pads":t.launch_pads.size()},"  "))
	get_tree().quit(1 if failures else 0)
