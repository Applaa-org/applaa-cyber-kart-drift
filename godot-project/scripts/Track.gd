extends Node2D
class_name Track

# Track Configuration
@export var track_name: String = "Neon Skyline"
@export var track_theme: String = "neon_skyline"
@export var total_checkpoints: int = 8
@export var lap_count: int = 3

# Track Components
var race_path: Path2D
var checkpoints: Array[Area2D] = []
var boost_pads: Array[Area2D] = []
var weapon_nodes: Array[Area2D] = []
var hazards: Array[Node2D] = []

# Visual layers
var background_layer: ParallaxBackground
var track_layer: Node2D
var effect_layer: Node2D

# Colors based on theme
var theme_colors: Dictionary = {
	"neon_skyline": {
		"primary": Color(0.0, 1.0, 1.0),
		"secondary": Color(1.0, 0.0, 0.8),
		"accent": Color(1.0, 0.8, 0.0),
		"background": Color(0.02, 0.01, 0.08)
	},
	"solar_canyon": {
		"primary": Color(1.0, 0.6, 0.2),
		"secondary": Color(0.9, 0.3, 0.1),
		"accent": Color(1.0, 0.9, 0.5),
		"background": Color(0.15, 0.08, 0.02)
	},
	"frostbyte": {
		"primary": Color(0.4, 0.8, 1.0),
		"secondary": Color(0.8, 0.9, 1.0),
		"accent": Color(0.0, 0.5, 1.0),
		"background": Color(0.02, 0.05, 0.12)
	},
	"quantum_rift": {
		"primary": Color(0.8, 0.2, 1.0),
		"secondary": Color(0.2, 1.0, 0.5),
		"accent": Color(1.0, 1.0, 0.0),
		"background": Color(0.05, 0.0, 0.1)
	},
	"overclocked_metro": {
		"primary": Color(1.0, 0.3, 0.3),
		"secondary": Color(0.3, 1.0, 0.3),
		"accent": Color(1.0, 1.0, 1.0),
		"background": Color(0.03, 0.03, 0.05)
	}
}

func _ready():
	setup_layers()

func setup_layers():
	# Background layer
	background_layer = ParallaxBackground.new()
	background_layer.name = "Background"
	add_child(background_layer)
	move_child(background_layer, 0)
	
	# Track layer
	track_layer = Node2D.new()
	track_layer.name = "TrackLayer"
	add_child(track_layer)
	
	# Effect layer (above track)
	effect_layer = Node2D.new()
	effect_layer.name = "EffectLayer"
	add_child(effect_layer)

func generate_track(track_data: Dictionary):
	track_name = track_data.get("name", "Track")
	track_theme = track_data.get("theme", "neon_skyline")
	
	var colors = theme_colors.get(track_theme, theme_colors["neon_skyline"])
	
	# Generate race path
	create_race_path(track_data.get("path_points", []))
	
	# Generate track visuals
	create_track_visuals(colors)
	
	# Generate checkpoints
	create_checkpoints(track_data.get("checkpoint_count", 8))
	
	# Generate boost pads
	create_boost_pads(track_data.get("boost_positions", []))
	
	# Generate weapon nodes
	create_weapon_nodes(track_data.get("weapon_positions", []))
	
	# Generate hazards
	create_hazards(track_data.get("hazards", []))
	
	# Create background
	create_background(colors)

func create_race_path(points: Array):
	race_path = Path2D.new()
	race_path.name = "RacePath"
	
	var curve = Curve2D.new()
	
	if points.size() == 0:
		# Default oval track
		points = generate_default_track_points()
	
	for point in points:
		if point is Vector2:
			curve.add_point(point)
		elif point is Dictionary:
			curve.add_point(
				point.get("position", Vector2.ZERO),
				point.get("in", Vector2.ZERO),
				point.get("out", Vector2.ZERO)
			)
	
	race_path.curve = curve
	track_layer.add_child(race_path)

