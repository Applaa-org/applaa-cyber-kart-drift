extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var message_label: Label = $VBoxContainer/MessageLabel
@onready var stats_container: VBoxContainer = $VBoxContainer/StatsContainer
@onready var restart_button: Button = $VBoxContainer/ButtonContainer/RestartButton
@onready var menu_button: Button = $VBoxContainer/ButtonContainer/MenuButton
@onready var close_button: Button = $VBoxContainer/ButtonContainer/CloseButton

var defeat_reason: String = "destroyed"

func _ready() -> void:
	setup_ui()
	display_stats()
	connect_signals()
	play_defeat_animation()

func setup_ui() -> void:
	if title_label:
		title_label.text = "RACE OVER"
		title_label.add_theme_font_size_override("font_size", 56)
		title_label.add_theme_color_override("font_color", Color(1.0, 0.2, 0.2))
	
	if message_label:
		match defeat_reason:
			"destroyed":
				message_label.text = "Your kart was destroyed!"
			"eliminated":
				message_label.text = "You were eliminated!"
			"timeout":
				message_label.text = "Time ran out!"
			_:
				message_label.text = "Better luck next time!"
		
		message_label.add_theme_font_size_override("font_size", 24)
		message_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))

func display_stats() -> void:
	for child in stats_container.get_children():
		child.queue_free()
	
	# Show what was achieved before defeat
	add_stat_row("Position", get_position_text(Global.player_position))
	add_stat_row("Laps Completed", str(maxi(0, Global.race_results.size())))
	add_stat_row("Drift Score", str(Global.player_drift_score))
	add_stat_row("Race Time", format_time(Global.player_race_time))
	
	# Consolation rewards (reduced)
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	stats_container.add_child(spacer)
	
	var consolation_credits = 50 + Global.player_drift_score / 20
	var consolation_xp = 25 + Global.player_drift_score / 10
	
	add_stat_row("Consolation Credits", "+%d" % consolation_credits, Color(0.5, 0.8, 0.5))
	add_stat_row("XP Earned", "+%d" % consolation_xp, Color(0.5, 0.7, 1.0))
	
	Global.add_credits(consolation_credits)
	Global.add_xp(consolation_xp)
	Global.save_game_data()

func get_position_text(pos: int) -> String:
	match pos:
		1: return "1ST"
		2: return "2ND"
		3: return "3RD"
		_: return "%dTH" % pos

func add_stat_row(label_text: String, value_text: String, value_color: Color = Color.WHITE) -> void:
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(350, 30)
	
	var label = Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	label.add_theme_font_size_override("font_size", 18)
	row.add_child(label)
	
	var value = Label.new()
	value.text = value_text
	value.add_theme_color_override("font_color", value_color)
	value.add_theme_font_size_override("font_size", 18)
	row.add_child(value)
	
	stats_container.add_child(row)

func format_time(time_seconds: float) -> String:
	var minutes = int(time_seconds) / 60
	var seconds = int(time_seconds) % 60
	var ms = int((time_seconds - int(time_seconds)) * 1000)
	return "%d:%02d.%03d" % [minutes, seconds, ms]

func connect_signals() -> void:
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
		style_button(restart_button, Color(0.0, 0.5, 0.3))
	
	if menu_button:
		menu_button.pressed.connect(_on_menu_pressed)
		style_button(menu_button, Color(0.2, 0.3, 0.4))
	
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
		style_button(close_button, Color(0.4, 0.1, 0.1))

func style_button(button: Button, bg_color: Color) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = bg_color.lightened(0.3)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_font_size_override("font_size", 18)
	button.custom_minimum_size = Vector2(140, 45)

func play_defeat_animation() -> void:
	modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	
	# Shake effect on title
	if title_label:
		var shake_tween = create_tween()
		shake_tween.set_loops(3)
		shake_tween.tween_property(title_label, "position:x", title_label.position.x + 5, 0.05)
		shake_tween.tween_property(title_label, "position:x", title_label.position.x - 5, 0.05)
		shake_tween.tween_property(title_label, "position:x", title_label.position.x, 0.05)

func set_defeat_reason(reason: String) -> void:
	defeat_reason = reason

func _on_restart_pressed() -> void:
	AudioManager.play_ui_sound("confirm")
	Global.reset_race_data()
	get_tree().change_scene_to_file("res://scenes/Race.tscn")

func _on_menu_pressed() -> void:
	AudioManager.play_ui_sound("back")
	Global.reset_race_data()
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _on_close_pressed() -> void:
	AudioManager.play_ui_sound("back")
	Global.save_game_data()
	get_tree().quit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_menu_pressed()