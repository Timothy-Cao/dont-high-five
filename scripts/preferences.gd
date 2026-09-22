extends RefCounted
## User-facing settings only. Physics experiments never become hidden save state.
var path := "user://settings.cfg"

func number(cfg: ConfigFile, key: String, fallback: float, lo: float, hi: float) -> float:
	var value = cfg.get_value("settings", key, fallback)
	if not (value is float or value is int) or not is_finite(float(value)): return fallback
	return clampf(float(value), lo, hi)

func flag(cfg: ConfigFile, key: String, fallback: bool) -> bool:
	var value = cfg.get_value("settings", key, fallback)
	return value if value is bool else fallback

func restore(lab: Node3D) -> void:
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK: return
	lab.audio_service.music_volume = number(cfg,"music",0.5,0,1)
	lab.audio_service.effects_volume = number(cfg,"effects",0.5,0,1)
	lab.player.sensitivity = number(cfg,"sensitivity",0.0022,0.0006,0.004)
	lab.set_visibility(number(cfg,"brightness",lab.visibility_fill,0.06,0.4))
	lab.player.camera_motion = flag(cfg,"camera_motion",true)
	lab.player.preview_enabled = flag(cfg,"trajectory",true)
	lab.player.grip_lights = flag(cfg,"glove_lights",true)
	lab.audio_enabled = flag(cfg,"sound",true)
	lab.player.fullscreen = flag(cfg,"fullscreen",false)
	if lab.player.fullscreen and DisplayServer.get_name() != "headless":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func save(lab: Node3D) -> Error:
	var cfg := ConfigFile.new()
	var values := {"music":lab.audio_service.music_volume,"effects":lab.audio_service.effects_volume,
		"sensitivity":lab.player.sensitivity,"brightness":lab.visibility_fill,
		"camera_motion":lab.player.camera_motion,"trajectory":lab.player.preview_enabled,
		"glove_lights":lab.player.grip_lights,"sound":lab.audio_enabled,"fullscreen":lab.player.fullscreen}
	for key in values: cfg.set_value("settings",key,values[key])
	return cfg.save(path)
