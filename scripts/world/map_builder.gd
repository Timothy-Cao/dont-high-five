extends Node3D
## Separate workshop, no mutation of the authored arena. Versioned data, reversible edits.
const Kit=preload("res://scripts/world/arena_kit.gd")
const ORIGIN=Vector3(0,400,0)
const LIMIT:=2048
var lab:Node3D
var active:=false
var testing:=false
var shell:Node3D
var pieces:Node3D
var camera:Camera3D
var work_light:DirectionalLight3D
var preview:Node3D
var specs:Array=[]
var entries:Array=[]
var undo_stack:Array=[]
var redo_stack:Array=[]
var selected:=0
var yaw:=0
var grid:=0.5
var elevation:=0.0
var candidate:=Vector3.ZERO
var valid:=false
var dirty:=false
var revision:=0
var autosave_elapsed:=0.0
var autosave_revision:=-1
var test_start:=Vector3(0,.05,24)
var status:=""
var pad_lock:=0.0
var saved_position:=Vector3.ZERO
var saved_rotation:=Vector3.ZERO
var saved_auto:=false
var preview_mat:StandardMaterial3D
func _ready() -> void:
	specs=Kit.catalogue()
	shell=Node3D.new();add_child(shell);shell.position=ORIGIN;shell.hide()
	pieces=Node3D.new();shell.add_child(pieces)
	camera=Camera3D.new();add_child(camera);camera.far=250;camera.near=0.1
	camera.environment=lab.environment.duplicate();camera.environment.ambient_light_energy=.7;camera.environment.fog_density=.003
	work_light=DirectionalLight3D.new();shell.add_child(work_light);work_light.rotation_degrees=Vector3(-55,-25,0);work_light.light_energy=.85;work_light.shadow_enabled=true
	var P=preload("res://scripts/gameplay/props.gd")
	P.box(shell,Vector3(0,-0.25,0),Vector3(304,.5,240),Color("192c38"))
	for side in [-1,1]:
		P.box(shell,Vector3(side*152,22,0),Vector3(.5,44,240),Color("17242f"))
		P.box(shell,Vector3(0,22,side*120),Vector3(304,44,.5),Color("17242f"))
	P.box(shell,Vector3(0,44.25,0),Vector3(304,.5,240),Color("182835"))
	for x in range(-144,145,8):
		P.box(shell,Vector3(x,.006,0),Vector3(.025,.012,240),Color("2e5860"),false)
	for z in range(-112,113,8):
		P.box(shell,Vector3(0,.006,z),Vector3(304,.012,.025),Color("2e5860"),false)
	for x in [-24,0,24]:
		for z in [-24,0,24]:
			var light:=OmniLight3D.new();shell.add_child(light);light.position=Vector3(x,12,z);light.omni_range=34;light.light_color=Color("9ec7cc");light.light_energy=4;light.shadow_enabled=false
			var fixture=P.box(shell,Vector3(x,34,z),Vector3(6,.10,.3),Color("88babb"),false)
			fixture.get_child(0).material_override=P.material(Color("88babb"),1.2)
	preview_mat=StandardMaterial3D.new();preview_mat.transparency=BaseMaterial3D.TRANSPARENCY_ALPHA;preview_mat.shading_mode=BaseMaterial3D.SHADING_MODE_UNSHADED
	select_part(0)
func enter() -> void:
	if active:return
	if lab.session.training.active:lab.session.training.leave()
	lab.session.watcher.leave()
	if lab.session.watcher.blackout>0:lab.session.watcher.cut_power()
	saved_auto=lab.session.watcher.auto_fire;lab.session.watcher.auto_fire=false
	saved_position=lab.player.position;saved_rotation=lab.player.rotation
	lab.player.cancel_hands(true);lab.player.velocity=Vector3.ZERO
	active=true;testing=false;work_light.show();lab.started=true;shell.show();lab.arena.hide();lab.session.hide()
	lab.arena.process_mode=Node.PROCESS_MODE_DISABLED;lab.session.process_mode=Node.PROCESS_MODE_DISABLED
	lab.player.position=ORIGIN+Vector3(0,.05,24)
	camera.position=ORIGIN+Vector3(0,12,26);camera.look_at(ORIGIN+Vector3(0,1,0));camera.current=true
	lab.set_paused(false);status="Empty workshop · choose a part, point and place"
func leave() -> void:
	if not active:return
	if dirty:save_recovery()
	active=false;testing=false;shell.hide();preview.hide();lab.arena.show();lab.session.show()
	lab.arena.process_mode=Node.PROCESS_MODE_INHERIT;lab.session.process_mode=Node.PROCESS_MODE_INHERIT
	lab.session.watcher.auto_fire=saved_auto
	lab.player.reset_to(saved_position);lab.player.rotation=saved_rotation
	lab.player.camera.current=not lab.player.third_person;lab.player.follow_camera.current=lab.player.third_person
	lab.set_paused(true)
