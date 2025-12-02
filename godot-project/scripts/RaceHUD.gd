extends CanvasLayer

# HUD Elements
var speed_label: Label
var position_label: Label
var lap_label: Label
var timer_label: Label
var boost_bar: ProgressBar
var special_bar: ProgressBar
var health_bar: ProgressBar
var weapon_icon: Control
var weapon_label: Label
var countdown_label: Label
var drift_score_label: Label
var minimap: Control

# Animation
var countdown_tween: Tween
var position_flash_tween: Tween

func _ready():
	setup_hud()
	connect_signals()

func setup_hud():
	# Main HUD container
	var hud_container = Control.new()
	hud_container.name = "HUDContainer"
	hud_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(hud_container)
	
	# Top bar
	create_top_bar(hud_container)
	
	# Left side - Speed and boost
	create_left_panel(hud_container)
	
	# Right side - Weapon and special
	create_right_panel(hud_container)
	
	# Center - Countdown
	create_countdown_display(hud_container)
	
	# Bottom - Drift score
	create_drift_display(hud_container)
	
	# Minimap
	create_minimap(hud_container)

func create_top_bar(parent: Control):
	var top_bar = HBoxContainer.new()
	top_bar.name = "TopBar"
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_bottom = 60
	top_bar.add_theme_constant_override("separation", 30)
	top_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(top_bar)
	
	# Background
	var bg = Panel.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.0, 0.0, 0.0, 0.5)
	bg.add_theme_stylebox_override("panel", bg_style)
	bg.z_index = -1
	top_bar.add_child(bg)
	
	# Position
	var pos_container = VBoxContainer.new()
	pos_container.alignment = BoxContainer.ALIGNMENT_CENTER
	top_bar.add_child(pos_container)
	
	position_label = Label.new()
	position_label.text = "1st"
	position_label.add_theme_font_size_override("font_size", 36)
	position_label.add_theme_color_override("font_color", Color(1.<applaa-write path="godot-project/scripts/RaceHUD.gd" description="In-race HUD displaying speed, position, lap, boost, weapons, and timer">
extends CanvasLayer

# HUD Elements
var speed_label: Label
var position_label: Label
var lap_label: Label
var timer_label: Label
var boost_bar: ProgressBar
var special_bar: ProgressBar
var health_bar: ProgressBar
var weapon_icon: Control
var weapon_label: Label
var countdown_label: Label
var drift_score_label: Label
var minimap: Control

# Animation
var countdown_tween: Tween
var position_flash_tween: Tween

func _ready():
	setup_hud()
	connect_signals()

func setup_hud():
	# Main HUD container
	var hud_container = Control.new()
	hud_container.name = "HUDContainer"
	hud_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(hud_container)
	
	# Top bar
	create_top_bar(hud_container)
	
	# Left side - Speed and boost
	create_left_panel(hud_container)
	
	# Right side - Weapon and special
	create_right_panel(hud_container)
	
	# Center - Countdown
	create_countdown_display(hud_container)
	
	# Bottom - Drift score
	create_drift_display(hud_container)
	
	# Minimap
	create_minimap(hud_container)

func create_top_bar(parent: Control):
	var top_bar = HBoxContainer.new()
	top_bar.name = "TopBar"
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_bottom = 60
	top_bar.add_theme_constant_override("separation", 30)
	top_bar.alignment = BoxContainer.ALIGNMENT_CENTER
	parent.add_child(top_bar)
	
	# Background
	var bg = Panel.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.0, 0.0, 0.0, 0.5)
	bg.add_theme_stylebox_override("panel", bg_style)
	bg.z_index = -1
	top_bar.add_child(bg)
	
	# Position
	var pos_container = VBoxContainer.new()
	pos_container.alignment = BoxContainer.ALIGNMENT_CENTER
	top_bar.add_child(pos_container)
	
	position_label = Label.new()
	position_label.text = "1st"
	position_label.add_theme_font_size_override("font_size", 36)
	position_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
	position_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pos_container.add_child(position_label)
	
	var pos_subtitle = Label.new()
	pos_subtitle.text = "POSITION"
	pos_subtitle.add_theme_font_size_override("font_size", 10)
	pos_subtitle.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	pos_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pos_container.add_child(pos_subtitle)
	
	# Lap
	var lap_container = VBoxContainer.new()
	lap_container.alignment = BoxContainer.ALIGNMENT_CENTER
	top_bar.add_child(lap_container)
	
	lap_label = Label.new()
	lap_label.text = "LAP 1/3"
	lap_label.add_theme_font_size_override("font_size", 28)
	lap_label.add_theme_color_override("font_color", Color(0.0, 1.0, 1.0))
	lap_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lap_container.add_child(lap_label)
	
	# Timer
	var timer_container = VBoxContainer.new()
	timer_container.alignment = BoxContainer.ALIGNMENT_CENTER
	top_bar.add_child(timer_container)
	
	timer_label = Label.new()
	timer_label.text = "00:00.00"
	timer_label.add_theme_font_size_override("font_size", 28)
	timer_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_container.add_child(timer_label)
	
	var timer_subtitle = Label.new()
	timer_subtitle.text = "TIME"
	timer_subtitle.add_theme_font_size_override("font_size", 10)
	timer_subtitle.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	timer_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	timer_container.add_child(timer_subtitle)

func create_left_panel(parent: Control):
	var left_panel = VBoxContainer.new()
	left_panel.name = "LeftPanel"
	left_panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	left_panel.offset_left = 20
	left_panel.offset_bottom = -20
	left_panel.offset_top = -180
	left_panel.offset_right = 220
	left_panel.add_theme_constant_override("separation", 10)
	parent.add_child(left_panel)
	
	# Speed display
	var speed_container = PanelContainer.new()
	var speed_style = StyleBoxFlat.new()
	speed_style.bg_color = Color(0.0, 0.0, 0.0, 0.6)
	speed_style.border_color = Color(0.0, 1.0, 1.0, 0.5)
	speed_style.set_border_width_all(2)
	speed_style.set_corner_radius_all(8)
	speed_container.add_theme_stylebox_override("panel", speed_style)
	left_panel.add_child(speed_container)
	
	var speed_vbox = VBoxContainer.new()
	speed_vbox.add_theme_constant_override("separation", 5)
	speed_container.add_child(speed_vbox)
	
	var speed_title = Label.new()
	speed_title.text = "SPEED"
	speed_title.add_theme_font_size_override("font_size", 12)
	speed_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	speed_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	speed_vbox.add_child(speed_title)
	
	speed_label = Label.new()
	speed_label.text = "0 km/h"
	speed_label.add_theme_font_size_override("font_size", 32)
	speed_label.add_theme_color_override("font_color", Color(0.0, 1.0, 1.0))
	speed_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	speed_vbox.add_child(speed_label)
	
	# Health bar
	var health_container = VBoxContainer.new()
	health_container.add_theme_constant_override("separation", 2)
	left_panel.add_child(health_container)
	
	var health_title = Label.new()
	health_title.text = "HEALTH"
	health_title.add_theme_font_size_override("font_size", 12)
	health_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	health_container.add_child(health_title)
	
	health_bar = ProgressBar.new()
	health_bar.custom_minimum_size = Vector2(180, 20)
	health_bar.max_value = 100
	health_bar.value = 100
	health_bar.show_percentage = false
	setup_progress_bar_style(health_bar, Color(0.2, 0.8, 0.2))
	health_container.add_child(health_bar)
	
	# Boost bar
	var boost_container = VBoxContainer.new()
	boost_container.add_theme_constant_override("separation", 2)
	left_panel.add_child(boost_container)
	
	var boost_title = Label.new()
	boost_title.text = "BOOST"
	boost_title.add_theme_font_size_override("font_size", 12)
	boost_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	boost_container.add_child(boost_title)
	
	boost_bar = ProgressBar.new()
	boost_bar.custom_minimum_size = Vector2(180, 20)
	boost_bar.max_value = 100
	boost_bar.value = 0
	boost_bar.show_percentage = false
	setup_progress_bar_style(boost_bar, Color(1.0, 0.5, 0.0))
	boost_container.add_child(boost_bar)

func create_right_panel(parent: Control):
	var right_panel = VBoxContainer.new()
	right_panel.name = "RightPanel"
	right_panel.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	right_panel.offset_right = -20
	right_panel.offset_bottom = -20
	right_panel.offset_top = -180
	right_panel.offset_left = -220
	right_panel.add_theme_constant_override("separation", 10)
	parent.add_child(right_panel)
	
	# Weapon display
	var weapon_container = PanelContainer.new()
	var weapon_style = StyleBoxFlat.new()
	weapon_style.bg_color = Color(0.0, 0.0, 0.0, 0.6)
	weapon_style.border_color = Color(1.0, 0.3, 0.3, 0.5)
	weapon_style.set_border_width_all(2)
	weapon_style.set_corner_radius_all(8)
	weapon_container.add_theme_stylebox_override("panel", weapon_style)
	right_panel.add_child(weapon_container)
	
	var weapon_vbox = VBoxContainer.new()
	weapon_vbox.add_theme_constant_override("separation", 5)
	weapon_container.add_child(weapon_vbox)
	
	var weapon_title = Label.new()
	weapon_title.text = "WEAPON"
	weapon_title.add_theme_font_size_override("font_size", 12)
	weapon_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	weapon_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	weapon_vbox.add_child(weapon_title)
	
	weapon_label = Label.new()
	weapon_label.text = "NONE"
	weapon_label.add_theme_font_size_override("font_size", 18)
	weapon_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	weapon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	weapon_vbox.add_child(weapon_label)
	
	# Weapon icon placeholder
	weapon_icon = Control.new()
	weapon_icon.custom_minimum_size = Vector2(60, 60)
	weapon_vbox.add_child(weapon_icon)
	
	# Special meter
	var special_container = VBoxContainer.new()
	special_container.add_theme_constant_override("separation", 2)
	right_panel.add_child(special_container)
	
	var special_title = Label.new()
	special_title.text = "SPECIAL"
	special_title.add_theme_font_size_override("font_size", 12)
	special_title.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	special_container.add_child(special_title)
	
	special_bar = ProgressBar.new()
	special_bar.custom_minimum_size = Vector2(180, 20)
	special_bar.max_value = 100
	special_bar.value = 0
	special_bar.show_percentage = false
	setup_progress_bar_style(special_bar, Color(0.8, 0.2, 1.0))
	special_container.add_child(special_bar)

func create_countdown_display(parent: Control):
	var countdown_container = CenterContainer.new()
	countdown_container.name = "CountdownContainer"
	countdown_container.set_anchors_preset(Control.PRESET_CENTER)
	countdown_container.offset_left = -150
	countdown_container.offset_right = 150
	countdown_container.offset_top = -100
	countdown_container.offset_bottom = 100
	parent.add_child(countdown_container)
	
	countdown_label = Label.new()
	countdown_label.text = ""
	countdown_label.add_theme_font_size_override("font_size", 120)
	countdown_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.0))
	countdown_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	countdown_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	countdown_container.add_child(countdown_label)

