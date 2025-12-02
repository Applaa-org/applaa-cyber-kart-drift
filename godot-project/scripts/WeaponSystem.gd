extends Node
class_name WeaponSystem

# Projectile pools
var missile_pool: Array[Node2D] = []
var mine_pool: Array[Node2D] = []
var effect_pool: Array[Node2D] = []

const POOL_SIZE: int = 20

func _ready():
	add_to_group("weapon_system")
	initialize_pools()

func initialize_pools():
	# Pre-create projectile objects for pooling
	for i in range(POOL_SIZE):
		var missile = create_missile_projectile()
		missile.visible = false
		add_child(missile)
		missile_pool.append(missile)
		
		var mine = create_mine_trap()
		mine.visible = false
		add_child(mine)
		mine_pool.append(mine)

func create_missile_projectile() -> Node2D:
	var missile = Area2D.new()
	missile.name = "Missile"
	missile.collision_layer = 4  # weapons layer
	missile.collision_mask = 1   # karts layer
	
	# Visual
	var body = Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-10, -4), Vector2(10, 0), Vector2(-10, 4)
	])
	body.color = Color(1.0, 0.3, 0.1)
	missile.add_child(body)
	
	# Glow trail
	var trail = Line2D.new()
	trail.name = "Trail"
	trail.width = 4.0
	trail.default_color = Color(1.0, 0.5, 0.0, 0.6)
	missile.add_child(trail)
	
	# Collision
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 8.0
	collision.shape = shape
	missile.add_child(collision)
	
	# Script data storage
	missile.set_meta("active", false)
	missile.set_meta("velocity", Vector2.ZERO)
	missile.set_meta("damage", 30)
	missile.set_meta("type", "straight")
	missile.set_meta("lifetime", 0.0)
	missile.set_meta("owner", null)
	missile.set_meta("target", null)
	
	missile.body_entered.connect(_on_missile_hit.bind(missile))
	
	return missile

func create_mine_trap() -> Node2D:
	var mine = Area2D.new()
	mine.name = "Mine"
	mine.collision_layer = 4
	mine.collision_mask = 1
	
	# Visual - pulsing mine
	var body = Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-12, 0), Vector2(-6, -10), Vector2(6, -10),
		Vector2(12, 0), Vector2(6, 10), Vector2(-6, 10)
	])
	body.color = Color(1.0, 0.2, 0.8)
	mine.add_child(body)
	
	# Inner glow
	var inner = Polygon2D.new()
	inner.polygon = PackedVector2Array([
		Vector2(-6, 0), Vector2(-3, -5), Vector2(3, -5),
		Vector2(6, 0), Vector2(3, 5), Vector2(-3, 5)
	])
	inner.color = Color(1.0, 0.8, 0.2)
	mine.add_child(inner)
	
	# Collision
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 15.0
	collision.shape = shape
	mine.add_child(collision)
	
	mine.set_meta("active", false)
	mine.set_meta("damage", 25)
	mine.set_meta("owner", null)
	mine.set_meta("lifetime", 0.0)
	
	mine.body_entered.connect(_on_mine_triggered.bind(mine))
	
	return mine

func spawn_projectile(data: Dictionary):
	var projectile = get_available_missile()
	if not projectile:
		return
	
	projectile.global_position = data.get("position", Vector2.ZERO)
	projectile.rotation = data.get("rotation", 0.0)
	projectile.visible = true
	projectile.set_meta("active", true)
	projectile.set_meta("damage", data.get("damage", 20))
	projectile.set_meta("type", data.get("type", "straight"))
	projectile.set_meta("owner", data.get("owner", null))
	projectile.set_meta("lifetime", 5.0)
	
	var speed = data.get("speed", 600.0)
	projectile.set_meta("velocity", Vector2.RIGHT.rotated(projectile.rotation) * speed)
	
	# For homing missiles, find target
	if data.get("type") == "homing":
		var target = find_nearest_target(projectile.global_position, data.get("owner"))
		projectile.set_meta("target", target)
	
	# Clear trail
	var trail = projectile.get_node_or_null("Trail")
	if trail:
		trail.clear_points()

func spawn_trap(data: Dictionary):
	var mine = get_available_mine()
	if not mine:
		return
	
	mine.global_position = data.get("position", Vector2.ZERO)
	mine.visible = true
	mine.set_meta("active", true)
	mine.set_meta("damage", data.get("damage", 25))
	mine.set_meta("owner", data.get("owner", null))
	mine.set_meta("lifetime", 15.0)

func spawn_area_effect(data: Dictionary):
	# Create temporary area effect (EMP, etc)
	var effect = Area2D.new()
	effect.global_position = data.get("position", Vector2.ZERO)
	
	# Visual circle
	var visual = Node2D.new()
	effect.add_child(visual)
	
	# Draw expanding circle
	var circle = Polygon2D.new()
	var points: PackedVector2Array = []
	var radius = data.get("radius", 100)
	for i in range(32):
		var angle = i * TAU / 32
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	circle.polygon = points
	circle.color = Color(0.0, 0.8, 1.0, 0.3)
	visual.add_child(circle)
	
	# Collision
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = radius
	collision.shape = shape
	effect.add_child(collision)
	
	add_child(effect)
	
	# Apply effect to karts in range
	effect.body_entered.connect(func(body):
		if body != data.get("owner") and body.has_method("apply_effect"):
			body.apply_effect(data.get("effect", "slow"), data.get("duration", 2.0))
	)
	
	# Animate and remove
	var tween = create_tween()
	tween.tween_property(circle, "color:a", 0.0, 0.5)
	tween.tween_callback(effect.queue_free)

