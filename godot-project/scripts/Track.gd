extends Node2D
class_name Track

signal checkpoint_passed(racer: Node, checkpoint_id: int)
signal lap_completed(racer: Node)
signal boost_pad_hit(racer: Node)
signal weapon_pickup_collected(racer: Node)

# Track Configuration
@export var track_name: String = "Unnamed Track"
@export var track_world: String = "Neon Skyline"
@export var lap_count: int = 3
@export var checkpoint_count: int = 5

# Track Elements
var checkpoints: Array[Area2D] = []
var boost_pads: Array[Area2D] = []
var weapon_pickups: Array[Area2D] = []
var hazards: Array[Area2D] = []
var spawn_points: Array[Marker2D] = []
var waypoints: Array[Vector2] = []

# Visual Elements
var track_color: Color = Color(0.0, 0.8, 1.0)
var glow_color: Color = Color(1.0, 0.0, 0.5)

func _ready() -> void:
	collect_track_elements()
	setup_connections()

func collect_track_elements() -> void:
	# Collect checkpoints
	if has_node("Checkpoints"):
		for child in $Checkpoints.get_children():
			if child is Area2D:
				checkpoints.append(child)
	
	# Collect boost pads
	if has_node("BoostPads"):
		for child in $BoostPads.get_children():
			if child is Area2D:
				boost_pads.append(child)
	
	# Collect weapon pickups
	if has_node("WeaponPickups"):
		for child in $WeaponPickups.get_children():
			if child is Area2D:
				weapon_pickups.append(child)
	
	# Collect hazards
	if has_node("Hazards"):
		for child in $Hazards.get_children():
			if child is Area2D:
				hazards.append(child)
	
	# Collect spawn points
	if has_node("SpawnPoints"):
		for child in $SpawnPoints.get_children():
			if child is Marker2D:
				spawn_points.append(child)
	
	# Collect waypoints for AI
	if has_node("Waypoints"):
		for child in $Waypoints.get_children():
			if child is Marker2D:
				waypoints.append(child.global_position)

func setup_connections() -> void:
	# Connect checkpoint signals
	for i in range(checkpoints.size()):
		var checkpoint = checkpoints[i]
		checkpoint.body_entered.connect(_on_checkpoint_entered.bind(i))
	
	# Connect boost pad signals
	for boost_pad in boost_pads:
		boost_pad.body_entered.connect(_on_boost_pad_entered)
	
	# Connect weapon pickup signals
	for pickup in weapon_pickups:
		pickup.body_entered.connect(_on_weapon_pickup_entered.bind(pickup))
	
	# Connect hazard signals
	for hazard in hazards:
		hazard.body_entered.connect(_on_hazard_entered.bind(hazard))

func _on_checkpoint_entered(body: Node, checkpoint_id: int) -> void:
	if not body.is_in_group("karts"):
		return
	
	# Check if this is the finish line (checkpoint 0)
	if checkpoint_id == 0:
		# Verify all checkpoints were passed
		if body.current_checkpoint >= checkpoints.size() - 1:
			body.complete_lap()
			lap_completed.emit(body)
	else:
		body.pass_checkpoint(checkpoint_id)
	
	checkpoint_passed.emit(body, checkpoint_id)

func _on_boost_pad_entered(body: Node) -> void:
	if not body.is_in_group("karts"):
		return
	
	if body.has_method("hit_boost_pad"):
		body.hit_boost_pad(30.0)
	
	boost_pad_hit.emit(body)
	AudioManager.play_boost_sound()

func _on_weapon_pickup_entered(body: Node, pickup: Area2D) -> void:
	if not body.is_in_group("karts"):
		return
	
	# Only allow pickup if no weapon held
	if body.current_weapon != "":
		return
	
	# Random weapon selection
	var available_weapons = Global.unlocked_weapons
	if available_weapons.is_empty():
		available_weapons = ["plasma_missile", "pulse_shield"]
	
	var random_weapon = available_weapons[randi() % available_weapons.size()]
	
	if body.has_method("pickup_weapon"):
		body.pickup_weapon(random_weapon)
	
	weapon_pickup_collected.emit(body)
	
	# Respawn pickup after delay
	pickup.visible = false
	pickup.set_deferred("monitoring", false)
	
	var timer = get_tree().create_timer(5.0)
	timer.timeout.connect(func(): respawn_pickup(pickup))

func respawn_pickup(pickup: Area2D) -> void:
	pickup.visible = true
	pickup.monitoring = true

func _on_hazard_entered(body: Node, hazard: Area2D) -> void:
	if not body.is_in_group("karts"):
		return
	
	var hazard_type = hazard.get_meta("hazard_type", "damage")
	var hazard_value = hazard.get_meta("hazard_value", 20)
	
	match hazard_type:
		"damage":
			if body.has_method("take_damage"):
				body.take_damage(hazard_value)
		"emp":
			if body.has_method("apply_emp"):
				body.apply_emp(hazard_value)
		"push":
			var push_direction = (body.global_position - hazard.global_position).normalized()
			body.velocity += push_direction * hazard_value
		"slow":
			body.current_speed *= 0.5

func get_spawn_positions() -> Array[Dictionary]:
	var positions: Array[Dictionary] = []
	
	for spawn in spawn_points:
		positions.append({
			"position": spawn.global_position,
			"rotation": spawn.rotation
		})
	
	return positions

func get_waypoints() -> Array[Vector2]:
	return waypoints

func get_track_data() -> Dictionary:
	return {
		"name": track_name,
		"world": track_world,
		"laps": lap_count,
		"checkpoints": checkpoints.size()
	}