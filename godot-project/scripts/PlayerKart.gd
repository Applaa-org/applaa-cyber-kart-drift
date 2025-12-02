extends CharacterBody2D
class_name PlayerKart

# Signals
signal health_changed(new_health: int)
signal boost_changed(new_boost: float)
signal special_changed(new_special: float)
signal weapon_changed(weapon_name: String)
signal lap_completed(lap_number: int)
signal race_finished(position: int)
signal drift_score_added(score: int)

# Kart Stats (loaded from Global)
var max_speed: float = 450.0
var acceleration: float = 250.0
var handling: float = 0.8
var boost_power: float = 1.0
var drift_bonus: float = 1.0
var special_ability: String = "pulse_shield"

# Current State
var current_speed: float = 0.0
var steering_angle: float = 0.0
var health: int = 100
var max_health: int = 100

# Boost System
var boost_meter: float = 0.0
var max_boost: float = 100.0
var boost_drain_rate: float = 30.0
var boost_gain_rate: float = 15.0
var is_boosting: bool = false
var boost_disabled: bool = false
var boost_disabled_timer: float = 0.0

# Drift System
var is_drifting: bool = false
var drift_direction: int = 0  # -1 left, 1 right, 0 none
var drift_angle: float = 0.0
var drift_time: float = 0.0
var drift_score_accumulator: float = 0.0
var total_drift_score: int = 0

# Special Ability
var special_meter: float = 0.0
var max_special: float = 100.0
var special_active: bool = false
var special_duration: float = 0.0

# Weapon System
var current_weapon: String = ""
var weapon_count: int = 0

# Race State
var current_lap: int = 0
var current_checkpoint: int = 0
var race_position: int = 1
var race_time: float = 0.0
var is_racing: bool = false
var finished_race: bool = false

# Physics
var hover_offset: float = 0.0
var hover_time: float = 0.0
var tilt_angle: float = 0.0

# Visual references
@onready var kart_body: Node2D = $KartBody
@onready var thruster_left: Node2D = $KartBody/ThrusterLeft
@onready var thruster_right: Node2D = $KartBody/ThrusterRight
@onready var drift_particles_left: GPUParticles2D = $DriftParticlesLeft
@onready var drift_particles_right: GPUParticles2D = $DriftParticlesRight
@onready var boost_particles: GPUParticles2D = $BoostParticles
@onready var trail_left: Line2D = $TrailLeft
@onready var trail_right: Line2D = $TrailRight

func _ready() -> void:
	load_kart_stats()
	add_to_group("karts")
	add_to_group("player")

func load_kart_stats() -> void:
	var stats = Global.get_kart_stats()
	max_speed = stats.max_speed
	acceleration = stats.acceleration
	handling = stats.handling
	boost_power = stats.boost_power
	drift_bonus = stats.drift_bonus
	special_ability = stats.special

func _physics_process(delta: float) -> void:
	if not is_racing or finished_race:
		return
	
	race_time += delta
	
	# Update timers
	update_timers(delta)
	
	# Handle input
	handle_input(delta)
	
	# Update physics
	update_movement(delta)
	
	# Update visual effects
	update_visuals(delta)
	
	# Move the kart
	move_and_slide()

func update_timers(delta: float) -> void:
	if boost_disabled:
		boost_disabled_timer -= delta
		if boost_disabled_timer <= 0:
			boost_disabled = false
	
	if special_active:
		special_duration -= delta
		if special_duration <= 0:
			deactivate_special()

func handle_input(delta: float) -> void:
	# Steering
	var steer_input = Input.get_axis("move_left", "move_right")
	var target_steering = steer_input * handling * 3.0
	steering_angle = lerp(steering_angle, target_steering, delta * 5.0)
	
	# Acceleration / Brake
	if Input.is_action_pressed("accelerate"):
		current_speed += acceleration * delta
	elif Input.is_action_pressed("brake"):
		current_speed -= acceleration * 1.5 * delta
	else:
		# Natural deceleration
		current_speed = move_toward(current_speed, 0, acceleration * 0.3 * delta)
	
	# Apply boost
	var effective_max_speed = max_spee<applaa-write path="godot-project/scripts/PlayerKart.gd" description="Player-controlled kart with full physics, drifting, boost, and weapons">
