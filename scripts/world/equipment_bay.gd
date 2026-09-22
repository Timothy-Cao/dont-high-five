extends Node3D
## Covered equipment bay. Disablement fields are parked until objective playtests.
const CENTER := Vector3(112,20,-82)
const BOUNDS := AABB(Vector3(101,20,-91),Vector3(22,12,18))
var arena: Node3D

func build(a: Node3D) -> void:
	arena=a
	var red:=Color("65b8c0")
	var doors:Array[Rect2]=[Rect2(-3,0,6,5)]
	for x in [-11,11]: a.wall(CENTER+Vector3(x,6,0),Vector3(0.6,12,18.6),red)
	for z in [-9,9]:
		a.window_wall(CENTER+Vector3(0,0,z),22,12,doors,red)
		for x in [-3.1,3.1]: a.stripe(CENTER+Vector3(x,2.5,z),Vector3(0.12,5,0.12),red)
	a.block(CENTER+Vector3(0,12,0),Vector3(22.6,0.5,18.6),a.WALL)
	for z in [-7,7]: a.stripe(CENTER+Vector3(0,0.04,z),Vector3(19,0.04,0.12),red)
	a.light_pool(CENTER+Vector3(0,8,0),red,15)
	# Sparse padded cover, with a straight, walkable path between two exits.
	for x in [-7,7]: a.wall(CENTER+Vector3(x,1.3,0),Vector3(3,2.6,6),red)
