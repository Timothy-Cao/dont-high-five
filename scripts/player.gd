extends CharacterBody3D

var lab: Node3D
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
var ball_shape := SphereShape3D.new()
var ball := false
var crouched := false
var crouch_shape := CapsuleShape3D.new()
var walk_speed := 7.0
var ground_accel := 100.0
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
var camera_motion := false
var grip_lights := true
var grounded_time := 0.0
var launch_gain := 4.2
var gravity := 24.0
var air_control := 36.0
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
var preview_enabled := true
var hands: Array[Dictionary] = []
var preview_dots: Array[MeshInstance3D] = []
var predicted_end := Vector3.ZERO
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
var preview_tick := 0
var arm_frame := 0
var recoil := 0.0
var ball_rim: MeshInstance3D
var preview_shape := SphereShape3D.new()
const CHORD_WINDOW_MS := 120
const ZIP_SPEED := 28.0
const HAND_RANGE := 25.5
const ZIP_RANGE := 17.0
const HAND_RECOVERY_DURATION := 2.0
var mouse_down := [false, false]
var mouse_pressed_at := [-1000, -1000]
var chord_latched := false
var zip_pending := false
var zip_enabled := true
var zip_catch_time := 0.0
var hand_recovery := 0.0
var recovery_origins: Array[Vector3] = [Vector3.ZERO,Vector3.ZERO]
var zip_direction := Vector3.ZERO
var zip_count := 0

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	stand_shape.radius = 0.34
	stand_shape.height = 1.8
	crouch_shape.radius = 0.34
	crouch_shape.height = 1.05
	ball_shape.radius = 0.32
	preview_shape.radius = 0.32
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
	var glove_fill:=DirectionalLight3D.new()
	lab.add_child(glove_fill)
	glove_fill.light_cull_mask=6
	glove_fill.light_energy=0.7
	glove_fill.rotation_degrees=Vector3(-35,-25,0)
	for i in 2:
		var c := Color("c88240") if i == 0 else Color("488f83")
		var glove: Node3D = load("res://assets/glove_left.glb" if i==0 else "res://assets/glove_right.glb").instantiate()
		lab.add_child(glove)
		for piece in glove.find_children("*","MeshInstance3D",true,false):
			piece.layers=2
			piece.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
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
		lamp.light_cull_mask=1
		lamp.omni_range=13
		lamp.omni_attenuation=1.4
		lamp.shadow_enabled=true
		lamp.shadow_caster_mask=1
		lamp.light_size=0.18
		var cord = load("res://scripts/elastic_arm.gd").new()
		lab.add_child(cord)
		hands.append({"state":0,"point":Vector3.ZERO,"normal":Vector3.FORWARD,"rest":0.0,"age":0.0,"from":Vector3.ZERO,"hit":false,"body":null,"glove":glove,"cord":cord,"color":c,"retract_left":0.0,"retract_pos":Vector3.ZERO,"spool_target":0.0,"lamp":lamp})
	for i in 34:
		var dot := MeshInstance3D.new()
		var s := SphereMesh.new()
		s.radius = 0.045 if i<33 else 0.22
		s.height = s.radius*2
		s.radial_segments = 8
		s.rings = 4
		dot.mesh = s
		dot.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		dot.material_override = lab.mat(Color("fff0aa"),0.3)
		lab.add_child(dot)
		dot.hide()
		preview_dots.append(dot)
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
	avatar=load("res://scripts/avatar.gd").new();add_child(avatar);avatar.hide()
	follow_camera=Camera3D.new();lab.add_child(follow_camera)
	follow_camera.near=0.08;follow_camera.far=420;follow_camera.fov=84
	follow_shape.radius=0.28

func toggle_view() -> void:
	third_person=not third_person
	follow_camera.current=third_person;camera.current=not third_person
	camera_cut=true
	update_camera(0.016)

func aim_point() -> Vector3:
	var end:=camera.global_position-camera.global_basis.z*HAND_RANGE
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
	avatar.visible=camera_distance>0.9
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
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode in [KEY_ESCAPE,KEY_TAB]:
			if lab.paused and lab.hud.page!="Home": lab.hud.go_back()
			else: lab.set_paused(not lab.paused)
			return
		if event.keycode==KEY_F11:
			fullscreen = not fullscreen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)
			return
	if lab.paused: return
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
		elif event.is_action_pressed("pop_jump"): request_jump()
		elif event.is_action_pressed("pop_launch"): launch()
		elif event.is_action_pressed("pop_recall") or event.keycode==KEY_BACKSPACE: cancel_hands()
		elif event.is_action_pressed("pop_retry"): retry()
		elif event.is_action_pressed("pop_reset"): lab.goto_station(lab.station)
		elif event.is_action_pressed("pop_preview"): preview_enabled=not preview_enabled
		elif event.keycode in [KEY_1,KEY_2,KEY_3,KEY_4]: lab.goto_station(event.keycode-KEY_1)

