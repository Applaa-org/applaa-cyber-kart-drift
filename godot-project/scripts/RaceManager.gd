extends Node
class_name RaceManager

signal race_countdown_tick(count: int)
signal race_started()
signal race_finished()
signal position_updated(positions: Array)
signal lap_updated(racer: Node, lap: int)

enum RaceState { WAITING, COUNTDOWN, RACING, FINISHED }
var current_state: RaceState = RaceState.WAITING

# Race Configuration
var total_laps: int = 3
var total_checkpoints: int = 0
var race_mode: String = "standard"

# Racers
var all_racers: Array = []
var player_kart: PlayerKart
var ai_karts: Array[AIKart] = []

# Timing
var countdown_timer: float = 0.0
var countdown_value: int = 3
var race_time: float = 0.0
var update_position_timer: float = 0.0

# Results
var finished_racers: Array = []
var race_positions: Array = []

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	match current_state:
		RaceState.COUNTDOWN:
			process_countdown(delta)
		RaceState.RACING:
			process_racing(delta)
		RaceState.FINISHED:
			pass

func process_countdown(delta: float) -> void:
	countdown_timer -= delta
	
	if countdown_timer <= 0:
		countdown_value -= 1
		race_countdown_tick.emit(countdown_value)
		AudioManager.play_countdown_beep(countdown_value == 0)
		
		if countdown_value <= 0:
			start_race()
		else:
			countdown_timer = 1.0

func process_racing(delta: float) -> void:
	race_time += delta
	
	# Update positions periodically
	update_position_timer -= delta
	if update_position_timer <= 0:
		update_positions()
		update_position_timer = 0.2

func setup_race(track_data: Dictionary, racers: Array) -> void:
	all_racers = racers
	total_laps = track_data.get("laps", 3)
	total_checkpoints = track_data.get("checkpoints", 5)
	race_mode = Global.current_mode
	
	# Separate player and AI
	for racer in all_racers:
		if racer is PlayerKart:
			player_kart = racer
		elif racer is AIKart:
			ai_karts.append(racer)
	
	# Connect signals
	for racer in all_racers:
		if racer.has_signal("lap_completed"):
			racer.lap_completed.connect(_on_racer_lap_completed.bind(racer))

func begin_countdown() -> void:
	current_state = RaceState.COUNTDOWN
	countdown_value = 3
	countdown_timer = 1.0
	race_countdown_tick.emit(countdown_value)
	AudioManager.play_countdown_beep()

func start_race() -> void:
	current_state = RaceState.RACING
	race_time = 0.0
	finished_racers.clear()
	
	for racer in all_racers:
		if racer.has_method("start_race"):
			racer.start_race()
	
	race_started.emit()

func update_positions() -> void:
	# Calculate progress for each racer
	var racer_progress: Array = []
	
	for racer in all_racers:
		if racer in finished_racers:
			continue
		
		var progress = calculate_racer_progress(racer)
		racer_progress.append({
			"racer": racer,
			"progress": progress
		})
	
	# Sort by progress (highest first)
	racer_progress.sort_custom(func(a, b): return a.progress > b.progress)
	
	# Assign positions (accounting for finished racers)
	var position = finished_racers.size() + 1
	race_positions.clear()
	
	for item in racer_progress:
		item.racer.race_position = position
		race_positions.append(item.racer)
		position += 1
	
	position_updated.emit(race_positions)

func calculate_racer_progress(racer: Node) -> float:
	# Progress = laps * 1000 + checkpoints * 100 + distance to next checkpoint
	var lap_progress = racer.current_lap * 1000.0
	var checkpoint_progress = racer.current_checkpoint * 100.0
	
	# Estimate distance progress (0-99)
	var distance_progress = 50.0  # Would calculate actual distance
	
	return lap_progress + checkpoint_progress + distance_progress

func _on_racer_lap_completed(lap: int, racer: Node) -> void:
	lap_updated.emit(racer, lap)
	
	# Check if race finished
	if lap >= total_laps:
		racer_finished(racer)

func racer_finished(racer: Node) -> void:
	if racer in finished_racers:
		return
	
	var position = finished_racers.size() + 1
	finished_racers.append(racer)
	
	if racer.has_method("finish_race"):
		racer.finish_race(position)
	
	# Check if all racers finished or player finished
	if racer == player_kart:
		Global.player_position = position
		Global.player_race_time = race_time
		Global.player_drift_score = player_kart.total_drift_score
	
	# End race when player finishes or all finish
	if racer == player_kart or finished_racers.size() >= all_racers.size():
		end_race()

func end_race() -> void:
	current_state = RaceState.FINISHED
	
	# Compile results
	Global.race_results.clear()
	
	var position = 1
	for racer in finished_racers:
		Global.race_results.append({
			"position": position,
			"name": racer.name,
			"time": racer.race_time,
			"is_player": racer == player_kart
		})
		position += 1
	
	# Add unfinished racers
	for racer in all_racers:
		if racer not in finished_racers:
			Global.race_results.append({
				"position": position,
				"name": racer.name,
				"time": -1,
				"is_player": racer == player_kart
			})
			position += 1
	
	race_finished.emit()

func get_player_position() -> int:
	if player_kart:
		return player_kart.race_position
	return 0

func get_race_time() -> float:
	return race_time

func get_player_lap() -> int:
	if player_kart:
		return player_kart.current_lap
	return 0

func format_time(time_seconds: float) -> String:
	var minutes = int(time_seconds) / 60
	var seconds = int(time_seconds) % 60
	var milliseconds = int((time_seconds - int(time_seconds)) * 1000)
	return "%d:%02d.%03d" % [minutes, seconds, milliseconds]

func reset_race() -> void:
	current_state = RaceState.WAITING
	race_time = 0.0
	finished_racers.clear()
	race_positions.clear()
	
	for racer in all_racers:
		if racer.has_method("reset_position"):
			racer.reset_position(Vector2.ZERO, 0)