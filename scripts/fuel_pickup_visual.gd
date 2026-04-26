extends Node2D

@export var bob_speed: float = 2.5
@export var bob_amplitude: float = 5.0
@export var rotation_speed: float = 30.0

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
	var w = 10.0
	var h = 14.0
	
	# Simple fuel cell (dark body + green window)
	var body_color = Color(0.15, 0.15, 0.2)
	var fuel_color = Color(0.2, 0.9, 0.3)
	
	# Main body
	draw_rect(Rect2(-w, -h, w * 2, h * 2), body_color)
	
	# Fuel window
	draw_rect(Rect2(-w + 2, -h + 4, w * 2 - 4, h * 2 - 8), Color(0.1, 0.1, 0.15))
	draw_rect(Rect2(-w + 3, -h + 6, w * 2 - 6, h * 2 - 12), fuel_color)
	
	# Top cap
	draw_rect(Rect2(-w * 0.5, -h - 3, w, 3), Color(0.4, 0.4, 0.45))

