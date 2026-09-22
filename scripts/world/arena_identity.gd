extends RefCounted
## After-hours robotic laser-tag venue. Architectural dressing respects existing lanes.
const Kit=preload("res://scripts/world/arena_kit.gd")
const P=preload("res://scripts/gameplay/props.gd")
func build(arena:Node3D) -> void:
	var specs:=Kit.catalogue()
	# Replace featureless enclosure faces with flush, manufactured impact panels.
	for side in [-1,1]:
		for z in range(-104,105,16):
			for y in [0.0,20.0]:
				var panel=Kit.make(specs[1]);arena.add_child(panel)
				panel.position=Vector3(side*151.2,y,z);panel.rotation.y=PI/2
		for x in range(-136,137,16):
			var panel=Kit.make(specs[1]);arena.add_child(panel);panel.position=Vector3(x,0,side*119.2)
	# Large reel emblems at the ends provide orientation without words or visual clutter.
	for side in [-1,1]:
		var at:=Vector3(side*151.45,29,0)
		var wash:=OmniLight3D.new();arena.add_child(wash);wash.position=Vector3(side*146,29,0);wash.omni_range=16;wash.light_energy=4;wash.light_color=Color("9abcc9");wash.shadow_enabled=true
		var disc:=CylinderMesh.new();disc.top_radius=5;disc.bottom_radius=5;disc.height=.12;disc.radial_segments=64
		var backing=P.mesh(arena,disc,at,Color("314851"));backing.rotation.z=PI/2
		for radius in [2.2,4.2]:
			var torus:=TorusMesh.new();torus.inner_radius=radius-.08;torus.outer_radius=radius;torus.rings=64;torus.ring_segments=8
			var rim=P.mesh(arena,torus,at-Vector3.RIGHT*side*.08,Color("d9a262") if side<0 else Color("69bbb9"),.8);rim.rotation.z=PI/2
		for i in 6:
			var a:=i*TAU/6
			var shape:=BoxMesh.new();shape.size=Vector3(.16,.45,2.0)
			var spoke=P.mesh(arena,shape,at+Vector3(-side*.1,sin(a)*3,cos(a)*3),Color("506975"));spoke.rotation.x=-a
	# Neutral pools reveal material form; existing coloured lights retain district identity.
	for at in [Vector3(-106,12,0),Vector3(106,30,20),Vector3(0,30,82),Vector3(0,12,-84)]:
		var light:=OmniLight3D.new();arena.add_child(light);light.position=at
		light.light_color=Color("a3c0c6");light.light_energy=2;light.omni_range=22;light.shadow_enabled=true
