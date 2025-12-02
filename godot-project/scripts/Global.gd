extends Node

# Game State
enum GameState { MENU, RACING, PAUSED, RESULTS, GARAGE }
var current_state: GameState = GameState.MENU

# Race Settings
var current_track: String = "neon_skyline_1"
var current_mode: String = "single_race"
var lap_count: int = 3
var ai_count: int = 5
var difficulty: String = "medium"

# Player Data
var player_name: String = "Racer"
var player_level: int = 1
var player_xp: int = 0
var credits: int = 1000
var holo_tokens: int = 50
var data_shards: int = 10

# Selected Kart
var selected_kart_class: String = "balanced"
var selected_kart_color: Color = Color(0.0, 0.8, 1.0)
var selected_underglow: Color = Color(1.0, 0.0, 0.5)
var selected_trail_type: int = 0

# Kart Stats (base values modified by class)
var kart_classes: Dictionary = {
	"speedster": {
		"name": "Speedster",
		"max_speed": 550.0,
		"acceleration": 280.0,
		"handling": 0.65,
		"boost_power": 1.3,
		"drift_bonus": 0.9,
		"special": "quantum_boost",
		"description": "Maximum velocity, minimum stability"
	},
	"bruiser": {
		"name": "Bruiser",
		"max_speed": 380.0,
		"acceleration": 200.0,
		"handling": 0.5,
		"boost_power": 0.8,
		"drift_bonus": 0.7,
		"special": "armor_wall",
		"description": "Heavy armor, devastating rams"
	},
	"balanced": {
		"name": "Balanced",
		"max_speed": 450.0,
		"acceleration": 250.0,
		"handling": 0.8,
		"boost_power": 1.0,
		"drift_bonus": 1.0,
		"special": "pulse_shield",
		"description": "Jack of all trades"
	},
	"technical": {
		"name": "Technical",
		"max_speed": 420.0,
		"acceleration": 270.0,
		"handling": 1.0,
		"boost_power": 1.1,
		"drift_bonus": 1.3,
		"special": "teleport_dash",
		"description": "Drift master, precision handling"
	},
	"experimental": {
		"name": "Experimental",
		"max_speed": 500.0,
		"acceleration": 320.0,
		"handling": 0.55,
		"boost_power": 1.5,
		"drift_bonus": 1.1,
		"special": "weapon_jam",
		"description": "Unstable but powerful"
	}
}

# Weapons Data
var weapons: Dictionary = {
	"plasma_missile": {
		"name": "Plasma Missile",
		"type": "offensive",
		"damage": 30,
		"homing": true,
		"speed": 600.0
	},
	"emp_blast": {
		"name": "EMP Blast",
		"type": "offensive",
		"damage": 0,
		"effect": "disable_boost",
		"duration": 3.0,
		"radius": 150.0
	},
	"arc_shot": {
		"name": "Arc Shot",
		"type": "offensive",
		"damage": 20,
		"chain_count": 3,
		"chain_range": 200.0
	},
	"shockwave_mine": {
		"name": "Shockwave Mine",
		"type": "offensive",
		"damage": 25,
		"push_force": 400.0
	},
	"inferno_rocket": {
		"name": "Inferno Rocket",
		"type": "offensive",
		"damage": 40,
		"speed": 800.0,
		"trail_damage": 10
	},
	"pulse_shield": {
		"name": "Pulse Shield",
		"type": "defensive",
		"absorb_count": 2,
		"duration": 5.0
	},
	"reflector_orb": {
		"name": "Reflector Orb",
		"type": "defensive",
		"reflect": true,
		"duration": 3.0
	},
	"decoy_drone": {
		"name": "Decoy Drone",
		"type": "defensive",
		"attract_range": 300.0,
		"duration": 4.0
	},
	"nano_repair": {
		"name": "Nano Repair",
		"type": "defensive",
		"heal_amount": 30,
		"heal_rate": 10.0
	}
}

# Track Data
var tracks: Dictionary = {
	"neon_skyline_1": {
		"name": "Night Boulevard",
		"world": "Neon Skyline",
		"difficulty": 1,
		"laps": 3,
		"best_time": 0.0
	},
	"neon_skyline_2": {
		"name": "Hologram Heights",
		"world": "Neon Skyline",
		"difficulty": 2,
		"laps": 3,
		"best_time": 0.0
	},
	"neon_skyline_3": {
		"name": "Sky Tunnel Sprint",
		"world": "Neon Skyline",
		"difficulty": 3,
		"laps": 3,
		"best_time": 0.0
	},
	"solar_canyon_1": {
		"name": "Desert Driftway",
		"world": "Solar Canyon",
		"difficulty": 2,
		"laps": 3,
		"best_time": 0.0
	},
	"frostbyte_1": {
		"name": "Ice Loop Arena",
		"world": "Frostbyte",
		"difficulty": 3,
		"laps": 3,
		"best_time": 0.0
	},
	"quantum_rift_1": {
		"name": "Anomaly Zone",
		"world": "Quantum Rift",
		"difficulty": 4,
		"laps": 3,
		"best_time": 0.0
	},
	"metro_1": {
		"name": "Rail Runner",
		"world": "Overclocked Metro",
		"difficulty": 3,
		"laps": 3,
		"best_time": 0.0
	}
}

