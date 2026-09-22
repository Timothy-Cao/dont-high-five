extends Node3D
## Authored macro layout, seeded looping mazes, shared instanced architecture.
const CYAN:=Color("57d5cf")
const PINK:=Color("db75c3")
const AMBER:=Color("edae68")
const LIME:=Color("aed478")
const BLUE:=Color("8199ec")
const WALL:=Color("283b46")
const FLOOR:=Color("202a3c")
var lab: Node3D
var equipment_bay: Node3D
var rave: Node3D
var districts: RefCounted
var travel: Node3D
var powerups:Node3D
var dummies:Array[Node3D]=[]
var batches: Dictionary={}
var solid: StaticBody3D
var pads: Array[Dictionary]=[]
var openings: Array[Dictionary]=[]
var pockets: Array[Transform3D]=[]
var maze_graphs: Array[Dictionary]=[]
var previous_body:=Vector3.ZERO
var cube:=BoxMesh.new()
var shapes:=0
var ring_meshes: Dictionary={}

func material(color: Color,glow: float) -> Material:
	if glow==0:
		var carpet:=ShaderMaterial.new()
		carpet.shader=load("res://shaders/carpet.gdshader")
		if color!=FLOOR:carpet.set_shader_parameter("base_color",color)
		return carpet
	var m:=StandardMaterial3D.new()
	m.metallic=0.08
	m.albedo_color=color
	m.roughness=0.68
	if glow>0:
		m.emission_enabled=true
		m.emission=color
		m.emission_energy_multiplier=glow
	return m

func instance(mesh: Mesh,xf: Transform3D,color: Color,glow:=0.0) -> void:
	var key:=str(mesh.get_instance_id())+color.to_html()+str(glow)
	if not batches.has(key): batches[key]={"mesh":mesh,"color":color,"glow":glow,"transforms":[]}
	batches[key].transforms.append(xf)

func block(pos: Vector3,size: Vector3,color:=WALL,collision:=true,basis:=Basis.IDENTITY,glow:=0.0) -> void:
	instance(cube,Transform3D(basis.scaled_local(size),pos),color,glow)
	if collision:
		var c:=CollisionShape3D.new()
		var shape:=BoxShape3D.new()
		shape.size=size
		c.shape=shape
		solid.add_child(c)
		c.transform=Transform3D(basis,pos)
		shapes+=1

func stripe(pos: Vector3,size: Vector3,color: Color,basis:=Basis.IDENTITY) -> void:
	block(pos,size,color,false,basis,0.85)

func platform(pos: Vector3,size: Vector2,color: Color,support:=false) -> void:
	block(pos-Vector3.UP*0.35,Vector3(size.x,0.7,size.y),FLOOR)
	for x in [-size.x/2+0.08,size.x/2-0.08]:
		stripe(pos+Vector3(x,0.025,0),Vector3(0.10,0.045,size.y),color)
	for z in [-size.y/2+0.08,size.y/2-0.08]:
		stripe(pos+Vector3(0,0.025,z),Vector3(size.x,0.045,0.10),color)
	if support and pos.y>1:
		for x in [-size.x/2+0.7,size.x/2-0.7]:
			block(Vector3(pos.x+x,pos.y/2,pos.z),Vector3(0.55,pos.y,0.55),WALL)

func wall(pos: Vector3,size: Vector3,color: Color) -> void:
	block(pos,size,WALL)
	stripe(pos+Vector3(0,size.y/2+0.015,0),Vector3(size.x+0.025,0.05,size.z+0.025),color)
	# Two faces share a muted lower bumper and a thin luminous cap.
	if size.x>size.z:
		for z in [-size.z/2-0.02,size.z/2+0.02]:
			stripe(pos+Vector3(0,-size.y/2+0.32,z),Vector3(size.x,0.065,0.035),color)
	else:
		for x in [-size.x/2-0.02,size.x/2+0.02]:
			stripe(pos+Vector3(x,-size.y/2+0.32,0),Vector3(0.035,0.065,size.z),color)