func generate_default_track_points() -> Array:
	var points = []
	var center = Vector2(640, 360)
	var width = 500.0
	var height = 280.0
	
	# Create oval with control points for smooth curves
	points.append({
		"position": center + Vector2(width, 0),
		"in": Vector2(0, -height * 0.5),
		"out": Vector2(0, height * 0.5)
	})
	points.append({
		"position": center + Vector2(0, height),
		"in": Vector2(width * 0.5, 0),
		"out": Vector2(-width * 0.5, 0)
	})
	points.append({
		"position": center + Vector2(-width, 0),
		"in": Vector2(0, height * 0.5),
		"out": Vector2(0, -height * 0.5)
	})
	points.append({
		"position": center + Vector2(0, -height),
		"in": Vector2(-width * 0.5, 0),
		"out": Vector2(width * 0.5, 0)
	})
	
	return points

func create_track_visuals(colors: Dictionary):
	if not race_path or not race_path.curve:
		return
	
	var curve = race_path.curve
	var track_width = 120.0
	
	# Create track surface
	var track_surface = create_track_polygon(curve, track_width, colors.primary)
	track_layer.add_child(track_surface)
	
	# Create track borders
	var outer_border = create_track_line(curve, track_width * 0.5, 4.0, colors.secondary)
	var inner_border = create_track_line(curve, -track_width * 0.5, 4.0, colors.secondary)
	track_layer.add_child(outer_border)
	track_layer.add_child(inner_border)
	
	# Create center line (dashed)
	var center_line = create_track_line(curve, 0, 2.0, Color(colors.accent, 0.5))
	track_layer.add_child(center_line)
	
	# Add neon glow lines along track
	for offset in [-track_width * 0.4, track_width * 0.4]:
		var glow_line = create_track_line(curve, offset, 3.0, Color(colors.primary, 0.6))
		effect_layer.add_child(glow_line)

func create_track_polygon(curve: Curve2D, width: float, color: Color) -> Polygon2Dfunc create_track_polygon(curve: Curve2D, width: float, color: Color) -> Polygon2D:
	var polygon = Polygon2D.new()
	var points: PackedVector2Array = []
	
	var baked = curve.get_baked_points()
	var half_width = width * 0.5
	
	# Create outer edge
	for i in range(baked.size()):
		var pos = baked[i]
		var next_idx = (i + 1) % baked.size()
		var dir = (baked[next_idx] - pos).normalized()
		var normal = Vector2(-dir.y, dir.x)
		points.append(pos + normal * half_width)
	
	# Create inner edge (reversed)
	for i in range(baked.size() - 1, -1, -1):
		var pos = baked[i]
		var next_idx = (i + 1) % baked.size()
		var dir = (baked[next_idx] - pos).normalized()
		var normal = Vector2(-dir.y, dir.x)
		points.append(pos - normal * half_width)
	
	polygon.polygon = points
	polygon.color = Color(color, 0.3)
	return polygon

func create_track_line(curve: Curve2D, offset: float, line_width: float, color: Color) -> Line2D:
	var line = Line2D.new()
	var baked = curve.get_baked_points()
	
	var points: PackedVector2Array = []
	for i in range(baked.size()):
		var pos = baked[i]
		var next_idx = (i + 1) % baked.size()
		var dir = (baked[next_idx] - pos).normalized()
		var normal = Vector2(-dir.y, dir.x)
		points.append(pos + normal * offset)
	
	# Close the loop
	if points.size() > 0:
		points.append(points[0])
	
	line.points = points
	line.width = line_width
	line.default_color = color
	return line

func create_checkpoints(count: int):
	if not race_path or not race_path.curve:
		return
	
	var curve = race_path.curve
	var curve_length = curve.get_baked_length()
	
	for i in range(count):
		var progress = float(i) / float(count)
		var pos = curve.sample_baked(progress * curve_length)
		var next_pos = curve.sample_baked((progress + 0.01) * curve_length)
		var dir = (next_pos - pos).normalized()
		var angle = dir.angle()
		
		var checkpoint = create_checkpoint(i, pos, angle)
		checkpoints.append(checkpoint)
		track_layer.add_child(checkpoint)
	
	# Register with race manager
	var race_manager = get_tree().get_first_node_in_group("race_manager")
	if race_manager:
		for i in range(checkpoints.size()):
			race_manager.register_checkpoint(checkpoints[i], i)

