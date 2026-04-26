extends Node

# Game State
var score: int = 0
var high_score: int = 0
var survival_time: float = 0.0
var is_game_over: bool = false
var is_paused: bool = false

# Upgrade Levels (0 = none, max 5)
var upgrade_thruster: int = 0
var upgrade_shield: int = 0
var upgrade_fuel: int = 0
var upgrade_gravity: int = 0

# Difficulty
var difficulty: float = 1.0

func _ready():
	load_high_score()

func reset_game():
	score = 0
	survival_time = 0.0
	is_game_over = false
	is_paused = false
	difficulty = 1.0

func add_score(points: int):
	score += points
	if score > high_score:
		high_score = score
		save_high_score()

func save_high_score():
	var file = FileAccess.open("user://highscore.save", FileAccess.WRITE)
	if file:
		file.store_var(high_score)
		file.close()

func load_high_score():
	if FileAccess.file_exists("user://highscore.save"):
		var file = FileAccess.open("user://highscore.save", FileAccess.READ)
		if file:
			high_score = file.get_var()
			file.close()

func reset_upgrades():
	upgrade_thruster = 0
	upgrade_shield = 0
	upgrade_fuel = 0
	upgrade_gravity = 0

