extends CharacterBody2D
class_name PlayerKart

# Movement Constants
const MAX_SPEED: float = 600.0
const ACCELERATION: float = 400.0
const DECELERATION: float = 300.0
const BRAKE_POWER: float = 600.0
const TURN_SPEED: float = 3.5
const DRIFT_TURN_MULTIPLIER: float = 1.8
const DRIFT_ANGLE_THRESHOLD: float = 0.3
const BOOST_MULTIPLIER: float = 1.8
const BOOST_DURATION: float = 2.0
const MAX_BOOST_METER: float = 100.0
const DRIFT_BOOST_GAIN: float = 15.0

# Hover Physics
const HOVER_HEIGHT: float = 8.0
const HOVER_FREQUENCY: float = 3.0
var hover_offset: float = 0.0

# State Variables
var current_speed: float = 0.0
var target_rotation: float = 0.0
var is_drifting: bool = false
var drift_direction: int = 0  # -1 left, 0 none, 1 right
var drift_angle: float = 0.0
var drift_time: float = 0.0

# Boost System
var boost_meter: float = 0.0
var is_boosting: bool = false
var boost_timer: float = 0.0

# Health System
var health: int = 100
var max_health: int = 100
var is_invulnerable: bool = false
var invulnerable_timer: float = 0.0

# Weapon System
var current_weapon: String = ""
var weapon_charges: int = 0
var special_meter: float = 0.0
var max_special_meter: float = 100.0

# Race Data
var checkpoint_index: int = 0
var lap_progress: float = 0.0
var race_position: int = 1

# Visual References
var body_sprite: Node2D
var thruster_particles: GPUParticles2D
var drift_particles: GPUParticles2D
var boost_particles: GPUParticles2D
var trail_line: Line2D

# Effects
var screen_shake_intensity: float = 0.0
var current_tilt: float = 0.0

# Signals
signal health_changed(new_health: int)
signal boost_changed(new_boost: float)
signal weapon_changed(weapon_name: String, charges: int)
signal special_changed(new_special: float)
signal kart_destroyed()
signal checkpoint_passed(index: int)
signal lap_completed()

func _ready():
	# Load stats from Global
	max_health = Global.kart_stats.max_health
	health = max_health
	
	# Setup collision
	add_to_group("player")
	add_to_group("karts")
	
	# Create visual components
	setup_visuals()

func setup_visuals():
	# Create kart body
	body_sprite = Node2D.new()
	body_sprite.name = "KartBody"
	add_child(body_sprite)
	
	# Main body shape
	var body_shape = Polygon2D.new()
	body_shape.polygon = PackedVector2Array([
		Vector2(-20, -12), Vector2(25, -8), Vector2(30, 0),
		Vector2(25, 8), Vector2(-20, 12), Vector2(-25, 8),
		Vector2(-25, -8)
	])
	body_shape.color = Global.get_kart_color()
	body_sprite.add_child(body_shape)
	
	# Cockpit
	var cockpit = Polygon2D.new()
	cockpit.polygon = PackedVector2Array([
		Vector2(-5, -6), Vector2(10, -4), Vector2(10, 4), Vector2(-5, 6)
	])
	cockpit.color = Color(0.1, 0.1, 0.2, 0.9)
	body_sprite.add_child(cockpit)
	
	# Neon trim
	var trim = Line2D.new()
	trim.points = PackedVector2Array([
		Vector2(-20, -12), Vector2(25, -8), Vector2(30, 0),
		Vector2(25, 8), Vector2(-20, 12), Vector2(-25, 8),
		Vector2(-25, -8), Vector2(-20, -12)
	])
	trim.width = 2.0
	trim.default_color = Color(0.0, 1.0, 1.0, 0.8)
	body_sprite.add_child(trim)
	
	# Thrusters
	var left_thruster = create_thruster(Vector2(-25, -8))
	var right_thruster = create_thruster(Vector2(-25, 8))
	body_sprite.add_child(left_thruster)
	body_sprite.add_child(right_thruster)
	
	# Trail line
	trail_line = Line2D.new()
	trail_line.width = 4.0
	trail_line.default_color = Color(Global.get_kart_color(), 0.5)
	trail_line.name = "Trail"
	add_child(trail_line)