func rim(pos: Vector3,radius: float,color: Color,vertical:=false) -> void:
	var key:=str(radius)
	if not ring_meshes.has(key):
		var mesh:=TorusMesh.new()
		mesh.inner_radius=radius-0.06
		mesh.outer_radius=radius+0.06
		mesh.rings=48
		mesh.ring_segments=8
		ring_meshes[key]=mesh
	var basis:=Basis(Vector3.RIGHT,PI/2) if vertical else Basis.IDENTITY
	instance(ring_meshes[key],Transform3D(basis,pos),color,1.3)

func bounce(pos: Vector3,radius: float,power: float,color:=PINK) -> void:
	var body:=StaticBody3D.new()
	add_child(body)
	body.position=pos
	body.set_meta("grippy",true)
	body.set_meta("bounce",true)
	body.set_meta("bounce_speed",power)
	var shape:=CylinderShape3D.new()
	shape.radius=radius
	shape.height=0.25
	var col:=CollisionShape3D.new()
	col.shape=shape
	body.add_child(col)
	var mesh:=CylinderMesh.new()
	mesh.top_radius=radius
	mesh.bottom_radius=radius
	mesh.height=0.25
	mesh.radial_segments=40
	instance(mesh,Transform3D(Basis.IDENTITY,pos),Color("493559"))
	rim(pos+Vector3.UP*0.135,radius-0.15,color)
	rim(pos+Vector3.UP*0.14,radius*0.55,color)
	stripe(pos+Vector3.UP*0.145,Vector3(radius*0.65,0.02,0.09),color)
	stripe(pos+Vector3.UP*0.145,Vector3(0.09,0.02,radius*0.65),color)
	pads.append({"pos":pos,"radius":radius,"power":power,"body":body})

func ramp(a: Vector3,b: Vector3,width: float,color: Color) -> void:
	var basis:=Basis.looking_at((b-a).normalized(),Vector3.UP)
	var center:=(a+b)*0.5
	block(center-basis.y*0.25,Vector3(width,0.5,a.distance_to(b)+0.25),FLOOR,true,basis)
	for x in [-width/2+0.08,width/2-0.08]:
		stripe(center+basis.x*x+basis.y*0.035,Vector3(0.10,0.04,a.distance_to(b)),color,basis)

func window_wall(pos: Vector3,width: float,height: float,holes: Array[Rect2],color: Color,yaw:=0.0) -> void:
	var xs: Array[float]=[-width/2,width/2]
	var ys: Array[float]=[0,height]
	for hole in holes:
		xs.append(hole.position.x);xs.append(hole.end.x)
		ys.append(hole.position.y);ys.append(hole.end.y)
	xs.sort();ys.sort()
	var basis:=Basis(Vector3.UP,yaw)
	for ix in xs.size()-1:
		for iy in ys.size()-1:
			var size:=Vector2(xs[ix+1]-xs[ix],ys[iy+1]-ys[iy])
			if size.x<0.01 or size.y<0.01: continue
			var mid:=Vector2(xs[ix],ys[iy])+size/2
			var empty:=false
			for hole in holes:
				if hole.has_point(mid): empty=true
			if not empty: block(pos+basis*Vector3(mid.x,mid.y,0),Vector3(size.x,size.y,0.8),WALL,true,basis)
	for hole in holes:
		var center:=hole.get_center()
		for z in [-0.43,0.43]:
			for x in [hole.position.x,hole.end.x]:
				stripe(pos+basis*Vector3(x,center.y,z),Vector3(0.11,hole.size.y,0.055),color,basis)
			for y in [hole.position.y,hole.end.y]:
				stripe(pos+basis*Vector3(center.x,y,z),Vector3(hole.size.x,0.11,0.055),color,basis)
		openings.append({"pos":pos+basis*Vector3(center.x,center.y,0),"size":hole.size,"basis":basis})

