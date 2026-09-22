extends CharacterBody3D
var glove_fill:DirectionalLight3D

var lab: Node3D
var hand_serial:=0
var cargo:CharacterBody3D
var cargo_hand:=-1
var zip_mode:=false
var zip:Node
var health:=100.0
var respawn_left:=0.0
var damage_flash:=0.0
var damage_feedback=preload("res://scripts/damage_feedback.gd").new()
var impostor:=false
var leg_disabled:=false
var camera: Camera3D
var follow_camera: Camera3D
var avatar: Node3D
var third_person:=false
var camera_cut:=true
var camera_distance:=4.8
var follow_shape:=SphereShape3D.new()
var portal_lock:=0.0
var pad_lock:=0.0
var step_distance:=0.0
var collider: CollisionShape3D
var stand_shape := CapsuleShape3D.new()

var ball := false
var crouched := false
var crouch_shape := CapsuleShape3D.new()
var walk_speed := 3.5
var ground_accel := 12.0
var ground_brake := 100.0
var jump_speed := 8.2
var double_jump_enabled := true
var wall_grip_enabled := true
var brake_enabled := true
var reel_enabled := true
var air_jumps := 1
var jump_buffer := 0.0
var coyote := 0.0
var jump_lock := 0.0
var wall_lock := 0.0
var wall_clinging := false
var wall_normal := Vector3.ZERO
var stone := false
var reeling := false
var momentum_air := false
var action_override := {}
var camera_motion := true
var fixed_mode := false
var fixed_rope = preload("res://scripts/fixed_tether.gd").new()
var anchored := false
var equipment_disabled := false
var movement_fx: Node3D
var grip_lights := true
var grounded_time := 0.0
var launch_gain := 4.2
var gravity := 24.0
var air_control := 36.0
var air_accel := 6.0
var landing_grace := 0.0
var floor_recheck := true
var sensitivity := 0.0022
var max_speed := 40.0
var slack_allowance := 0.6
var stretch_limit := 5.5
var spring_stiffness := 2.6
var spring_cubic := 0.12
var spring_damping := 1.6
var ball_mass := 0.09
var walk_drive := 6.0
var anchor_drive_limit := 35.0
var input_override := Vector2.ZERO
var testing_input := false
var tether_limited := false
var fullscreen := false
var power := 0.0
var hands: Array[Dictionary] = []
var last_setup: Dictionary = {}
var shots := 0
var best_distance := 0.0
var last_distance := 0.0
var last_landing := Vector3.ZERO
var launch_origin := Vector3.ZERO
var flying := false
var flight_time := 0.0
var target_valid := false
var target_text := ""
var arm_frame := 0
var visual_time := 0.0
var recoil := 0.0
var ball_rim: MeshInstance3D
var preview_shape := CapsuleShape3D.new()
const CHORD_WINDOW_MS := 120
const HAND_RANGE := 25.5
const HAND_RECOVERY_DURATION := 0.65
var mouse_down := [false, false]
var mouse_pressed_at := [-1000, -1000]
var chord_latched := false
var chord_had_arms := false
var punch_enabled:=true
var combat:Node
var buffs:Dictionary={}
var buff_flash:=0.0
var hand_recovery:=0.0
var recovery_origins:Array[Vector3]=[Vector3.ZERO,Vector3.ZERO]

func grant_buff(kind: String,duration: float) -> void:
	if kind not in ["speed","reach","pull","vision","overdrive","charge","invisible","insulation","toughness","max_charge"]: return
	buffs[kind]=maxf(float(buffs.get(kind,0)),duration);buff_flash=0.7

func speed_multiplier() -> float:
	return 1.45 if buffs.has("overdrive") else (1.3 if buffs.has("speed") else 1.0)

func pull_multiplier() -> float:
	return 1.75 if buffs.has("overdrive") else (1.35 if buffs.has("pull") else 1.0)

func hand_range() -> float:
	return HAND_RANGE*(1.5 if buffs.has("overdrive") else (1.25 if buffs.has("reach") else 1.0))

func vision_multiplier() -> float:
	return 1.8 if buffs.has("overdrive") else (1.6 if buffs.has("vision") else 1.0)

