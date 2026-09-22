extends RefCounted
## Infill occupies previously empty bays, not the reserved ramps or pad trajectories.
const MAZE_WINDOWS:Array[Rect2]=[Rect2(-12,0,7,5),Rect2(4,2,8,5)]
const CONCOURSE_DOORS:Array[Rect2]=[Rect2(-8,0,6,5),Rect2(3,3,6,4)]
const LOOP_DOORS:Array[Rect2]=[Rect2(-11,0,5,4.5),Rect2(6,0,5,4.5)]
const TERRACE_DOOR:Array[Rect2]=[Rect2(-3,0,6,3.8)]
const TERRACE_PASSAGES:Array[Rect2]=[Rect2(-14,0,6,4.5),Rect2(-3,0,6,4.5),Rect2(8,0,6,4.5)]
const BAY_WINDOWS:Array[Rect2]=[Rect2(-8,1,6,4),Rect2(2,0,6,5)]
var routes:Array[Dictionary]=[]
var perches:Array[Vector3]=[]
var first_shape:=0
var last_shape:=0

func build(a:Node3D) -> void:
	first_shape=a.solid.get_child_count()
	for x in [-112,112]:
		for z in [-65,65]:
			covered_loop(a,Vector3(x,0,z),a.AMBER if x<0 else a.PINK)
	# Upper corridor bays provide open routes below the hanging ribbons.
	for spec in [[Vector3(-68,20,-68),a.CYAN,239],[Vector3(32,20,32),a.PINK,751]]:
		var origin:Vector3=spec[0];var color:Color=spec[1]
		a.corridor_bay(origin,33,color)
		a.light_pool(origin+Vector3(16.5,7,16.5),color,10)
		# Broad overhead ribbons make the maze walls useful take-off/landing surfaces.
		for z in [5.5,27.5]:
			var pos:=origin+Vector3(16.5,9,z)
			a.platform(pos,Vector2(33,4),color);perches.append(pos)
		a.ramp(origin+Vector3(-3,0,1),origin+Vector3(-3,9,31),4,color)
		a.platform(origin+Vector3(0,9,29),Vector2(9,7),color)
		a.window_wall(origin+Vector3(16.5,9,16.5),29,9,MAZE_WINDOWS,color)
		a.platform(origin+Vector3(8,11,18.5),Vector2(9,5),color)
		a.bounce(origin+Vector3(16.5,0.14,-4),2,21,color)
	# The opposing upper corners use terraces rather than another copy of the maze.
	terraces(a,Vector3(-51,20,51),a.LIME)
	terraces(a,Vector3(51,20,-51),a.BLUE)
	# Hanging bridges occupy parts of the tall annex voids, leaving a clear central shaft.
	bridge_bay(a,Vector3(-119,20,23),a.AMBER)
	bridge_bay(a,Vector3(122,20,-15),a.PINK)
	# End concourses become alternating alcoves, roofs and wide slalom openings.
	for x in [-100,-66,52,88]:
		for side in [-1,1]:
			# Keep the red field's northern approach open.
			var c:Color=a.BLUE if side<0 else a.LIME
			var base:=Vector3(x,20,side*106)
			a.window_wall(base,24,10,CONCOURSE_DOORS,c)
			a.platform(base+Vector3(0,6,side*4),Vector2(17,6),c)
			a.wall(base+Vector3(-10,3.5,side*5),Vector3(0.7,7,10),c)
			perches.append(base+Vector3(0,6,side*4))
			routes.append({"from":base+Vector3(-5,0.05,-6),"to":base+Vector3(-5,0.05,6),"name":"concourse doorway"})
	last_shape=a.solid.get_child_count()

func covered_loop(a:Node3D,base:Vector3,color:Color) -> void:
	# Four generous doors, an offset S bend, two roof strips and a climbable canopy.
	for z in [-9,9]:
		a.window_wall(base+Vector3(0,0,z),28,6,LOOP_DOORS,color)
	for side in [-1,1]:
		a.wall(base+Vector3(side*14,3,0),Vector3(0.7,6,18),color)
		a.platform(base+Vector3(side*10,6.7,0),Vector2(8,19),color)
		a.wall(base+Vector3(side*4,1.8,side*3),Vector3(11,3.6,0.65),color)
	a.platform(base+Vector3(0,10.5,0),Vector2(11,5),color)
	a.ramp(base+Vector3(-18,0,10),base+Vector3(-18,6.7,-8),4,color)
	a.platform(base+Vector3(-14,6.7,-7),Vector2(9,5),color)
	a.hoop(base+Vector3(0,14,-5),2.6,color)
	a.light_pool(base+Vector3(0,4.8,0),color,7)
	for x in [-8.5,8.5]:
		# The outside vestibule remains unobstructed; the inside requires a turn.
		routes.append({"from":base+Vector3(x,0.05,-12),"to":base+Vector3(x,0.05,-5),"name":"covered-loop entrance"})
	perches.append(base+Vector3(0,10.5,0))

func terraces(a:Node3D,base:Vector3,color:Color) -> void:
	a.light_pool(base+Vector3(2,10,3),color,12)
	for i in 3:
		var pos:=base+Vector3(-10+i*10,4+i*4,-8+i*8)
		a.platform(pos,Vector2(12,13),color)
		for x in [-5,5]: a.wall(pos+Vector3(x,-2,0),Vector3(0.6,4,10),color)
		perches.append(pos)
		a.window_wall(pos+Vector3(0,0,-5),11,5.5,TERRACE_DOOR,color)
	# Sheltered lower crossing, with a roof opening between the rising decks.
	a.window_wall(base+Vector3(0,0,0),34,6,TERRACE_PASSAGES,color)
	a.ramp(base+Vector3(-17,0,12),base+Vector3(-17,4,-9),4,color)
	a.platform(base+Vector3(-13,4,-8),Vector2(10,7),color)
	a.bounce(base+Vector3(13,0.14,-12),2,22,color)
	routes.append({"from":base+Vector3(0,0.05,-4),"to":base+Vector3(0,0.05,4),"name":"terrace underpass"})

func bridge_bay(a:Node3D,base:Vector3,color:Color) -> void:
	a.light_pool(base+Vector3(0,11,3),color,14)
	# Connection to both edges of each existing second-floor hole; no floor seals the void.
	for x in [-13,13]:
		a.platform(base+Vector3(x,6,0),Vector2(6,40),color)
		for z in [-16,16]:
			a.block(base+Vector3(x,16,z),Vector3(0.45,12,0.45),a.WALL)
			a.stripe(base+Vector3(x,16,z+0.25),Vector3(0.12,11,0.04),color)
	for z in [-16,16]: a.platform(base+Vector3(0,6,z),Vector2(32,6),color)
	a.platform(base+Vector3(-2,12,-5),Vector2(13,8),color)
	a.window_wall(base+Vector3(-2,6,-9),22,10,BAY_WINDOWS,color)
	# Long ramps from the existing floor outside the void, safely above pad flights.
	a.ramp(base+Vector3(-13,0,30 if base.x<0 else 38),base+Vector3(-13,6,16),5,color)
	perches.append(base+Vector3(-2,12,-5))
