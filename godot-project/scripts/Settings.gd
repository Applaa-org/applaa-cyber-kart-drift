extends Control

@onready var music_slider: HSlider = $VBoxContainer/MusicContainer/MusicSlider
@onready var sfx_slider: HSlider = $VBoxContainer/SFXContainer/SFXSlider
@onready var screen_shake_check: CheckButton = $VBoxContainer/ScreenShakeCheck
@onready var speedometer_check: CheckButton = $VBoxContainer/SpeedometerCheck
@onready var back_button: Button = $VBoxContainer/BackButton

func _ready() -> void:
	setup_ui()
	load_settings()
	connect_signals()

func setup_ui() -> void:
	if music_slider:
		music_slider.min_value = 0.0
		music_slider.max_value = 1.0
		music_slider.step = 0.05
	
	if sfx_slider:
		sfx_slider.min_value = 0.0
		sfx_slider.max_value = 1.0
		sfx_slider.step = 0.05
	
	if back_button:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.3, 0.2, 0.4)
		style.border_color = Color(0.5, 0.3, 0.7)
		style.set_border_width_all(2)
		style.set_corner_radius_all(8)
		back_button.add_theme_stylebox_override("normal", style)
		back_button.custom_minimum_size = Vector2(150, 50)

func load_settings() -> void:
	if music_slider:
		music_slider.value = Global.music_volume
	
	if sfx_slider:
		sfx_slider.value = Global.sfx_volume
	
	if screen_shake_check:
		screen_shake_check.button_pressed = Global.screen_shake
	
	if speedometer_check:<applaa-write path="godot-project/scripts/Settings.gd" description="Settings screen for audio and gameplay options">
extends Control

@onready var music_slider: HSlider = $VBoxContainer/MusicContainer/MusicSlider
@onready var sfx_slider: HSlider = $VBoxContainer/SFXContainer/SFXSlider
@onready var screen_shake_check: CheckButton = $VBoxContainer/ScreenShakeCheck
@onready var speedometer_check: CheckButton = $VBoxContainer/SpeedometerCheck
@onready var back_button: Button = $VBoxContainer/BackButton

func _ready() -> void:
	setup_ui()
	load_settings()
	connect_signals()

func setup_ui() -> void:
	if music_slider:
		music_slider.min_value = 0.0
		music_slider.max_value = 1.0
		music_slider.step = 0.05
	
	if sfx_slider:
		sfx_slider.min_value = 0.0
		sfx_slider.max_value = 1.0
		sfx_slider.step = 0.05
	
	if back_button:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.3, 0.2, 0.4)
		style.border_color = Color(0.5, 0.3, 0.7)
		style.set_border_width_all(2)
		style.set_corner_radius_all(8)
		back_button.add_theme_stylebox_override("normal", style)
		back_button.custom_minimum_size = Vector2(150, 50)

func load_settings() -> void:
	if music_slider:
		music_slider.value = Global.music_volume
	
	if sfx_slider:
		sfx_slider.value = Global.sfx_volume
	
	if screen_shake_check:
		screen_shake_check.button_pressed = Global.screen_shake
	
	if speedometer_check:
		speedometer_check.button_pressed = Global.show_speedometer

func connect_signals() -> void:
	if music_slider:
		music_slider.value_changed.connect(_on_music_changed)
	
	if sfx_slider:
		sfx_slider.value_changed.connect(_on_sfx_changed)
	
	if screen_shake_check:
		screen_shake_check.toggled.connect(_on_screen_shake_toggled)
	
	if speedometer_check:
		speedometer_check.toggled.connect(_on_speedometer_toggled)
	
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

func _on_music_changed(value: float) -> void:
	Global.music_volume = value
	AudioManager.update_volumes()

func _on_sfx_changed(value: float) -> void:
	Global.sfx_volume = value
	AudioManager.play_ui_sound("click")

func _on_screen_shake_toggled(enabled: bool) -> void:
	Global.screen_shake = enabled
	AudioManager.play_ui_sound("click")

func _on_speedometer_toggled(enabled: bool) -> void:
	Global.show_speedometer = enabled
	AudioManager.play_ui_sound("click")

func _on_back_pressed() -> void:
	AudioManager.play_ui_sound("back")
	Global.save_game_data()
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_back_pressed()