func create_checkpoint(index: int, pos: Vector2, angle: float) -> Area2D:
	var checkpoint = Area2D.new()
	checkpoint.name = "Checkpoint_%d" % index
	checkpoint.position = pos
	checkpoint.rotation = angle
	checkpoint.collision_layer = 0
	checkpoint.collision_mask = 1  # Detect karts
	
	# Collision shape (wide gate)
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(20, 150)
	collision.shape = shape
	checkpoint.add_child(collision)
	
	# Visual gate
	var colors = theme_colors.get(track_theme, theme_colors["neon_skyline"])
	
	# Gate posts
	for offset in [-60, 60]:
		var post = Polygon2D.new()
		post.polygon = PackedVector2Array([
			Vector2(-5, offset - 10), Vector2(5, offset - 10),
			Vector2(5, offset + 10), Vector2(-5, offset + 10)
		])
		post.color = colors.secondary
		checkpoint.add_child(post)
	
	# Gate beam (finish line is special)
	var beam = Line2D.new()
	beam.points = PackedVector2Array([Vector2(0, -60), Vector2(0, 60)])
	beam.width = 4.0
	beam.default_color = Color(colors.primary, 0.7) if index > 0 else Color(1.0, 1.0, 1.0, 0.9)
	checkpoint.add_child(beam)
	
	# Index label
	var label = Label.new()
	label.text = "START" if index == 0 else str(index)
	label.position = Vector2(-20, -80)
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", colors.accent)
	checkpoint.add_child(label)
	
	# Connect signal
	checkpoint.body_entered.connect(_on_checkpoint_entered.bind(index))
	
	return checkpoint

func _on_checkpoint_entered(body: Node, checkpoint_index: int):
	if body.has_method("pass_checkpoint"):
		body.pass_checkpoint(checkpoint_index)
		
		# Check for lap completion (checkpoint 0 is start/finish)
		if checkpoint_index == 0 and body.checkpoint_index >= checkpoints.size() - 1:
			if body.has_method("complete_lap"):
				body.complete_lap()

func create_boost_pads(positions: Array):
	if positions.size() == 0 and race_path and race_path.curve:
		# Auto-generate boost pad positions
		var curve = race_path.curve
		var curve_length = curve.get_baked_length()
		var pad_count = 6
		
		for i in range(pad_count):
			var progress = (float(i) / float(pad_count)) + 0.05
			var pos = curve.sample_baked(progress * curve_length)
			var next_pos = curve.sample_baked((progress + 0.01) * curve_length)
			var angle = (next_pos - pos).angle()
			positions.append({"position": pos, "angle": angle})
	
	for pad_data in positions:
		var pos = pad_data.get("position", Vector2.ZERO)
		var angle = pad_data.get("angle", 0.0)
		var boost_pad = create_boost_pad(pos, angle)
		boost_pads.append(boost_pad)
		track_layer.add_child(boost_pad)

func create_boost_pad(pos: Vector2, angle: float) -> Area2D:
	var pad = Area2D.new()
	pad.name = "BoostPad"
	pad.position = pos
	pad.rotation = angle
	pad.collision_layer = 0
	pad.collision_mask = 1
	
	var colors = theme_colors.get(track_theme, theme_colors["neon_skyline"])
	
	# Visual - arrow shaped pad
	var visual = Polygon2D.new()
	visual.polygon = PackedVector2Array([
		Vector2(-30, -20), Vector2(30, -20), Vector2(40, 0),
		Vector2(30, 20), Vector2(-30, 20), Vector2(-20, 0)
	])
	visual.color = Color(colors.accent, 0.6)
	pad.add_child(visual)
	
	# Arrow indicators
	for i in range(3):
		var arrow = Polygon2D.new()
		arrow.polygon = PackedVector2Array([
			Vector2(-10 + i * 15, -8), Vector2(0 + i * 15, 0), Vector2(-10 + i * 15, 8)
		])
		arrow.color = colors.primary
		pad.add_child(arrow)
	
	# Collision
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(60, 40)
	collision.shape = shape
	pad.add_child(collision)
	
	pad.body_entered.connect(_on_boost_pad_entered)
	
	return pad

func _on_boost_pad_entered(body: Node):
	if body.has_method("hit_boost_pad"):
		body.hit_boost_pad(25.0)
		AudioManager.play_sfx("boost_pad")

