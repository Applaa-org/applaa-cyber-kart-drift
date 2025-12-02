extends Node
class_name WeaponSystem

# Weapon projectile scenes would be instantiated here

static func create_plasma_missile(owner_kart: Node, target: Node = null) -> Node2D:
	var missile = Node2D.new()
	missile.set_script(PlasmaMissile)
	missile.owner_kart = owner_kart
	missile.target = target
	return missile

static func create_emp_blast(owner_kart: Node, radius: float) -> void:
	var karts = owner_kart.get_tree().get_nodes_in_group("karts")
	for kart in karts:
		if kart != owner_kart:
			var distance = owner_kart.global_position.distance_to(kart.global_position)
			if distance < radius:
				if kart.has_method("apply_emp"):
					kart.apply_emp(3.0)

static func create_shockwave_mine(owner_kart: Node) -> Node2D:
	var mine = Node2D.new()
	mine.set_script(ShockwaveMine)
	mine.owner_kart = owner_kart
	mine.global_position = owner_kart.global_position - Vector2(50, 0).rotated(owner_kart.rotation)
	return mine

# Plasma Missile class
class PlasmaMissile extends Area2D:
	var owner_kart: Node
	var target: Node
	var speed: float = 600.0
	var damage: int = 30
	var lifetime: float = 5.0
	var homing_strength: float = 3.0
	
	func _ready() -> void:
		# Setup collision
		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = 10
		shape.shape = circle
		add_child(shape)
		
		collision_layer = 4  # Weapons layer
		collision_mask = 2   # Karts layer
		
		body_entered.connect(_on_body_entered)
	
	func _physics_process(delta: float) -> void:
		lifetime -= delta
		if lifetime <= 0:
			queue_free()
			return
		
		# Homing behavior
		if target and is_instance_valid(target):
			var direction_to_target = (target.global_position - global_position).normalized()
			var current_direction = Vector2.RIGHT.rotated(rotation)
			var new_direction = current_direction.lerp(direction_to_target, homing_strength * delta)
			rotation = new_direction.angle()
		
		# Move forward
		position += Vector2.RIGHT.rotated(rotation) * speed * delta
	
	func _on_body_entered(body: Node) -> void:
		if body == owner_kart:
			return
		
		if body.has_method("take_damage"):
			body.take_damage(damage, owner_kart)
		
		# Explosion effect would go here
		queue_free()

# Shockwave Mine class
class ShockwaveMine extends Area2D:
	var owner_kart: Node
	var damage: int = 25
	var push_force: float = 400.0
	var arm_time: float = 1.0
	var lifetime: float = 15.0
	var is_armed: bool = false
	
	func _ready() -> void:
		var shape = CollisionShape2D.new()
		var circle = CircleShape2D.new()
		circle.radius = 30
		shape.shape = circle
		add_child(shape)
		
		collision_layer = 4
		collision_mask = 2
		
		body_entered.connect(_on_body_entered)
	
	func _physics_process(delta: float) -> void:
		if not is_armed:
			arm_time -= delta
			if arm_time <= 0:
				is_armed = true
		
		lifetime -= delta
		if lifetime <= 0:
			queue_free()
	
	func _on_body_entered(body: Node) -> void:
		if not is_armed:
			return
		
		if body == owner_kart:
			return
		
		if body.has_method("take_damage"):
			body.take_damage(damage, owner_kart)
		
		# Push effect
		var push_direction = (body.global_position - global_position).normalized()
		body.velocity += push_direction * push_force
		
		queue_free()