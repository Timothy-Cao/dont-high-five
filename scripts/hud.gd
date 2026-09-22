extends Control

const PAPER = Color("e0d5bc")
const DIM = Color("92aaa8")
const ORANGE = Color("d6a15d")
var lab: Node3D
var menu: PanelContainer
var start_button: Button
var pages: VBoxContainer
var font := ThemeDB.fallback_font
var page := "Home"
var home: VBoxContainer
var detail_header: HBoxContainer
var back_button: Button
var header_title: Label
var welcome_time := 10.0
var nav_buttons: Dictionary = {}
var selected_binding := ""
var binder_status: Label
var page_scroll: ScrollContainer
var binding_buttons: Dictionary = {}
var now_playing: Label
var skip_track: Button

func style(color: Color, radius := 10) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = color
	s.set_corner_radius_all(radius)
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	return s

func label(parent: Node, value: String, point_size := 18, color := PAPER) -> Label:
	var l := Label.new()
	l.text = value
	l.add_theme_font_size_override("font_size",point_size)
	l.add_theme_color_override("font_color",color)
	parent.add_child(l)
	return l

func button(parent: Node, value: String, action: Callable, primary := false) -> Button:
	var b := Button.new()
	b.text = value
	b.custom_minimum_size.y = 42
	b.add_theme_font_size_override("font_size",19)
	b.add_theme_color_override("font_color",Color("203c42") if primary else PAPER)
	b.add_theme_color_override("font_hover_color",Color("203c42") if primary else PAPER)
	b.add_theme_color_override("font_focus_color",Color("203c42") if primary else PAPER)
	b.add_theme_color_override("font_pressed_color",Color("203c42") if primary else PAPER)
	b.add_theme_stylebox_override("normal",style(ORANGE if primary else Color("304950")))
	b.add_theme_stylebox_override("hover",style(Color("e0b578") if primary else Color("41616a")))
	b.add_theme_stylebox_override("pressed",style(Color("ae824d") if primary else Color("20383f")))
	var focus := style(Color(0,0,0,0))
	focus.set_border_width_all(2)
	focus.border_color = PAPER
	b.add_theme_stylebox_override("focus",focus)
	b.pressed.connect(action)
	parent.add_child(b)
	return b

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	menu = PanelContainer.new()
	add_child(menu)
	menu.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	var paper := style(Color("14232c"),12)
	paper.content_margin_left = 28
	paper.content_margin_right = 28
	paper.content_margin_top = 24
	paper.content_margin_bottom = 24
	menu.add_theme_stylebox_override("panel",paper)
	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation",18)
	menu.add_child(column)
	home = VBoxContainer.new()
	home.add_theme_constant_override("separation",10)
	column.add_child(home)
	label(home,"Don’t High Five",32)
	var space := Control.new()
	space.custom_minimum_size.y=12
	home.add_child(space)
	start_button=button(home,"Play",func():lab.started=true;lab.set_paused(false),true)
	for entry in [["Settings","Settings"]]:
		nav_buttons[entry[0]]=button(home,entry[1],func():show_page(entry[0]))
	button(home,"Quit",func():get_tree().quit())
	detail_header=HBoxContainer.new()
	column.add_child(detail_header)
	back_button=button(detail_header,"← Back",go_back)
	header_title=label(detail_header,"",19,DIM)
	header_title.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	header_title.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
	page_scroll=ScrollContainer.new()
	page_scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
	page_scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
	page_scroll.follow_focus=true
	column.add_child(page_scroll)
	pages=VBoxContainer.new()
	pages.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	pages.add_theme_constant_override("separation",12)
	page_scroll.add_child(pages)
	show_page("Home")

func go_back() -> void:
	show_page("Controls" if page=="Bindings" else ("Settings" if page in ["Controls","Abilities","Physics","Audio"] else "Home"))

