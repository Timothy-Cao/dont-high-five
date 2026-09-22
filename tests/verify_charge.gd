extends Node
var checks:=0
var failures:=0
func check(ok: bool,message: String) -> void:
	checks+=1
	if not ok: failures+=1
	print(("PASS  " if ok else "FAIL  ")+message)
func frames(n: int) -> void:
	for i in n: await get_tree().physics_frame
func run(lab: Node3D) -> void:
	var p=lab.player;var c=p.combat
	lab.started=true;lab.set_paused(false);p.testing_input=true;lab.arena.powerups.testing=true
	p.reset_to(Vector3(-114,0.05,17));await frames(8)
	var attacks:int=c.attacks
	p.handle_glove_button(0,true,1000);p.handle_glove_button(1,true,1050)
	check(c.charging and not c.active and not p.has_anchor(),"chord retracts ordinary glove and charges without firing")
	await frames(3);p.handle_glove_button(0,false,1080)
	check(c.active and not c.charging and c.attacks==attacks+1,"releasing either button fires exactly once")
	check(c.projectiles[0].remaining<5.5 and c.projectiles[0].impulse<10,"quick tap has short reach and low knockback")
	p.handle_glove_button(0,true,1090)
	check(c.attacks==attacks+1,"re-pressing one button while the other is held cannot retrigger")
	p.handle_glove_button(0,false,1100);p.handle_glove_button(1,false,1110)
	await frames(120)
	p.handle_glove_button(1,true,2000);p.handle_glove_button(0,true,2050)
	await frames(180)
	check(c.charging and c.charge_fraction()==1 and c.attacks==attacks+1,"full charge caps at 1.1 seconds and waits for release")
	p.camera.rotation.y=0.4;p.handle_glove_button(1,false,4000)
	check(is_equal_approx(c.projectiles[0].remaining,25.5) and c.projectiles[0].impulse==24,"full punch reaches normal glove distance and uses one 24 m/s recipient impulse")
	check(c.direction.dot(-p.camera.global_basis.z)>0.999,"attack aims on release, not when charging began")
	p.handle_glove_button(0,false,4020)
	await frames(150)
	p.reset_to(Vector3(-114,0.05,17));p.camera.rotation=Vector3.ZERO
	c.start_charge();await frames(20);var before:int=c.attacks
	lab.set_paused(true);await frames(8)
	check(not c.charging and c.attacks==before,"pause safely cancels charge without firing")
	lab.set_paused(false);c.start_charge();p.action_override={"brake":true};await frames(2)
	check(not c.charging and c.attacks==before,"brake interrupts charge without producing an attack")
	p.action_override={};c.start_charge();p.reset_to(Vector3(112,20.05,-82));await frames(3)
	check(not c.charging and c.start_charge(),"reset cancels charge; former field bay permits a fresh charge")
	# Knockback/range through actual collision, rather than just checking constants.
	var dummy=lab.arena.dummies[0]
	p.reset_to(dummy.position+Vector3(0,0.05,8));p.camera.position.y=1.58
	await frames(8);p.camera.look_at(dummy.position+Vector3.UP*1.85)
	c.begin(0);await frames(110)
	check(dummy.hits_received==0,"tap cannot reach a dummy beyond its short reach")
	c.begin(1);await frames(110)
	check(dummy.hits_received==1 and dummy.knocked_out,"full charge reaches the same dummy with one nonlethal knockback")
	# Slow input generation, immediate stop, and grounded bunny-hop contact.
	p.reset_to(Vector3(-114,0.05,17));p.camera.rotation=Vector3.ZERO;p.rotation=Vector3.ZERO
	await frames(8);p.input_override=Vector2(1,0);await frames(12)
	check(p.velocity.x>0.8 and p.velocity.x<1.4,"first 100 ms builds about 1.2 m/s rather than snapping to full speed")
	await frames(40);check(absf(p.velocity.x-3.5)<0.02,"unassisted ground speed is half the old walk speed")
	p.input_override=Vector2.ZERO;await frames(8)
	check(p.velocity.length()<0.01,"slow acceleration does not make stopping slippery")
	var v:=Vector3.ZERO
	for i in 1200: v=p.steer_air(v,Vector3.RIGHT,1.0/120)
	check(absf(v.length()-3.5)<0.01,"sustained air input cannot generate more than walking speed")
	v=Vector3(0,0,-30)
	for i in 120: v=p.steer_air(v,Vector3.RIGHT,1.0/120)
	check(absf(v.length()-30)<0.01 and v.x>29,"one second of steering retains earned speed through a right-angle turn")
	p.reset_to(Vector3(-114,0.8,17));p.velocity=Vector3(20,-4,0);p.momentum_air=true
	for i in 60:
		await frames(1)
		if p.is_on_floor(): break
	check(p.is_on_floor() and p.velocity.x>19.9,"landing retains hand-earned horizontal speed for a short grace window")
	p.request_jump();await frames(3)
	check(not p.is_on_floor() and p.velocity.x>19.9 and p.velocity.y>7,"bunny hop carries momentum into the next jump")
	p.reset_to(Vector3(-114,0.8,17));p.velocity=Vector3(20,-4,0)
	await frames(100)
	check(p.is_on_floor() and p.velocity.length()<0.01,"not hopping settles to a stop after landing grace")
	var avatar=p.avatar
	p.velocity=Vector3(3.5,0,0);c.start_charge();c.charge_time=0.6;avatar.pose(p,0.016)
	check(avatar.current_clip=="Walk","charging while walking keeps the leg gait rather than freezing the feet")
	p.velocity=Vector3.ZERO;avatar.pose(p,0.016)
	check(avatar.current_clip=="Charge","standing charge uses the planted full-body wind-up")
	c.cancel()
	check(avatar.skeleton.get_bone_count()==12,"runtime courier imports twelve skeletal joints")
	for clip in ["Idle","Walk","Air","Charge","Punch","Land"]:
		check(avatar.clips.has(clip) and avatar.animator.get_animation(avatar.clips[clip]).get_track_count()>10,"imported skeletal clip has animation tracks: "+clip)
	var foot:int=avatar.skeleton.find_bone("foot_L")
	avatar.animator.play(avatar.clips.Walk);avatar.animator.seek(0,true)
	var rest:Transform3D=avatar.skeleton.get_bone_global_pose(foot)
	avatar.animator.seek(0.2,true)
	check(avatar.skeleton.get_bone_global_pose(foot).origin.distance_to(rest.origin)>0.05,"walk clip actually articulates the foot through the leg chain")
	var planted:=true
	var lifted:=false
	for i in 24:
		avatar.animator.seek(i/30.0,true)
		var foot_pos:Vector3=avatar.skeleton.get_bone_global_pose(foot).origin
		if i<12: planted=planted and absf(foot_pos.y-0.205)<0.006
		else: lifted=lifted or foot_pos.y>0.30
	check(planted and lifted,"baked stride keeps stance foot flat at floor height and lifts the swing foot")
	check(avatar.shoulder_position(0).distance_to(avatar.shoulder_position(1))>0.5,"elastic arms attach to distinct skeletal shoulder sockets")
	print("CHARGE RESULT: ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)

