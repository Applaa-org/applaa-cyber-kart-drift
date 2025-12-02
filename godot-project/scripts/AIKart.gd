extends CharacterBody2D
class_name AIKart

# AI Configuration
enum AIPersonality { AGGRESSIVE, DEFENSIVE, DRIFTER, SPEEDSTER }
enum AIDifficulty { EASY, MEDIUM, HARD, EXTREME }

@export var personality: AIPersonality = AIPersonality.SPEEDSTER
@export var difficulty: AIDifficulty = AIDifficulty.MEDIUM

# Movement
const MAX_SPEED: float = 550.0
const ACCELERATION: float = 350.0
const TURN_SPEED: float = 3.0

var current_speed: float = 0.0
var target_position: Vector2
var path_index: int = 0

# Stats modified by difficulty
var reaction_time: float = 0.3
var accuracy: float = 0.8
var aggression: float = 0.5

# State
var health: int = 100
var max_health: int = 100
var boost_meter: float = 0.0
var is_boosting: bool = false
var is_drifting: bool = false
var current_weapon: String = ""
var weapon_charges: int = 0
var weapons_jammed: bool = false
var jam_timer: float = 0.0

# Race data
var checkpoint_index: int = 0
var lap_count: int = 0
var race_position: int = 1

# Path following
var race_path: Path2D
var path_follow: PathFollow2D
var look_ahead_distance: float = 150.0

# Visual
var body_sprite: Node2D
var kart_color: Color
var trail_line: Line2D

# Hover effect
var hover_offset: float = 0.0
const HOVER_FREQUENCY: float = 2.5
const HOVER_HEIGHT: float = 6.0

signal ai_destroyed(ai_kart: AIKart)

func _ready():
	add_to_group("ai_karts")
	add_to_group("karts")
	
	setup_difficulty()
	setup_visuals()
	randomize_personality()

func setup_difficulty():
	match difficulty:
		AIDifficulty.EASY:
			reaction_time = 0.5
			accuracy = 0.6
			aggression = 0.2
		AIDifficulty.MEDIUM:
			reaction_time = 0.3
			accuracy = 0.75
			aggression = 0.5
		AIDifficulty.HARD:
			reaction_time = 0.15
			accuracy = 0.9
			aggression = 0.7
		AIDifficulty.EXTREME:
			reaction_time = 0.05
			accuracy = 0.98
			aggression = 0.9

func randomize_personality():
	if randf() < 0.3:
		personality = AIPersonality.values()[randi() % AIPersonality.size()]
	
	# Adjust behavior based on personality
	match personality:
		AIPersonality.AGGRESSIVE:
			aggression = min(aggression + 0.3, 1.0)
		AIPersonality.DEFENSIVE:
			aggression = max(aggression - 0.3, 0.1)
		AIPersonality.DRIFTER:
			accuracy = min(accuracy + 0.1, 1.0)
		AIPersonality.SPEEDSTER:
			pass

func setup_visuals():
	# Random neon color for AI
	var colors = [
		Color(1.0, 0.2, 0.4),  # Red
		Color(0.2, 1.0, 0.4),  # Green
		Color(1.0, 0.8, 0.2),  # Yellow
		Color(0.8, 0.2, 1.0),  # Purple
		Color(1.0, 0.5, 0.2),  # Orange
	]
	kart_color = colors[randi() % colors.size()]
	
	body_sprite = Node2D.new()
	body_sprite.name = "KartBody"
	add_child(body_sprite)
	
	# Body shape
	var body = Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-18, -10), Vector2(22, -7), Vector2(26, 0),
		Vector2(22, 7), Vector2(-18, 10), Vector2(-22, 7),
		Vector2(-22, -7)
	])
	body.color = kart_color
	body_sprite.add_child(body)
	
	# Cockpit
	var cockpit = Polygon2D.new()
	cockpit.polygon = PackedVector2Array([
		Vector2(-4, -5), Vector2(8, -3), Vector2(8, 3), Vector2(-4, 5)
	])
	cockpit.color = Color(0.1, 0.1, 0.15, 0.9)
	body_sprite.add_child(cockpit)
	
	# Neon outline
	var outline = Line2D.new()
	outline.points = PackedVector2Array([
		Vector2(-18, -10), Vector2(22, -7), Vector2(26, 0),
		Vector2(22, 7), Vector2(-18, 10), Vector2(-22, 7),
		Vector2(-22, -7), Vector2(-18, -10)
	])
	outline.width = 2.0
	outline.default_color = Color(kart_color, 0.9)
	body_sprite.add_child(outline)
	
	# Thrusters
	for offset in [-7, 7]:
		var thruster = Polygon2D.new()
		thruster.polygon = PackedVector2Array([
			Vector2(0, -2), Vector2(-6, 0), Vector2(0, 2)
		])
		thruster.position = Vector2(-22, offset)
		thruster.color = Color(1.0, 0.6, 0.2)
		body_sprite.add_child(thruster)
	
	# Trail
	trail_line = Line2D.new()
	trail_line.width = 3.0
	trail_line.default_color = Color(kart_color, 0.4)
	add_child(trail_line)