func show_page(which: String) -> void:
	page = which
	if which!="Bindings": selected_binding=""
	for child in pages.get_children():
		pages.remove_child(child)
		child.queue_free()
	home.visible=which=="Home"
	pages.visible=which!="Home"
	page_scroll.visible=which!="Home"
	page_scroll.scroll_vertical=0
	detail_header.visible=which!="Home"
	header_title.text={"Yard":"Practice areas","Bindings":"Key bindings","Physics":"Advanced tuning"}.get(which,which)
	if which=="Yard" and not lab.test_world: header_title.text="Explore"
	var width:=440.0 if which=="Home" else 700.0
	var height:=300.0 if which=="Home" else 650.0
	menu.offset_left=-width/2
	menu.offset_right=width/2
	menu.offset_top=-height/2
	menu.offset_bottom=height/2
	if which=="Home": start_button.grab_focus()
	else: back_button.grab_focus()
	match which:
		"Yard":
			if not lab.test_world:
				label(pages,"Wander anywhere.",29)
				label(pages,"No timer, finish line, or required route.\nAll spaces connect. These are just shortcuts.",19,DIM)
				for i in 4:
					button(pages,lab.station_names[i],func():lab.goto_station(i);lab.started=true;lab.set_paused(false))
				label(pages,"Power stations recharge around the center and four corners.",18,DIM)
				return
			label(pages,"AFTER-HOURS MOVEMENT LAB",14,ORANGE)
			label(pages,"Light the way. Launch yourself.",29)
			label(pages,"Your gloves are lights, anchors and grapples.\nStart with a jump. Then try a slingshot.",19,DIM)
			label(pages,"Choose a practice area",16)
			for i in 4:
				var names := ["01   First class       /  the basic slingshot","02   Air mail            /  height & angle","03   Letter box       /  fit through the slot","04   After hours     /  wall grip, bounce & grapple"]
				button(pages,names[i],func():lab.goto_station(i);lab.started=true;lab.set_paused(false))
			label(pages,"No timer. No lives. Just one more launch.",17,DIM)
		"Controls":
			label(pages,"LMB / RMB   Place or recall a glove",18)
			label(pages,"LMB + RMB   Recall arms; when idle, hold to charge punch",18)
			label(pages,"Elastic: MMB reels / wheel adjusts. Fixed: alternate clicks.",18,DIM)
			label(pages,"F5   Camera     •     F11   Fullscreen     •     Esc   Menu",18,DIM)
			button(pages,"Key bindings",func():show_page("Bindings"))
		"Bindings":
			build_binder()
		"Abilities":
			label(pages,"EXPERIMENTAL MOVEMENT KIT",14,ORANGE)
			label(pages,"Keep what feels good.",29)
			check_button("Parallel punch (LMB + RMB)",lab.player.punch_enabled,func(v):lab.player.punch_enabled=v)
			check_button("Double jump",lab.player.double_jump_enabled,func(v):lab.player.double_jump_enabled=v)
			check_button("Stone brake / crouch",lab.player.brake_enabled,func(v):lab.player.brake_enabled=v)
			check_button("Wall grip & wall jump",lab.player.wall_grip_enabled,func(v):lab.player.wall_grip_enabled=v)
			check_button("Grapple reel",lab.player.reel_enabled,func(v):lab.player.reel_enabled=v)
			label(pages,"Ringed pads bounce. Walls and platforms accept gloves.",18,DIM)
		"Settings":
			add_slider("Music",0,100,1,lab.audio_service.music_volume*100,func(v):lab.audio_service.music_volume=v/100,true)
			add_slider("Sound effects",0,100,1,lab.audio_service.effects_volume*100,func(v):lab.audio_service.effects_volume=v/100,true)
			add_slider("Mouse sensitivity",0.6,4,0.1,lab.player.sensitivity*1000,func(v):lab.player.sensitivity=v/1000)
			add_slider("Brightness",0.06,0.4,0.01,lab.visibility_fill,func(v):lab.set_visibility(v))
			check_button("Speed FOV effect",lab.player.camera_motion,func(v):lab.player.camera_motion=v)
			check_button("Fullscreen",lab.player.fullscreen,func(v):lab.player.fullscreen=v;DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if v else DisplayServer.WINDOW_MODE_WINDOWED) if not lab.scripted_run else null)
			button(pages,"Controls",func():show_page("Controls"))
			if lab.test_world:
				button(pages,"Practice tuning",func():show_page("Physics"))
		"Audio":
			label(pages,"AFTERGLOW RADIO",14,ORANGE)
			label(pages,"Sound & music",29)
			add_slider("Music",0,100,1,lab.audio_service.music_volume*100,func(v):lab.audio_service.music_volume=v/100)
			add_slider("Effects",0,100,1,lab.audio_service.effects_volume*100,func(v):lab.audio_service.effects_volume=v/100)
			label(pages,"Now playing",16,DIM)
			now_playing=label(pages,lab.audio_service.title(),24)
			label(pages,"Five tracks. Shuffled, with a soft transition between songs.",18,DIM)
			skip_track=button(pages,"Next track",func():lab.audio_service.start_track())
		"Physics":
			label(pages,"RUBBER DEPARTMENT",14,ORANGE)
			label(pages,"Experiment with the feel",29)
			add_slider("Launch strength",1.5,6,0.1,lab.player.launch_gain,func(v):lab.player.launch_gain=v)
			add_slider("Gravity",8,28,0.5,lab.player.gravity,func(v):lab.player.gravity=v)
			add_slider("Air steering",0,60,1,lab.player.air_control,func(v):lab.player.air_control=v)
			add_slider("Spring stiffness",1,5,0.1,lab.player.spring_stiffness,func(v):lab.player.spring_stiffness=v)
			add_slider("Slack allowance",0.1,2,0.1,lab.player.slack_allowance,func(v):lab.player.slack_allowance=v)
			label(pages,"Slack changes apply when a glove next sticks.\nMaximum extra stretch: 5.5 m. Gloves stay attached.",17,DIM)
			button(pages,"Restore defaults",func():lab.player.launch_gain=4.2;lab.player.gravity=24;lab.player.air_control=36;lab.player.spring_stiffness=2.6;lab.player.slack_allowance=0.6;show_page("Physics"))