func toggle_test(from_cursor:=false) -> void:
	if not testing:
		test_start=Vector3(0,.05,24)
		if from_cursor:
			var hit:=ray()
			if hit.is_empty() or not safe_test_spot(hit.position,hit.normal):
				status="Point at a walkable surface with room for your robot";return
			test_start=hit.position-ORIGIN+Vector3.UP*.05
	testing=not testing;work_light.visible=not testing;lab.player.cancel_hands();lab.player.clear_mouse_chord();lab.player.velocity=Vector3.ZERO
	if testing:
		lab.player.reset_to(ORIGIN+test_start);lab.player.rotation.y=camera.rotation.y
		lab.player.camera.current=not lab.player.third_person;lab.player.follow_camera.current=lab.player.third_person
	else:camera.current=true
	preview.visible=not testing;status="F7 returns to editing" if testing else "Editing · F7 to playtest"
func safe_test_spot(at:Vector3,normal:Vector3) -> bool:
	var local:=at-ORIGIN
	if normal.y<0.7 or absf(local.x)>150.7 or absf(local.z)>118.7 or local.y<-.1 or local.y>41.8:return false
	var shape:=CapsuleShape3D.new();shape.radius=0.42;shape.height=1.8
	var query:=PhysicsShapeQueryParameters3D.new();query.shape=shape;query.collision_mask=1;query.margin=.01
	query.transform.origin=at+Vector3.UP*.96
	return get_world_3d().direct_space_state.intersect_shape(query,1).is_empty()
func pick_part(index:int) -> bool:
	if index<0 or index>=entries.size():return false
	var entry:Dictionary=entries[index];select_part(entry.part);yaw=entry.yaw;elevation=0
	status="Picked "+str(specs[selected].name)+" · rotation copied";return true
func select_part(index:int) -> void:
	selected=posmod(index,specs.size())
	if is_instance_valid(preview):preview.queue_free()
	preview=Kit.make(specs[selected],false);add_child(preview)
	for mesh in preview.find_children("*","MeshInstance3D",true,false):mesh.material_override=preview_mat;mesh.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	preview.visible=active and not testing
func snapshot() -> void:
	undo_stack.append(entries.duplicate(true))
	if undo_stack.size()>64:undo_stack.pop_front()
	redo_stack.clear();dirty=true
func rebuild() -> void:
	revision+=1
	for child in pieces.get_children():pieces.remove_child(child);child.queue_free()
	for i in entries.size():
		var entry:Dictionary=entries[i];var spec:Dictionary=specs[entry.part]
		var part=Kit.make(spec);pieces.add_child(part);part.position=Kit.vector(entry.pos);part.rotation.y=entry.yaw*PI/2;part.set_meta("entry",i)
func place() -> bool:
	if not valid or entries.size()>=LIMIT:status="Blocked: overlap, shell boundary, spawn clearance or part limit";return false
	snapshot();entries.append({"part":selected,"pos":[candidate.x,candidate.y,candidate.z],"yaw":yaw});rebuild();status="Placed "+str(specs[selected].name);return true
func remove(index:int) -> void:
	if index<0 or index>=entries.size():return
	snapshot();entries.remove_at(index);rebuild();status="Removed part · Ctrl+Z to undo"
func undo(redo:=false) -> void:
	var source:Array=redo_stack if redo else undo_stack
	if source.is_empty():return
	var destination:Array=undo_stack if redo else redo_stack
	destination.append(entries.duplicate(true));entries=source.pop_back();dirty=true;rebuild()
func map_path() -> String:return "user://maps/workshop-1.json"
func recovery_path() -> String:
	return "res://.local/reports/workshop-autosave-test.json" if lab.scripted_run else "user://maps/workshop-autosave.json"
func save_recovery() -> Error:
	var error:=save_map(recovery_path(),false)
	if error==OK:autosave_revision=revision;status="Recovery saved · Ctrl+S saves your main layout"
	return error
func recover_map() -> bool:
	if not load_map(recovery_path()):return false
	dirty=true;status="Recovered unsaved work · Ctrl+S to keep it";return true
func update_autosave(dt:float) -> void:
	autosave_elapsed+=dt
	if autosave_elapsed<60:return
	autosave_elapsed=0
	if dirty and revision!=autosave_revision:save_recovery()
