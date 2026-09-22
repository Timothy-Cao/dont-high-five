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
	lab.started=true;lab.set_paused(false);var p=lab.player;var w=lab.session.watcher;var b=lab.builder
	p.testing_input=true
	check(p.avatar.skeleton.find_bone("wheel")>=0 and p.avatar.skeleton.find_bone("thigh_L")==-1,"new rig has a wheel and no legs")
	p.set_ball(true);p.avatar.pose(p,.1)
	check(p.collider.shape==p.stand_shape and p.avatar.body.visible,"launch keeps full-size wheel robot collision and silhouette")
	p.set_ball(false);p.set_crouch(true);p.avatar.pose(p,.2)
	check(p.avatar.body.scale==Vector3.ONE and p.collider.shape.height>1.6,"braking uses shallow suspension compression")
	w.enter();w.cooldowns.grenade=0;w.grenade();await frames(31)
	check(w.cooldowns.grenade<0.00001 and w.grenade(),"grenades repeat at 0.25 seconds")
	for bomb in w.bombs:bomb.node.queue_free()
	w.bombs.clear()
	w.cooldowns.mine=0;check(w.throw_mine() and not w.throw_mine(),"R mine reserves a two-second cooldown")
	var mine=w.mines.back();mine.position=Vector3(0,140.3,0);mine.velocity=Vector3.ZERO
	lab.box(Vector3(0,139.5,0),Vector3(50,1,50),lab.INK);await frames(110)
	check(mine.landed and mine.armed,"thrown mine settles then arms")
	lab.set_paused(true);var age:float=mine.age;await frames(30)
	check(mine.age==age,"pause freezes mine lifetime")
	lab.set_paused(false)
	var target=load("res://scripts/gameplay/test_partner.gd").new();target.lab=lab;target.position=Vector3(3,140,0);lab.add_child(target);target.set_physics_process(false);lab.session.objectives.partners.append(target)
	await frames(3);check(is_instance_valid(mine),"outside one-metre trigger does not detonate")
	target.position=Vector3(.5,140,0);await frames(3)
	check(not is_instance_valid(mine) and target.health<100,"stepping close triggers real blast damage")
	w.cooldowns.mine=0;w.throw_mine();mine=w.mines.back();mine.position=Vector3(0,140.3,0);mine.velocity=Vector3.ZERO;target.position=Vector3(10,140,0);target.health=100
	await frames(3);check(mine.receive_punch(Vector3.ZERO,1),"punch can detonate a mine before or after arming")
	await frames(2);check(target.health==100 and not is_instance_valid(mine),"remote detonation leaves distant target unharmed")
	w.cooldowns.mine=0;w.throw_mine();mine=w.mines.back();mine.age=119.99;await frames(4)
	check(not is_instance_valid(mine),"untriggered mine expires at two minutes")
	lab.session.objectives.partners.erase(target);target.queue_free()
	w.cooldowns.mine=0;w.throw_mine();mine=w.mines.back();mine.position=Vector3(0,140.2,0);mine.velocity=Vector3.ZERO
	w.leave();p.reset_to(Vector3(0,140.05,8));p.camera.look_at(Vector3(0,140.12,0));await frames(3)
	p.combat.begin(1);await frames(45)
	check(not is_instance_valid(mine) and p.health==100,"parallel fist projectiles remotely clear a mine without harming the shooter")
	var original:Vector3=p.position;b.enter();await frames(3)
	check(b.active and not b.testing and b.camera.current and b.entries.is_empty(),"builder opens an empty separate shell with free camera")
	check(not lab.arena.visible and lab.session.process_mode==Node.PROCESS_MODE_DISABLED,"original arena and its simulation are isolated")
	check(b.specs.size()==9,"nine reusable module definitions load")
	var edit_position:Vector3=b.camera.position
	lab.set_paused(true);var event:=InputEventKey.new();event.keycode=KEY_F7;event.pressed=true
	b.handle_input(event);await frames(3)
	check(not b.testing and b.camera.position==edit_position,"pause prevents F7 and freezes edit camera")
	lab.set_paused(false);event.keycode=KEY_F6
	check(b.handle_input(event) and not w.active,"workshop consumes role switch rather than entering a distant tower")
	for spec in b.specs:
		var part=load("res://scripts/world/arena_kit.gd").make(spec);lab.add_child(part)
		check(part.get_child_count()>1 and not part.find_children("*","MeshInstance3D",true,false).is_empty(),"visual and collider load: "+str(spec.id));part.queue_free()
	b.selected=1;b.candidate=Vector3(0,0,0);b.valid=b.can_place(b.candidate,1,0)
	check(b.place(),"place valid snapped wall")
	await frames(3);check(not b.can_place(Vector3.ZERO,1,0),"overlapping placement is rejected")
	check(not b.can_place(Vector3(0,0,24),1,0),"player test spawn stays clear")
	b.undo();check(b.entries.is_empty(),"undo removes placement")
	b.undo(true);check(b.entries.size()==1,"redo restores placement")
	b.remove(0);check(b.entries.is_empty(),"delete removes selected part")
	b.undo();check(b.entries.size()==1,"delete is undoable")
	var path:="res://.local/reports/workshop-test.json"
	check(b.save_map(path)==OK and b.save_map(path)==OK,"save and atomic replacement both succeed")
	b.entries.clear();b.rebuild();check(b.load_map(path) and b.entries.size()==1,"saved layout round-trips with typed catalogue IDs")
	var file:=FileAccess.open("res://.local/reports/workshop-bad.json",FileAccess.WRITE);file.store_string('{"version":1,"parts":[{"part":99,"yaw":0,"pos":[0,0,0]}]}');file.close()
	check(not b.load_map("res://.local/reports/workshop-bad.json") and b.entries.size()==1,"invalid map is rejected without losing current work")
	b.toggle_test();await frames(30)
	check(b.testing and p.is_on_floor() and p.position.y>399,"F7 uses the real player controller on the workshop floor")
	p.input_override=Vector2(1,0);var start:Vector3=p.position;await frames(60);p.input_override=Vector2.ZERO
	check(p.position.distance_to(start)>0.5,"workshop playtest accepts normal movement")
	check(b.load_map("res://assets/maps/workshop-example.json"),"example uses stable module identifiers")
	p.reset_to(b.ORIGIN+Vector3(0,.05,9));p.rotation=Vector3.ZERO;p.input_override=Vector2(0,-1)
	await frames(430);p.input_override=Vector2.ZERO
	check(p.position.z<0 and p.position.y>b.ORIGIN.y+3.9,"real wheel controller traverses the kit ramp onto its raised deck")
	b.toggle_test();check(not b.testing and b.camera.current,"F7 restores edit camera")
	b.leave();check(not b.active and lab.arena.visible and p.position.distance_to(original)<0.01,"return restores original arena and player position")
	print("WORKSHOP RESULT: ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
