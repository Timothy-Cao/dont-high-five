extends Control
## Whole-arena north-up overview. Architecture follows the local floor; actors span all levels.
const Plan=preload("res://scripts/minimap_plan.gd")
const RANGE:=160.0
const MAP_SIZE:=260.0
const MAP_HEIGHT:=208.0
const EDGES=[[0,1],[0,2],[0,4],[1,3],[1,5],[2,3],[2,6],[3,7],[4,5],[4,6],[5,7],[6,7]]
var lab:Node3D
var enabled:=true
var floor_y:=0.0
var context:=""
var revision:=-1
var shapes:Array[Dictionary]=[]
var markers:Array[Dictionary]=[]
var ramp_links:Array[Dictionary]=[]
var atlas:SubViewport
var plan:Control
var scan_clock:=0.0
var candidate_floor:=0.0
var candidate_age:=0.0
var refreshes:=0
var last_build_usec:=0
var font:=ThemeDB.fallback_font
var panel_style:=StyleBoxFlat.new()
func _ready() -> void:
	mouse_filter=Control.MOUSE_FILTER_IGNORE
	panel_style.bg_color=Color(.035,.07,.095,.93);panel_style.set_corner_radius_all(8)
	atlas=SubViewport.new();atlas.size=Vector2i(1280,1024);atlas.disable_3d=true
	atlas.render_target_update_mode=SubViewport.UPDATE_DISABLED;add_child(atlas)
	plan=Plan.new();atlas.add_child(plan)
func focus() -> Vector3:
	return lab.session.watcher.camera.global_position if lab.session.watcher.active else lab.player.global_position
func heading() -> float:
	return lab.session.watcher.camera.global_rotation.y if lab.session.watcher.active else lab.player.global_rotation.y
func relevant() -> bool:
	return enabled and lab.started and not lab.paused and lab.session!=null and not lab.session.training.active and not (lab.builder and lab.builder.active and not lab.builder.testing)
func invalidate() -> void:revision=-1
func collect_geometry() -> void:
	shapes.clear();markers.clear();ramp_links.clear()
	for col in lab.find_children("*","CollisionShape3D",true,false):
		var body=col.get_parent()
		if col.disabled or not body is StaticBody3D or (body.collision_layer&1)==0 or not body.is_visible_in_tree():continue
		var points:=PackedVector3Array();var ramp:=false
		if col.shape is BoxShape3D:
			var half:Vector3=col.shape.size*.5
			for i in 8:points.append(col.global_transform*(half*Vector3(1 if i&1 else -1,1 if i&2 else -1,1 if i&4 else -1)))
			ramp=absf(col.global_basis.y.normalized().y)<.995 and absf(col.global_basis.y.normalized().y)>.5
		elif col.shape is CylinderShape3D:
			for y in [-.5,.5]:
				for i in 12:points.append(col.global_transform*Vector3(cos(i*TAU/12)*col.shape.radius,y*col.shape.height,sin(i*TAU/12)*col.shape.radius))
		elif col.shape is ConvexPolygonShape3D:
			for point in col.shape.points:points.append(col.global_transform*point)
			ramp=body.get_meta("kit_id","")=="ramp"
		else:continue
		var low:=INF;var high:=-INF;var projected:=PackedVector2Array()
		for point in points:
			low=minf(low,point.y);high=maxf(high,point.y);projected.append(Vector2(point.x,point.z))
		var hull:=Geometry2D.convex_hull(projected)
		if hull.size()<4:continue
		hull.resize(hull.size()-1)
		shapes.append({"points":points,"footprint":hull,"low":low,"high":high,"ramp":ramp,"box":col.shape is BoxShape3D})
		if ramp:
			var top:=Vector3.ZERO;var bottom:=Vector3.ZERO;var nt:=0;var nb:=0
			for point in points:
				if point.y>high-.55:top+=point;nt+=1
				if point.y<low+.55:bottom+=point;nb+=1
			if nt>0 and nb>0:ramp_links.append({"a":bottom/nb,"b":top/nt,"low":low,"high":high})
		if body.get_meta("bounce",false):markers.append({"pos":body.global_position,"kind":"pad"})
		if body.get_meta("kit_id","")=="pad":markers.append({"pos":body.global_position,"kind":"pad"})
	if not (lab.builder and lab.builder.active) and lab.arena:
		for pad in lab.arena.travel.launch_pads:markers.append({"pos":pad.pos,"kind":"pad"})
		for portal in lab.arena.travel.portals:markers.append({"pos":portal.base,"kind":"portal"})
	elif lab.builder.testing:
		for portal in lab.session.objectives.travel.portals:markers.append({"pos":portal.base,"kind":"portal"})
