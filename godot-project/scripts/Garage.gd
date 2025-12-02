extends Control

@onready var kart_preview: Node2D = $KartPreviewViewport/KartPreview
@onready var class_list: VBoxContainer = $LeftPanel/ClassList
@onready var stats_panel: VBoxContainer = $RightPanel/StatsPanel
@onready var color_picker: ColorPickerButton = $RightPanel/CustomizePanel/ColorPicker
@onready var glow_picker: ColorPickerButton = $RightPanel/CustomizePanel/GlowPicker
@onready var credits_label: Label = $TopBar/CreditsLabel
@onready var back_button: Button = $TopBar/BackButton
@onready var select_button: Button = $BottomBar/SelectButton

var selected_class: String = "balanced"
var preview_rotation: float = 0.0

func _ready() -> void:
	setup_class_list()
	setup_customization()
	setup_buttons()
	update_credits_display()
	select_class(Global.selected_kart_class)

func _process(delta: float) -> void:
	# Rotate kart preview
	preview_rotation += delta * 0.5
	if kart_preview:
		kart_preview.rotation = preview_rotation

func setup_class_list() -> void:
	for child in class_list.get_children():
		child.queue_free()
	
	for class_id in Global.kart_classes:
		var class_data = Global.kart_classes[class_id]
		var is_unlocked = class_id in Global.unlocked_karts
		
		var button = Button.new()
		button.text = class_data.get("name", class_id)
		button.custom_minimum_size = Vector2(200, 50)
		button.disabled = not is_unlocked
		
		if not is_unlocked:
			button.text += " 🔒"
		
		style_class_button(button, is_unlocked)
		button.pressed.connect(_on_class_selected.bind(class_id))
		class_list.add_child(button)

func style_class_button(button: Button, unlocked: bool) -> void:
	var style = StyleBoxFlat.new()
	
	if unlocked:
		style.bg_color = Color(0.1, 0.15, 0.25, 0.9)
		style.border_color = Color(0.0, 0.8, 1.0)
	else:
		style.bg_color = Color(0.1, 0.1, 0.1, 0.5)
		style.border_color = Color(0.3, 0.3, 0.3)
	
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	button.add_theme_stylebox_override("normal", style)

func setup_customization() -> void:
	if color_picker:
		color_picker.color = Global.selected_kart_color
		color_picker.color_changed.connect(_on_color_changed)
	
	if glow_picker:
		glow_picker.color = Global.selected_underglow
		glow_picker.color_changed.connect(_on_glow_changed)

func setup_buttons() -> void:
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	if select_button:
		select_button.pressed.connect(_on_select_pressed)
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.0, 0.6, 0.3, 0.9)
		style.border_color = Color(0.0, 1.0, 0.5)
		style.set_border_width_all(3)
		style.set_corner_radius_all(8)
		select_button.add_theme_stylebox_override("normal", style)

func _on_class_selected(class_id: String) -> void:
	if class_id not in Global.unlocked_karts:
		return
	
	select_class(class_id)
	AudioManager.play_ui_sound("click")

func select_class(class_id: String) -> void:
	selected_class = class_id
	update_stats_display()
	update_preview()

func update_stats_display() -> void:
	var class_data = Global.kart_classes.get(selected_class, {})
	
	# Clear existing stats
	for child in stats_panel.get_children():
		child.queue_free()
	
	# Class name
	var name_label = Label.new()
	name_label.text = class_data.get("name", "Unknown")
	name_label.add_theme_font_size_override("font_size", 28)
	name_label.add_theme_color_override("font_color", Color(0.0, 1.0, 1.0))
	stats_panel.add_child(name_label)
	
	# Description
	var desc_label = Label.new()
	desc_label.text = class_data.get("description", "")
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	stats_panel.add_child(desc_label)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	stats_<applaa-write path="godot-project/scripts/Garage.gd" description="Garage screen for kart customization">
extends Control

@onready var kart_preview: Node2D = $KartPreviewViewport/KartPreview
@onready var class_list: VBoxContainer = $LeftPanel/ClassList
@onready var stats_panel: VBoxContainer = $RightPanel/StatsPanel
@onready var color_picker: ColorPickerButton = $RightPanel/CustomizePanel/ColorPicker
@onready var glow_picker: ColorPickerButton = $RightPanel/CustomizePanel/GlowPicker
@onready var credits_label: Label = $TopBar/CreditsLabel
@onready var back_button: Button = $TopBar/BackButton
@onready var select_button: Button = $BottomBar/SelectButton

var selected_class: String = "balanced"
var preview_rotation: float = 0.0

func _ready() -> void:
	setup_class_list()
	setup_customization()
	setup_buttons()
	update_credits_display()
	select_class(Global.selected_kart_class)

func _process(delta: float) -> void:
	# Rotate kart preview
	preview_rotation += delta * 0.5
	if kart_preview:
		kart_preview.rotation = preview_rotation

func setup_class_list() -> void:
	for child in class_list.get_children():
		child.queue_free()
	
	for class_id in Global.kart_classes:
		var class_data = Global.kart_classes[class_id]
		var is_unlocked = class_id in Global.unlocked_karts
		
		var button = Button.new()
		button.text = class_data.get("name", class_id)
		button.custom_minimum_size = Vector2(200, 50)
		button.disabled = not is_unlocked
		
		if not is_unlocked:
			button.text += " 🔒"
		
		style_class_button(button, is_unlocked)
		button.pressed.connect(_on_class_selected.bind(class_id))
		class_list.add_child(button)