func light_pool(pos: Vector3,color: Color,range_m:=22.0) -> void:
	var light:=OmniLight3D.new()
	add_child(light)
	light.position=pos
	light.light_color=color
	light.light_energy=3.0
	light.omni_range=range_m+12
	light.omni_attenuation=1.1
	light.light_cull_mask=1
	light.shadow_enabled=false
	rim(pos,1.5,color)

func build() -> void:
	cube.size=Vector3.ONE
	solid=StaticBody3D.new()
	add_child(solid)
	solid.set_meta("grippy",true)
	# A continuous safety floor and enclosing building; no reset volumes in the routes.
	block(Vector3(0,-0.5,0),Vector3(304,1,240),FLOOR)
	block(Vector3(0,44,0),Vector3(304,1,240),Color("121725"))
	for side in [-1,1]:
		wall(Vector3(side*152,22,0),Vector3(1,44,240),BLUE)
		wall(Vector3(0,22,side*120),Vector3(304,44,1),BLUE)
	for x in [-72,-24,24,72]:
		for z in [-72,-24,24,72]:
			block(Vector3(x,22,z),Vector3(1.5,44,1.5),WALL)
			stripe(Vector3(x+0.77,22,z),Vector3(0.04,39,0.12),BLUE)
	for z in [-64,-32,0,32,64]:
		block(Vector3(0,33.8,z),Vector3(150,0.8,0.5),WALL)
		stripe(Vector3(0,33.35,z),Vector3(124,0.06,0.06),BLUE)
	build_atrium()
	build_west()
	build_east()
	build_north()
	build_south()
	build_details()
	build_hideaways()
	travel=load("res://scripts/travel.gd").new();travel.lab=lab;add_child(travel)
	load("res://scripts/world/annex.gd").new().build(self,travel)
	# One labyrinth. Other districts use broad, open-ended corridor bays.
	maze(Vector3(-69,0,-69),7,7,5.5,CYAN,971,true)
	corridor_bay(Vector3(30,0,-69),38.5,BLUE)
	corridor_bay(Vector3(-69,0,30),38.5,LIME)
	corridor_bay(Vector3(30,0,30),38.5,PINK)
	corridor_bay(Vector3(-69,8.5,-69),38.5,CYAN)
	corridor_bay(Vector3(30,8.5,30),38.5,PINK)
	# Sloped entrances and upper exits make the second layer traversable without a reset.
	ramp(Vector3(-72,0,-24),Vector3(-72,8.5,-47),3.4,CYAN)
	platform(Vector3(-69,8.5,-47),Vector2(6,5.5),CYAN)
	ramp(Vector3(72,0,24),Vector3(72,8.5,47),3.4,PINK)
	platform(Vector3(69,8.5,47),Vector2(6,5.5),PINK)
	platform(Vector3(-28,8.5,-49),Vector2(7,5),CYAN)
	platform(Vector3(28,8.5,49),Vector2(7,5),PINK)
	for pos in [Vector3(0,27,0),Vector3(-49,23,0),Vector3(49,20,0),Vector3(0,25,-49),Vector3(0,13,49),Vector3(-49,15,-49),Vector3(49,14,49),Vector3(49,10,-49),Vector3(-49,10,49)]:
		light_pool(pos,[CYAN,BLUE,PINK][int(absf(pos.x+pos.z))%3])
	load("res://scripts/world/upper_floor.gd").new().build(self)
	equipment_bay=load("res://scripts/world/equipment_bay.gd").new();add_child(equipment_bay);equipment_bay.build(self)
	districts=load("res://scripts/world/districts.gd").new();districts.build(self)
	flush_batches()
	load("res://scripts/world/arena_identity.gd").new().build(self)
	rave=load("res://scripts/world/rave.gd").new();rave.lab=lab;add_child(rave)
	powerups=load("res://scripts/powerups.gd").new();powerups.lab=lab;add_child(powerups)
	for pos in [Vector3(-4,0,17),Vector3(14,0,19),Vector3(39,20,14),Vector3(-108,0,-25),Vector3(115,20,33),Vector3(21,20,88)]:
		var dummy=load("res://scripts/target_dummy.gd").new();dummy.lab=lab;dummy.position=pos;add_child(dummy);dummy.rotation.y=PI;dummies.append(dummy)

