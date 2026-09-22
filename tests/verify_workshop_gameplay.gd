extends Node
var checks:=0
var failures:=0
func check(ok:bool,message:String) -> void:
	checks+=1
	if not ok:failures+=1
	print(("PASS  " if ok else "FAIL  ")+message)
func frames(n:int) -> void:
	for i in n:await get_tree().physics_frame
func entry(b:Node,id:String,pos:Vector3,turn:=0) -> Dictionary:
	for i in b.specs.size():
		if b.specs[i].id==id:return {"part":i,"pos":[pos.x,pos.y,pos.z],"yaw":turn}
	return {}
func run(lab:Node3D) -> void:
	lab.started=true;lab.set_paused(false)
	var b=lab.builder;var p=lab.player;var original=lab.session;p.testing_input=true;p.health=73
	b.enter();b.entries=[entry(b,"spawn",Vector3(0,0,12),1),entry(b,"tower",Vector3(-24,0,-24)),entry(b,"tower",Vector3(24,0,-24)),entry(b,"cargo",Vector3(-8,0,8)),entry(b,"socket",Vector3(8,0,8)),entry(b,"ring",Vector3(0,0,-10),1),entry(b,"portal_a",Vector3(-40,0,0)),entry(b,"portal_b",Vector3(40,0,0),1),entry(b,"light",Vector3(0,10,0))]
	b.rebuild();await frames(3);b.toggle_test();await frames(3)
	check(b.testing and lab.session!=original,"placed objects create an isolated gameplay session")
	check(p.position.distance_to(b.ORIGIN+Vector3(0,.05,12))<.2 and absf(p.rotation.y-PI/2)<.01,"placed start controls position and facing")
	var s=lab.session;var w=s.watcher;var o=s.objectives
	check(w.towers.size()==2 and o.total()==2 and o.cargos.size()==1 and o.travel.portals.size()==2,"runtime builds exactly the placed towers, objectives and portal pair")
	check(not w.auto_fire and not w.demo_patrol,"new workshop defaults to peaceful pressure")
	lab.hud.minimap.context="workshop";lab.hud.minimap.collect_geometry()
	check(lab.hud.minimap.actor_markers().size()==2 and lab.hud.minimap.markers.filter(func(m):return m.kind=="portal").size()==2,"overview shows placed towers and portals")
	var role_key:=InputEventKey.new();role_key.keycode=KEY_F6;role_key.pressed=true;p._unhandled_input(role_key);await frames(2)
	check(w.active and w.camera.position.y>400,"F6 enters a local workshop tower")
	var shots:int=w.shots;w.fire(w.camera.position,Vector3.DOWN,55,0)
	check(w.shots==shots+1 and w.grenade(),"placed tower uses working gun and grenade abilities")
	w.leave();w.set_pressure("One tower");await frames(3)
	check(w.auto_fire and w.single_tower and not w.tower_ai.states[1].ready,"one-tower preset excludes the other tower")
	w.set_pressure("Patrol");await frames(2)
	check(w.demo_patrol and not w.auto_fire and not w.single_tower,"patrol switches to roaming laser hazards")
	w.set_pressure("Chaos");check(w.auto_fire and not w.single_tower,"chaos activates all towers")
	w.set_pressure("Peaceful");p.set_physics_process(false)
	var cargo=o.cargos[0];cargo.set_physics_process(false)
	check(cargo.try_pickup(p,0) and p.cargo_hand==0 and p.hands[1].state==0,"workshop core occupies only its carrying hand")
	cargo.position=o.sockets[0].pos+Vector3.UP*.5;await frames(2)
	check(cargo.delivered and not p.has_cargo() and o.progress()==1,"core delivery releases its hand and completes a socket")
	var xf:Transform3D=o.rings[0].xf;o.previous=xf*Vector3(0,0,1);p.position=xf*Vector3(0,0,-1)-(p.chest()-p.position);await frames(2)
	check(o.rings[0].done and o.progress()==2,"rotated traversal ring detects a real crossing")
	o.reset_tasks();check(o.progress()==0 and not cargo.delivered,"reset makes workshop objectives repeatable")
	p.velocity=Vector3(0,0,-25)
	check(o.travel.transfer(p,0,1,Vector3(0,-1.2,0)) and absf(p.velocity.length()-25)<.01 and p.position.x>39,"linked portal rotates and preserves launch momentum")
	var blocked=o.travel.portals[1].xf*Vector3(0,-1.2,1.2)
	var obstacle=preload("res://scripts/gameplay/props.gd").box(lab,blocked,Vector3(3,3,3),Color.BLACK);await frames(2)
	check(not o.travel.transfer(p,0,1,Vector3(0,-1.2,0)),"blocked portal exit refuses unsafe teleport")
	obstacle.queue_free();cargo.try_pickup(p,0);w.cut_power();await frames(2);b.toggle_test();await frames(3)
	check(not p.has_cargo() and p.cargo_hand==-1 and p.hands[0].state!=4,"ending a test while carrying clears cargo and occupied-hand state")
	check(lab.session==original and p.health==73 and not b.testing and lab.environment.ambient_light_energy>0,"edit restores original session, health and lighting")
	check(not is_instance_valid(s),"temporary gameplay session is freed on return to edit")
	b.selection.toggle(0);b.selection.toggle(3);b.selection.begin(false);b.selection.offset=Vector3(0,0,8)
	var start_pos:Array=b.entries[0].pos.duplicate();var cargo_pos:Array=b.entries[3].pos.duplicate()
	check(b.selection.commit() and b.entries[0].pos[2]==20 and b.entries[3].pos[2]==16,"group move preserves relative spacing in one transaction")
	b.undo();await frames(2)
	check(b.entries[0].pos==start_pos and b.entries[3].pos==cargo_pos,"one undo restores the entire group")
	b.selection.toggle(3);b.selection.toggle(4);b.selection.begin(true);b.selection.offset=Vector3(0,0,-24)
	check(b.selection.commit() and b.entries.size()==11,"duplicate creates a group without moving originals")
	b.undo();await frames(2)
	check(b.entries.size()==9,"one undo removes the whole duplicate")
	b.selection.toggle(3);b.selection.begin(false);b.selection.offset=Vector3(500,0,0)
	check(not b.selection.commit() and b.entries[3].pos==cargo_pos,"invalid group move leaves original data untouched")
	b.selection.cancel();check(not b.selection.pending and b.selection.offset==Vector3.ZERO,"cancel restores the edit preview")
	b.selection.toggle(4);b.selection.remove();check(b.entries.size()==7,"group delete removes exactly the selected parts")
	b.undo();await frames(2);check(b.entries.size()==9,"group delete is undoable")
	var path:="res://.local/reports/workshop-gameplay.json";b.save_map(path);b.entries.clear();b.rebuild();b.load_map(path)
	check(b.entries.size()==9 and b.specs[b.entries[7].part].id=="portal_b","functional gameplay parts persist through stable IDs")
	b.entries.remove_at(7);b.rebuild();b.toggle_test()
	check(not b.testing and "Portal" in b.status,"unpaired portal has actionable validation and cannot start")
	b.load_map(path);await frames(2);b.toggle_test();await frames(2)
	check(b.testing and lab.session.watcher.towers.size()==2,"repeated edit/play cycle rebuilds the layout cleanly")
	lab.set_paused(true);lab.hud.show_page("Playtest");lab.hud.show_page("Build");await frames(2)
	check(lab.hud.pages.get_child_count()>8,"workshop palette and pressure menu build without arena-only controls")
	b.leave();await frames(2)
	check(lab.session==original and not b.active and original.process_mode==Node.PROCESS_MODE_INHERIT,"leaving during gameplay resumes original arena")
	print("WORKSHOP GAMEPLAY RESULT: ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