func tick_buffs(dt: float) -> void:
	buff_flash=maxf(0,buff_flash-dt)
	for kind in buffs.keys():
		buffs[kind]=maxf(0,float(buffs[kind])-dt)
		if buffs[kind]<=0: buffs.erase(kind)

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	stand_shape.radius = 0.34
	stand_shape.height = 1.8
	crouch_shape.radius = 0.34
	crouch_shape.height = 1.62
	preview_shape.radius = 0.34
	preview_shape.height = 1.8
	collider = CollisionShape3D.new()
	collider.shape = stand_shape
	collider.position.y = 0.9
	add_child(collider)
	floor_snap_length = 0.12
	camera = Camera3D.new()
	add_child(camera)
	camera.position.y = 1.58
	camera.near = 0.045
	camera.far = 420
	camera.fov = 84
	camera.current = true
	glove_fill=DirectionalLight3D.new()
	lab.add_child(glove_fill)
	glove_fill.light_cull_mask=2
	glove_fill.set_meta("blackout_exempt",true)
	glove_fill.light_energy=0.7
	glove_fill.rotation_degrees=Vector3(-35,-25,0)
	for i in 2:
		var c := Color("c88240") if i == 0 else Color("488f83")
		var glove: Node3D = load("res://assets/glove_left.glb" if i==0 else "res://assets/glove_right.glb").instantiate()
		lab.add_child(glove)
		preload("res://scripts/gameplay/props.gd").glowing_glove(glove,0.22)
		for piece in glove.find_children("*","MeshInstance3D",true,false):
			piece.layers=2
			piece.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var fist:Node3D=load("res://assets/fist_left.glb" if i==0 else "res://assets/fist_right.glb").instantiate()
		lab.add_child(fist);fist.hide()
		preload("res://scripts/gameplay/props.gd").glowing_glove(fist,0.22)
		for piece in fist.find_children("*","MeshInstance3D",true,false):
			piece.layers=2;piece.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		var cuff_light:=MeshInstance3D.new()
		var cuff_ring:=TorusMesh.new()
		cuff_ring.inner_radius=0.05
		cuff_ring.outer_radius=0.06
		cuff_light.mesh=cuff_ring
		cuff_light.material_override=lab.mat(Color("ffc885") if i==0 else Color("76e6dd"),1.0)
		cuff_light.position.y=-0.17
		cuff_light.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		cuff_light.layers=2
		glove.add_child(cuff_light)
		var lamp:=OmniLight3D.new()
		lab.add_child(lamp)
		lamp.light_color=Color("ffd298") if i==0 else Color("8bf1ed")
		lamp.light_energy=2.5
		lamp.set_meta("blackout_exempt",true)
		glove.set_meta("blackout_exempt",true);fist.set_meta("blackout_exempt",true)
		lamp.light_cull_mask=1
		lamp.omni_range=13
		lamp.omni_attenuation=1.4
		lamp.shadow_enabled=true
		lamp.shadow_caster_mask=1
		lamp.light_size=0.18
		var cord = load("res://scripts/elastic_arm.gd").new()
		lab.add_child(cord)
		hands.append({"state":0,"point":Vector3.ZERO,"normal":Vector3.FORWARD,"rest":0.0,"age":0.0,"from":Vector3.ZERO,"hit":false,"body":null,"glove":glove,"fist":fist,"cord":cord,"color":c,"retract_left":0.0,"retract_pos":Vector3.ZERO,"spool_target":0.0,"route":preload("res://scripts/arm_route.gd").new(),"lamp":lamp})
	ball_rim = MeshInstance3D.new()
	var rim := TorusMesh.new()
	rim.inner_radius = 0.29
	rim.outer_radius = 0.32
	ball_rim.mesh = rim
	ball_rim.layers=2
	ball_rim.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	ball_rim.material_override = lab.mat(Color("66d8cb"))
	camera.add_child(ball_rim)
	ball_rim.position = Vector3(0,-0.26,-0.22)
	ball_rim.hide()
	combat=load("res://scripts/combat.gd").new();combat.player=self;add_child(combat)
	zip=load("res://scripts/gameplay/zip.gd").new();zip.player=self;add_child(zip)
	avatar=load("res://scripts/avatar.gd").new();add_child(avatar);avatar.hide()
	follow_camera=Camera3D.new();lab.add_child(follow_camera)
	follow_camera.near=0.08;follow_camera.far=420;follow_camera.fov=84
	follow_shape.radius=0.28
	movement_fx=load("res://scripts/movement_fx.gd").new();movement_fx.player=self;lab.add_child(movement_fx)

func toggle_view() -> void:
	third_person=not third_person
	follow_camera.current=third_person;camera.current=not third_person
	camera_cut=true
	update_camera(0.016)

func aim_point() -> Vector3:
	var end:=camera.global_position-camera.global_basis.z*hand_range()
	var hit:=ray(camera.global_position,end)
	return hit.position if not hit.is_empty() else end

func update_camera(dt: float) -> void:
	if not third_person:
		avatar.hide()
		return
	var origin:=camera.global_position
	var offset:=camera.global_basis*Vector3(0.65,0.4,4.8)
	var q:=PhysicsShapeQueryParameters3D.new()
	q.shape=follow_shape;q.transform=Transform3D(Basis.IDENTITY,origin)
	q.motion=offset;q.collision_mask=1;q.exclude=[get_rid()];q.margin=0.025
	var fractions:=get_world_3d().direct_space_state.cast_motion(q)
	var allowed:=maxf(0.0,offset.length()*fractions[0]-0.06)
	# Pull in immediately at a wall; ease back out. Never smooth through geometry.
	camera_distance=allowed if camera_cut or allowed<camera_distance else lerpf(camera_distance,allowed,1-exp(-dt*12))
	follow_camera.global_position=origin+offset.normalized()*camera_distance
	follow_camera.look_at(aim_point(),Vector3.UP)
	follow_camera.fov=camera.fov
	avatar.visible=camera_distance>0.9 and not buffs.has("invisible")
	camera_cut=false

func launch_from_pad(impulse: Vector3) -> void:
	cancel_hands();set_ball(true)
	velocity=impulse;momentum_air=true;flying=true;flight_time=0
	launch_origin=position;grounded_time=0;air_jumps=1;jump_lock=0.15;coyote=0
	wall_clinging=false;wall_lock=0.2

func chest() -> Vector3:
	return global_position + Vector3.UP*1.15

func hand_start(i: int) -> Vector3:
	return camera.global_transform * Vector3(-0.37 if i==0 else 0.37,-0.34,-0.65)

func ray(a: Vector3,b: Vector3) -> Dictionary:
	var q := PhysicsRayQueryParameters3D.create(a,b,1,[get_rid()])
	return get_world_3d().direct_space_state.intersect_ray(q)

