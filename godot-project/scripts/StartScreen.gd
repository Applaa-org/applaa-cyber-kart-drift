extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var menu_container: VBoxContainer = $VBoxContainer/MenuContainer
@onready var version_label: Label = $VersionLabel

# Menu buttons
var single_race_btn: Button
var grand_prix_btn: Button
var time_trial_btn: Button
var garage_btn: Button
var settings_btn: Button
var quit_btn: Button

# Animation
var title_glow_time: float = 0.0

func _ready() -> void:
	setup_ui()
	connect_signals()
	animate_intro()

func setup_ui() -> void:
	# Create menu buttons
	single_race_btn = create_menu_button("SINGLE RACE", "race_single")
	grand_prix_btn = create_menu_button("GRAND PRIX", "grand_prix")
	time_trial_btn = create_menu_button("TIME TRIAL", "time_trial")
	garage_btn = create_menu_button("GARAGE", "garage")
	settings_btn = create_menu_button("SETTINGS", "settings")
	quit_btn = create_menu_button("QUIT", "quit")
	
	menu_container.add_child(single_race_btn)
	menu_container.add_child(grand_prix_btn)
	menu_container.add_child(time_trial_btn)
	menu_container.add_child(garage_btn)
	menu_container.add_child(settings_btn)
	menu_container.add_child(quit_btn)
	
	# Style title
	if title_label:
		title_label.text = "CYBER KART DRIFT"
		title_label.add_theme_font_size_override("font_size", 64)
		title_label.add_theme_color_override("font_color", Color(0.0, 0.9, 1.0))
	
	# Version label
	if version_label:
		version_label.text = "v1.0.0"
		version_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

func create_menu_button(text: String, action: String) -> Button:
	var button = Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(300, 50)
	button.add_theme_font_size_override("font_size", 24)
	
	# Style button
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.1, 0.1, 0.2, 0.8)
	style_normal.border_color = Color(0.0, 0.8, 1.0)
	style_normal.set_border_width_all(2)
	style_normal.set_corner_radius_all(8)
	
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.0, 0.3, 0.4, 0.9)
	style_hover.border_color = Color(0.0, 1.0, 1.0)
	style_hover.set_border_width_all(3)
	style_hover.set_corner_radius_all(8)
	
	var style_pressed = StyleBoxFlat.new()
	style_pressed.bg_color = Color(0.0, 0.5, 0.6, 1.0)
	style_pressed.border_color = Color(1.0, 0.5, 0.0)
	style_pressed.set_border_width_all(3)
	style_pressed.set_corner_radius_all(8)
	
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed",<applaa-write path="godot-project/scripts/StartScreen.gd" description="Main menu start screen with all options">
extends Control

@onready var title_label: Label = $VBoxContainer/TitleLabel
@onready var menu_container: VBoxContainer = $VBoxContainer/MenuContainer
@onready var version_label: Label = $VersionLabel

# Menu buttons
var single_race_btn: Button
var grand_prix_btn: Button
var time_trial_btn: Button
var garage_btn: Button
var settings_btn: Button
var quit_btn: Button

# Animation
var title_glow_time: float = 0.0

func _ready() -> void:
	setup_ui()
	connect_signals()
	animate_intro()

func setup_ui() -> void:
	# Create menu buttons
	single_race_btn = create_menu_button("SINGLE RACE", "race_single")
	grand_prix_btn = create_menu_button("GRAND PRIX", "grand_prix")
	time_trial_btn = create_menu_button("TIME TRIAL", "time_trial")
	garage_btn = create_menu_button("GARAGE", "garage")
	settings_btn = create_menu_button("SETTINGS", "settings")
	quit_btn = create_menu_button("QUIT", "quit")
	
	menu_container.add_child(single_race_btn)
	menu_container.add_child(grand_prix_btn)
	menu_container.add_child(time_trial_btn)
	menu_container.add_child(garage_btn)
	menu_container.add_child(settings_btn)
	menu_container.add_child(quit_btn)
	
	# Style title
	if title_label:
		title_label.text = "CYBER KART DRIFT"
		title_label.add_theme_font_size_override("font_size", 64)
		title_label.add_theme_color_override("font_color", Color(0.0, 0.9, 1.0))
	
	# Version label
	if version_label:
		version_label.text = "v1.0.0"
		version_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))

