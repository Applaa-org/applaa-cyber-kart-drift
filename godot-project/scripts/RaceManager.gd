extends Node
class_name RaceManager

# Race State
enum RaceState { COUNTDOWN, RACING, FINISHED, PAUSED }
var current_race_state: RaceState = RaceState.COUNTDOWN

# Race Configuration
var total_laps: int = 3
var race_mode: String = "single_race"
var track_name: String = "neon_skyline_1"

# Racers
var player_kart: PlayerKart
var ai_karts: Array[AIKart] = []
var all_racers: Array = []

# Timing
var countdown_timer: float = 3.0
var race_timer: float = 0.0
var elimination_timer: float = 20.0

# Checkpoints and Track
var checkpoints: Array[Area2D] = []
var finish_line: Area2D
var race_path: Path2D

# Position tracking
var racer_positions: Array = []

# Signals
signal countdown_tick(count: int)
signal race_started()
signal race_finished(results: Array)
signal position_updated(position: int)
signal lap_completed(racer: Node, lap: int)
signal elimination_warning(time_left: float)

func _ready():
	add_to_group("race_manager")

func initialize_race(mode: String, track: String, ai_count: int, laps: int = 3):
	race_mode = mode
	track_name = track
	total_laps = laps
	Global.total_laps = laps
	Global.reset_race()
	
	# Setup racers
	setup_player()
	setup_ai_racers(ai_count)
	
	# Gather all racers
	all_racers = [player_kart] + ai_karts
	
	# Start countdown
	current_race_state = RaceState.COUNTDOWN
	countdown_timer = 3.0
	Global.current_state = Global.GameState.RACING

func setup_player():
	player_kart = get_tree().get_first_node_in_group("player") as PlayerKart
	if player_kart:
		player_kart.lap_completed.connect(_on_player_lap_completed)

