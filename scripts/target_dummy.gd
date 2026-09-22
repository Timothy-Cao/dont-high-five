extends CharacterBody3D
## Nonlethal knockback target. Its colored lamps show recovery, not health.
var lab: Node3D
var respawn:=0.0
var model:Node3D
var lamps:Array[MeshInstance3D]=[]
var home:=Vector3.ZERO
var hits_received:=0
var last_impulse:=Vector3.ZERO
var knocked_out:=false
var last_hit_kind:=""

func _ready() -> void:
	set_meta("grippy",false);collision_layer=1;collision_mask=1
	home=position
	model=load("res://assets/target_dummy.glb").instantiate();add_child(model)
	var col:=CollisionShape3D.new();var shape:=CapsuleShape3D.new()
	shape.radius=0.76;shape.height=2.65;col.shape=shape;col.position.y=1.66;add_child(col)
	for i in 4:
		var lamp:=MeshInstance3D.new();var sphere:=SphereMesh.new();sphere.radius=0.075;sphere.height=0.15
		lamp.mesh=sphere;add_child(lamp);lamp.position=Vector3(-0.3+i*0.2,3.24,0)
		lamp.material_override=lab.mat(Color("64dec6"),1.0);lamps.append(lamp)

func receive_punch(impulse: Vector3,strength: float) -> bool:
	hits_received+=1;last_impulse=impulse;velocity+=impulse;last_hit_kind="punch"
	knocked_out=true;respawn=lerpf(1.5,3.0,strength)
	model.rotation.x=impulse.z*0.025;model.rotation.z=-impulse.x*0.025
	lab.sound("stick",0.7)
	for lamp in lamps: lamp.hide()
	return true

func take_damage(amount:float,source:=Vector3.ZERO,_kind:="watcher") -> void:
	# Practice targets visibly react to firearms as well as nonlethal punches.
	var away:Vector3=(global_position+Vector3.UP-source).normalized()
	receive_punch(away*clampf(amount*0.24,2.0,13.0)+Vector3.UP*2,clampf(amount/55.0,0,1))
	last_hit_kind=_kind

func reset_target() -> void:
	position=home;velocity=Vector3.ZERO;respawn=0;knocked_out=false;last_hit_kind=""
	model.rotation=Vector3.ZERO;model.scale=Vector3.ONE
	for lamp in lamps: lamp.show()

func _physics_process(dt: float) -> void:
	if lab.paused: return
	velocity.y-=24*dt
	if is_on_floor():
		velocity.x=move_toward(velocity.x,0,12*dt)
		velocity.z=move_toward(velocity.z,0,12*dt)
	move_and_slide()
	if knocked_out:
		respawn=maxf(0,respawn-dt)
		model.scale.y=move_toward(model.scale.y,0.35,dt*3)
		for i in 4: lamps[i].visible=respawn<float(i)*0.45
		if respawn<=0: reset_target()
	elif position.y< -10: reset_target()
