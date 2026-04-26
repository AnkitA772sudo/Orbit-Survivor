extends StaticBody2D

@export var radius: float = 60.0
@export var gravity_strength: float = 200000.0
@export var planet_color: Color = Color(0.2, 0.6, 1.0)
@export var has_rings: bool = false
@export var ring_color: Color = Color(0.8, 0.7, 0.5, 0.6)

func _ready():
	var shape = CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape
	
	var gravity_radius = radius * 12.0
	$GravityArea/CollisionShape2D.shape = CircleShape2D.new()
	$GravityArea/CollisionShape2D.shape.radius = gravity_radius
	
	add_to_group("gravity_sources")

func _draw():
	# Simple planet body with shadow
	var shadow_color = planet_color.darkened(0.4)
	draw_circle(Vector2.ZERO, radius, shadow_color)
	
	# Lit side
	var lit_color = planet_color.lightened(0.15)
	draw_circle(Vector2(-radius * 0.15, -radius * 0.15), radius * 0.88, lit_color)
	
	# One surface band
	var band_color = planet_color.darkened(0.2)
	draw_circle(Vector2.ZERO, radius * 0.5, Color(band_color.r, band_color.g, band_color.b, 0.25))
	
	# One crater
	draw_circle(Vector2(radius * 0.3, radius * 0.2), radius * 0.08, planet_color.darkened(0.3))
	
	# Simple ring (if enabled)
	if has_rings:
		var ring_r = radius * 1.6
		draw_arc(Vector2.ZERO, ring_r, 0.0, TAU, 32, Color(ring_color.r, ring_color.g, ring_color.b, 0.5), 3.0)

