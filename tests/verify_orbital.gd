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
	lab.started=true;lab.set_paused(false);var p=lab.player;var w=lab.session.watcher
	p.testing_input=true;p.set_physics_process(false);w.enter();w.cut_power()
	var nv=w.night_vision
	await frames(30)
	check(w.camera.environment==null and not nv.screen.visible and nv.gain==0,"first quarter second of blackout has no night vision")
	lab.set_paused(true);var age:float=nv.elapsed;await frames(20)
	check(nv.elapsed==age,"pause freezes night-vision startup")
	lab.set_paused(false);await frames(33)
	check(nv.gain==0 and not nv.screen.visible,"blackout remains dark after the former night-vision delay")
	await frames(65)
	check(nv.gain==0 and w.camera.environment==null,"blackout never automatically grants a bright camera environment")
	w.cut_power();check(w.camera.environment==null and not nv.screen.visible,"turning lights on immediately cancels night vision")
	w.cut_power();await frames(12);w.cut_power();await frames(120)
	check(not nv.screen.visible and w.camera.environment==null,"rapid toggles cannot leave a delayed green overlay behind")
	w.cut_power();await frames(15);w.leave();await frames(120)
	check(not nv.screen.visible and p.camera.environment==null,"leaving Watcher during startup never gives Fiver night vision")
	w.cut_power();w.enter();w.camera.position=Vector3(0,146,0);w.camera.rotation=Vector3.ZERO
	w.cooldowns.gun=0;w.scope=true;w.manual_fire();var count:int=w.shots
	await frames(30);w.manual_fire();check(w.shots==count,"sniper rejects another shot after 0.25 seconds")
	await frames(20);w.manual_fire();check(w.shots==count+1,"sniper fires again after 0.4 seconds")
	w.scope=false;w.cooldowns.grenade=0;check(w.grenade() and not w.grenade(),"grenade rejects an immediate repeat")
	await frames(32);check(w.grenade(),"grenade can repeat after a quarter second")
	for bomb in w.bombs:bomb.node.queue_free()
	w.bombs.clear()
	var floor=lab.box(Vector3(0,139.5,0),Vector3(100,1,100),lab.INK)
	var roof=lab.box(Vector3(0,169.5,0),Vector3(100,1,100),lab.INK)
	var wall=lab.box(Vector3(-8,145,0),Vector3(1,10,10),lab.INK)
	await frames(2);w.camera.look_at(Vector3(1,140,0));w.cooldowns.strike=0
	check(w.strike() and w.cooldowns.strike==5 and not w.strike(),"airstrike reserves its five-second cooldown when marked")
	# Remove warning: isolate field damage from a second delayed activation.
	for marker in w.strikes:marker.node.queue_free()
	w.strikes.clear()
	var targets:Array[Node3D]=[]
	for pos in [Vector3(14,140,0),Vector3(20,140,0),Vector3(-12,140,0),Vector3(0,170,0)]:
		var target=load("res://scripts/gameplay/test_partner.gd").new();target.lab=lab;target.position=pos;lab.add_child(target);target.set_physics_process(false);lab.session.objectives.partners.append(target);targets.append(target)
	await frames(2)
	var field=w.begin_orbital(Vector3(0,140.12,0))
	check(field.RADIUS==18 and field.height>28 and field.height<30,"orbital field has 18 m radius and clips to the actual ceiling")
	check(field.columns.size()==1 and field.columns[0].visible and field.columns[0].mesh.cap_top and field.columns[0].mesh.cap_bottom,"live orbital column encloses its complete footprint, including top and bottom")
	var solid_shader:String=field.curtains[0].shader.code
	check(not solid_shader.contains("ALPHA") and not solid_shader.contains("blend_add"),"orbital body uses the opaque rendering path rather than transparent blending")
	await frames(64)
	check(targets[0].health<70 and targets[0].health>50,"sustained ticks damage a target beyond the old ten-metre radius")
	check(targets[1].health==100,"targets outside the larger radius remain safe")
	check(targets[2].health==100,"solid walls still provide cover from the field")
	check(targets[3].health==100,"a floor above the field's ceiling remains safe")
	lab.set_paused(true);var health:float=targets[0].health;age=field.age;await frames(20)
	check(field.age==age and targets[0].health==health and field.sound.stream_paused,"pause freezes orbital visuals, damage and sound together")
	lab.set_paused(false);await frames(140)
	check(targets[0].health==0,"remaining inside the column is dangerous over time")
	await frames(380)
	check(not is_instance_valid(field),"orbital column and its audio clean up after the burn and fade")
	check(not w.strike(),"airstrike still rejects a repeat just before five seconds")
	await frames(30)
	check(w.cooldowns.strike==0 and w.strike(),"airstrike becomes available again after five seconds")
	for target in targets:lab.session.objectives.partners.erase(target);target.queue_free()
	floor.queue_free();roof.queue_free();wall.queue_free()
	print("ORBITAL RESULT: ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
