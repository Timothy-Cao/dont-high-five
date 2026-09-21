extends Node
var checks:=0
var failures:=0
func check(ok: bool,message: String) -> void:
	checks+=1
	if not ok: failures+=1
	print(("PASS  " if ok else "FAIL  ")+message)
func frames(n: int) -> void:
	for i in n: await get_tree().physics_frame
func setup(lab: Node3D) -> void:
	lab.set_paused(false)
	lab.goto_station(3)
	lab.player.position.z=33
	lab.player.action_override={}
	lab.player.input_override=Vector2.ZERO
	await frames(8)
	lab.player.camera.look_at(Vector3(0,17,27))
func run(lab: Node3D) -> void:
	var p=lab.player
	lab.started=true
	p.testing_input=true
	await setup(lab)
	for h in p.hands:
		var clean:=true
		for mesh in h.glove.find_children("*","GeometryInstance3D",true,false):
			clean=clean and mesh.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_OFF and mesh.layers==2
		check(clean,"every glove component is isolated from world shadow casting")
		check(h.lamp.shadow_enabled and h.lamp.shadow_caster_mask==1,"glove lamp preserves world occlusion but excludes viewmodel layer")
	check(p.ball_rim.cast_shadow==GeometryInstance3D.SHADOW_CASTING_SETTING_OFF,"ball rim cannot cast an enlarged first-person shadow")
	p.handle_glove_button(0,true,1000)
	check(p.hands[0].state==1 and not p.zip_pending,"single click fires immediately without waiting for chord detection")
	p.handle_glove_button(1,true,1070)
	check(p.zip_pending and p.hands[0].state==1 and p.hands[1].state==1,"70 ms left-right chord starts both projectiles")
	var a:Vector3=(p.hands[0].point-p.hands[0].from).normalized()
	var b:Vector3=(p.hands[1].point-p.hands[1].from).normalized()
	check(a.dot(b)>0.99999,"zip glove rays extend in parallel rather than converging at the reticle")
	var origin:Vector3=p.position
	var count:int=p.zip_count
	var ticks:=0
	while p.zip_count==count and ticks<100:
		await frames(1)
		ticks+=1
	check(p.zip_count==count+1 and ticks<45,"real overhead catch produces a burst in under 375 ms")
	check(p.ball and p.velocity.length()>27 and p.velocity.length()<=28.1,"zip tucks into a ball and gives a bounded 28 m/s impulse")
	check(not p.has_anchor() and not p.zip_pending,"zip releases anchors cleanly after the catch")
	check(p.hand_recovery>1.98,"successful catch begins two seconds of glove recovery")
	p.fire_hand(0);p.fire_hand(1)
	check(p.hands[0].state==0 and p.hands[1].state==0 and not p.begin_zip(),"both ordinary glove shots and zip are blocked during recovery")
	p.cancel_hands()
	check(p.hand_recovery>1.98,"recall cannot bypass physical hand recovery")
	var recovery_before:float=p.hand_recovery
	lab.set_paused(true)
	await frames(12)
	check(is_equal_approx(p.hand_recovery,recovery_before),"pausing freezes hand recovery instead of skipping the cost")
	lab.set_paused(false)
	await frames(20)
	check(p.position.y>origin.y+3,"zip actually carries the player upward through the level")
	check(p.hands[0].glove.visible and p.hands[1].glove.visible,"returning gloves remain visible while tucked in a ball")
	p.handle_glove_button(1,true,1400)
	await frames(100)
	check(p.zip_count==count+1,"holding both buttons never repeats the burst")
	check(p.hand_recovery>0.9,"gloves are still unavailable about one second after the burst")
	await frames(130)
	check(p.hand_recovery==0,"gloves finish recovering after two seconds of active play")
	p.fire_hand(0)
	check(p.hands[0].state==1,"ordinary glove use returns when the physical recovery ends")
	await setup(lab)
	p.handle_glove_button(1,true,2000)
	p.handle_glove_button(0,true,2110)
	check(p.zip_pending,"right-left order works within the 120 ms tolerance")
	p.cancel_hands()
	await frames(65)
	check(not p.zip_pending and p.zip_count==count+1,"recall cancels an in-flight zip without a delayed launch")
	await setup(lab)
	p.handle_glove_button(0,true,3000)
	p.handle_glove_button(1,true,3200)
	check(not p.zip_pending and p.hands[0].state==1 and p.hands[1].state==1,"slower separate clicks remain independent glove placements")
	await setup(lab)
	p.zip_enabled=false
	p.handle_glove_button(0,true,4000)
	p.handle_glove_button(1,true,4050)
	check(not p.zip_pending and p.hands[0].state==1 and p.hands[1].state==1,"disabling zip restores independent shots even for simultaneous clicks")
	p.zip_enabled=true
	await setup(lab)
	p.begin_zip()
	p.action_override={"brake":true}
	await frames(45)
	check(not p.zip_pending and p.zip_count==count+1,"brake pressed during projectile travel cancels the pending launch")
	await setup(lab)
	p.camera.rotation=Vector3.ZERO
	var speed:float=p.velocity.length()
	check(not p.begin_zip() and p.velocity.length()==speed,"empty space cannot produce a free air dash")
	# Only one parallel ray fits at the edge of a pad.
	p.reset_to(Vector3(40,15,18))
	p.camera.rotation=Vector3.ZERO
	var narrow=lab.box(Vector3(39.63,16,8),Vector3(0.4,3,0.4),lab.MINT)
	await frames(2)
	var left_hit:Dictionary=p.ray(p.hand_start(0),p.hand_start(0)+Vector3.FORWARD*p.ZIP_RANGE)
	var right_hit:Dictionary=p.ray(p.hand_start(1),p.hand_start(1)+Vector3.FORWARD*p.ZIP_RANGE)
	check(not left_hit.is_empty() and left_hit.collider==narrow and right_hit.is_empty(),"edge fixture has exactly one valid parallel ray")
	check(not p.begin_zip(),"a one-glove edge hit cannot trigger the two-hand move")
	narrow.queue_free()
	var level_pad=lab.box(Vector3(40,4,8),Vector3(4,8,0.3),lab.MINT)
	p.reset_to(Vector3(40,0.05,18))
	p.camera.rotation=Vector3.ZERO
	await frames(15)
	check(p.is_on_floor() and p.begin_zip(),"a level shot from the floor can start a zip")
	var flat_count:int=p.zip_count
	for tick in 100:
		await frames(1)
		if p.zip_count>flat_count: break
	await frames(3)
	check(p.velocity.z< -26 and p.velocity.y>4 and not p.is_on_floor(),"level zip has enough lift to escape floor friction")
	p.action_override={"brake":true}
	await frames(2)
	check(absf(p.velocity.x)<0.01 and absf(p.velocity.z)<0.01 and p.hand_recovery>1.8,"stone brake stays available without bypassing hand recovery")
	p.action_override={}
	p.jump_buffer=0.10
	await frames(2)
	check(p.velocity.y>7 and p.hand_recovery>1.8,"air jump remains available while gloves retract")
	p.reset_to(Vector3(40,0.05,26.2));p.camera.rotation=Vector3.ZERO
	await frames(15)
	check(not p.begin_zip(),"surface beyond 17 m cannot trigger quick zip")
	p.fire_hand(0)
	await frames(45)
	check(p.hands[0].state==2,"normal glove can still attach beyond quick zip range")
	p.reset_to(Vector3(40,0.05,33.5));p.camera.rotation=Vector3.ZERO
	await frames(15)
	p.fire_hand(0)
	await frames(55)
	check(p.hands[0].state==2,"regular shot attaches just inside its 25.5 m reach")
	p.reset_to(Vector3(40,0.05,34.0));p.camera.rotation=Vector3.ZERO
	await frames(15)
	p.fire_hand(0)
	await frames(55)
	check(p.hands[0].state==0 and not p.target_valid,"shot and reticle both reject surfaces beyond 25.5 m")
	level_pad.queue_free()
	await setup(lab)
	p.hand_recovery=0.3
	check(not p.begin_zip(),"busy hands prevent stacked impulses")
	p.hand_recovery=0
	p.action_override={"brake":true}
	check(not p.begin_zip(),"held brake takes priority over zip")
	p.action_override={}
	check(p.begin_zip(),"valid target becomes available after recovery and brake release")
	lab.set_paused(true)
	check(not p.zip_pending and not p.mouse_down[0] and not p.mouse_down[1],"pause cancels the pending burst and clears stale mouse chords")
	await frames(5)
	check(lab.hud.page=="Home" and lab.hud.menu.size.x<500 and lab.hud.menu.size.y<520,"pause opens a compact home menu")
	check(lab.hud.home.visible and not lab.hud.pages.visible,"advanced content is hidden on the home screen")
	lab.hud.nav_buttons.Controls.pressed.emit()
	check(lab.hud.page=="Controls","home Controls button opens the actual control page")
	lab.hud.show_page("Bindings")
	lab.hud.back_button.pressed.emit()
	check(lab.hud.page=="Controls","bindings Back returns to its parent page")
	lab.hud.back_button.pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	check(lab.hud.page=="Home" and lab.hud.menu.size.x<500,"returning from a wide page restores the compact menu")
	lab.hud.start_button.pressed.emit()
	check(not lab.paused,"compact Resume button returns to play")
	print("POLISH RESULT: ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
