extends Control

@onready var resume_button: Button = $PanelContainer/VBoxContainer/ResumeButton
@onready var restart_button: Button = $PanelContainer/VBoxContainer/RestartButton
@onready var settings_button: Button = $PanelContainer/VBoxContainer/SettingsButton
@onready var quit_button: Button = $PanelContainer/VBoxContainer/QuitButton

var is_paused: bool = false

func _ready() -> void:
	setup_ui()
	connect_signals()
	visible = false

func setup_ui() -> void:
	style_button(resume_button, Color(0.0, 0.6, 0.3))
	style_button(restart_button, Color(0.5, 0.4, 0.0))
	style_button(settings_button, Color(0.2, 0.3, 0.5))
	style_button(quit_button, Color(0.5, 0.1, 0.1))

func style_button(button: Button, bg_color: Color) -> void:
	if not button:
		return
	
	var style = StyleBoxFlat.new()
	style.bg_color = bg_color
	style.border_color = bg_color.lightened(0.3)
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	button.add_theme_stylebox_override("normal", style)
	button.add_theme_font_size_override("font_size", 22)
	button.custom_minimum_size = Vector2(200, 50)

func connect_signals() -> void:
	if resume_button:
		resume_button.pressed.connect(_on_resume_pressed)
	if restart_button:
		restart_button.pressed.connect(_on_restart_pressed)
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
	if quit_button:
		quit_button.pressed.connect(_on_quit_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()

func toggle_pause() -> void:
	is_paused = not is_paused
	visible = is_paused
	get_tree().paused = is_paused
	
	if is_paused:
		AudioManager.play_ui_sound("click")

func _on_resume_pressed() -> void:
	AudioManager.play_ui_sound("confirm")
	toggle_pause()

func _on_restart_pressed() -> void:
	AudioManager.play_ui_sound("confirm")
	get_tree().paused = false
	Global.reset_race_data()
	get_tree().change_scene_to_file("res://scenes/Race.tscn")

func _on_settings_pressed() -> void:
	AudioManager.play_ui_sound("click")
	# Would show settings overlay

func _on_quit_pressed() -> void:
	AudioManager.play_ui_sound("back")
	get_tree().paused = false
	Global.reset_race_data()
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")