extends Node
var checks:=0
var failures:=0
func check(ok:bool,message:String) -> void:
	checks+=1
	if not ok:failures+=1
	print(("PASS  " if ok else "FAIL  ")+message)
func frames(n:int) -> void:
	for i in n:await get_tree().physics_frame
func run(lab:Node3D) -> void:
	lab.started=true;lab.set_paused(false)
	var p=lab.player;var b=lab.builder;var a=lab.audio_service;var w=lab.session.watcher
	p.testing_input=true;p.set_physics_process(false)
	var voice=a.play_at("watcher_sniper",p.camera.global_position+Vector3.RIGHT*20)
	check(voice is AudioStreamPlayer3D and voice.global_position.distance_to(p.camera.global_position+Vector3.RIGHT*20)<.001,"world shot plays at its actual source")
	check(voice.bus=="Effects" and voice.unit_size==18 and voice.max_distance==260 and voice.attenuation_model==AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE,"world sound uses bounded distance attenuation and the effects slider")
	check(a.play_at("watcher_blast",p.camera.global_position+Vector3.UP*300)==null,"inaudibly distant events do not occupy the voice pool")
	for i in 100:a.play_at("watcher_mg",p.camera.global_position+Vector3.RIGHT*(2+i%12))
	check(a.spatial.get_child_count()==32,"rapid tower fire keeps a fixed 32-voice budget")
	check(a.play_at("watcher_blast",p.camera.global_position+Vector3.RIGHT*25)!=null,"blast voices remain available during machine-gun saturation")
	lab.set_paused(true);await get_tree().process_frame;await get_tree().process_frame
	check(voice.stream_paused and a.play_at("watcher_mg",Vector3.ZERO)==null,"pause suspends world voices and rejects new gameplay sounds")
	lab.set_paused(false);await get_tree().process_frame;await get_tree().process_frame
	check(not voice.stream_paused,"world voices resume with play")
	lab.audio_enabled=false;check(a.play_at("watcher_blast",p.position)==null,"sound-disabled setting suppresses world events");lab.audio_enabled=true
	for item in a.spatial.voices:item.stop()
	var count:int=a.spatial.serial;w.fire(p.camera.global_position+Vector3.RIGHT*8,Vector3.UP,12)
	check(a.spatial.serial==count+1,"unpiloted tower firing uses world audio")
	count=a.spatial.serial;w.explode(p.position+Vector3.UP*25,1,0)
	check(a.spatial.serial==count+1,"explosion sound originates at the blast")
	p.rotation=Vector3.ZERO;p.camera.rotation=Vector3.ZERO
	var feedback=p.damage_feedback;var origin:Vector3=p.camera.global_position
	check(feedback.bearing(p.camera,origin+Vector3.FORWARD*10).is_equal_approx(Vector2.UP) and feedback.bearing(p.camera,origin+Vector3.RIGHT*10).is_equal_approx(Vector2.RIGHT),"damage bearings distinguish front and right")
	p.camera.rotation.x=-PI/2
	check(feedback.bearing(p.camera,origin+Vector3.BACK*10).is_equal_approx(Vector2.DOWN),"ceiling aim preserves a stable yaw-relative bearing")
	p.camera.rotation=Vector3.ZERO
	p.take_damage(0,origin,"watcher");check(feedback.hits.is_empty(),"zero damage never reports an incoming hit")
	p.take_damage(1,origin+Vector3.RIGHT*10,"watcher");p.take_damage(1,origin+Vector3.RIGHT*10,"watcher")
	check(feedback.hits.size()==1,"repeated fire from one source refreshes one cue")
	feedback.update(1);check(feedback.hits.is_empty(),"attack cue expires without tracking enemies")
	p.take_damage(1,origin,"blast");p.reset_to(p.position)
	check(feedback.hits.is_empty(),"retry clears obsolete damage feedback")
	b.enter();b.load_map("res://assets/maps/workshop-example.json");await frames(3)
	b.entries[0].yaw=3;b.rebuild();await frames(2)
	b.elevation=7
	check(b.pick_part(0) and b.selected==b.entries[0].part and b.yaw==3 and b.elevation==0,"eyedropper copies module and rotation without stale height offset")
	check(not b.pick_part(-1) and not b.pick_part(999),"eyedropper ignores invalid targets")
	var floor:Vector3=b.ORIGIN+Vector3(32,0,32)
	check(b.safe_test_spot(floor,Vector3.UP) and not b.safe_test_spot(floor,Vector3.RIGHT),"test-here accepts clear floors and rejects walls")
	var low_roof=lab.box(floor+Vector3.UP*1.3,Vector3(4,.3,4),lab.INK);await frames(3)
	check(not b.safe_test_spot(floor,Vector3.UP),"test-here rejects insufficient headroom")
	low_roof.queue_free();await frames(3)
	b.camera.position=floor+Vector3(0,8,8);b.camera.look_at(floor)
	var edit_position:Vector3=b.camera.position
	b.toggle_test(true)
	check(b.testing and p.position.distance_to(floor+Vector3.UP*.05)<.1,"test-here enters play on the pointed surface")
	p.position+=Vector3.RIGHT*10;p.retry()
	check(p.position.distance_to(b.ORIGIN+b.test_start)<.01,"retry returns to the local test point")
	b.toggle_test();check(b.camera.current and b.camera.position==edit_position,"return to edit preserves the working camera")
	b.snapshot();b.entries.append({"part":0,"pos":[50,0,50],"yaw":0});b.rebuild()
	var saved_size:int=b.entries.size();b.autosave_elapsed=59;b.update_autosave(1)
	check(FileAccess.file_exists(b.recovery_path()) and b.dirty and b.autosave_revision==b.revision,"periodic recovery preserves dirty status and does not claim a main save")
	b.remove(b.entries.size()-1)
	check(b.recover_map() and b.entries.size()==saved_size and b.dirty,"recovery restores unsaved work and still requests a manual save")
	b.undo();check(b.entries.size()==saved_size-1,"recovery itself is undoable")
	b.dirty=false;b.leave()
	print("REFINEMENT RESULT: ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