func build_atrium() -> void:
	# Two differently oriented bridges cross without forming a flat ceiling.
	platform(Vector3(0,8.5,11),Vector2(49,6),CYAN)
	platform(Vector3(8,16,-3),Vector2(5,53),AMBER)
	platform(Vector3(-12,23,-13),Vector2(13,10),BLUE)
	for x in [-22,22]:
		block(Vector3(x,4.1,11),Vector3(1.2,8.2,5.5),WALL)
	for z in [-26,22]:
		block(Vector3(8,7.6,z),Vector3(4.5,15.2,1),WALL)
	for y in [8,16,25]: rim(Vector3(0,y,0),4.2,CYAN if y!=16 else PINK)
	# Hanging ribs double as reachable grapple surfaces and a recognizable landmark.
	for x in [-4.5,4.5]:
		block(Vector3(x,22,0),Vector3(0.65,19,0.65),Color("304657"))
		stripe(Vector3(x,22,0.34),Vector3(0.12,18,0.04),CYAN)
	bounce(Vector3(-9,0.14,3),2.6,23)
	bounce(Vector3(13,0.14,-12),2.5,26)
	bounce(Vector3(-17,8.65,11),1.8,22)
	ramp(Vector3(-20,0,29),Vector3(-20,8.5,9),3.8,CYAN)
	window_wall(Vector3(-23,0,0),38,19,[Rect2(-16,0,6,4),Rect2(-5,7,10,6),Rect2(11,0,6,4)],AMBER,PI/2)
	window_wall(Vector3(23,0,0),38,22,[Rect2(-16,0,6,5),Rect2(-4,9,8,5),Rect2(11,0,6,4)],PINK,PI/2)
	window_wall(Vector3(0,0,-25),44,24,[Rect2(-18,0,7,5),Rect2(-5,5,10,8),Rect2(5,15,7,5)],BLUE)

func build_west() -> void:
	# A tall shaft with a staggered stack of shelves, several ways up, and open sides.
	for i in 5:
		var y:=3.5+i*4.5
		var x:=-58.0 if i%2==0 else -39.0
		var z:=-12.0+i*6
		platform(Vector3(x,y,z),Vector2(11,9),AMBER,true)
		bounce(Vector3(x,y+0.14,z),1.7,20.5)
	wall(Vector3(-68,14,0),Vector3(1.2,28,40),AMBER)
	window_wall(Vector3(-48,0,-23),42,27,[Rect2(-17,0,7,5),Rect2(-5,9,10,5),Rect2(10,19,8,4)],AMBER)
	platform(Vector3(-48,26,-19),Vector2(18,6),AMBER)
	bounce(Vector3(-48,0.14,3),3.5,25)
	for z in [-15,0,15]:
		stripe(Vector3(-67.36,14,z),Vector3(0.045,25,0.18),AMBER)

func build_east() -> void:
	# A large room of offset walkways and airborne window shortcuts.
	for i in 4:
		var z:=-17.0+i*11
		var y:=4.0+i*3.4
		platform(Vector3(49,y,z),Vector2(29 if i%2==0 else 20,5),PINK,true)
	ramp(Vector3(67,0,-24),Vector3(67,8.5,-47),3.8,BLUE)
	platform(Vector3(62,8.5,-47),Vector2(10,6),BLUE)
	window_wall(Vector3(49,0,-4),39,18,[Rect2(-16,0,6,4),Rect2(-5,5.2,10,3.8),Rect2(12,11,5,3)],PINK)
	window_wall(Vector3(49,0,23),39,24,[Rect2(-17,0,7,5),Rect2(-4,12.5,8,2.0),Rect2(10,17,7,4)],PINK)
	bounce(Vector3(58,0.14,9),2.8,24)
	bounce(Vector3(32,0.14,-15),2.4,19)
	platform(Vector3(49,21,27),Vector2(24,5),PINK)

