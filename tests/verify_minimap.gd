extends Node
var checks:=0
var failures:=0
func check(ok:bool,message:String) -> void:
	checks+=1
	if not ok:failures+=1
	print(("PASS  " if ok else "FAIL  ")+message)
func frames(n:int) -> void:
	for i in n:await get_tree().physics_frame
func covered(polygons:Array,point:Vector2) -> bool:
	for polygon in polygons:
		if Geometry2D.is_point_in_polygon(point,polygon):return true
	return false
func run(lab:Node3D) -> void:
	lab.started=true;lab.set_paused(false);var p=lab.player;var map=lab.hud.minimap;var w=lab.session.watcher
	p.testing_input=true;p.set_physics_process(false)
	lab.box(Vector3(0,139.75,0),Vector3(60,.5,60),lab.INK)
	lab.box(Vector3(-20,159.75,-20),Vector3(10,.5,10),lab.INK)
	lab.box(Vector3(10,142,0),Vector3(2,4,10),lab.INK)
	var ramp=lab.box(Vector3(-10,141,0),Vector3(3,.3,10),lab.INK);ramp.rotation.x=.25
	p.reset_to(Vector3(0,140.05,0));await frames(4)
	map.collect_geometry();map.sample_floor(.1,true)
	check(map.enabled and map.visible and absf(map.floor_y-140)<.1,"map is enabled and selects actual support beneath the player")
	check(covered(map.plan.floors,Vector2(-20,-20)),"ground remains traversable below an overhead deck")
	check(covered(map.plan.walls,Vector2(10,0)),"wall footprint comes from real collision at body height")
	check(not covered(map.plan.walls,Vector2(0,0)),"open lane is not marked as blocked")
	check(not map.plan.ramps.is_empty(),"tilted collision surfaces become ramp connections")
	map.floor_y=160;map.rebuild_slice()
	check(covered(map.plan.floors,Vector2(-20,-20)) and not covered(map.plan.floors,Vector2(0,0)),"upper slice distinguishes its deck from a real void")
	check(not covered(map.plan.walls,Vector2(10,0)),"lower wall does not leak into upper slice")
	map.floor_y=140;p.position=Vector3(0,150,0);map.sample_floor(1)
	check(map.floor_y==140,"airborne movement keeps the previous navigation floor")
	p.position=Vector3(-20,160.05,-20)
	for i in 4:map.sample_floor(.1)
	check(map.floor_y==160,"approaching upper support switches floor after a short stable delay")
	var actors:Array=map.actor_markers()
	check(actors.filter(func(item):return item.kind=="tower").size()==7,"whole-arena overview includes all seven numbered towers")
	check(actors.filter(func(item):return item.kind=="fiver").size()==lab.session.objectives.partners.size(),"overview includes living local Fivers on all floors")
	var partner=lab.session.objectives.partners[0];var old:Vector3=partner.position
	partner.position+=Vector3.RIGHT*10
	check(map.actor_markers().any(func(item):return item.kind=="fiver" and item.pos==partner.position),"Fiver markers follow actual movement")
	partner.health=0
	check(map.actor_markers().filter(func(item):return item.kind=="fiver").size()==lab.session.objectives.partners.size()-1,"dead Fivers disappear from the overview")
	partner.health=100;partner.position=old
	check(map.map_point(Vector3.ZERO,Vector2.ZERO,Vector3(-100,0,0))==map.map_point(Vector3.ZERO,Vector2.ZERO,Vector3(100,0,0)),"arena projection remains fixed when the player moves")
	check(map.marker_in_view(Vector3(151,35,119)) and not map.marker_in_view(Vector3(170,0,0)),"overview covers both distant arena corners across floors")
	p.rotation.y=PI/2
	check(is_equal_approx(map.heading(),PI/2),"direction marker follows actual heading without rotating architecture")
	var builds:int=map.refreshes;await frames(30)
	check(map.refreshes==builds,"stationary map reuses its raster instead of rebuilding every frame")
	w.cut_power();await frames(3)
	check(map.modulate.a<.4,"blackout dims the map")
	w.cut_power();lab.set_paused(true);await frames(2)
	check(not map.visible,"pause hides minimap behind menus")
	lab.set_paused(false);var press:=InputEventKey.new();press.physical_keycode=lab.controls.keys.minimap;press.pressed=true
	p._unhandled_input(press);await frames(2)
	check(not map.enabled and not map.visible,"rebindable M toggle hides the map")
	p._unhandled_input(press);w.enter();await frames(3)
	check(map.visible and map.focus()==w.camera.global_position and map.actor_markers().filter(func(item):return item.kind=="tower" and item.selected).size()==1,"Watcher overview highlights its selected tower")
	w.leave();lab.builder.enter();await frames(3)
	check(not map.visible,"building mode keeps its canvas clear")
	lab.builder.toggle_test();await frames(4)
	check(map.visible and map.context=="workshop" and map.floor_y==400,"workshop playtest uses its own floor geometry")
	check(map.actor_markers().is_empty(),"workshop excludes distant arena actors")
	var old_revision:int=map.revision;lab.builder.load_map("res://assets/maps/workshop-example.json");await frames(20)
	check(map.revision>old_revision and not map.plan.ramps.is_empty(),"loading or editing workshop geometry refreshes the map")
	print("MINIMAP BUILD: ",map.last_build_usec," us, ",map.shapes.size()," collision shapes")
	print("MINIMAP RESULT: ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