extends CharacterBody2D
class_name PlayerKart

# Signals
signal health_changed(new_health: int)
signal boost_changed(new_boost: float)
signal special_changed(new_special: float)
signal weapon_changed(weapon_name: String)
signal lap_completed(lap_number: int)
signal race_finished(position: int)
signal drift_score_added(score: int)

# Kart Stats (loaded from Global)
var max_speed: float = 450.0
var acceleration: float = 250.0
var handling: float = 0.8
var boost_power: float = 1.0
var drift_bonus: float = 1.0
var special_ability: String = "pulse_shield"

# Current State
var current_speed: float = 0.0
var steering_angle: float = 0.0
var health: int = 100
var max_health: int = 100

# Boost System
var boost_meter: float = 0.0
var max_boost: float = 100.0
var boost_drain_rate: float = 30.0
var boost_gain_rate: float = 15.0
var is_boosting: bool = false
var boost_disabled: bool = false
var boost_disabled_timer: float = 0.0

# Drift System
var is_drifting: bool = false
var drift_direction: int = 0  # -1 left, 1 right, 0 none
var drift_angle: float = 0.0
var drift_time: float = 0.0
var drift_score_accumulator: float = 0.0
var total_drift_score: int = 0

# Special Ability
var special_meter: float = 0.0
var max_special: float = 100.0
var special_active: bool = false
var special_duration: float = 0.0

# Weapon System
var current_weapon: String = ""
var weapon_count: int = 0

# Race State
var current_lap: int = 0
var current_checkpoint: int = 0
var race_position: int = 1
var race_time: float = 0.0
var is_racing: bool = false
var finished_race: bool = false

# Physics
var hover_offset: float = 0.0
var hover_time: float = 0.0
var tilt_angle: float = 0.0

# Visual references
@onready var kart_body: Node2D = $KartBody
@onready var thruster_left: Node2D = $KartBody/ThrusterLeft
@onready var thruster_right: Node2D = $KartBody/ThrusterRight
@onready var drift_particles_left: GPUParticles2D = $DriftParticlesLeft
@onready var drift_particles_right: GPUParticles2D = $DriftParticlesRight
@onready var boost_particles: GPUParticles2D = $BoostParticles
@onready var trail_left: Line2D = $TrailLeft
@onready var trail_right: Line2D = $TrailRight

func _ready() -> void:
	load_kart_stats()
	add_to_group("karts")
	add_to_group("player")

func load_kart_stats() -> void:
	var stats = Global.get_kart_stats()
	max_speed = stats.max_speed
	acceleration = stats.acceleration
	handling = stats.handling
	boost_power = stats.boost_power
	drift_bonus = stats.drift_bonus
	special_ability = stats.special

func _physics_process(delta: float) -> void:
	if not is_racing or finished_race:
		return
	
	race_time += delta
	
	# Update timers
	update_timers(delta)
	
	# Handle input
	handle_input(delta)
	
	# Update physics
	update_movement(delta)
	
	# Update visual effects
	update_visuals(delta)
	
	# Move the kart
	move_and_slide()

func update_timers(delta: float) -> void:
	if boost_disabled:
		boost_disabled_timer -= delta
		if boost_disabled_timer <= 0:
			boost_disabled = false
	
	if special_active:
		special_duration -= delta
		if special_duration <= 0:
			deactivate_special()

