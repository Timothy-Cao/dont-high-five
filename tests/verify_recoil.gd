extends Node
var checks:=0
var failures:=0
func check(ok:bool,message:String) -> void:
	checks+=1
	if not ok: failures+=1
	print(("PASS  " if ok else "FAIL  ")+message)
func frames(n:int) -> void:
	for i in n: await get_tree().physics_frame
func reset(p:CharacterBody3D,pos:=Vector3(0,60.05,0)) -> void:
	p.reset_to(pos);p.rotation=Vector3.ZERO;p.camera.rotation=Vector3.ZERO;p.camera.position.y=1.58
	p.input_override=Vector2.ZERO;p.action_override={}
	await frames(10)
func run(lab:Node3D) -> void:
	var p=lab.player;var c=p.combat
	lab.started=true;lab.set_paused(false);p.testing_input=true;lab.arena.powerups.testing=true
	lab.box(Vector3(0,59.5,0),Vector3(110,1,110),lab.INK)
	await reset(p)
	p.camera.look_at(p.position+Vector3(0,0,-0.65));c.begin(1)
	var start_y:float=p.position.y;var apex:=start_y
	for i in 255:
		await frames(1);apex=maxf(apex,p.position.y)
	check(apex-start_y>=10 and apex-start_y<12.5,"full ground blast rises at least ten meters without doubling two fist contacts")
	print("FULL BLAST APEX ",apex-start_y)
	await reset(p)
	p.camera.look_at(p.position+Vector3(0,0,-0.65));c.begin(0)
	var tap_start:float=p.position.y;var tap_apex:=tap_start
	for i in 110: await frames(1);tap_apex=maxf(tap_apex,p.position.y)
	check(tap_apex-tap_start>1 and tap_apex-tap_start<2.0,"tap gives a smaller recoil hop")
	# Airborne ground punch preserves speed supplied by a preceding launch.
	await reset(p,Vector3(0,60.6,0));p.launch_from_pad(Vector3(22,3,0))
	p.camera.look_at(p.position+Vector3(0,-0.6,-0.6));c.begin(1)
	await frames(10)
	check(p.velocity.x>21.9 and p.velocity.y>22,"ground blast adds lift without deleting the actual launch-pad entry impulse")
	p.request_jump();await frames(2)
	check(p.velocity.y>20,"Space immediately after a blast does not overwrite the earned upward velocity")
	var wall=lab.box(Vector3(0,66,-2.8),Vector3(18,12,.3),lab.INK)
	await reset(p);c.begin(1);await frames(12)
	check(p.velocity.z>23 and p.velocity.y>0,"nearby wall punch propels away from the surface with floor clearance")
	# Parallel fists hit different faces of this inside corner.
	var sidewall=lab.box(Vector3(-2.8,66,0),Vector3(.3,12,18),lab.INK)
	await reset(p);p.camera.look_at(Vector3(-2.8,61.58,-2.8));c.begin(1);await frames(14)
	check(c.recoil_applied.x>12 and c.recoil_applied.z>12,"two wall normals combine into an outward diagonal at a corner")
	check(absf(c.recoil_applied.length()-24*c.recoil_weight)<0.05 and c.recoil_applied.length()<=24.05,"corner recoil shares one distance-weighted impulse budget instead of two boosts")
	sidewall.queue_free();wall.queue_free();await frames(2)
	# A far contact can damage without remote self-knockback.
	var farwall=lab.box(Vector3(0,66,-14),Vector3(18,12,.3),lab.INK)
	await reset(p);c.begin(1);await frames(40)
	check(not c.hopped and c.recoil_applied.length()<0.01,"distant impacts outside 4.5 m do not launch the player")
	farwall.queue_free();await frames(2)
	# Keep an actual boosted speed through landing and a buffered follow-up hop.
	await reset(p,Vector3(0,60.8,0));p.velocity=Vector3(28,-4,0);p.momentum_air=true
	for i in 90:
		await frames(1)
		if p.is_on_floor(): break
	p.request_jump();await frames(2)
	check(p.velocity.x>27.9 and p.velocity.y>7,"fast bunny hop retains blast/pad momentum")
	# Asset bounds and signed thumb locations are checked in imported Godot space.
	for i in 2:
		var hand:Node3D=p.hands[i].glove;var fist:Node3D=p.hands[i].fist
		var thumb=hand.find_child("Inward_thumb",true,false)
		if thumb==null: thumb=hand.find_child("Inward thumb",true,false)
		check(thumb!=null and thumb.position.x*(1 if i==0 else -1)>0.1,"open glove thumb faces inward: "+str(i))
		var folded=fist.find_child("Tucked_inward_thumb",true,false)
		if folded==null: folded=fist.find_child("Tucked inward thumb",true,false)
		check(folded!=null and folded.position.x*(1 if i==0 else -1)>0.08,"closed fist thumb faces inward: "+str(i))
		var bounds:=AABB()
		for mesh in fist.find_children("*","MeshInstance3D",true,false): bounds=bounds.merge(mesh.transform*mesh.get_aabb())
		check(bounds.size.x<0.30 and bounds.size.y<0.32,"compact fist has about half the previous dimensions: "+str(i))
	var rave=lab.arena.rave
	check(rave.beams.size()==20 and rave.spots.size()==28,"distributed installations bound laser and light-pool counts")
	var angle:float=rave.mirror.rotation.y;await frames(16)
	check(rave.mirror.rotation.y!=angle,"mirrorball turns while the game is running")
	lab.set_paused(true);angle=rave.mirror.rotation.y;await frames(16)
	check(rave.mirror.rotation.y==angle,"pause freezes the rave installation")
	lab.set_paused(false)
	check(lab.audio_service.samples.has("blast") and lab.audio_service.samples.blast.size()==4,"four original recoil sound variations load")
	print("RECOIL RESULT: ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