# Race Results (temporary storage)
var race_results: Array = []
var player_position: int = 0
var player_race_time: float = 0.0
var player_drift_score: int = 0
var player_knockouts: int = 0

# Unlocks
var unlocked_karts: Array = ["balanced", "speedster"]
var unlocked_tracks: Array = ["neon_skyline_1", "neon_skyline_2"]
var unlocked_weapons: Array = ["plasma_missile", "pulse_shield"]

# Settings
var music_volume: float = 0.8
var sfx_volume: float = 1.0
var screen_shake: bool = true
var show_speedometer: bool = true

# Signals
signal credits_changed(new_amount: int)
signal xp_gained(amount: int)
signal level_up(new_level: int)
signal item_unlocked(item_type: String, item_id: String)

func _ready() -> void:
	load_game_data()

func get_kart_stats() -> Dictionary:
	return kart_classes.get(selected_kart_class, kart_classes["balanced"])

func add_credits(amount: int) -> void:
	credits += amount
	credits_changed.emit(credits)

func spend_credits(amount: int) -> bool:
	if credits >= amount:
		credits -= amount
		credits_changed.emit(credits)
		return true
	return false

func add_xp(amount: int) -> void:
	player_xp += amount
	xp_gained.emit(amount)
	check_level_up()

func check_level_up() -> void:
	var xp_needed = player_level * 500
	while player_xp >= xp_needed:
		player_xp -= xp_needed
		player_level += 1
		level_up.emit(player_level)
		xp_needed = player_level * 500

func unlock_item(item_type: String, item_id: String) -> void:
	match item_type:
		"kart":
			if item_id not in unlocked_karts:
				unlocked_karts.append(item_id)
		"track":
			if item_id not in unlocked_tracks:
				unlocked_tracks.append(item_id)
		"weapon":
			if item_id not in unlocked_weapons:
				unlocked_weapons.append(item_id)
	item_unlocked.emit(item_type, item_id)

func calculate_race_rewards(position: int, drift_score: int, knockouts: int) -> Dictionary:
	var position_credits = [500, 350, 250, 175, 125, 75, 50, 25]
	var base_credits = position_credits[mini(position - 1, 7)]
	var drift_bonus = drift_score / 10
	var knockout_bonus = knockouts * 50
	var total_credits = base_credits + drift_bonus + knockout_bonus
	
	var xp_gain = (9 - position) * 50 + drift_score / 5 + knockouts * 25
	
	return {
		"credits": total_credits,
		"xp": xp_gain,
		"holo_tokens": 1 if position <= 3 else 0,
		"data_shards": knockouts
	}

func reset_race_data() -> void:
	race_results.clear()
	player_position = 0
	player_race_time = 0.0
	player_drift_score = 0
	player_knockouts = 0

func save_game_data() -> void:
	var save_data = {
		"player_name": player_name,
		"player_level": player_level,
		"player_xp": player_xp,
		"credits": credits,
		"holo_tokens": holo_tokens,
		"data_shards": data_shards,
		"selected_kart_class": selected_kart_class,
		"unlocked_karts": unlocked_karts,
		"unlocked_tracks": unlocked_tracks,
		"unlocked_weapons": unlocked_weapons,
		"tracks": tracks,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume
	}
	
	var file = FileAccess.open("user://savegame.dat", FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		file.close()

func load_game_data() -> void:
	if FileAccess.file_exists("user://savegame.dat"):
		var file = FileAccess.open("user://savegame.dat", FileAccess.READ)
		if file:
			var save_data = file.get_var()
			file.close()
			
			if save_data is Dictionary:
				player_name = save_data.get("player_name", "Racer")
				player_level = save_data.get("player_level", 1)
				player_xp = save_data.get("player_xp", 0)
				credits = save_data.get("credits", 1000)
				holo_tokens = save_data.get("holo_tokens", 50)
				data_shards = save_data.get("data_shards", 10)
				selected_kart_class = save_data.get("selected_kart_class", "balanced")
				unlocked_karts = save_data.get("unlocked_karts", ["balanced", "speedster"])
				unlocked_tracks = save_data.get("unlocked_tracks", ["neon_skyline_1", "neon_skyline_2"])
				unlocked_weapons = save_data.get("unlocked_weapons", ["plasma_missile", "pulse_shield"])
				music_volume = save_data.get("music_volume", 0.8)
				sfx_volume = save_data.get("sfx_volume", 1.0)
				
				var saved_tracks = save_data.get("tracks", {})
				for track_id in saved_tracks:
					if track_id in tracks:
						tracks[track_id]["best_time"] = saved_tracks[track_id].get("best_time", 0.0)