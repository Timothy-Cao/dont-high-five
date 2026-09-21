extends Node
var checks:=0
var failures:=0
func check(ok: bool,message: String) -> void:
	checks+=1
	if not ok: failures+=1
	print(("PASS  " if ok else "FAIL  ")+message)
func frames(n: int) -> void:
	for i in n: await get_tree().physics_frame
func clear_shape(p: Node3D,shape: Shape3D,pos: Vector3) -> bool:
	var q:=PhysicsShapeQueryParameters3D.new()
	q.shape=shape;q.transform.origin=pos;q.collision_mask=1
	return p.get_world_3d().direct_space_state.intersect_shape(q,1).is_empty()
func run(lab: Node3D) -> void:
	var a=lab.arena
	var p=lab.player
	p.testing_input=true
	lab.started=true
	lab.set_paused(false)
	await frames(10)
	check(not lab.test_world and a!=null,"normal build loads the connected arena instead of the test bays")
	check(a.find_children("*","Label3D",true,false).is_empty(),"arena contains no instructional or objective signs")
	check(a.sparks.size()>150 and a.pads.size()>15 and a.openings.size()>20,"map contains varied pickups, bounce pads, and genuine openings")
	for i in 4:
		lab.goto_station(i)
		await frames(15)
		check(p.is_on_floor() and p.position.distance_to(lab.spawns[i])<0.2,"entry "+str(i)+" is clear and rests on a real floor")
	# Audit maze connectivity from the generated graph, including upper layers.
	for graph in a.maze_graphs:
		var seen:Dictionary={Vector2i.ZERO:true}
		var queue:Array[Vector2i]=[Vector2i.ZERO]
		while not queue.is_empty():
			var cur:Vector2i=queue.pop_front()
			for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
				var next:Vector2i=cur+d
				if not seen.has(next) and graph.links.has(str(cur)+str(next)):
					seen[next]=true;queue.append(next)
		check(seen.size()==graph.nx*graph.nz,"all maze cells connect at "+str(graph.origin))
	# Check physical routes as well as generation intent: flood-fill a walkable ground grid.
	p.set_physics_process(false)
	var capsule:=CapsuleShape3D.new();capsule.radius=0.34;capsule.height=1.8
	var free:Dictionary={}
	var n:=53
	for x in n:
		for z in n:
			var pos:=Vector3(-71.5+x*2.75,0.96,-71.5+z*2.75)
			if clear_shape(p,capsule,pos): free[Vector2i(x,z)]=pos
	var seed_cell:Vector2i=free.keys()[0]
	var reached:Dictionary={seed_cell:true}
	var queue:Array[Vector2i]=[seed_cell]
	while not queue.is_empty():
		var cur:Vector2i=queue.pop_front()
		for d in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next:Vector2i=cur+d
			if not free.has(next) or reached.has(next): continue
			if p.ray(free[cur],free[next]).is_empty(): reached[next]=true;queue.append(next)
	print("GROUND REACHABILITY ",reached.size()," / ",free.size())
	for cell in free:
		if not reached.has(cell): print("GROUND SAMPLE NEEDS HOP OR CROUCH ",free[cell])
	check(float(reached.size())/free.size()>0.95,"over 95% of sampled walkable ground belongs to one connected region")
	for center in [Vector3.ZERO,Vector3(-49,0,-49),Vector3(49,0,-49),Vector3(-49,0,49),Vector3(49,0,49)]:
		var accessible:=false
		for cell in reached:
			if Vector2(free[cell].x-center.x,free[cell].z-center.z).length()<8: accessible=true;break
		check(accessible,"central hall and corner region reachable on foot: "+str(center))
	var orb_shape:=SphereShape3D.new();orb_shape.radius=0.20
	var blocked:Array=[]
	for i in a.sparks.size():
		if not clear_shape(p,orb_shape,a.sparks[i]): blocked.append({"index":i,"pos":a.sparks[i]})
	print("BLOCKED SPARKS ",blocked)
	check(blocked.is_empty(),"every collectible is clear of solid geometry")
	for xf in a.pockets:
		p.reset_to(xf*Vector3(-2,0.05,3.5))
		check(not p.test_move(p.transform,xf.basis*Vector3(0,0,-5)),"sheltered perch has a full standing entrance: "+str(xf.origin))
		check(not p.ray(xf*Vector3(2,1.5,7),xf*Vector3(2,1.5,-1)).is_empty(),"offset corner breaks the direct sightline into its hiding space")
		p.reset_to(xf*Vector3(5,0.05,0));p.set_ball(true)
		check(not p.test_move(p.transform,xf.basis*Vector3(-3,0,0)),"perch escape slot admits the tucked ball")
		p.set_ball(false)
		check(p.test_move(p.transform,xf.basis*Vector3(-3,0,0)),"perch escape slot requires a small profile")
		check(clear_shape(p,capsule,xf*Vector3(2,0.96,-1)),"hidden corner has room to stand without clipping")
	p.reset_to(Vector3(0,0.05,67.5));p.set_ball(true)
	check(not p.test_move(p.transform,Vector3(0,0,5)),"low cross-passage has an unobstructed crouch shortcut")
	p.set_ball(false)
	check(p.test_move(p.transform,Vector3(0,0,5)),"low cross-passage shortcut blocks an upright body")
	check(clear_shape(p,capsule,Vector3(-3,2.33,71.4)),"hop apex over low passage hurdle clears the overhead roof")
	p.reset_to(Vector3(0,0.05,-10));p.camera.rotation_degrees=Vector3(89,0,0)
	p.fire_hand(0)
	check(not p.hands[0].hit,"shorter gloves cannot directly reach the atrium roof from the floor")
	p.reset_to(Vector3(0,16,-10));p.camera.rotation_degrees=Vector3(89,0,0)
	p.camera.position.y=1.58
	p.fire_hand(0)
	check(p.hands[0].hit and p.hands[0].point.y>33,"gaining height first makes the same roof reachable")
	p.cancel_hands()
	# Crouch/ball shortcut through an actual low aperture, not a painted target.
	p.reset_to(Vector3(14.5,3.25,36))
	p.set_ball(true)
	check(not p.test_move(p.transform,Vector3(0,0,4)),"ball shape can pass through the low tunnel aperture")
	p.set_ball(false)
	check(p.test_move(p.transform,Vector3(0,0,4)),"same aperture blocks a standing body")
	p.reset_to(Vector3(-17,16.05,-66))
	check(not p.test_move(p.transform,Vector3(0,0,34)),"west high gallery passes through both dividing walls")
	p.reset_to(Vector3(18,22.05,-66))
	check(not p.test_move(p.transform,Vector3(0,0,34)),"east high gallery passes through both dividing walls")
	# Real bounce trajectory and original responsive movement on the new floor.
	p.set_physics_process(true)
	p.reset_to(Vector3(-7,0.05,71.4));p.rotation.y=0
	await frames(10)
	p.input_override=Vector2(1,0)
	var hurdles:=[-3.0,3.0]
	var next_hurdle:=0
	for tick in 250:
		if next_hurdle<2 and p.is_on_floor() and p.position.x>hurdles[next_hurdle]-1.7:
			p.jump_buffer=0.10;next_hurdle+=1
		await frames(1)
		if p.position.x>7: break
	check(p.position.x>7 and next_hurdle==2,"two normal jumps traverse the covered hopping passage")
	p.input_override=Vector2.ZERO
	p.reset_to(Vector3(-9,2,3));p.velocity.y=-4
	await frames(45)
	check(p.velocity.y>12 and p.position.y>1,"atrium pad gives a real high bounce")
	p.action_override={"brake":true}
	await frames(180)
	check(p.is_on_floor(),"brake can settle on the powerful arena pad")
	p.action_override={}
	lab.goto_station(0)
	await frames(12)
	p.input_override=Vector2(0,-1)
	await frames(24)
	check(absf(p.velocity.z+7)<0.1,"walking retains its 7 m/s speed in the new arena")
	p.input_override=Vector2.ZERO
	await frames(12)
	check(Vector2(p.velocity.x,p.velocity.z).length()<0.1,"new floor retains clean stopping")
	lab.goto_station(0)
	await frames(10)
	p.camera.look_at(Vector3(-14,7.8,11))
	var zip_before:int=p.zip_count
	check(p.begin_zip(),"wide underside of an atrium bridge accepts the parallel zip")
	await frames(60)
	print("ATRIUM ZIP position=",p.position," velocity=",p.velocity," new launches=",p.zip_count-zip_before)
	check(p.zip_count==zip_before+1 and p.position.y>2,"zip produces actual upward traversal in the new architecture")
	lab.goto_station(0)
	await frames(10)
	p.camera.look_at(Vector3(-14,7.8,11))
	p.fire_hand(0)
	await frames(40)
	p.action_override={"reel":true}
	await frames(90)
	check(p.position.y>3 and p.has_anchor(),"bridge geometry supports sustained grapple reeling")
	p.action_override={}
	p.reset_to(Vector3(-22.18,3,0))
	p.action_override={"cling":true}
	p.hand_recovery=1.0
	await frames(15)
	check(not p.wall_clinging and p.hand_recovery>0,"retracting gloves cannot bypass recovery by gripping a wall")
	p.hand_recovery=0
	await frames(15)
	check(p.wall_clinging and absf(p.velocity.y)<0.05,"atrium walls support stable wall grip")
	p.action_override={}
	p.reset_to(Vector3(-20,0.05,30.5))
	p.rotation.y=0
	p.input_override=Vector2(0,-1)
	await frames(300)
	check(p.position.y>5 and p.is_on_floor(),"the atrium ramp is walkable rather than a collision step")
	p.input_override=Vector2.ZERO
	# A collectible is swept at zip speeds, cannot pay twice, and cannot be taken through cover.
	p.set_physics_process(false)
	a.set_physics_process(false)
	var index:int=a.sparks.size()-1
	var location:Vector3=a.sparks[index]
	a.taken[index]=false
	var before:int=a.collected
	a.collect_at(location-Vector3.RIGHT*2,location+Vector3.RIGHT*2)
	check(a.taken[index] and a.collected>before,"swept collection catches a pickup between movement samples")
	before=a.collected
	a.collect_at(location,location)
	check(a.collected==before,"collected pickup cannot pay out twice")
	# An explicit nearby test barrier isolates occlusion from random maze geometry.
	var barrier=lab.box(Vector3(0,2,73),Vector3(4,4,0.2),lab.INK)
	await frames(2)
	a.sparks[index]=Vector3(0,1,73.4);a.taken[index]=false
	a.collect_at(Vector3(0,1,72.6),Vector3(0,1,72.6))
	check(not a.taken[index],"a wall blocks collecting a nearby spark through it")
	barrier.queue_free()
	# Expanded boundary must not trigger the old 70 m recovery limit.
	p.set_physics_process(true)
	p.reset_to(Vector3(73,0.05,0));p.velocity=Vector3.ZERO
	await frames(10)
	check(p.position.x>72,"outer corridors do not hit the old sandbox reset boundary")
	lab.set_paused(true)
	lab.hud.show_page("Yard")
	await get_tree().process_frame
	await get_tree().process_frame
	check(lab.hud.menu.get_global_rect().encloses(lab.hud.pages.get_global_rect()),"Explore shortcuts fit the menu")
	print("ARENA RESULT: ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
