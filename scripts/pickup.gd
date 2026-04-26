extends Area2D

@export var pickup_type: String = "fuel"  # fuel, repair, upgrade
@export var amount: float = 25.0
@export var color: Color = Color(0.0, 1.0, 0.5)

var bob_offset: float = 0.0

func _ready():
	bob_offset = randf() * TAU

func _process(delta):
	var t = float(Time.get_ticks_msec()) / 1000.0
	position.y += sin(t * 2.0 + bob_offset) * 0.3

func _on_body_entered(body):
	if body.is_in_group("player"):
		match pickup_type:
			"fuel":
				body.add_fuel(amount)
				Global.add_score(5)
			"repair":
				body.repair(amount)
				Global.add_score(5)
			"upgrade":
				apply_random_upgrade(body)
				Global.add_score(25)
		queue_free()

func apply_random_upgrade(player):
	var options = ["thruster", "shield", "fuel", "gravity"]
	var choice = options[randi() % options.size()]
	match choice:
		"thruster":
			Global.upgrade_thruster = min(Global.upgrade_thruster + 1, 5)
			player.base_thrust += 50.0
		"shield":
			Global.upgrade_shield = min(Global.upgrade_shield + 1, 5)
			player.max_shield += 25.0
			player.shield = player.max_shield
		"fuel":
			Global.upgrade_fuel = min(Global.upgrade_fuel + 1, 5)
			player.max_fuel += 20.0
			player.fuel = player.max_fuel
		"gravity":
			Global.upgrade_gravity = min(Global.upgrade_gravity + 1, 5)

func _draw():
	match pickup_type:
		"fuel":
			draw_rect(Rect2(-8, -10, 16, 20), Color(0.0, 0.9, 1.0))
			draw_rect(Rect2(-4, -14, 8, 4), Color(0.0, 0.9, 1.0))
		"repair":
			draw_rect(Rect2(-3, -10, 6, 20), Color(0.2, 1.0, 0.3))
			draw_rect(Rect2(-10, -3, 20, 6), Color(0.2, 1.0, 0.3))
		"upgrade":
			var pts = []
			for i in range(5):
				var angle = -PI/2 + i * TAU/5
				var r = 12.0 if i % 2 == 0 else 6.0
				pts.append(Vector2(cos(angle), sin(angle)) * r)
			draw_colored_polygon(pts, Color(1.0, 0.8, 0.0))