func create_thruster(pos: Vector2) -> Node2D:
	var thruster = Node2D.new()
	thruster.position = pos
	
	var thruster_glow = Polygon2D.new()
	thruster_glow.polygon = PackedVector2Array([
		Vector2(0, -3), Vector2(-8, 0), Vector2(0, 3)
	])
	thruster_glow.color = Global.kart_customization.thruster_color
	thruster.add_child(thruster_glow)
	
	return thruster

func _physics_process(delta: float):
	if Global.current_state != Global.GameState.RACING:
		return
	
	# Update hover effect
	hover_offset = sin(Time.get_ticks_msec() * 0.001 * HOVER_FREQUENCY) * HOVER_HEIGHT
	
	# Handle input
	handle_input(delta)
	
	# Update boost
	update_boost(delta)
	
	# Update drift
	update_drift(delta)
	
	# Update invulnerability
	update_invulnerability(delta)
	
	# Apply movement
	apply_movement(delta)
	
	# Update visuals
	update_visuals(delta)
	
	# Update trail
	update_trail()
	
	move_and_slide()

func handle_input(delta: float):
	# Acceleration
	var accel_input = Input.get_axis("brake", "accelerate")
	
	if accel_input > 0:
		var accel_rate = Global.kart_stats.acceleration
		if is_boosting:
			accel_rate *= BOOST_MULTIPLIER
		current_speed = move_toward(current_speed, get_max_speed(), accel_rate * delta)
	elif accel_input < 0:
		current_speed = move_toward(current_speed, -get_max_speed() * 0.3, BRAKE_POWER * delta)
	else:
		current_speed = move_toward(current_speed, 0, DECELERATION * delta)
	
	# Steering
	var steer_input = Input.get_axis("move_left", "move_right")
	var turn_rate = TURN_SPEED * Global.kart_stats.handling
	
	if is_drifting:
		turn_rate *= DRIFT_TURN_MULTIPLIER
	
	if abs(current_speed) > 10:
		var speed_factor = clamp(abs(current_speed) / get_max_speed(), 0.3, 1.0)
		rotation += steer_input * turn_rate * speed_factor * delta * sign(current_speed)
	
	# Drift input
	if Input.is_action_just_pressed("drift") and abs(current_speed) > get_max_speed() * 0.5:
		start_drift(sign(steer_input) if steer_input != 0 else 1)
	elif Input.is_action_just_released("drift") and is_drifting:
		end_drift()
	
	# Boost input
	if Input.is_action_just_pressed("boost") and boost_meter >= 30:
		activate_boost()
	
	# Weapon input
	if Input.is_action_just_pressed("fire_weapon") and current_weapon != "" and weapon_charges > 0:
		fire_weapon()
	
	# Special ability input
	if Input.is_action_just_pressed("special_ability") and special_meter >= max_special_meter:
		activate_special()

func get_max_speed() -> float:
	var speed = Global.kart_stats.speed
	if is_boosting:
		speed *= BOOST_MULTIPLIER * Global.kart_stats.boost_power
	return speed

func start_drift(direction: int):
	is_drifting = true
	drift_direction = direction
	drift_time = 0.0
	drift_angle = 0.0
	AudioManager.play_drift_sound(0)

func end_drift():
	if is_drifting:
		is_drifting = false
		
		# Award boost based on drift time
		var drift_bonus = drift_time * DRIFT_BOOST_GAIN * Global.kart_stats.drift_efficiency
		boost_meter = clamp(boost_meter + drift_bonus, 0, MAX_BOOST_METER)
		boost_changed.emit(boost_meter)
		
		# Award drift score
		var drift_points = int(drift_time * 10 * abs(drift_angle) * 10)
		Global.add_drift_score(drift_points)
		
		AudioManager.stop_drift_sound(0)
		drift_direction = 0

