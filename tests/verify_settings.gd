extends Node
var checks:=0
var failures:=0
func check(ok: bool,message: String) -> void:
	checks+=1
	if not ok: failures+=1
	print(("PASS  " if ok else "FAIL  ")+message)
func frames(n: int) -> void:
	for i in n: await get_tree().physics_frame
func run(lab: Node3D) -> void:
	var a=lab.audio_service;var p=lab.player;var hud=lab.hud
	p.testing_input=true;lab.started=true;lab.set_paused(false)
	check(a.music_volume==0.5 and a.effects_volume==0.5,"new sessions default both audio sliders to 50 percent")
	a.update_mix(0.01)
	check(absf(db_to_linear(AudioServer.get_bus_volume_db(a.music_bus))-0.125)<0.0001,"music 50 percent produces 12.5 percent bus gain")
	check(absf(db_to_linear(AudioServer.get_bus_volume_db(a.effects_bus))-0.5)<0.0001,"effects retain ordinary linear 50 percent gain")
	for volume in [0.0,0.5,1.0]:
		a.music_volume=volume;a.effects_volume=volume;a.update_mix(0.01)
		check(AudioServer.is_bus_mute(a.music_bus)==(volume==0) and AudioServer.is_bus_mute(a.effects_bus)==(volume==0),"zero mutes and positive volume unmutes both buses: "+str(volume))
	a.music_volume=0.5;a.effects_volume=0.5
	var prefs=load("res://scripts/preferences.gd").new();prefs.path="res://.local/settings-test.cfg"
	a.music_volume=0.32;a.effects_volume=0.71;p.sensitivity=0.0031;p.camera_motion=true
	check(prefs.save(lab)==OK,"preferences save to an isolated test file")
	a.music_volume=0.5;a.effects_volume=0.5;p.sensitivity=0.0022;p.camera_motion=false
	prefs.restore(lab)
	check(absf(a.music_volume-0.32)<0.001 and absf(a.effects_volume-0.71)<0.001 and absf(p.sensitivity-0.0031)<0.00001 and p.camera_motion,"audio and input preferences survive a reload")
	var cfg:=ConfigFile.new();cfg.set_value("settings","music",99);cfg.set_value("settings","effects","invalid");cfg.set_value("settings","camera_motion",false);cfg.save(prefs.path)
	prefs.restore(lab)
	check(a.music_volume==1 and a.effects_volume==0.5 and not p.camera_motion,"malformed preferences are bounded or replaced with defaults")
	DirAccess.remove_absolute(prefs.path)
	lab.set_paused(true);hud.show_page("Settings")
	await frames(2)
	var sliders=hud.pages.find_children("*","HSlider",true,false)
	sliders[0].value=50;sliders[1].value=50
	check(a.music_volume==0.5 and a.effects_volume==0.5,"visible Settings sliders update the real audio service")
	check(hud.pages.find_children("*","CheckButton",true,false).size()==2,"ordinary Settings has only camera-motion and fullscreen toggles")
	hud.show_page("Bindings");await frames(2)
	check(hud.binding_buttons.size()==lab.controls.keys.size(),"simple action list exposes every keyboard binding")
	var old_jump:int=lab.controls.keys.jump;var old_reel:int=lab.controls.keys.reel
	hud.binding_buttons.jump.pressed.emit();hud.assign_binding("jump",old_reel)
	check(lab.controls.keys.jump==old_reel and lab.controls.keys.reel==old_jump,"rebinding an occupied key swaps actions without losing either")
	check(hud.binding_buttons.jump.text==lab.controls.prompt("jump"),"changed key is shown immediately")
	hud.select_binding("jump");hud.assign_binding("jump",KEY_F5)
	check(lab.controls.keys.jump==old_reel and hud.selected_binding=="jump","reserved camera key is rejected without replacing the binding")
	var event:=InputEventKey.new();event.keycode=KEY_ESCAPE;event.pressed=true;hud._input(event)
	check(hud.selected_binding.is_empty() and lab.paused,"Escape cancels key capture without resuming the game")
	lab.controls.reset_bindings(false);hud.show_page("Bindings");await frames(2)
	check(hud.page_scroll.get_v_scroll_bar().max_value>hud.page_scroll.size.y,"long binding list scrolls instead of stretching the menu")
	check(hud.get_global_rect().encloses(hud.menu.get_global_rect()),"binding menu fits the baseline viewport")
	# The new red room always applies to everyone, with two usable walking exits.
	lab.set_paused(false);p.reset_to(Vector3(112,20.05,-82));await frames(3)
	check(p.arms_suppressed(),"entering the red room disables arm equipment")
	p.fire_hand(0);check(p.hands[0].state==0,"suppression prevents glove fire")
	check(not p.combat.begin(),"suppression prevents punching")
	p.attach_fixture(Vector3(108,26,-82),Vector3(116,26,-82));p.action_override={"reel":true,"cling":true};await frames(3)
	check(not p.has_anchor() and not p.reeling and not p.wall_clinging,"field clears existing anchors and prevents reel and wall grip")
	p.action_override={};p.input_override=Vector2(0,1);await frames(195)
	check(p.position.z> -71 and not p.arms_suppressed(),"south field can be walked through and equipment returns outside")
	p.input_override=Vector2.ZERO;p.hand_recovery=0;p.fire_hand(0)
	check(p.hands[0].state==1,"gloves work again after leaving the field")
	p.reset_to(Vector3(112,20.05,-82));p.input_override=Vector2(0,-1);await frames(195)
	check(p.position.z< -93 and not p.arms_suppressed(),"north exit is also freely walkable")
	p.input_override=Vector2.ZERO;p.reset_to(Vector3(112,20.05,-94));p.camera.look_at(Vector3(112,21.6,-82));p.fire_hand(0)
	check(not p.hands[0].hit and p.hands[0].point.z< -90,"red doorway blocks incoming glove anchors")
	p.cancel_hands();p.hand_recovery=0;p.combat.begin();await frames(20)
	check(not p.combat.active,"red doorway stops incoming punches")
	print("SETTINGS AND ROOM RESULT: ",checks-failures,"/",checks)
	get_tree().quit(1 if failures else 0)