func held(action: String) -> bool:
	if testing_input: return bool(action_override.get(action,false))
	if action=="reel" and Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE): return true
	return lab.controls.held(action)

func _unhandled_input(event: InputEvent) -> void:
	if lab.builder and lab.builder.handle_input(event):return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ESCAPE,KEY_TAB]:
			if lab.paused and lab.hud.page!="Home": lab.hud.go_back()
			else: lab.set_paused(not lab.paused)
			return
		if event.keycode==KEY_F11:
			fullscreen = not fullscreen
			lab.save_preferences()
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
			return
	if lab.paused: return
	if event.is_action_pressed("pop_minimap"):
		lab.hud.minimap.enabled=not lab.hud.minimap.enabled;lab.save_preferences();return
	if lab.session and event is InputEventKey and event.pressed and not event.echo and event.keycode==KEY_F7:
		lab.session.watcher.cut_power();return
	if lab.session and not (lab.builder and lab.builder.active) and lab.session.handle_input(event): return
	if respawn_left>0: return
	if event is InputEventMouseMotion and Input.mouse_mode==Input.MOUSE_MODE_CAPTURED:
		apply_mouse_motion(event)
	elif event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT: handle_glove_button(0,event.pressed)
			MOUSE_BUTTON_RIGHT: handle_glove_button(1,event.pressed)
			MOUSE_BUTTON_WHEEL_UP:
				if event.pressed: adjust_length(-1.0)
			MOUSE_BUTTON_WHEEL_DOWN:
				if event.pressed: adjust_length(1.0)
	elif event is InputEventKey and event.pressed and not event.echo:
		if event.keycode==KEY_F5: toggle_view()
		elif event.is_action_pressed("pop_arm_mode"): toggle_arm_mode()
		elif event.is_action_pressed("pop_attack_mode"):
			cancel_hands();clear_mouse_chord();zip_mode=not zip_mode
		elif event.is_action_pressed("pop_jump"): request_jump()
		elif event.is_action_pressed("pop_launch"): launch()
		elif event.is_action_pressed("pop_recall") or event.keycode==KEY_BACKSPACE: cancel_hands()
		elif event.is_action_pressed("pop_retry"): retry()
		elif event.is_action_pressed("pop_reset"): lab.goto_station(lab.station)
		elif lab.test_world and event.keycode in [KEY_2,KEY_3,KEY_4]: lab.goto_station(event.keycode-KEY_1)

func apply_mouse_motion(event: InputEventMouseMotion) -> void:
	rotate_y(-event.screen_relative.x*sensitivity)
	camera.rotation.x=clampf(camera.rotation.x-event.screen_relative.y*sensitivity,-1.4,1.4)

func request_jump() -> void:
	jump_buffer=0.12

func clear_mouse_chord() -> void:
	mouse_down=[false,false]
	mouse_pressed_at=[-1000,-1000]
	chord_latched=false
	chord_had_arms=false

func handle_glove_button(i: int,pressed: bool,at_ms: int = -1) -> void:
	if mouse_down[i]==pressed: return
	if pressed and not mouse_down[0] and not mouse_down[1]:
		chord_had_arms=hands[0].state!=0 or hands[1].state!=0
	mouse_down[i]=pressed
	if not pressed:
		if combat.charging: combat.release_charge()
		if not mouse_down[0] and not mouse_down[1]: chord_latched=false
		return
	if has_cargo():
		fire_hand(i);return
	if chord_latched: return
	var now:=Time.get_ticks_msec() if at_ms<0 else at_ms
	mouse_pressed_at[i]=now
	if mouse_down[1-i] and not chord_latched and now-mouse_pressed_at[1-i]<=CHORD_WINDOW_MS:
		chord_latched=true
		if chord_had_arms:
			cancel_hands()
			return
		if zip_mode:
			if not zip.begin():cancel_hands();lab.notify("Zip needs two surfaces in reach")
			return
		if combat.start_charge(): return
		return
	# No chord timeout on the first shot: normal glove placement remains instant.
	fire_hand(i)

func has_anchor() -> bool:
	return hands[0].state==2 or hands[1].state==2

func adjust_length(amount: float) -> void:
	if fixed_mode: return
	for h in hands:
		if h.state==2:
			h.spool_target=clampf(float(h.spool_target)+amount,2,40)

func find_wall() -> Vector3:
	for direction in [-global_basis.z,global_basis.x,-global_basis.x,global_basis.z]:
		var hit:=ray(position+Vector3.UP*0.75,position+Vector3.UP*0.75+direction*0.70)
		if not hit.is_empty() and absf(hit.normal.y)<0.25: return hit.normal
	return Vector3.ZERO

func set_crouch(value: bool) -> void:
	if ball: return
	if not value and crouched:
		var q:=PhysicsShapeQueryParameters3D.new()
		q.shape=stand_shape
		q.transform=Transform3D(Basis.IDENTITY,position+Vector3.UP*0.91)
		q.collision_mask=1
		q.exclude=[get_rid()]
		if not get_world_3d().direct_space_state.intersect_shape(q,1).is_empty(): return
	crouched=value
	collider.shape=crouch_shape if value else stand_shape
	collider.position.y=0.81 if value else 0.9

func arms_suppressed() -> bool:
	return equipment_disabled and not buffs.has("insulation")

