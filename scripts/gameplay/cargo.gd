extends CharacterBody3D
## Collision-swept physical cargo; one occupied hand, never a hidden inventory slot.
var lab:Node3D
var carrier:CharacterBody3D
var hand_index:=-1
var home:=Vector3.ZERO
var delivered:=false
var color:=Color("ffca78")
var shell:MeshInstance3D
func _ready() -> void:
	collision_layer=4;collision_mask=1;home=position;set_meta("grippy",true)
	var col:=CollisionShape3D.new();var sphere:=SphereShape3D.new();sphere.radius=0.48;col.shape=sphere;add_child(col)
	shell=MeshInstance3D.new();var mesh:=SphereMesh.new();mesh.radius=0.48;mesh.height=0.96;shell.mesh=mesh
	shell.material_override=lab.mat(Color("244551"));add_child(shell)
	for axis in [Vector3.RIGHT,Vector3.FORWARD,Vector3.UP]:
		var band:=MeshInstance3D.new();var ring:=TorusMesh.new();ring.inner_radius=0.45;ring.outer_radius=0.485;ring.rings=32;ring.ring_segments=6
		band.mesh=ring;band.rotation=axis*PI/2;band.material_override=lab.mat(color,1.0);add_child(band)
func try_pickup(p:CharacterBody3D,index:int) -> bool:
	if delivered or is_instance_valid(carrier) or is_instance_valid(p.cargo): return false
	carrier=p;hand_index=index;p.cargo=self;p.cargo_hand=index;collision_layer=0
	p.hands[index].state=4;p.hands[index].point=global_position
	lab.sound("stick");return true
func release() -> void:
	if is_instance_valid(carrier):
		velocity=carrier.velocity
		carrier.hands[hand_index].state=0;carrier.cargo=null;carrier.cargo_hand=-1
	carrier=null;hand_index=-1;collision_layer=4
func reset_cargo() -> void:
	release();position=home;velocity=Vector3.ZERO;delivered=false;show()
func _physics_process(dt:float) -> void:
	if lab.paused or delivered: return
	if is_instance_valid(carrier):
		var target:Vector3=carrier.camera.global_transform*Vector3(-0.65 if hand_index==0 else 0.65,-0.25,-1.65)
		velocity=(target-global_position).limit_length(maxf(30,carrier.velocity.length()+20)*dt)/dt
		move_and_slide()
		carrier.hands[hand_index].point=global_position
	else:
		velocity.y-=24*dt
		var before:=velocity
		move_and_slide()
		if is_on_floor():
			velocity.x=move_toward(velocity.x,0,5*dt);velocity.z=move_toward(velocity.z,0,5*dt)
			if before.y< -3: velocity.y=-before.y*0.35
		if position.y<home.y-25: reset_cargo()
