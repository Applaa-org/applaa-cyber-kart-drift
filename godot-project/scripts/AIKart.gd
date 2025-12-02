extends CharacterBody2D
class_name AIKart

# AI Configuration
enum AIPersonality { AGGRESSIVE, DEFENSIVE, DRIFTER, SPEEDSTER }
var personality: AIPersonality = AIPersonality.AGGRESSIVE
var difficulty: String = "medium"

# Kart Stats
var max_speed: float = 420.0
var acceleration: float = 240.0
var handling: float = 0.75
var boost_power: float = 1.0

# Current State
var current_speed: float = 0.0
var steering_angle: float = 0.0
var health: int = 100
var max_health: int = 100

# Boost System
var boost_meter: float = 0.0
var max_boost: float = 100.0
var is_boosting: bool = false
var boost_disabled: bool = false
var boost_disabled_timer: float = 0.0

# Drift System
var is_drifting: bool = false
var drift_direction: int = 0
var drift_angle: float = 0.0

# Weapon System
var current_weapon: String = ""
var weapon_count: int = 0
var weapon_cooldown: float = 0.0

# Race State
var current_lap: int = 0
var current_checkpoint: int = 0
var race_position: int = 1
var race_time: float = 0.0
var is_racing: bool = false
var finished_race: bool = false

# AI Navigation
var waypoints: Array[Vector2] = []
var current_waypoint_index: int = 0
var target_position: Vector2 = Vector2.ZERO
var stuck_timer: float = 0.0
var last_position: Vector2 = Vector2.ZERO

# Visual
var kart_color: Color = Color(1.0, 0.3, 0.3)
var hover_offset: float = 0.0
var hover_time: float = 0.0

@onready var kart_body: Node2D = $KartBody

func _ready() -> void:
	add_to_group("karts")
	add_to_group("ai_karts")
	randomize_personality()
	apply_difficulty_modifiers()

func randomize_personality() -> void:
	var rand = randi() % 4
	personality = rand as AIPersonality
	
	match personality:
		AIPersonality.AGGRESSIVE:
			kart_color = Color(1.0, 0.2, 0.2)
		AIPersonality.DEFENSIVE:
			kart_color = Color(0.2, 0.5, 1.0)
		AIPersonality.DRIFTER:
			kart_color = Color(0.2, 1.0, 0.5)
		AIPersonality.SPEEDSTER:
			kart_color = Color(1.0, 1.0, 0.2)

func apply_difficulty_modifiers() -> void:
	match difficulty:
		"easy":
			max_speed *= 0.85
			acceleration *= 0.8
			handling *= 0.7
		"medium":
			max_speed *= 0.95
			acceleration *= 0.9
			handling *= 0.85
		"hard":
			max_speed *= 1.0
			acceleration *= 1.0
			handling *= 0.95
		"extreme":
			max_speed *= 1.05
			acceleration *= 1.05
			handling *= 1.0

func _physics_process(delta: float) -> void:
	if not is_racing or finished_race:
		return
	
	race_time += delta
	
	# Update timers
	update_timers(delta)
	
	# AI decision making
	update_ai_behavior(delta)
	
	# Update physics
	update_movement(delta)
	
	# Update visuals
	update_visuals(delta)
	
	# Move
	move_and_slide()
	
	# Check if stuck
	check_stuck(delta)

func update_timers(delta: float) -> void:
	if boost_disabled:
		boost_disabled_timer -= delta
		if boost_disabled_timer <= 0:
			boost_disabled = false
	
	if weapon_cooldown > 0:
		weapon_cooldown -= delta