func setup_ai_racers(count: int):
	ai_karts.clear()
	
	var difficulty_map = {<applaa-write path="godot-project/scripts/RaceManager.gd" description="Race manager handling game modes, positions, and race flow">
extends Node
class_name RaceManager

# Race State
enum RaceState { COUNTDOWN, RACING, FINISHED, PAUSED }
var current_race_state: RaceState = RaceState.COUNTDOWN

# Race Configuration
var total_laps: int = 3
var race_mode: String = "single_race"
var track_name: String = "neon_skyline_1"

# Racers
var player_kart: PlayerKart
var ai_karts: Array[AIKart] = []
var all_racers: Array = []

# Timing
var countdown_timer: float = 3.0
var race_timer: float = 0.0
var elimination_timer: float = 20.0

# Checkpoints and Track
var checkpoints: Array[Area2D] = []
var finish_line: Area2D
var race_path: Path2D

# Position tracking
var racer_positions: Array = []

# Signals
signal countdown_tick(count: int)
signal race_started()
signal race_finished(results: Array)
signal position_updated(position: int)
signal lap_completed(racer: Node, lap: int)
signal elimination_warning(time_left: float)

func _ready():
	add_to_group("race_manager")

func initialize_race(mode: String, track: String, ai_count: int, laps: int = 3):
	race_mode = mode
	track_name = track
	total_laps = laps
	Global.total_laps = laps
	Global.reset_race()
	
	# Setup racers
	setup_player()
	setup_ai_racers(ai_count)
	
	# Gather all racers
	all_racers = [player_kart] + ai_karts
	
	# Start countdown
	current_race_state = RaceState.COUNTDOWN
	countdown_timer = 3.0
	Global.current_state = Global.GameState.RACING

func setup_player():
	player_kart = get_tree().get_first_node_in_group("player") as PlayerKart
	if player_kart:
		player_kart.lap_completed.connect(_on_player_lap_completed)

func setup_ai_racers(count: int):
	ai_karts.clear()
	
	var difficulty_map = {
		"easy": AIKart.AIDifficulty.EASY,
		"medium": AIKart.AIDifficulty.MEDIUM,
		"hard": AIKart.AIDifficulty.HARD,
		"extreme": AIKart.AIDifficulty.EXTREME
	}
	
	var ai_difficulty = difficulty_map.get(Global.ai_difficulty, AIKart.AIDifficulty.MEDIUM)
	
	for ai_node in get_tree().get_nodes_in_group("ai_karts"):
		var ai = ai_node as AIKart
		if ai:
			ai.difficulty = ai_difficulty
			ai.ai_destroyed.connect(_on_ai_destroyed)
			ai_karts.append(ai)
			
			if race_path:
				ai.set_race_path(race_path)

func _process(delta: float):
	match current_race_state:
		RaceState.COUNTDOWN:
			process_countdown(delta)
		RaceState.RACING:
			process_racing(delta)
		RaceState.PAUSED:
			pass
		RaceState.FINISHED:
			pass

func process_countdown(delta: float):
	var prev_count = int(countdown_timer)
	countdown_timer -= delta
	var new_count = int(countdown_timer)
	
	if new_count != prev_count and new_count >= 0:
		countdown_tick.emit(new_count)
		AudioManager.play_countdown_beep(new_count)
	
	if countdown_timer <= 0:
		current_race_state = RaceState.RACING
		race_started.emit()
		AudioManager.play_countdown_beep(0)  # GO!

func process_racing(delta: float):
	race_timer += delta
	Global.race_time = race_timer
	
	# Update positions
	update_race_positions()
	
	# Handle elimination mode
	if race_mode == "elimination":
		process_elimination(delta)
	
	# Check for race completion
	check_race_completion()

func update_race_positions():
	# Calculate progress for each racer
	racer_positions.clear()
	
	for racer in all_racers:
		if racer and is_instance_valid(racer):
			var progress = racer.get_race_progress()
			racer_positions.append({
				"racer": racer,
				"progress": progress
			})
	
	# Sort by progress (highest first)
	racer_positions.sort_custom(func(a, b): return a.progress > b.progress)
	
	# Update position for each racer
	for i in range(racer_positions.size()):
		var racer = racer_positions[i].racer
		racer.race_position = i + 1
		
		if racer == player_kart:
			Global.race_position = i + 1
			position_updated.emit(i + 1)

func process_elimination(delta: float):
	elimination_timer -= delta
	
	if elimination_timer <= 5.0:
		elimination_warning.emit(elimination_timer)
	
	if elimination_timer <= 0:
		elimination_timer = 20.0
		eliminate_last_place()

func eliminate_last_place():
	if racer_positions.size() > 1:
		var last_racer = racer_positions[racer_positions.size() - 1].racer
		
		if last_racer == player_kart:
			# Player eliminated
			end_race_defeat()
		else:
			# Eliminate AI
			var ai = last_racer as AIKart
			if ai:
				ai.on_destroyed()
				all_racers.erase(ai)

func check_race_completion():
	# Check if player finished
	if Global.lap_count >= total_laps:
		end_race_victory()

func _on_player_lap_completed():
	lap_completed.emit(player_kart, Global.lap_count)
	
	if Global.lap_count >= total_laps:
		end_race_victory()
	elif Global.lap_count == total_laps - 1:
		AudioManager.set_final_lap(true)

func _on_ai_destroyed(ai: AIKart):
	ai_karts.erase(ai)
	all_racers.erase(ai)
	Global.knockouts += 1
	Global.add_score(50)

func end_race_victory():
	current_race_state = RaceState.FINISHED
	
	# Calculate final results
	var results = []
	for i in range(racer_positions.size()):
		results.append({
			"position": i + 1,
			"racer": racer_positions[i].racer,
			"time": race_timer if racer_positions[i].racer == player_kart else race_timer + randf_range(0.5, 5.0)
		})
	
	# Award based on position
	var position_rewards = [500, 300, 200, 100, 50, 25, 10, 5]
	if Global.race_position <= position_rewards.size():
		Global.add_credits(position_rewards[Global.race_position - 1])
	
	Global.add_xp(100 + (8 - Global.race_position) * 20)
	
	AudioManager.play_victory_fanfare()
	race_finished.emit(results)
	
	# Change to victory screen after delay
	get_tree().create_timer(2.0).timeout.connect(func():
		get_tree().change_scene_to_file("res://scenes/VictoryScreen.tscn")
	)

func end_race_defeat():
	current_race_state = RaceState.FINISHED
	Global.current_state = Global.GameState.DEFEAT
	
	AudioManager.play_defeat_sound()
	
	get_tree().create_timer(1.5).timeout.connect(func():
		get_tree().change_scene_to_file("res://scenes/DefeatScreen.tscn")
	)

func pause_race():
	if current_race_state == RaceState.RACING:
		current_race_state = RaceState.PAUSED
		get_tree().paused = true

func resume_race():
	if current_race_state == RaceState.PAUSED:
		current_race_state = RaceState.RACING
		get_tree().paused = false

func restart_race():
	Global.reset_race()
	get_tree().reload_current_scene()

func set_race_path(path: Path2D):
	race_path = path
	for ai in ai_karts:
		ai.set_race_path(path)

func register_checkpoint(checkpoint: Area2D, index: int):
	while checkpoints.size() <= index:
		checkpoints.append(null)
	checkpoints[index] = checkpoint

func register_finish_line(line: Area2D):
	finish_line = line

func get_race_time_formatted() -> String:
	var minutes = int(race_timer / 60)
	var seconds = int(race_timer) % 60
	var milliseconds = int((race_timer - int(race_timer)) * 100)
	return "%02d:%02d.%02d" % [minutes, seconds, milliseconds]

func get_position_suffix(pos: int) -> String:
	match pos:
		1: return "st"
		2: return "nd"
		3: return "rd"
		_: return "th"