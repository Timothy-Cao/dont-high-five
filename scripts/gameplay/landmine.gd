extends CharacterBody3D
## Thrown proximity puck. Punches use the same physical hit path as other targets.
const P=preload("res://scripts/gameplay/props.gd")
const LIFETIME:=120.0
const TRIGGER_RADIUS:=1.0
var watcher:Node3D
var age:=0.0
var landed:=false
var armed:=false
var arm_time:=0.0
var detonated:=false
var lamp:OmniLight3D
var indicator:MeshInstance3D
var previous:Dictionary={}
func _ready() -> void:
	collision_layer=32;collision_mask=1;set_meta("blackout_exempt",true)
	var col:=CollisionShape3D.new();var shape:=CylinderShape3D.new();shape.radius=0.36;shape.height=0.18;col.shape=shape;add_child(col)
	var puck:=CylinderMesh.new();puck.top_radius=0.30;puck.bottom_radius=0.34;puck.height=0.18;puck.radial_segments=24
	P.mesh(self,puck,Vector3.ZERO,Color("253a46"))
	var lid:=CylinderMesh.new();lid.top_radius=.16;lid.bottom_radius=.22;lid.height=.065;lid.radial_segments=12
	P.mesh(self,lid,Vector3.UP*.105,Color("667c83"))
	var sensor:=SphereMesh.new();sensor.radius=.055;sensor.height=.065
	P.mesh(self,sensor,Vector3.UP*.155,Color("ff4c63"),2)
	var ring:=TorusMesh.new();ring.inner_radius=0.23;ring.outer_radius=0.28;ring.rings=32;ring.ring_segments=8
	indicator=P.mesh(self,ring,Vector3.UP*0.10,Color("ff365e"),4)
	for i in 3:
		var fin:=BoxMesh.new();fin.size=Vector3(0.10,0.065,0.18)
		var angle:=i*TAU/3
		var node=P.mesh(self,fin,Vector3(sin(angle)*.27,-.04,cos(angle)*.27),Color("c6a36c"));node.rotation.y=angle
	lamp=OmniLight3D.new();lamp.light_color=Color("ff315b");lamp.omni_range=2;lamp.light_energy=0;add_child(lamp)
func receive_punch(_impulse:Vector3,_strength:float) -> bool:
	if detonated:return false
	detonate();return true
func detonate() -> void:
	if detonated:return
	detonated=true;collision_layer=0
	watcher.explode(global_position+Vector3.UP*0.2,4,65)
	queue_free()
func _physics_process(dt:float) -> void:
	if watcher.lab.paused or detonated:return
	age+=dt
	if age>=LIFETIME:queue_free();return
	if not landed:
		velocity.y-=16*dt
		var hit:=move_and_collide(velocity*dt)
		if hit:
			velocity=velocity.bounce(hit.get_normal())*0.18
			if hit.get_normal().y>0.5:landed=true;velocity=Vector3.ZERO;rotation=Vector3.ZERO
	else:
		arm_time+=dt;armed=arm_time>=0.7
	var flash:=armed and fposmod(age,0.65)<0.18
	indicator.visible=true
	indicator.material_override.emission_energy_multiplier=6.0 if flash else 0.65
	lamp.light_energy=1.5 if flash else 0.04
	if not armed:return
	var live:Dictionary={}
	for target in watcher.targets():
		var id:int=target.get_instance_id();var point:Vector3=target.global_position+Vector3.UP*0.5
		var from:Vector3=previous.get(id,point)
		if from.distance_to(point)>20:from=point
		var nearest:=Geometry3D.get_closest_point_to_segment(global_position,from,point)
		live[id]=point
		if nearest.distance_to(global_position)<=TRIGGER_RADIUS and watcher.clear_line(global_position,point,target):detonate();return
	previous=live