func update_ai_behavior(delta: float) -> void:
	if waypoints.is_empty():
		return
	
	# Get current target waypoint
	target_position = waypoints[current_waypoint_index]
	
	# Calculate direction to waypoint
	var direction_to_target = (target_position - global_position).normalized()
	var angle_to_target = direction_to_target.angle()
	var angle_diff = angle_difference(rotation, angle_to_target)
	
	# Steering
	var target_steering = clamp(angle_diff * 2.0, -handling * 3.0, handling * 3.0)
	steering_angle = lerp(steering_angle, target_steering, delta * 4.0)
	
	# Decide whether to drift
	var should_drift = abs(angle_diff) > 0.5 and current_speed > max_speed * 0.5
	if personality == AIPersonality.DRIFTER:
		should_drift = abs(angle_diff) > 0.3 and current_speed > max_speed * 0.4
	
	if should_drift and not is_drifting:
		start_drift(sign(angle_diff) as int)
	elif not should_drift and is_drifting:
		end_drift()
	
	# Acceleration decision
	var distance_to_waypoint = global_position.distance_to(target_position)
	var should_brake = distance_to_waypoint < 100 and abs(angle_diff) > 0.8
	
	if should_brake:
		current_speed -= acceleration * 1.2 * delta
	else:
		current_speed += acceleration * delta
	
	# Boost decision
	decide_boost(delta)
	
	# Weapon decision
	decide_weapon(delta)
	
	# Check waypoint reached
	if distance_to_waypoint < 80:
		current_waypoint_index = (current_waypoint_index + 1) % waypoints.size()

func decide_boost(delta: float) -> void:
	if boost_disabled or boost_meter < 30:
		is_boosting = false
		return
	
	var should_boost = false
	
	match personality:
		AIPersonality.AGGRESSIVE:
			# Boost when chasing or ahead
			should_boost = boost_meter > 50
		AIPersonality.DEFENSIVE:
			# Boost to escape danger
			should_boost = boost_meter > 80
		AIPersonality.DRIFTER:
			# Boost after drifts
			should_boost = not is_drifting and boost_meter > 40
		AIPersonality.SPEEDSTER:
			# Always boost when possible
			should_boost = boost_meter > 30
	
	if should_boost and not is_boosting:
		is_boosting = true
	elif is_boosting and boost_meter < 10:
		is_boosting = false
	
	# Drain boost
	if is_boosting:
		boost_meter = max(0, boost_meter - 25.0 * delta)

func decide_weapon(delta: float) -> void:
	if current_weapon == "" or weapon_count <= 0 or weapon_cooldown > 0:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	var direction_to_player = (player.global_position - global_position).normalized()
	var facing_player = direction_to_player.dot(Vector2.RIGHT.rotated(rotation)) > 0.7
	
	var should_fire = false
	
	match personality:
		AIPersonality.AGGRESSIVE:
			should_fire = distance_to_player < 400 and facing_player
		AIPersonality.DEFENSIVE:
			# Use defensive items or fire when safe
			if current_weapon in ["pulse_shield", "nano_repair"]:
				should_fire = health < 70
			else:
				should_fire = distance_to_player < 200
		AIPersonality.DRIFTER:
			should_fire = distance_to_player < 300 and facing_player
		AIPersonality.SPEEDSTER:
			should_fire = distance_to_player < 350
	
	if should_fire:
		fire_weapon()
		weapon_cooldown = 2.0

func update_movement(delta: float) -> void:
	# Apply steering
	var steer_modifier = 0.6 if is_drifting else 1.0
	rotation += steering_angle * steer_modifier * delta
	
	# Apply drift angle
	if is_drifting:
		drift_angle = lerp(drift_angle, drift_direction * 0.35, delta * 3.0)
		boost_meter = min(boost_meter + 12.0 * delta, max_boost)
	else:
		drift_angle = lerp(drift_angle, 0.0, delta * 5.0)
	
	# Calculate effective max speed
	var effective_max_speed = max_speed
	if is_boosting and not boost_disabled:
		effective_max_speed *= (1.0 + boost_power * 0.4)
	
	current_speed = clamp(current_speed, 0, effective_max_speed)
	
	# Apply velocity
	var move_direction = Vector2.RIGHT.rotated(rotation)
	var drift_offset = Vector2.RIGHT.rotated(rotation + drift_angle * 0.5)
	velocity = move_direction.lerp(drift_offset, abs(drift_angle)) * current_speed

func update_visuals(delta: float) -> void:
	hover_time += delta * 3.0
	hover_offset = sin(hover_time) * 2.5
	
	if kart_body:
		kart_body.position.y = hover_offset
		kart_body.rotation = -steering_angle * 0.08

func check_stuck(delta: float) -> void:
	if global_position.distance_to(last_position) < 5:
		stuck_timer += delta
		if stuck_timer > 2.0:
			unstuck()
	else:
		stuck_timer = 0
	
	last_position = global_position

