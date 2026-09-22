extends Node
var checks:=0
var failures:=0
func check(ok:bool,message:String) -> void:
	checks+=1
	if not ok:failures+=1
	print(("PASS  " if ok else "FAIL  ")+message)
func frames(n:int) -> void:
	for i in n:await get_tree().physics_frame
func run(lab:Node3D) -> void:
	var p=lab.player;var w=lab.session.watcher;var cargo=lab.session.objectives.cargos[0]
	lab.started=true;lab.set_paused(false);p.testing_input=true;lab.arena.powerups.testing=true
	p.set_physics_process(false);p.reset_to(Vector3(0,140,0));cargo.reset_cargo();cargo.position=p.chest()
	check(cargo.try_pickup(p,0),"left hand accepts cargo")
	p.fixed_mode=false;var h:Dictionary=p.hands[1];h.state=2;h.point=p.chest()+Vector3(0,4,-8);h.normal=Vector3.UP;h.rest=4;h.spool_target=4
	p.launch()
	check(p.has_cargo() and p.hands[0].state==4 and h.state==0 and p.velocity.length()>5,"one-handed elastic E launch keeps cargo and releases only its anchor")
	p.launch_from_pad(Vector3(0,20,-30));check(p.has_cargo() and p.velocity.length()>30,"pad launch retains cargo at high speed")
	cargo.position=p.chest();p.camera.position.y=1.58;p.set_physics_process(true);p.gravity=0
	await frames(120)
	check(p.has_cargo() and cargo.position.distance_to(p.chest())<4,"carried cargo catches up during sustained fast traversal without a distance drop")
	p.set_physics_process(false);p.cancel_hands();check(p.has_cargo(),"ordinary recall never discards the occupied hand")
	# A held ball leaves the same free hand available for successive ceiling clicks.
	var ceiling=lab.box(Vector3(0,165,0),Vector3(100,0.5,30),lab.INK)
	p.position=Vector3(0,158,0);cargo.position=p.chest();p.velocity=Vector3.ZERO;p.fixed_mode=true;p.gravity=24;p.set_ball(false);p.camera.position.y=1.58
	await frames(2);p.set_physics_process(true);var start_x:float=p.position.x;var attached:=0
	for step in 5:
		p.camera.look_at(Vector3(p.position.x+5,164.75,0));p.handle_glove_button(1,true,1000+step*600);p.handle_glove_button(1,false,1030+step*600)
		await frames(60)
		if h.state==2:attached+=1
	print("ONE HAND CEILING distance=",p.position.x-start_x," grips=",attached)
	check(attached==5 and p.position.x-start_x>8 and p.has_cargo(),"five clicks with the same free hand traverse the ceiling while carrying")
	var before:Vector3=p.velocity;p.launch()
	check(p.has_cargo() and h.state==0 and p.velocity==before,"fixed E release keeps cargo and earned velocity")
	p.set_physics_process(false);ceiling.queue_free();p.cancel_hands();p.clear_mouse_chord()
	p.fire_hand(0);check(not p.has_cargo() and cargo.carrier==null,"clicking the hand that picked up cargo explicitly drops it")
	cargo.position=p.chest();check(cargo.try_pickup(p,1),"right hand can own cargo too")
	p.cancel_hands();check(p.hands[1].state==4,"recall preserves right-hand ownership too")
	# Use a portal's actual collision-tested transfer path.
	var travel=lab.arena.travel;var src:Transform3D=travel.portals[0].xf
	p.position=src.origin-p.collider.position;p.global_basis=src.basis;p.velocity=-src.basis.z*10
	cargo.position=p.position+Vector3.UP*1.2
	check(travel.transfer(p,0,1,Vector3.ZERO) and p.has_cargo() and cargo.position.distance_to(p.chest())<3,"portal transfers the held cargo with its carrier")
	p.stone=true;p.fire_hand(1);check(not p.has_cargo(),"explicit carrying-hand drop remains available while braking");p.reset_to(Vector3(0,140,0))
	w.enter();w.cut_power();await frames(135)
	check(w.camera.environment==null and not w.night_vision.screen.visible,"Watcher blackout grants no night vision")
	check(lab.environment.ambient_light_energy==0 and w.night_vision.gain==0,"both roles share the fully dark environment")
	w.leave();await frames(2)
	check(not w.night_vision.screen.visible and p.camera.environment==null and lab.environment.ambient_light_energy==0,"returning to Fiver removes night vision without restoring arena lights")
	var glove:Node3D=lab.session.objectives.partners[0].gloves[0]
	var luminous:=false
	for mesh in glove.find_children("*","MeshInstance3D",true,false):
		for surface in mesh.mesh.get_surface_count():
			var mat=mesh.get_active_material(surface)
			luminous=luminous or (mat is StandardMaterial3D and mat.emission_enabled and mat.emission_energy_multiplier>0.5)
	check(luminous and w.darkness.exempt(glove),"other Fivers' gloves remain visibly emissive during blackout")
	w.feedback.pulse_light(Vector3(0,140,0),true)
	check(w.feedback.impact_lights.any(func(item):return item.node.light_energy>0) and w.darkness.exempt(w.feedback),"shot impacts illuminate surrounding geometry during blackout")
	await frames(30);check(w.feedback.impact_lights.all(func(item):return item.node.light_energy==0),"impact lights retire after their short reveal pulse")
	w.cut_power();w.enter();w.camera.position=Vector3(0,146,0);w.camera.rotation=Vector3.ZERO
	var floor=lab.box(Vector3(0,139,0),Vector3(80,1,80),lab.INK)
	var wall=lab.box(Vector3(0,145,-5),Vector3(20,12,0.5),lab.INK)
	await frames(2);w.cooldowns.grenade=0;w.grenade()
	var bomb:Dictionary=w.bombs.back();var touched:=false
	for tick in 120:
		await frames(1)
		if bomb.velocity.length()<10:touched=true;break
	check(touched and not bomb.landed and bomb.velocity.length()<10,"wall contact kills most grenade speed rather than creating a large bounce")
	for tick in 300:
		if bomb.get("touched",false):break
		await frames(1)
	check(bomb.get("touched",false) and bomb.fuse>0.95,"first floor bounce starts a non-resetting one-second fuse")
	await frames(90);check(w.bombs.has(bomb),"landed grenade remains for at least three quarters of a second")
	await frames(40);check(not w.bombs.has(bomb),"landed grenade explodes after one second")
	var warning=w.feedback.strike_visual(Vector3(0,140,0),Vector3.RIGHT)
	check(warning.get_child_count()==1 and warning.get_child(0).mesh is PlaneMesh and warning.get_child(0).mesh.size==Vector2.ONE*36 and warning.basis.is_equal_approx(Basis.IDENTITY),"airstrike warning marks the entire 36 m diameter footprint on a horizontal plane")
	warning.queue_free();floor.queue_free();wall.queue_free();w.leave()
	print("CARRY NIGHT RESULT: ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