func build_north() -> void:
	# High galleries circle a void. Low doors and high windows reveal other layers.
	platform(Vector3(0,8.5,-48),Vector2(43,5),BLUE)
	platform(Vector3(-17,16,-49),Vector2(6,42),BLUE,true)
	platform(Vector3(18,22,-48),Vector2(6,42),BLUE,true)
	platform(Vector3(0,16,-68),Vector2(39,6),BLUE)
	for z in [-38,-59]:
		window_wall(Vector3(0,0,z),44,28,[Rect2(-17,0,6,4.5),Rect2(-4,7,8,5),Rect2(-20,15.8,6,4.5),Rect2(15,21.8,6,4.2)],BLUE)
	bounce(Vector3(-8,0.14,-48),2.8,24)
	bounce(Vector3(10,8.65,-48),1.8,24)
	ramp(Vector3(-24,0,-70),Vector3(-4,8.5,-70),4,BLUE)
	platform(Vector3(0,8.5,-70),Vector2(8,5),BLUE)

func build_south() -> void:
	# A low, sheltered warren opens unexpectedly into the atrium overhead.
	for z in [38,51,64]:
		window_wall(Vector3(0,0,z),43,7,[Rect2(-17,0,5,3.5),Rect2(-3,0,6,3),Rect2(12,3.2,5,1.75)],LIME)
		platform(Vector3(0,7.2,z),Vector2(43,4),LIME,true)
		platform(Vector3(14.5,3.2,z+2.5),Vector2(7,5),LIME)
	for x in [-13,12]:
		wall(Vector3(x,2,44.5),Vector3(0.7,4,8),LIME)
		wall(Vector3(-x,2,58),Vector3(0.7,4,7),LIME)
	platform(Vector3(-8,5,44),Vector2(11,9),LIME)
	platform(Vector3(9,5,58),Vector2(11,9),LIME)
	ramp(Vector3(-23,0,68),Vector3(-23,7.2,49),4,LIME)
	platform(Vector3(-23,7.2,43),Vector2(4,12),LIME)
	bounce(Vector3(7,0.14,43),2.2,18)
	bounce(Vector3(-7,0.14,58),2.2,18)

func hideaway(pos: Vector3,color: Color,yaw:=0.0) -> void:
	# Offset standing entrance, sheltered corner, and a second low escape slot.
	# Each roof is another usable landing; none closes off a main circulation route.
	var b:=Basis(Vector3.UP,yaw)
	pockets.append(Transform3D(b,pos))
	var size:=Vector2(5.8,8.6) if absf(b.x.z)>0.5 else Vector2(8.6,5.8)
	platform(pos,size,color)
	platform(pos+Vector3.UP*3.95,size,color)
	window_wall(pos+b*Vector3(0,0,2.5),8,3.25,[Rect2(-3.25,0,2.5,2.6)],color,yaw)
	window_wall(pos+b*Vector3(4,0,0),5,3.25,[Rect2(-1,0,2,1.75)],color,yaw+PI/2)
	block(pos+b*Vector3(-4,1.625,0),Vector3(0.6,3.25,5),WALL,true,b)
	block(pos+b*Vector3(0,1.625,-2.5),Vector3(8,3.25,0.6),WALL,true,b)
	for x in [-3,3]:
		block(pos+b*Vector3(x,-0.9,-1.7),Vector3(0.3,1.8,2.9),WALL,true,b)
	stripe(pos+b*Vector3(1,0.35,-2.18),Vector3(4,0.06,0.04),color,b)
	stripe(pos+b*Vector3(3.68,0.30,0),Vector3(0.04,0.06,1.8),color,b)

