extends Node3D
## Original skeletal courier. In-place clips; the controller alone owns motion.
var body: Node3D
var wheel_angle:=0.0
var lean:=Vector2.ZERO
var suspension:=0.0
var skeleton: Skeleton3D
var animator: AnimationPlayer
var clips: Dictionary={}
var current_clip:=""
var was_grounded:=true
var land_time:=0.0

func _ready() -> void:
	body=load("res://assets/courier.glb").instantiate();add_child(body)
	preload("res://scripts/gameplay/props.gd").soften_visor(body)
	for piece in body.find_children("*","GeometryInstance3D",true,false): piece.layers=4
	skeleton=body.find_children("*","Skeleton3D",true,false)[0]
	animator=body.find_children("*","AnimationPlayer",true,false)[0]
	# Manual advancement freezes with the game and permits deterministic pose reviews.
	animator.callback_mode_process=AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_MANUAL
	for key in animator.get_animation_list():
		var short:=String(key).get_slice("/",String(key).get_slice_count("/")-1)
		clips[short]=key
		if short in ["Idle","Walk","Air"]: animator.get_animation(key).loop_mode=Animation.LOOP_LINEAR

func pose(p:CharacterBody3D,dt:float) -> void:
	body.show()
	var local:Vector3=p.global_basis.inverse()*p.velocity
	var speed:=Vector2(local.x,local.z).length()
	var grounded:=p.is_on_floor()
	if grounded and not was_grounded:land_time=0.32
	was_grounded=grounded;land_time=maxf(0,land_time-dt)
	var attached:bool=p.has_anchor()
	var clip:="Walk" if grounded and speed>0.25 else "Idle"
	if not grounded:clip="Hang" if attached else "Air"
	if land_time>0:clip="Land"
	if p.crouched or p.stone:clip="Brake"
	if p.combat.pose_fists:clip="Punch"
	if p.combat.charging:clip="Charge"
	if current_clip!=clip:animator.play(clips[clip],0.13);current_clip=clip
	if clip=="Charge":animator.seek(p.combat.charge_fraction()*animator.get_animation(clips[clip]).length,true)
	elif clip=="Brake":animator.seek(minf(0.6,animator.current_animation_position+dt),true)
	else:animator.advance(dt)
	wheel_angle=fposmod(wheel_angle+local.z*dt/0.43,TAU)
	skeleton.set_bone_pose_rotation(skeleton.find_bone("wheel"),Quaternion(Vector3.RIGHT,wheel_angle))
	var desired:=Vector2(clampf(local.z*0.006,-0.16,0.16),clampf(-local.x*0.008,-0.20,0.20))
	if attached and not grounded:desired.x=-0.12
	if p.has_cargo():desired.y+=0.08 if p.cargo_hand==0 else -0.08
	lean=lean.lerp(desired,1-exp(-dt*8))
	var spine:=skeleton.find_bone("spine")
	skeleton.set_bone_pose_rotation(spine,skeleton.get_bone_pose_rotation(spine)*Quaternion.from_euler(Vector3(lean.x,0,lean.y)))
	# Compress the chassis, never scale the entire robot or its tire.
	suspension=lerpf(suspension,-0.10 if p.crouched and clip!="Brake" else 0.0,1-exp(-dt*16))
	var hips:=skeleton.find_bone("hips")
	skeleton.set_bone_pose_position(hips,skeleton.get_bone_pose_position(hips)+Vector3(0,suspension,0))
	body.scale=Vector3.ONE

func shoulder_position(i: int) -> Vector3:
	var bone:=skeleton.find_bone("shoulder_L" if i==0 else "shoulder_R")
	return skeleton.to_global(skeleton.get_bone_global_pose(bone).origin)
