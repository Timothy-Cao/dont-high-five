extends Node
var checks:=0
var failures:=0
func check(ok:bool,message:String) -> void:
	checks+=1
	if not ok: failures+=1
	print(("PASS  " if ok else "FAIL  ")+message)
func frames(n:int) -> void:
	for i in n: await get_tree().physics_frame
func clear(p:Node3D,pos:Vector3) -> bool:
	var shape:=CapsuleShape3D.new();shape.radius=0.36;shape.height=1.8
	var q:=PhysicsShapeQueryParameters3D.new();q.shape=shape;q.transform.origin=pos+Vector3.UP*0.95;q.collision_mask=1
	return p.get_world_3d().direct_space_state.intersect_shape(q,1).is_empty()
func cover(p:Node3D,samples:Array[Vector3]) -> Dictionary:
	var total:=0.0;var near:=0
	for point in samples:
		var closest:=40.0
		for i in 12:
			var dir:=Vector3(cos(i*TAU/12),0,sin(i*TAU/12))
			var hit:Dictionary=p.ray(point,point+dir*40)
			if not hit.is_empty(): closest=minf(closest,point.distance_to(hit.position))
		total+=closest
		if closest<=10: near+=1
	return {"samples":samples.size(),"mean_nearest_wall_m":total/maxi(1,samples.size()),"cover_within_10m":float(near)/maxi(1,samples.size())}
func run(lab:Node3D) -> void:
	var p=lab.player;var a=lab.arena;var district=a.districts
	lab.started=true;lab.set_paused(false);p.testing_input=true;p.set_physics_process(false);a.powerups.testing=true
	await frames(5)
	for route in district.routes:
		p.reset_to(route.from)
		check(clear(p,route.from) and not p.test_move(p.transform,route.to-route.from),route.name+" admits a standing body at "+str(route.from))
	for pos in district.perches:
		var hit:Dictionary=p.ray(pos+Vector3.UP*0.2,pos-Vector3.UP*0.3)
		check(clear(p,pos+Vector3.UP*0.05) and not hit.is_empty() and hit.normal.y>0.9,"new perch has floor and headroom: "+str(pos))
	# Same clear, supported points before/after: this measures usable cover, not object count.
	var samples:Array[Vector3]=[]
	for y in [0.05,20.05]:
		for x in range(-140,141,8):
			for z in range(-108,109,8):
				var pos:=Vector3(x,y,z)
				if not clear(p,pos): continue
				var floor_hit:Dictionary=p.ray(pos+Vector3.UP*0.2,pos-Vector3.UP*0.3)
				if not floor_hit.is_empty(): samples.append(pos+Vector3.UP*1.25)
	var after:=cover(p,samples)
	for i in range(district.first_shape,district.last_shape): a.solid.get_child(i).set_deferred("disabled",true)
	await frames(3)
	var before:=cover(p,samples)
	for i in range(district.first_shape,district.last_shape): a.solid.get_child(i).set_deferred("disabled",false)
	await frames(3)
	print("DENSITY BEFORE ",JSON.stringify(before));print("DENSITY AFTER ",JSON.stringify(after))
	check(samples.size()>1000,"cover audit samples both supported main floors")
	check(after.mean_nearest_wall_m<before.mean_nearest_wall_m*0.90,"infill reduces distance to usable nearby cover by at least ten percent")
	check(after.cover_within_10m>before.cover_within_10m+0.04,"at least four percent more sampled space has cover within ten meters")
	# Full-height flight shafts remain clear; no infill seals the principal atrium void.
	check(p.ray(Vector3(0,5,15),Vector3(0,32,15)).is_empty(),"central vertical flight lane remains open")
	var r=a.rave;var distributed:=true;var clipped:=true
	r.update_installation()
	for i in r.emitters.size():
		if absf(r.emitters[i].x)<80: distributed=false
		if not p.ray(r.emitters[i],r.beam_ends[i]-(r.beam_ends[i]-r.emitters[i]).normalized()*0.05).is_empty(): clipped=false
	check(distributed and r.beams.size()==20,"four laser fans occupy outer halls instead of crowding the center")
	check(clipped,"laser segments stop at the nearest solid architecture")
	var file:=FileAccess.open("res://.local/reports/density.json",FileAccess.WRITE)
	file.store_string(JSON.stringify({"before":before,"after":after,"checks":checks,"failures":failures,"added_shapes":district.last_shape-district.first_shape},"  "));file.close()
	print("DENSITY RESULT: ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