func update_drift(delta: float):
	if is_drifting:
		drift_time += delta
		var steer_input = Input.get_axis("move_left", "move_right")
		drift_angle = lerp(drift_angle, steer_input * 0.5, delta * 3.0)
		
		# Visual drift angle on kart
		current_tilt = lerp(current_tilt, drift_direction * 15.0, delta * 5.0)
		
		# Continuous boost gain while drifting
		var gain_rate = 5.0 * Global.kart_stats.drift_efficiency
		boost_meter = clamp(boost_meter + gain_rate * delta, 0, MAX_BOOST_METER)
		boost_changed.emit(boost_meter)
		
		# Build special meter while drifting
		special_meter = clamp(special_meter + delta * 5.0, 0, max_special_meter)
		special_changed.emit(special_meter)
	else:
		current_tilt = lerp(current_tilt, 0.0, delta * 8.0)

func activate_boost():
	if boost_meter >= 30:
		is_boosting = true
		boost_timer = BOOST_DURATION
		boost_meter -= 30
		boost_changed.emit(boost_meter)
		AudioManager.play_boost_sound(0)
		screen_shake_intensity = 5.0

func update_boost(delta: float):
	if is_boosting:
		boost_timer -= delta
		if boost_timer <= 0:
			is_boosting = false
			boost_timer = 0

func apply_movement(delta: float):
	var direction = Vector2.RIGHT.rotated(rotation)
	velocity = direction * current_speed
	
	# Apply hover offset to visual only
	if body_sprite:
		body_sprite.position.y = hover_offset

func update_visuals(delta: float):
	if body_sprite:
		# Apply tilt during drift
		body_sprite.rotation = deg_to_rad(current_tilt)
		
		# Update thruster intensity based on speed
		var speed_ratio = abs(current_speed) / get_max_speed()
		for child in body_sprite.get_children():
			if child is Node2D and child.get_child_count() > 0:
				var thruster_glow = child.get_child(0)
				if thruster_glow is Polygon2D:
					var intensity = 0.5 + speed_ratio * 0.5
					if is_boosting:
						intensity = 1.5
					thruster_glow.color.a = intensity

func update_trail():
	if trail_line:
		# Add current position to trail
		var trail_pos = global_position - Vector2.RIGHT.rotated(rotation) * 25
		
		if trail_line.points.size() == 0:
			trail_line.add_point(trail_pos)
		else:
			trail_line.add_point(trail_pos)
			
			# Limit trail length
			if trail_line.points.size() > 20:
				trail_line.remove_point(0)
		
		# Update trail color based on state
		if is_boosting:
			trail_line.default_color = Color(1.0, 0.5, 0.0, 0.8)
			trail_line.width = 6.0
		elif is_drifting:
			trail_line.default_color = Color(0.0, 1.0, 1.0, 0.6)
			trail_line.width = 5.0
		else:
			trail_line.default_color = Color(Global.get_kart_color(), 0.4)
			trail_line.width = 3.0

func collect_weapon(weapon_name: String, charges: int = 1):
	current_weapon = weapon_name
	weapon_charges = charges
	weapon_changed.emit(current_weapon, weapon_charges)
	AudioManager.play_pickup_sound()

func fire_weapon():
	if current_weapon == "" or weapon_charges <= 0:
		return
	
	weapon_charges -= 1
	AudioManager.play_weapon_sound(current_weapon)
	
	# Spawn weapon projectile based on type
	match current_weapon:
		"PlasmaMissile":
			spawn_plasma_missile()
		"EMPBlast":
			spawn_emp_blast()
		"ArcShot":
			spawn_arc_shot()
		"ShockwaveMine":
			spawn_mine()
		"InfernoRocket":
			spawn_inferno_rocket()
		"PulseShield":
			activate_shield()
		"ReflectorOrb":
			activate_reflector()
		"DecoyDrone":
			spawn_decoy()
		"NanoRepair":
			activate_repair()
	
	if weapon_charges <= 0:
		current_weapon = ""
	weapon_changed.emit(current_weapon, weapon_charges)

func spawn_plasma_missile():
	# Missile spawning handled by weapon system
	var missile_data = {
		"position": global_position + Vector2.RIGHT.rotated(rotation) * 30,
		"rotation": rotation,
		"type": "homing",
		"damage": 30,
		"owner": self
	}
	get_tree().call_group("weapon_system", "spawn_projectile", missile_data)

func spawn_emp_blast():
	var blast_data = {
		"position": global_position,
		"radius": 150,
		"effect": "disable_boost",
		"duration": 3.0,
		"owner": self
	}
	get_tree().call_group("weapon_system", "spawn_area_effect", blast_data)

