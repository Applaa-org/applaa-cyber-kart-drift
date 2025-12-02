extends Control

@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var loading_label: Label = $VBoxContainer/LoadingLabel
@onready var title_label: Label = $VBoxContainer/TitleLabel

var load_progress: float = 0.0
var target_scene: String = "res://scenes/StartScreen.tscn"

func _ready() -> void:
	setup_visuals()
	start_loading()

func setup_visuals() -> void:
	if title_label:
		title_label.add_theme_font_size_override("font_size", 48)
		title_label.add_theme_color_override("font_color", Color(0.0, 0.9, 1.0))
	
	if loading_label:
		loading_label.add_theme_font_size_override("font_size", 18)
		loading_label.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
	
	if progress_bar:
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.0, 0.8, 1.0)
		progress_bar.add_theme_stylebox_override("fill", style)

func start_loading() -> void:
	# Simulate loading with tween
	var tween = create_tween()
	tween.tween_method(update_progress, 0.0, 100.0, 1.5)
	tween.tween_callback(finish_loading)

func update_progress(value: float) -> void:
	load_progress = value
	if progress_bar:
		progress_bar.value = value
	
	if loading_label:
		if value < 30:
			loading_label.text = "Initializing systems..."
		elif value < 60:
			loading_label.text = "Loading assets..."
		elif value < 90:
			loading_label.text = "Preparing race tracks..."
		else:
			loading_label.text = "Ready!"

func finish_loading() -> void:
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file(target_scene)