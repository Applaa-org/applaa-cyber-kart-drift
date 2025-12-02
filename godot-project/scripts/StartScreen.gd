extends Control

# UI References
var title_label: Label
var mode_container: VBoxContainer
var kart_container: VBoxContainer
var track_container: VBoxContainer
var start_button: Button
var close_button: Button
var current_panel: String = "main"

# Selected options
var selected_mode: String = "single_race"<applaa-write path="godot-project/scripts/StartScreen.gd" description="Start screen with menu, kart selection, and game mode options">
extends Control

# UI References
var title_label: Label
var mode_container: VBoxContainer
var kart_container: VBoxContainer
var track_container: VBoxContainer
var start_button: Button
var close_button: Button
var current_panel: String = "main"

# Selected options
var selected_mode: String = "single_race"
var selected_kart: String = "Balanced"
var selected_track: String = "neon_skyline_1"

# Animation
var title_glow_tween: Tween
var background_particles: Array[Node2D] = []

func _ready():
	setup_ui()
	setup_background()
	animate_title()
	
	# Set initial global state
	Global.current_state = Global.GameState.MENU

func setup_ui():
	# Main container
	var main_container = VBoxContainer.new()
	main_container.name = "MainContainer"
	main_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	main_container.add_theme_constant_override("separation", 20)
	add_child(main_container)
	
	# Top spacer
	var top_spacer = Control.new()
	top_spacer.custom_minimum_size = Vector2(0, 80)
	main_container.add_child(top_spacer)
	
	# Title
	var title_container = CenterContainer.new()
	main_container.add_child(title_container)
	
	title_label = Label.new()
	title_label.text = "CYBER KART DRIFT"
	title_label.add_theme_font_size_override("font_size", 64)
	title_label.add_theme_color_override("font_color", Color(0.0, 1.0, 1.0))
	title_label.add_theme_color_override("font_shadow_color", Color(1.0, 0.0, 0.8, 0.5))
	title_label.add_theme_constant_override("shadow_offset_x", 3)
	title_label.add_theme_constant_override("shadow_offset_y", 3)
	title_container.add_child(title_label)
	
	# Subtitle
	var subtitle_container = CenterContainer.new()
	main_container.add_child(subtitle_container)
	
	var subtitle = Label.new()
	subtitle.text = "Anti-Gravity Racing • Weapons • Drift Combat"
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	subtitle_container.add_child(subtitle)
	
	# Spacer
	var mid_spacer = Control.new()
	mid_spacer.custom_minimum_size = Vector2(0, 40)
	main_container.add_child(mid_spacer)
	
	# Menu panels container
	var panels_center = CenterContainer.new()
	panels_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_container.add_child(panels_center)
	
	var panels_container = VBoxContainer.new()
	panels_container.name = "PanelsContainer"
	panels_container.add_theme_constant_override("separation", 15)
	panels_center.add_child(panels_container)
	
	# Main menu panel
	create_main_menu_panel(panels_container)
	
	# Mode selection panel
	create_mode_panel(panels_container)
	
	# Kart selection panel
	create_kart_panel(panels_container)
	
	# Track selection panel
	create_track_panel(panels_container)
	
	# Bottom buttons
	var bottom_container = HBoxContainer.new()
	bottom_container.add_theme_constant_override("separation", 20)
	bottom_container.alignment = BoxContainer.ALIGNMENT_CENTER
	main_container.add_child(bottom_container)
	
	# Close button
	close_button = create_styled_button("QUIT GAME", Color(0.8, 0.2, 0.2))
	close_button.pressed.connect(_on_close_pressed)
	bottom_container.add_child(close_button)
	
	# Bottom spacer
	var bottom_spacer = Control.new()
	bottom_spacer.custom_minimum_size = Vector2(0, 30)
	main_container.add_child(bottom_spacer)
	
	# Show main menu by default
	show_panel("main")