func fire_hand(i: int) -> void:
	if has_cargo() and i==cargo_hand:
		var occupied:Dictionary=hands[i];occupied.retract_pos=occupied.glove.global_position;occupied.retract_left=0.14
		cargo.release();lab.sound("cancel");return
	if arms_suppressed() or stone or hand_recovery>0 or combat.active or combat.charging or zip.active or respawn_left>0: return
	# Gloves can be fired in flight to chain a launch into a grapple.
	var h: Dictionary = hands[i]
	if fixed_mode and fixed_rope.retiring_hand==i and hands[1-i].state==2:
		# Fast alternation can reuse the retiring hand before its overlap expires.
		retract_hand(i);fixed_rope.retiring_hand=-1;fixed_rope.overlap=0
	if has_cargo() and i!=cargo_hand and fixed_mode and h.state==2:
		# One free hand can regrip with one click; keep its earned flight momentum.
		retract_hand(i);fixed_rope.clear()
	if h.state != 0:
		h.retract_pos = h.glove.global_position
		h.retract_left = 0.14
		h.state = 0
		lab.sound("cancel")
		return
	var from := camera.global_position
	var to := from-camera.global_basis.z*hand_range()
	var query:=PhysicsRayQueryParameters3D.create(from,to,61,[get_rid()])
	var result := get_world_3d().direct_space_state.intersect_ray(query)
	h.route.clear()
	h.point = result.position if not result.is_empty() else to
	h.normal = result.normal if not result.is_empty() else Vector3.UP
	h.body = result.get("collider")
	h.hit = not result.is_empty() and bool(h.body.get_meta("grippy",false))
	h.from = hand_start(i)
	h.age = 0.0
	h.state = 1
	lab.sound("fire")

func retract_hand(index: int) -> void:
	if has_cargo() and index==cargo_hand:return
	var h:Dictionary=hands[index]
	if h.state!=0:
		h.retract_pos=h.glove.global_position;h.retract_left=0.14
	h.state=0;h.rest=0;h.route.clear()

func cancel_hands(drop_cargo:=false) -> void:
	hand_serial+=1
	if drop_cargo and has_cargo(): cargo.release()
	if is_instance_valid(zip): zip.cancel()
	if is_instance_valid(combat): combat.cancel()
	for i in 2:
		if not has_cargo() or i!=cargo_hand:retract_hand(i)
	fixed_rope.clear()

func toggle_arm_mode() -> void:
	fixed_mode=not fixed_mode
	fixed_rope.clear()
	for i in 2:
		if hands[i].state!=2: continue
		if fixed_mode: fixed_rope.attach(self,i)
		else:
			hands[i].rest=maxf(3,arm_length(hands[i],chest())+slack_allowance)
			hands[i].spool_target=hands[i].rest

func receive_punch(impulse: Vector3,_strength: float) -> bool:
	if anchored or held("anchor"): return false
	velocity+=impulse
	momentum_air=true;flying=true;flight_time=0;launch_origin=position
	landing_grace=0.1;jump_lock=0.15;coyote=0;wall_clinging=false;wall_lock=0.2
	return true

func arm_anchor(h:Dictionary) -> Vector3:
	return h.route.pivot(h.point)

func arm_length(h:Dictionary,at:Vector3) -> float:
	return h.route.length_from(at,h.point)

func arm_tail(h:Dictionary) -> float:
	return h.route.tail(h.point)

func update_arm_routes(dt:float) -> void:
	for h in hands:
		if h.state==2:h.route.update(self,h,chest()+velocity*dt,velocity,dt)
		else:h.route.clear()

func pull_vector(at: Vector3) -> Vector3:
	if fixed_mode: return Vector3.ZERO
	var total := Vector3.ZERO
	for h in hands:
		if h.state != 2:
			continue
		var d: Vector3 = arm_anchor(h)-(at+Vector3.UP*1.15)
		var extension := clampf(arm_length(h,at+Vector3.UP*1.15)-float(h.rest),0,stretch_limit)
		total += d.normalized()*(spring_stiffness*extension+spring_cubic*pow(extension,3))
	return total

func elastic_energy(at: Vector3) -> float:
	var energy := 0.0
	for h in hands:
		if h.state != 2: continue
		var extension := clampf(arm_length(h,at+Vector3.UP*1.15)-float(h.rest),0,stretch_limit)
		energy += 0.5*spring_stiffness*extension*extension+0.25*spring_cubic*pow(extension,4)
	return energy

func spring_force(at: Vector3,vel: Vector3) -> Vector3:
	if fixed_mode: return Vector3.ZERO
	var force := Vector3.ZERO
	for h in hands:
		if h.state != 2: continue
		var d: Vector3 = arm_anchor(h)-(at+Vector3.UP*1.15)
		var extension := maxf(0,arm_length(h,at+Vector3.UP*1.15)-float(h.rest))
		if extension<=0: continue
		var n := d.normalized()
		# Damping opposes radial motion; a slack arm never pushes the body away.
		var tension := maxf(0,spring_stiffness*extension+spring_cubic*pow(extension,3)-spring_damping*vel.dot(n))
		force += n*tension
	return force

