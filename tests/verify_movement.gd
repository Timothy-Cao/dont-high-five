extends Node
var checks:=0
var failures:=0
var metrics:={}
func check(ok: bool,message: String) -> void:
	checks+=1
	if not ok: failures+=1
	print(("PASS  " if ok else "FAIL  ")+message)
func frames(n: int) -> void:
	for i in n: await get_tree().physics_frame
func run(lab: Node3D) -> void:
	var p=lab.player
	lab.started=true
	lab.set_paused(false)
	p.testing_input=true
	p.input_override=Vector2.ZERO
	p.action_override={}
	lab.goto_station(0)
	await frames(10)
	p.input_override=Vector2(0,-1)
	await frames(30)
	check(absf(p.velocity.z+7)<0.05,"W reaches the intended 7 m/s walking speed")
	var stopped_at:Vector3=p.position
	p.input_override=Vector2.ZERO
	var stop_ticks:=0
	while p.velocity.length()>0.05 and stop_ticks<120:
		await frames(1)
		stop_ticks+=1
	metrics["ground_stop_seconds"]=stop_ticks/120.0
	metrics["ground_stop_distance_m"]=p.position.distance_to(stopped_at)
	check(stop_ticks<=12,"releasing movement stops within 100 ms")
	check(p.position.distance_to(stopped_at)<0.30,"walking stop drifts less than 30 cm")
	lab.goto_station(0)
	await frames(12)
	p.input_override=Vector2(1,1)
	await frames(25)
	check(absf(Vector2(p.velocity.x,p.velocity.z).length()-7)<0.05,"diagonal movement has no speed boost")
	p.input_override=Vector2(-1,-1)
	await frames(18)
	check(p.velocity.x<0 and p.velocity.z<0,"opposite input reverses direction within 150 ms")
	p.input_override=Vector2.ZERO
	lab.goto_station(0)
	await frames(10)
	var start_y:float=p.position.y
	p.request_jump()
	var apex:=start_y
	for i in 100:
		await frames(1)
		apex=maxf(apex,p.position.y)
	metrics["jump_apex_m"]=apex-start_y
	check(apex-start_y>1.3 and apex-start_y<1.5,"standard jump has a predictable 1.3–1.5 m apex")
	check(p.is_on_floor(),"standard jump lands without a lingering bounce")
	p.request_jump()
	await frames(42)
	p.request_jump()
	await frames(2)
	check(p.velocity.y>7 and p.air_jumps==0,"second Space press provides one air jump")
	var v_before:float=p.velocity.y
	p.request_jump()
	await frames(2)
	check(p.velocity.y<v_before,"a third jump cannot repeatedly add lift")
	lab.goto_station(0)
	await frames(12)
	p.position.x=11
	await frames(12)
	p.request_jump()
	await frames(2)
	check(p.velocity.y>7 and p.air_jumps==1,"100 ms ledge grace uses the ground jump, preserving the air jump")
	p.reset_to(Vector3(0,3.2,12))
	p.air_jumps=0
	p.velocity.y=-4
	p.request_jump()
	await frames(15)
	check(p.velocity.y>5 and p.position.y>3.2,"a jump pressed just before landing is buffered")
	p.reset_to(Vector3(-42,18,0))
	p.set_ball(true)
	p.flying=true
	p.flight_time=0.2
	p.velocity=Vector3(0,0,-30)
	p.input_override=Vector2(1,0)
	await frames(60)
	metrics["air_correction_degrees_500ms"]=rad_to_deg(atan2(absf(p.velocity.x),absf(p.velocity.z)))
	check(p.velocity.x>10 and p.velocity.z< -10,"half a second of air input makes a meaningful controlled turn")
	check(Vector2(p.velocity.x,p.velocity.z).length()<=30.1,"air steering cannot create unlimited horizontal speed")
	p.reset_to(Vector3(-42,18,0))
	p.flying=true
	p.flight_time=0.2
	p.velocity=Vector3(0,0,-30)
	p.input_override=Vector2.ZERO
	await frames(40)
	check(absf(p.velocity.z+30)<0.05,"untouched launch preserves horizontal momentum")
	p.action_override={"brake":true}
	await frames(2)
	check(Vector2(p.velocity.x,p.velocity.z).length()<0.01 and p.velocity.y< -7,"stone brake removes horizontal momentum immediately and drops")
	p.action_override={}
	p.input_override=Vector2(1,0)
	await frames(20)
	check(p.velocity.x>3 and not p.stone,"release brake restores air control")
	p.input_override=Vector2.ZERO
	p.reset_to(Vector3(16.06,5,42))
	p.action_override={"cling":true}
	await frames(20)
	var grip_y:float=p.position.y
	check(p.wall_clinging and absf(p.velocity.y)<0.01,"held wall grip stops falling beside a wall")
	await frames(40)
	check(absf(p.position.y-grip_y)<0.02,"wall grip holds height without sliding")
	p.input_override=Vector2(0,-1)
	await frames(40)
	check(p.position.y>grip_y+0.8,"W climbs while wall grip is held")
	p.input_override=Vector2.ZERO
	p.request_jump()
	await frames(2)
	check(not p.wall_clinging and p.velocity.x< -5 and p.velocity.y>7,"Space wall-jumps away from the surface")
	p.action_override={}
	lab.goto_station(3)
	await frames(10)
	p.camera.look_at(Vector3(0,17,27))
	p.fire_hand(0)
	await frames(60)
	check(p.hands[0].state==2,"overhead glove projectile reaches the grapple anchor")
	var reel_y:float=p.position.y
	var rest_before:float=p.hands[0].rest
	p.action_override={"reel":true}
	await frames(120)
	metrics["grapple_rise_1s_m"]=p.position.y-reel_y
	check(p.position.y>reel_y+5 and p.hands[0].rest<rest_before-3,"hold reel lifts the body and progressively shortens the arm")
	p.action_override={}
	p.cancel_hands()
	var release_speed:=Vector2(p.velocity.x,p.velocity.z).length()
	await frames(10)
	check(absf(Vector2(p.velocity.x,p.velocity.z).length()-release_speed)<0.05,"releasing a grapple preserves its horizontal momentum")
	lab.goto_station(0)
	await frames(12)
	p.attach_fixture(Vector3(-4,7,5.23),Vector3(4,7,5.23))
	var length_before:float=p.hands[0].rest
	p.adjust_length(2)
	await frames(70)
	check(p.hands[0].rest>length_before+1.9 and p.shot_velocity(p.position).length()<0.05,"paying out variable arm length adds slack without free launch energy")
	p.adjust_length(-4)
	await frames(100)
	check(p.hands[0].rest<length_before-1.0 and p.hands[0].state==2,"shortening an arm is gradual and preserves attachment")
	check(p.hands[0].lamp.global_position.distance_to(p.hands[0].point+p.hands[0].normal*0.45)<0.1,"glove light follows the distant anchor")
	p.cancel_hands()
	p.reset_to(Vector3(-20,4,34))
	p.velocity=Vector3(0,-5,0)
	await frames(50)
	check(p.velocity.y>5,"purple bounce pad returns upward momentum")
	p.reset_to(Vector3(-20,2,34))
	p.action_override={"brake":true}
	await frames(120)
	check(p.is_on_floor() and absf(p.velocity.y)<0.1,"stone brake stays planted on a bounce pad instead of looping rebounds")
	p.action_override={}
	p.input_override=Vector2.ZERO
	lab.set_paused(true)
	var controls=lab.controls
	var saved:Dictionary=controls.keys.duplicate()
	controls.reset_bindings(false)
	check(controls.keys.jump==KEY_SPACE,"Space is the default jump input")
	check(controls.bind("launch",KEY_F,false) and controls.keys.reel==KEY_E,"binding to an occupied key swaps the actions without losing one")
	check(not controls.bind("launch",KEY_ESCAPE,false),"reserved menu keys cannot be stolen")
	var event:=InputEventKey.new()
	event.physical_keycode=KEY_F
	event.pressed=true
	check(event.is_action_pressed("pop_launch"),"the rebound key resolves through the engine InputMap")
	controls.keys=saved
	controls.apply()
	lab.set_paused(false)
	var mouse_event:=InputEventMouseMotion.new()
	mouse_event.screen_relative=Vector2(10,0)
	mouse_event.relative=Vector2(100,0)
	p.rotation.y=0
	p.apply_mouse_motion(mouse_event)
	var first_yaw:float=p.rotation.y
	mouse_event.relative=Vector2(1,0)
	p.apply_mouse_motion(mouse_event)
	check(absf(first_yaw+10*p.sensitivity)<0.0001 and absf(p.rotation.y-2*first_yaw)<0.0001,"mouse aim ignores resolution-scaled motion and uses raw screen deltas")
	lab.set_paused(true)
	for page_name in ["Controls","Bindings","Abilities","Settings","Physics"]:
		lab.hud.show_page(page_name)
		await get_tree().process_frame
		await get_tree().process_frame
		check(lab.hud.menu.get_global_rect().encloses(lab.hud.page_scroll.get_global_rect()),page_name+" content fits inside its menu")
		check(lab.hud.get_global_rect().encloses(lab.hud.menu.get_global_rect()),page_name+" entire menu fits the viewport")
	print("METRICS ",JSON.stringify(metrics))
	print("MOVEMENT RESULT: ",checks-failures,"/",checks)
	var f:=FileAccess.open("res://.local/reports/movement-metrics.json",FileAccess.WRITE)
	f.store_string(JSON.stringify({"checks":checks,"failures":failures,"metrics":metrics},"  "))
	get_tree().quit(1 if failures else 0)

