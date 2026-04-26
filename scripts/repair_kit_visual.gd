extends Node2D

@export var bob_speed: float = 3.0
@export var bob_amplitude: float = 4.0
@export var rotation_speed: float = 45.0

var base_y: float = 0.0
var time: float = 0.0

func _ready():
	base_y = position.y

func _process(delta):
	time += delta
	position.y = base_y + sin(time * bob_speed) * bob_amplitude
	rotation_degrees += rotation_speed * delta
	# NO queue_redraw() needed - Godot auto-redraws on transform change!

func _draw():
	var size = 12.0
	
	# Simple medical kit (red box + white cross)
	var case_color = Color(0.9, 0.15, 0.15)
	var case_dark = Color(0.6, 0.1, 0.1)
	
	# Main box
	draw_rect(Rect2(-size, -size * 0.75, size * 2, size * 1.5), case_dark)
	draw_rect(Rect2(-size + 2, -size * 0.75 + 2, size * 2 - 4, size * 1.5 - 4), case_color)
	
	# White cross
	draw_rect(Rect2(-1.5, -4.5, 3, 9), Color.WHITE)
	draw_rect(Rect2(-4.5, -1.5, 9, 3), Color.WHITE)

