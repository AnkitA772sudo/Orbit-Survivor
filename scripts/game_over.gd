extends CanvasLayer

@onready var score_label: Label = $Panel/VBoxContainer/ScoreLabel
@onready var time_label: Label = $Panel/VBoxContainer/TimeLabel
@onready var high_score_label: Label = $Panel/VBoxContainer/HighScoreLabel

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func show_game_over(score: int, time_sec: int):
	score_label.text = "Score: %d" % score
	var mins = time_sec / 60
	var secs = time_sec % 60
	time_label.text = "Survived: %02d:%02d" % [mins, secs]
	high_score_label.text = "High Score: %d" % Global.high_score
	show()

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_menu_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