func build_hideaways() -> void:
	# Sparse refuges on the edges of the high-speed rooms, at different heights.
	hideaway(Vector3(-16,10,-22),BLUE)
	hideaway(Vector3(-64.5,12,14),AMBER,PI/2)
	hideaway(Vector3(64,10,18),PINK,PI)
	# A sheltered cross-passage at the back of the low tunnels: two full-height
	# exits, a central crouch shortcut, and low hurdles with room for a normal hop.
	window_wall(Vector3(0,0,68.8),18,3.6,[Rect2(-8.5,0,3,3.2),Rect2(-1,0,2,1.75),Rect2(5.5,0,3,3.2)],LIME)
	wall(Vector3(0,1.8,74),Vector3(18,3.6,0.6),LIME)
	platform(Vector3(0,4.3,71.4),Vector2(18.6,5.8),LIME)
	for x in [-3,3]:
		wall(Vector3(x,0.275,71.4),Vector3(0.45,0.55,4.8),LIME)

func hoop(pos: Vector3,radius: float,color: Color) -> void:
	for i in 12:
		var basis:=Basis(Vector3.FORWARD,TAU*i/12)
		var center:=pos+basis*Vector3(0,radius,0)
		block(center,Vector3(radius*0.54,0.5,0.8),Color("374255"),true,basis)
		stripe(center+Vector3(0,0,0.43),Vector3(radius*0.54,0.085,0.06),color,basis)
		stripe(center-Vector3(0,0,0.43),Vector3(radius*0.54,0.085,0.06),color,basis)

func build_details() -> void:
	hoop(Vector3(0,9,-25),3.35,BLUE)
	hoop(Vector3(-48,11.5,-23),2.12,AMBER)
	hoop(Vector3(49,7.1,-4),1.5,PINK)
	# Small low fixtures wash the floor; high hall lights alone miss enclosed corridors.
	for x in [-65,-32,32,65]:
		for z in [-65,-32,32,65]:
			var c:=CYAN if x<0 else PINK
			var light:=OmniLight3D.new()
			add_child(light)
			light.position=Vector3(x,5.8,z)
			light.light_color=c
			light.light_energy=1.3
			light.omni_range=15
			light.light_cull_mask=1
			stripe(light.position,Vector3(0.6,0.14,0.6),c)
	# UV-reactive wall marks are abstract shapes, never instructions or targets.
	for side in [-1,1]:
		for z in range(-65,66,13):
			for j in 3:
				var b:=Basis(Vector3.RIGHT,-0.35)
				stripe(Vector3(side*75.43,3.0+j*0.7,z+j*0.8),Vector3(0.045,0.2,2.3),BLUE,b)
	# A forest of rounded padded columns breaks the rectilinear silhouette in the south.
	for p in [Vector3(-19,0,29),Vector3(-11,0,30),Vector3(12,0,28),Vector3(20,0,31)]:
		var mesh:=CylinderMesh.new()
		mesh.top_radius=0.75;mesh.bottom_radius=0.75;mesh.height=5
		instance(mesh,Transform3D(Basis.IDENTITY,p+Vector3.UP*2.5),Color("384442"))
		var c:=CollisionShape3D.new()
		var shape:=CylinderShape3D.new()
		shape.radius=0.75;shape.height=5
		c.shape=shape;solid.add_child(c);c.position=p+Vector3.UP*2.5
		for y in [0.2,2.5,4.8]: rim(p+Vector3.UP*y,0.77,LIME)

