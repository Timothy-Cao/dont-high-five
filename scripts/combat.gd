extends Node
## Two parallel volume sweeps share one additive surface-recoil impulse budget.
var player: CharacterBody3D
var active:=false
var charging:=false
var charge_time:=0.0
var released_charge:=0.0
var pose_fists:=false
var direction:=Vector3.FORWARD
var shot_basis:=Basis.IDENTITY
var projectiles:Array[Dictionary]=[]
var shape:=SphereShape3D.new()
var hopped:=false
var attacks:=0
var hits:=0
var hit_flash:=0.0
var recoil_normals:=Vector3.ZERO
var recoil_applied:=Vector3.ZERO
var recoil_weight:=0.0
var attack_pull:=1.0
const SPEED:=70.0
const CHARGE_SECONDS:=1.1
const TAP_RANGE:=4.5
var struck_bodies: Dictionary={}
const RECOIL_RADIUS:=4.5
const TAP_IMPULSE:=9.0
const FULL_IMPULSE:=24.0

func _ready() -> void:
	shape.radius=0.105

func charge_fraction() -> float:
	return 1.0 if player.buffs.has("max_charge") else clampf(charge_time/CHARGE_SECONDS,0,1)

func start_charge() -> bool:
	if player.has_cargo() or player.arms_suppressed() or not player.punch_enabled or player.stone or player.held("brake") or player.held("anchor") or player.hand_recovery>0 or active or charging: return false
	player.cancel_hands()
	charging=true;pose_fists=true;charge_time=0
	return true

func release_charge() -> bool:
	if not charging: return false
	var strength:=charge_fraction()
	charging=false
	return begin(strength)

func begin(strength: float = 0.0) -> bool:
	if player.has_cargo() or player.arms_suppressed() or not player.punch_enabled or player.stone or player.held("brake") or player.held("anchor") or player.hand_recovery>0 or active or charging: return false
	player.cancel_hands()
	released_charge=clampf(strength,0,1)
	recoil_normals=Vector3.ZERO;recoil_applied=Vector3.ZERO;recoil_weight=0;attack_pull=player.pull_multiplier()
	active=true;pose_fists=true;hopped=false;attacks+=1
	direction=-player.camera.global_basis.z;shot_basis=player.camera.global_basis
	# Aim the pair's midpoint at the crosshair hit. Both fists still travel
	# parallel, but their lowered muzzle no longer hits the floor short of a target.
	var aim_query:=PhysicsRayQueryParameters3D.create(player.camera.global_position,player.camera.global_position+direction*player.hand_range(),59,[player.get_rid()])
	var aim_hit:=player.get_world_3d().direct_space_state.intersect_ray(aim_query)
	if not aim_hit.is_empty():
		var midpoint:Vector3=(player.hand_start(0)+player.hand_start(1))*0.5
		var aim_delta:Vector3=aim_hit.position-midpoint
		if aim_delta.length()>0.5 and aim_delta.normalized().dot(direction)>0.5:direction=aim_delta.normalized()
	projectiles.clear();struck_bodies.clear()
	for i in 2:
		var origin:Vector3=player.hand_start(i)
		# A fist cannot originate beyond nearby cover or below the ground.
		var muzzle_hit:Dictionary=player.ray(player.camera.global_position,origin)
		if not muzzle_hit.is_empty(): origin=muzzle_hit.position-direction*0.24
		projectiles.append({"pos":origin,"remaining":lerpf(TAP_RANGE,player.hand_range(),released_charge),"done":false,"impulse":lerpf(TAP_IMPULSE,FULL_IMPULSE,released_charge)*sqrt(attack_pull)})
		player.hands[i].state=3;player.hands[i].point=origin
		player.hands[i].from=origin;player.hands[i].retract_left=0
	player.lab.sound("fire",0.72)
	return true

func cancel() -> void:
	if charging:
		charging=false;charge_time=0;pose_fists=false
	if not active: return
	finish()

func finish() -> void:
	active=false
	for i in 2:
		player.recovery_origins[i]=player.hands[i].point
		player.hands[i].state=0;player.hands[i].retract_left=0
	player.hand_recovery=player.HAND_RECOVERY_DURATION