func get_available_missile() -> Node2D:
	for missile in missile_pool:
		if not missile.get_meta("active"):
			return missile
	return null

func get_available_mine() -> Node2D:
	for mine in mine_pool:
		if not mine.get_meta("active"):
			return mine
	return null

func find_nearest_target(from_pos: Vector2, owner: Node) -> Node:
	var nearest: Node = null
	var nearest_dist: float = INF
	
	for kart in get_tree().get_nodes_in_group("karts"):
		if kart != owner and is_instance_valid(kart):
			var dist = from_pos.distance_to(kart.global_position)
			if dist < nearest_dist:
				nearest_dist = dist
				nearest = kart
	
	return nearest

func _physics_process(delta: float):
	# Update active projectiles
	for missile in missile_pool:
		if missile.get_meta("active"):
			update_missile(missile, delta)
	
	# Update active mines
	for mine in mine_pool:
		if mine.get_meta("active"):
			update_mine(mine, delta)

func update_missile(missile: Node2D, delta: float):
	var lifetime = missile.get_meta("lifetime") - delta
	missile.set_meta("lifetime", lifetime)
	
	if lifetime <= 0:
		deactivate_missile(missile)
		return
	
	var velocity: Vector2 = missile.get_meta("velocity")
	var missile_type = missile.get_meta("type")
	
	# Homing behavior
	if missile_type == "homing":
		var target = missile.get_meta("target")
		if target and is_instance_valid(target):
			var to_target = (target.global_position - missile.global_position).normalized()
			var current_dir = velocity.normalized()
			var new_dir = current_dir.lerp(to_target, 3.0 * delta).normalized()
			velocity = new_dir * velocity.length()
			missile.rotation = velocity.angle()
			missile.set_meta("velocity", velocity)
	
	missile.global_position += velocity * delta
	
	# Update trail
	var trail = missile.get_node_or_null("Trail") as Line2D
	if trail:
		trail.add_point(missile.global_position)
		if trail.points.size() > 10:
			trail.remove_point(0)
	
	# Out of bounds check
	if missile.global_position.length() > 5000:
		deactivate_missile(missile)

func update_mine(mine: Node2D, delta: float):
	var lifetime = mine.get_meta("lifetime") - delta
	mine.set_meta("lifetime", lifetime)
	
	if lifetime <= 0:
		deactivate_mine(mine)
		return
	
	# Pulsing animation
	var pulse = 1.0 + sin(Time.get_ticks_msec() * 0.01) * 0.1
	mine.scale = Vector2(pulse, pulse)

func _on_missile_hit(body: Node, missile: Node2D):
	if not missile.get_meta("active"):
		return
	
	var owner = missile.get_meta("owner")
	if body == owner:
		return
	
	if body.has_method("take_damage"):
		body.take_damage(missile.get_meta("damage"), owner)
	
	# Explosion effect
	spawn_explosion(missile.global_position)
	AudioManager.play_collision_sound(300)
	
	deactivate_missile(missile)

func _on_mine_triggered(body: Node, mine: Node2D):
	if not mine.get_meta("active"):
		return
	
	var owner = mine.get_meta("owner")
	if body == owner:
		return
	
	if body.has_method("take_damage"):
		body.take_damage(mine.get_meta("damage"), owner)
	
	# Shockwave effect
	spawn_shockwave(mine.global_position)
	AudioManager.play_collision_sound(400)
	
	deactivate_mine(mine)

func spawn_explosion(pos: Vector2):
	var explosion = Node2D.new()
	explosion.global_position = pos
	add_child(explosion)
	
	# Create expanding circles
	for i in range(3):
		var circle = Polygon2D.new()
		var points: PackedVector2Array = []
		var radius = 20 + i * 15
		for j in range(16):
			var angle = j * TAU / 16
			points.append(Vector2(cos(angle), sin(angle)) * radius)
		circle.polygon = points
		circle.color = Color(1.0, 0.5 - i * 0.15, 0.0, 0.8 - i * 0.2)
		explosion.add_child(circle)
	
	var tween = create_tween()
	tween.tween_property(explosion, "scale", Vector2(2.5, 2.5), 0.3)
	tween.parallel().tween_property(explosion, "modulate:a", 0.0, 0.3)
	tween.tween_callback(explosion.queue_free)

func spawn_shockwave(pos: Vector2):
	var wave = Node2D.new()
	wave.global_position = pos
	add_child(wave)
	
	var ring = Line2D.new()
	var points: PackedVector2Array = []
	for i in range(33):
		var angle = i * TAU / 32
		points.append(Vector2(cos(angle), sin(angle)) * 30)
	ring.points = points
	ring.width = 8.0
	ring.default_color = Color(0.8, 0.2, 1.0, 0.9)
	wave.add_child(ring)
	
	var tween = create_tween()
	tween.tween_property(wave, "scale", Vector2(4.0, 4.0), 0.4)
	tween.parallel().tween_property(ring, "default_color:a", 0.0, 0.4)
	tween.tween_callback(wave.queue_free)

func deactivate_missile(missile: Node2D):
	missile.set_meta("active", false)
	missile.visible = false
	var trail = missile.get_node_or_null("Trail") as Line2D
	if trail:
		trail.clear_points()

func deactivate_mine(mine: Node2D):
	mine.set_meta("active", false)
	mine.visible = false
	mine.scale = Vector2.ONE