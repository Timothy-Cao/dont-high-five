extends Node
## Prebuilt, level-matched assets. Two decks crossfade a no-repeat shuffled playlist.
const FADE:=1.4
var lab: Node3D
var playlist: Array=[]
var bag: Array[int]=[]
var current_track:=-1
var active_deck:=0
var decks: Array[AudioStreamPlayer]=[]
var deck_tracks: Array[int]=[-1,-1]
var fade_time:=FADE
var music_volume:=0.65
var effects_volume:=0.8
var samples: Dictionary={}
var voices: Dictionary={}
var last_variant: Dictionary={}
var loops: Dictionary={}
var rng:=RandomNumberGenerator.new()
var music_bus: int
var effects_bus: int
var ambience_bus: int

func bus(title: String) -> int:
	var index:=AudioServer.get_bus_index(title)
	if index<0:
		AudioServer.add_bus();index=AudioServer.bus_count-1
		AudioServer.set_bus_name(index,title)
	return index

func _ready() -> void:
	rng.randomize()
	music_bus=bus("Music");effects_bus=bus("Effects");ambience_bus=bus("Ambience")
	if AudioServer.get_bus_effect_count(0)==0:
		var limiter:=AudioEffectLimiter.new();limiter.ceiling_db=-1.0
		AudioServer.add_bus_effect(0,limiter)
	playlist=JSON.parse_string(FileAccess.get_file_as_string("res://assets/audio/music/playlist.json"))
	for i in 2:
		var deck:=AudioStreamPlayer.new();deck.bus="Music";add_child(deck);decks.append(deck)
	for kind in ["fire","stick","cancel","launch","jump","bounce","land","brake","portal","pad","success","ui","step"]:
		samples[kind]=[];voices[kind]=[];last_variant[kind]=-1
		for i in (5 if kind=="step" else 4):
			samples[kind].append(load("res://assets/audio/sfx/%s_%d.wav"%[kind,i]))
		for i in 3:
			var voice:=AudioStreamPlayer.new();voice.bus="Effects";add_child(voice);voices[kind].append(voice)
	for kind in ["wind","creak","reel","room"]:
		var stream:AudioStreamWAV=load("res://assets/audio/sfx/"+kind+".wav").duplicate()
		stream.loop_mode=AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin=0;stream.loop_end=int(stream.get_length()*stream.mix_rate)
		var voice:=AudioStreamPlayer.new();voice.bus="Ambience";voice.stream=stream;voice.volume_db=-80
		add_child(voice);loops[kind]=voice;voice.play()
	start_track(false)

func next_track() -> int:
	if bag.is_empty():
		for i in playlist.size(): bag.append(i)
		for i in range(bag.size()-1,0,-1):
			var j:=rng.randi_range(0,i);var saved:=bag[i];bag[i]=bag[j];bag[j]=saved
		if bag[-1]==current_track and bag.size()>1:
			var saved:=bag[0];bag[0]=bag[-1];bag[-1]=saved
	return bag.pop_back()

func start_track(crossfade:=true) -> void:
	if crossfade: active_deck=1-active_deck
	current_track=next_track();deck_tracks[active_deck]=current_track
	var deck:=decks[active_deck]
	deck.stop();deck.stream=load("res://assets/audio/music/"+str(playlist[current_track].file))
	deck.volume_db=-80 if crossfade else float(playlist[current_track].gain_db)
	deck.play();fade_time=0 if crossfade else FADE

func title() -> String:
	return str(playlist[current_track].title) if current_track>=0 else ""

func play(kind: String,pitch:=1.0) -> void:
	if not lab.audio_enabled or (lab.paused and kind!="ui") or not samples.has(kind): return
	var count:int=samples[kind].size()
	var variant:=rng.randi_range(0,count-2)
	if int(last_variant[kind])<0: variant=rng.randi_range(0,count-1)
	elif variant>=int(last_variant[kind]): variant+=1
	variant=variant%count;last_variant[kind]=variant
	var voice:AudioStreamPlayer=voices[kind][0]
	for candidate in voices[kind]:
		if not candidate.playing: voice=candidate;break
	voice.stop();voice.stream=samples[kind][variant]
	voice.pitch_scale=clampf(pitch*rng.randf_range(0.96,1.04),0.5,1.8)
	voice.volume_db=-5 if kind in ["step","success"] else -2
	voice.play()

func update_mix(dt: float) -> void:
	AudioServer.set_bus_mute(music_bus,not lab.audio_enabled)
	AudioServer.set_bus_mute(effects_bus,not lab.audio_enabled or lab.paused)
	AudioServer.set_bus_mute(ambience_bus,not lab.audio_enabled or lab.paused)
	AudioServer.set_bus_volume_db(music_bus,linear_to_db(maxf(0.0001,music_volume))+(-6 if lab.paused else 0))
	AudioServer.set_bus_volume_db(effects_bus,linear_to_db(maxf(0.0001,effects_volume)))
	AudioServer.set_bus_volume_db(ambience_bus,linear_to_db(maxf(0.0001,effects_volume)))
	fade_time=minf(FADE,fade_time+dt)
	var fraction:=fade_time/FADE
	for i in 2:
		if deck_tracks[i]<0: continue
		var weight:=sin(fraction*PI/2) if i==active_deck else cos(fraction*PI/2)
		decks[i].volume_db=float(playlist[deck_tracks[i]].gain_db)+linear_to_db(maxf(weight,0.0001))
		if i!=active_deck and fade_time>=FADE: decks[i].stop()
	var deck:=decks[active_deck]
	if fade_time>=FADE and (not deck.playing or deck.get_playback_position()>=deck.stream.get_length()-FADE):
		start_track()
	var p=lab.player
	var speed:float=p.velocity.length()
	loops.wind.volume_db=lerpf(-70,-14,smoothstep(7,38,speed))
	loops.creak.volume_db=-80 if p.power<0.04 else lerpf(-29,-16,clampf(p.power,0,1))
	loops.creak.pitch_scale=0.75+clampf(p.power,0,1)*0.65
	loops.reel.volume_db=move_toward(loops.reel.volume_db,-20 if p.reeling else -80,dt*100)
	loops.room.volume_db=-29

func _process(dt: float) -> void:
	update_mix(dt)

func _exit_tree() -> void:
	for child in get_children():
		if child is AudioStreamPlayer: child.stop();child.stream=null
	decks.clear();loops.clear();voices.clear();samples.clear()