func create_weapon_nodes(positions: Array):
	if positions.size() == 0 and race_path and race_path.curve:
		# Auto-generate weapon node positions
		var curve = race_path.curve
		var curve_length = curve.get_baked_length()
		var node_count = 8
		
		for i in range(node_count):
			var progress = (float(i) / float(node_count)) + 0.1
			var pos = curve.sample_baked(progress * curve_length)
			# Offset slightly from center
			var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
			positions.append(pos + offset)
	
	for pos in positions:
		var weapon_node = create_weapon_node(pos)
		weapon_nodes.append(weapon_node)
		track_layer.add_child(weapon_node)

func create_weapon_node(pos: Vector2) -> Area2D:
	var node = Area2D.new()
	node.name = "WeaponNode"
	node.position = pos
	node.collision_layer = 8  # Collectibles layer
	node.collision_mask = 1
	
	var colors = theme_colors.get(track_theme, theme_colors["neon_skyline"])
	
	# Floating orb visual
	var orb = Node2D.new()
	orb.name = "Orb"
	node.add_child(orb)
	
	# Outer ring
	var ring = Line2D.new()
	var ring_points: PackedVector2Array = []
	for i in range(17):
		var angle = i * TAU / 16
		ring_points.append(Vector2(cos(angle), sin(angle)) * 18)
	ring.points = ring_points
	ring.width = 3.0
	ring.default_color = colors.secondary
	orb.add_child(ring)
	
	# Inner core
	var core = Polygon2D.new()
	var core_points: PackedVector2Array = []
	for i in range(8):
		var angle = i * TAU / 8
		core_points.append(Vector2(cos(angle), sin(angle)) * 10)
	core.polygon = core_points
	core.color = colors.primary
	orb.add_child(core)
	
	# Question mark or icon
	var icon = Label.new()
	icon.text = "?"
	icon.position = Vector2(-6, -12)
	icon.add_theme_font_size_override("font_size", 18)
	icon.add_theme_color_override("font_color", Color.WHITE)
	orb.add_child(icon)
	
	# Collision
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 20.0
	collision.shape = shape
	node.add_child(collision)
	
	# Animation
	node.set_meta("base_y", pos.y)
	node.set_meta("active", true)
	node.set_meta("respawn_timer", 0.0)
	
	node.body_entered.connect(_on_weapon_node_collected.bind(node))
	
	return node

func _on_weapon_node_collected(body: Node, weapon_node: Area2D):
	if not weapon_node.get_meta("active"):
		return
	
	if body.has_method("collect_weapon"):
		# Random weapon selection
		var weapons = [
			"PlasmaMissile", "EMPBlast", "ArcShot", "ShockwaveMine",
			"InfernoRocket", "PulseShield", "ReflectorOrb", "NanoRepair"
		]
		var weapon = weapons[randi() % weapons.size()]
		body.collect_weapon(weapon, 1)
		
		# Deactivate and start respawn timer
		weapon_node.set_meta("active", false)
		weapon_node.set_meta("respawn_timer", 5.0)
		weapon_node.get_node("Orb").visible = false

func create_hazards(hazard_data: Array):
	var colors = theme_colors.get(track_theme, theme_colors["neon_skyline"])
	
	# Add theme-specific hazards if none provided
	if hazard_data.size() == 0:
		match track_theme:
			"neon_skyline":
				# Laser barriers
				if race_path and race_path.curve:
					var curve = race_path.curve
					var length = curve.get_baked_length()
					hazard_data.append({
						"type": "laser_barrier",
						"position": curve.sample_baked(length * 0.3),
						"rotation": 0
					})
			"solar_canyon":
				# Sand traps
				hazard_data.append({
					"type": "slow_zone",
					"position": Vector2(400, 300),
					"radius": 50
				})
			"frostbyte":
				# Ice patches
				hazard_data.append({
					"type": "ice_patch",
					"position": Vector2(600, 400),
					"radius": 40
				})
	
	for data in hazard_data:
		var hazard = create_hazard(data, colors)
		if hazard:
			hazards.append(hazard)
			track_layer.add_child(hazard)

