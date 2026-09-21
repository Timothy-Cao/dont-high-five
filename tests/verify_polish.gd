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
	check(p.hands[0].state==1 and not p.combat.active,"single click fires an ordinary glove immediately")
	p.handle_glove_button(1,true,1070)
	check(p.combat.active and p.hands[0].state==3 and p.hands[1].state==3,"70 ms left-right chord starts a parallel punch")
	var origin:Vector3=p.position
	await frames(75)
	check(not p.combat.active and p.position.distance_to(origin)<0.15,"overhead punch ends without pulling the player toward the hit")
	check(p.hand_recovery>0,"punch has an explicit physical return interval")
	p.fire_hand(0)
	check(p.hands[0].state==0,"regular glove use waits for fist recovery")
	var recovery_before:float=p.hand_recovery
	lab.set_paused(true);await frames(12)
	check(is_equal_approx(p.hand_recovery,recovery_before),"pause freezes fist recovery")
	lab.set_paused(false);await frames(90)
	check(p.hand_recovery==0,"hands return to regular use after recovery")
	p.fire_hand(0)
	check(p.hands[0].state==1,"ordinary glove can fire after recovery")
	await setup(lab)
	p.handle_glove_button(1,true,2000);p.handle_glove_button(0,true,2100)
	check(p.combat.active,"right-left chord works within 120 ms")
	p.cancel_hands()
	check(not p.combat.active and p.hand_recovery>0,"recall cancels projectiles without skipping their return")
	await setup(lab)
	p.handle_glove_button(0,true,3000);p.handle_glove_button(1,true,3200)
	check(not p.combat.active and p.hands[0].state==1 and p.hands[1].state==1,"separate clicks keep independent glove placements")
	await setup(lab)
	p.punch_enabled=false
	p.handle_glove_button(0,true,4000);p.handle_glove_button(1,true,4050)
	check(not p.combat.active,"ability toggle disables the punch")
	p.punch_enabled=true
	await setup(lab)
	p.combat.begin();lab.set_paused(true)
	check(not p.combat.active and not p.mouse_down[0] and not p.mouse_down[1],"pause cancels an active punch and clears mouse chords")
	await frames(5)
	check(lab.hud.page=="Home" and lab.hud.menu.size.x<500 and lab.hud.menu.size.y<520,"pause opens a compact home menu")
	check(lab.hud.home.visible and not lab.hud.pages.visible,"advanced content is hidden on the home screen")
	lab.hud.nav_buttons.Settings.pressed.emit()
	for b in lab.hud.pages.find_children("*","Button",true,false):
		if b.text=="Controls": b.pressed.emit();break
	check(lab.hud.page=="Controls","home Controls button opens the actual control page")
	lab.hud.show_page("Bindings")
	lab.hud.back_button.pressed.emit()
	check(lab.hud.page=="Controls","bindings Back returns to its parent page")
	lab.hud.back_button.pressed.emit()
	lab.hud.back_button.pressed.emit()
	await get_tree().process_frame
	await get_tree().process_frame
	check(lab.hud.page=="Home" and lab.hud.menu.size.x<500,"returning from a wide page restores the compact menu")
	lab.hud.start_button.pressed.emit()
	check(not lab.paused,"compact Resume button returns to play")
	print("POLISH RESULT: ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