func handle_input(delta: float) -> void:
	# Steering
	var steer_input = Input.get_axis("move_left", "move_right")
	var target_steering = steer_input * handling * 3.0
	steering_angle = lerp(steering_angle, target_steering, delta * 5.0)
	
	# Acceleration / Brake
	if Input.is_action_pressed("accelerate"):
		current_speed += acceleration * delta
	elif Input.is_action_pressed("brake"):
		current_speed -= acceleration * 1.5 * delta
	else:
		# Natural deceleration
		current_speed = move_toward(current_speed, 0, acceleration * 0.3 * delta)
	
	# Apply boost
	var effective_max_speed = max_speed
	if is_boosting and not boost_disabled:
		effective_max_speed *= (1.0 + boost_power * 0.5)
	
	current_speed = clamp(current_speed, -max_speed * 0.3, effective_max_speed)
	
	# Drift input
	if Input.is_action_pressed("drift") and abs(steer_input) > 0.3 and current_speed > max_speed * 0.4:
		start_drift(sign(steer_input))
	elif Input.is_action_just_released("drift") or abs(steer_input) < 0.1:
		end_drift()
	
	# Boost input
	if Input.is_action_pressed("boost") and boost_meter > 0 and not boost_disabled:
		activate_boost()
	else:
		deactivate_boost()
	
	# Weapon input
	if Input.is_action_just_pressed("fire_weapon") and current_weapon != "" and weapon_count > 0:
		fire_weapon()
	
	# Special ability input
	if Input.is_action_just_pressed("special_ability") and special_meter >= max_special:
		activate_special()

func update_movement(delta: float) -> void:
	# Calculate movement direction based on rotation
	var move_direction = Vector2.RIGHT.rotated(rotation)
	
	# Apply steering (reduced when drifting)
	var steer_modifier = 0.6 if is_drifting else 1.0
	rotation += steering_angle * steer_modifier * delta
	
	# Apply drift angle
	if is_drifting:
		drift_angle = lerp(drift_angle, drift_direction * 0.4, delta * 3.0)
		drift_time += delta
		
		# Accumulate drift score based on angle and speed
		var drift_score_rate = abs(drift_angle) * (current_speed / max_speed) * 100.0 * drift_bonus
		drift_score_accumulator += drift_score_rate * delta
		
		# Build boost meter while drifting
		boost_meter = min(boost_meter + boost_gain_rate * delta * drift_bonus, max_boost)
		boost_changed.emit(boost_meter)
		
		# Build special meter
		special_meter = min(special_meter + 5.0 * delta, max_special)
		special_changed.emit(special_meter)
	else:
		drift_angle = lerp(drift_angle, 0.0, delta * 5.0)
	
	# Apply velocity
	var drift_offset = Vector2.RIGHT.rotated(rotation + drift_angle * 0.5)
	velocity = move_direction.lerp(drift_offset, abs(drift_angle)) * current_speed
	
	# Boost drain
	if is_boosting:
		boost_meter = max(0, boost_meter - boost_drain_rate * delta)
		boost_changed.emit(boost_meter)
		if boost_meter <= 0:
			deactivate_boost()

func update_visuals(delta: float) -> void:
	# Hover effect
	hover_time += delta * 3.0
	hover_offset = sin(hover_time) * 3.0
	if kart_body:
		kart_body.position.y = hover_offset
	
	# Tilt based on steering
	tilt_angle = lerp(tilt_angle, -steering_angle * 0.1, delta * 8.0)
	if kart_body:
		kart_body.rotation = tilt_angle
	
	# Drift particles
	if drift_particles_left and drift_particles_right:
		drift_particles_left.emitting = is_drifting and drift_direction < 0
		drift_particles_right.emitting = is_drifting and drift_direction > 0
	
	# Boost particles
	if boost_particles:
		boost_particles.emitting = is_boosting
	
	# Update trails
	update_trails()
	
	# Thruster glow based on speed
	var speed_ratio = current_speed / max_speed
	if thruster_left and thruster_right:
		var thruster_color = Color(0.0, 0.8, 1.0).lerp(Color(1.0, 0.5, 0.0), speed_ratio)
		if is_boosting:
			thruster_color = Color(1.0, 0.3, 0.0)
		thruster_left.modulate = thruster_color
		thruster_right.modulate = thruster_color

