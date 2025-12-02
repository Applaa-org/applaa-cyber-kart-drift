extends Node

# Audio buses
var master_bus: int
var music_bus: int
var sfx_bus: int

# Current music
var current_music: AudioStreamPlayer
var music_tween: Tween

# Sound pools for frequently used sounds
var engine_sounds: Array[AudioStreamPlayer] = []
var drift_sounds: Array[AudioStreamPlayer] = []
var boost_sounds: Array[AudioStreamPlayer] = []

# Adaptive music state
var race_intensity: float = 0.0
var is_final_lap: bool = false

func _ready():
	# Create audio players
	current_music = AudioStreamPlayer.new()
	current_music.bus = "Master"
	add_child(current_music)
	
	# Pre-create sound effect pools
	create_sound_pools()

func create_sound_pools():
	# Engine sounds pool
	for i in range(8):
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		engine_sounds.append(player)
	
	# Drift sounds pool
	for i in range(4):
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		drift_sounds.append(player)
	
	# Boost sounds pool
	for i in range(4):
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		boost_sounds.append(player)

func play_music(music_name: String, fade_duration: float = 1.0):
	# For now, just handle music state
	# In full implementation, load and play music files
	pass

func stop_music(fade_duration: float = 1.0):
	if current_music.playing:
		if music_tween:
			music_tween.kill()
		music_tween = create_tween()
		music_tween.tween_property(current_music, "volume_db", -80.0, fade_duration)
		music_tween.tween_callback(current_music.stop)

func play_sfx(sfx_name: String, volume: float = 0.0, pitch: float = 1.0):
	# Create one-shot sound effect
	var player = AudioStreamPlayer.new()
	player.bus = "Master"
	player.volume_db = volume
	player.pitch_scale = pitch
	add_child(player)
	# In full implementation, load sound file
	# player.stream = load("res://assets/sounds/" + sfx_name + ".wav")
	# player.play()
	# player.finished.connect(player.queue_free)

func play_engine_sound(kart_index: int, speed_ratio: float):
	if kart_index < engine_sounds.size():
		var player = engine_sounds[kart_index]
		player.pitch_scale = 0.8 + speed_ratio * 0.6
		if not player.playing:
			pass # player.play()

func play_drift_sound(kart_index: int):
	if kart_index < drift_sounds.size():
		var player = drift_sounds[kart_index]
		if not player.playing:
			pass # player.play()

func stop_drift_sound(kart_index: int):
	if kart_index < drift_sounds.size():
		drift_sounds[kart_index].stop()

func play_boost_sound(kart_index: int):
	if kart_index < boost_sounds.size():
		pass # boost_sounds[kart_index].play()

func set_race_intensity(intensity: float):
	race_intensity = clamp(intensity, 0.0, 1.0)
	# Adjust music parameters based on intensity
	# In full implementation, this would control adaptive music layers

func set_final_lap(is_final: bool):
	is_final_lap = is_final
	if is_final:
		set_race_intensity(1.0)

func play_countdown_beep(count: int):
	var pitch = 1.0 if count > 0 else 1.5
	play_sfx("countdown_beep", 0.0, pitch)

func play_collision_sound(impact_force: float):
	var volume = lerp(-20.0, 0.0, clamp(impact_force / 500.0, 0.0, 1.0))
	play_sfx("collision", volume)

func play_weapon_sound(weapon_name: String):
	play_sfx("weapon_" + weapon_name.to_lower())

func play_pickup_sound():
	play_sfx("pickup", -5.0, randf_range(0.9, 1.1))

func play_victory_fanfare():
	stop_music(0.5)
	play_sfx("victory_fanfare")

func play_defeat_sound():
	stop_music(0.5)
	play_sfx("defeat")