func create_hazard(data: Dictionary, colors: Dictionary) -> Node2D:
	var hazard_type = data.get("type", "laser_barrier")
	var pos = data.get("position", Vector2.ZERO)
	
	match hazard_type:
		"laser_barrier":
			return create_laser_barrier(pos, data.get("rotation", 0), colors)
		"slow_zone":
			return create_slow_zone(pos, data.get("radius", 50), colors)
		"ice_patch":
			return create_ice_patch(pos, data.get("radius", 40))
		"emp_zone":
			return create_emp_zone(pos, data.get("radius", 60), colors)
	
	return null

func create_laser_barrier(pos: Vector2, angle: float, colors: Dictionary) -> Area2D:
	var barrier = Area2D.new()
	barrier.name = "LaserBarrier"
	barrier.position = pos
	barrier.rotation = angle
	barrier.collision_layer = 16  # Hazards layer
	barrier.collision_mask = 1
	
	# Barrier posts
	for offset in [-50, 50]:
		var post = Polygon2D.new()
		post.polygon = PackedVector2Array([
			Vector2(-8, offset - 8), Vector2(8, offset - 8),
			Vector2(8, offset + 8), Vector2(-8, offset + 8)
		])
		post.color = Color(0.3, 0.3, 0.4)
		barrier.add_child(post)
	
	# Laser beam
	var beam = Line2D.new()
	beam.name = "Beam"
	beam.points = PackedVector2Array([Vector2(0, -50), Vector2(0, 50)])
	beam.width = 6.0
	beam.default_color = Color(1.0, 0.2, 0.2, 0.9)
	barrier.add_child(beam)
	
	# Collision
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(10, 100)
	collision.shape = shape
	barrier.add_child(collision)
	
	# Toggle animation
	barrier.set_meta("active", true)
	barrier.set_meta("toggle_timer", randf_range(2.0, 4.0))
	
	barrier.body_entered.connect(_on_laser_hit)
	
	return barrier

func _on_laser_hit(body: Node):
	if body.has_method("take_damage"):
		body.take_damage(25)

func create_slow_zone(pos: Vector2, radius: float, colors: Dictionary) -> Area2D:
	var zone = Area2D.new()
	zone.name = "SlowZone"
	zone.position = pos
	zone.collision_layer = 16
	zone.collision_mask = 1
	
	# Visual
	var visual = Polygon2D.new()
	var points: PackedVector2Array = []
	for i in range(24):
		var angle = i * TAU / 24
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	visual.polygon = points
	visual.color = Color(0.8, 0.6, 0.2, 0.4)
	zone.add_child(visual)
	
	# Collision
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = radius
	collision.shape = shape
	zone.add_child(collision)
	
	zone.body_entered.connect(func(body):
		if body.has_method("apply_effect"):
			body.apply_effect("slow", 1.0)
	)
	
	return zone

func create_ice_patch(pos: Vector2, radius: float) -> Area2D:
	var patch = Area2D.new()
	patch.name = "IcePatch"
	patch.position = pos
	patch.collision_layer = 16
	patch.collision_mask = 1
	
	# Visual
	var visual = Polygon2D.new()
	var points: PackedVector2Array = []
	for i in range(20):
		var angle = i * TAU / 20
		var r = radius * (0.8 + randf() * 0.4)
		points.append(Vector2(cos(angle), sin(angle)) * r)
	visual.polygon = points
	visual.color = Color(0.7, 0.9, 1.0, 0.5)
	patch.add_child(visual)
	
	# Collision
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = radius
	collision.shape = shape
	patch.add_child(collision)
	
	patch.body_entered.connect(func(body):
		if body.has_method("apply_effect"):
			body.apply_effect("spin", 0.5)
	)
	
	return patch

func create_emp_zone(pos: Vector2, radius: float, colors: Dictionary) -> Area2D:
	var zone = Area2D.new()
	zone.name = "EMPZone"
	zone.position = pos
	zone.collision_layer = 16
	zone.collision_mask = 1
	
	# Visual
	var visual = Polygon2D.new()
	var points: PackedVector2Array = []
	for i in range(24):
		var angle = i * TAU / 24
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	visual.polygon = points
	visual.color = Color(0.2, 0.5, 1.0, 0.3)
	zone.add_child(visual)
	
	# Electric effect lines
	for i in range(6):
		var line = Line2D.new()
		var angle = i * TAU / 6
		line.points = PackedVector2Array([
			Vector2.ZERO,
			Vector2(cos(angle), sin(angle)) * radius * 0.8
		])
		line.width = 2.0
		line.default_color = Color(0.4, 0.8, 1.0, 0.6)
		zone.add_child(line)
	
	# Collision
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = radius
	collision.shape = shape
	zone.add_child(collision)
	
	zone.body_entered.connect(func(body):
		if body.has_method("apply_effect"):
			body.apply_effect("disable_boost", 2.0)
	)
	
	return zone