func create_main_menu_panel(parent: Control):
	var panel = PanelContainer.new()
	panel.name = "MainMenuPanel"
	setup_panel_style(panel)
	parent.add_child(panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 15)
	margin.add_child(vbox)
	
	# Menu buttons
	var quick_race_btn = create_styled_button("⚡ QUICK RACE", Color(0.0, 1.0, 0.5))
	quick_race_btn.pressed.connect(_on_quick_race_pressed)
	vbox.add_child(quick_race_btn)
	
	var mode_btn = create_styled_button("🏁 SELECT MODE", Color(0.0, 0.8, 1.0))
	mode_btn.pressed.connect(func(): show_panel("mode"))
	vbox.add_child(mode_btn)
	
	var kart_btn = create_styled_button("🚗 SELECT KART", Color(1.0, 0.8, 0.0))
	kart_btn.pressed.connect(func(): show_panel("kart"))
	vbox.add_child(kart_btn)
	
	var track_btn = create_styled_button("🗺️ SELECT TRACK", Color(0.8, 0.4, 1.0))
	track_btn.pressed.connect(func(): show_panel("track"))
	vbox.add_child(track_btn)
	
	# Controls info
	var controls_label = Label.new()
	controls_label.text = "\n📋 CONTROLS\nW/↑ = Accelerate | S/↓ = Brake\nA/D or ←/→ = Steer\nSPACE = Drift | E = Boost | Q = Special\nLMB/SPACE = Fire Weapon | ESC = Pause"
	controls_label.add_theme_font_size_override("font_size", 14)
	controls_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	controls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(controls_label)

func create_mode_panel(parent: Control):
	var panel = PanelContainer.new()
	panel.name = "ModePanel"
	panel.visible = false
	setup_panel_style(panel)
	parent.add_child(panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "SELECT GAME MODE"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.0, 1.0, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	mode_container = VBoxContainer.new()
	mode_container.add_theme_constant_override("separation", 8)
	vbox.add_child(mode_container)
	
	var modes = [
		{"id": "single_race", "name": "🏎️ Single Race", "desc": "One race, pick your track"},
		{"id": "grand_prix", "name": "🏆 Grand Prix", "desc": "4 races, compete for championship"},
		{"id": "time_trial", "name": "⏱️ Time Trial", "desc": "Race against the clock"},
		{"id": "battle_arena", "name": "⚔️ Battle Arena", "desc": "Combat focused, weapons galore"},
		{"id": "elimination", "name": "💀 Elimination", "desc": "Last place eliminated every 20s"},
		{"id": "drift_trial", "name": "🌀 Drift Trial", "desc": "Score points with epic drifts"}
	]
	
	for mode in modes:
		var btn = create_mode_button(mode.id, mode.name, mode.desc)
		mode_container.add_child(btn)
	
	var back_btn = create_styled_button("← BACK", Color(0.5, 0.5, 0.5))
	back_btn.pressed.connect(func(): show_panel("main"))
	vbox.add_child(back_btn)

func create_kart_panel(parent: Control):
	var panel = PanelContainer.new()
	panel.name = "KartPanel"
	panel.visible = false
	setup_panel_style(panel)
	parent.add_child(panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "SELECT KART CLASS"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	kart_container = VBoxContainer.new()
	kart_container.add_theme_constant_override("separation", 8)
	vbox.add_child(kart_container)
	
	for kart_name in Global.kart_classes.keys():
		var kart = Global.kart_classes[kart_name]
		var btn = create_kart_button(kart_name, kart)
		kart_container.add_child(btn)
	
	var back_btn = create_styled_button("← BACK", Color(0.5, 0.5, 0.5))
	back_btn.pressed.connect(func(): show_panel("main"))
	vbox.add_child(back_btn)

func create_track_panel(parent: Control):
	var panel = PanelContainer.new()
	panel.name = "TrackPanel"
	panel.visible = false
	setup_panel_style(panel)
	parent.add_child(panel)
	
	var margin = MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 40)
	margin.add_theme_constant_override("margin_right", 40)
	margin.add_theme_constant_override("margin_top", 30)
	margin.add_theme_constant_override("margin_bottom", 30)
	panel.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 12)
	margin.add_child(vbox)
	
	var title = Label.new()
	title.text = "SELECT TRACK"
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(0.8, 0.4, 1.0))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(title)
	
	track_container = VBoxContainer.new()
	track_container.add_theme_constant_override("separation", 8)
	vbox.add_child(track_container)
	
	var tracks = [
		{"id": "neon_skyline_1", "name": "🌃 Neon Skyline - Night Boulevard", "theme": "neon_skyline"},
		{"id": "neon_skyline_2", "name": "🌃 Neon Skyline - Hologram Heights", "theme": "neon_skyline"},
		{"id": "solar_canyon_1", "name": "🏜️ Solar Canyon - Desert Driftway", "theme": "solar_canyon"},
		{"id": "frostbyte_1", "name": "❄️ Frostbyte - Ice Loop Arena", "theme": "frostbyte"},
		{"id": "quantum_rift_1", "name": "🌀 Quantum Rift - Anomaly Zone", "theme": "quantum_rift"},
		{"id": "metro_1", "name": "🚇 Overclocked Metro - Rail Runner", "theme": "overclocked_metro"}
	]
	
	for track in tracks:
		var btn = create_track_button(track.id, track.name, track.theme)
		track_container.add_child(btn)
	
	var back_btn = create_styled_button("← BACK", Color(0.5, 0.5, 0.5))
	back_btn.pressed.connect(func(): show_panel("main"))
	vbox.add_child(back_btn)

