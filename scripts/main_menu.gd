extends Control

@onready var high_score_label: Label = $VBoxContainer/HighScoreLabel

func _ready():
	refresh_high_score()

func refresh_high_score():
	high_score_label.text = "High Score: %d" % Global.high_score

func _on_play_pressed():
	Global.reset_upgrades()
	Global.reset_game()
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_how_to_play_pressed():
	$HowToPlayPanel.show()

func _on_close_how_to_play_pressed():
	$HowToPlayPanel.hide()

func _on_quit_pressed():
	get_tree().quit()
