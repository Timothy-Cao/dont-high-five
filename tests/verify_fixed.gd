extends Node
var checks:=0
var failures:=0
func check(ok:bool,message:String) -> void:
	checks+=1
	if not ok: failures+=1
	print(("PASS  " if ok else "FAIL  ")+message)
func frames(n:int) -> void:
	for i in n: await get_tree().physics_frame
func latch(p:CharacterBody3D,index:int,point:Vector3) -> void:
	p.hands[index].state=2;p.hands[index].point=point;p.hands[index].normal=Vector3.DOWN
	p.fixed_rope.attach(p,index)
func run(lab:Node3D) -> void:
	var p=lab.player;var c=p.combat;var rope=p.fixed_rope
	lab.started=true;lab.set_paused(false);p.testing_input=true;lab.arena.powerups.testing=true
	lab.box(Vector3(0,59.5,0),Vector3(110,1,110),lab.INK)
	await frames(3)
	# Ten seconds of free orbit must not bleed tangent speed at either tick rate.
	var outcomes:Array[Vector3]=[]
	for rate in [60,120]:
		var offset:=Vector3(10,0,0);var v:=Vector3(0,0,30)
		for i in rate*10:
			var result:Dictionary=rope.integrate(offset,v,10,1.0/rate)
			offset=result.offset;v=result.velocity
		check(absf(v.length()-30)<0.03 and absf(offset.length()-10)<0.001,"fixed orbit retains radius and tangent speed for ten seconds at "+str(rate)+" Hz")
		outcomes.append(offset)
	check(outcomes[0].distance_to(outcomes[1])<0.03,"fixed orbit is consistent across 60 and 120 Hz")
	var pendulum:=Vector3(10,0,0);var falling:=Vector3.ZERO
	var fastest:=0.0
	for i in 240:
		falling.y-=24.0/120
		var result:Dictionary=rope.integrate(pendulum,falling,10,1.0/120)
		pendulum=result.offset;falling=result.velocity;fastest=maxf(fastest,absf(falling.x))
	check(fastest>18 and fastest<23,"falling beside a high anchor becomes horizontal speed below it without an extra impulse")
	print("PENDULUM MAX HORIZONTAL ",fastest)
	var slack:Dictionary=rope.integrate(Vector3(2,0,0),Vector3(-2,0,0),10,0.1)
	check(not slack.taut and slack.offset.distance_to(Vector3(1.8,0,0))<0.001,"slack fixed rope never pushes away from the anchor")
	var radial:Dictionary=rope.integrate(Vector3(10,0,0),Vector3(20,0,0),10,0.01)
	check(radial.velocity.length()<0.01,"pure outward velocity is stopped rather than converted into a free sideways boost")
	p.fixed_mode=true;p.reset_to(Vector3(0,70,0));p.set_physics_process(false)
	var initial:Vector3=p.position;latch(p,0,Vector3(0,84,0))
	check(absf(p.hands[0].rest-12.85)<0.01 and p.position==initial,"distant attachment captures current distance without a 5 m snap")
	latch(p,1,Vector3(3,84,0));rope.tick(p,0.29)
	check(p.hands[0].state==2 and p.hands[1].state==2,"successful grip handover briefly overlaps")
	rope.tick(p,0.02)
	check(p.hands[0].state==0 and p.hands[1].state==2,"old hand releases within 0.3 seconds of replacement grip")
	p.hands[0].state=1;p.hands[0].hit=false;p.hands[0].age=10;p.hands[0].from=p.position;p.hands[0].point=p.position
	p.update_hands(0.01);rope.tick(p,0.4)
	check(p.hands[1].state==2,"missed replacement leaves existing ceiling grip attached")
	var attacks:int=c.attacks
	p.clear_mouse_chord();p.handle_glove_button(0,true,1000);p.handle_glove_button(1,true,1050)
	check(not p.has_anchor() and not c.charging and c.attacks==attacks,"chord with pre-existing extended hands recalls both without punching")
	p.handle_glove_button(0,false,1100);p.handle_glove_button(1,false,1110)
	p.handle_glove_button(1,true,2000);p.handle_glove_button(0,true,2050)
	check(c.charging,"next idle-hands chord charges normally after a recall chord")
	p.reset_to(Vector3(0,70,0));p.velocity=Vector3(20,0,0);latch(p,0,Vector3(0,84,0))
	p.launch()
	check(not p.has_anchor() and p.velocity==Vector3(20,0,0),"E releases fixed rope while preserving earned velocity")
	p.reset_to(Vector3(0,70,0));latch(p,0,Vector3(0,84,0));p.gravity=0
	p.hands[0].spool_target=p.hands[0].rest
	p.velocity=Vector3(18,0,0);p.set_physics_process(true)
	await frames(120)
	check(absf(p.velocity.length()-18)<0.05 and absf(p.chest().distance_to(p.hands[0].point)-p.hands[0].rest)<0.02,"real CharacterBody controller preserves a one-second collision-free orbit")
	p.reset_to(Vector3(0,70,0));latch(p,0,Vector3(0,84,0));p.action_override={}
	await frames(60)
	check(p.position.y>74 and p.hands[0].rest<8,"automatic fixed winch lifts the body without any reel input")
	p.action_override={};p.launch()
	check(p.velocity.y>10 and p.velocity.y<=14.1,"releasing automatic pull retains its current upward motion")
	p.action_override={};p.reset_to(Vector3(0,70,0));latch(p,0,Vector3(0,84,0))
	var blocker=lab.box(Vector3(0,75,0),Vector3(12,0.5,12),lab.INK)
	p.action_override={};await frames(160)
	check(p.position.y<73.25 and p.position.y>72.5,"fixed reel stops the body at a solid ceiling instead of teleporting through")
	check(p.hands[0].rest>=p.chest().distance_to(p.hands[0].point)-0.02,"blocked reeling cannot wind rope through solid geometry")
	blocker.queue_free();await frames(2)
	# Let the automatic motor finish: it should settle instead of flinging into the ceiling.
	p.reset_to(Vector3(0,70,0));p.action_override={};latch(p,0,Vector3(0,84,0))
	await frames(240)
	check(absf(p.hands[0].rest-5)<0.01 and absf(p.chest().distance_to(p.hands[0].point)-5)<0.02 and p.velocity.length()<0.02,"automatic shortening settles at five metres without overshoot or continuing drift")
	p.adjust_length(-3);p.action_override={"reel":true};await frames(30)
	check(p.hands[0].spool_target==5 and not p.reeling,"fixed traversal needs no length management; manual reel remains elastic-only")
	p.action_override={};p.gravity=24
	var ceiling=lab.box(Vector3(0,85,0),Vector3(100,0.4,30),lab.INK)
	await frames(2)
	p.reset_to(Vector3(0,78.65,0));p.camera.position.y=1.58
	var start:Vector3=p.position
	var attached_clicks:=0
	var minimum_y:float=p.position.y
	for step in 6:
		p.camera.look_at(Vector3(p.position.x+6,84.8,0))
		p.handle_glove_button(step%2,true,5000+step*500)
		p.handle_glove_button(step%2,false,5030+step*500)
		for tick in 45:
			await frames(1);minimum_y=minf(minimum_y,p.position.y)
		if p.hands[step%2].state==2: attached_clicks+=1
	print("CEILING CLICK METRICS distance=",p.position.x-start.x," attached=",attached_clicks," min_y=",minimum_y," speed=",p.velocity.length())
	check(attached_clicks==6,"six alternating mouse clicks all attach, including rapid hand reuse")
	check(p.position.x-start.x>12 and minimum_y>77,"alternating clicks alone traverse over twelve metres of ceiling without movement or reel keys")
	check(not c.charging and not p.reeling,"alternating traversal never accidentally punches or needs manual reel")
	ceiling.queue_free();p.fixed_mode=false;p.reset_to(Vector3(0,60.05,0))
	await frames(10);p.action_override={"anchor":true};await frames(3)
	var anchored:Vector3=p.position
	check(p.anchored and p.crouched and not p.receive_punch(Vector3(30,15,0),1),"ground anchor crouches and rejects incoming knockback")
	p.input_override=Vector2(1,0);p.request_jump();await frames(15)
	check(p.position.distance_to(anchored)<0.01,"anchored body ignores walking and jumping until released")
	var pad:Dictionary=lab.arena.travel.launch_pads[0]
	p.reset_to(pad.pos+Vector3.UP*0.05);p.action_override={"anchor":true};p.input_override=Vector2.ZERO
	await frames(10)
	check(not p.flying and p.velocity.length()<0.1,"holding anchor also suppresses automatic launch pads")
	p.reset_to(Vector3(0,60.05,0));await frames(8)
	p.action_override={};p.input_override=Vector2.ZERO;await frames(2)
	p.receive_punch(Vector3(20,12,0),1);await frames(2)
	check(p.velocity.x>19 and p.velocity.y>10,"unanchored recipient adds punch velocity for a teammate boost")
	p.reset_to(Vector3(0,70,0));p.velocity=Vector3(20,12,0);p.action_override={"anchor":true};await frames(3)
	check(p.velocity.x==0 and p.velocity.z==0 and p.velocity.y< -8,"airborne anchor cancels lateral speed and drops quickly")
	p.action_override={};p.reset_to(Vector3(0,60.05,0));await frames(10)
	var dummy=load("res://scripts/target_dummy.gd").new();dummy.lab=lab;dummy.position=Vector3(0,60,-2.7);lab.add_child(dummy)
	await frames(3);p.camera.rotation=Vector3.ZERO;p.camera.position.y=1.58
	c.begin(1);await frames(20)
	check(dummy.hits_received==1 and dummy.velocity.z< -20 and p.velocity.z>15,"nearby target punch separates both bodies with one recipient impulse")
	check(not dummy.has_method("take_damage"),"dummy exposes nonlethal knockback rather than a hidden damage path")
	p.reset_to(Vector3(0,70,0));p.set_physics_process(false);p.set_ball(true);p.third_person=true
	c.start_charge();c.charge_time=1.1;p._process(0.016)
	check(p.avatar.shoulder_position(0).distance_to(p.position+Vector3.UP*0.32)<0.3,"ball arms attach to low shell sockets instead of hidden standing shoulders")
	check(p.hands[0].fist.position.y-p.position.y<0.7,"third-person ball charge fists stay close to its body")
	p.velocity=Vector3(30,0,0);p.camera_motion=true
	for i in 120: p._process(1.0/120)
	check(p.camera.fov>87 and p.camera.fov<89.1,"speed FOV remains a restrained five-degree maximum")
	var fist_before:Vector3=p.hands[0].fist.position
	p._process(0.013)
	check(p.hands[0].fist.position.distance_to(fist_before)>0.001,"fully capped charge still animates subtle hand vibration")
	p.camera_motion=false
	for i in 120: p._process(1.0/120)
	check(absf(p.camera.fov-84)<0.05,"comfort toggle restores constant FOV")
	for i in 30: p.movement_fx.emit_ghost()
	check(p.movement_fx.ghosts.size()==6,"afterimages reuse a six-instance pool")
	p.camera.current=true;p.third_person=false
	p.movement_fx._process(0.001)
	check(p.movement_fx.ghosts[0].mat.albedo_color.a<0.001,"afterimages fade away inside the first-person near field")
	p.movement_fx.clear_history()
	check(p.movement_fx.ghosts[0].life==0 and not p.movement_fx.ghosts[0].root.visible,"reset clears local afterimage history")
	for i in 35: p.movement_fx.stamp(Vector3(0,61,0),Vector3.UP,Color.CYAN,1)
	check(p.movement_fx.marks.size()==24,"surface marks have a strict bounded lifetime pool")
	for station in lab.arena.powerups.stations:
		check(station.period==30,"power station replenishes 30 seconds after collection: "+station.kind)
	var old_config:=ConfigFile.new()
	old_config.set_value("keys","jump",KEY_C);old_config.set_value("keys","cling",KEY_SHIFT)
	lab.controls.restore_bindings(old_config)
	check(lab.controls.keys.jump==KEY_C and lab.controls.keys.cling!=KEY_C and lab.controls.keys.anchor==KEY_SHIFT,"legacy custom key survives migration even when it occupies the new wall-grip default")
	check(lab.controls.keys.values().size()==Array(lab.controls.keys.values().reduce(func(acc, key): acc[key]=true;return acc,{}).keys()).size(),"migrated bindings remain unique")
	lab.controls.reset_bindings(false)
	check(lab.controls.keys.anchor==KEY_SHIFT and lab.controls.keys.cling==KEY_C and lab.controls.keys.arm_mode==KEY_1,"default bindings expose Shift anchor, C grip and 1 fixed mode")
	print("FIXED AND FIVER RESULT: ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
