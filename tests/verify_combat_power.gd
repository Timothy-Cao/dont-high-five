extends Node
var checks:=0
var failures:=0
func check(ok: bool,message: String) -> void:
	checks+=1
	if not ok: failures+=1
	print(("PASS  " if ok else "FAIL  ")+message)
func frames(n: int) -> void:
	for i in n: await get_tree().physics_frame
func run(lab:Node3D) -> void:
	var p=lab.player
	var a=lab.arena
	var powers=a.powerups
	var c=p.combat
	lab.started=true;lab.set_paused(false);p.testing_input=true
	powers.testing=true
	await frames(5)
	check(not p.has_method("begin_zip"),"quick zip is removed from the controller")
	check(not a.has_method("trail"),"old decorative collectible trails are removed")
	check(lab.visibility_fill<0.2 and lab.environment.fog_density>0.015,"arena starts darker with stronger distance haze")
	check(exp(-lab.environment.fog_density*150)<0.1 and exp(-lab.environment.fog_density*25)>0.5,"haze strongly obscures half-map distance while preserving close range")
	p.reset_to(Vector3(-114,0.05,17));p.camera.position.y=1.58;p.camera.rotation=Vector3.ZERO
	await frames(8)
	var before:Vector3=p.position
	check(c.begin(1.0),"punch fires into open space without requiring a grapple target")
	var start_left:Vector3=p.hands[0].point;var start_right:Vector3=p.hands[1].point
	await frames(8)
	var left:Vector3=p.hands[0].point-start_left;var right:Vector3=p.hands[1].point-start_right
	check(left.normalized().dot(right.normalized())>0.99999,"fist projectiles travel on parallel paths")
	check(absf(p.hands[0].point.distance_to(p.hands[1].point)-0.74)<0.01,"parallel fists preserve muzzle separation")
	check(p.hands[0].fist.visible and not p.hands[0].glove.visible,"punch swaps the open hand mesh for the modeled fist")
	await frames(135)
	check(p.position.distance_to(before)<0.1 and p.velocity.length()<0.1,"punching forward cannot perform a free movement dash")
	check(not c.active and p.hand_recovery==0,"misses finish their travel and recover")
	# Nearby floor hit: one vertical hop, no compounded impulse from the second fist.
	p.reset_to(Vector3(-114,0.05,17));p.camera.position.y=1.58
	await frames(8);p.camera.look_at(p.position+Vector3(0,0,-1))
	p.velocity=Vector3(6,0,3)
	c.begin(1.0)
	var initial_y:float=p.position.y;var apex:=initial_y;var peak_v:=0.0
	for tick in 150:
		await frames(1);apex=maxf(apex,p.position.y);peak_v=maxf(peak_v,p.velocity.y)
	print("GROUND BLAST METRICS hopped=",c.hopped," peak=",peak_v," apex=",apex-initial_y," impulse=",c.recoil_applied," velocity=",p.velocity," pos=",p.position)
	check(c.hopped and peak_v>22 and peak_v<24.5,"two floor contacts apply exactly one bounded ground-hop impulse")
	check(apex-initial_y>=10 and apex-initial_y<12.5,"ground punch produces at least ten meters of charged lift")
	check(Vector2(p.velocity.x,p.velocity.z).length()>5.5,"ground punch preserves incoming horizontal momentum")
	# Attack real moving dummy geometry; paired fists award one additive impulse.
	var dummy=a.dummies[0]
	dummy.reset_target()
	p.reset_to(dummy.position+Vector3(0,0.05,7));p.camera.position.y=1.58
	await frames(8);p.camera.look_at(dummy.position+Vector3.UP*1.85)
	var target_start:Vector3=dummy.position
	c.begin(1.0);await frames(65)
	check(dummy.hits_received==1 and dummy.knocked_out,"paired fists deliver one nonlethal recipient hit")
	check(dummy.position.distance_to(target_start)>3,"actual target body travels away from a charged punch")
	await frames(40)
	check(dummy.hits_received==1,"projectile recovery cannot repeat a target impulse")
	dummy.respawn=0.02;await frames(6)
	check(not dummy.knocked_out and dummy.position.distance_to(dummy.home)<0.1,"dummy recovers at its home without health or death")
	p.hand_recovery=0
	var wall=lab.box(dummy.position+Vector3(0,1.6,3),Vector3(4,4,0.3),lab.INK)
	await frames(2);c.begin(1.0);await frames(65)
	check(dummy.hits_received==1,"solid cover stops fist knockback before the dummy")
	wall.queue_free();await frames(2)
	p.reset_to(dummy.position+Vector3(0,0.05,7));p.camera.position.y=1.58
	p.camera.look_at(dummy.position+Vector3.UP*1.85);p.grant_buff("overdrive",20)
	c.begin(1.0);await frames(90)
	check(dummy.hits_received==2 and dummy.last_impulse.length()>30,"Overdrive increases knockback, never introduces damage")
	# Stat bonuses are temporary, bounded, and never multiply with repeated pickups.
	p.reset_to(Vector3(-114,0.05,17));p.rotation.y=0
	p.grant_buff("speed",8);p.grant_buff("speed",8)
	check(is_equal_approx(p.speed_multiplier(),1.3),"repeated speed pickups refresh duration without multiplying speed")
	p.input_override=Vector2(0,-1);await frames(60)
	check(absf(p.velocity.z+4.55)<0.1,"speed pickup changes actual walking speed from 3.5 to 4.55 m/s")
	p.input_override=Vector2.ZERO;p.grant_buff("overdrive",20)
	check(p.hand_range()>38 and p.pull_multiplier()>1.6 and p.speed_multiplier()>1.4 and p.vision_multiplier()>1.7,"central Overdrive raises all four stats above corner bonuses")
	p.grant_buff("speed",8)
	check(is_equal_approx(p.speed_multiplier(),1.45),"a weak pickup does not downgrade Overdrive")
	p.buffs["overdrive"]=0.01;p.tick_buffs(0.02)
	check(not p.buffs.has("overdrive") and is_equal_approx(p.speed_multiplier(),1.3),"Overdrive expiry exposes the independently timed weaker bonus")
	p.tick_buffs(30)
	check(p.buffs.is_empty() and p.speed_multiplier()==1 and p.hand_range()==25.5,"expired boosts restore base stats")
	p.grant_buff("vision",18);await frames(3)
	check(lab.environment.fog_density<0.012 and p.hands[0].lamp.omni_range>20,"vision boost reduces haze and extends actual glove illumination")
	p.reset_to(Vector3(-114,0.05,17));await frames(3)
	check(is_equal_approx(lab.environment.fog_density,0.018),"reset clears the vision bonus and restores baseline haze")
	# Longer arm buff affects actual hits, while expiry preserves existing anchors.
	var reach_wall=lab.box(Vector3(-114,8,-16),Vector3(8,16,0.5),lab.INK)
	p.camera.position.y=1.58;p.camera.rotation=Vector3.ZERO
	await frames(2);p.fire_hand(0);await frames(65)
	check(not p.has_anchor(),"unboosted glove cannot hit a surface 33 m away")
	p.grant_buff("overdrive",20);p.fire_hand(0);await frames(70)
	check(p.has_anchor(),"range boost lets a real glove attach beyond the normal reach")
	p.buffs.clear();await frames(3)
	check(p.has_anchor(),"range expiry does not abruptly detach an existing glove")
	p.grant_buff("pull",18);p.action_override={"reel":true}
	await frames(60)
	check(Vector2(p.velocity.x,p.velocity.z).length()>17,"pull bonus increases actual sustained grapple speed")
	p.action_override={};p.cancel_hands();reach_wall.queue_free()
	# Timed generators and sparse random spawns.
	check(powers.stations.size()==5 and powers.stations[0].kind=="overdrive","one central and four corner power generators exist")
	check(powers.candidates.size()>100,"random boosts have many collision-validated locations on the two floors")
	for station in powers.stations: station.timer=0.1;station.available=false
	powers.tick(0.11)
	var ready:=true
	for station in powers.stations: ready=ready and station.available and station.token.visible
	check(ready,"stations produce visible pickups when their countdown completes")
	p.set_physics_process(false);a.set_physics_process(false)
	var center:Vector3=powers.stations[0].pos+Vector3.UP*1.65
	p.buffs.clear();powers.collect(center-Vector3.RIGHT*2,center+Vector3.RIGHT*2)
	check(p.buffs.has("overdrive") and not powers.stations[0].available,"swept center collection grants Overdrive and starts recharge")
	var collected:int=powers.pickups;powers.collect(center,center)
	check(powers.pickups==collected,"a consumed station cannot grant twice")
	powers.tick(1)
	check(not powers.stations[0].available,"station stays empty until its interval has elapsed")
	powers.stations[0].timer=0.1;powers.tick(0.11)
	check(powers.stations[0].available,"central station generates again after recharge")
	for i in 40: powers.spawn_mote()
	check(powers.motes.size()==8,"random temporary speed pickups obey a strict sparse cap of eight")
	var mote:Dictionary=powers.motes[0];p.buffs.clear()
	powers.collect(mote.pos-Vector3.RIGHT*1.5,mote.pos+Vector3.RIGHT*1.5)
	check(p.buffs.has("speed") and powers.motes.size()==7,"random speed pickup is collected by a fast crossing and grants its effect")
	var shield=lab.box(Vector3(-115,2,17.5),Vector3(3,4,0.2),lab.INK)
	powers.motes[0].pos=Vector3(-115,1.15,18)
	await frames(2)
	var mote_count:int=powers.motes.size()
	powers.collect(Vector3(-115,1.15,17.1),Vector3(-115,1.15,17.1))
	check(powers.motes.size()==mote_count,"a nearby speed boost cannot be collected through a solid wall")
	shield.queue_free()
	var remaining:float=p.buffs.speed
	p.set_physics_process(true);lab.set_paused(true);await frames(15)
	check(is_equal_approx(p.buffs.speed,remaining),"pause freezes temporary bonuses")
	lab.set_paused(false);p.buffs.clear();a.set_physics_process(true)
	# Walk each entire gentle ramp with the real controller. No jump or grapple inputs.
	for z in [-85,85]:
		p.reset_to(Vector3(-136,0.05,z));p.rotation.y=0;p.camera.rotation=Vector3.ZERO
		p.input_override=Vector2(1,0)
		for tick in 4800:
			await frames(1)
			if p.position.x> -12: break
		print("RAMP END ",z," ",p.position)
		check(p.position.x> -12 and p.position.y>19.8 and p.is_on_floor(),"entire broad ramp reaches the second main floor: "+str(z))
	p.input_override=Vector2.ZERO
	print("COMBAT POWER RESULT: ",checks-failures,"/",checks)
	var file:=FileAccess.open("res://.local/reports/combat-power-metrics.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"checks":checks,"failures":failures,"ground_punch_apex":apex-initial_y,"pickup_candidates":powers.candidates.size(),"floor_height":20,"ceiling_height":44},"  "))
	get_tree().quit(1 if failures else 0)