func apply_mouse_motion(event: InputEventMouseMotion) -> void:
	rotate_y(-event.screen_relative.x*sensitivity)
	camera.rotation.x=clampf(camera.rotation.x-event.screen_relative.y*sensitivity,-1.4,1.4)

func request_jump() -> void:
	jump_buffer=0.12

func clear_mouse_chord() -> void:
	mouse_down=[false,false]
	mouse_pressed_at=[-1000,-1000]
	chord_latched=false

func handle_glove_button(i: int,pressed: bool,at_ms: int = -1) -> void:
	if mouse_down[i]==pressed: return
	mouse_down[i]=pressed
	if not pressed:
		if not mouse_down[0] and not mouse_down[1]: chord_latched=false
		return
	var now:=Time.get_ticks_msec() if at_ms<0 else at_ms
	mouse_pressed_at[i]=now
	if mouse_down[1-i] and not chord_latched and now-mouse_pressed_at[1-i]<=CHORD_WINDOW_MS:
		chord_latched=true
		if begin_zip(): return
	# No chord timeout on the first shot: normal glove placement remains instant.
	fire_hand(i)

func begin_zip() -> bool:
	if not zip_enabled or stone or held("brake") or hand_recovery>0 or zip_pending: return false
	var hits: Array[Dictionary]=[]
	var direction: Vector3=-camera.global_basis.z
	for i in 2:
		var origin:=hand_start(i)
		# Reject a muzzle clipped through nearby cover before tracing forward.
		if not ray(camera.global_position,origin).is_empty(): return false
		var hit:=ray(origin,origin+direction*ZIP_RANGE)
		if hit.is_empty() or not hit.collider.get_meta("grippy",false) or hit.collider.get_meta("button",false):
			lab.notify("Zip needs room for both gloves on a grip surface.")
			return false
		if origin.distance_to(hit.position)<3: return false
		hits.append(hit)
	cancel_hands()
	zip_pending=true
	zip_catch_time=0
	zip_direction=direction
	for i in 2:
		var h: Dictionary=hands[i]
		h.from=hand_start(i)
		h.point=hits[i].position
		h.normal=hits[i].normal
		h.body=hits[i].collider
		h.hit=true
		h.age=0.0
		h.retract_left=0.0
		h.state=1
	lab.sound("fire")
	return true

func finish_zip() -> void:
	var v:=zip_direction*ZIP_SPEED
	# A level shot needs a small hop so ground friction does not eat the burst.
	if is_on_floor() and v.y>=-1: v.y=maxf(v.y,6.0)
	v=v.limit_length(ZIP_SPEED)
	set_ball(true)
	velocity=v
	crouched=false
	wall_clinging=false
	wall_lock=0.2
	momentum_air=true
	coyote=0
	jump_lock=0.12
	launch_origin=position
	flying=true
	flight_time=0
	grounded_time=0
	shots+=1
	zip_count+=1
	recoil=1
	for i in 2:
		recovery_origins[i]=hands[i].point+hands[i].normal*0.08
	cancel_hands()
	hand_recovery=HAND_RECOVERY_DURATION
	for h in hands: h.retract_left=0.0
	lab.sound("launch")

func has_anchor() -> bool:
	return hands[0].state==2 or hands[1].state==2

func adjust_length(amount: float) -> void:
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
	collider.position.y=0.525 if value else 0.9

func fire_hand(i: int) -> void:
	if stone or hand_recovery>0: return
	if zip_pending: cancel_hands()
	# Gloves can be fired in flight to chain a launch into a grapple.
	var h: Dictionary = hands[i]
	if h.state != 0:
		h.retract_pos = h.glove.global_position
		h.retract_left = 0.14
		h.state = 0
		lab.sound("cancel")
		return
	var from := camera.global_position
	var to := from-camera.global_basis.z*HAND_RANGE
	var result := ray(from,to)
	h.point = result.position if not result.is_empty() else to
	h.normal = result.normal if not result.is_empty() else Vector3.UP
	h.body = result.get("collider")
	h.hit = not result.is_empty() and bool(h.body.get_meta("grippy",false))
	h.from = hand_start(i)
	h.age = 0.0
	h.state = 1
	lab.sound("fire")

