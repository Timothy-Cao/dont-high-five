extends Node3D

const PAWN = preload("res://scripts/player.gd")
const HUD = preload("res://scripts/hud.gd")
const CREAM = Color("b6ac94")
const INK = Color("20283d")
const MINT = Color("347d87")
const GOLD = Color("e5a35e")
var preferences = preload("res://scripts/preferences.gd").new()
var scripted_run := false
var controls: Node
var environment: Environment
var visibility_fill := 0.12
# Approximate base High Fiver distance at which exponential haze obscures 90%.
var fog_distance:=100.0
var world_hints: Array[Label3D] = []
var rounded_mesh: Mesh
var player: CharacterBody3D
var hud: Control
var paused := false
var station := 0
var spawns: Array[Vector3] = [Vector3(0,3.05,12), Vector3(-28,3.05,12), Vector3(28,3.05,12), Vector3(0,0.05,35)]
var station_names := ["01  /  FIRST CLASS", "02  /  AIR MAIL", "03  /  LETTER BOX", "04  /  AFTER HOURS"]
var message := ""
var message_time := 8.0
var gate: StaticBody3D
var gate_open := false
var targets: Array[Dictionary] = []
var audio_enabled := true
var audio_service: Node
var started := false
var arena: Node3D
var session:Node3D
var builder:Node3D
var test_world:=false
var world_limits:=Vector2(156,124)

func _ready() -> void:
	DirAccess.make_dir_recursive_absolute("res://.local/reports")
	var args:=OS.get_cmdline_user_args()
	scripted_run = not args.is_empty()
	test_world="--verify" in args or "--metrics" in args or "--polish" in args or "--capture" in args
	if test_world: world_limits=Vector2(70,75)
	controls=load("res://scripts/bindings.gd").new()
	add_child(controls)
	var block: Node3D = load("res://assets/rounded_block.glb").instantiate()
	rounded_mesh = block.find_children("*", "MeshInstance3D", true, false)[0].mesh
	block.free()
	build_world()
	player = PAWN.new()
	player.lab = self
	add_child(player)
	if not test_world:
		session=load("res://scripts/gameplay/session.gd").new();session.lab=self;add_child(session);session.build()
	if not test_world:
		builder=load("res://scripts/world/map_builder.gd").new();builder.lab=self;add_child(builder)
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = HUD.new()
	hud.lab = self
	layer.add_child(hud)
	build_audio()
	if not scripted_run: preferences.restore(self)
	goto_station(0)
	if not load("res://tests/runner.gd").new().start(self,args):
		set_paused(true)

func save_preferences() -> void:
	if not scripted_run and preferences.save(self) != OK:
		push_warning("Could not save settings; current session values remain active.")