func check_button(title: String, checked: bool, action: Callable) -> void:
	var b := CheckButton.new()
	b.text = title
	b.button_pressed = checked
	b.custom_minimum_size.y = 40
	b.add_theme_font_size_override("font_size",20)
	b.add_theme_color_override("font_color",PAPER)
	b.toggled.connect(func(v):action.call(v);lab.save_preferences())
	pages.add_child(b)

func add_slider(title: String, lo: float, hi: float, step: float, value: float, action: Callable, percentage := false) -> void:
	var row := HBoxContainer.new()
	pages.add_child(row)
	var l := label(row,title,18)
	l.custom_minimum_size.x = 180
	var slider := HSlider.new()
	slider.min_value = lo
	slider.max_value = hi
	slider.step = step
	slider.value = value
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size.y = 42
	row.add_child(slider)
	var number := label(row,("%.0f%%"%value) if percentage else ("%.2f"%value),18,ORANGE)
	number.custom_minimum_size.x = 45
	number.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	slider.value_changed.connect(func(v):number.text=("%.0f%%"%v) if percentage else ("%.2f"%v);action.call(v);lab.save_preferences())

func _process(dt: float) -> void:
	if page=="Audio" and is_instance_valid(now_playing):
		now_playing.text=lab.audio_service.title()
		skip_track.disabled=lab.audio_service.fade_time<lab.audio_service.FADE
	if not lab.paused: welcome_time=maxf(0,welcome_time-dt)
	queue_redraw()