func cancel_hands() -> void:
	zip_pending=false
	zip_catch_time=0
	for h in hands:
		if h.state!=0:
			h.retract_pos = h.glove.global_position
			h.retract_left = 0.14
		h.state = 0
		h.rest = 0.0

func pull_vector(at: Vector3) -> Vector3:
	var total := Vector3.ZERO
	for h in hands:
		if h.state != 2:
			continue
		var d: Vector3 = h.point-(at+Vector3.UP*1.15)
		var extension := clampf(d.length()-float(h.rest),0,stretch_limit)
		total += d.normalized()*(spring_stiffness*extension+spring_cubic*pow(extension,3))
	return total

func elastic_energy(at: Vector3) -> float:
	var energy := 0.0
	for h in hands:
		if h.state != 2: continue
		var extension := clampf((h.point-(at+Vector3.UP*1.15)).length()-float(h.rest),0,stretch_limit)
		energy += 0.5*spring_stiffness*extension*extension+0.25*spring_cubic*pow(extension,4)
	return energy

func spring_force(at: Vector3,vel: Vector3) -> Vector3:
	var force := Vector3.ZERO
	for h in hands:
		if h.state != 2: continue
		var d: Vector3 = h.point-(at+Vector3.UP*1.15)
		var extension := maxf(0,d.length()-float(h.rest))
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
			var anchor: Vector3 = h.point-Vector3.UP*1.15
			var maximum: float = h.rest+stretch_limit
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
	# A straight arm cannot wrap a corner. Stop the crossing motion instead of severing it.
	for h in hands:
		if h.state!=2: continue
		var obstruction := ray(next+Vector3.UP*1.15,h.point+h.normal*0.04)
		if not obstruction.is_empty() and obstruction.position.distance_to(h.point)>0.35:
			var current := ray(chest(),h.point+h.normal*0.04)
			if current.is_empty() or current.position.distance_to(h.point)<=0.35:
				next.x = position.x
				next.z = position.z
				tether_limited = true
	velocity = (next-position)/dt

func shot_velocity(at: Vector3) -> Vector3:
	var pull := pull_vector(at)
	if pull.length() < 0.04:
		return Vector3.ZERO
	var speed := sqrt(2.0*elastic_energy(at)/ball_mass)*(launch_gain/4.2)
	return pull.normalized()*minf(max_speed,speed)

func launch() -> void:
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
	collider.shape = ball_shape if value else (crouch_shape if crouched else stand_shape)
	collider.position.y = 0.32 if value else (0.525 if crouched else 0.9)
	ball_rim.visible = value

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
	cancel_hands()
	flying = false
	flight_time = 0
	grounded_time = 0
	power = 0

func retry() -> void:
	if last_setup.is_empty():
		lab.goto_station(lab.station)
		return
	reset_to(last_setup.position)
	rotation.y = last_setup.yaw
	camera.rotation.x = last_setup.pitch
	for i in 2:
		for key in last_setup.hands[i]:
			hands[i][key] = last_setup.hands[i][key]
	lab.notify("Setup restored. Adjust your position or change either hand.")

