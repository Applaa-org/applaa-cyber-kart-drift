extends Node

# Audio buses
var music_bus: int
var sfx_bus: int

# Currently playing
var current_music: AudioStreamPlayer
var music_tracks: Dictionary = {}

# Sound effect pools
var sfx_pool: Array[AudioStreamPlayer] = []
const SFX_POOL_SIZE: int = 16

func _ready() -> void:
	music_bus = AudioServer.get_bus_index("Master")
	sfx_bus = AudioServer.get_bus_index("Master")
	
	# Create music player
	current_music = AudioStreamPlayer.new()
	current_music.bus = "Master"
	add_child(current_music)
	
	# Create SFX pool
	for i in range(SFX_POOL_SIZE):
		var player = AudioStreamPlayer.new()
		player.bus = "Master"
		add_child(player)
		sfx_pool.append(player)
	
	update_volumes()

func update_volumes() -> void:
	AudioServer.set_bus_volume_db(music_bus, linear_to_db(Global.music_volume))

func play_music(track_name: String, fade_in: float = 1.0) -> void:
	# For now, just stop any playing music
	if current_music.playing:
		var tween = create_tween()
		tween.tween_property(current_music, "volume_db", -40.0, 0.5)
		tween.tween_callback(current_music.stop)

func stop_music(fade_out: float = 1.0) -> void:
	if current_music.playing:
		var tween = create_tween()
		tween.tween_property(current_music, "volume_db", -40.0, fade_out)
		tween.tween_callback(current_music.stop)

func play_sfx(sound_name: String, volume: float = 1.0, pitch: float = 1.0) -> void:
	# Find available player in pool
	for player in sfx_pool:
		if not player.playing:
			player.volume_db = linear_to_db(volume * Global.sfx_volume)
			player.pitch_scale = pitch
			# Would load actual sound here
			# player.stream = load("res://assets/sounds/" + sound_name + ".wav")
			# player.play()
			break

func play_engine_sound(speed_ratio: float) -> void:
	# Engine sound with pitch based on speed
	var pitch = lerp(0.8, 1.5, speed_ratio)
	play_sfx("engine_loop", 0.3, pitch)

func play_drift_sound() -> void:
	play_sfx("drift_screech", 0.5, randf_range(0.9, 1.1))

func play_boost_sound() -> void:
	play_sfx("boost_ignite", 0.8, 1.0)

func play_weapon_sound(weapon_type: String) -> void:
	match weapon_type:
		"plasma_missile":
			play_sfx("missile_launch", 0.7)
		"emp_blast":
			play_sfx("emp_pulse", 0.8)
		"arc_shot":
			play_sfx("electric_zap", 0.6)
		"shockwave_mine":
			play_sfx("mine_drop", 0.5)
		_:
			play_sfx("generic_weapon", 0.6)

func play_impact_sound(impact_type: String = "default") -> void:
	match impact_type:
		"explosion":
			play_sfx("explosion", 0.9, randf_range(0.9, 1.1))
		"shield":
			play_sfx("shield_hit", 0.7)
		"wall":
			play_sfx("wall_scrape", 0.5)
		_:
			play_sfx("impact", 0.6)

func play_ui_sound(sound_type: String = "click") -> void:
	match sound_type:
		"click":
			play_sfx("ui_click", 0.4, 1.0)
		"hover":
			play_sfx("ui_hover", 0.2, 1.2)
		"confirm":
			play_sfx("ui_confirm", 0.5, 1.0)
		"back":
			play_sfx("ui_back", 0.4, 0.9)

func play_countdown_beep(final: bool = false) -> void:
	if final:
		play_sfx("countdown_go", 0.8, 1.0)
	else:
		play_sfx("countdown_beep", 0.6, 1.0)

func play_lap_complete() -> void:
	play_sfx("lap_complete", 0.7, 1.0)

func play_race_finish(position: int) -> void:
	if position == 1:
		play_sfx("victory_fanfare", 0.9)
	elif position <= 3:
		play_sfx("podium_finish", 0.7)
	else:
		play_sfx("race_complete", 0.5)