func unstuck() -> void:
	# Teleport to nearest waypoint
	if not waypoints.is_empty():
		var nearest_dist = INF
		var nearest_idx = 0
		for i in range(waypoints.size()):
			var dist = global_position.distance_to(waypoints[i])
			if dist < nearest_dist:
				nearest_dist = dist
				nearest_idx = i
		
		current_waypoint_index = nearest_idx
		position = waypoints[nearest_idx] - Vector2(50, 0).rotated(rotation)
		current_speed = max_speed * 0.5
	
	stuck_timer = 0

func start_drift(direction: int) -> void:
	is_drifting = true
	drift_direction = direction

func end_drift() -> void:
	is_drifting = false
	drift_direction = 0

func fire_weapon() -> void:
	if current_weapon == "" or weapon_count <= 0:
		return
	
	weapon_count -= 1
	AudioManager.play_weapon_sound(current_weapon)
	
	# Weapon effect would be spawned here
	
	if weapon_count <= 0:
		current_weapon = ""

func pickup_weapon(weapon_id: String) -> void:
	current_weapon = weapon_id
	weapon_count = 1

func take_damage(amount: int, source: Node = null) -> void:
	health -= amount
	
	if health <= 0:
		handle_destruction()

func handle_destruction() -> void:
	health = max_health
	current_speed = 0
	boost_meter = 0

func apply_emp(duration: float) -> void:
	boost_disabled = true
	boost_disabled_timer = duration
	is_boosting = false

func hit_boost_pad(boost_amount: float) -> void:
	boost_meter = min(boost_meter + boost_amount, max_boost)
	current_speed = min(current_speed + 80, max_speed * 1.15)

func pass_checkpoint(checkpoint_id: int) -> void:
	if checkpoint_id == current_checkpoint + 1 or (checkpoint_id == 0 and current_checkpoint == -1):
		current_checkpoint = checkpoint_id

func complete_lap() -> void:
	current_lap += 1
	current_checkpoint = 0
	boost_meter = min(boost_meter + 25, max_boost)

func finish_race(final_position: int) -> void:
	finished_race = true
	race_position = final_position

func start_race() -> void:
	is_racing = true<applaa-write path="godot-project/scripts/AIKart.gd" description="AI-controlled kart with adaptive racing behavior">
extends CharacterBody2D
class_name AIKart

# AI Configuration
enum AIPersonality { AGGRESSIVE, DEFENSIVE, DRIFTER, SPEEDSTER }
var personality: AIPersonality = AIPersonality.AGGRESSIVE
var difficulty: String = "medium"

# Kart Stats
var max_speed: float = 420.0
var acceleration: float = 240.0
var handling: float = 0.75
var boost_power: float = 1.0

# Current State
var current_speed: float = 0.0
var steering_angle: float = 0.0
var health: int = 100
var max_health: int = 100

# Boost System
var boost_meter: float = 0.0
var max_boost: float = 100.0
var is_boosting: bool = false
var boost_disabled: bool = false
var boost_disabled_timer: float = 0.0

# Drift System
var is_drifting: bool = false
var drift_direction: int = 0
var drift_angle: float = 0.0

# Weapon System
var current_weapon: String = ""
var weapon_count: int = 0
var weapon_cooldown: float = 0.0

# Race State
var current_lap: int = 0
var current_checkpoint: int = 0
var race_position: int = 1
var race_time: float = 0.0
var is_racing: bool = false
var finished_race: bool = false

# AI Navigation
var waypoints: Array[Vector2] = []
var current_waypoint_index: int = 0
var target_position: Vector2 = Vector2.ZERO
var stuck_timer: float = 0.0
var last_position: Vector2 = Vector2.ZERO

# Visual
var kart_color: Color = Color(1.0, 0.3, 0.3)
var hover_offset: float = 0.0
var hover_time: float = 0.0

@onready var kart_body: Node2D = $KartBody

func _ready() -> void:
	add_to_group("karts")
	add_to_group("ai_karts")
	randomize_personality()
	apply_difficulty_modifiers()

func randomize_personality() -> void:
	var rand = randi() % 4
	personality = rand as AIPersonality
	
	match personality:
		AIPersonality.AGGRESSIVE:
			kart_color = Color(1.0, 0.2, 0.2)
		AIPersonality.DEFENSIVE:
			kart_color = Color(0.2, 0.5, 1.0)
		AIPersonality.DRIFTER:
			kart_color = Color(0.2, 1.0, 0.5)
		AIPersonality.SPEEDSTER:
			kart_color = Color(1.0, 1.0, 0.2)

