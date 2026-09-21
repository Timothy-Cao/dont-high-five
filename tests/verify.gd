extends Node

var failures := 0
var checks := 0

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok: failures += 1
	print(("PASS  " if ok else "FAIL  ")+message)

func frames(n: int) -> void:
	for i in n: await get_tree().physics_frame

func run(lab: Node3D) -> void:
	var p = lab.player
	lab.started = true
	lab.set_paused(false)
	await frames(10)
	check(p.is_on_floor(),"spawn settles on the launch deck")
	p.camera.look_at(Vector3(-4,7,5))
	p.fire_hand(0)
	await frames(45)
	check(p.hands[0].state==2,"left projectile attaches to its aimed panel")
	p.camera.look_at(Vector3(4,7,5))
	p.fire_hand(1)
	await frames(45)
	check(p.hands[1].state==2,"right projectile independently attaches")
	check(p.shot_velocity(p.position).length()<0.1,"attachment itself does not generate energy")
	p.camera.rotation = Vector3.ZERO
	var base: Vector3 = p.position
	var weak: Vector3 = p.shot_velocity(base+Vector3(0,0,2))
	var strong: Vector3 = p.shot_velocity(base+Vector3(0,0,4))
	check(strong.length()>weak.length()+3,"drawing back increases launch speed")
	var sideways: Vector3 = p.shot_velocity(base+Vector3(2,0,4))
	check(sideways.x < -0.5,"body repositioning changes launch direction")
	check(p.shot_velocity(base+Vector3(0,0,100)).length()<=p.max_speed+0.01,"stretch and launch power have a hard limit")
	p.testing_input = true
	p.input_override = Vector2(0,1)
	await frames(600)
	check(p.velocity.length()<0.1 and p.position.z>base.z+3,"holding backward settles into spring/movement-force equilibrium")
	check(p.hands[0].state==2 and p.hands[1].state==2,"sustained pulling never detaches either glove")
	print("EQUILIBRIUM pos=",p.position," velocity=",p.velocity," shot=",p.shot_velocity(p.position))
	var settled: Vector3 = p.position
	await frames(120)
	check(p.position.distance_to(settled)<0.02,"equilibrium stays stable for a further second")
	var setup: Vector3 = p.position
	var initial: Vector3 = p.shot_velocity(p.position)
	p.update_preview()
	var prediction: Vector3 = p.predicted_end
	p.launch()
	p.input_override = Vector2.ZERO
	check(p.ball and p.velocity.distance_to(initial)<0.01,"launch switches collision shape and uses the derived vector")
	check(p.hands[0].state==0 and p.hands[1].state==0,"launch automatically releases both arms")
	await frames(220)
	check(p.position.z<1 and p.is_on_floor() and p.position.y>2.9,"default full draw clears the gap and lands on the raised deck")
	print("LANDING position=",p.position," preview=",prediction," flight distance=",p.last_distance)
	check(p.last_landing.distance_to(prediction)<0.65,"preview predicts the actual first landing within 65cm")
	p.retry()
	check(p.position.distance_to(setup)<0.08 and p.hands[0].state==2 and p.hands[1].state==2,"retry restores body and both anchor states")
	check(p.shot_velocity(p.position).distance_to(initial)<0.1,"restored setup reproduces launch velocity")
	await frames(120)
	check(p.position.z<setup.z-0.5,"releasing backward input lets the stretched arms pull the body forward")
	p.anchor_drive_limit = 180
	var original_length:float=p.hands[0].rest
	p.input_override = Vector2(0,1)
	await frames(240)
	var within_limit := true
	for h in p.hands:
		within_limit = within_limit and p.chest().distance_to(h.point)<=h.rest+p.stretch_limit+0.02
	check(within_limit and p.hands[0].state==2 and p.hands[1].state==2,"maximum reach constrains an overpowered walk without detaching")
	check(absf(p.hands[0].rest-original_length)<0.001 and p.chest().distance_to(p.hands[0].point)<=original_length+p.stretch_limit+0.02,"hard maximum cannot creep outward by silently extending an arm")
	p.anchor_drive_limit = 35
	p.input_override = Vector2.ZERO
	var before: Vector3 = p.position
	lab.set_paused(true)
	await frames(20)
	check(p.position.distance_to(before)<0.001,"pause freezes player movement")
	lab.set_paused(false)
	p.cancel_hands()
	check(p.shot_velocity(p.position).length()<0.01,"cancellation removes stored launch power")
	# Place the ball under a test ceiling; standing must not clip through it.
	lab.box(Vector3(0,1.2,36),Vector3(4,0.4,4),lab.INK,false)
	p.reset_to(Vector3(0,0.02,36))
	p.set_ball(true)
	await frames(4)
	check(not p.try_stand(),"ball cannot unfold through a low ceiling")
	lab.goto_station(2)
	await frames(4)
	p.camera.look_at(Vector3(36,4.5,4))
	p.fire_hand(1)
	await frames(50)
	check(lab.gate_open and lab.gate.collision_layer==0,"remote button removes shutter collision")
	check(p.hands[1].state==0,"button frees the hand for another launch")
	# Search only the small window's launch setup, then exercise the best actual flight.
	# The search is a level reachability check, not part of the player's aiming system.
	var found := false
	var chosen := Vector2.ZERO
	for height in [5.5,6.0,6.5,7.0,7.5,8.0,8.5,9.0,9.25]:
		for draw in [2.0,2.25,2.5,2.75,3.0,3.25,3.5,3.75,4.0,4.25,4.5,4.75,5.0,5.25,5.5]:
			p.reset_to(lab.spawns[2])
			p.attach_fixture(Vector3(24,height,5.23),Vector3(32,height,5.23))
			p.position.z += draw
			var v: Vector3 = p.shot_velocity(p.position)
			var t: float = (-8.5-p.position.z)/v.z if v.z < -0.1 else 100.0
			var y: float = p.position.y+0.32+v.y*t-0.5*p.gravity*t*t
			if y>5.04 and y<5.28:
				chosen = Vector2(height,draw)
				found = true
				break
		if found: break
	check(found,"a default-tuning shot exists through the ball-sized opening")
	if found:
		p.reset_to(lab.spawns[2])
		p.attach_fixture(Vector3(24,chosen.x,5.23),Vector3(32,chosen.x,5.23))
		p.position.z += chosen.y
		await frames(1)
		p.launch()
		await frames(230)
		print("WINDOW setup height/draw=",chosen," final=",p.position)
		check(p.position.z < -10 and p.is_on_floor() and p.position.y>2.9,"ball actually passes through the window and lands beyond it")
	lab.goto_station(0)
	await frames(4)
	p.camera.look_at(Vector3(0,2,-55))
	p.fire_hand(0)
	await frames(65)
	check(p.hands[0].state==0,"a missed or invalid projectile returns safely")
	# Swept movement against a thin wall at maximum speed.
	lab.box(Vector3(0,4,38),Vector3(8,8,0.08),lab.INK,false)
	p.reset_to(Vector3(0,2,40))
	p.set_ball(true)
	p.velocity = Vector3(0,0,-40)
	await frames(20)
	check(p.position.z>38.3,"fast ball cannot tunnel through a thin wall")
	# Exercise actual menu signals, including captured practice-area indices.
	lab.set_paused(true)
	for page_name in ["Yard","Controls","Settings","Physics"]:
		lab.hud.show_page(page_name)
		await get_tree().process_frame
		await get_tree().process_frame
		check(lab.hud.page==page_name and lab.hud.menu.get_global_rect().encloses(lab.hud.pages.get_global_rect()),page_name+" menu opens with its content inside the panel")
	lab.hud.show_page("Settings")
	var settings_checks = lab.hud.pages.find_children("*","CheckButton",true,false)
	settings_checks[0].button_pressed = false
	settings_checks[1].button_pressed = false
	check(not p.preview_enabled and not lab.audio_enabled,"settings toggles change the actual preview and audio state")
	settings_checks[0].button_pressed = true
	settings_checks[1].button_pressed = true
	lab.hud.show_page("Physics")
	var sliders = lab.hud.pages.find_children("*","HSlider",true,false)
	sliders[0].value = 5.5
	check(is_equal_approx(p.launch_gain,5.5),"physics slider changes the live launch setting")
	lab.hud.pages.get_child(lab.hud.pages.get_child_count()-1).pressed.emit()
	check(is_equal_approx(p.launch_gain,4.2),"restore defaults resets the live physics settings")
	lab.hud.show_page("Yard")
	var area_buttons = lab.hud.pages.find_children("*","Button",true,false)
	area_buttons[2].pressed.emit()
	check(lab.station==2 and not lab.paused,"practice-area menu loads the selected area and resumes")
	lab.set_paused(true)
	lab.hud.start_button.pressed.emit()
	check(not lab.paused,"resume button returns control to the game")
	print("RESULT: ",checks-failures,"/",checks," checks passed")
	get_tree().quit(1 if failures else 0)

