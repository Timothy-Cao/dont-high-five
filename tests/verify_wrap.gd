extends Node
var checks:=0
var failures:=0
func check(ok:bool,message:String) -> void:
	checks+=1
	if not ok:failures+=1
	print(("PASS  " if ok else "FAIL  ")+message)
func frames(n:int) -> void:
	for i in n:await get_tree().physics_frame
func latch(p:CharacterBody3D,fixed:bool) -> void:
	p.reset_to(Vector3(10,150,3));p.fixed_mode=fixed;p.gravity=0
	var h:Dictionary=p.hands[0];h.state=2;h.point=Vector3(0,151.15,2);h.normal=Vector3.BACK
	if fixed:p.fixed_rope.attach(p,0)
	else:h.rest=12
	h.spool_target=h.rest
	p.velocity=Vector3(0,0,-12)
func run(lab:Node3D) -> void:
	var p=lab.player;lab.started=true;lab.set_paused(false);p.testing_input=true;lab.arena.powerups.testing=true
	p.set_physics_process(false)
	var column=lab.box(Vector3(0,150,0),Vector3(4,30,4),lab.INK)
	await frames(3)
	var h:Dictionary=p.hands[0];h.state=2;h.point=Vector3(0,151.15,2);h.normal=Vector3.BACK
	var route=h.route
	var good:=true;var bent:=false;var max_length:=0.0
	for step in 37:
		var a:float=step*PI/24
		var at:=Vector3(sin(a)*8,151.15,cos(a)*8)
		route.update(p,h,at,Vector3(cos(a),0,-sin(a))*12,1.0/120)
		var path:Array[Vector3]=route.points();path.append(h.point+h.normal*0.1)
		bent=bent or path.size()>1;var previous:Vector3=at
		for point in path:
			good=good and route.obstructed(p,previous,point).is_empty()
			good=good and absf(point.y-151.15)<0.05
			previous=point
		max_length=maxf(max_length,route.length_from(at,h.point))
	check(good and bent,"contact path follows 270 degrees around a column without cutting through it or going over its roof")
	check(max_length>10 and route.bends.size()<=12,"wrapping accounts for consumed arm length and bounds contact count")
	route.update(p,h,Vector3(0,151.15,8),Vector3.ZERO,0.1)
	check(route.bends.is_empty(),"returning to clear line of sight unwraps all contacts")
	# Real CharacterBody motion must pass the old gate, in both modes.
	for fixed in [false,true]:
		latch(p,fixed);p.set_physics_process(true)
		var maximum_speed:=0.0;var penetrated:=false;var used_bend:=false
		for tick in 120:
			await frames(1)
			maximum_speed=maxf(maximum_speed,p.velocity.length())
			penetrated=penetrated or (absf(p.position.x)<2.3 and absf(p.position.z)<2.3)
			used_bend=used_bend or not h.route.bends.is_empty()
		print("WRAP MOTION fixed=",fixed," position=",p.position," speed=",p.velocity.length()," path=",p.arm_length(h,p.chest())," rest=",h.rest)
		check(p.position.z< -2.5 and used_bend,"real swing passes behind the column instead of stopping at the old angle gate: "+str(fixed))
		check(not penetrated and maximum_speed<12.2,"wrapping preserves body collision without injecting speed: "+str(fixed))
		if fixed:check(p.arm_length(h,p.chest())<=h.rest+0.12,"fixed route spends existing length on bends rather than granting extra reach")
		p.set_physics_process(false);p.cancel_hands()
		check(h.route.bends.is_empty(),"recalling clears corner state: "+str(fixed))
	# Rotated cover and multiple distinct obstacles.
	column.rotation.y=0.4;await frames(2)
	h.state=2;h.point=Vector3(-7,151,0);h.normal=Vector3.LEFT
	route.update(p,h,Vector3(7,151,0),Vector3(0,0,10),0.1)
	var path:Array[Vector3]=route.points();path.append(h.point+h.normal*0.1);var from:=Vector3(7,151,0);good=not route.bends.is_empty()
	for point in path:good=good and route.obstructed(p,from,point).is_empty();from=point
	check(good,"rotated collision boxes produce an unobstructed route")
	column.queue_free();await frames(2);route.update(p,h,Vector3(7,151,0),Vector3.ZERO,0.1)
	check(route.bends.is_empty(),"removing cover removes its contact points")
	var blocks:Array[Node3D]=[]
	for x in [0,5]:blocks.append(lab.box(Vector3(x,150,0),Vector3(2,20,3),lab.INK))
	await frames(2)
	h.point=Vector3(-5,151,0);h.normal=Vector3.LEFT
	for i in 8:route.update(p,h,Vector3(9,151,0),Vector3(0,0,10),0.12)
	path=route.points();path.append(h.point+h.normal*0.1);from=Vector3(9,151,0);good=route.bends.size()>1
	for point in path:good=good and route.obstructed(p,from,point).is_empty();from=point
	check(good,"one arm routes around two separate pieces of cover")
	for block in blocks:block.queue_free()
	p.cancel_hands();await frames(2)
	var w=lab.session.watcher;w.enter();w.pitch=0;w.yaw=0
	var event:=InputEventMouseMotion.new();event.screen_relative=Vector2(100,40)
	w.scope=false;w.handle_input(event);var full:=Vector2(w.yaw,w.pitch)
	w.pitch=0;w.yaw=0;w.scope=true;w.handle_input(event)
	check(Vector2(w.yaw,w.pitch).is_equal_approx(full*0.5),"tower scoped yaw and pitch are exactly half normal sensitivity")
	w.leave()
	print("CORNER WRAP RESULT: ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