func constrain_tethers(dt: float) -> void:
	tether_limited = false
	var next := position+velocity*dt
	for iteration in 8:
		for h in hands:
			if h.state!=2: continue
			var anchor: Vector3 = arm_anchor(h)-Vector3.UP*1.15
			var maximum: float = maxf(0.5,h.rest+stretch_limit-arm_tail(h))
			if is_on_floor() and not ball:
				# Feet remain braced vertically; solve the horizontal slice of the reach sphere.
				var dy: float = next.y-anchor.y
				var radius := sqrt(maxf(0,maximum*maximum-dy*dy))
				var horizontal := Vector2(next.x-anchor.x,next.z-anchor.z)
				if horizontal.length()>radius:
					horizontal = horizontal.normalized()*radius
					next.x = anchor.x+horizontal.x
					next.z = anchor.z+horizontal.y
					tether_limited = true
			else:
				var difference := next-anchor
				if difference.length()>maximum:
					next = anchor+difference.normalized()*maximum
					tether_limited = true
	velocity = (next-position)/dt

func shot_velocity(at: Vector3) -> Vector3:
	var pull := pull_vector(at)
	if pull.length() < 0.04:
		return Vector3.ZERO
	var speed := sqrt(2.0*elastic_energy(at)/ball_mass)*(launch_gain/4.2)
	return pull.normalized()*minf(max_speed*pull_multiplier(),speed*pull_multiplier())

func launch() -> void:
	if fixed_mode:
		cancel_hands();momentum_air=true
		return
	if arms_suppressed(): return
	if not is_on_floor() and not wall_clinging and not has_anchor():
		lab.notify("Stick a glove first, then stretch or reel.")
		return
	var v := shot_velocity(position)
	if v.length()<1.5:
		lab.notify("Arms are slack. Walk back or shorten them with the wheel.")
		return
	last_setup = {"position":position,"yaw":rotation.y,"pitch":camera.rotation.x,"hands":[]}
	for h in hands:
		last_setup.hands.append({"state":h.state if h.state==2 else 0,"point":h.point,"normal":h.normal,"rest":h.rest,"body":h.body,"spool_target":h.spool_target})
	set_ball(true)
	velocity = v
	momentum_air=true
	crouched = false
	wall_clinging = false
	wall_lock = 0.2
	air_jumps = 1
	coyote = 0
	jump_lock = 0.12
	launch_origin = position
	flying = true
	flight_time = 0.0
	grounded_time = 0.0
	shots += 1
	recoil = 1.0
	cancel_hands()
	lab.sound("launch")

func set_ball(value: bool) -> void:
	ball = value
	collider.shape = crouch_shape if crouched and not value else stand_shape
	collider.position.y = 0.81 if crouched and not value else 0.9
	ball_rim.hide()

func try_stand() -> bool:
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = stand_shape
	q.transform = Transform3D(Basis.IDENTITY,global_position+Vector3.UP*0.91)
	q.collision_mask = 1
	q.exclude = [get_rid()]
	q.margin = 0.001
	if not get_world_3d().direct_space_state.intersect_shape(q,1).is_empty():
		return false
	crouched=false
	set_ball(false)
	return true

func reset_to(p: Vector3) -> void:
	damage_feedback.hits.clear();damage_flash=0
	if is_instance_valid(movement_fx): movement_fx.clear_history()
	buffs.clear()
	if is_instance_valid(combat): combat.active=false;combat.charging=false;combat.charge_time=0;combat.pose_fists=false;combat.hit_flash=0
	landing_grace=0
	anchored=false
	fixed_rope.clear()
	floor_recheck=true
	portal_lock=0;pad_lock=0;camera_cut=true;step_distance=0
	clear_mouse_chord()
	hand_recovery=0
	position = p
	crouched = false
	stone = false
	wall_clinging = false
	reeling = false
	momentum_air = false
	air_jumps = 1
	jump_buffer = 0
	jump_lock = 0
	wall_lock = 0
	coyote = 0
	velocity = Vector3.ZERO
	set_ball(false)
	cancel_hands(true)
	hand_recovery=0
	flying = false
	flight_time = 0
	grounded_time = 0
	power = 0

func retry() -> void:
	if lab.builder and lab.builder.active:
		reset_to(lab.builder.ORIGIN+lab.builder.test_start);return
	if lab.session and lab.session.training.active:
		lab.session.training.restart();return
	if last_setup.is_empty():
		lab.goto_station(lab.station)
		return
	reset_to(last_setup.position)
	fixed_mode=false
	rotation.y = last_setup.yaw
	camera.rotation.x = last_setup.pitch
	for i in 2:
		for key in last_setup.hands[i]:
			hands[i][key] = last_setup.hands[i][key]
	lab.notify("Setup restored. Adjust your position or change either hand.")