func cross_section(item:Dictionary,y:float) -> PackedVector2Array:
	if not item.box:return item.footprint
	var crossings:=PackedVector2Array()
	for edge in EDGES:
		var a:Vector3=item.points[edge[0]];var b:Vector3=item.points[edge[1]]
		if (a.y-y)*(b.y-y)>0 or absf(b.y-a.y)<.0001:continue
		var point:=a.lerp(b,(y-a.y)/(b.y-a.y));crossings.append(Vector2(point.x,point.z))
	if crossings.size()<3:return PackedVector2Array()
	var hull:=Geometry2D.convex_hull(crossings)
	if hull.size()>0:hull.resize(hull.size()-1)
	return hull
func rebuild_slice() -> void:
	var start:=Time.get_ticks_usec();plan.floors.clear();plan.walls.clear();plan.ramps.clear()
	for item in shapes:
		if item.ramp:
			if item.low<=floor_y+1 and item.high>=floor_y-.8:plan.ramps.append(item.footprint)
		elif item.high>=floor_y-.8 and item.high<=floor_y+.35:plan.floors.append(item.footprint)
		elif item.low<floor_y+1 and item.high>floor_y+1:
			var section:=cross_section(item,floor_y+1)
			if section.size()>=3:plan.walls.append(section)
	plan.queue_redraw();atlas.render_target_update_mode=SubViewport.UPDATE_ONCE
	refreshes+=1;last_build_usec=Time.get_ticks_usec()-start
func sample_floor(dt:float,force:=false) -> void:
	var at:=focus();var next:=floor_y
	if lab.session.watcher.active:
		next=lab.session.watcher.towers[lab.session.watcher.selected].base.y
	else:
		var query:=PhysicsRayQueryParameters3D.create(at+Vector3.UP*.25,at+Vector3.DOWN*60,1)
		var hit:Dictionary={}
		for attempt in 8:
			hit=lab.get_world_3d().direct_space_state.intersect_ray(query)
			if hit.is_empty() or hit.collider is StaticBody3D:break
			# A passing dummy/cargo should not invent a navigation level.
			var excluded:=query.exclude;excluded.append(hit.collider.get_rid());query.exclude=excluded;hit={}
		if not hit.is_empty() and hit.normal.y>.55:
			# Keep the previous floor across gaps/jumps. Change on landing, nearby
			# support, falling below it, or a context/teleport initialization.
			if force or lab.player.is_on_floor() or at.y-hit.position.y<3 or at.y<floor_y-1.5:next=roundf(hit.position.y)
		elif force:next=400 if lab.builder and lab.builder.active else 0
	if absf(next-candidate_floor)>.6:candidate_floor=next;candidate_age=0
	else:candidate_age+=dt
	if force or (candidate_age>=.25 and absf(next-floor_y)>=1):floor_y=next;rebuild_slice()
func _physics_process(dt:float) -> void:
	if not relevant():return
	scan_clock-=dt
	if scan_clock>0:return
	scan_clock=.1
	var next_context:="workshop" if lab.builder and lab.builder.active else "arena"
	var next_revision:int=lab.builder.revision if next_context=="workshop" else 0
	var changed:bool=context!=next_context or revision!=next_revision
	if changed:context=next_context;revision=next_revision;collect_geometry()
	sample_floor(.1,changed)
func _process(_dt:float) -> void:
	visible=relevant()
	if not visible:return
	var ui_scale:=clampf(get_viewport_rect().size.y/1080.0,.85,1.6)
	scale=Vector2.ONE*ui_scale;size=Vector2(MAP_SIZE+24,MAP_HEIGHT+82)
	position=Vector2(get_viewport_rect().size.x-size.x*ui_scale-24,82)
	modulate=Color(1,1,1,.32 if lab.session.watcher.blackout>0 else 1)
	queue_redraw()
func map_point(point:Vector3,center:Vector2,_at:=Vector3.ZERO) -> Vector2:
	return center+Vector2(point.x,point.z)*(MAP_SIZE/(RANGE*2))