func create_styled_button(text: String, color: Color) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(300, 50)
	
	# Create style
	var style = StyleBoxFlat.new()
	style.bg_color = Color(color, 0.3)
	style.border_color = color
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	style.set_content_margin_all(10)
	
	var hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color(color, 0.5)
	hover_style.border_color = color
	hover_style.set_border_width_all(3)
	hover_style.set_corner_radius_all(8)
	hover_style.set_content_margin_all(10)
	
	var pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = Color(color, 0.7)
	pressed_style.border_color = Color.WHITE
	pressed_style.set_border_width_all(3)
	pressed_style.set_corner_radius_all(8)
	pressed_style.set_content_margin_all(10)
	
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_stylebox_override("hover", hover_style)
	button.add_theme_stylebox_override("pressed", pressed_style)
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	
	return button

func create_mode_button(mode_id: String, mode_name: String, description: String) -> Button:
	var button = Button.new()
	button.text = mode_name + "\n" + description
	button.custom_minimum_size = Vector2(350, 60)
	
	var is_selected = mode_id == selected_mode
	var color = Color(0.0, 1.0, 0.8) if is_selected else Color(0.3, 0.3, 0.4)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(color, 0.3)
	style.border_color = color
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(8)
	
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", Color.WHITE)
	
	button.pressed.connect(func(): select_mode(mode_id))
	
	return button

func create_kart_button(kart_name: String, kart_data: Dictionary) -> Button:
	var button = Button.new()
	
	var stats_text = "SPD:%d ACC:%d HDL:%.1f BST:%.1f" % [
		kart_data.speed, kart_data.acceleration, 
		kart_data.handling, kart_data.boost_power
	]
	button.text = kart_name + " - " + kart_data.special.replace("_", " ").capitalize() + "\n" + stats_text
	button.custom_minimum_size = Vector2(400, 60)
	
	var is_selected = kart_name == selected_kart
	var color = kart_data.color if is_selected else Color(0.3, 0.3, 0.4)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(color, 0.3)
	style.border_color = color
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(8)
	
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", Color.WHITE)
	
	button.pressed.connect(func(): select_kart(kart_name))
	
	return button

func create_track_button(track_id: String, track_name: String, theme: String) -> Button:
	var button = Button.new()
	button.text = track_name
	button.custom_minimum_size = Vector2(400, 45)
	
	var is_selected = track_id == selected_track
	var theme_colors = {
		"neon_skyline": Color(0.0, 1.0, 1.0),
		"solar_canyon": Color(1.0, 0.6, 0.2),
		"frostbyte": Color(0.4, 0.8, 1.0),
		"quantum_rift": Color(0.8, 0.2, 1.0),
		"overclocked_metro": Color(1.0, 0.3, 0.3)
	}
	var color = theme_colors.get(theme, Color(0.5, 0.5, 0.5))
	if not is_selected:
		color = Color(0.3, 0.3, 0.4)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(color, 0.3)
	style.border_color = color
	style.set_border_width_all(2)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(8)
	
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_color", Color.WHITE)
	
	button.pressed.connect(func(): select_track(track_id, theme))
	
	return button

func setup_panel_style(panel: PanelContainer):
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.05, 0.05, 0.1, 0.9)
	style.border_color = Color(0.0, 1.0, 1.0, 0.5)
	style.set_border_width_all(2)
	style.set_corner_radius_all(12)
	panel.add_theme_stylebox_override("panel", style)

func show_panel(panel_name: String):
	current_panel = panel_name
	
	var panels = get_node("MainContainer/PanelsContainer")
	if panels:
		panels.get_node("MainMenuPanel").visible = (panel_name == "main")
		panels.get_node("ModePanel").visible = (panel_name == "mode")
		panels.get_node("KartPanel").visible = (panel_name == "kart")
		panels.get_node("TrackPanel").visible = (panel_name == "track")

func select_mode(mode_id: String):
	selected_mode = mode_id
	Global.selected_game_mode = mode_id
	refresh_mode_buttons()

func select_kart(kart_name: String):
	selected_kart = kart_name
	Global.select_kart_class(kart_name)
	refresh_kart_buttons()

func select_track(track_id: String, theme: String):
	selected_track = track_id
	Global.selected_track = track_id
	refresh_track_buttons()

