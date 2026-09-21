extends Node3D
const COLORS={"reach":Color("65e3ce"),"pull":Color("efb75b"),"speed":Color("ef83c4"),"vision":Color("98a6ff"),"overdrive":Color("ffce79")}
var lab:Node3D
var stations:Array[Dictionary]=[]
var motes:Array[Dictionary]=[]
var candidates:Array[Vector3]=[]
var rng:=RandomNumberGenerator.new()
var spawn_clock:=9.0
var elapsed:=0.0
var pickups:=0
var testing:=false
func _ready() -> void:
	rng.randomize()
	add_station(Vector3(0,20,0),"overdrive",22,65)
	var kinds:=["reach","pull","speed","vision"]
	var positions:=[Vector3(-136,0,-101),Vector3(136,0,-101),Vector3(136,0,101),Vector3(-136,0,101)]
	for i in 4: add_station(positions[i],kinds[i],4+i*6,30+i*2)
	call_deferred("prepare_candidates")
func icon(kind: String,pos: Vector3,scale_size:=1.0) -> Node3D:
	var node:Node3D=load("res://assets/power_"+kind+".glb").instantiate()
	add_child(node);node.position=pos;node.scale=Vector3.ONE*scale_size
	return node
func add_station(pos: Vector3,kind: String,first: float,period: float) -> void:
	var base:Node3D=load("res://assets/power_station.glb").instantiate();add_child(base);base.position=pos
	var body:=StaticBody3D.new();base.add_child(body);body.set_meta("grippy",true)
	var col:=CollisionShape3D.new();var shape:=CylinderShape3D.new();shape.radius=0.94;shape.height=0.86
	col.shape=shape;col.position.y=0.43;body.add_child(col)
	var token:=icon(kind,pos+Vector3.UP*1.65,1.3 if kind=="overdrive" else 1.0);token.hide()
	var ring:=MeshInstance3D.new();var torus:=TorusMesh.new();torus.inner_radius=1.15;torus.outer_radius=1.20
	ring.mesh=torus;ring.material_override=lab.mat(COLORS[kind],0.65);add_child(ring);ring.position=pos+Vector3.UP*0.055
	var light:=OmniLight3D.new();add_child(light);light.position=pos+Vector3.UP*2.0
	light.light_color=COLORS[kind];light.light_energy=0.4;light.omni_range=6;light.light_cull_mask=1
	stations.append({"pos":pos,"kind":kind,"timer":first,"period":period,"available":false,"token":token,"light":light,"ring":ring})
func prepare_candidates() -> void:
	# Candidate locations are validated against both full-body clearance and a real floor.
	var body:=CapsuleShape3D.new();body.radius=0.45;body.height=1.8
	for y in [0.0,20.0]:
		for x in range(-128,129,16):
			for z in range(-104,105,16):
				var pos:=Vector3(x,y+1.0,z)
				var q:=PhysicsShapeQueryParameters3D.new();q.shape=body;q.transform.origin=pos;q.collision_mask=1
				if not get_world_3d().direct_space_state.intersect_shape(q,1).is_empty(): continue
				var hit:=get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(pos,pos-Vector3.UP*1.5,1))
				if hit.is_empty() or hit.normal.y<0.9 or absf(hit.position.y-y)>0.15: continue
				candidates.append(Vector3(x,y+1.15,z))
func spawn_mote() -> bool:
	if motes.size()>=8 or candidates.is_empty(): return false
	for attempt in 30:
		var pos:Vector3=candidates[rng.randi_range(0,candidates.size()-1)]
		if is_instance_valid(lab.player) and pos.distance_to(lab.player.position)<8: continue
		var crowded:=false
		for mote in motes:
			if pos.distance_to(mote.pos)<20: crowded=true
		if crowded: continue
		motes.append({"pos":pos,"node":icon("speed",pos,0.6),"life":65.0})
		return true
	return false
func collect(from: Vector3,to: Vector3) -> void:
	for station in stations:
		if not station.available: continue
		var center:Vector3=station.pos+Vector3.UP*1.65
		var nearest:=Geometry3D.get_closest_point_to_segment(center,from,to)
		if nearest.distance_to(center)>1.6 or not lab.player.ray(nearest,center).is_empty(): continue
		lab.player.grant_buff(station.kind,20 if station.kind=="overdrive" else 18)
		station.available=false;station.timer=station.period;station.token.hide();pickups+=1
		lab.sound("success",0.8 if station.kind=="overdrive" else 1.0)
	for i in range(motes.size()-1,-1,-1):
		var mote:Dictionary=motes[i]
		var nearest:=Geometry3D.get_closest_point_to_segment(mote.pos,from,to)
		if nearest.distance_to(mote.pos)>1.0 or not lab.player.ray(nearest,mote.pos).is_empty(): continue
		lab.player.grant_buff("speed",8);mote.node.queue_free();motes.remove_at(i);pickups+=1;lab.sound("success",1.15)
func tick(dt: float) -> void:
	elapsed+=dt
	for station in stations:
		if not station.available:
			station.timer=maxf(0,station.timer-dt)
			if station.timer==0: station.available=true;station.token.show()
		station.token.position=station.pos+Vector3.UP*(1.65+sin(elapsed*2)*0.12)
		station.token.rotation.y=elapsed*0.8
		station.light.light_energy=1.8 if station.available else 0.35
		station.ring.scale=Vector3.ONE*(1.0 if station.available else lerpf(0.40,1.0,1-station.timer/station.period))
	spawn_clock-=dt
	if spawn_clock<=0: spawn_clock=rng.randf_range(7,13);spawn_mote()
	for i in range(motes.size()-1,-1,-1):
		var mote:Dictionary=motes[i];mote.life-=dt
		mote.node.position=mote.pos+Vector3.UP*sin(elapsed*2+i)*0.12;mote.node.rotation.y=elapsed*1.2
		if mote.life<=0: mote.node.queue_free();motes.remove_at(i)
func _physics_process(dt: float) -> void:
	if lab.paused or testing: return
	tick(dt)