func spawn_arc_shot():
	var arc_data = {
		"position": global_position + Vector2.RIGHT.rotated(rotation) * 30,
		"rotation": rotation,
		"type": "chain",
		"damage": 20,
		"chain_count": 3,
		"owner": self
	}
	get_tree().call_group("weapon_system", "spawn_projectile", arc_data)

func spawn_mine():
	var mine_data = {
		"position": global_position - Vector2.RIGHT.rotated(rotation) * 30,
		"type": "mine",
		"damage": 25,
		"owner": self
	}
	get_tree().call_group("weapon_system", "spawn_trap", mine_data)

func spawn_inferno_rocket():
	var rocket_data = {
		"position": global_position + Vector2.RIGHT.rotated(rotation) * 30,
		"rotation": rotation,
		"type": "straight",
		"damage": 40,
		"speed": 800,
		"owner": self
	}
	get_tree().call_group("weapon_system", "spawn_projectile", rocket_data)

func activate_shield():
	is_invulnerable = true
	invulnerable_timer = 3.0
	# Visual shield effect
	modulate = Color(0.5, 0.8, 1.0, 0.8)

func activate_reflector():
	# Reflector orb logic
	pass

func spawn_decoy():
	# Decoy drone logic
	pass

func activate_repair():
	var heal_amount = 30
	health = clamp(health + heal_amount, 0, max_health)
	health_changed.emit(health)

func activate_special():
	special_meter = 0
	special_changed.emit(special_meter)
	
	var ability = Global.get_special_ability()
	match ability:
		"quantum_boost":
			# Massive speed boost
			boost_meter = MAX_BOOST_METER
			activate_boost()
			boost_timer = BOOST_DURATION * 2
		"armor_wall":
			# Temporary invulnerability
			is_invulnerable = true
			invulnerable_timer = 5.0
			modulate = Color(1.0, 0.5, 0.3, 0.8)
		"pulse_shield":
			# Shield + knockback
			activate_shield()
			# Push nearby karts away
		"teleport_dash":
			# Teleport forward
			global_position += Vector2.RIGHT.rotated(rotation) * 200
		"weapon_jam":
			# Disable nearby enemy weapons
			get_tree().call_group("ai_karts", "jam_weapons", 3.0)

func update_invulnerability(delta: float):
	if is_invulnerable:
		invulnerable_timer -= delta
		if invulnerable_timer <= 0:
			is_invulnerable = false
			modulate = Color.WHITE

func take_damage(amount: int, source: Node = null):
	if is_invulnerable:
		return
	
	health -= amount
	health_changed.emit(health)
	
	# Brief invulnerability
	is_invulnerable = true
	invulnerable_timer = 0.5
	
	# Screen shake
	screen_shake_intensity = amount * 0.3
	
	# Flash red
	modulate = Color(1.0, 0.3, 0.3)
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color.WHITE, 0.2)
	
	if health <= 0:
		on_destroyed()

func on_destroyed():
	health = 0
	kart_destroyed.emit()
	# Respawn logic handled by race manager

func hit_boost_pad(boost_amount: float):
	boost_meter = clamp(boost_meter + boost_amount, 0, MAX_BOOST_METER)
	boost_changed.emit(boost_meter)
	
	# Auto-activate small boost
	if not is_boosting:
		is_boosting = true
		boost_timer = 0.5

func pass_checkpoint(checkpoint_id: int):
	checkpoint_index = checkpoint_id
	checkpoint_passed.emit(checkpoint_id)

func complete_lap():
	Global.complete_lap()
	lap_completed.emit()

func get_race_progress() -> float:
	# Calculate progress based on checkpoints and position
	return lap_progress + Global.lap_count

func apply_effect(effect_name: String, duration: float):
	match effect_name:
		"disable_boost":
			boost_meter = 0
			boost_changed.emit(boost_meter)
			# Prevent boost for duration
		"slow":
			# Reduce max speed temporarily
			pass
		"spin":
			# Force spin out
			var spin_tween = create_tween()
			spin_tween.tween_property(self, "rotation", rotation + PI * 4, 1.0)