func refresh_mode_buttons():
	# Rebuild mode buttons with new selection
	for child in mode_container.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	var modes = [
		{"id": "single_race", "name": "🏎️ Single Race", "desc": "One race, pick your track"},
		{"id": "grand_prix", "name": "🏆 Grand Prix", "desc": "4 races, compete for championship"},
		{"id": "time_trial", "name": "⏱️ Time Trial", "desc": "Race against the clock"},
		{"id": "battle_arena", "name": "⚔️ Battle Arena", "desc": "Combat focused, weapons galore"},
		{"id": "elimination", "name": "💀 Elimination", "desc": "Last place eliminated every 20s"},
		{"id": "drift_trial", "name": "🌀 Drift Trial", "desc": "Score points with epic drifts"}
	]
	
	for mode in modes:
		var btn = create_mode_button(mode.id, mode.name, mode.desc)
		mode_container.add_child(btn)

func refresh_kart_buttons():
	for child in kart_container.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	for kart_name in Global.kart_classes.keys():
		var kart = Global.kart_classes[kart_name]
		var btn = create_kart_button(kart_name, kart)
		kart_container.add_child(btn)

func refresh_track_buttons():
	for child in track_container.get_children():
		child.queue_free()
	
	await get_tree().process_frame
	
	var tracks = [
		{"id": "neon_skyline_1", "name": "🌃 Neon Skyline - Night Boulevard", "theme": "neon_skyline"},
		{"id": "neon_skyline_2", "name": "🌃 Neon Skyline - Hologram Heights", "theme": "neon_skyline"},
		{"id": "solar_canyon_1", "name": "🏜️ Solar Canyon - Desert Driftway", "theme": "solar_canyon"},
		{"id": "frostbyte_1", "name": "❄️ Frostbyte - Ice Loop Arena", "theme": "frostbyte"},
		{"id": "quantum_rift_1", "name": "🌀 Quantum Rift - Anomaly Zone", "theme": "quantum_rift"},
		{"id": "metro_1", "name": "🚇 Overclocked Metro - Rail Runner", "theme": "overclocked_metro"}
	]
	
	for track in tracks:
		var btn = create_track_button(track.id, track.name, track.theme)
		track_container.add_child(btn)

func setup_background():
	# Dark gradient background
	var bg = ColorRect.new()
	bg.color = Color(0.02, 0.01, 0.05)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.z_index = -10
	add_child(bg)
	move_child(bg, 0)
	
	# Floating neon particles
	var particles_container = Node2D.new()
	particles_container.name = "Particles"
	particles_container.z_index = -5
	add_child(particles_container)
	move_child(particles_container, 1)
	
	for i in range(30):
		var particle = create_background_particle()
		particles_container.add_child(particle)
		background_particles.append(particle)

func create_background_particle() -> Node2D:
	var particle = Node2D.new()
	particle.position = Vector2(randf_range(0, 1280), randf_range(0, 720))
	
	var colors = [
		Color(0.0, 1.0, 1.0, 0.3),
		Color(1.0, 0.0, 0.8, 0.3),
		Color(1.0, 0.8, 0.0, 0.2),
		Color(0.0, 1.0, 0.5, 0.2)
	]
	
	var shape = Polygon2D.new()
	var size = randf_range(2, 6)
	shape.polygon = PackedVector2Array([
		Vector2(-size, 0), Vector2(0, -size),
		Vector2(size, 0), Vector2(0, size)
	])
	shape.color = colors[randi() % colors.size()]
	particle.add_child(shape)
	
	particle.set_meta("speed", randf_range(20, 60))
	particle.set_meta("direction", randf_range(-0.5, 0.5))
	
	return particle

func animate_title():
	if title_glow_tween:
		title_glow_tween.kill()
	
	title_glow_tween = create_tween()
	title_glow_tween.set_loops()
	title_glow_tween.tween_property(title_label, "modulate", Color(1.2, 1.2, 1.2), 1.0)
	title_glow_tween.tween_property(title_label, "modulate", Color(0.9, 0.9, 0.9), 1.0)

func _process(delta: float):
	# Animate background particles
	for particle in background_particles:
		particle.position.y -= particle.get_meta("speed") * delta
		particle.position.x += particle.get_meta("direction") * 30 * delta
		particle.rotation += delta
		
		if particle.position.y < -20:
			particle.position.y = 740
			particle.position.x = randf_range(0, 1280)

func _on_quick_race_pressed():
	start_race()

func _on_close_pressed():
	get_tree().quit()

func start_race():
	Global.selected_game_mode = selected_mode
	Global.select_kart_class(selected_kart)
	Global.selected_track = selected_track
	Global.reset_race()
	
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _input(event: InputEvent):
	if event.is_action_pressed("pause"):
		if current_panel != "main":
			show_panel("main")