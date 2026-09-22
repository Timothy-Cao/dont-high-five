extends Node
var checks:=0
var failures:=0
func check(ok:bool,message:String) -> void:
	checks+=1
	if not ok:failures+=1
	print(("PASS  " if ok else "FAIL  ")+message)
func frames(n:int) -> void:
	for i in n:await get_tree().physics_frame
func key(p:Node,code:int) -> void:
	var event:=InputEventKey.new();event.keycode=code;event.pressed=true;p._unhandled_input(event)
func run(lab:Node3D) -> void:
	lab.started=true;lab.set_paused(false);var p=lab.player;var w=lab.session.watcher
	p.testing_input=true
	check(not lab.controls.keys.has("preview") and not lab.controls.permitted(KEY_F7),"trajectory binding removed and F7 reserved")
	key(p,KEY_F7);await frames(140)
	check(w.blackout>0 and w.camera.environment==null and not w.night_vision.screen.visible,"Fiver F7 toggles persistent darkness without night vision")
	w.enter();await frames(3)
	check(w.camera.environment==null,"changing role does not grant night vision")
	key(p,KEY_E);check(w.mines.size()==1 and w.cooldowns.mine==2,"Watcher E throws the mine")
	key(p,KEY_R);check(w.reveal_left==5 and w.cooldowns.reveal==5,"R starts five-second reveal and five-second cooldown")
	check(not w.reveal_players(),"reveal cannot immediately retrigger")
	await frames(3)
	check(w.reveal.visible and w.reveal.copies.size()>=3,"live Fivers have visible silhouette proxies in Watcher view")
	var layer:int=w.reveal.LAYER
	check((p.camera.cull_mask&layer)==0 and (p.follow_camera.cull_mask&layer)==0 and (w.camera.cull_mask&layer)!=0,"reveal layer is private to Watcher in either Fiver camera")
	check(w.darkness.exempt(w.reveal),"reveal survives full blackout independently of night vision")
	lab.set_paused(true);var left:float=w.reveal_left;await frames(30)
	check(w.reveal_left==left,"pause freezes reveal and cooldown")
	lab.set_paused(false);w.leave();await frames(2)
	check(not w.reveal.visible,"leaving Watcher immediately hides all silhouettes")
	w.enter();await frames(610)
	check(w.reveal_left==0 and not w.reveal.visible and w.reveal_players(),"reveal expires and becomes reusable after five seconds")
	key(p,KEY_F7);check(w.blackout==0,"Watcher can also toggle the testing blackout")
	w.leave();w.demo_patrol=true;p.health=100000;await frames(3)
	check(w.tower_ai.states.all(func(state):return is_instance_valid(state.beam) and state.beam.visible),"all unattended towers display scoped patrol lasers")
	var before:Vector3=w.towers[0].rig.rotation;await frames(60)
	check(w.towers[0].rig.rotation.distance_to(before)>.001,"patrol aim sweeps continuously")
	var state:Dictionary=w.tower_ai.states[0];state.demo_grenade=0;state.demo_strike=0
	var grenades:int=w.tower_ai.grenades_fired;await frames(2)
	check(w.tower_ai.grenades_fired>grenades and state.demo_grenade>=13,"ambient grenade fires then waits a sparse interval")
	check(state.demo_strike>27,"ambient orbital attempts use a separate long interval")
	w.enter();await frames(2)
	check(not w.tower_ai.states[w.selected].beam.visible,"piloting an eye suppresses that eye's autonomous laser")
	w.demo_patrol=false;await frames(2)
	check(w.tower_ai.states.all(func(item):return not item.beam.visible),"demo toggle removes every patrol laser")
	w.leave();p.velocity=Vector3(0,0,-3);p.rotation=Vector3.ZERO;p.avatar.wheel_angle=0;p.avatar.pose(p,.05)
	check(p.avatar.wheel_angle>PI,"forward travel spins the tire in the corrected direction")
	check(lab.builder.can_place(Vector3(100,0,80),1,0),"workshop accepts parts at the real arena scale")
	print("REVEAL DEMO RESULT: ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
