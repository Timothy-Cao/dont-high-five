extends CharacterBody3D
## Cosmetic collapse. A small collision body lets airborne deaths fall to the floor.
var lab:Node3D
var age:=0.0
var visual:Node3D
var spin:=1.0
var skeleton:Skeleton3D
static func spawn(owner_node:Node3D, source:Vector3) -> Node3D:
	var body=load("res://scripts/gameplay/fiver_death.gd").new()
	body.lab=owner_node.lab;body.position=owner_node.global_position+Vector3.UP*0.35
	body.rotation.y=owner_node.rotation.y;body.spin=-1.0 if owner_node.get_instance_id()%2 else 1.0
	var away:Vector3=(owner_node.global_position-source).normalized()
	body.velocity=owner_node.velocity.limit_length(18)+away*3+Vector3.UP*2
	owner_node.lab.add_child(body)
	return body
func _ready() -> void:
	collision_layer=0;collision_mask=1
	var col:=CollisionShape3D.new();var shape:=SphereShape3D.new();shape.radius=0.32;col.shape=shape;add_child(col)
	visual=Node3D.new();add_child(visual)
	var model=load("res://assets/courier.glb").instantiate();visual.add_child(model)
	preload("res://scripts/gameplay/props.gd").soften_visor(model)
	for animation in model.find_children("*","AnimationPlayer",true,false):animation.stop()
	skeleton=model.find_children("*","Skeleton3D",true,false)[0]
	for i in 2:
		var glove=load("res://assets/glove_left.glb" if i==0 else "res://assets/glove_right.glb").instantiate()
		visual.add_child(glove);glove.position=Vector3(-0.48 if i==0 else 0.48,0.95,-0.12);glove.scale=Vector3.ONE*0.7
		preload("res://scripts/gameplay/props.gd").glowing_glove(glove)
func _physics_process(dt:float) -> void:
	if lab.paused:return
	age+=dt
	skeleton.set_bone_pose_rotation(skeleton.find_bone("wheel"),Quaternion(Vector3.RIGHT,10*(1-exp(-age*2))))
	var fall:=smoothstep(0.0,0.65,age)
	visual.rotation=Vector3(-fall*PI/2,0,spin*sin(fall*PI)*0.18)
	visual.position.y=lerpf(-0.35,0.05,fall)
	velocity.y-=24*dt;velocity.x=move_toward(velocity.x,0,8*dt);velocity.z=move_toward(velocity.z,0,8*dt)
	move_and_slide()
	visual.scale=Vector3.ONE*(1-smoothstep(2.5,2.9,age))
	if age>=2.9:queue_free()
