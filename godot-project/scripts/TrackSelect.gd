extends Control

@onready var track_list: VBoxContainer = $HSplitContainer/TrackList/ScrollContainer/VBoxContainer
@onready var track_preview: TextureRect = $HSplitContainer/PreviewPanel/TrackPreview
@onready var track_name_label: Label = $HSplitContainer/PreviewPanel/TrackInfo/TrackNameLabel
@onready var track_world_label: Label = $HSplitContainer/PreviewPanel/TrackInfo/TrackWorldLabel
@onready var track_difficulty_label: Label = $HSplitContainer/PreviewPanel/TrackInfo/DifficultyLabel
@onready var best_time_label: Label = $HSplitContainer/PreviewPanel/TrackInfo/BestTimeLabel
@onready var start_button: Button = $HSplitContainer/PreviewPanel/StartButton
@onready var back_button: Button = $BackButton

var selected_track: String = ""
var track_buttons: Dictionary = {}

func _ready() -> void:
	setup_track_list()
	setup_buttons()
	
	# Select first available track
	if not Global.unlocked_tracks.is_empty():
		select_track(Global.unlocked_tracks[0])

func setup_track_list() -> void:
	# Clear existing
	for child in track_list.get_children():
		child.queue_free()
	
	# Group tracks by world
	var worlds: Dictionary = {}
	for track_id in Global.tracks:
		var track_data = Global.tracks[track_id]
		var world = track_data.get("world", "Unknown")
		if world not in worlds:
			worlds[world] = []
		worlds[world].append(track_id)
	
	# Create world sections
	for world in worlds:
		# World header
		var header = Label.new()
		header.text = world.to_upper()
		header.add_theme_font_size_override("font_size", 20)
		header.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0))
		track_list.add_child(header)
		
		# Track buttons
		for track_id in worlds[world]:
			var track_data = Global.tracks[track_id]
			var is_unlocked = track_id in Global.unlocked_tracks
			
			var button = Button.new()
			button.text = track_data.get("name", track_id)
			button.custom_minimum_size = Vector2(250, 40)
			button.disabled = not is_unlocked
			
			# Style
			style_track_button(button, is_unlocked)
			
			button.pressed.connect(_on_track_selected.bind(track_id))
			track_list.add_child(button)
			track_buttons[track_id] = button
		
		# Spacer
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 10)
		track_list.add_child(spacer)

func style_track_button(button: Button, unlocked: bool) -> void:
	var style = StyleBoxFlat.new()
	
	if unlocked:
		style.bg_color = Color(0.1, 0.2, 0.3, 0.8)
		style.border_color = Color(0.0, 0.8, 1.0)
		button.add_theme_color_override("font_color", Color.WHITE)
	else:
		style.bg_color = Color(0.1, 0.1, 0.1, 0.5)
		style.border_color = Color(0.3, 0.3, 0.3)
		button.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
	
	style.set_border_width_all(2)
	style.set_corner_radius_all(5)
	button.add_theme_stylebox_override("normal", style)

func setup_buttons() -> void:
	if start_button:
		start_button.pressed.connect(_on_start_pressed)
		
		var style = StyleBoxFlat.new()
		style.bg_color = Color(0.0, 0.6, 0.3, 0.9)
		style.border_color = Color(0.0, 1.0, 0.5)
		style.set_border_width_all(3)
		style.set_corner_radius_all(8)
		start_button.add_theme_stylebox_override("normal", style)
		start_button.add_theme_font_size_override("font_size", 24)
	
	if back_button:
		back_button.pressed.connect(_on_back_pressed)

func _on_track_selected(track_id: String) -> void:
	select_track(track_id)
	AudioManager.play_ui_sound("click")

func select_track(track_id: String) -> void:
	selected_track = track_id
	
	# Highlight selected button
	for tid in track_buttons:
		var button = track_buttons[tid]
		if tid == track_id:
			button.modulate = Color(1.2, 1.2, 1.0)
		else:
			button.modulate = Color.WHITE
	
	# Update preview
	update_preview(track_id)

func update_preview(track_id: String) -> void:
	var track_data = Global.tracks.get(track_id, {})
	
	if track_name_label:
		track_name_label.text = track_data.get("name", "Unknown Track")
	
	if track_world_label:
		track_world_label.text = track_data.get("world", "Unknown World")
	
	if track_difficulty_label:
		var difficulty = track_data.get("difficulty", 1)
		var stars = "★".repeat(difficulty) + "☆".repeat(5 - difficulty)
		track_difficulty_label.text = "Difficulty: " + stars
	
	if best_time_label:
		var best = track_data.get("best_time", 0.0)
		if best > 0:
			best_time_label.text = "Best: " + format_time(best)
		else:
			best_time_label.text = "Best: --:--.---"

func format_time(time_seconds: float) -> String:
	var minutes = int(time_seconds) / 60
	var seconds = int(time_seconds) % 60
	var ms = int((time_seconds - int(time_seconds)) * 1000)
	return "%d:%02d.%03d" % [minutes, seconds, ms]

func _on_start_pressed() -> void:
	if selected_track == "":
		return
	
	AudioManager.play_ui_sound("confirm")
	Global.current_track = selected_track
	get_tree().change_scene_to_file("res://scenes/Race.tscn")

func _on_back_pressed() -> void:
	AudioManager.play_ui_sound("back")
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")