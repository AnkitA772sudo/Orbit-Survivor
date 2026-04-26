extends Area2D

@export var expand_speed: float = 120.0
@export var max_radius: float = 300.0
@export var damage_per_sec: float = 40.0

var current_radius: float = 10.0
var growing: bool = true
var fading: bool = false
var last_drawn_radius: float = -1.0

func _ready():
	$CollisionShape2D.shape = CircleShape2D.new()

func _process(delta):
	var changed = false
	
	if growing:
		current_radius += expand_speed * delta
		if current_radius >= max_radius:
			growing = false
			fading = true
		changed = true
	elif fading:
		current_radius -= expand_speed * delta * 0.5
		if current_radius <= 0.0:
			queue_free()
			return
		changed = true
	
	$CollisionShape2D.shape.radius = current_radius
	
	# Only redraw if radius changed significantly (reduces draw calls)
	if changed and abs(current_radius - last_drawn_radius) > 2.0:
		last_drawn_radius = current_radius
		queue_redraw()
	
	# Continuous damage to overlapping player (throttled)
	if Engine.get_process_frames() % 5 == 0:
		for body in get_overlapping_bodies():
			if body.is_in_group("player"):
				body.take_damage(damage_per_sec * delta * 5.0)

func _draw():
	var alpha = 0.3 if growing else 0.15
	# Simplified draw - single circle, no arc
	draw_circle(Vector2.ZERO, current_radius, Color(1.0, 0.6, 0.1, alpha))