func mat(c: Color, glow: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.82
	if glow > 0:
		m.emission_enabled = true
		m.emission = c
		m.emission_energy_multiplier = glow
	return m

func box(pos: Vector3, size: Vector3, color: Color, grippy := true, solid := true) -> Node3D:
	var root: Node3D = StaticBody3D.new() if solid else Node3D.new()
	add_child(root)
	root.position = pos
	root.set_meta("grippy", grippy)
	var mesh := MeshInstance3D.new()
	mesh.mesh = rounded_mesh
	mesh.scale = size
	mesh.material_override = mat(color)
	if not solid: mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	root.add_child(mesh)
	if solid:
		var collision := CollisionShape3D.new()
		var b := BoxShape3D.new()
		b.size = size
		collision.shape = b
		root.add_child(collision)
	return root

func label3(text: String, pos: Vector3, scale_size := 0.018, color := CREAM) -> Label3D:
	var l := Label3D.new()
	add_child(l)
	l.text = text
	l.position = pos
	l.font_size = 48
	l.pixel_size = scale_size
	l.modulate = color
	l.outline_size = 0
	l.no_depth_test = false
	return l

func panel(x: float, y: float, z: float, w := 3.0, h := 4.0) -> void:
	box(Vector3(x,y,z), Vector3(w,h,0.45), MINT)
	for dx in [-w*0.5+0.08,w*0.5-0.08]:
		glow_box(Vector3(x+dx,y,z+0.24),Vector3(0.07,h-0.2,0.05),Color("67dcd6"),1.4)
	for dy in [-1.2, -0.6, 0.0, 0.6, 1.2]:
		glow_box(Vector3(x,y+dy,z+0.24), Vector3(w-0.5,0.045,0.045),Color("509ca6"),0.8)
	label3("GRIP",Vector3(x,y+h*0.5-0.45,z+0.25),0.0045,INK)
	box(Vector3(x,1.5,z), Vector3(0.3,3,0.4), INK, false)

func deck(pos: Vector3, size: Vector3, color := Color("303d51")) -> void:
	box(pos-size.y*0.5*Vector3.UP, size, color)
	for z in [-size.z*0.5+0.12,size.z*0.5-0.12]:
		glow_box(pos+Vector3(0,0.025,z),Vector3(size.x,0.03,0.09),GOLD,1.0)
	for x in [-size.x*0.5+0.15,size.x*0.5-0.15]:
		box(pos+Vector3(x,0.015,0),Vector3(0.08,0.03,size.z),Color("537987"),false,false)

func landing(pos: Vector3, size: Vector2, title: String) -> void:
	deck(pos,Vector3(size.x,0.7,size.y), MINT.darkened(0.15))
	var ring := MeshInstance3D.new()
	var torus := TorusMesh.new()
	torus.inner_radius = 1.7
	torus.outer_radius = 1.85
	ring.mesh = torus
	ring.material_override = mat(GOLD,1.2)
	add_child(ring)
	ring.position = pos + Vector3.UP*0.045
	ring.scale.y = 0.1
	label3(title,pos+Vector3(0,0.65,-size.y*0.5),0.013)
	targets.append({"pos":pos,"size":size,"hit":false,"ring":ring})

func build_world() -> void:
	var env := WorldEnvironment.new()
	var e := Environment.new()
	environment=e
	e.background_mode=Environment.BG_COLOR
	e.background_color=Color("080b16")
	e.ambient_light_source=Environment.AMBIENT_SOURCE_COLOR
	e.ambient_light_color=Color("a1b5dc")
	e.ambient_light_energy=visibility_fill
	e.tonemap_mode=Environment.TONE_MAPPER_FILMIC
	e.glow_enabled=true
	e.glow_intensity=0.45
	e.ssao_enabled=true
	e.ssao_radius=1.2
	e.fog_enabled=true
	e.fog_light_color=Color("1b2440")
	e.fog_density=0.003
	env.environment=e
	add_child(env)
	if not test_world:
		e.ambient_light_energy=0.17
		visibility_fill=0.17
		e.fog_density=2.302585/fog_distance
		e.fog_light_color=Color("0c1323")
		e.fog_light_energy=0.7
		arena=load("res://scripts/world/arena.gd").new()
		arena.lab=self
		add_child(arena)
		arena.build()
		spawns=[Vector3(-14,0.05,23),Vector3(-48,0.05,20),Vector3(49,0.05,-25),Vector3(0,0.05,32)]
		station_names=["Atrium","Amber tower","Violet galleries","Low tunnels"]
		return
	box(Vector3(0,-0.4,0),Vector3(100,0.8,110),Color("1a2233"))
	for x in range(-48,49,4):
		box(Vector3(x,0.01,0),Vector3(0.025,0.015,108),Color("2a354a"),false,false)
	for z in range(-52,53,4):
		box(Vector3(0,0.012,z),Vector3(98,0.015,0.025),Color("2a354a"),false,false)
	for x in [-50,50]:
		box(Vector3(x,13,0),Vector3(0.8,26,110),INK,true)
	for z in [-55,55]:
		box(Vector3(0,13,z),Vector3(100,26,0.8),INK,true)
	box(Vector3(0,26,0),Vector3(100,1,110),INK,true)
	for z in range(-50,51,20):
		box(Vector3(0,24,z),Vector3(99,1.2,0.8),Color("344056"),false)
		glow_box(Vector3(0,23.32,z),Vector3(82,0.08,0.13),Color("5986a6"),0.8)
		for x in [-46,46]:
			box(Vector3(x,12,z),Vector3(1,24,1),Color("344056"),true)
			glow_box(Vector3(x,9,z+0.53),Vector3(0.12,16,0.06),Color("6776bd"),1.3)
	for pos in [Vector3(0,18,10),Vector3(-28,18,10),Vector3(28,18,10),Vector3(0,18,35)]:
		var light:=SpotLight3D.new()
		add_child(light)
		light.position=pos
		light.rotation_degrees.x=-90
		light.light_color=Color("759fc2")
		light.light_energy=5
		light.spot_range=27
		light.spot_angle=58
		light.shadow_enabled=false
		glow_box(pos+Vector3.UP*0.3,Vector3(4,0.15,2),Color("8ac5cc"),2)
	# Broad attachment panels allow actual placement choices rather than snap points.
	deck(Vector3(0,3,13),Vector3(18,0.7,14))
	panel(-4,7,5,3,5)
	panel(4,7,5,3,5)
	postal_sign("01   FIRST CLASS",Vector3(0,10.4,5),10)
	label3("GLOVES OUT.  LIGHTS ON.",Vector3(0,9.6,5),0.006)
	landing(Vector3(0,3,-14),Vector2(18,30),"SPECIAL DELIVERY")
	for z in [10,12,14,16,18]:
		box(Vector3(0,3.02,z),Vector3(14,0.015,0.055),GOLD,false,false)
	# Staggered landing heights and side walls.
	deck(Vector3(-28,3,13),Vector3(18,0.7,14))
	panel(-33,8,4,3,7)
	panel(-23,8,4,3,7)
	postal_sign("02   AIR MAIL",Vector3(-28,12.5,4),10)
	box(Vector3(-28,4,-7),Vector3(4,8,2),INK,false)
	landing(Vector3(-35,4,-12),Vector2(8,10),"LEFT / 4m")
	landing(Vector3(-22,6,-17),Vector2(9,12),"HIGH / 6m")
	panel(-39,9,-17,3,7)
	# Ball-sized opening in a wall. The button latches instead of occupying a hand.
	deck(Vector3(28,3,13),Vector3(18,0.7,14))
	panel(24,7,5,3,5)
	panel(32,7,5,3,5)
	postal_sign("03   LETTER BOX",Vector3(28,10.5,5),10)
	var hole_y := 5.9
	box(Vector3(23,5,-9),Vector3(7,10,1),Color("a36f60"),false)
	box(Vector3(33,5,-9),Vector3(7,10,1),Color("a36f60"),false)
	box(Vector3(28,2.3,-9),Vector3(3,4.6,1),CREAM)
	box(Vector3(28,8.6,-9),Vector3(3,2.8,1),CREAM)
	# 1.1m opening admits the 0.64m ball but excludes the 1.8m standing body.
	gate = box(Vector3(28,hole_y,-9),Vector3(3,2.6,0.6),GOLD,false) as StaticBody3D
	gate.set_meta("gate",true)
	box(Vector3(28,4.58,-8.45),Vector3(3.4,0.12,0.25),INK,false,false)
	label3("LETTERS & RUBBER EMPLOYEES",Vector3(28,8,-8.45),0.007,INK)
	var button := box(Vector3(36,4.5,4),Vector3(1.2,1.2,0.5),GOLD,true)
	button.set_meta("button",true)
	label3("HIT TO OPEN",Vector3(36,5.5,4.3),0.008)
	landing(Vector3(28,3,-22),Vector2(15,28),"THROUGH THE WINDOW")
	# Free-play wall and platforms near the starting side of the lab.
	postal_sign("04   AFTER HOURS",Vector3(0,9,27),12)
	box(Vector3(-8,4,27),Vector3(7,8,1),MINT)
	box(Vector3(8,4,27),Vector3(7,8,1),MINT)
	for i in range(4):
		deck(Vector3(-13+i*8,1+i*1.4,43),Vector3(5,0.6,5))
	# Walkable stairs out of the lower recovery floor.
	for i in range(6):
		box(Vector3(-10,0.25*(i+1),22-i*0.75),Vector3(3,0.5*(i+1),0.8),CREAM)
	label3("1 — 4  /  JUMP TO A PRACTICE AREA",Vector3(0,1.7,23),0.010,INK)
	decorate_yard()
	build_movement_lab()

func postal_sign(title: String, pos: Vector3, width: float) -> void:
	box(pos,Vector3(width,1.1,0.22),INK,false,false)
	label3(title,pos+Vector3(0,0,0.13),0.011,CREAM)
	for x in [-width*0.45,width*0.45]:
		box(pos+Vector3(x,-0.9,0),Vector3(0.1,1.8,0.1),GOLD,false,false)

func decorate_yard() -> void:
	# Decorative parcels sit outside the launch lanes and use conservative box collisions.
	for pos in [Vector3(-8,3,17),Vector3(8,3,17),Vector3(-36,3,17),Vector3(36,3,17),Vector3(-44,0,-28),Vector3(43,0,-28)]:
		var parcel: Node3D = load("res://assets/parcel.glb").instantiate()
		add_child(parcel)
		parcel.position = pos
		parcel.rotation.y = pos.x*0.1
		var body := StaticBody3D.new()
		parcel.add_child(body)
		body.set_meta("grippy",true)
		var col := CollisionShape3D.new()
		var shape := BoxShape3D.new()
		shape.size = Vector3(1.2,1,0.9)
		col.shape = shape
		col.position.y = 0.5
		body.add_child(col)
	for x in range(-45,46,10):
		box(Vector3(x,2.2,-53),Vector3(0.24,4.4,0.24),GOLD,false,false)
		box(Vector3(x,4.2,-53),Vector3(5,0.45,0.45),CREAM,false,false)
	postal_sign("DON’T HIGH FIVE",Vector3(0,7,-53),23)
	# Oversized rounded sorting bins read as playful scenery at a distance.
	for x in [-44,44]:
		for z in [-35,-23,-11]:
			box(Vector3(x,2,z),Vector3(6,4,7),Color("8a7761"),false)
			box(Vector3(x,4.1,z),Vector3(6.3,0.35,7.3),GOLD,false,false)
			label3("POST",Vector3(x,2.6,z+3.55),0.012,INK)

func goto_station(i: int) -> void:
	if builder and builder.active:player.reset_to(builder.ORIGIN+builder.test_start);return
	if session and session.training.active:
		session.training.restart();return
	station = i
	player.reset_to(spawns[i])
	player.rotation.y = 0
	player.camera.rotation.x = 0
	player.last_setup.clear()
	message_time=0

func notify(text: String) -> void:
	message = text
	message_time = 4.0

func hit_button() -> void:
	if gate_open:
		return
	gate_open = true
	gate.collision_layer = 0
	gate.collision_mask = 0
	gate.hide()
	notify("Shutter open. Both hands are free for your launch.")
	sound("success")

func set_paused(value: bool) -> void:
	paused = value
	if value and session:
		session.watcher.firing=false;session.watcher.scope=false
	if not scripted_run: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE if value else Input.MOUSE_MODE_CAPTURED
	if is_instance_valid(hud):
		hud.menu.visible = value
		hud.start_button.text = "Resume" if started else "Arena"
		if value:
			player.clear_mouse_chord()
			if player.combat.active or player.combat.charging: player.cancel_hands()
			hud.show_page("Home")

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and is_instance_valid(hud):
		set_paused(true)

func _process(delta: float) -> void:
	if not test_world and is_instance_valid(player):
		environment.fog_density=base_fog_density()*(2.0/9.0 if session and session.watcher.active else (0.5 if session and session.training.active else 1.0))/player.vision_multiplier()
		environment.ambient_light_energy=visibility_fill*(1.15 if player.vision_multiplier()>1 else 1.0)*(0.0 if session and session.watcher.blackout>0 else 1.0)
	if controls.changed and world_hints.size()==2:
		world_hints[0].text="HOLD "+controls.prompt("cling")+"  /  WALL GRIP"
		world_hints[1].text="HOLD "+controls.prompt("reel")+" OR MMB  /  REEL TO YOUR GLOVES"
		controls.changed=false
	message_time = maxf(0,message_time-delta)
	if not paused:
		for target in targets:
			var p: Vector3 = target.pos
			var s: Vector2 = target.size
			if not target.hit and player.is_on_floor() and absf(player.position.y-p.y)<0.2 and absf(player.position.x-p.x)<s.x/2 and absf(player.position.z-p.z)<s.y/2:
				target.hit = true
				target.ring.material_override = mat(Color("edeee0"),0.3)
				notify("Clean landing. Try a different hand placement, or press R to repeat.")
				sound("success")

func build_audio() -> void:
	audio_service=load("res://scripts/audio_service.gd").new()
	audio_service.lab=self
	add_child(audio_service)

func sound(kind: String,pitch:=1.0) -> void:
	if is_instance_valid(audio_service): audio_service.play(kind,pitch)

func glow_box(pos: Vector3,size: Vector3,color: Color,energy:=1.0) -> Node3D:
	var item:=box(pos,size,color,false,false)
	item.get_child(0).material_override=mat(color,energy)
	return item

func build_movement_lab() -> void:
	# A shaded landing alcove makes glove placement change what the player can see.
	box(Vector3(-40,8.5,-12),Vector3(0.5,9,12),Color("202337"),true)
	box(Vector3(-30,8.5,-12),Vector3(0.5,9,12),Color("202337"),true)
	box(Vector3(-35,13,-12),Vector3(10,0.5,12),Color("202337"),true)
	box(Vector3(-35,8.5,-18),Vector3(10,9,0.5),Color("202337"),true)
	label3("SEND A LIGHT AHEAD",Vector3(-35,13.6,-6),0.009,Color("9ad9da"))
	# Distinct optional toys: purple bounce pads, a climb wall and overhead hand anchors.
	for pos in [Vector3(-20,0.16,34),Vector3(20,0.16,34),Vector3(0,0.16,-40)]:
		var pad:=box(pos,Vector3(5,0.3,5),Color("653a83"),true)
		pad.set_meta("bounce",true)
		for x in [-2.2,2.2]: glow_box(pos+Vector3(x,0.17,0),Vector3(0.10,0.05,4.6),Color("d789ef"),2)
		label3("BOING",pos+Vector3(0,0.7,-2),0.009,Color("d789ef"))
	box(Vector3(17,6,42),Vector3(1,12,13),Color("333858"),true)
	glow_box(Vector3(16.45,6,42),Vector3(0.08,11.5,0.2),Color("8ca4ff"),1.3)
	deck(Vector3(21,10,42),Vector3(7,0.7,8))
	panel(0,17,27,7,2)
	panel(-17,13,33,4,3)
	world_hints.append(label3("",Vector3(13,13,39),0.008,Color("b9b6e3")))
	world_hints.append(label3("",Vector3(0,19,27),0.009,Color("83d9d3")))
	# Alternating platforms are a controlled double-jump and air-steering test.
	for i in 4:
		deck(Vector3(-30+i*4,1.3+i*1.3,43-i*3),Vector3(2.5,0.5,2.5))

func set_visibility(value: float) -> void:
	visibility_fill=value
	environment.ambient_light_energy=value

func base_fog_density() -> float:return 2.302585/fog_distance
func set_fog_distance(value:float) -> void:
	fog_distance=clampf(value,50,250) if is_finite(value) else 100.0
