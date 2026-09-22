extends Node
var checks:=0
var failures:=0
func check(ok:bool,message:String) -> void:
	checks+=1
	if not ok:failures+=1
	print(("PASS  " if ok else "FAIL  ")+message)
func frames(n:int) -> void:
	for i in n:await get_tree().physics_frame
func clear(p:CharacterBody3D,pos:Vector3) -> bool:
	var q:=PhysicsShapeQueryParameters3D.new();var shape:=CapsuleShape3D.new();shape.radius=0.36;shape.height=1.8
	q.shape=shape;q.transform.origin=pos+Vector3.UP*0.95;q.collision_mask=1
	return p.get_world_3d().direct_space_state.intersect_shape(q,1).is_empty()
func run(lab:Node3D) -> void:
	var p=lab.player;var s=lab.session;var w=s.watcher;var o=s.objectives;var t=s.training
	lab.started=true;lab.set_paused(false);p.testing_input=true;lab.arena.powerups.testing=true
	await frames(5)
	check(w.towers.size()==7 and not w.auto_fire,"seven towers exist; unattended auto-fire defaults off")
	check(lab.arena.maze_graphs.size()==1,"the arena contains exactly one generated maze")
	check(s.layout.get_child_count()==14,"scene-native placement handles expose eyes and tasks")
	p.set_physics_process(false);p.reset_to(Vector3(-110,0.05,-22));p.camera.position.y=1.58
	var cargo=o.cargos[0]
	cargo.reset_cargo();p.camera.look_at(cargo.position);p.fire_hand(0);p.update_hands(0.5)
	check(p.has_cargo() and p.hands[0].state==4,"a real glove ray picks up the cargo and occupies one hand")
	check(not p.combat.start_charge() and not p.zip.begin(),"carrying rejects both two-handed attacks")
	p.camera.look_at(p.chest()+Vector3(0,20,1));p.fire_hand(1)
	check(p.hands[1].state==1 and p.has_cargo(),"the free hand can still shoot a traversal grip")
	await frames(20)
	check(cargo.position.distance_to(p.chest())<3,"physical cargo approaches the carrier through collision sweeps")
	p.cancel_hands();check(p.has_cargo(),"ordinary recall preserves the occupied cargo hand")
	p.fire_hand(0);check(not p.has_cargo() and cargo.collision_layer==4,"clicking the occupied hand releases cargo and restores collision")
	cargo.position=o.delivery_pos+Vector3.UP*0.5;await frames(2)
	check(o.delivered and o.progress()==1,"delivery awards one task")
	await frames(5);check(o.progress()==1,"parked cargo cannot repeatedly award progress")
	o.reset_tasks();p.reset_to(o.social_pos+Vector3(0,0.05,3));p.health=35
	var partner=o.partners[0];partner.health=20;partner.highfive_cd=0;partner.position=partner.home
	p.camera.look_at(partner.position+Vector3.UP);p.fire_hand(0);p.update_hands(0.5);await frames(30)
	check(p.health==100 and partner.health==100 and o.highfive_done,"reciprocal local palm interaction heals both and completes its task")
	partner.highfive_cd=0;p.health=40;partner.hand_touch(p,0);p.cancel_hands();await frames(30)
	check(p.health==40,"recalling cancels an unconfirmed high five")
	p.action_override={"anchor":true};p.health=100;p.take_damage(20)
	check(p.health==90 and not p.receive_punch(Vector3(30,0,0),1),"anchoring halves damage and rejects knockback")
	p.action_override={};p.take_damage(20);check(p.health==70,"unanchored damage remains ordinary")
	p.grant_buff("toughness",1);p.take_damage(20);check(p.health==60,"temporary toughness halves incoming damage")
	p.buffs.clear();p.take_damage(200);check(p.respawn_left==3 and p.collision_layer==0,"lethal damage starts a three-second safe respawn")
	p.set_physics_process(true);await frames(365)
	check(p.health==100 and p.collision_layer==2 and p.respawn_left==0,"respawn restores a living body at the checkpoint")
	p.set_physics_process(false);p.reset_to(Vector3(-114,0.05,17));p.camera.rotation=Vector3.ZERO
	p.grant_buff("charge",3);p.combat.start_charge();p.combat.tick(0.55)
	check(p.combat.charge_fraction()==1,"charge-rate bonus halves the full charge time")
	p.cancel_hands();p.buffs.clear();p.grant_buff("max_charge",3);p.combat.start_charge()
	check(p.combat.charge_fraction()==1,"max-charge bonus produces a full tap")
	p.cancel_hands();p.buffs.clear();p.grant_buff("invisible",1)
	check(p not in w.targets(),"invisibility excludes the Fiver from automatic acquisition")
	p.tick_buffs(2);check(p in w.targets(),"invisibility expires without permanent immunity")
	p.equipment_disabled=true;p.grant_buff("insulation",1)
	check(not p.arms_suppressed(),"insulation resists future equipment disablement")
	p.buffs.clear();p.equipment_disabled=false
	# Parallel zip has no open-air thrust and preserves existing transverse momentum.
	p.reset_to(Vector3(0,60,0));p.camera.rotation=Vector3.ZERO
	check(not p.zip.begin(),"parallel zip rejects empty space")
	var wall=load("res://scripts/gameplay/props.gd").box(lab,Vector3(0,61,-10),Vector3(8,6,0.5),Color.GRAY)
	await frames(3);p.velocity=Vector3(10,0,0)
	check(p.zip.begin(),"two parallel grips start a surface zip")
	p.zip.tick(0.1)
	check(p.velocity.x>9.99 and p.velocity.z< -3,"zip adds forward pull without deleting transverse momentum")
	p.reset_to(Vector3(-114,0.05,17));check(not p.zip.active and p.hand_recovery==0,"reset cancels zip and leaves hands ready")
	wall.queue_free();await frames(2)
	var original:Vector3=p.position;w.enter()
	check(w.active and w.camera.current and p.collision_layer==0,"role switch selects the Watcher camera and removes the frozen Fiver body")
	w.select(6);check(w.selected==6,"Watcher can choose the seventh eye")
	var point:Vector3=partner.position+Vector3.UP
	partner.health=100;w.fire(point+Vector3(0,0,3),Vector3.FORWARD,4)
	check(partner.health==96,"machine-gun ray actually damages an exposed local partner")
	var before:int=w.shots
	w.towers[6].eye.receive_punch(Vector3.UP,1);w.firing=true;await frames(3)
	check(w.towers[6].blind>0 and w.shots==before,"punching the current eye interrupts its fire")
	w.firing=false;w.towers[6].blind=0
	for i in 7:check(clear(p,w.infiltration_spawn(i)),"tower infiltration exit has standing clearance: "+str(i))
	# Exercise delayed strikes on a real collision target, including the warning interval.
	w.camera.position=partner.position+Vector3(0,6,6);w.camera.look_at(partner.position+Vector3.UP)
	check(w.strike() and w.strikes.size()==1,"area strike places a visible warning at a ray hit")
	var before_health:float=partner.health
	await frames(120);check(partner.health==before_health and not w.strikes.is_empty(),"strike leaves at least one second to escape")
	await frames(225);check(w.strikes.is_empty() and not w.fields.is_empty(),"delayed warning resolves into a sustained orbital field")
	await frames(580) # The field expires before unrelated partner/high-five checks.
	w.select(6)
	check(w.grenade() and not w.grenade(),"grenade creates once then respects its cooldown")
	var grenade_start:Vector3=w.bombs[0].pos;await frames(8)
	check(w.bombs[0].pos.distance_to(grenade_start)>0.5,"grenade integrates flight instead of remaining at its muzzle")
	var emissive:StandardMaterial3D
	for geometry in lab.arena.find_children("*","GeometryInstance3D",true,false):
		if geometry.material_override is StandardMaterial3D and geometry.material_override.emission_enabled:emissive=geometry.material_override;break
	var energy:float=emissive.emission_energy_multiplier
	w.cut_power();check(w.blackout>0 and emissive.emission_energy_multiplier<energy,"blackout dims real arena emissions")
	w.set_dark(false);w.blackout=0;check(is_equal_approx(emissive.emission_energy_multiplier,energy),"shared material energy restores exactly after blackout")
	w.leave();check(not w.active and p.position.distance_to(original)<0.1 and p.camera.current,"returning to Fiver restores its position and camera")
	p.reset_to(o.social_pos+Vector3(0,0.05,3));p.impostor=true;partner.highfive_cd=0;partner.health=100;partner.hand_touch(p,0);await frames(30)
	check(partner.respawn>0,"impostor's confirmed palm downs the local partner")
	p.impostor=false;s.reset_round()
	check(partner.respawn==0 and partner.collision_layer==16 and partner.health==100,"round reset restores dead partners as interactable bodies")
	o.reset_tasks();p.reset_to(o.maintenance_pos+Vector3(0,-1.15,2));p.camera.position.y=1.58
	for index in [0,2,1]:p.camera.look_at(o.maintenance_lamps[index].global_position);o.interact()
	check(o.maintenance_done,"aiming at the three indicated maintenance nodes completes calibration")
	# Infiltration returns to the chosen tower after the stationary fuse; auto-fire is opt-in.
	w.enter();w.select(1);w.infiltrate();p.velocity=Vector3.ZERO
	check(p.impostor and not w.active,"infiltration gives control of the robot")
	p.set_physics_process(true);await frames(35);p.set_physics_process(false)
	w.stationary=9.99;await frames(3)
	check(w.active and not p.impostor,"stationary impostor self-destruct returns control to its tower")
	w.leave();w.auto_fire=false
	for tower in w.towers:tower.clock=0;tower.pending=0
	before=w.shots;await frames(90);check(w.shots==before,"unattended towers remain quiet by default")
	# Put a local test target at a measured visible floor location.
	var visible_target:=Vector3.ZERO
	for candidate in lab.arena.powerups.candidates:
		if w.towers[1].pos.distance_to(candidate)<100 and p.ray(w.towers[1].pos,candidate).is_empty():visible_target=candidate;break
	partner.position=visible_target-Vector3.UP;partner.velocity=Vector3.ZERO;partner.set_physics_process(false);partner.health=100;partner.respawn=0;partner.collision_layer=16
	w.auto_fire=true;await frames(2)
	var warning_pending:=false
	for state in w.tower_ai.states:warning_pending=warning_pending or not state.history.is_empty()
	check(warning_pending and w.shots==before,"automatic acquisition warns before firing")
	await frames(100);check(w.shots>before,"opt-in auto-fire produces actual shots after the warning")
	w.auto_fire=false;partner.set_physics_process(true);partner.position=partner.home
	for kind in ["High five","Cargo","Rings","Maintenance","Dummies","Hazards"]:
		s.visit_task(kind);await frames(2);check(clear(p,p.position),"task shortcut has body clearance: "+kind)
	# Warning-timed hazards remain optional and anchor damage resistance applies.
	var h=s.hazards;p.reset_to(h.river_pos);p.health=100;h.hurt_clock=0;h.enabled=true;h._physics_process(0.01)
	check(p.health<100,"laser channel damages a grounded body")
	p.health=100;h.hurt_clock=0;h.enabled=false;h._physics_process(0.01)
	check(p.health==100,"disabled hazard gallery cannot damage the player")
	h.enabled=true
	p.set_physics_process(true);t.enter();await frames(4)
	check(t.active and t.built and p.position.y>99,"Training opens independently above the arena")
	for i in 9:
		t.choose(i);await frames(3)
		check(clear(p,p.position) and p.position.distance_to(t.origin()+Vector3(-14,0.05,0))<0.2,"training entry has standing clearance and stable floor: "+str(i))
	check(p.fixed_mode,"ceiling Training selects automatic fixed mode")
	p.position.y=t.origin().y-9;await frames(3)
	check(p.position.y>99,"falling out of a Training exercise returns to that room")
	t.leave();check(not t.active and p.position.y<99,"leaving Training returns to the arena")
	lab.set_paused(true)
	for page in ["Home","Training","Playtest","Tasks","Settings","Bindings"]:
		lab.hud.show_page(page);await frames(2)
		check(lab.hud.get_global_rect().encloses(lab.hud.menu.get_global_rect()),page+" menu fits the viewport")
	lab.set_paused(false);p.set_physics_process(false)
	await watcher_controls(lab)
	# Occlusion audit uses actual standing-clear floor samples, not a desired percentage.
	var visible:=0;var total:=0;var per_eye:Array[int]=[0,0,0,0,0,0,0]
	for sample in lab.arena.powerups.candidates:
		if not clear(p,sample-Vector3.UP*1.1):continue
		total+=1;var seen:=false
		for i in w.towers.size():
			var tower:Dictionary=w.towers[i]
			if tower.pos.distance_to(sample)<130 and p.ray(tower.pos,sample).is_empty():per_eye[i]+=1;seen=true
		if seen:visible+=1
	var coverage:={"floor_samples":total,"visible_any":visible,"union_fraction":float(visible)/maxi(1,total),"per_eye_counts":per_eye}
	print("WATCHER COVERAGE ",JSON.stringify(coverage))
	check(total>150,"coverage audit includes both main floors")
	check(visible>0 and visible<total,"tower sightlines include both exposure and real blind spots")
	for station in lab.arena.powerups.stations:
		var seen:=false
		for tower in w.towers:
			if tower.pos.distance_to(station.pos)<130 and p.ray(tower.pos,station.pos+Vector3.UP*2).is_empty():seen=true
		check(seen,"power station is exposed to at least one tower: "+station.kind)
	var file:=FileAccess.open("res://.local/reports/pilot.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"coverage":coverage},"  "));file.close()
	print("LOCAL PILOT RESULT: ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)

func mouse(button:int,pressed:bool) -> void:
	var event:=InputEventMouseButton.new();event.button_index=button;event.pressed=pressed;event.position=get_viewport().get_visible_rect().size/2
	get_viewport().push_input(event,true)
func key(code:int) -> void:
	var event:=InputEventKey.new();event.keycode=code;event.physical_keycode=code;event.pressed=true
	get_viewport().push_input(event,true)
func watcher_controls(lab:Node3D) -> void:
	var w=lab.session.watcher;var p=lab.player
	lab.set_paused(false);w.auto_fire=false;lab.session.objectives.reset_tasks();w.enter()
	for i in 7:
		key(KEY_1+i)
		check(w.selected==i,"real key input selects Watcher eye "+str(i+1))
		var hit:Dictionary=w.aim()
		check(w.camera.position.distance_to(hit.position)>8,"tower starting sightline clears its own support: "+str(i+1))
	var dummy=load("res://scripts/target_dummy.gd").new();dummy.lab=lab;dummy.position=Vector3(0,65,-12);lab.add_child(dummy);dummy.set_physics_process(false);lab.arena.dummies.append(dummy)
	w.camera.position=Vector3(0,66.5,0);w.camera.look_at(dummy.position+Vector3.UP*1.5)
	await frames(3)
	w.cooldowns.gun=0;w.scope=false
	var count:int=w.shots
	mouse(MOUSE_BUTTON_LEFT,true);mouse(MOUSE_BUTTON_LEFT,false)
	check(w.shots==count+1 and dummy.knocked_out,"a same-frame mouse tap fires and knocks down a real practice dummy")
	check(w.hit_confirm>0,"damageable hits create operator hit confirmation")
	await frames(2);check(not lab.session.objectives.dummy_done,"Watcher gun hits do not award the Fivers a punch task")
	dummy.reset_target();w.explode(dummy.position+Vector3(0,1,2),4,40)
	check(dummy.knocked_out,"Watcher area damage also reacts on practice dummies")
	await frames(15);count=w.shots;mouse(MOUSE_BUTTON_LEFT,true);await frames(120);mouse(MOUSE_BUTTON_LEFT,false)
	check(w.shots>=count+28 and w.shots<=count+32,"holding LMB produces sustained thirty-round-per-second machine-gun fire")
	count=w.shots;await frames(25);check(w.shots==count,"releasing LMB stops automatic fire")
	mouse(MOUSE_BUTTON_RIGHT,true);w.feedback.update_scope()
	check(w.scope and w.feedback.laser.visible,"actual RMB input enables the world-space aiming laser")
	check(w.feedback.endpoint.distance_to(w.aim().position)<0.1,"scoped laser terminates at the visible collision target")
	count=w.feedback.get_child_count();await frames(20)
	check(w.feedback.get_child_count()==count,"scoping reuses persistent effect nodes")
	w.cooldowns.gun=0;count=w.shots;mouse(MOUSE_BUTTON_LEFT,true);mouse(MOUSE_BUTTON_LEFT,false)
	check(w.shots==count+1 and is_equal_approx(w.cooldowns.gun,0.4),"scoped tap uses a 0.4-second sniper interval")
	await frames(30);mouse(MOUSE_BUTTON_LEFT,true);mouse(MOUSE_BUTTON_LEFT,false)
	check(w.shots==count+1,"sniper cannot fire again after only a quarter second")
	await frames(30);mouse(MOUSE_BUTTON_LEFT,true);mouse(MOUSE_BUTTON_LEFT,false)
	check(w.shots==count+2,"sniper can fire again after 0.4 seconds")
	mouse(MOUSE_BUTTON_RIGHT,false);w.feedback.update_scope();check(not w.feedback.laser.visible,"releasing scope removes its laser")
	w.cooldowns.grenade=0;key(KEY_Q);check(w.cooldowns.grenade==0.25 and not w.bombs.is_empty(),"Q throws grenade with quarter-second repeat delay")
	w.cooldowns.strike=0;key(KEY_W);check(w.cooldowns.strike==5 and not w.strikes.is_empty(),"W paints an orbital strike with five-second repeat delay")
	w.cooldowns.blackout=0;key(KEY_F7);check(w.cooldowns.blackout==0 and w.blackout>0,"F7 enables persistent blackout without a cooldown")
	check(lab.environment.ambient_light_energy==0 and lab.environment.fog_light_energy==0,"blackout removes ambient and fog illumination")
	var extinguished:=true
	for item in w.darkness.materials.values():extinguished=extinguished and not item.mat.emission_enabled and item.mat.shading_mode==BaseMaterial3D.SHADING_MODE_PER_PIXEL
	for item in w.darkness.lamps.values():
		if is_instance_valid(item.node):extinguished=extinguished and item.node.light_energy==0
	check(extinguished,"blackout extinguishes decorative emission, unlit outlines and non-hand lights")
	check(p.hands[0].lamp.light_energy>0 and p.hands[1].lamp.light_energy>0,"hand lamps retain real illumination during blackout")
	w.feedback.explosion(Vector3(0,65,0),7)
	var burst=w.feedback.bursts.back()
	check(w.darkness.exempt(burst) and burst.light.light_energy>0,"active blasts retain neon and local light during blackout")
	lab.set_paused(true);var burst_age:float=burst.age;await frames(5)
	check(burst.age==burst_age,"pause freezes explosion lifetime")
	lab.set_paused(false);await frames(180)
	check(not is_instance_valid(burst),"explosion retires itself after the short flash and debris tail")
	for i in 12:w.feedback.explosion(Vector3(0,65,0),7)
	check(w.feedback.bursts.size()<=8,"simultaneous large explosions have a bounded budget")
	key(KEY_F7);check(w.blackout==0 and not w.darkness.active,"second F7 press instantly restores lighting with no cooldown")
	key(KEY_F7);await frames(10);check(w.blackout==1,"blackout does not count down or automatically end")
	w.cooldowns.mine=0;key(KEY_E);check(w.cooldowns.mine==2 and not w.mines.is_empty(),"E throws a mine with a two-second cooldown")
	lab.set_paused(true);count=w.shots;mouse(MOUSE_BUTTON_LEFT,true);await frames(5)
	check(w.shots==count and not w.firing,"menu mouse clicks cannot shoot")
	lab.set_paused(false);w.blackout=0;w.set_dark(false)
	for tower in w.towers:tower.pending=0
	for effect in w.effects:effect.node.queue_free()
	w.effects.clear()
	for i in 70:w.add_effect(Node3D.new(),0.3)
	count=w.shots;w.fire(w.camera.position,Vector3.FORWARD,8)
	check(w.shots==count+1 and w.effects.size()<=64,"full cosmetic budget never prevents a real shot")
	for effect in w.effects:effect.node.queue_free()
	w.effects.clear()
	for kind in ["watcher_mg","watcher_sniper","watcher_blast"]:
		check(lab.audio_service.samples[kind].size()==4,"four distinct original audio variations load: "+kind)
	mouse(MOUSE_BUTTON_RIGHT,true);w.leave();w.feedback.update_scope()
	check(not w.feedback.laser.visible and not w.firing,"role exit clears scope and fire")
	lab.arena.dummies.erase(dummy);dummy.queue_free();await frames(2)
