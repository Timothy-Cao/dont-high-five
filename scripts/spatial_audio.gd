extends Node3D
## Bounded world voices. Nearby events win over distant events when the pool fills.
const LIMIT:=32
var lab:Node3D
var voices:Array[AudioStreamPlayer3D]=[]
var serial:=0
func _ready() -> void:
	for i in LIMIT:
		var voice:=AudioStreamPlayer3D.new();voice.bus="Effects";voice.max_db=0
		voice.attenuation_model=AudioStreamPlayer3D.ATTENUATION_INVERSE_DISTANCE
		voice.unit_size=18;voice.max_distance=260;voice.panning_strength=0.85
		voice.attenuation_filter_cutoff_hz=6000;voice.attenuation_filter_db=-12
		add_child(voice);voices.append(voice)
func play_at(stream:AudioStream,at:Vector3,pitch:=1.0,gain_db:=-2.0,important:=false) -> AudioStreamPlayer3D:
	if not lab.audio_enabled or lab.paused or stream==null:return null
	var camera:=get_viewport().get_camera_3d()
	if camera==null or camera.global_position.distance_to(at)>=260:return null
	var voice:AudioStreamPlayer3D
	# Reserve eight voices for blasts so machine-gun tails cannot consume every cue.
	var candidates:Array=voices.slice(24,32) if important else voices.slice(0,24)
	for candidate in candidates:
		if not candidate.playing:voice=candidate;break
	if voice==null:
		voice=candidates[0]
		for candidate in candidates:
			if candidate.global_position.distance_squared_to(camera.global_position)>voice.global_position.distance_squared_to(camera.global_position):voice=candidate
		if at.distance_squared_to(camera.global_position)>voice.global_position.distance_squared_to(camera.global_position):return null
	voice.stop();voice.global_position=at;voice.stream=stream;voice.pitch_scale=clampf(pitch,0.5,1.8);voice.volume_db=gain_db
	voice.stream_paused=false;voice.play();serial+=1
	return voice
func _process(_dt:float) -> void:
	for voice in voices:voice.stream_paused=lab.paused
func _exit_tree() -> void:
	for voice in voices:voice.stop();voice.stream=null
