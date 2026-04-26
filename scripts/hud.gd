extends CanvasLayer

@onready var fuel_bar: ProgressBar = $MarginContainer/VBoxContainer/HBoxContainer/FuelBar
@onready var health_bar: ProgressBar = $MarginContainer/VBoxContainer/HBoxContainer2/HealthBar
@onready var shield_bar: ProgressBar = $MarginContainer/VBoxContainer/HBoxContainer3/ShieldBar
@onready var score_label: Label = $MarginContainer/VBoxContainer/ScoreLabel
@onready var time_label: Label = $MarginContainer/VBoxContainer/TimeLabel

func _ready():
	# Style bars neon
	style_bar(fuel_bar, Color(0.0, 0.9, 1.0))
	style_bar(health_bar, Color(1.0, 0.2, 0.3))
	style_bar(shield_bar, Color(0.3, 0.6, 1.0))

func style_bar(bar: ProgressBar, color: Color):
	var fg = StyleBoxFlat.new()
	fg.bg_color = color
	fg.border_color = color.lightened(0.4)
	fg.border_width_bottom = 2
	fg.border_width_top = 2
	fg.border_width_left = 2
	fg.border_width_right = 2
	bar.add_theme_stylebox_override("fill", fg)
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.05, 0.05, 0.1, 0.8)
	bar.add_theme_stylebox_override("background", bg)

func update_player_ui(player):
	if not is_instance_valid(player):
		return
	fuel_bar.max_value = player.max_fuel
	fuel_bar.value = player.fuel
	health_bar.max_value = player.max_health
	health_bar.value = player.health
	shield_bar.max_value = player.max_shield
	shield_bar.value = player.shield

func update_score(score: int, time_sec: int):
	score_label.text = "Score: %d" % score
	var mins = time_sec / 60
	var secs = time_sec % 60
	time_label.text = "Time: %02d:%02d" % [mins, secs]

