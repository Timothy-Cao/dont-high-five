extends Node

const PREFIX := "pop_"
const DEFAULTS := {"forward":KEY_W,"back":KEY_S,"left":KEY_A,"right":KEY_D,"jump":KEY_SPACE,"launch":KEY_E,"reel":KEY_F,"brake":KEY_CTRL,"cling":KEY_C,"anchor":KEY_SHIFT,"arm_mode":KEY_1,"recall":KEY_Q,"retry":KEY_R,"reset":KEY_T,"preview":KEY_P}
const TITLES := {"forward":"Forward","back":"Backward","left":"Strafe left","right":"Strafe right","jump":"Jump / double jump","launch":"Slingshot","reel":"Reel in (hold)","brake":"Crouch / stone brake","cling":"Wall grip (hold)","anchor":"Anchor / drop (hold)","arm_mode":"Elastic / fixed arms","recall":"Recall gloves","retry":"Retry shot","reset":"Return to area","preview":"Trajectory"}
var keys: Dictionary = DEFAULTS.duplicate()
var changed := false

func _ready() -> void:
	var cfg := ConfigFile.new()
	if cfg.load("user://user_bindings.cfg")==OK: restore_bindings(cfg)
	apply()

func restore_bindings(cfg: ConfigFile) -> void:
	var candidate: Dictionary = DEFAULTS.duplicate()
	for action in DEFAULTS:
		var key = cfg.get_value("keys",action,DEFAULTS[action])
		if key is int and permitted(key): candidate[action]=key
	# Preserve old custom bindings. A newly introduced default never silently
	# takes a key from a user's saved action.
	if not cfg.has_section_key("keys","anchor"):
		if candidate.cling==KEY_SHIFT: candidate.cling=KEY_C
		for action in ["cling","anchor","arm_mode"]:
			var occupied:=[]
			for other in candidate:
				if other!=action: occupied.append(candidate[other])
			if candidate[action] in occupied:
				for fallback in [KEY_G,KEY_H,KEY_J,KEY_K,KEY_L,KEY_U,KEY_I]:
					if fallback not in occupied: candidate[action]=fallback;break
	var used := {}
	var valid := true
	for key in candidate.values():
		if used.has(key): valid=false
		used[key]=true
	if valid: keys=candidate

func permitted(key: int) -> bool:
	return key>0 and key not in [KEY_ESCAPE,KEY_TAB,KEY_F5,KEY_F11,KEY_2,KEY_3,KEY_4]

func apply() -> void:
	changed=true
	for action in keys:
		var name: String = PREFIX+action
		if not InputMap.has_action(name): InputMap.add_action(name)
		InputMap.action_erase_events(name)
		var event := InputEventKey.new()
		event.physical_keycode = keys[action]
		InputMap.action_add_event(name,event)

func bind(action: String,key: int, persist := true) -> bool:
	if not keys.has(action) or not permitted(key): return false
	var previous: int = keys[action]
	for other in keys:
		if other!=action and keys[other]==key: keys[other]=previous
	keys[action]=key
	apply()
	if persist: save()
	return true

func reset_bindings(persist := true) -> void:
	keys=DEFAULTS.duplicate()
	apply()
	if persist: save()

func save() -> void:
	var cfg := ConfigFile.new()
	for action in keys: cfg.set_value("keys",action,keys[action])
	cfg.save("user://user_bindings.cfg")

func key_name(code: int) -> String:
	return "Ctrl" if code==KEY_CTRL else OS.get_keycode_string(code)

func prompt(action: String) -> String:
	return key_name(keys.get(action,0))

func movement_prompt() -> String:
	return "%s/%s/%s/%s"%[prompt("forward"),prompt("left"),prompt("back"),prompt("right")]

func held(action: String) -> bool:
	return Input.is_action_pressed(PREFIX+action)