func create_drift_display(parent: Control):
	var drift_container = CenterContainer.new()
	drift_container.name = "DriftContainer"
	drift_container.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	drift_container.offset_top = -80
	drift_container.offset_bottom = -40
	drift_container.offset_left = -100
	drift_container.offset_right = 100
	parent.add_child(drift_container)
	
	drift_score_label = Label.new()
	drift_score_label.text = ""
	drift_score_label.add_theme_font_size_override("font_size", 28)
	drift_score_label.add_theme_color_override("font_color", Color(0.0, 1.0, 1.0))
	drift_score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	drift_container.add_child(drift_score_label)

func create_minimap(parent: Control):
	minimap = Control.new()
	minimap.name = "Minimap"
	minimap.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	minimap.offset_right = -20
	minimap.offset_top = 70
	minimap.offset_left = -170
	minimap.offset_bottom = 220
	parent.add_child(minimap)
	
	# Minimap background
	var minimap_bg = Panel.new()
	minimap_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	var minimap_style = StyleBoxFlat.new()
	minimap_style.bg_color = Color(0.0, 0.0, 0.0, 0.5)
	minimap_style.border_color = Color(0.0, 1.0, 1.0, 0.3)
	minimap_style.set_border_width_all(2)
	minimap_style.set_corner_radius_all(8)
	minimap_bg.add_theme_stylebox_override("panel", minimap_style)
	minimap.add_child(minimap_bg)