func _physics_process(dt: float) -> void:
	if lab.paused or (lab.builder and lab.builder.active and not lab.builder.testing): return
	if lab.session and lab.session.watcher and lab.session.watcher.active: return
	damage_flash=maxf(0,damage_flash-dt)
	damage_feedback.update(dt)
	if respawn_left>0:
		respawn_left=maxf(0,respawn_left-dt)
		if respawn_left<=0:
			if impostor and lab.session:
				impostor=false;health=100;lab.session.watcher.active=true;lab.session.watcher.camera.current=true;lab.session.watcher.select(lab.session.watcher.selected);return
			health=100;collision_layer=2
			reset_to(lab.session.checkpoint() if lab.session else lab.spawns[lab.station])
		return
	zip.tick(dt)
	if arms_suppressed(): cancel_hands()
	var movement_start:=position
	var was_stone:=stone
	if fixed_mode: fixed_rope.tick(self,dt)
	anchored=held("anchor")
	hand_recovery=maxf(0,hand_recovery-dt)
	tick_buffs(dt)
	combat.tick(dt)
	if (combat.active or combat.charging) and (held("brake") or anchored or not punch_enabled): cancel_hands()
	landing_grace=maxf(0,landing_grace-dt)
	var input:=Vector2(float(held("right"))-float(held("left")),float(held("back"))-float(held("forward")))
	if testing_input: input=input_override
	if leg_disabled and not buffs.has("insulation"): input=Vector2.ZERO
	input=input.limit_length(1)
	var direction:=basis*Vector3(input.x,0,input.y)
	var was_floor:=is_on_floor() and not floor_recheck
	floor_recheck=false
	jump_lock=maxf(0,jump_lock-dt)
	wall_lock=maxf(0,wall_lock-dt)
	jump_buffer=maxf(0,jump_buffer-dt)
	coyote=0.10 if was_floor and jump_lock<=0 else maxf(0,coyote-dt)
	if was_floor and jump_lock<=0: air_jumps=1
	reeling=not fixed_mode and not arms_suppressed() and reel_enabled and held("reel") and has_anchor()
	wall_normal=find_wall() if not arms_suppressed() and held("cling") and wall_grip_enabled and hand_recovery<=0 and not was_floor and wall_lock<=0 else Vector3.ZERO
	wall_clinging=wall_normal.length()>0.5 and not held("brake") and not anchored and not reeling
	stone=(anchored or (brake_enabled and held("brake"))) and not was_floor
	if stone and not was_stone: lab.sound("brake")
	if was_floor: set_crouch(anchored or (brake_enabled and held("brake")))
	var jumped:=false
	if jump_buffer>0 and not stone and not anchored:
		if wall_clinging:
			velocity=wall_normal*7+Vector3.UP*jump_speed
			wall_lock=0.25
			wall_clinging=false
			cancel_hands()
			air_jumps=1
			jumped=true
		elif coyote>0 or (double_jump_enabled and air_jumps>0):
			if coyote<=0: air_jumps-=1
			# A jump can add lift, but must not erase a freshly earned blast/pad launch.
			velocity.y=maxf(velocity.y,jump_speed)
			if reeling: cancel_hands();reeling=false
			jumped=true
		if jumped:
			jump_buffer=0
			coyote=0
			jump_lock=0.12
			lab.sound("jump")
	update_arm_routes(dt)
	var before:=velocity
	if anchored and was_floor:
		cancel_hands();velocity=Vector3.DOWN*gravity*dt;momentum_air=false
	elif stone:
		momentum_air=false
		cancel_hands()
		velocity.x=0
		velocity.z=0
		velocity.y=minf(velocity.y,-8.0)-gravity*1.8*dt
	elif wall_clinging:
		# Hold means hold: no automatic slide, camera roll, or stamina countdown.
		var tangent:=Vector3.UP.cross(wall_normal).normalized()
		if tangent.dot(global_basis.x)<0: tangent=-tangent
		velocity=tangent*input.x*3+Vector3.UP*(-input.y*3)-wall_normal*0.3
		air_jumps=1
	elif reeling and not fixed_mode:
		momentum_air=true
		var target:=Vector3.ZERO
		var count:=0
		for h in hands:
			if h.state==2:
				target+=arm_anchor(h)
				count+=1
				h.spool_target=maxf(2,h.spool_target-8*pull_multiplier()*dt)
		var delta: Vector3=target/count-chest()
		velocity=velocity.move_toward(delta.normalized()*minf(14*pull_multiplier(),delta.length()*2),55*pull_multiplier()*dt)
		velocity.y-=gravity*dt
	else:
		var horizontal:=Vector3(velocity.x,0,velocity.z)
		if was_floor and not jumped and not (flying and flight_time==0):
			var desired:=direction*((1.75 if crouched else walk_speed)*speed_multiplier())
			if has_anchor() and not ball and not fixed_mode:
				var drive: Vector3=((desired-horizontal)*22).limit_length(anchor_drive_limit) if input.length()>0 else -horizontal*12
				horizontal+=(drive+spring_force(position,velocity))*dt
			elif landing_grace<=0 or held("brake"):
				var rate:=ground_accel if input.length()>0 else (170.0 if ball else ground_brake)
				horizontal=horizontal.move_toward(desired,rate*dt)
		else:
			if input.length()>0:
				horizontal=steer_air(horizontal,direction,dt)
			if has_anchor():
				var tension:=spring_force(position,velocity)
				horizontal+=tension*dt
				velocity.y+=tension.y*dt
		velocity.x=horizontal.x
		velocity.z=horizontal.z
		velocity.y-=gravity*dt
	if has_anchor():
		if fixed_mode: fixed_rope.constrain(self,dt)
		else: constrain_tethers(dt)
	move_and_slide()
	if fixed_mode: fixed_rope.after_move(self)
	if flying:
		flight_time+=dt
		last_distance=Vector2(position.x-launch_origin.x,position.z-launch_origin.z).length()
	var bounced:=false
	if is_on_floor() and before.y<0 and not anchored and not (brake_enabled and held("brake")):
		for i in get_slide_collision_count():
			var hit:=get_slide_collision(i)
			if hit.get_normal().y>0.7 and hit.get_collider().get_meta("bounce",false):
				velocity.y=maxf(float(hit.get_collider().get_meta("bounce_speed",13.0)),absf(before.y)*0.9)
				air_jumps=1
				jump_lock=0.12
				coyote=0
				flying=true
				flight_time=0
				launch_origin=position
				bounced=true
				lab.sound("bounce")
	if is_on_floor() and not was_floor and not bounced:
		# Preserve a brief contact for buffered/manual bunny hops; brake remains immediate.
		landing_grace=0.10 if Vector2(velocity.x,velocity.z).length()>walk_speed*speed_multiplier()+0.1 else 0.0
		momentum_air=false
		if before.y < -3: lab.sound("land")
		if flying and flight_time>0.12:
			last_landing=position+Vector3.UP*0.9
			best_distance=maxf(best_distance,last_distance)
			flying=false
		stone=false
	if ball and is_on_floor():
		grounded_time+=dt
		if grounded_time>0.12 and velocity.length()<8: try_stand()
	else: grounded_time=0
	if lab.session and lab.session.training.active:
		if position.y<lab.session.training.origin().y-8: lab.session.training.restart()
	elif position.y < -12 or absf(position.x)>lab.world_limits.x or absf(position.z)>lab.world_limits.y: retry()
	if lab.arena and not (lab.session and lab.session.training.active): lab.arena.travel.update_player(self,movement_start,dt)

	update_hands(dt)
	power=clampf(shot_velocity(position).length()/max_speed,0,1)

