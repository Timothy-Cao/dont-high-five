extends CharacterBody3D
## Explicit local test partner: reciprocal palm and patrol target, not a network peer.
var lab:Node3D
var home:=Vector3.ZERO
var health:=100.0
var respawn:=0.0
var ko:=0.0
var highfive_cd:=0.0
var pending:=0.0
var visitor:CharacterBody3D
var gesture_serial:=0
var patrol:=false
var phase:=0.0
var model:Node3D
var animator:AnimationPlayer
var skeleton:Skeleton3D
var clips:Dictionary={}
var current_clip:=""
var cords:Array[MeshInstance3D]=[]
var gloves:Array[Node3D]=[]
var hits_received:=0
var roamer:=false
var roam_speed:=8.0
var roam_heading:=0.0
var wheel_angle:=0.0
var stuck_time:=0.0
func _ready() -> void:
	home=position;collision_layer=16;collision_mask=1;set_meta("grippy",true)
	var col:=CollisionShape3D.new();var shape:=CapsuleShape3D.new();shape.radius=0.4;shape.height=1.8;col.shape=shape;col.position.y=0.9;add_child(col)
	model=load("res://assets/courier.glb").instantiate();add_child(model)
	preload("res://scripts/gameplay/props.gd").soften_visor(model)
	animator=model.find_children("*","AnimationPlayer",true,false)[0]
	skeleton=model.find_children("*","Skeleton3D",true,false)[0]
	animator.callback_mode_process=AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	for key in animator.get_animation_list():
		var short:=String(key).get_slice("/",String(key).get_slice_count("/")-1)
		clips[short]=key
		if short in ["Idle","Walk"]:animator.get_animation(key).loop_mode=Animation.LOOP_LINEAR
	rotation.y=PI
	for i in 2:
		var g:Node3D=load("res://assets/glove_left.glb" if i==0 else "res://assets/glove_right.glb").instantiate();add_child(g);g.position=Vector3(-0.44 if i==0 else 0.44,1.1,-0.25);g.scale=Vector3.ONE*0.7;gloves.append(g);preload("res://scripts/gameplay/props.gd").glowing_glove(g)
		var cord=load("res://scripts/elastic_arm.gd").new();add_child(cord);cords.append(cord)
func hand_touch(p:CharacterBody3D,_index:int) -> void:
	if respawn>0 or ko>0 or highfive_cd>0 or pending>0:return
	visitor=p;gesture_serial=p.hand_serial;pending=0.2
func receive_punch(impulse:Vector3,strength:float) -> bool:
	if respawn>0:return false
	velocity+=impulse;ko=lerpf(0.5,2,strength);pending=0;hits_received+=1;return true
func take_damage(amount:float,_source:=Vector3.ZERO,_kind:="hit") -> void:
	if respawn>0:return
	health=maxf(0,health-amount)
	if health<=0:
		preload("res://scripts/gameplay/fiver_death.gd").spawn(self,_source)
		respawn=3;collision_layer=0;pending=0;model.hide()
		for glove in gloves:glove.hide()
		for cord in cords:cord.hide()
func _physics_process(dt:float) -> void:
	if lab.paused or (lab.session and lab.session.training.active):return
	highfive_cd=maxf(0,highfive_cd-dt);ko=maxf(0,ko-dt)
	if respawn>0:
		respawn=maxf(0,respawn-dt)
		if respawn==0:reset_partner()
		return
	model.rotation.z=lerp_angle(model.rotation.z,0.65 if ko>0 else 0.0,1-exp(-dt*9))
	if pending>0:
		pending=maxf(0,pending-dt)
		gloves[0].position.y=1.6
		if pending==0 and is_instance_valid(visitor) and not visitor.combat.charging and not visitor.combat.active and visitor.respawn_left<=0 and visitor.hand_serial==gesture_serial:
			if visitor.position.distance_to(position)<visitor.hand_range()+1 and visitor.ray(visitor.chest(),position+Vector3.UP).is_empty():
				if visitor.impostor:take_damage(100,visitor.position,"impostor")
				else:
					visitor.heal_full();health=100
					if lab.session:lab.session.objectives.highfive(position)
				lab.sound("success");highfive_cd=2
	else:gloves[0].position.y=lerpf(gloves[0].position.y,1.1,1-exp(-dt*9))
	if roamer and ko<=0:
		roam(dt)
	elif patrol and ko<=0:
		phase+=dt
		var goal:=home+Vector3(sin(phase*0.6)*6,0,cos(phase*0.6)*4)
		var direction:=Vector3(goal.x-position.x,0,goal.z-position.z)
		velocity.x=direction.x*2;velocity.z=direction.z*2
		if direction.length()>0.1:rotation.y=lerp_angle(rotation.y,atan2(-direction.x,-direction.z),dt*6)
	else:
		if not patrol and ko<=0 and lab.player.position.distance_to(position)<8:
			var toward:Vector3=lab.player.position-position
			rotation.y=lerp_angle(rotation.y,atan2(-toward.x,-toward.z),1-exp(-dt*5))
		velocity.x=move_toward(velocity.x,0,12*dt);velocity.z=move_toward(velocity.z,0,12*dt)
	velocity.y-=24*dt;move_and_slide()
	if position.y<home.y-20:position=home;velocity=Vector3.ZERO

