extends StaticBody3D
var lab: Node3D
var health:=100.0
var respawn:=0.0
var hit_time:=0.0
var wobble:=0.0
var model:Node3D
var lamps:Array[MeshInstance3D]=[]
var damage_received:=0.0
func _ready() -> void:
	set_meta("grippy",false)
	model=load("res://assets/target_dummy.glb").instantiate();add_child(model)
	var col:=CollisionShape3D.new();var shape:=CapsuleShape3D.new()
	shape.radius=0.76;shape.height=2.65;col.shape=shape;col.position.y=1.66;add_child(col)
	for i in 4:
		var lamp:=MeshInstance3D.new();var sphere:=SphereMesh.new();sphere.radius=0.075;sphere.height=0.15
		lamp.mesh=sphere;add_child(lamp);lamp.position=Vector3(-0.3+i*0.2,3.24,0)
		lamp.material_override=lab.mat(Color("64dec6"),1.0);lamps.append(lamp)
func take_damage(amount: float,direction: Vector3) -> void:
	if respawn>0: return
	amount=maxf(0,amount);damage_received+=minf(health,amount);health=maxf(0,health-amount)
	hit_time=0.22;wobble=0.25
	model.rotation.x=direction.z*0.18;model.rotation.z=-direction.x*0.18
	lab.sound("stick",0.7)
	if health<=0: respawn=8;collision_layer=0;lab.sound("success",0.72)
	for i in 4: lamps[i].visible=health>i*25
func _physics_process(dt: float) -> void:
	if lab.paused: return
	hit_time=maxf(0,hit_time-dt);wobble=maxf(0,wobble-dt)
	if respawn>0:
		respawn=maxf(0,respawn-dt)
		model.scale.y=move_toward(model.scale.y,0.16,dt*3)
		if respawn==0:
			health=100;collision_layer=1
			for lamp in lamps: lamp.show()
	else:
		model.scale.y=move_toward(model.scale.y,1.0,dt*3)
		model.rotation=model.rotation.lerp(Vector3.ZERO,1-exp(-dt*14))
		model.position.y=sin(wobble*45)*wobble*0.18