func steer_air(horizontal: Vector3,direction: Vector3,dt: float) -> Vector3:
	var speed:=horizontal.length()
	var self_limit:=walk_speed*speed_multiplier()
	if speed<=self_limit+0.01:
		return horizontal.move_toward(direction*self_limit,air_accel*speed_multiplier()*dt).limit_length(self_limit)
	# Rotate earned velocity without minting speed or deleting it during a turn.
	var current:=Vector2(horizontal.x,horizontal.z)
	var target:=Vector2(direction.x,direction.z)
	var turn:=clampf(current.angle_to(target),-air_control/22.5*dt,air_control/22.5*dt)
	current=current.rotated(turn)
	return Vector3(current.x,0,current.y)

func update_hands(dt: float) -> void:
	for i in 2:
		var h: Dictionary = hands[i]
		if h.state==2 and not fixed_mode:
			var requested:=move_toward(h.rest,h.spool_target,8*dt if reeling else 4*dt)
			if requested<h.rest:
				# Blocking a requested shortening must never pay out extra rope.
				var safe_min:=maxf(2,arm_length(h,chest())-stretch_limit)
				requested=maxf(requested,minf(h.rest,safe_min))
			h.rest=requested
		if h.state == 1:
			h.age += dt
			var duration := maxf(0.08,h.from.distance_to(h.point)/65.0)
			if h.age >= duration:
				if h.hit:
					if is_instance_valid(h.body) and h.body.has_method("try_pickup"):
						if not h.body.try_pickup(self,i): h.state=0
					elif is_instance_valid(h.body) and h.body.has_method("hand_touch"):
						h.body.hand_touch(self,i);h.state=0
					elif is_instance_valid(h.body) and h.body.get_meta("button",false):
						lab.hit_button()
						h.state = 0
					else:
						h.state = 2
						h.rest = maxf(3.0,chest().distance_to(h.point)+slack_allowance)
						h.spool_target=h.rest
						if fixed_mode: fixed_rope.attach(self,i)
						lab.sound("stick")
				else:
					h.state = 0
					lab.notify("No grip in reach. Aim at a teal pad or another grip surface.")
	var target := ray(camera.global_position,camera.global_position-camera.global_basis.z*hand_range())
	target_valid = hand_recovery<=0 and not target.is_empty() and bool(target.collider.get_meta("grippy",false))
	target_text = "GRIP" if target_valid else ""
	if target_valid and target.collider.get_meta("button",false): target_text = "OPEN SHUTTER"