func maze(origin: Vector3,nx: int,nz: int,cell: float,color: Color,seed_value: int,roof: bool,upper:=false) -> void:
	var rng:=RandomNumberGenerator.new();rng.seed=seed_value
	var links: Dictionary={}
	var visited: Dictionary={Vector2i.ZERO:true}
	var stack: Array[Vector2i]=[Vector2i.ZERO]
	var dirs: Array[Vector2i]=[Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT,Vector2i.UP]
	while not stack.is_empty():
		var cur:Vector2i=stack.back()
		var choices: Array[Vector2i]=[]
		for d in dirs:
			var next:=cur+d
			if next.x>=0 and next.x<nx and next.y>=0 and next.y<nz and not visited.has(next): choices.append(next)
		if choices.is_empty(): stack.pop_back();continue
		var next:=choices[rng.randi_range(0,choices.size()-1)]
		links[str(cur)+str(next)]=true;links[str(next)+str(cur)]=true
		visited[next]=true;stack.append(next)
	# Extra cross-links deliberately remove tree-maze dead-end fatigue.
	for x in nx:
		for z in nz:
			var cur:=Vector2i(x,z)
			for d in [Vector2i.RIGHT,Vector2i.DOWN]:
				var next:Vector2i=cur+d
				if next.x<nx and next.y<nz and rng.randf()<0.24:
					links[str(cur)+str(next)]=true;links[str(next)+str(cur)]=true
	maze_graphs.append({"origin":origin,"nx":nx,"nz":nz,"cell":cell,"links":links})
	for x in nx:
		for z in nz:
			var cur:=Vector2i(x,z)
			var center:=origin+Vector3((x+0.5)*cell,0,(z+0.5)*cell)
			var shaft:=cur in [Vector2i(2,2),Vector2i(5,4)]
			if roof and not shaft: platform(center+Vector3.UP*8.5,Vector2(cell,cell),color)
			if roof and shaft: bounce(center+Vector3.UP*0.14,1.8,22,color)
			for d in [Vector2i.RIGHT,Vector2i.DOWN]:
				var next:Vector2i=cur+d
				if next.x>=nx or next.y>=nz: continue
				if not links.has(str(cur)+str(next)):
					var size:=Vector3(0.6,4.8,cell) if d==Vector2i.RIGHT else Vector3(cell,4.8,0.6)
					wall(center+Vector3(d.x*cell/2,2.4,d.y*cell/2),size,color)
			if not upper and not roof and (x*3+z)%11==0:
				platform(center+Vector3.UP*5.6,Vector2(cell,cell),color)
			# Sparse glowing floor marks, not a pervasive checkerboard.
			if (x+z)%3==0: stripe(center+Vector3.UP*0.018,Vector3(0.65,0.025,0.10),color)
	if upper:
		for cur in [Vector2i(2,2),Vector2i(5,4)]:
			var p:=origin+Vector3((cur.x+0.5)*cell,0,(cur.y+0.5)*cell)
			rim(p+Vector3.UP*0.03,2.1,color)

func flush_batches() -> void:
	for data in batches.values():
		var node:=MultiMeshInstance3D.new()
		var mm:=MultiMesh.new()
		mm.transform_format=MultiMesh.TRANSFORM_3D
		mm.mesh=data.mesh
		mm.instance_count=data.transforms.size()
		for i in mm.instance_count: mm.set_instance_transform(i,data.transforms[i])
		node.multimesh=mm
		node.material_override=material(data.color,data.glow)
		if data.glow>0: node.cast_shadow=GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		add_child(node)

func _physics_process(dt: float) -> void:
	if not is_instance_valid(lab.player) or lab.paused: return
	if lab.session and (lab.session.training.active or lab.session.watcher.active):return
	var body:Vector3=lab.player.position+Vector3.UP*(0.32 if lab.player.ball else 0.95)
	if previous_body.distance_to(body)>5: previous_body=body
	powerups.collect(previous_body,body)
	previous_body=body

func corridor_bay(origin:Vector3,width:float,color:Color) -> void:
	# Two long walls, wide end bypasses, two through-windows, walkable canopy strips.
	# No recursive passages: players can read the next two turns from entry.
	for fraction in [0.30,0.70]:
		var center:=origin+Vector3(width/2,0,width*fraction)
		window_wall(center,width-10,5.5,[Rect2(-3,0,6,4)],color)
		platform(center+Vector3(0,5.5,0),Vector2(width-10,2.5),color)
	for side in [-1,1]:
		var x:float=width*0.5+side*(width*0.5-2)
		wall(origin+Vector3(x,2.75,width/2),Vector3(1.1,5.5,width*0.35),color)
	# Offset overhead visor provides a hideout without closing the corridor below.
	platform(origin+Vector3(width*0.5,8,width*0.5),Vector2(9,6),color)