func impact(index: int,contact: Dictionary) -> void:
	var body=instance_from_id(int(contact.get("collider_id",0))) if int(contact.get("collider_id",0))!=0 else null
	if is_instance_valid(body) and body.has_method("receive_punch") and not struck_bodies.has(body.get_instance_id()):
		struck_bodies[body.get_instance_id()]=true
		var impulse:Vector3=direction*projectiles[index].impulse
		if absf(direction.y)<0.3: impulse.y+=4.0
		if body.receive_punch(impulse,released_charge): hits+=1;hit_flash=0.18
	var normal:Vector3=contact.get("normal",Vector3.ZERO)
	var point:Vector3=contact.get("point",projectiles[index].pos)
	var distance:float=point.distance_to(player.position+Vector3.UP*0.9)
	if normal.length()>0.5 and distance<RECOIL_RADIUS and body is CollisionObject3D and (body.collision_layer&19)!=0:
		var weight:=1.0-smoothstep(3.0,RECOIL_RADIUS,distance)
		recoil_normals+=normal.normalized()*weight
		recoil_weight=maxf(recoil_weight,weight)
	if body is StaticBody3D and (body.collision_layer&1)!=0 and is_instance_valid(player.movement_fx):
		player.movement_fx.stamp(point,normal,player.hands[index].color,released_charge)
	player.lab.sound("land",0.8)
	player.recoil=0.3

func apply_recoil() -> void:
	if recoil_normals.length()<0.01: return
	var impulse:=recoil_normals.normalized()*lerpf(TAP_IMPULSE,FULL_IMPULSE,released_charge)*sqrt(attack_pull)*recoil_weight
	var change:=impulse-recoil_applied
	if change.length()<0.001: return
	# A second contact redirects the shared impulse; it does not award a second blast.
	player.velocity+=change
	if not hopped:
		# A grounded wall skim needs a little floor clearance to avoid instant friction.
		if player.is_on_floor() and absf(impulse.y)<1: player.velocity.y+=4.0
		player.lab.sound("blast",lerpf(1.15,0.8,released_charge))
		hopped=true
	recoil_applied=impulse
	player.momentum_air=true;player.flying=true;player.flight_time=0
	player.launch_origin=player.position;player.grounded_time=0;player.landing_grace=0.10
	player.jump_lock=0.15;player.coyote=0;player.wall_clinging=false;player.wall_lock=0.2

func tick(dt: float) -> void:
	hit_flash=maxf(0,hit_flash-dt)
	if charging:
		charge_time=minf(CHARGE_SECONDS,charge_time+dt*(2.0 if player.buffs.has("charge") else 1.0))
		return
	if not active:
		if player.hand_recovery<=0: pose_fists=false
		return
	var all_done:=true
	for i in 2:
		var projectile:Dictionary=projectiles[i]
		if projectile.done: continue
		var step:float=minf(SPEED*dt,projectile.remaining)
		var q:=PhysicsShapeQueryParameters3D.new()
		q.shape=shape;q.transform.origin=projectile.pos;q.motion=direction*step
		q.collision_mask=59;q.exclude=[player.get_rid()];q.margin=0.005
		var space:=player.get_world_3d().direct_space_state
		var initial:=space.get_rest_info(q)
		var fraction:=space.cast_motion(q)
		var previous:Vector3=projectile.pos
		# A center ray also runs on every sweep. Tiny spheres can otherwise tunnel
		# into a large compound floor, producing an arbitrary penetration normal.
		var ray_query:=PhysicsRayQueryParameters3D.create(previous,previous+direction*(step+shape.radius),59,[player.get_rid()])
		var surface:=space.intersect_ray(ray_query)
		var travel:float=step*(0.0 if not initial.is_empty() else fraction[0])
		if not surface.is_empty(): travel=minf(travel,maxf(0,previous.distance_to(surface.position)-shape.radius))
		var collided:bool=not initial.is_empty() or fraction[0]<1 or not surface.is_empty()
		projectile.pos+=direction*travel
		projectile.remaining-=step
		if collided:
			q.transform.origin=projectile.pos+direction*0.02;q.motion=Vector3.ZERO
			var contact:Dictionary=initial if not initial.is_empty() else space.get_rest_info(q)
			if not surface.is_empty() and (contact.is_empty() or surface.collider_id==contact.get("collider_id",-1) or fraction[0]>=1):
				contact={"point":surface.position,"normal":surface.normal,"collider_id":surface.collider_id}
			if not contact.is_empty(): impact(i,contact)
		projectile.done=collided or projectile.remaining<=0.001
		player.hands[i].point=projectile.pos
		all_done=all_done and projectile.done
	apply_recoil()
	if all_done: finish()