func apply_difficulty_modifiers() -> void:
	match difficulty:
		"easy":
			max_speed *= 0.85
			acceleration *= 0.8
			handling *= 0.7
		"medium":
			max_speed *= 0.95
			acceleration *= 0.9
			handling *= 0.85
		"hard":
			max_speed *= 1.0
			acceleration *= 1.0
			handling *= 0.95
		"extreme":
			max_speed *= 1.05
			acceleration *= 1.05
			handling *= 1.0

func _physics_process(delta: float) -> void:
	if not is_racing or finished_race:
		return
	
	race_time += delta
	
	# Update timers
	update_timers(delta)
	
	# AI decision making
	update_ai_behavior(delta)
	
	# Update physics
	update_movement(delta)
	
	# Update visuals
	update_visuals(delta)
	
	# Move
	move_and_slide()
	
	# Check if stuck
	check_stuck(delta)

func update_timers(delta: float) -> void:
	if boost_disabled:
		boost_disabled_timer -= delta
		if boost_disabled_timer <= 0:
			boost_disabled = false
	
	if weapon_cooldown > 0:
		weapon_cooldown -= delta

func update_ai_behavior(delta: float) -> void:
	if waypoints.is_empty():
		return
	
	# Get current target waypoint
	target_position = waypoints[current_waypoint_index]
	
	# Calculate direction to waypoint
	var direction_to_target = (target_position - global_position).normalized()
	var angle_to_target = direction_to_target.angle()
	var angle_diff = angle_difference(rotation, angle_to_target)
	
	# Steering
	var target_steering = clamp(angle_diff * 2.0, -handling * 3.0, handling * 3.0)
	steering_angle = lerp(steering_angle, target_steering, delta * 4.0)
	
	# Decide whether to drift
	var should_drift = abs(angle_diff) > 0.5 and current_speed > max_speed * 0.5
	if personality == AIPersonality.DRIFTER:
		should_drift = abs(angle_diff) > 0.3 and current_speed > max_speed * 0.4
	
	if should_drift and not is_drifting:
		start_drift(sign(angle_diff) as int)
	elif not should_drift and is_drifting:
		end_drift()
	
	# Acceleration decision
	var distance_to_waypoint = global_position.distance_to(target_position)
	var should_brake = distance_to_waypoint < 100 and abs(angle_diff) > 0.8
	
	if should_brake:
		current_speed -= acceleration * 1.2 * delta
	else:
		current_speed += acceleration * delta
	
	# Boost decision
	decide_boost(delta)
	
	# Weapon decision
	decide_weapon(delta)
	
	# Check waypoint reached
	if distance_to_waypoint < 80:
		current_waypoint_index = (current_waypoint_index + 1) % waypoints.size()

func decide_boost(delta: float) -> void:
	if boost_disabled or boost_meter < 30:
		is_boosting = false
		return
	
	var should_boost = false
	
	match personality:
		AIPersonality.AGGRESSIVE:
			should_boost = boost_meter > 50
		AIPersonality.DEFENSIVE:
			should_boost = boost_meter > 80
		AIPersonality.DRIFTER:
			should_boost = not is_drifting and boost_meter > 40
		AIPersonality.SPEEDSTER:
			should_boost = boost_meter > 30
	
	if should_boost and not is_boosting:
		is_boosting = true
	elif is_boosting and boost_meter < 10:
		is_boosting = false
	
	if is_boosting:
		boost_meter = max(0, boost_meter - 25.0 * delta)

func decide_weapon(delta: float) -> void:
	if current_weapon == "" or weapon_count <= 0 or weapon_cooldown > 0:
		return
	
	var player = get_tree().get_first_node_in_group("player")
	if not player:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	var direction_to_player = (player.global_position - global_position).normalized()
	var facing_player = direction_to_player.dot(Vector2.RIGHT.rotated(rotation)) > 0.7
	
	var should_fire = false
	
	match personality:
		AIPersonality.AGGRESSIVE:
			should_fire = distance_to_player < 400 and facing_player
		AIPersonality.DEFENSIVE:
			if current_weapon in ["pulse_shield", "nano_repair"]:
				should_fire = health < 70
			else:
				should_fire = distance_to_player < 200
		AIPersonality.DRIFTER:
			should_fire = distance_to_player < 300 and facing_player
		AIPersonality.SPEEDSTER:
			should_fire = distance_to_player < 350
	
	if should_fire:
		fire_weapon()
		weapon_cooldown = 2.0