func setup_progress_bar_style(bar: ProgressBar, color: Color):
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	bg_style.set_corner_radius_all(4)
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = color
	fill_style.set_corner_radius_all(4)
	
	bar.add_theme_stylebox_override("background", bg_style)
	bar.add_theme_stylebox_override("fill", fill_style)

func connect_signals():
	Global.score_changed.connect(_on_score_changed)
	Global.health_changed.connect(_on_health_changed)
	Global.boost_changed.connect(_on_boost_changed)
	Global.lap_completed.connect(_on_lap_completed)
	Global.weapon_collected.connect(_on_weapon_collected)
	
	var race_manager = get_tree().get_first_node_in_group("race_manager")
	if race_manager:
		race_manager.countdown_tick.connect(_on_countdown_tick)
		race_manager.race_started.connect(_on_race_started)
		race_manager.position_updated.connect(_on_position_updated)

func _process(delta: float):
	update_speed_display()
	update_timer_display()
	update_lap_display()

func update_speed_display():
	var player = get_tree().get_first_node_in_group("player") as PlayerKart
	if player:
		var speed_kmh = int(abs(player.current_speed) * 1.5)
		speed_label.text = "%d km/h" % speed_kmh
		
		# Color based on speed
		var speed_ratio = abs(player.current_speed) / player.get_max_speed()
		if player.is_boosting:
			speed_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0))
		elif speed_ratio > 0.8:
			speed_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
		else:
			speed_label.add_theme_color_override("font_color", Color(0.0, 1.0, 1.0))

func update_timer_display():
	var race_manager = get_tree().get_first_node_in_group("race_manager") as RaceManager
	if race_manager:
		timer_label.text = race_manager.get_race_time_formatted()

