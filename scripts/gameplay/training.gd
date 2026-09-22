extends Node3D
const P=preload("res://scripts/gameplay/props.gd")
var lab:Node3D
var active:=false
var built:=false
var room:=0
var completed:=false
var cargo:CharacterBody3D
var dummy:CharacterBody3D
var pulse:=0.0
var exit_ring:MeshInstance3D
var return_pos:=Vector3.ZERO
const TITLES=["Move / jump","Grapple / reel","Carry","Elastic slingshot","Punch","Ground punch","Anchor","Momentum","Ceiling walk"]
func origin(index:int=-1) -> Vector3:
	var i:=room if index<0 else index
	return Vector3((i%3-1)*80,100,(floori(i/3.0)-1)*70)
func build() -> void:
	built=true
	for i in 9:
		var o:=origin(i);var root:=Node3D.new();add_child(root);root.position=o
		var color:=Color("7bd6d0") if i%2==0 else Color("f0bb76")
		var dark:=Color("35434b")
		var height:=40.0 if i==3 else (12.0 if i==8 else 17.0)
		P.box(root,Vector3(0,-10.5,0),Vector3(40,1,36),dark)
		for z in [-18,18]:P.box(root,Vector3(0,height/2,z),Vector3(40,height,0.7),dark)
		for x in [-20,20]:P.box(root,Vector3(x,height/2,0),Vector3(0.7,height,36),dark)
		P.box(root,Vector3(0,height,0),Vector3(40,0.5,36),dark)
		if i in [0,3,8]:
			var edge:=1.1 if i==0 else 8.0
			for side in [-1,1]:P.box(root,Vector3(side*(20+edge)/2,-0.3,0),Vector3(20-edge,0.6,35.5),dark)
		else:P.box(root,Vector3(0,-0.3,0),Vector3(40,0.6,35.5),dark)
		for z in [-17.5,17.5]:
			var strip=P.box(root,Vector3(0,0.03,z),Vector3(38,0.04,0.10),color,false)
			strip.get_child(0).material_override=P.material(color,1.2)
		# Mark the safe lane and the actual ledge lips; never draw a path over empty air.
		for x in range(-16,17,4):
			if i in [0,3,8] and absf(x)<(1.1 if i==0 else 8.0):continue
			P.beam(root,Vector3(x,0.035,-12),Vector3(x,0.035,12),Color("36555d"),0.014)
		for z in [-3,3]:
			for segment in [[-18.0,-1.1],[1.1,18.0]] if i==0 else ([[-18.0,-8.0],[8.0,18.0]] if i in [3,8] else [[-18.0,18.0]]):
				P.beam(root,Vector3(segment[0],0.06,z),Vector3(segment[1],0.06,z),color,0.025)
		if i in [0,3,8]:
			for edge in [-1.1,1.1] if i==0 else [-8.0,8.0]:
				P.beam(root,Vector3(edge,0.04,-17),Vector3(edge,0.04,17),Color("ffc778"),0.05)
		if i in [1,5]:
			P.beam(root,Vector3(5,7.03 if i==1 else 9.03,-14),Vector3(5,7.03 if i==1 else 9.03,14),color,0.05)
		if i==8:
			for x in [-8,0,8]:P.box(root,Vector3(x,11.65,0),Vector3(3,0.25,8),color)
		var lamp:=OmniLight3D.new();root.add_child(lamp);lamp.position=Vector3(0,10,0);lamp.omni_range=35;lamp.light_energy=5;lamp.light_color=color
		if i in [1,5]:P.box(root,Vector3(12,3.5 if i==1 else 4.5,0),Vector3(14,7 if i==1 else 9,30),dark)
		if i==3:
			for z in [-5,5]:P.box(root,Vector3(-7,6,z),Vector3(1.5,12,1.5),color)
		if i==7:
			for z in [-4,4]:P.box(root,Vector3(-7,2,z),Vector3(0.9,4,0.9),color)
		if i==2:
			cargo=load("res://scripts/gameplay/cargo.gd").new();cargo.lab=lab;cargo.position=o+Vector3(-6,0.7,0);add_child(cargo)
			P.ring(root,Vector3(11,0.05,0),1.8,color)
		if i==4:
			dummy=load("res://scripts/target_dummy.gd").new();dummy.lab=lab;dummy.position=o;add_child(dummy)
	exit_ring=P.ring(self,Vector3.ZERO,2,Color("91e8c6"),true);exit_ring.rotation.y=PI/2
	hide();set_children_active(false)
func set_children_active(value:bool) -> void:
	if cargo:cargo.set_physics_process(value)
	if dummy:dummy.set_physics_process(value)
func enter() -> void:
	if lab.builder and lab.builder.active:lab.builder.leave()
	if not built:build()
	lab.session.watcher.leave()
	return_pos=lab.player.position
	active=true;show();set_children_active(true);room=0;completed=false
	restart();lab.started=true;lab.set_paused(false)
func leave() -> void:
	active=false;hide();set_children_active(false)
	lab.player.reset_to(return_pos);lab.player.health=100
func restart() -> void:
	pulse=0;lab.player.respawn_left=0;lab.player.collision_layer=2
	lab.player.reset_to(origin()+Vector3(-14,0.05,0));lab.player.rotation.y=-PI/2;lab.player.camera.rotation=Vector3.ZERO
	lab.player.fixed_mode=room==8;lab.player.zip_mode=false;lab.player.health=100
	if cargo:cargo.reset_cargo()
	if dummy:dummy.reset_target()
	exit_ring.position=origin()+Vector3(16,8.8 if room==5 else (6.8 if room==1 else 1.8),0)
func choose(index:int) -> void:
	if not active:enter()
	room=clampi(index,0,8);restart();lab.set_paused(false)
func prompt() -> String:
	var c=lab.controls
	return [c.movement_prompt()+"  ·  "+c.prompt("jump"),"LMB / RMB  ·  "+c.prompt("reel"),"Click carrying hand to drop  ·  Free hand moves  ·  "+c.prompt("launch"), "LMB then RMB anchors  ·  "+c.prompt("launch"),"LMB + RMB  ·  hold / release","Look down  ·  hold LMB + RMB",c.prompt("anchor")+"  ·  hold against the pulse","Stretch  ·  launch  ·  "+c.prompt("jump"),"Fixed mode  ·  aim up  ·  LMB → RMB → LMB"][room]
func _physics_process(dt:float) -> void:
	if not active or lab.paused:return
	var p=lab.player;var local:Vector3=p.position-origin()
	pulse+=dt
	if room==6 and pulse>=2.5:
		pulse=0;p.receive_punch(Vector3(-13,2,0),0.5);lab.sound("blast",0.8)
	if room==2 and not cargo.delivered and cargo.position.distance_to(origin()+Vector3(11,0.5,0))<2:
		cargo.release();cargo.delivered=true;lab.sound("success")
	if local.x>14 and absf(local.z)<3 and (room not in [1,5] or local.y>(6.7 if room==1 else 8.7)):
		if room==8:completed=true;leave();lab.notify("Training complete")
		else:room+=1;restart()
