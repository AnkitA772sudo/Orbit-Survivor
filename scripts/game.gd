extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var hud: CanvasLayer = $HUD
@onready var spawner: Node = $Spawner
@onready var pause_menu: CanvasLayer = $PauseMenu
@onready var game_over_screen: CanvasLayer = $GameOver

var _last_score: int = -1
var _last_time: int = -1

func _ready():
	Global.reset_game()
	get_tree().paused = false
	pause_menu.hide()
	game_over_screen.hide()

func _process(delta):
	if Global.is_game_over:
		return
	Global.survival_time += delta
	Global.difficulty = 1.0 + Global.survival_time / 30.0
	Global.add_score(int(delta * 10))

	# Update HUD only when values change (reduces UI overhead)
	var current_time = int(Global.survival_time)
	var current_score = Global.score
	if current_time != _last_time or current_score != _last_score:
		hud.update_player_ui(player)
		hud.update_score(current_score, current_time)
		_last_time = current_time
		_last_score = current_score

	if Input.is_action_just_pressed("pause") and not Global.is_game_over:
		toggle_pause()

func toggle_pause():
	Global.is_paused = not Global.is_paused
	get_tree().paused = Global.is_paused
	if Global.is_paused:
		pause_menu.show()
	else:
		pause_menu.hide()

func game_over():
	get_tree().paused = true
	game_over_screen.show_game_over(Global.score, int(Global.survival_time))
