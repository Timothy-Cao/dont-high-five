extends RefCounted
## Deliberately fallible local opponent. Snapshot aim never predicts player velocity.
var watcher:Node3D
var elapsed:=0.0
var states:Array[Dictionary]=[]
var grenades_fired:=0
var strikes_fired:=0
const AIM_DELAY:=0.6
func update(dt:float) -> void:
	elapsed+=dt
	while states.size()<watcher.towers.size():
		var i:=states.size()
		states.append({"history":[],"sample":0.0,"gun":0.0,"grenade":0.4+i*0.19,"strike":1.0+i*0.63,"target":null,"aim":Vector3.ZERO,"ready":false,"sniper":i%2==0,"demo_grenade":4.0+i*1.7,"demo_strike":12.0+i*3.1,"beam":null})
	for i in states.size():
		var state:Dictionary=states[i];var tower:Dictionary=watcher.towers[i]
		if is_instance_valid(state.beam):state.beam.hide()
		if watcher.demo_patrol and not watcher.auto_fire and tower.blind<=0 and not (watcher.active and i==watcher.selected):
			demo_step(i,state,tower,dt)
		if tower.blind>0 or not watcher.auto_fire or (watcher.active and i==watcher.selected):
			state.history.clear();state.ready=false;state.target=null;continue
		if not is_instance_valid(state.target):state.target=null;state.ready=false;state.history.clear()
		for key in ["sample","gun","grenade","strike"]:state[key]=maxf(0,state[key]-dt)
		if state.sample<=0:
			state.sample=0.15
			var target:Node3D=null
			for candidate in watcher.targets():
				var center:Vector3=candidate.global_position+Vector3.UP
				if tower.pos.distance_to(center)<160 and watcher.clear_line(tower.pos,center,candidate):target=candidate;break
			if target!=state.target:
				state.history.clear();state.ready=false;state.target=target
			if is_instance_valid(target):
				state.history.append({"time":elapsed,"pos":target.global_position+Vector3.UP})
				if state.sniper:
					var endpoint:Vector3=state.aim if state.ready else target.global_position+Vector3.UP
					watcher.add_effect(watcher.P.beam(watcher,tower.pos,endpoint,Color("ff204b"),0.035),0.16)
			else:state.ready=false
		while not state.history.is_empty() and elapsed-state.history[0].time>=AIM_DELAY:
			state.aim=state.history.pop_front().pos;state.ready=true
		if not state.ready or not is_instance_valid(state.target):continue
		var direction:Vector3=(state.aim-tower.pos).normalized()
		if direction.length_squared()<0.5:continue
		tower.rig.look_at(state.aim)
		# MG has a readable burst/rest rhythm, but uses the real 30 rounds/sec rate.
		var burst:bool=fposmod(elapsed+i*0.27,1.4)<0.6
		if state.gun<=0 and (state.sniper or burst):
			watcher.fire(tower.pos,direction,55 if state.sniper else 8,0.004 if state.sniper else watcher.MG_SPREAD)
			state.gun=watcher.SNIPER_INTERVAL if state.sniper else watcher.MG_INTERVAL
		if state.grenade<=0:
			var flight:=clampf(tower.pos.distance_to(state.aim)/30.0,0.7,3.0)
			var start:Vector3=tower.pos+direction*2
			watcher.launch_grenade(start,(state.aim-start)/flight+Vector3.UP*8*flight)
			grenades_fired+=1;state.grenade=watcher.GRENADE_INTERVAL+watcher.rng.randf_range(0,0.25)
		if state.strike<=0:
			var mark:Vector3=state.aim+Vector3(watcher.rng.randf_range(-3,3),0,watcher.rng.randf_range(-3,3))
			var hit:=watcher.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(mark,mark+Vector3.DOWN*80,1))
			if not hit.is_empty():watcher.mark_strike(hit.position+Vector3.UP*0.12);strikes_fired+=1
			state.strike=watcher.STRIKE_INTERVAL+watcher.rng.randf_range(0,0.6)


func demo_step(index:int,state:Dictionary,tower:Dictionary,dt:float) -> void:
	# Slow patrol across inward-facing walls. Rays stop on real cover.
	var yaw:float=atan2(tower.pos.x,tower.pos.z)+sin(elapsed*0.17+index*1.7)*0.95
	var pitch:float=-0.22+sin(elapsed*0.11+index)*0.16
	var direction:=Basis.from_euler(Vector3(pitch,yaw,0))*Vector3.FORWARD
	var end:Vector3=tower.pos+direction*220
	var hit:=watcher.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(tower.pos,end,1))
	if not hit.is_empty():end=hit.position
	tower.rig.look_at(end)
	var start:Vector3=tower.pos+direction*1.3
	if not is_instance_valid(state.beam):
		state.beam=watcher.P.beam(watcher,start,end,Color("ff2440"),0.028)
		state.beam.set_meta("blackout_exempt",true)
		state.beam.material_override.emission_energy_multiplier=3
	var beam:MeshInstance3D=state.beam
	beam.show();beam.position=(start+end)/2;beam.mesh.height=maxf(.01,start.distance_to(end))
	var up:Vector3=(end-start).normalized();var right:=up.cross(Vector3.FORWARD).normalized()
	if right.length()<.5:right=Vector3.RIGHT
	beam.basis=Basis(right,up,right.cross(up)).orthonormalized()
	state.demo_grenade-=dt;state.demo_strike-=dt
	if state.demo_grenade<=0:
		watcher.launch_grenade(start,direction*24+Vector3.UP*5);grenades_fired+=1
		state.demo_grenade=watcher.rng.randf_range(14,24)
	if state.demo_strike<=0:
		var mark:Vector3=tower.pos+direction*watcher.rng.randf_range(12,55)
		var floor_hit:=watcher.get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(mark,mark+Vector3.DOWN*80,1))
		if not floor_hit.is_empty():watcher.mark_strike(floor_hit.position+Vector3.UP*.12);strikes_fired+=1
		state.demo_strike=watcher.rng.randf_range(28,45)