func create_background(colors: Dictionary):
	# Create parallax layers
	var layer1 = ParallaxLayer.new()
	layer1.motion_scale = Vector2(0.2, 0.2)
	background_layer.add_child(layer1)
	
	# Background color rect
	var bg_rect = ColorRect.new()
	bg_rect.color = colors.background
	bg_rect.size = Vector2(3000, 2000)
	bg_rect.position = Vector2(-1000, -500)
	layer1.add_child(bg_rect)
	
	# Add stars/lights
	var stars_layer = ParallaxLayer.new()
	stars_layer.motion_scale = Vector2(0.3, 0.3)
	background_layer.add_child(stars_layer)
	
	var stars_container = Node2D.new()
	stars_layer.add_child(stars_container)
	
	for i in range(100):
		var star = Polygon2D.new()
		var size = randf_range(1, 3)
		star.polygon = PackedVector2Array([
			Vector2(-size, 0), Vector2(0, -size),
			Vector2(size, 0), Vector2(0, size)
		])
		star.color = Color(colors.primary, randf_range(0.3, 0.8))
		star.position = Vector2(randf_range(-500, 1800), randf_range(-200, 900))
		stars_container.add_child(star)
	
	# Add city silhouettes or theme-appropriate background elements
	var buildings_layer = ParallaxLayer.new()
	buildings_layer.motion_scale = Vector2(0.5, 0.5)
	background_layer.add_child(buildings_layer)
	
	create_background_elements(buildings_layer, colors)

func create_background_elements(layer: ParallaxLayer, colors: Dictionary):
	var container = Node2D.new()
	layer.add_child(container)
	
	match track_theme:
		"neon_skyline":
			# City buildings
			for i in range(15):
				var building = create_building(colors)
				building.position = Vector2(i * 150 - 200, 600)
				container.add_child(building)
		"solar_canyon":
			# Rock formations
			for i in range(10):
				var rock = create_rock(colors)
				rock.position = Vector2(i * 200 - 100, 550)
				container.add_child(rock)
		"frostbyte":
			# Ice pillars
			for i in range(12):
				var pillar = create_ice_pillar(colors)
				pillar.position = Vector2(i * 160 - 150, 580)
				container.add_child(pillar)
		"quantum_rift":
			# Floating anomalies
			for i in range(8):
				var anomaly = create_anomaly(colors)
				anomaly.position = Vector2(randf_range(0, 1280), randf_range(100, 500))
				container.add_child(anomaly)
		"overclocked_metro":
			# Train tracks and structures
			for i in range(10):
				var structure = create_metro_structure(colors)
				structure.position = Vector2(i * 180 - 100, 550)
				container.add_child(structure)

func create_building(colors: Dictionary) -> Node2D:
	var building = Node2D.new()
	
	var width = randf_range(40, 80)
	var height = randf_range(100, 300)
	
	var body = Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-width/2, 0), Vector2(width/2, 0),
		Vector2(width/2, -height), Vector2(-width/2, -height)
	])
	body.color = Color(0.05, 0.05, 0.1)
	building.add_child(body)
	
	# Windows
	for row in range(int(height / 20)):
		for col in range(int(width / 15)):
			if randf() > 0.3:
				var window = Polygon2D.new()
				window.polygon = PackedVector2Array([
					Vector2(0, 0), Vector2(8, 0), Vector2(8, 10), Vector2(0, 10)
				])
				window.position = Vector2(-width/2 + 5 + col * 15, -15 - row * 20)
				window.color = Color(colors.primary, randf_range(0.3, 0.8)) if randf() > 0.5 else Color(colors.secondary, randf_range(0.3, 0.8))
				building.add_child(window)
	
	return building