func _process(dt:float) -> void:
	if lab.paused or respawn>0:return
	var clip:="Walk" if Vector2(velocity.x,velocity.z).length()>0.4 and ko<=0 else "Idle"
	if clip!=current_clip:animator.play(clips[clip],0.15);current_clip=clip
	animator.advance(dt*clampf(velocity.length()/1.2,0.7,3) if clip=="Walk" else dt)
	wheel_angle=fposmod(wheel_angle+(global_basis.inverse()*velocity).z*dt/0.43,TAU)
	skeleton.set_bone_pose_rotation(skeleton.find_bone("wheel"),Quaternion(Vector3.RIGHT,wheel_angle))
	for i in 2:
		gloves[i].visible=respawn<=0;cords[i].visible=respawn<=0
		if respawn>0:continue
		var bone:int=skeleton.find_bone("shoulder_L" if i==0 else "shoulder_R")
		var start:Vector3=skeleton.to_global(skeleton.get_bone_global_pose(bone).origin)
		cords[i].shape_arm(start,gloves[i].global_position,0.1,0,Color("bd8c4e") if i==0 else Color("3b9196"),Vector3.ZERO,0.055)

func reset_partner() -> void:
	position=home;health=100;respawn=0;ko=0;pending=0;highfive_cd=0;collision_layer=16;velocity=Vector3.ZERO;stuck_time=0
	model.show();model.scale=Vector3.ONE
func roam(dt:float) -> void:
	# Smooth laps with local wall/edge avoidance. Actual collision remains authoritative.
	var desired:=Vector3(cos(roam_heading),0,sin(roam_heading))
	var space:=get_world_3d().direct_space_state
	var lookahead:=maxf(3,roam_speed*0.35)
	var best:= -INF
	var chosen:=desired
	for offset in [0.0,0.45,-0.45,0.9,-0.9,1.6,-1.6,PI]:
		var candidate:=desired.rotated(Vector3.UP,offset)
		var start:=global_position+Vector3.UP
		var hit:=space.intersect_ray(PhysicsRayQueryParameters3D.create(start,start+candidate*lookahead,1))
		var free:float=lookahead if hit.is_empty() else start.distance_to(hit.position)
		var floor_hit:=space.intersect_ray(PhysicsRayQueryParameters3D.create(start+candidate*minf(free,lookahead),start+candidate*minf(free,lookahead)+Vector3.DOWN*4,1))
		var score:=free-absf(offset)*0.6
		if floor_hit.is_empty():score-=lookahead
		if score>best:best=score;chosen=candidate
	var target_angle:=atan2(chosen.z,chosen.x)
	roam_heading=lerp_angle(roam_heading,target_angle,1-exp(-dt*10))+dt*0.11
	var direction:=Vector3(cos(roam_heading),0,sin(roam_heading))
	velocity.x=direction.x*roam_speed;velocity.z=direction.z*roam_speed
	rotation.y=atan2(-direction.x,-direction.z)
	stuck_time=stuck_time+dt if get_real_velocity().length()<roam_speed*0.15 else 0.0
	if stuck_time>0.6:roam_heading+=PI*0.7;stuck_time=0
