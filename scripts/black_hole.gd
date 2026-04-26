extends StaticBody2D

@export var radius: float = 30.0
@export var gravity_strength: float = 150000.0
@export var event_horizon_damage: float = 80.0

var spin_angle: float = 0.0
var accretion_spin: float = 0.5

func _ready():
	var shape = CircleShape2D.new()
	shape.radius = radius
	$CollisionShape2D.shape = shape
	
	var gravity_radius = radius * 10.0
	$GravityArea/CollisionShape2D.shape = CircleShape2D.new()
	$GravityArea/CollisionShape2D.shape.radius = gravity_radius
	
	# Event horizon damage area
	$DamageArea/CollisionShape2D.shape = CircleShape2D.new()
	$DamageArea/CollisionShape2D.shape.radius = radius * 1.5
	
	add_to_group("gravity_sources")
	add_to_group("black_hole")

func _process(delta):
	spin_angle += accretion_spin * delta

func _draw():
	var center = Vector2.ZERO
	var r = radius
	
	# Simple accretion disk (2 arcs only)
	var tilt = 0.25
	draw_set_transform(center, 0.0, Vector2(1.0, tilt))
	
	# Back half (dim)
	draw_arc(Vector2.ZERO, r * 2.5, 0.0, PI, 24, Color(1.0, 0.4, 0.1, 0.3), 2.0)
	# Front half (bright)
	draw_arc(Vector2.ZERO, r * 2.5, PI, TAU, 24, Color(1.0, 0.6, 0.2, 0.5), 3.0)
	
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	
	# Photon ring
	draw_arc(center, r * 1.3, 0.0, TAU, 32, Color(1.0, 0.9, 0.6, 0.7), 2.0)
	
	# Event horizon (black)
	draw_circle(center, r, Color(0.0, 0.0, 0.0, 1.0))
	# Inner glow
	draw_circle(center, r * 0.85, Color(0.05, 0.0, 0.08, 0.6))

func _on_damage_area_body_entered(body):
	if body.is_in_group("player"):
		body.take_damage(event_horizon_damage)

func _on_damage_area_body_exited(body):
	pass

