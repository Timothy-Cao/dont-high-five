extends Node3D
const P=preload("res://scripts/gameplay/props.gd")
var lab:Node3D
var rings:Array[Dictionary]=[]
var cargos:Array[CharacterBody3D]=[]
var partners:Array[CharacterBody3D]=[]
var moving_fivers:=false
var roamers:Array[CharacterBody3D]=[]
var delivered:=false
var highfive_done:=false
var maintenance_done:=false
var dummy_done:=false
var maintenance_step:=0
var maintenance_pos:=Vector3(-12,24.2,-13)
var delivery_pos:=Vector3(-100,0,-12)
var social_pos:=Vector3(-18,0,26)
var previous:=Vector3.ZERO
var complete_flash:=0.0
var maintenance_lamps:Array[MeshInstance3D]=[]
func build() -> void:
	maintenance_pos=lab.session.positions("maintenance")[0];delivery_pos=lab.session.positions("delivery")[0];social_pos=lab.session.positions("social")[0]
	for pos in lab.session.positions("ring"):
		var node=P.ring(self,pos,2.5,Color("77dfcc"),true)
		rings.append({"pos":pos,"node":node,"done":false})
	var cargo=load("res://scripts/gameplay/cargo.gd").new();cargo.lab=lab;cargo.position=lab.session.positions("cargo")[0];add_child(cargo);cargos.append(cargo)
	P.ring(self,delivery_pos+Vector3.UP*0.04,2.2,Color("ffc47b"))
	P.box(self,delivery_pos+Vector3(0,-0.07,0),Vector3(5,0.1,5),Color("384c53"))
	for pos in [social_pos,Vector3(-115,0,14),Vector3(116,20,25)]:
		var partner=load("res://scripts/gameplay/test_partner.gd").new();partner.lab=lab;partner.position=pos;partner.patrol=partners.size()>0;add_child(partner);partners.append(partner)
	P.ring(self,social_pos+Vector3.UP*0.03,3,Color("e991ca"))
	P.box(self,maintenance_pos,Vector3(2.5,1.3,0.3),Color("233f4b"),false)
	for i in 3:
		maintenance_lamps.append(P.orb(self,maintenance_pos+Vector3((i-1)*0.65,0,0.22),0.18,Color("ffc47b"),1))
func progress() -> int:
	var value:=int(delivered)+int(highfive_done)+int(maintenance_done)+int(dummy_done)
	for ring in rings:value+=int(ring.done)
	return value
func reset_tasks() -> void:
	delivered=false;highfive_done=false;maintenance_done=false;dummy_done=false;maintenance_step=0
	for dummy in lab.arena.dummies:dummy.reset_target()
	for cargo in cargos:cargo.reset_cargo()
	for ring in rings:ring.done=false;ring.node.material_override=P.material(Color("77dfcc"),1.4)
	for lamp in maintenance_lamps:lamp.material_override=P.material(Color("ffc47b"),1)
func payoff() -> void:
	complete_flash=1;lab.sound("success")
func highfive(pos:Vector3) -> void:
	if not highfive_done and pos.distance_to(social_pos)<4:highfive_done=true;payoff()
func interact() -> void:
	if maintenance_done or lab.session.training.active or lab.player.impostor:return
	if lab.player.chest().distance_to(maintenance_pos)>3:return
	var direction:Vector3=-lab.player.camera.global_basis.z
	if direction.dot((maintenance_pos-lab.player.camera.global_position).normalized())<0.8:return
	var target:Vector3=maintenance_lamps[[0,2,1][maintenance_step]].global_position
	var aim_dot:float=direction.dot((target-lab.player.camera.global_position).normalized())
	if aim_dot<0.997:return
	maintenance_lamps[[0,2,1][maintenance_step]].material_override=P.material(Color("76eed7"),1)
	maintenance_step+=1
	if maintenance_step==3:maintenance_done=true;payoff()
func hint() -> String:
	if lab.player.chest().distance_to(maintenance_pos)<3 and not maintenance_done:return lab.controls.prompt("interact")+"  Calibrate lit node  ·  %d / 3"%maintenance_step
	if lab.player.position.distance_to(social_pos)<6 and not highfive_done:return "LMB / RMB  High five test partner"
	if lab.player.has_cargo():return ("LMB drop  ·  RMB move" if lab.player.cargo_hand==0 else "RMB drop  ·  LMB move")+"  ·  "+lab.controls.prompt("launch")
	return ""
func _physics_process(dt:float) -> void:
	if lab.paused or lab.session.training.active:return
	complete_flash=maxf(0,complete_flash-dt)
	if not maintenance_done:
		for i in 3:
			maintenance_lamps[i].scale=Vector3.ONE*(1.5 if i==[0,2,1][maintenance_step] else 1.0)
	var p=lab.player
	if lab.session.watcher.active or p.impostor:previous=p.chest();return
	var now:Vector3=p.chest()
	if previous.distance_to(now)<8:
		for ring in rings:
			if ring.done:continue
			var dz:float=now.z-previous.z
			if absf(dz)<0.001:continue
			var t:float=(ring.pos.z-previous.z)/dz
			if t>=0 and t<=1 and previous.lerp(now,t).distance_to(ring.pos)<2.3:
				ring.done=true;ring.node.material_override=P.material(Color("f3dba1"),1.4);payoff()
	previous=now
	if not delivered:
		for cargo in cargos:
			if cargo.position.distance_to(delivery_pos+Vector3.UP*0.5)<2:
				cargo.release();cargo.delivered=true;cargo.position=delivery_pos+Vector3.UP*0.5;delivered=true;payoff()
	if not dummy_done:
		for dummy in lab.arena.dummies:
			if dummy.knocked_out and dummy.last_hit_kind=="punch":dummy_done=true;payoff();break

func set_moving_fivers(enabled:bool) -> void:
	if moving_fivers==enabled:return
	moving_fivers=enabled
	if not enabled:
		for actor in roamers:partners.erase(actor);actor.queue_free()
		roamers.clear();return
	var speeds=[5.0,8.0,12.0,18.0,24.0,30.0,36.0,40.0]
	for i in 8:
		var actor=load("res://scripts/gameplay/test_partner.gd").new()
		actor.lab=lab;actor.roamer=true;actor.roam_speed=speeds[i];actor.roam_heading=i*TAU/8
		actor.position=lab.session.watcher.infiltration_spawn(i%lab.session.watcher.towers.size())
		add_child(actor);partners.append(actor);roamers.append(actor)
