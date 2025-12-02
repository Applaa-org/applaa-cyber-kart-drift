extends Node

# Game State
enum GameState { MENU, RACING, PAUSED, VICTORY, DEFEAT, GARAGE, LOADING }
var current_state: GameState = GameState.MENU

# Player Data
var player_name: String = "Racer"
var credits: int = 1000
var holo_tokens: int = 50
var data_shards: int = 10
var xp: int = 0
var level: int = 1

# Current Race Data
var score: int = 0
var lap_count: int = 0
var total_laps: int = 3
var race_position: int = 1
var race_time: float = 0.0
var drift_score: int = 0
var knockouts: int = 0

# Selected Options
var selected_kart_class: String = "Balanced"
var selected_track: String = "neon_skyline_1"
var selected_game_mode: String = "single_race"
var ai_difficulty: String = "medium"
var ai_racer_count: int = 5

# Kart Stats (base values modified by class)
var kart_stats: Dictionary = {
	"speed": 400.0,
	"acceleration": 250.0,
	"handling": 0.8,
	"boost_power": 1.0,
	"drift_efficiency": 1.0,
	"max_health": 100
}

# Kart Classes Definition
var kart_classes: Dictionary = {
	"Speedster": {"speed": 500, "acceleration": 300, "handling": 0.7, "boost_power": 1.2, "drift_efficiency": 0.9, "max_health": 80, "special": "quantum_boost", "color": Color(0.0, 0.8, 1.0)},
	"Bruiser": {"speed": 350, "acceleration": 200, "handling": 0.5, "boost_power": 0.8, "drift_efficiency": 0.7, "max_health": 150, "special": "armor_wall", "color": Color(1.0, 0.3, 0.2)},
	"Balanced": {"speed": 400, "acceleration": 250, "handling": 0.8, "boost_power": 1.0, "drift_efficiency": 1.0, "max_health": 100, "special": "pulse_shield", "color": Color(0.5, 1.0, 0.5)},
	"Technical": {"speed": 380, "acceleration": 280, "handling": 1.0, "boost_power": 1.1, "drift_efficiency": 1.3, "max_health": 90, "special": "teleport_dash", "color": Color(1.0, 0.8, 0.0)},
	"Experimental": {"speed": 450, "acceleration": 350, "handling": 0.6, "boost_power": 1.5, "drift_efficiency": 1.1, "max_health": 70, "special": "weapon_jam", "color": Color(0.8, 0.2, 1.0)}
}

# Unlocked Content
var unlocked_karts: Array = ["Balanced", "Speedster"]
var unlocked_tracks: Array = ["neon_skyline_1", "neon_skyline_2"]
var unlocked_weapons: Array = ["PlasmaMissile", "PulseShield"]
var unlocked_skins: Array = ["default"]

# Customization
var kart_customization: Dictionary = {
	"body_kit": "default",
	"underglow_color": Color(0.0, 1.0, 1.0),
	"trail_effect": "neon",
	"decal": "none",
	"thruster_color": Color(1.0, 0.5, 0.0)
}

# Settings
var settings: Dictionary = {
	"master_volume": 0.8,
	"music_volume": 0.7,
	"sfx_volume": 0.9,
	"screen_shake": true,
	"show_fps": false,
	"control_scheme": "keyboard"
}

# Signals
signal score_changed(new_score: int)
signal health_changed(new_health: int)
signal boost_changed(new_boost: float)
signal lap_completed(lap_number: int)
signal race_finished(position: int)
signal weapon_collected(weapon_name: String)
signal credits_changed(new_credits: int)

func _ready():
	load_kart_stats()

func load_kart_stats():
	if selected_kart_class in kart_classes:
		var kart = kart_classes[selected_kart_class]
		kart_stats = {
			"speed": kart.speed,
			"acceleration": kart.acceleration,
			"handling": kart.handling,
			"boost_power": kart.boost_power,
			"drift_efficiency": kart.drift_efficiency,
			"max_health": kart.max_health
		}

func select_kart_class(class_name: String):
	if class_name in kart_classes:
		selected_kart_class = class_name
		load_kart_stats()

func add_score(points: int):
	score += points
	score_changed.emit(score)

func add_drift_score(points: int):
	drift_score += points
	add_score(points)

func add_credits(amount: int):
	credits += amount
	credits_changed.emit(credits)

func spend_credits(amount: int) -> bool:
	if credits >= amount:
		credits -= amount
		credits_changed.emit(credits)
		return true
	return false

func add_xp(amount: int):
	xp += amount
	check_level_up()

func check_level_up():
	var xp_needed = level * 500
	while xp >= xp_needed:
		xp -= xp_needed
		level += 1
		xp_needed = level * 500
		# Unlock rewards on level up
		on_level_up()

func on_level_up():
	add_credits(100 * level)
	holo_tokens += 10

func complete_lap():
	lap_count += 1
	lap_completed.emit(lap_count)
	if lap_count >= total_laps:
		finish_race()

func finish_race():
	var position_points = [100, 75, 50, 35, 25, 15, 10, 5]
	if race_position <= position_points.size():
		add_score(position_points[race_position - 1])
	add_xp(50 + (8 - race_position) * 10)
	race_finished.emit(race_position)

func reset_race():
	score = 0
	lap_count = 0
	race_position = 1
	race_time = 0.0
	drift_score = 0
	knockouts = 0

func reset_all():
	reset_race()
	current_state = GameState.MENU

func get_kart_color() -> Color:
	if selected_kart_class in kart_classes:
		return kart_classes[selected_kart_class].color
	return Color(0.0, 1.0, 1.0)

func get_special_ability() -> String:
	if selected_kart_class in kart_classes:
		return kart_classes[selected_kart_class].special
	return "pulse_shield"