func txt(pos: Vector2, value: String, point_size: int, color := PAPER) -> void:
	draw_string(font,pos+Vector2(1,2),value,HORIZONTAL_ALIGNMENT_LEFT,-1,point_size,Color(0.02,0.07,0.09,0.8))
	draw_string(font,pos,value,HORIZONTAL_ALIGNMENT_LEFT,-1,point_size,color)

func centered(pos: Vector2, value: String, point_size: int, color := PAPER) -> void:
	txt(pos-Vector2(font.get_string_size(value,HORIZONTAL_ALIGNMENT_LEFT,-1,point_size).x*0.5,0),value,point_size,color)

func _draw() -> void:
	if not is_instance_valid(lab.player): return
	if lab.paused:
		draw_rect(Rect2(Vector2.ZERO,size),Color(0.02,0.07,0.09,0.65))
		return
	var p = lab.player
	var center := size*0.5
	if lab.test_world: txt(Vector2(28,40),lab.station_names[lab.station],15,DIM)
	if lab.test_world and p.velocity.length()>9:
		txt(Vector2(size.x-124,40),"%02.0f m/s"%p.velocity.length(),19,DIM)
	if p.arms_suppressed(): centered(center+Vector2(0,42),"ARMS OFFLINE",14,Color("f49baa"))
	var mode_label: String="FIXED · AUTO" if p.fixed_mode else "ELASTIC"
	if p.anchored: mode_label="ANCHORED"
	centered(Vector2(center.x,size.y-24),mode_label+"  ·  "+lab.controls.prompt("arm_mode"),13,DIM)
	if p.fixed_mode and p.has_anchor():
		var active: int=p.fixed_rope.active_hand
		if active>=0: centered(center+Vector2(0,38),"%.1f m"%p.hands[active].rest,13,DIM)
	var reticle := Color("9dcfbb") if p.target_valid else PAPER
	draw_circle(center,6,Color(0.05,0.12,0.13,0.7))
	draw_arc(center,5,0,TAU,24,reticle,1.5,true)
	draw_circle(center,1,reticle)
	if p.target_valid and lab.test_world:
		centered(center+Vector2(0,30),p.target_text,13,reticle)
	var attached := false
	for i in 2:
		var h: Dictionary = p.hands[i]
		var pos := center+Vector2(-42 if i==0 else 42,0)
		draw_circle(pos,5,h.color if h.state==2 else Color("233b43"))
		draw_arc(pos,6,0,TAU,20,PAPER,1,true)
		if p.hand_recovery>0:
			draw_arc(pos,8,-PI/2,-PI/2+TAU*(1-p.hand_recovery/p.HAND_RECOVERY_DURATION),24,h.color,2,true)
		if h.state==2:
			attached = true
			var tension := clampf((p.chest().distance_to(h.point)-float(h.rest))/p.stretch_limit,0,1)
			draw_line(pos+Vector2(-12,15),pos+Vector2(12,15),Color("233b43"),4,true)
			draw_line(pos+Vector2(-12,15),pos+Vector2(-12+24*tension,15),h.color.lightened(0.2),3,true)
	var hint := "LMB + RMB   /   Hold to charge, release to punch" if welcome_time>0 else ""
	if p.ball:
		hint = "%s  Brake"%lab.controls.prompt("brake") if p.velocity.length()>12 else ""
	elif p.power>0.02:
		hint = "%s   Launch   •   %.0f m/s   •   hold %s  Reel"%[lab.controls.prompt("launch"),p.shot_velocity(p.position).length(),lab.controls.prompt("reel")]
	elif attached and p.fixed_mode:
		hint="LMB / RMB  Alternate grips   •   %s  Release"%lab.controls.prompt("launch")
	elif attached:
		hint = "Walk back to stretch  •  hold %s to reel"%lab.controls.prompt("reel")
	if p.combat.active: hint="PUNCH"
	elif p.combat.charging: hint="CHARGING"
	elif p.stone: hint="STONE BRAKE  /  horizontal momentum stopped"
	elif p.wall_clinging: hint="WALL GRIP  /  %s climb  •  %s wall jump"%[lab.controls.movement_prompt(),lab.controls.prompt("jump")]
	elif p.reeling: hint="REELING  /  release %s to coast  •  %s jump off"%[lab.controls.prompt("reel"),lab.controls.prompt("jump")]
	if attached and lab.test_world:
		var lengths:=""
		for i in 2:
			if p.hands[i].state==2: lengths+=("L" if i==0 else "R")+" %.1f m   "%p.hands[i].rest
		centered(center+Vector2(0,58),lengths+"Wheel adjusts length",13,DIM)
	if lab.test_world:
		if not hint.is_empty(): centered(Vector2(center.x,size.y-42),hint,17)
		txt(Vector2(size.x-106,size.y-22),"Esc  Menu",13,DIM)
	if p.combat.charging:
		draw_arc(center,22,-PI/2,-PI/2+TAU*maxf(0.01,p.combat.charge_fraction()),48,ORANGE,3,true)
	if p.combat.hit_flash>0:
		for side in [-1,1]:
			draw_line(center+Vector2(side*9,-9),center+Vector2(side*15,-15),ORANGE,2,true)
			draw_line(center+Vector2(side*9,9),center+Vector2(side*15,15),ORANGE,2,true)
	var row_y:=size.y-28.0
	var names:={"speed":"SPEED","reach":"LONG ARMS","pull":"POWER","vision":"VISION","overdrive":"OVERDRIVE"}
	for kind in p.buffs:
		var value:float=p.buffs[kind]
		txt(Vector2(24,row_y),names[kind]+"  "+str(ceili(value))+"s",16,ORANGE if kind=="overdrive" else PAPER)
		row_y-=24
	if lab.message_time>0 and lab.test_world:
		centered(Vector2(center.x,76),lab.message,16)