func marker_in_view(point:Vector3,_at:=Vector3.ZERO) -> bool:
	return absf(point.x)<156 and absf(point.z)<124
func actor_markers() -> Array[Dictionary]:
	var result:Array[Dictionary]=[]
	if context=="workshop" and not lab.builder.testing:return result
	var w=lab.session.watcher
	for i in w.towers.size():result.append({"pos":w.towers[i].pos,"kind":"tower","id":i+1,"selected":w.active and w.selected==i})
	for fiver in lab.session.objectives.partners:
		if is_instance_valid(fiver) and fiver.is_visible_in_tree() and fiver.health>0:result.append({"pos":fiver.global_position,"kind":"fiver"})
	return result
func text(at:Vector2,value:String,point_size:=13,color:=Color("c9d8d5")) -> void:
	draw_string(font,at,value,HORIZONTAL_ALIGNMENT_LEFT,-1,point_size,color)
func _draw() -> void:
	if not visible or not lab.session:return
	draw_style_box(panel_style,Rect2(Vector2.ZERO,size))
	var rect:=Rect2(12,30,MAP_SIZE,MAP_HEIGHT);var center:=rect.get_center();var at:=focus()
	var offset:=400.0 if context=="workshop" else 0.0
	text(Vector2(12,20),"N ↑  ARENA   ·   FLOOR +%.0f m"%(floor_y-offset),13)
	var source:=Rect2(Vector2.ZERO,Plan.BOUNDS.size*Plan.SCALE)
	draw_texture_rect_region(atlas.get_texture(),rect,source)
	draw_rect(rect,Color("54747b"),false,1)
	for link in ramp_links:
		if link.low>floor_y+1 or link.high<floor_y-.8:continue
		var middle:Vector3=(link.a+link.b)*.5
		if not marker_in_view(middle):continue
		var toward:Vector2=Vector2(link.b.x-link.a.x,link.b.z-link.a.z).normalized()
		var pos:=map_point(middle,center,at);var side:=toward.orthogonal()
		draw_polyline(PackedVector2Array([pos-toward*4+side*4,pos+toward*4,pos-toward*4-side*4]),Color("74c9c4"),2,true)
	for item in markers:
		if not marker_in_view(item.pos,at):continue
		var pos:=map_point(item.pos,center,at)
		if item.kind=="portal":draw_arc(pos,3,0,TAU,16,Color("c896db"),1,true)
	var actors:=actor_markers()
	actors.sort_custom(func(a,b):return a.kind<b.kind) # Towers stay readable when bots pass beneath them.
	for item in actors:
		if not marker_in_view(item.pos):continue
		var pos:=map_point(item.pos,center)
		if item.kind=="tower":
			var color:=Color("ffca7a") if item.selected else Color("ff6c7d")
			draw_circle(pos,8,Color("08121b"));draw_rect(Rect2(pos-Vector2.ONE*6,Vector2.ONE*12),color,false,1.5)
			text(pos+Vector2(-3.5,4),str(item.id),11,color)
		else:
			draw_circle(pos,4.5,Color("08121b"));draw_circle(pos,3,Color("73e8d2"))
			if absf(item.pos.y-floor_y)>4:text(pos+Vector2(4,-3),"↑" if item.pos.y>floor_y else "↓",10,Color("73e8d2"))
	var dir:=Vector2(-sin(heading()),-cos(heading()));var right:=dir.orthogonal()
	var here:=map_point(at,center)
	if not lab.session.watcher.active:
		draw_circle(here,7,Color("0a151d"))
		draw_colored_polygon(PackedVector2Array([here+dir*6,here-dir*4+right*4,here-dir*4-right*4]),Color("fff0be"))
	text(Vector2(12,size.y-35),"▲ YOU   ● HIGH FIVER",11,Color("b4ceca"))
	text(Vector2(12,size.y-21),"▣ TOWER   ↑ / ↓ OTHER FLOOR",10,Color("91aaa9"))
	text(Vector2(12,size.y-7),lab.controls.prompt("minimap")+" HIDE",11,Color("91aaa9"))
	var length:=50*MAP_SIZE/(RANGE*2)
	draw_line(Vector2(size.x-12-length,size.y-11),Vector2(size.x-12,size.y-11),Color("c9d8d5"),2)
	text(Vector2(size.x-47,size.y-19),"50 m",11)