func style_class_button(button: Button, unlocked: bool) -> void:
	var style = StyleBoxFlat.new()
	
	if unlocked:
		style.bg_color = Color(0.1, 0.15, 0.25, 0.9)
		style.border_color = Color(0.0, 0.8, 1.0)
	else:
		style.bg_color = Color(0.1, 0.1, 0.1, 0.5)
		style.border_color = Color(0.3, 0.3, 0.3)
	
	style.set_border_width_all(2)
	style.set_corner_radius_all(8)
	button.add_theme_stylebox_override("normal", style)

func setup_customization() -> void:
	if color_picker:
		color_picker.color = Global.selected_kart_color
		color_picker.color_changed.connect(_on_color_changed)
	
	if glow_picker:
		glow_picker.color = Global.selected_underglow
		glow_picker.color_changed.connect(_on_glow_changed)

func setup_buttons() -> void:
	if back_button:
		back_button.pressed.connect(_on_back_pressed)
	
	if select_button:
		select_button.pressed.connect(_on_select_pressed)
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.0, 0.6, 0.3, 0.9)
		style.border_color = Color(0.0, 1.0, 0.5)
		style.set_border_width_all(3)
		style.set_corner_radius_all(8)
		select_button.add_theme_stylebox_override("normal", style)

func _on_class_selected(class_id: String) -> void:
	if class_id not in Global.unlocked_karts:
		return
	
	select_class(class_id)
	AudioManager.play_ui_sound("click")

func select_class(class_id: String) -> void:
	selected_class = class_id
	update_stats_display()
	update_preview()

func update_stats_display() -> void:
	var class_data = Global.kart_classes.get(selected_class, {})
	
	# Clear existing stats
	for child in stats_panel.get_children():
		child.queue_free()
	
	# Class name
	var name_label = Label.new()
	name_label.text = class_data.get("name", "Unknown")
	name_label.add_theme_font_size_override("font_size", 28)
	name_label.add_theme_color_override("font_color", Color(0.0, 1.0, 1.0))
	stats_panel.add_child(name_label)
	
	# Description
	var desc_label = Label.new()
	desc_label.text = class_data.get("description", "")
	desc_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	stats_panel.add_child(desc_label)
	
	# Spacer
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(0, 20)
	stats_panel.add_child(spacer)
	
	# Stats bars
	add_stat_bar("SPEED", class_data.get("max_speed", 400) / 600.0)
	add_stat_bar("ACCELERATION", class_data.get("acceleration", 250) / 400.0)
	add_stat_bar("HANDLING", class_data.get("handling", 0.8))
	add_stat_bar("BOOST POWER", class_data.get("boost_power", 1.0) / 1.5)
	add_stat_bar("DRIFT BONUS", class_data.get("drift_bonus", 1.0) / 1.5)
	
	# Special ability
	var special_spacer = Control.new()
	special_spacer.custom_minimum_size = Vector2(0, 15)
	stats_panel.add_child(special_spacer)
	
	var special_label = Label.new()
	special_label.text = "SPECIAL: " + class_data.get("special", "none").to_upper().replace("_", " ")
	special_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0))
	special_label.add_theme_font_size_override("font_size", 18)
	stats_panel.add_child(special_label)

func add_stat_bar(stat_name: String, value: float) -> void:
	var container = HBoxContainer.new()
	container.custom_minimum_size = Vector2(0, 30)
	
	var label = Label.new()
	label.text = stat_name
	label.custom_minimum_size = Vector2(120, 0)
	label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
	container.add_child(label)
	
	var bar_bg = ColorRect.new()
	bar_bg.custom_minimum_size = Vector2(150, 20)
	bar_bg.color = Color(0.2, 0.2, 0.2)
	container.add_child(bar_bg)
	
	var bar_fill = ColorRect.new()
	bar_fill.custom_minimum_size = Vector2(150 * clamp(value, 0, 1), 20)
	bar_fill.color = Color(0.0, 0.8, 1.0).lerp(Color(1.0, 0.3, 0.0), value)
	bar_fill.position = Vector2.ZERO
	bar_bg.add_child(bar_fill)
	
	stats_panel.add_child(container)

func update_preview() -> void:
	# Update kart preview colors
	if kart_preview:
		kart_preview.modulate = Global.selected_kart_color

func update_credits_display() -> void:
	if credits_label:
		credits_label.text = "Credits: %d" % Global.credits

func _on_color_changed(color: Color) -> void:
	Global.selected_kart_color = color
	update_preview()

func _on_glow_changed(color: Color) -> void:
	Global.selected_underglow = color
	update_preview()

func _on_select_pressed() -> void:
	Global.selected_kart_class = selected_class
	Global.save_game_data()
	AudioManager.play_ui_sound("confirm")
	
	# Show confirmation
	if select_button:
		select_button.text = "SELECTED!"
		var tween = create_tween()
		tween.tween_interval(1.0)
		tween.tween_callback(func(): select_button.text = "SELECT KART")

func _on_back_pressed() -> void:
	AudioManager.play_ui_sound("back")
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_back_pressed()