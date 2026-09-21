extends Node
## Each fist sweeps its actual volume; one contact per fist, one hop per attack.
var player: CharacterBody3D
var active:=false
var pose_fists:=false
var direction:=Vector3.FORWARD
var shot_basis:=Basis.IDENTITY
var projectiles:Array[Dictionary]=[]
var shape:=SphereShape3D.new()
var hopped:=false
var attacks:=0
var hits:=0
var hit_flash:=0.0
const SPEED:=70.0
const DAMAGE:=30.0

func _ready() -> void:
	shape.radius=0.22

func begin() -> bool:
	if player.arms_suppressed() or not player.punch_enabled or player.stone or player.held("brake") or player.hand_recovery>0 or active: return false
	player.cancel_hands()
	active=true;pose_fists=true;hopped=false;attacks+=1
	direction=-player.camera.global_basis.z;shot_basis=player.camera.global_basis
	projectiles.clear()
	for i in 2:
		var origin:Vector3=player.hand_start(i)
		# A fist cannot originate beyond nearby cover or below the ground.
		var muzzle_hit:Dictionary=player.ray(player.camera.global_position,origin)
		if not muzzle_hit.is_empty(): origin=muzzle_hit.position-direction*0.24
		projectiles.append({"pos":origin,"remaining":player.hand_range(),"done":false,"damage":DAMAGE*player.pull_multiplier()})
		player.hands[i].state=3;player.hands[i].point=origin
		player.hands[i].from=origin;player.hands[i].retract_left=0
	player.lab.sound("fire",0.72)
	return true

func cancel() -> void:
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
	if is_instance_valid(body) and body.has_method("take_damage"):
		body.take_damage(projectiles[index].damage,direction)
		hits+=1;hit_flash=0.18
	var normal:Vector3=contact.get("normal",Vector3.ZERO)
	var point:Vector3=contact.get("point",projectiles[index].pos)
	if not hopped and normal.y>0.65 and direction.y < -0.4 and point.distance_to(player.position)<3.2:
		hopped=true
		player.velocity=Vector3.UP*10.5*sqrt(player.pull_multiplier())
		player.momentum_air=true;player.flying=true;player.flight_time=0
		player.launch_origin=player.position;player.grounded_time=0
		player.jump_lock=0.15;player.coyote=0;player.wall_clinging=false;player.wall_lock=0.2
		player.lab.sound("bounce",0.82)
	else: player.lab.sound("land",0.8)
	player.recoil=0.3

func tick(dt: float) -> void:
	hit_flash=maxf(0,hit_flash-dt)
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
		q.collision_mask=9;q.exclude=[player.get_rid()];q.margin=0.005
		var space:=player.get_world_3d().direct_space_state
		var initial:=space.get_rest_info(q)
		var fraction:=space.cast_motion(q)
		var collided:bool=not initial.is_empty() or fraction[0]<1
		projectile.pos+=direction*step*(0.0 if not initial.is_empty() else fraction[0])
		projectile.remaining-=step
		if collided:
			q.transform.origin=projectile.pos+direction*0.02;q.motion=Vector3.ZERO
			var contact:Dictionary=initial if not initial.is_empty() else space.get_rest_info(q)
			if not contact.is_empty(): impact(i,contact)
		projectile.done=collided or projectile.remaining<=0.001
		player.hands[i].point=projectile.pos
		all_done=all_done and projectile.done
	if all_done: finish()
