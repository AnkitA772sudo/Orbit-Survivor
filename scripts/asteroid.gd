extends Area2D

@export var speed: float = 80.0
var direction: Vector2 = Vector2.RIGHT
var health: float = 30.0

var _drawn_points: PackedVector2Array = PackedVector2Array()

func _ready():
	rotation = direction.angle()
	# Generate shape once and cache it
	_generate_shape()

func _generate_shape():
	var rng = RandomNumberGenerator.new()
	rng.seed = int(global_position.x + global_position.y)
	var points = PackedVector2Array()
	var count = 8
	for i in range(count):
		var angle = i * TAU / count
		var r = 18.0 + rng.randf_range(-6.0, 6.0)
		points.append(Vector2(cos(angle), sin(angle)) * r)
	
	_drawn_points = points
	
	# Collision shape
	$CollisionShape2D.shape = ConvexPolygonShape2D.new()
	$CollisionShape2D.shape.points = points

func _process(delta):
	position += direction * speed * delta
	
	var cam = get_viewport().get_camera_2d()
	if cam and global_position.distance_to(cam.global_position) > 2500:
		queue_free()

func _draw():
	# Use cached points - no RNG here!
	draw_colored_polygon(_drawn_points, Color(0.5, 0.4, 0.35))
	for i in range(_drawn_points.size()):
		draw_line(_drawn_points[i], _drawn_points[(i+1) % _drawn_points.size()], Color(0.3, 0.25, 0.2), 2.0)

func take_damage(amount: float):
	health -= amount
	if health <= 0.0:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(25.0)
		queue_free()