func update_trails() -> void:
	if not trail_left or not trail_right:
		return
	
	var trail_color = Global.selected_underglow
	if is_boosting:
		trail_color = Color(1.0, 0.5, 0.0)
	elif is_drifting:
		trail_color = Color(0.0, 1.0, 0.5)
	
	trail_left.default_color = trail_color
	trail_right.default_color = trail_color
	
	# Add points to trails
	var left_pos = to_local(global_position + Vector2(-15, 0).rotated(rotation))
	var right_pos = to_local(global_position + Vector2(15, 0).rotated(rotation))
	
	if trail_left.get_point_count() > 50:
		trail_left.remove_point(0)
	if trail_right.get_point_count() > 50:
		trail_right.remove_point(0)
	
	if current_speed > 50:
		trail_left.add_point(left_pos)
		trail_right.add_point(right_pos)

func start_drift(direction: int) -> void:
	if not is_drifting:
		is_drifting = true
		drift_direction = direction
		drift_time = 0.0
		drift_score_accumulator = 0.0
		AudioManager.play_drift_sound()

func end_drift() -> void:
	if is_drifting:
		is_drifting = false
		
		# Award drift score
		var final_drift_score = int(drift_score_accumulator)
		if final_drift_score > 10:
			total_drift_score += final_drift_score
			drift_score_added.emit(final_drift_score)
			
			# Bonus boost for long drifts
			if drift_time > 2.0:
				boost_meter = min(boost_meter + 20.0, max_boost)
				boost_changed.emit(boost_meter)
		
		drift_direction = 0
		drift_score_accumulator = 0.0

func activate_boost() -> void:
	if not is_boosting and boost_meter > 0 and not boost_disabled:
		is_boosting = true
		AudioManager.play_boost_sound()

func deactivate_boost() -> void:
	is_boosting = false

func activate_special() -> void:
	if special_meter >= max_special and not special_active:
		special_active = true
		special_meter = 0
		special_changed.emit(special_meter)
		
		match special_ability:
			"quantum_boost":
				# Massive speed boost
				special_duration = 3.0
				current_speed = max_speed * 1.5
				boost_meter = max_boost
			"armor_wall":
				# Invincibility + ram damage
				special_duration = 4.0
			"pulse_shield":
				# Shield that absorbs damage
				special_duration = 5.0
			"teleport_dash":
				# Short teleport forward
				position += Vector2.RIGHT.rotated(rotation) * 200
				special_duration = 0.1
			"weapon_jam":
				# Disable nearby enemy weapons
				special_duration = 4.0
				jam_nearby_weapons()

func deactivate_special() -> void:
	special_active = false

func jam_nearby_weapons() -> void:
	var nearby_karts = get_tree().get_nodes_in_group("karts")
	for kart in nearby_karts:
		if kart != self and kart.has_method("disable_weapons"):
			var distance = global_position.distance_to(kart.global_position)
			if distance < 300:
				kart.disable_weapons(3.0)

func fire_weapon() -> void:
	if current_weapon == "" or weapon_count <= 0:
		return
	
	weapon_count -= 1
	AudioManager.play_weapon_sound(current_weapon)
	
	var weapon_data = Global.weapons.get(current_weapon, {})
	
	# Spawn weapon projectile or effect
	match current_weapon:
		"plasma_missile":
			spawn_missile(weapon_data)
		"emp_blast":
			spawn_emp_blast(weapon_data)
		"arc_shot":
			spawn_arc_shot(weapon_data)
		"shockwave_mine":
			spawn_mine(weapon_data)
		"inferno_rocket":
			spawn_rocket(weapon_data)
		"pulse_shield":
			activate_shield(weapon_data)
		"reflector_orb":
			activate_reflector(weapon_data)
		"decoy_drone":
			spawn_decoy(weapon_data)
		"nano_repair":
			activate_repair(weapon_data)
	
	if weapon_count <= 0:
		current_weapon = ""
	
	weapon_changed.emit(current_weapon)