func _physics_process(delta: float):
	if Global.current_state != Global.GameState.RACING:
		return
	
	# Hover effect
	hover_offset = sin(Time.get_ticks_msec() * 0.001 * HOVER_FREQUENCY) * HOVER_HEIGHT
	if body_sprite:
		body_sprite.position.y = hover_offset
	
	# Update jam timer
	if weapons_jammed:
		jam_timer -= delta
		if jam_timer <= 0:
			weapons_jammed = false
	
	# AI decision making
	update_ai(delta)
	
	# Apply movement
	apply_movement(delta)
	
	# Update trail
	update_trail()
	
	move_and_slide()

func update_ai(delta: float):
	# Get target position (next point on race path)
	if race_path and path_follow:
		path_follow.progress += look_ahead_distance
		target_position = path_follow.global_position
		path_follow.progress -= look_ahead_distance
	else:
		# Fallback: move toward next checkpoint or forward
		target_position = global_position + Vector2.RIGHT.rotated(rotation) * 200
	
	# Calculate steering
	var to_target = (target_position - global_position).normalized()
	var target_angle = to_target.angle()
	var angle_diff = wrapf(target_angle - rotation, -PI, PI)
	
	# Apply accuracy variance
	angle_diff += randf_range(-0.1, 0.1) * (1.0 - accuracy)
	
	# Steering with reaction delay
	var steer_amount = clamp(angle_diff / PI, -1.0, 1.0)
	rotation += steer_amount * TURN_SPEED * delta
	
	# Speed control
	var target_speed = MAX_SPEED * accuracy
	
	# Slow down for sharp turns
	if abs(angle_diff) > PI * 0.3:
		target_speed *= 0.6
		is_drifting = true
	else:
		is_drifting = false
	
	# Boost usage
	if boost_meter >= 30 and abs(angle_diff) < PI * 0.1:
		if randf() < aggression * 0.1:
			activate_boost()
	
	# Build boost while driving
	boost_meter = clamp(boost_meter + delta * 5.0, 0, 100)
	
	if is_boosting:
		target_speed *= 1.5
	
	current_speed = move_toward(current_speed, target_speed, ACCELERATION * delta)
	
	# Weapon usage
	if current_weapon != "" and weapon_charges > 0 and not weapons_jammed:
		consider_weapon_use()

func consider_weapon_use():
	# Find nearby targets
	var player = get_tree().get_first_node_in_group("player")
	if player:
		var dist_to_player = global_position.distance_to(player.global_position)
		
		# Use weapon based on personality and distance
		var should_fire = false
		
		match personality:
			AIPersonality.AGGRESSIVE:
				should_fire = dist_to_player < 300 and randf() < aggression
			AIPersonality.DEFENSIVE:
				should_fire = dist_to_player < 150 and randf() < 0.3
			_:
				should_fire = dist_to_player < 250 and randf() < aggression * 0.5
		
		if should_fire:
			fire_weapon()

func activate_boost():
	if boost_meter >= 30:
		is_boosting = true
		boost_meter -= 30
		# Auto-disable after duration
		get_tree().create_timer(1.5).timeout.connect(func(): is_boosting = false)

func fire_weapon():
	if weapons_jammed or current_weapon == "" or weapon_charges <= 0:
		return
	
	weapon_charges -= 1
	AudioManager.play_weapon_sound(current_weapon)
	
	# Spawn projectile
	var projectile_data = {
		"position": global_position + Vector2.RIGHT.rotated(rotation) * 25,
		"rotation": rotation,
		"type": "straight",
		"damage": 20,
		"owner": self
	}
	get_tree().call_group("weapon_system", "spawn_projectile", projectile_data)
	
	if weapon_charges <= 0:
		current_weapon = ""

func apply_movement(delta: float):
	var direction = Vector2.RIGHT.rotated(rotation)
	velocity = direction * current_speed

func update_trail():
	if trail_line:
		var trail_pos = global_position - Vector2.RIGHT.rotated(rotation) * 22
		trail_line.add_point(trail_pos)
		
		if trail_line.points.size() > 15:
			trail_line.remove_point(0)
		
		if is_boosting:
			trail_line.default_color = Color(1.0, 0.5, 0.0, 0.7)
			trail_line.width = 5.0
		elif is_drifting:
			trail_line.default_color = Color(kart_color, 0.6)
			trail_line.width = 4.0
		else:
			trail_line.default_color = Color(kart_color, 0.3)
			trail_line.width = 3.0

func set_race_path(path: Path2D):
	race_path = path
	if race_path:
		path_follow = PathFollow2D.new()
		path_follow.loop = true
		race_path.add_child(path_follow)

func collect_weapon(weapon_name: String, charges: int = 1):
	current_weapon = weapon_name
	weapon_charges = charges

func take_damage(amount: int, source: Node = null):
	health -= amount
	
	# Flash effect
	if body_sprite:
		var orig_color = body_sprite.get_child(0).color
		body_sprite.get_child(0).color = Color.WHITE
		get_tree().create_timer(0.1).timeout.connect(func():
			if body_sprite and body_sprite.get_child_count() > 0:
				body_sprite.get_child(0).color = orig_color
		)
	
	if health <= 0:
		on_destroyed()

func on_destroyed():
	ai_destroyed.emit(self)
	# Respawn handled by race manager

func jam_weapons(duration: float):
	weapons_jammed = true
	jam_timer = duration

func pass_checkpoint(checkpoint_id: int):
	checkpoint_index = checkpoint_id

func get_race_progress() -> float:
	return checkpoint_index + lap_count * 100.0

func hit_boost_pad(boost_amount: float):
	boost_meter = clamp(boost_meter + boost_amount, 0, 100)
	activate_boost()