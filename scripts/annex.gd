extends RefCounted

func build(a: Node3D,t: Node3D) -> void:
	var side_holes:Array[Rect2]=[Rect2(-61,0,14,8),Rect2(-7,0,14,10),Rect2(47,0,14,8),Rect2(-28,14,16,7),Rect2(14,21,16,6)]
	var end_holes:Array[Rect2]=[Rect2(-62,0,14,8),Rect2(-7,0,14,10),Rect2(48,0,14,8),Rect2(-30,14,16,7),Rect2(12,21,16,6)]
	var screen_holes:Array[Rect2]=[Rect2(-26,0,14,8),Rect2(-6,10,16,8),Rect2(16,0,12,8),Rect2(-22,21,12,6)]
	# The old shell becomes a perforated internal boundary; the new halls form a loop.
	for side in [-1,1]:
		a.window_wall(Vector3(side*76,0,0),152,35,side_holes,a.BLUE,PI/2)
		a.window_wall(Vector3(0,0,side*76),152,35,end_holes,a.BLUE)
		var c:Color=a.AMBER if side<0 else a.PINK
		for z in [-48,48]:
			a.window_wall(Vector3(side*112,0,z),64,29,screen_holes,c)
		a.platform(Vector3(side*101,9,45),Vector2(32,7),c,true)
		a.platform(Vector3(side*128,17,6),Vector2(22,12),c,true)
		a.platform(Vector3(side*100,24,-44),Vector2(18,12),c,true)
		a.ramp(Vector3(side*87,0,75),Vector3(side*87,9,45),5,c)
		a.bounce(Vector3(side*112,0.14,-9),3.0,28,c)
		for z in [-82,0,82]:
			a.light_pool(Vector3(side*115,23,z),c,35)
			a.block(Vector3(side*146,17,z),Vector3(1.2,34,1.2),a.WALL)
			a.stripe(Vector3(side*145.35,17,z),Vector3(0.06,30,0.16),c)
		# Staggered covers form pockets without enclosing the fast central lane.
		for z in [-68,-20,28,76]:
			a.wall(Vector3(side*139,2.5,z),Vector3(14,5,0.8),c)
			a.platform(Vector3(side*142,5.7,z+3),Vector2(10,7),c)
			a.trail(Vector3(side*104,1.2,z-5),Vector3(side*104,1.2,z+5),3)
		a.trail(Vector3(side*92,10.2,45),Vector3(side*111,10.2,45),4)
		a.trail(Vector3(side*122,18.2,6),Vector3(side*134,18.2,6),3)
		# North and south concourses are long enough to make a travel network useful.
		a.platform(Vector3(0,8,side*97),Vector2(224,6),a.CYAN,true)
		a.ramp(Vector3(-125,0,side*86),Vector3(-105,8,side*97),5,a.CYAN)
		for x in [-120,-60,0,60,120]:
			a.light_pool(Vector3(x,20,side*102),a.BLUE,29)
			a.trail(Vector3(x-5,1.2,side*82),Vector3(x+5,1.2,side*82),3)
			a.wall(Vector3(x+12,2.2,side*112),Vector3(0.8,4.4,10),a.BLUE)
		a.trail(Vector3(-100,9.2,side*97),Vector3(100,9.2,side*97),13)
	a.platform(Vector3(140,17,0),Vector2(14,20),a.PINK)
	a.platform(Vector3(0,18,-108),Vector2(18,16),a.BLUE,true)
	a.ramp(Vector3(-36,8,-97),Vector3(-5,18,-108),4,a.BLUE)
	t.add_portal(a,Vector3(-140,0,0),PI/2,a.CYAN,0)
	t.add_portal(a,Vector3(140,17,0),-PI/2,a.CYAN,0)
	t.add_portal(a,Vector3(0,18,-108),0,a.PINK,1)
	t.add_portal(a,Vector3(0,0,108),PI,a.PINK,1)
	t.add_pad(a,Vector3(-110,0,42),Vector3(-128,17,6),1.75,a.AMBER)
	t.add_pad(a,Vector3(112,0,-32),Vector3(128,17,6),1.75,a.PINK)
	t.add_pad(a,Vector3(-104,8,-97),Vector3(-44,8,-97),2.24,a.CYAN)
	t.add_pad(a,Vector3(104,8,97),Vector3(44,8,97),2.24,a.CYAN)
