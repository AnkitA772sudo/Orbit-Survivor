extends Node2D

@export var star_count: int = 150

var stars: Array[Dictionary] = []
var time: float = 0.0

func _ready():
	generate_stars()

func generate_stars():
	stars.clear()
	for i in range(star_count):
		stars.append({
			"pos": Vector2(randf_range(-2000, 2000), randf_range(-2000, 2000)),
			"size": randf_range(0.5, 2.5),
			"brightness": randf_range(0.3, 1.0),
			"twinkle_speed": randf_range(0.5, 3.0),
			"twinkle_offset": randf_range(0.0, TAU),
			"parallax": randf_range(0.02, 0.15),
			"color": _random_star_color(),
		})

func _random_star_color() -> Color:
	var r = randf()
	if r < 0.6:
		return Color(1.0, 1.0, 1.0)
	elif r < 0.8:
		return Color(0.7, 0.8, 1.0)
	elif r < 0.9:
		return Color(1.0, 0.9, 0.7)
	else:
		return Color(1.0, 0.6, 0.5)

func _process(delta):
	time += delta
	queue_redraw()

func _draw():
	var cam = get_viewport().get_camera_2d()
	var cam_pos = cam.global_position if cam else Vector2.ZERO
	
	# Deep space background
	draw_rect(Rect2(cam_pos - Vector2(1500, 1500), Vector2(3000, 3000)), Color(0.01, 0.015, 0.04, 1.0))
	
	# Draw stars
	for star in stars:
		var parallax = star["parallax"]
		var pos = star["pos"] - cam_pos * parallax
		
		# Wrap around
		pos.x = fmod(pos.x + 2000, 4000) - 2000
		pos.y = fmod(pos.y + 2000, 4000) - 2000
		star["pos"] = pos + cam_pos * parallax
		
		# Twinkle
		var twinkle = sin(time * star["twinkle_speed"] + star["twinkle_offset"]) * 0.5 + 0.5
		var alpha = star["brightness"] * (0.4 + 0.6 * twinkle)
		var size = star["size"]
		var color = star["color"]
		
		var draw_pos = pos + cam_pos * (1.0 - parallax)
		
		# Single draw call per star (fast!)
		draw_circle(draw_pos, size, Color(color.r, color.g, color.b, alpha))