func save_map(path:="",mark_clean:=true) -> Error:
	if path.is_empty():path=map_path()
	DirAccess.make_dir_recursive_absolute(path.get_base_dir())
	var file:=FileAccess.open(path+".tmp",FileAccess.WRITE)
	if file==null:status="Save failed: "+error_string(FileAccess.get_open_error());return FileAccess.get_open_error()
	var serialized:Array=[]
	for entry in entries:
		serialized.append({"id":specs[entry.part].id,"pos":entry.pos,"yaw":entry.yaw})
	file.store_string(JSON.stringify({"version":1,"parts":serialized},"\t"));file.close()
	if FileAccess.file_exists(path):
		var copied:=DirAccess.copy_absolute(path,path+".bak")
		if copied!=OK:status="Could not preserve previous save";return copied
	var error:=DirAccess.rename_absolute(path+".tmp",path)
	status="Saved arena · %d parts"%entries.size() if error==OK else "Save failed: "+error_string(error)
	if error==OK and mark_clean:dirty=false
	return error
func load_map(path:="") -> bool:
	if path.is_empty():path=map_path()
	if not FileAccess.file_exists(path):status="No arena saved yet";return false
	var file:=FileAccess.open(path,FileAccess.READ)
	if file==null or file.get_length()>500000:status="Cannot read map";return false
	var data=JSON.parse_string(file.get_as_text())
	if not data is Dictionary or data.get("version")!=1 or not data.get("parts") is Array:status="Unsupported map";return false
	var rows:Array=data.parts
	if rows.size()>LIMIT:status="Map exceeds %d parts"%LIMIT;return false
	for row in rows:
		if row is Dictionary and row.get("id") is String:
			row.part=-1
			for index in specs.size():
				if specs[index].id==row.id:row.part=index;break
		if not row is Dictionary or not (row.get("part") is float or row.get("part") is int) or not row.get("yaw") is float or not row.get("pos") is Array:status="Invalid part";return false
		if row.part!=floor(row.part) or row.part<0 or row.part>=specs.size() or row.yaw not in [0.0,1.0,2.0,3.0] or row.pos.size()!=3:status="Invalid part values";return false
		for value in row.pos:
			if not (value is float or value is int) or not is_finite(value):status="Invalid position";return false
		var pos:=Kit.vector(row.pos)
		if absf(pos.x)>150 or absf(pos.z)>118 or pos.y<0 or pos.y>42:status="Part outside workshop";return false
		row.part=int(row.part);row.yaw=int(row.yaw)
	snapshot();entries=rows;dirty=false;rebuild();status="Loaded arena";return true
func handle_input(event:InputEvent) -> bool:
	if not active:return false
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_F7 and not lab.paused:toggle_test(event.shift_pressed);return true
		if event.keycode==KEY_F6:return true
	if testing or lab.paused:return false
	if event is InputEventMouseMotion:
		camera.rotation.y-=event.screen_relative.x*lab.player.sensitivity
		camera.rotation.x=clampf(camera.rotation.x-event.screen_relative.y*lab.player.sensitivity,-1.5,1.5);return true
	if event is InputEventMouseButton and event.pressed:
		if event.button_index==MOUSE_BUTTON_LEFT:place()
		elif event.button_index==MOUSE_BUTTON_RIGHT:
			var hit:=ray()
			if not hit.is_empty() and hit.collider.has_meta("entry"):remove(hit.collider.get_meta("entry"))
		elif event.button_index==MOUSE_BUTTON_MIDDLE:
			var hit:=ray()
			if not hit.is_empty() and hit.collider.has_meta("entry"):pick_part(hit.collider.get_meta("entry"))
		elif event.button_index==MOUSE_BUTTON_WHEEL_UP:select_part(selected+1)
		elif event.button_index==MOUSE_BUTTON_WHEEL_DOWN:select_part(selected-1)
		return true
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ESCAPE,KEY_TAB,KEY_F11]:return false
		if event.ctrl_pressed:
			match event.keycode:
				KEY_S:save_map()
				KEY_L:load_map()
				KEY_Z:undo()
				KEY_Y:undo(true)
		elif event.keycode>=KEY_1 and event.keycode<=KEY_9:select_part(event.keycode-KEY_1)
		elif event.keycode==KEY_R:yaw=posmod(yaw+1,4)
		elif event.keycode==KEY_G:grid=1.0 if grid==0.5 else (2.0 if grid==1 else 0.5)
		elif event.keycode==KEY_PAGEUP:elevation+=grid
		elif event.keycode==KEY_PAGEDOWN:elevation-=grid
		return true
	return true
func ray() -> Dictionary:
	return get_world_3d().direct_space_state.intersect_ray(PhysicsRayQueryParameters3D.create(camera.global_position,camera.global_position-camera.global_basis.z*100,1))
