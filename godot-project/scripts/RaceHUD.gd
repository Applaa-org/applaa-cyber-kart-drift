extends CanvasLayer

# References
var race_manager: RaceManager
var player_kart: PlayerKart

# UI Elements
@onready var speed_label: Label = $SpeedContainer/SpeedLabel
@onready var speed_bar: ProgressBar = $SpeedContainer/SpeedBar
@onready var position_label: Label = $PositionContainer/PositionLabel
@onready var lap_label: Label = $LapContainer/LapLabel
@onready var time_label: Label = $TimeContainer/TimeLabel
@onready var boost_bar: ProgressBar = $BoostContainer/BoostBar
@onready var special_bar: ProgressBar = $SpecialContainer/SpecialBar
@onready var health_bar: ProgressBar = $HealthContainer/HealthBar
@onready var weapon_icon: TextureRect = $WeaponContainer/WeaponIcon
@onready var weapon_label: Label = $WeaponContainer/WeaponLabel
@onready var countdown_label: Label = $CountdownLabel
@onready var drift_score_label: Label = $DriftScoreLabel
@onready var minimap: Control = $Minimap

# State
var showing_drift_score: bool = false
var drift_score_timer: float = 0.0
var current_drift_score: int = 0

func _ready() -> void:
	setup_ui_style()
	hide_countdown()

func setup_ui_style() -> void:
	# Style progress bars with cyberpunk colors
	if boost_bar:
		var boost_style = StyleBoxFlat.new()
		boost_style.bg_color = Color(0.0, 0.8, 1.0)
		boost_bar.add_theme_stylebox_override("fill", boost_style)
	
	if special_bar:
		var special_style = StyleBoxFlat.new()
		special_style.bg_color = Color(1.0, 0.0, 0.5)
		special_bar.add_theme_stylebox_override("fill", special_style)
	
	if health_bar:
		var health_style = StyleBoxFlat.new()
		health_style.bg_color = Color(0.0, 1.0, 0.3)
		health_bar.add_theme_stylebox_override("fill", health_style)

func initialize(manager: RaceManager, player: PlayerKart) -> void:
	race_manager = manager
	player_kart = player
	
	# Connect player signals
	if player_kart:
		player_kart.health_changed.connect(_on_health_changed)
		player_kart.boost_changed.connect(_on_boost_changed)
		player_kart.special_changed.connect(_on_special_changed)
		player_kart.weapon_changed.connect(_on_weapon_changed)
		player_kart.drift_score_added.connect(_on_drift_score_added)
	
	# Connect race manager signals
	if race_manager:
		race_manager.race_countdown_tick.connect(_on_countdown_tick)
		race_manager.race_started.connect(_on_race_started)
		race_manager.position_updated.connect(_on_position_updated)

func _process(delta: float) -> void:
	if not player_kart or not race_manager:
		return
	
	update_speed_display()
	update_time_display()
	update_lap_display()
	update_drift_score_display(delta)

func update_speed_display() -> void:
	if speed_label and player_kart:
		var speed_kmh = int(player_kart.current_speed * 2.5)
		speed_label.text = "%d KM/H" % speed_kmh
		
		if player_kart.is_boosting:
			speed_label.add_theme_color_override("font_color", Color(1.0, 0.5, 0.0))
		else:
			speed_label.add_theme_color_override("font_color", Color(0.0, 1.0, 1.0))
	
	if speed_bar and player_kart:
		speed_bar.value = (player_kart.current_speed / player_kart.max_speed) * 100

func update_time_display() -> void:
	if time_label and race_manager:
		time_label.text = race_manager.format_time(race_manager.get_race_time())

func update_lap_display() -> void:
	if lap_label and player_kart and race_manager:
		var current_lap = mini(player_kart.current_lap + 1, race_manager.total_laps)
		lap_label.text = "LAP %d/%d" % [current_lap, race_manager.total_laps]

func update_drift_score_display(delta: float) -> void:
	if not drift_score_label:
		return
	
	if showing_drift_score:
		drift_score_timer -= delta
		if drift_score_timer <= 0:
			showing_drift_score = false
			drift_score_label.visible = false
		else:
			# Fade out
			drift_score_label.modulate.a = drift_score_timer / 2.0