func update_lap_display():
	var current_lap = min(Global.lap_count + 1, Global.total_laps)
	lap_label.text = "LAP %d/%d" % [current_lap, Global.total_laps]
	
	# Final lap warning
	if Global.lap_count == Global.total_laps - 1:
		lap_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
	else:
		lap_label.add_theme_color_override("font_color", Color(0.0, 1.0, 1.0))

func _on_score_changed(new_score: int):
	# Could display score somewhere if needed
	pass

func _on_health_changed(new_health: int):
	health_bar.value = new_health
	
	# Flash red when low
	if new_health < 30:
		var tween = create_tween()
		tween.tween_property(health_bar, "modulate", Color(1.5, 0.5, 0.5), 0.1)
		tween.tween_property(health_bar, "modulate", Color.WHITE, 0.1)

func _on_boost_changed(new_boost: float):
	boost_bar.value = new_boost
	
	# Ready to boost indicator
	if new_boost >= 30:
		boost_bar.modulate = Color(1.2, 1.2, 1.0)
	else:
		boost_bar.modulate = Color.WHITE

func _on_special_changed(new_special: float):
	special_bar.value = new_special
	
	# Ready to use special
	if new_special >= 100:
		special_bar.modulate = Color(1.2, 1.0, 1.2)
		# Pulse effect
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(special_bar, "modulate", Color(1.5, 1.0, 1.5), 0.5)
		tween.tween_property(special_bar, "modulate", Color(1.0, 0.8, 1.0), 0.5)

func _on_lap_completed(lap_number: int):
	# Show lap completion message
	show_message("LAP %d COMPLETE!" % lap_number, Color(0.0, 1.0, 0.5))

func _on_weapon_collected(weapon_name: String):
	weapon_label.text = weapon_name.to_upper().replace("_", " ")
	weapon_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0))
	
	# Flash effect
	var tween = create_tween()
	tween.tween_property(weapon_label, "modulate", Color(2.0, 2.0, 2.0), 0.1)
	tween.tween_property(weapon_label, "modulate", Color.WHITE, 0.2)

func update_weapon_display(weapon_name: String, charges: int):
	if weapon_name == "":
		weapon_label.text = "NONE"
		weapon_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	else:
		weapon_label.text = "%s x%d" % [weapon_name.to_upper(), charges]
		weapon_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0))

func _on_countdown_tick(count: int):
	if count > 0:
		countdown_label.text = str(count)
		countdown_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.0))
	else:
		countdown_label.text = "GO!"
		countdown_label.add_theme_color_override("font_color", Color(0.0, 1.0, 0.0))
	
	# Animate countdown
	countdown_label.scale = Vector2(1.5, 1.5)
	if countdown_tween:
		countdown_tween.kill()
	countdown_tween = create_tween()
	countdown_tween.tween_property(countdown_label, "scale", Vector2(1.0, 1.0), 0.3)

func _on_race_started():
	# Hide countdown after a moment
	await get_tree().create_timer(1.0).timeout
	countdown_label.text = ""

func _on_position_updated(position: int):
	var suffix = get_position_suffix(position)
	position_label.text = "%d%s" % [position, suffix]
	
	# Color based on position
	match position:
		1:
			position_label.add_theme_color_override("font_color", Color(1.0, 0.85, 0.0))
		2:
			position_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		3:
			position_label.add_theme_color_override("font_color", Color(0.8, 0.5, 0.2))
		_:
			position_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
	
	# Flash on position change
	if position_flash_tween:
		position_flash_tween.kill()
	position_flash_tween = create_tween()
	position_flash_tween.tween_property(position_label, "scale", Vector2(1.3, 1.3), 0.1)
	position_flash_tween.tween_property(position_label, "scale", Vector2(1.0, 1.0), 0.2)

func get_position_suffix(pos: int) -> String:
	match pos:
		1: return "st"
		2: return "nd"
		3: return "rd"
		_: return "th"

func show_message(text: String, color: Color = Color.WHITE):
	var message = Label.new()
	message.text = text
	message.add_theme_font_size_override("font_size", 36)
	message.add_theme_color_override("font_color", color)
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.set_anchors_preset(Control.PRESET_CENTER)
	message.position.y = -50
	get_child(0).add_child(message)
	
	var tween = create_tween()
	tween.tween_property(message, "position:y", -100, 1.0)
	tween.parallel().tween_property(message, "modulate:a", 0.0, 1.0)
	tween.tween_callback(message.queue_free)

func show_drift_score(score: int):
	drift_score_label.text = "DRIFT +%d" % score
	drift_score_label.modulate.a = 1.0
	
	var tween = create_tween()
	tween.tween_property(drift_score_label, "modulate:a", 0.0, 1.5)

func show_elimination_warning(time_left: float):
	if time_left <= 5.0:
		show_message("⚠️ ELIMINATION IN %.1f" % time_left, Color(1.0, 0.2, 0.2))