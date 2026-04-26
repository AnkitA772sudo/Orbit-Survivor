extends CanvasLayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()

func _on_resume_pressed():
	get_parent().toggle_pause()

func _on_restart_pressed():
	get_tree().paused = false
	Global.reset_game()
	get_tree().reload_current_scene()

func _on_menu_pressed():
	get_tree().paused = false
	Global.reset_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