func _process(dt: float) -> void:
	if lab.paused: return
	if lab.builder and lab.builder.active and not lab.builder.testing:
		for h in hands:h.glove.hide();h.fist.hide();h.cord.hide();h.lamp.hide()
		avatar.hide();return
	glove_fill.light_energy=0.12 if lab.session and lab.session.watcher.blackout>0 else 0.7
	if (lab.session and lab.session.watcher and lab.session.watcher.active) or respawn_left>0:
		for h in hands: h.glove.hide();h.fist.hide();h.cord.hide();h.lamp.hide()
		avatar.hide();ball_rim.hide();return
	visual_time+=dt
	recoil = move_toward(recoil,0,dt*5)
	camera.position.y = lerpf(camera.position.y,1.42 if crouched else 1.58,1-exp(-dt*15))
	camera.fov = lerpf(camera.fov,84+(clampf(velocity.length()/40,0,1)*5 if camera_motion else 0),1-exp(-dt*5))
	# Keep the ball outline below the recovering wrists so their state is readable.
	ball_rim.position.y=lerpf(-0.26,-0.35,smoothstep(0.0,0.35,hand_recovery))
	ball_rim.hide()
	avatar.pose(self,dt)
	if buffs.has("invisible"):avatar.hide()
	update_camera(dt)
	arm_frame += 1
	for i in 2:
		var h: Dictionary = hands[i]
		var start := hand_start(i)
		var end := start
		if h.state == 1:
			var duration := maxf(0.08,h.from.distance_to(h.point)/65.0)
			end = h.from.lerp(h.point,clampf(h.age/duration,0,1))
		elif h.state == 2:
			end = h.point+h.normal*0.08
		elif h.state in [3,4,5]: end=h.point
		if combat.charging:
			var charge:float=combat.charge_fraction()
			var shake:=sin(visual_time*73)*0.008 if charge>=0.99 else 0.0
			end=start+camera.global_basis*Vector3((-1.0 if i==0 else 1.0)*(0.06*charge+shake),0.07*charge,0.16*charge)
		h.retract_left = maxf(0,h.retract_left-dt)
		if h.state==0 and h.retract_left>0:
			end = start.lerp(h.retract_pos,pow(h.retract_left/0.14,2))
		if hand_recovery>0:
			# Catch -> fast physical return -> low wrists winding in -> rise to ready.
			# The physics timer owns this animation; pause cannot consume recovery.
			var elapsed:=HAND_RECOVERY_DURATION-hand_recovery
			var settle:=smoothstep(0.0,0.35,hand_recovery)
			var dock:=start+camera.global_basis*Vector3(0,-0.06*settle,0.02*settle)
			end=recovery_origins[i].lerp(dock,1-pow(1-clampf(elapsed/0.45,0,1),3))
		h.glove.visible = not combat.pose_fists
		h.fist.visible=combat.pose_fists
		h.cord.visible = h.glove.visible or h.fist.visible
		h.lamp.omni_range=13*vision_multiplier()
		h.lamp.visible=grip_lights
		h.lamp.global_position=end+(h.normal*0.45 if h.state==2 else Vector3.UP*0.15)
		h.glove.global_position = end
		h.glove.global_basis = camera.global_basis
		if hand_recovery>0:
			var wind:=sin((HAND_RECOVERY_DURATION-hand_recovery)*18)*0.055
			h.glove.rotate_object_local(Vector3.FORWARD,(0.23+wind)*(-1 if i==0 else 1)*smoothstep(0.0,0.35,hand_recovery))
		h.glove.scale = Vector3.ONE*0.7
		h.fist.global_position=end;h.fist.global_basis=combat.shot_basis if combat.active else camera.global_basis
		h.fist.scale=Vector3.ONE*0.7
		if combat.charging:
			h.fist.rotate_object_local(Vector3.UP,(-1 if i==0 else 1)*lerpf(0.08,0.38,combat.charge_fraction()))
			h.fist.rotate_object_local(Vector3.RIGHT,-0.25*combat.charge_fraction())
		if h.state == 2:
			var direction: Vector3 = h.normal
			h.glove.look_at(end-direction,Vector3.FORWARD if absf(direction.dot(Vector3.UP))>0.98 else Vector3.UP)
		var shoulder := camera.global_transform*Vector3(-0.30 if i==0 else 0.30,-0.42,-0.1)
		if third_person: shoulder=avatar.shoulder_position(i)
		var slack: float = maxf(0,h.rest-arm_length(h,chest())) if h.state==2 else 0.0
		var strain: float = maxf(0,arm_length(h,chest())-h.rest)/stretch_limit if h.state==2 else 0.0
		if h.cord.visible:
			var curl:=global_basis*Vector3(-0.12 if i==0 else 0.12,0.06,0.10) if third_person and ball and h.state==0 else Vector3.ZERO
			h.cord.shape_arm(shoulder,end-h.glove.global_basis.y*0.17,slack,strain,h.color,curl,0.055 if third_person and ball and h.state==0 else 0.034,h.route.points() if h.state==2 else [])

func predict_landing() -> Vector3:
	# Physics-only diagnostic used by verification; no visual trajectory is created.
	var p := position+Vector3.UP*0.9
	var v := shot_velocity(position)
	var step := 0.065
	var last := p
	for i in 33:
		# Integrate the same gravity, then sweep the ball volume between samples.
		var next := p+v*step+Vector3.DOWN*gravity*0.5*step*step
		var q := PhysicsShapeQueryParameters3D.new()
		q.shape = preview_shape
		q.transform = Transform3D(Basis.IDENTITY,p)
		q.motion = next-p
		q.collision_mask = 1
		q.exclude = [get_rid()]
		q.margin = 0.002
		var fraction := get_world_3d().direct_space_state.cast_motion(q)
		if fraction[0] < 1:
			last = p.lerp(next,fraction[0])
			break
		p = next
		v.y -= gravity*step
		last = p
	return last

func attach_fixture(a: Vector3,b: Vector3) -> void:
	for i in 2:
		hands[i].state = 2
		hands[i].point = a if i==0 else b
		hands[i].normal = Vector3.BACK
		hands[i].rest = maxf(3.0,chest().distance_to(hands[i].point)+slack_allowance)
		hands[i].spool_target=hands[i].rest
		hands[i].body = null


func has_cargo() -> bool:
	return is_instance_valid(cargo)

func take_damage(amount:float,_source:=Vector3.ZERO,_kind:="hit") -> void:
	if amount<=0:return
	if respawn_left>0 or (lab.session and lab.session.watcher and lab.session.watcher.active): return
	var resistance:=0.5 if held("anchor") else 1.0
	if buffs.has("toughness"): resistance*=0.5
	damage_feedback.record(amount*resistance,_source,_kind)
	health=maxf(0,health-maxf(0,amount)*resistance);damage_flash=0.25
	if health<=0:
		preload("res://scripts/gameplay/fiver_death.gd").spawn(self,_source)
		cancel_hands(true);clear_mouse_chord();velocity=Vector3.ZERO;respawn_left=3.0;collision_layer=0

func heal_full() -> void:
	if respawn_left<=0: health=100