func create_rock(colors: Dictionary) -> Node2D:
	var rock = Node2D.new()
	
	var points: PackedVector2Array = []
	var segments = randi_range(5, 8)
	for i in range(segments):
		var angle = i * TAU / segments - PI/2
		var r = randf_range(30, 80)
		points.append(Vector2(cos(angle) * r, sin(angle) * r * 1.5))
	
	var body = Polygon2D.new()
	body.polygon = points
	body.color = Color(colors.secondary, 0.6)
	rock.add_child(body)
	
	return rock

func create_ice_pillar(colors: Dictionary) -> Node2D:
	var pillar = Node2D.new()
	
	var width = randf_range(20, 40)
	var height = randf_range(80, 200)
	
	var body = Polygon2D.new()
	body.polygon = PackedVector2Array([
		Vector2(-width/2, 0), Vector2(width/2, 0),
		Vector2(width/3, -height), Vector2(-width/3, -height)
	])
	body.color = Color(colors.primary, 0.5)
	pillar.add_child(body)
	
	return pillar

func create_anomaly(colors: Dictionary) -> Node2D:
	var anomaly = Node2D.new()
	
	var ring = Line2D.new()
	var points: PackedVector2Array = []
	var radius = randf_range(20, 50)
	for i in range(17):
		var angle = i * TAU / 16
		points.append(Vector2(cos(angle), sin(angle)) * radius)
	ring.points = points
	ring.width = 3.0
	ring.default_color = Color(colors.primary, 0.6)
	anomaly.add_child(ring)
	
	return anomaly

func create_metro_structure(colors: Dictionary) -> Node2D:
	var structure = Node2D.new()
	
	# Support beam
	var beam = Polygon2D.new()
	beam.polygon = PackedVector2Array([
		Vector2(-10, 0), Vector2(10, 0),
		Vector2(8, -150), Vector2(-8, -150)
	])
	beam.color = Color(0.2, 0.2, 0.25)
	structure.add_child(beam)
	
	# Rail
	var rail = Line2D.new()
	rail.points = PackedVector2Array([Vector2(-50, -150), Vector2(50, -150)])
	rail.width = 5.0
	rail.default_color = colors.secondary
	structure.add_child(rail)
	
	return structure

func _process(delta: float):
	# Update weapon node respawns
	for node in weapon_nodes:
		if not node.get_meta("active"):
			var timer = node.get_meta("respawn_timer") - delta
			node.set_meta("respawn_timer", timer)
			if timer <= 0:
				node.set_meta("active", true)
				node.get_node("Orb").visible = true
	
	# Animate weapon nodes (floating)
	for node in weapon_nodes:
		if node.get_meta("active"):
			var base_y = node.get_meta("base_y")
			node.position.y = base_y + sin(Time.get_ticks_msec() * 0.003) * 5
			node.get_node("Orb").rotation += delta * 2.0
	
	# Update hazard animations
	for hazard in hazards:
		if hazard.name.begins_with("LaserBarrier"):
			var timer = hazard.get_meta("toggle_timer") - delta
			if timer <= 0:
				var active = not hazard.get_meta("active")
				hazard.set_meta("active", active)
				hazard.get_node("Beam").visible = active
				hazard.get_child(hazard.get_child_count() - 1).disabled = not active  # Collision
				hazard.set_meta("toggle_timer", randf_range(2.0, 4.0))
			else:
				hazard.set_meta("toggle_timer", timer)

func get_race_path() -> Path2D:
	return race_path

func get_start_positions(count: int) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	
	if race_path and race_path.curve:
		var curve = race_path.curve
		var start_pos = curve.sample_baked(0)
		var next_pos = curve.sample_baked(50)
		var dir = (next_pos - start_pos).normalized()
		var perpendicular = Vector2(-dir.y, dir.x)
		
		for i in range(count):
			var row = i / 2
			var col = i % 2
			var offset = perpendicular * (col * 60 - 30) - dir * (row * 50 + 30)
			positions.append(start_pos + offset)
	else:
		# Default positions
		for i in range(count):
			positions.append(Vector2(200 + i * 50, 360 + (i % 2) * 40))
	
	return positions

func get_start_rotation() -> float:
	if race_path and race_path.curve:
		var curve = race_path.curve
		var start_pos = curve.sample_baked(0)
		var next_pos = curve.sample_baked(50)
		return (next_pos - start_pos).angle()
	return 0.0