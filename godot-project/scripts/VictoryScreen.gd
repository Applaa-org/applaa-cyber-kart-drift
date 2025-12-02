extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var position_label: Label = $VBoxContainer/PositionLabel
@onready var results_container: VBoxContainer = $VBoxContainer/ResultsContainer
@onready var rewards_container: VBoxContainer = $VBoxContainer/RewardsContainer
@onready var restart_button: Button = $VBoxContainer/ButtonContainer/RestartButton
@onready var menu_button: Button = $VBoxContainer/ButtonContainer/MenuButton
@onready var close_button: Button = $VBoxContainer/ButtonContainer/CloseButton

func _ready() -> void:
	setup_ui()
	display_results()
	connect_signals()
	play_result_animation()

func setup_ui() -> void:
	# Style title based on position
	var position = Global.player_position
	
	if title_label:
		if position == 1:
			title_label.text = "🏆 VICTORY! 🏆"
			title_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
		elif position <= 3:
			title_label.text = "🎉 PODIUM FINISH! 🎉"
			title_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
		else:
			title_label.text = "RACE COMPLETE"
			title_label.add_theme_color_override("font_color", Color(0.0, 0.8, 1.0))
		
		title_label.add_theme_font_size_override("font_size", 48)
	
	if position_label:
		position_label.text = get_position_text(position)
		position_label.add_theme_font_size_override("font_size", 72)
		
		match position:
			1:
				position_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
			2:
				position_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
			3:
				position_label.add_theme_color_override("font_color", Color(0.8, 0.5, 0.2))
			_:
				position_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))

func get_position_text(pos: int) -> String:
	match pos:
		1: return "1ST"
		2: return "2ND"
		3: return "3RD"
		_: return "%dTH" % pos

func display_results() -> void:
	# Clear existing
	for child in results_container.get_children():
		child.queue_free()
	
	# Race time
	add_result_row("Race Time", format_time(Global.player_race_time))
	
	# Drift score
	add_result_row("Drift Score", str(Global.player_drift_score))
	
	# Knockouts
	add_result_row("Knockouts", str(Global.player_knockouts))
	
	# Calculate and display rewards
	var rewards = Global.calculate_race_rewards(
		Global.player_position,
		Global.player_drift_score,
		Global.player_knockouts
	)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	results_container.add_child(spacer)
	
	# Rewards header
	var rewards_header = Label.new()
	rewards_header.text = "— REWARDS —"
	rewards_header.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
	rewards_header.add_theme_font_size_override("font_size", 24)
	rewards_header.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	results_container.add_child(rewards_header)
	
	add_result_row("Credits", "+%d" % rewards.credits, Color(0.0, 1.0, 0.5))
	add_result_row("XP", "+%d" % rewards.xp, Color(0.5, 0.8, 1.0))
	
	if rewards.holo_tokens > 0:
		add_result_row("Holo Tokens", "+%d" % rewards.holo_tokens, Color(1.0, 0.0, 0.8))
	
	if rewards.data_shards > 0:
		add_result_row("Data Shards", "+%d" % rewards.data_shards, Color(0.0, 1.0, 1.0))
	
	# Apply rewards
	Global.add_credits(rewards.credits)
	Global.add_xp(rewards.xp)
	Global.holo_tokens += rewards.holo_tokens
	Global.data_shards += rewards.data_shards
	Global.save_game_data()

func add_result_row(label_text: String, value_text: String, value_color: Color = Color.WHITE) -> void:
	var row = HBoxContainer.new()
	row.custom_minimum_size = Vector2(400, 35)
	
	var label = Label.new()
	label.text = label_text
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	label.add_theme_font_size_override("font_size", 20)
	row.add_child(label)
	
	var value = Label.new()
	value.text = value_text
	value.add_theme_color_override("font_color", value_color)
	value.add_theme_font_size_override("font_size", 20)
	value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	row.add_child(value)
	
	results_container.add_child(row)

func format_time(time_seconds: float) -> String:
	var minutes = int(time_seconds) / 60
	var seconds = int(time_seconds) % 60
	var ms = int((time_seconds - int(time_seconds)) * 1000)
	return "%d:%02d.%03d" % [minutes, seconds, ms]

func connect_signals() -> void:
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
		style_button(restart_button, Color(0.0, 0.6, 0.3))
	
	if menu_button:
		menu_button.pressed.connect(_on_menu_pressed)
		style_button(menu_button, Color(0.2, 0.3, 0.5))
	
	if close_button:
		close_button.pressed.connect(_on_close_pressed)
		style_button(close_button, Color(0.5, 0.1, 0.1))

func style_button(button: Button, bg_color: Color) -> void:
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = bg_color.lightened(0.3)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_font_size_override("font_size", 20)
	button.custom_minimum_size = Vector2(150, 50)

func play_result_animation() -> void:
	modulate.a = 0.0
	
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	
	# Animate position reveal
	if position_label:
		position_label.scale = Vector2(3.0, 3.0)
		position_label.modulate.a = 0.0
		
		var pos_tween = create_tween()
		pos_tween.tween_interval(0.3)
		pos_tween.tween_property(position_label, "modulate:a", 1.0, 0.3)
		pos_tween.parallel().tween_property(position_label, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK)

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