extends Node
var checks:=0
var failures:=0
func check(ok:bool,message:String) -> void:
	checks+=1
	if not ok:failures+=1
	print(("PASS  " if ok else "FAIL  ")+message)
func frames(n:int) -> void:
	for i in n:await get_tree().physics_frame
func run(lab:Node3D) -> void:
	lab.started=true;lab.set_paused(false);var p=lab.player;var w=lab.session.watcher;var o=lab.session.objectives
	p.testing_input=true;p.set_physics_process(false);p.position=Vector3(0,145,0)
	check(not o.moving_fivers and not w.auto_fire,"crowd and tower AI are opt-in")
	o.set_moving_fivers(true);check(o.roamers.size()==8 and o.partners.size()==11,"toggle creates exactly eight extra targets")
	o.set_moving_fivers(true);check(o.roamers.size()==8,"repeated enable never duplicates actors")
	var starts:Array[Vector3]=[]
	for actor in o.roamers:starts.append(actor.position)
	await frames(600)
	var moved:=0
	for i in 8:
		if o.roamers[i].position.distance_to(starts[i])>3:moved+=1
	print("ROAMERS moved >3m: ",moved)
	check(moved>=7,"at least seven real-arena actors travel meaningfully in five seconds")
	check(o.roamers[7].roam_speed==p.max_speed and o.roamers[0].roam_speed==5,"speeds span walking to full base slingshot speed")
	lab.set_paused(true);var pos:Vector3=o.roamers[7].position;await frames(30)
	check(o.roamers[7].position==pos,"pause freezes moving actors")
	lab.set_paused(false)
	var victim=o.roamers[0];victim.take_damage(100,Vector3.ZERO)
	check(victim.respawn>0 and not victim.model.visible and victim.collision_layer==0,"death removes the living target and starts respawn")
	var corpse:Node3D=null
	for node in lab.get_children():
		if node.get_script()==load("res://scripts/gameplay/fiver_death.gd"):corpse=node
	await frames(85)
	check(is_instance_valid(corpse) and absf(corpse.visual.rotation.x)>1.5,"death visibly topples onto its back without squashing")
	await frames(290)
	check(victim.health==100 and victim.model.visible and victim.respawn==0,"dead moving Fiver respawns and resumes")
	check(not is_instance_valid(corpse),"cosmetic corpse expires before respawn")
	o.set_moving_fivers(false);await frames(2)
	check(o.partners.size()==3 and o.roamers.is_empty(),"disable removes all eight extra targets")
	# Isolated visible tower/target lane above the arena.
	lab.box(Vector3(0,139.5,0),Vector3(150,1,150),lab.INK)
	await frames(2)
	p.position=Vector3(0,140.1,-35);p.health=100000;p.respawn_left=0
	var original:Vector3=w.towers[0].pos;w.towers[0].pos=Vector3(0,150,0)
	for i in range(1,7):w.towers[i].blind=100
	w.auto_fire=true;w.tower_ai.states.clear();var shots:int=w.shots
	await frames(55)
	check(w.shots==shots and not w.tower_ai.states[0].history.is_empty(),"AI waits through its reaction delay before first shot")
	var previous:Vector3=p.position;p.position.x+=20
	await frames(25)
	check(w.tower_ai.states[0].ready and w.tower_ai.states[0].aim.x<5,"tower fires at the older position after target moves")
	await frames(80)
	check(w.shots>shots,"sniper AI fires actual damaging weapon shots")
	check(w.tower_ai.grenades_fired>0 and w.tower_ai.strikes_fired>0,"AI autonomously uses both grenade and orbital abilities")
	check(w.tower_ai.states[0].sniper and not w.tower_ai.states[1].sniper,"neighboring towers alternate sniper and machine gun")

	w.towers[0].blind=100;w.towers[1].blind=0
	var second_origin:Vector3=w.towers[1].pos;w.towers[1].pos=Vector3(0,150,0)
	shots=w.shots;await frames(230)
	check(w.shots>=shots+10,"machine-gun tower fires a real sustained burst")
	var cover=lab.box(Vector3(10,150,-18),Vector3(55,35,1),lab.INK)
	await frames(30);shots=w.shots;await frames(80)
	check(w.shots==shots and not w.tower_ai.states[1].ready,"losing line of sight clears tracking and stops gunfire")
	cover.queue_free();await frames(100);w.towers[1].blind=5;shots=w.shots;await frames(70)
	check(w.shots==shots,"blinding an automated eye interrupts shooting")
	w.towers[1].pos=second_origin
	lab.set_paused(true);shots=w.shots;var time:float=w.tower_ai.elapsed;await frames(40)
	check(w.shots==shots and w.tower_ai.elapsed==time,"pause freezes AI timers and shooting")
	lab.set_paused(false);w.auto_fire=false;await frames(2);shots=w.shots;await frames(80)
	check(w.shots==shots and not w.tower_ai.states[0].ready,"switching AI off cancels acquisition and future shots")
	var removed:=Node3D.new();lab.add_child(removed);w.tower_ai.states[0].target=removed;removed.queue_free()
	await frames(2);w.auto_fire=true;w.towers[0].blind=0;w.tower_ai.states[0].sample=0;await frames(2)
	check(is_instance_valid(w.tower_ai.states[0].target),"freed crowd targets are safely reacquired")
	w.auto_fire=false
	w.towers[0].pos=original
	var field=w.begin_orbital(Vector3(0,140,0))
	check(field.VISUAL_HEIGHT==180 and field.filaments[0].mesh.height>179,"orbital filaments span the entire vertical arena")
	p.health=100;p.respawn_left=0;p.take_damage(1000,Vector3.ZERO)
	check(p.respawn_left>0 and p.collision_layer==0,"local player uses the same collapse and respawn flow")
	print("CROWD RESULT: ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