func create_menu_button(text: String, action: String) -> Button:
	var button = Button.new()
	button.text = text
	button.name = action
	button.custom_minimum_size = Vector2(300, 50)
	button.add_theme_font_size_override("font_size", 24)
	
	# Style button
	var style_normal = StyleBoxFlat.new()
	style_normal.bg_color = Color(0.1, 0.1, 0.2, 0.8)
	style_normal.border_color = Color(0.0, 0.8, 1.0)
	style_normal.set_border_width_all(2)
	style_normal.set_corner_radius_all(8)
	
	var style_hover = StyleBoxFlat.new()
	style_hover.bg_color = Color(0.0, 0.3, 0.4, 0.9)
	style_hover.border_color = Color(0.0, 1.0, 1.0)
	style_hover.set_border_width_all(3)
	style_hover.set_corner_radius_all(8)
	
	var style_pressed = StyleBoxFlat.new()
	style_pressed.bg_color = Color(0.0, 0.5, 0.6, 1.0)
	style_pressed.border_color = Color(1.0, 0.5, 0.0)
	style_pressed.set_border_width_all(3)
	style_pressed.set_corner_radius_all(8)
	
	button.add_theme_stylebox_override("normal", style_normal)
	button.add_theme_stylebox_override("hover", style_hover)
	button.add_theme_stylebox_override("pressed", style_pressed)
	button.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))
	button.add_theme_color_override("font_hover_color", Color(0.0, 1.0, 1.0))
	
	return button

func connect_signals() -> void:
	single_race_btn.pressed.connect(_on_single_race_pressed)
	grand_prix_btn.pressed.connect(_on_grand_prix_pressed)
	time_trial_btn.pressed.connect(_on_time_trial_pressed)
	garage_btn.pressed.connect(_on_garage_pressed)
	settings_btn.pressed.connect(_on_settings_pressed)
	quit_btn.pressed.connect(_on_quit_pressed)
	
	# Hover sounds
	for button in menu_container.get_children():
		if button is Button:
			button.mouse_entered.connect(_on_button_hover)

func animate_intro() -> void:
	# Fade in animation
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	
	# Animate buttons sliding in
	var delay = 0.2
	for button in menu_container.get_children():
		if button is Button:
			button.modulate.a = 0.0
			button.position.x -= 50
			var btn_tween = create_tween()
			btn_tween.tween_interval(delay)
			btn_tween.tween_property(button, "modulate:a", 1.0, 0.3)
			btn_tween.parallel().tween_property(button, "position:x", button.position.x + 50, 0.3)
			delay += 0.1

func _process(delta: float) -> void:
	# Animate title glow
	title_glow_time += delta * 2.0
	if title_label:
		var glow_intensity = (sin(title_glow_time) + 1.0) * 0.5
		var glow_color = Color(0.0, 0.9, 1.0).lerp(Color(1.0, 0.0, 0.5), glow_intensity * 0.3)
		title_label.add_theme_color_override("font_color", glow_color)

func _on_button_hover() -> void:
	AudioManager.play_ui_sound("hover")

func _on_single_race_pressed() -> void:
	AudioManager.play_ui_sound("confirm")
	Global.current_mode = "single_race"
	get_tree().change_scene_to_file("res://scenes/TrackSelect.tscn")

func _on_grand_prix_pressed() -> void:
	AudioManager.play_ui_sound("confirm")
	Global.current_mode = "grand_prix"
	get_tree().change_scene_to_file("res://scenes/TrackSelect.tscn")

func _on_time_trial_pressed() -> void:
	AudioManager.play_ui_sound("confirm")
	Global.current_mode = "time_trial"
	get_tree().change_scene_to_file("res://scenes/TrackSelect.tscn")

func _on_garage_pressed() -> void:
	AudioManager.play_ui_sound("confirm")
	get_tree().change_scene_to_file("res://scenes/Garage.tscn")

func _on_settings_pressed() -> void:
	AudioManager.play_ui_sound("confirm")
	get_tree().change_scene_to_file("res://scenes/Settings.tscn")

func _on_quit_pressed() -> void:
	AudioManager.play_ui_sound("back")
	Global.save_game_data()
	get_tree().quit()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		# ESC does nothing on main menu, or could quit
		pass