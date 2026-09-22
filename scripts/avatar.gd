extends Node3D
## Original skeletal courier. In-place clips; the controller alone owns motion.
var body: Node3D
var ball_shell: MeshInstance3D
var skeleton: Skeleton3D
var animator: AnimationPlayer
var clips: Dictionary={}
var current_clip:=""
var was_grounded:=true
var land_time:=0.0

func _ready() -> void:
	body=load("res://assets/courier.glb").instantiate();add_child(body)
	for piece in body.find_children("*","GeometryInstance3D",true,false): piece.layers=4
	skeleton=body.find_children("*","Skeleton3D",true,false)[0]
	animator=body.find_children("*","AnimationPlayer",true,false)[0]
	# Manual advancement freezes with the game and permits deterministic pose reviews.
	animator.callback_mode_process=AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	for key in animator.get_animation_list():
		var short:=String(key).get_slice("/",String(key).get_slice_count("/")-1)
		clips[short]=key
		if short in ["Idle","Walk","Air"]: animator.get_animation(key).loop_mode=Animation.LOOP_LINEAR
	ball_shell=MeshInstance3D.new()
	var sphere:=SphereMesh.new();sphere.radius=0.32;sphere.height=0.64;sphere.radial_segments=40;sphere.rings=20
	ball_shell.mesh=sphere
	var mat:=StandardMaterial3D.new();mat.albedo_color=Color("7ca99c");mat.roughness=0.55
	ball_shell.material_override=mat;ball_shell.position.y=0.32;ball_shell.layers=4
	add_child(ball_shell)
	for axis in [Vector3.RIGHT,Vector3.FORWARD]:
		var band:=MeshInstance3D.new();var ring:=TorusMesh.new();ring.inner_radius=0.305;ring.outer_radius=0.328;ring.rings=40;ring.ring_segments=6
		band.mesh=ring;band.rotation=axis*PI/2;band.layers=4
		var rubber:=StandardMaterial3D.new();rubber.albedo_color=Color("172d36")
		band.material_override=rubber;ball_shell.add_child(band)

func pose(p: CharacterBody3D,dt: float) -> void:
	body.visible=not p.ball;ball_shell.visible=p.ball
	var speed:=Vector2(p.velocity.x,p.velocity.z).length()
	if p.ball:
		var local_velocity:Vector3=p.global_basis.inverse()*p.velocity
		var axis:=Vector3.UP.cross(Vector3(local_velocity.x,0,local_velocity.z))
		if axis.length()>0.01: ball_shell.rotate(axis.normalized(),speed*dt/0.32)
		return
	var walking:=p.is_on_floor() and speed>0.25
	if p.is_on_floor() and not was_grounded: land_time=0.24
	was_grounded=p.is_on_floor();land_time=maxf(0,land_time-dt)
	var clip:="Walk" if walking else "Idle"
	if land_time>0 and not walking: clip="Land"
	if not p.is_on_floor(): clip="Air"
	if p.combat.pose_fists and not walking and p.is_on_floor(): clip="Punch"
	if p.combat.charging and not walking and p.is_on_floor(): clip="Charge"
	if clip!=current_clip:
		animator.play(clips[clip],0.12);current_clip=clip
	if clip=="Charge":
		animator.seek(p.combat.charge_fraction()*animator.get_animation(clips[clip]).length,true)
	else:
		var rate:=speed/1.2 if clip=="Walk" else (1.67 if clip=="Land" else 1.0)
		# Play the in-place stride backwards when backing up. Strafe turns the hips.
		var local:Vector3=p.global_basis.inverse()*p.velocity
		if clip=="Walk" and local.z>absf(local.x): rate=-rate
		animator.advance(dt*rate)
		var yaw:=clampf(atan2(-local.x,absf(local.z)+0.01),-0.6,0.6) if walking else 0.0
		body.rotation.y=lerp_angle(body.rotation.y,yaw,1-exp(-dt*12))
	# Keep the leg gait while charging on the move; layer the wind-up on the torso.
	if p.combat.charging and clip!="Charge":
		var spine:=skeleton.find_bone("spine")
		skeleton.set_bone_pose_rotation(spine,skeleton.get_bone_pose_rotation(spine)*Quaternion(Vector3.RIGHT,-0.12*p.combat.charge_fraction()))
	body.scale.y=lerpf(body.scale.y,0.60 if p.crouched else 1.0,1-exp(-dt*18))

func shoulder_position(i: int) -> Vector3:
	if ball_shell.visible: return to_global(Vector3(-0.25 if i==0 else 0.25,0.32,0))
	var bone:=skeleton.find_bone("shoulder_L" if i==0 else "shoulder_R")
	return skeleton.to_global(skeleton.get_bone_global_pose(bone).origin)