func spawn_missile(data: Dictionary) -> void:
	# Would instantiate missile scene
	pass

func spawn_emp_blast(data: Dictionary) -> void:
	# EMP effect in radius
	var nearby_karts = get_tree().get_nodes_in_group("karts")
	for kart in nearby_karts:
		if kart != self:
			var distance = global_position.distance_to(kart.global_position)
			if distance < data.get("radius", 150.0):
				if kart.has_method("apply_emp"):
					kart.apply_emp(data.get("duration", 3.0))

func spawn_arc_shot(data: Dictionary) -> void:
	# Chain lightning effect
	pass

func spawn_mine(data: Dictionary) -> void:
	# Drop mine behind kart
	pass

func spawn_rocket(data: Dictionary) -> void:
	# Straight-line rocket
	pass

func activate_shield(data: Dictionary) -> void:
	# Temporary shield
	pass

func activate_reflector(data: Dictionary) -> void:
	# Reflect projectiles
	pass

func spawn_decoy(data: Dictionary) -> void:
	# Spawn decoy drone
	pass

func activate_repair(data: Dictionary) -> void:
	# Heal over time
	var heal_amount = data.get("heal_amount", 30)
	health = mini(health + heal_amount, max_health)
	health_changed.emit(health)

func pickup_weapon(weapon_id: String) -> void:
	current_weapon = weapon_id
	weapon_count = 1
	if weapon_id in ["pulse_shield", "nano_repair"]:
		weapon_count = 2
	weapon_changed.emit(current_weapon)

func take_damage(amount: int, source: Node = null) -> void:
	if special_active and special_ability == "armor_wall":
		return  # Invincible during armor wall
	
	health -= amount
	health_changed.emit(health)
	
	AudioManager.play_impact_sound("explosion")
	
	if health <= 0:
		handle_destruction()

func handle_destruction() -> void:
	# Respawn after short delay
	health = max_health
	health_changed.emit(health)
	current_speed = 0
	boost_meter = 0
	boost_changed.emit(boost_meter)
	
	# Would trigger respawn animation

func apply_emp(duration: float) -> void:
	boost_disabled = true
	boost_disabled_timer = duration
	deactivate_boost()

func disable_weapons(duration: float) -> void:
	# Weapon jam effect
	pass

func hit_boost_pad(boost_amount: float) -> void:
	boost_meter = min(boost_meter + boost_amount, max_boost)
	boost_changed.emit(boost_meter)
	current_speed = min(current_speed + 100, max_speed * 1.2)

func pass_checkpoint(checkpoint_id: int) -> void:
	if checkpoint_id == current_checkpoint + 1 or (checkpoint_id == 0 and current_checkpoint == -1):
		current_checkpoint = checkpoint_id

func complete_lap() -> void:
	current_lap += 1
	current_checkpoint = 0
	lap_completed.emit(current_lap)
	AudioManager.play_lap_complete()
	
	# Add bonus boost and special on lap completion
	boost_meter = min(boost_meter + 30, max_boost)
	boost_changed.emit(boost_meter)
	special_meter = min(special_meter + 20, max_special)
	special_changed.emit(special_meter)

func finish_race(final_position: int) -> void:
	finished_race = true
	race_position = final_position
	race_finished.emit(final_position)
	AudioManager.play_race_finish(final_position)

func start_race() -> void:
	is_racing = true
	finished_race = false
	current_lap = 0
	current_checkpoint = 0
	race_time = 0.0
	health = max_health
	boost_meter = 0
	special_meter = 0
	current_weapon = ""
	weapon_count = 0

func reset_position(spawn_position: Vector2, spawn_rotation: float) -> void:
	position = spawn_position
	rotation = spawn_rotation
	current_speed = 0
	velocity = Vector2.ZERO