func _physics_process(dt: float) -> void:
	if lab.paused: return
	var movement_start:=position
	var was_stone:=stone
	hand_recovery=maxf(0,hand_recovery-dt)
	if zip_pending and held("brake"): cancel_hands()
	var input:=Vector2(float(held("right"))-float(held("left")),float(held("back"))-float(held("forward")))
	if testing_input: input=input_override
	input=input.limit_length(1)
	var direction:=basis*Vector3(input.x,0,input.y)
	var was_floor:=is_on_floor()
	jump_lock=maxf(0,jump_lock-dt)
	wall_lock=maxf(0,wall_lock-dt)
	jump_buffer=maxf(0,jump_buffer-dt)
	coyote=0.10 if was_floor and jump_lock<=0 else maxf(0,coyote-dt)
	if was_floor and jump_lock<=0: air_jumps=1
	reeling=reel_enabled and held("reel") and has_anchor()
	wall_normal=find_wall() if held("cling") and wall_grip_enabled and hand_recovery<=0 and not was_floor and wall_lock<=0 else Vector3.ZERO
	wall_clinging=wall_normal.length()>0.5 and not held("brake") and not reeling
	stone=brake_enabled and held("brake") and not was_floor
	if stone and not was_stone: lab.sound("brake")
	if was_floor: set_crouch(brake_enabled and held("brake"))
	var jumped:=false
	if jump_buffer>0 and not stone:
		if wall_clinging:
			velocity=wall_normal*7+Vector3.UP*jump_speed
			wall_lock=0.25
			wall_clinging=false
			cancel_hands()
			air_jumps=1
			jumped=true
		elif coyote>0 or (double_jump_enabled and air_jumps>0):
			if coyote<=0: air_jumps-=1
			velocity.y=jump_speed
			if reeling: cancel_hands();reeling=false
			jumped=true
		if jumped:
			jump_buffer=0
			coyote=0
			jump_lock=0.12
			lab.sound("jump")
	var before:=velocity
	if stone:
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
	elif reeling:
		momentum_air=true
		var target:=Vector3.ZERO
		var count:=0
		for h in hands:
			if h.state==2:
				target+=h.point
				count+=1
				h.spool_target=maxf(2,h.spool_target-8*dt)
		var delta: Vector3=target/count-chest()
		velocity=velocity.move_toward(delta.normalized()*minf(14,delta.length()*2),55*dt)
		velocity.y-=gravity*dt
	else:
		var horizontal:=Vector3(velocity.x,0,velocity.z)
		if was_floor and not jumped and not (flying and flight_time==0):
			var desired:=direction*(3.0 if crouched else walk_speed)
			if has_anchor() and not ball:
				var drive: Vector3=((desired-horizontal)*22).limit_length(anchor_drive_limit) if input.length()>0 else -horizontal*12
				horizontal+=(drive+spring_force(position,velocity))*dt
			else:
				var rate:=ground_accel if input.length()>0 else (170.0 if ball else ground_brake)
				horizontal=horizontal.move_toward(desired,rate*dt)
		else:
			if input.length()>0:
				# Turn toward intent without deleting launch momentum or accelerating without limit.
				horizontal=horizontal.move_toward(direction*maxf(9,horizontal.length()),air_control*dt)
			elif not flying and not momentum_air:
				horizontal=horizontal.move_toward(Vector3.ZERO,7*dt)
			if has_anchor():
				var tension:=spring_force(position,velocity)
				horizontal+=tension*dt
				velocity.y+=tension.y*dt
		velocity.x=horizontal.x
		velocity.z=horizontal.z
		velocity.y-=gravity*dt
	if has_anchor(): constrain_tethers(dt)
	move_and_slide()
	if flying:
		flight_time+=dt
		last_distance=Vector2(position.x-launch_origin.x,position.z-launch_origin.z).length()
	var bounced:=false
	if is_on_floor() and before.y<0 and not (brake_enabled and held("brake")):
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
		momentum_air=false
		if before.y < -3: lab.sound("land")
		if flying and flight_time>0.12:
			last_landing=position+Vector3.UP*0.32
			best_distance=maxf(best_distance,last_distance)
			flying=false
		stone=false
	if ball and is_on_floor():
		grounded_time+=dt
		if grounded_time>0.12 and velocity.length()<8: try_stand()
	else: grounded_time=0
	if position.y < -12 or absf(position.x)>lab.world_limits.x or absf(position.z)>lab.world_limits.y: retry()
	if lab.arena: lab.arena.travel.update_player(self,movement_start,dt)
	if is_on_floor() and not ball and not flying:
		step_distance+=Vector2(position.x-movement_start.x,position.z-movement_start.z).length()
		if step_distance>1.9:
			step_distance=0;lab.sound("step",0.92 if crouched else 1.0)
	else: step_distance=0
	update_hands(dt)
	power=clampf(shot_velocity(position).length()/max_speed,0,1)
	preview_tick+=1
	if preview_tick%5==0: update_preview()

