extends RefCounted
var holes:Array[Rect2]=[
	Rect2(-27,-29,54,60),Rect2(-69,-26,42,52),Rect2(28,-27,42,56),Rect2(-24,-73,48,47),
	Rect2(-140,-5,42,57),Rect2(98,-42,51,61),Rect2(-45,-118,60,25),
	Rect2(-141,-92,126,14),Rect2(-141,78,126,14),
	Rect2(-109,-101,71,8),Rect2(38,93,71,8)
]
func build(a: Node3D) -> void:
	# Broad second floor with real voids; slab grid merges around the authored openings.
	var xs:Array[float]=[-151.5,151.5];var zs:Array[float]=[-119.5,119.5]
	for hole in holes:
		xs.append(hole.position.x);xs.append(hole.end.x)
		zs.append(hole.position.y);zs.append(hole.end.y)
	xs.sort();zs.sort()
	for ix in xs.size()-1:
		for iz in zs.size()-1:
			var size:=Vector2(xs[ix+1]-xs[ix],zs[iz+1]-zs[iz])
			if size.x<0.01 or size.y<0.01: continue
			var center:=Vector2(xs[ix],zs[iz])+size/2
			var opening:=false
			for hole in holes:
				if hole.has_point(center): opening=true;break
			if not opening: a.block(Vector3(center.x,19.6,center.y),Vector3(size.x,0.8,size.y),a.FLOOR)
	for hole in holes:
		var center:=hole.get_center()
		for x in [hole.position.x,hole.end.x]: a.stripe(Vector3(x,20.025,center.y),Vector3(0.12,0.04,hole.size.y),a.BLUE)
		for z in [hole.position.y,hole.end.y]: a.stripe(Vector3(center.x,20.025,z),Vector3(hole.size.x,0.04,0.12),a.BLUE)
	# A 120 m run climbs 20 m: broad, gradual ramps rather than narrow staircases.
	for z in [-85,85]:
		a.ramp(Vector3(-135,0,z),Vector3(-15,20,z),12,a.CYAN)
		for x in [-125,-85,-45]:
			a.light_pool(Vector3(x,12+(x+135)/6.0,z),a.CYAN,15)
	# Center stage bridges the atrium void from the two upper-floor sides.
	a.platform(Vector3(0,20,0),Vector2(12,12),a.AMBER)
	for side in [-1,1]: a.platform(Vector3(side*18,20,0),Vector2(24,5),a.AMBER)
	# Large, offset doorways compartmentalize the upper concourses.
	var doors:Array[Rect2]=[Rect2(-19,0,10,7),Rect2(-6,0,12,8),Rect2(-7,11,12,6)]
	for side in [-1,1]:
		for z in [-57,57]: a.window_wall(Vector3(side*112,20,z),64,23,doors,a.BLUE)
		for x in [-64,64]: a.window_wall(Vector3(x,20,side*98),40,23,doors,a.PINK,PI/2)
		for x in [-105,0,105]: a.light_pool(Vector3(x,36,side*101),a.BLUE,25)
		# Upper landing rooms and short sheltered loops.
		a.hideaway(Vector3(side*126,20,side*69),a.PINK,0 if side<0 else PI)
		a.light_pool(Vector3(side*115,35,0),a.CYAN,28)