func build_binder() -> void:
	binding_buttons.clear()
	binder_status=label(pages,"Choose a key to change. Esc cancels. Used keys swap.",16,DIM)
	for action in lab.controls.keys:
		var row:=HBoxContainer.new()
		pages.add_child(row)
		var title:=label(row,lab.controls.TITLES[action],18)
		title.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		title.vertical_alignment=VERTICAL_ALIGNMENT_CENTER
		var key:=button(row,lab.controls.prompt(action),func():select_binding(action))
		key.custom_minimum_size=Vector2(150,36)
		key.add_theme_font_size_override("font_size",17)
		binding_buttons[action]=key
	button(pages,"Reset keys",func():lab.controls.reset_bindings(not lab.scripted_run);selected_binding="";show_page("Bindings"))

func select_binding(action: String) -> void:
	for old in binding_buttons: binding_buttons[old].text=lab.controls.prompt(old)
	selected_binding=action
	binding_buttons[action].text="Press a key…"
	binder_status.text="Press a key for "+lab.controls.TITLES[action]+". Esc cancels."

func assign_binding(action: String,code: int) -> void:
	if lab.controls.bind(action,code,not lab.scripted_run):
		selected_binding=""
		for bound in binding_buttons: binding_buttons[bound].text=lab.controls.prompt(bound)
		binder_status.text="Saved. Used keys swap; Esc returns."
		binding_buttons[action].grab_focus()
	else: binder_status.text="That key is reserved for the menu, fullscreen, or practice areas."

func _input(event: InputEvent) -> void:
	if not lab.paused or selected_binding.is_empty(): return
	if event is InputEventKey and event.pressed and not event.echo:
		get_viewport().set_input_as_handled()
		if event.keycode==KEY_ESCAPE:
			selected_binding=""
			show_page("Bindings")
		else: assign_binding(selected_binding,event.physical_keycode if event.physical_keycode!=0 else event.keycode)