func update_hands(dt: float) -> void:
	for i in 2:
		var h: Dictionary = hands[i]
		if h.state==2:
			var requested:=move_toward(h.rest,h.spool_target,8*dt if reeling else 4*dt)
			if requested<h.rest:
				# Blocking a requested shortening must never pay out extra rope.
				var safe_min:=maxf(2,chest().distance_to(h.point)-stretch_limit)
				requested=maxf(requested,minf(h.rest,safe_min))
			h.rest=requested
		if h.state == 1:
			h.age += dt
			var duration := maxf(0.08,h.from.distance_to(h.point)/(95.0 if zip_pending else 65.0))
			if h.age >= duration:
				if h.hit:
					if is_instance_valid(h.body) and h.body.get_meta("button",false):
						lab.hit_button()
						h.state = 0
					else:
						h.state = 2
						h.rest = maxf(3.0,chest().distance_to(h.point)+slack_allowance)
						h.spool_target=h.rest
						lab.sound("stick")
				else:
					h.state = 0
					lab.notify("No grip in reach. Aim at a teal pad or another grip surface.")
	if zip_pending and hands[0].state==2 and hands[1].state==2:
		zip_catch_time+=dt
		if zip_catch_time>=0.055: finish_zip()
	var target := ray(camera.global_position,camera.global_position-camera.global_basis.z*HAND_RANGE)
	target_valid = hand_recovery<=0 and not target.is_empty() and bool(target.collider.get_meta("grippy",false))
	target_text = "GRIP" if target_valid else ""
	if target_valid and target.collider.get_meta("button",false): target_text = "OPEN SHUTTER"

func _process(dt: float) -> void:
	if lab.paused: return
	recoil = move_toward(recoil,0,dt*5)
	camera.position.y = lerpf(camera.position.y,0.43 if ball else (0.9 if crouched else 1.58),1-exp(-dt*15))
	camera.fov = lerpf(camera.fov,84+(clampf(velocity.length()/40,0,1)*5 if camera_motion else 0),1-exp(-dt*5))
	# Keep the ball outline below the recovering wrists so their state is readable.
	ball_rim.position.y=lerpf(-0.26,-0.35,smoothstep(0.0,0.35,hand_recovery))
	ball_rim.visible=ball and not third_person
	avatar.pose(self,dt)
	update_camera(dt)
	arm_frame += 1
	for i in 2:
		var h: Dictionary = hands[i]
		var start := hand_start(i)
		var end := start
		if h.state == 1:
			var duration := maxf(0.08,h.from.distance_to(h.point)/(95.0 if zip_pending else 65.0))
			end = h.from.lerp(h.point,clampf(h.age/duration,0,1))
		elif h.state == 2:
			end = h.point+h.normal*0.08
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
		h.glove.visible = not ball or h.state!=0 or wall_clinging or h.retract_left>0 or hand_recovery>0
		h.cord.visible = h.glove.visible
		h.lamp.visible=grip_lights
		h.lamp.global_position=end+(h.normal*0.45 if h.state==2 else Vector3.UP*0.15)
		h.glove.global_position = end
		h.glove.global_basis = camera.global_basis
		if hand_recovery>0:
			var wind:=sin((HAND_RECOVERY_DURATION-hand_recovery)*18)*0.055
			h.glove.rotate_object_local(Vector3.FORWARD,(0.23+wind)*(-1 if i==0 else 1)*smoothstep(0.0,0.35,hand_recovery))
		h.glove.scale = Vector3.ONE*0.7
		if h.state == 2:
			var direction: Vector3 = h.normal
			if absf(direction.dot(Vector3.UP))<0.98:
				h.glove.look_at(end-direction,Vector3.UP)
		var shoulder := camera.global_transform*Vector3(-0.30 if i==0 else 0.30,-0.42,-0.1)
		if third_person: shoulder=global_transform*Vector3(-0.325 if i==0 else 0.325,0.95 if crouched else 1.17,0)
		var slack: float = maxf(0,h.rest-chest().distance_to(h.point)) if h.state==2 else 0.0
		var strain: float = maxf(0,chest().distance_to(h.point)-h.rest)/stretch_limit if h.state==2 else 0.0
		if h.cord.visible:
			h.cord.shape_arm(shoulder,end-h.glove.global_basis.y*0.17,slack,strain,h.color)

func update_preview() -> void:
	for dot in preview_dots: dot.hide()
	if ball or not preview_enabled or power<0.025: return
	var p := position+Vector3.UP*0.32
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
		preview_dots[i].position = p
		preview_dots[i].show()
		last = p
	predicted_end = last
	preview_dots[33].position = last
	preview_dots[33].show()

func attach_fixture(a: Vector3,b: Vector3) -> void:
	for i in 2:
		hands[i].state = 2
		hands[i].point = a if i==0 else b
		hands[i].normal = Vector3.BACK
		hands[i].rest = maxf(3.0,chest().distance_to(hands[i].point)+slack_allowance)
		hands[i].spool_target=hands[i].rest
		hands[i].body = null