func _on_health_changed(new_health: int) -> void:
	if health_bar:
		health_bar.value = new_health
		
		# Flash red when damaged
		if new_health < health_bar.max_value:
			var tween = create_tween()
			health_bar.modulate = Color(1.0, 0.3, 0.3)
			tween.tween_property(health_bar, "modulate", Color.WHITE, 0.3)

func _on_boost_changed(new_boost: float) -> void:
	if boost_bar:
		boost_bar.value = new_boost

func _on_special_changed(new_special: float) -> void:
	if special_bar:
		special_bar.value = new_special
		
		# Glow when full
		if new_special >= 100:
			special_bar.modulate = Color(1.2, 1.0, 1.2)
		else:
			special_bar.modulate = Color.WHITE

func _on_weapon_changed(weapon_name: String) -> void:
	if weapon_label:
		if weapon_name == "":
			weapon_label.text = "NO WEAPON"
			weapon_label.add_theme_color_override("font_color", Color(0.5, 0.5, 0.5))
		else:
			var weapon_data = Global.weapons.get(weapon_name, {})
			weapon_label.text = weapon_data.get("name", weapon_name).to_upper()
			
			if weapon_data.get("type", "") == "offensive":
				weapon_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.3))
			else:
				weapon_label.add_theme_color_override("font_color", Color(0.3, 0.8, 1.0))

func _on_drift_score_added(score: int) -> void:
	current_drift_score = score
	showing_drift_score = true
	drift_score_timer = 2.0
	
	if drift_score_label:
		drift_score_label.visible = true
		drift_score_label.text = "+%d DRIFT!" % score
		drift_score_label.modulate.a = 1.0
		
		# Color based on score
		if score >= 500:
			drift_score_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
		elif score >= 200:
			drift_score_label.add_theme_color_override("font_color", Color(0.0, 1.0, 0.5))
		else:
			drift_score_label.add_theme_color_override("font_color", Color(0.0, 0.8, 1.0))
		
		# Scale animation
		var tween = create_tween()
		drift_score_label.scale = Vector2(1.5, 1.5)
		tween.tween_property(drift_score_label, "scale", Vector2.ONE, 0.3)

func _on_countdown_tick(count: int) -> void:
	if countdown_label:
		countdown_label.visible = true
		
		if count > 0:
			countdown_label.text = str(count)
			countdown_label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.0))
		else:
			countdown_label.text = "GO!"
			countdown_label.add_theme_color_override("font_color", Color(0.0, 1.0, 0.0))
		
		# Scale animation
		var tween = create_tween()
		countdown_label.scale = Vector2(2.0, 2.0)
		tween.tween_property(countdown_label, "scale", Vector2.ONE, 0.5)
		
		if count == 0:
			tween.tween_callback(hide_countdown)

func _on_race_started() -> void:
	# Hide countdown after a delay
	var timer = get_tree().create_timer(1.0)
	timer.timeout.connect(hide_countdown)

func _on_position_updated(positions: Array) -> void:
	if position_label and player_kart:
		var pos = player_kart.race_position
		var total = positions.size() + 1
		position_label.text = "%d/%d" % [pos, total]
		
		# Color based on position
		match pos:
			1:
				position_label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0))
			2:
				position_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
			3:
				position_label.add_theme_color_override("font_color", Color(0.8, 0.5, 0.2))
			_:
				position_label.add_theme_color_override("font_color", Color(1.0, 1.0, 1.0))

func hide_countdown() -> void:
	if countdown_label:
		countdown_label.visible = false

func show_final_lap_warning() -> void:
	if lap_label:
		lap_label.add_theme_color_override("font_color", Color(1.0, 0.3, 0.0))
		
		var tween = create_tween()
		tween.set_loops(3)
		tween.tween_property(lap_label, "scale", Vector2(1.2, 1.2), 0.2)
		tween.tween_property(lap_label, "scale", Vector2.ONE, 0.2)

func show_wrong_way_warning(show: bool) -> void:
	# Would show "WRONG WAY" indicator
	pass