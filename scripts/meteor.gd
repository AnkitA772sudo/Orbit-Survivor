extends Area2D

@export var speed: float = 450.0
var direction: Vector2 = Vector2.RIGHT

func _ready():
	rotation = direction.angle()

func _process(delta):
	position += direction * speed * delta
	
	# Despawn if too far
	var cam = get_viewport().get_camera_2d()
	if cam and global_position.distance_to(cam.global_position) > 2000:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(15.0)
		queue_free()

func _draw():
	draw_circle(Vector2.ZERO, 6.0, Color(0.9, 0.3, 0.1))
	draw_circle(Vector2.ZERO, 4.0, Color(1.0, 0.5, 0.2))