func can_place(at:Vector3,part_index:int,turn:int) -> bool:
	var spec:Dictionary=specs[part_index];var bounds:=Kit.vector(spec.bounds);var basis:=Basis(Vector3.UP,turn*PI/2)
	var size:Vector3=(basis*bounds).abs()
	if absf(at.x)+size.x/2>151.7 or absf(at.z)+size.z/2>119.7 or at.y<0 or at.y+size.y>43.7:return false
	if AABB(at-Vector3(size.x/2,0,size.z/2),size).intersects(AABB(Vector3(-0.7,0,23.3),Vector3(1.4,2,1.4))):return false
	var q:=PhysicsShapeQueryParameters3D.new();q.collision_mask=1;q.margin=0.001
	var shape:=BoxShape3D.new();shape.size=bounds*0.985;q.shape=shape;q.transform=Transform3D(basis,ORIGIN+at+Vector3.UP*bounds.y/2)
	# Conservative bounds prevent accidental intersections and keep editing predictable.
	return get_world_3d().direct_space_state.intersect_shape(q,1).is_empty()
func _physics_process(dt:float) -> void:
	if not active or lab.paused:return
	update_autosave(dt)
	pad_lock=maxf(0,pad_lock-dt)
	if testing:
		if lab.player.position.y<ORIGIN.y-6:lab.player.reset_to(ORIGIN+test_start)
		if pad_lock<=0:
			for node in pieces.get_children():
				var spec:Dictionary=specs[entries[node.get_meta("entry")].part]
				if not spec.has("launch"):continue
				var local:Vector3=node.to_local(lab.player.global_position)
				if absf(local.x)<2 and absf(local.z)<2 and local.y>=0 and local.y<0.8 and lab.player.velocity.y<=1:
					lab.player.launch_from_pad(Vector3(lab.player.velocity.x,24,lab.player.velocity.z));pad_lock=0.6;lab.sound("pad");break
		return
	var movement:=Vector3(float(Input.is_physical_key_pressed(KEY_D))-float(Input.is_physical_key_pressed(KEY_A)),0,float(Input.is_physical_key_pressed(KEY_S))-float(Input.is_physical_key_pressed(KEY_W)))
	if Input.is_physical_key_pressed(KEY_CTRL):movement=Vector3.ZERO
	var up:=float(Input.is_physical_key_pressed(KEY_SPACE))-float(Input.is_physical_key_pressed(KEY_C))
	camera.position+=(camera.basis*movement+Vector3.UP*up).limit_length(1)*dt*(30 if Input.is_physical_key_pressed(KEY_SHIFT) else 12)
	var hit:=ray();valid=false;preview.hide()
	if hit.is_empty():return
	var bounds:=Kit.vector(specs[selected].bounds);var basis:=Basis(Vector3.UP,yaw*PI/2);var extents:Vector3=(basis*bounds).abs()/2
	var pos:Vector3=hit.position-ORIGIN+hit.normal*hit.normal.abs().dot(extents)-Vector3.UP*bounds.y/2
	pos.y+=elevation;candidate=pos.snapped(Vector3.ONE*grid)
	valid=can_place(candidate,selected,yaw)
	preview.position=ORIGIN+candidate;preview.basis=basis;preview.show()
	preview_mat.albedo_color=Color(0.2,0.95,0.8,0.48) if valid else Color(1,0.18,0.2,0.48)
func draw_hud(hud:Control) -> void:
	hud.txt(Vector2(28,40),"WORKSHOP  /  "+("PLAYTEST" if testing else "BUILD"),22)
	hud.txt(Vector2(28,70),"Your arena%s · %d / %d parts"%[" *" if dirty else "",entries.size(),LIMIT],16)
	if testing:hud.centered(Vector2(hud.size.x/2,40),"F7  Return to editing",17);return
	hud.draw_circle(hud.size/2,3,Color.WHITE)
	hud.centered(Vector2(hud.size.x/2,hud.size.y-105),"%d  %s  ·  %.1f m grid  ·  %d°"%[selected+1,specs[selected].name,grid,yaw*90],21)
	hud.centered(Vector2(hud.size.x/2,hud.size.y-76),"LMB place · RMB delete · MMB pick · 1–9 / Wheel parts · R rotate · G grid · PgUp/PgDn height",16)
	hud.centered(Vector2(hud.size.x/2,hud.size.y-49),"WASD fly · Space/C rise/fall · Ctrl+Z/Y undo/redo · Ctrl+S/L save/load · F7 test · Shift+F7 test here",16)
	hud.centered(Vector2(hud.size.x/2,hud.size.y-22),status,15)