func update_movement(delta: float) -> void:
	var steer_modifier = 0.6 if is_drifting else 1.0
	rotation += steering_angle * steer_modifier * delta
	
	if is_drifting:
		drift_angle = lerp(drift_angle, drift_direction * 0.35, delta * 3.0)
		boost_meter = min(boost_meter + 12.0 * delta, max_boost)
	else:
		drift_angle = lerp(drift_angle, 0.0, delta * 5.0)
	
	var effective_max_speed = max_speed
	if is_boosting and not boost_disabled:
		effective_max_speed *= (1.0 + boost_power * 0.4)
	
	current_speed = clamp(current_speed, 0, effective_max_speed)
	
	var move_direction = Vector2.RIGHT.rotated(rotation)
	var drift_offset = Vector2.RIGHT.rotated(rotation + drift_angle * 0.5)
	velocity = move_direction.lerp(drift_offset, abs(drift_angle)) * current_speed

func update_visuals(delta: float) -> void:
	hover_time += delta * 3.0
	hover_offset = sin(hover_time) * 2.5
	
	if kart_body:
		kart_body.position.y = hover_offset
		kart_body.rotation = -steering_angle * 0.08

func check_stuck(delta: float) -> void:
	if global_position.distance_to(last_position) < 5:
		stuck_timer += delta
		if stuck_timer > 2.0:
			unstuck()
	else:
		stuck_timer = 0
	
	last_position = global_position

func unstuck() -> void:
	if not waypoints.is_empty():
		var nearest_dist = INF
		var nearest_idx = 0
		for i in range(waypoints.size()):
			var dist = global_position.distance_to(waypoints[i])
			if dist < nearest_dist:
				nearest_dist = dist
				nearest_idx = i
		
		current_waypoint_index = nearest_idx
		position = waypoints[nearest_idx] - Vector2(50, 0).rotated(rotation)
		current_speed = max_speed * 0.5
	
	stuck_timer = 0

func start_drift(direction: int) -> void:
	is_drifting = true
	drift_direction = direction

func end_drift() -> void:
	is_drifting = false
	drift_direction = 0

func fire_weapon() -> void:
	if current_weapon == "" or weapon_count <= 0:
		return
	
	weapon_count -= 1
	AudioManager.play_weapon_sound(current_weapon)
	
	if weapon_count <= 0:
		current_weapon = ""

func pickup_weapon(weapon_id: String) -> void:
	current_weapon = weapon_id
	weapon_count = 1

func take_damage(amount: int, source: Node = null) -> void:
	health -= amount
	
	if health <= 0:
		handle_destruction()

func handle_destruction() -> void:
	health = max_health
	current_speed = 0
	boost_meter = 0

func apply_emp(duration: float) -> void:
	boost_disabled = true
	boost_disabled_timer = duration
	is_boosting = false

func hit_boost_pad(boost_amount: float) -> void:
	boost_meter = min(boost_meter + boost_amount, max_boost)
	current_speed = min(current_speed + 80, max_speed * 1.15)

func pass_checkpoint(checkpoint_id: int) -> void:
	if checkpoint_id == current_checkpoint + 1 or (checkpoint_id == 0 and current_checkpoint == -1):
		current_checkpoint = checkpoint_id

func complete_lap() -> void:
	current_lap += 1
	current_checkpoint = 0
	boost_meter = min(boost_meter + 25, max_boost)

func finish_race(final_position: int) -> void:
	finished_race = true
	race_position = final_position

func start_race() -> void:
	is_racing = true
	finished_race = false
	current_lap = 0
	current_checkpoint = 0
	race_time = 0.0
	health = max_health
	boost_meter = 0
	current_weapon = ""
	weapon_count = 0

func set_waypoints(new_waypoints: Array[Vector2]) -> void:
	waypoints = new_waypoints
	current_waypoint_index = 0

func set_difficulty(new_difficulty: String) -> void:
	difficulty = new_difficulty
	apply_difficulty_modifiers()

func reset_position(spawn_position: Vector2, spawn_rotation: float) -> void:
	position = spawn_position
	rotation = spawn_rotation
	current_speed = 0
	velocity = Vector2.ZERO
	stuck_timer = 0