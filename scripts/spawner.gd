extends Node

var Meteor = preload("res://scenes/meteor.tscn")
var Asteroid = preload("res://scenes/asteroid.tscn")
var SolarFlare = preload("res://scenes/solar_flare.tscn")
var FuelPickup = preload("res://scenes/fuel_pickup.tscn")
var RepairKit = preload("res://scenes/repair_kit.tscn")
var UpgradePickup = preload("res://scenes/upgrade.tscn")

@onready var spawn_timer: Timer = $SpawnTimer

var difficulty_timer: float = 0.0
var spawn_rate: float = 0.8

# Max objects to prevent lag
const MAX_METEORS = 30
const MAX_ASTEROIDS = 20
const MAX_PICKUPS = 10

func _ready():
	spawn_timer.wait_time = spawn_rate
	spawn_timer.start()

func _process(delta):
	difficulty_timer += delta
	# Faster spawns: cap at 0.12s (very fast waves) with steeper difficulty curve
	spawn_rate = max(0.12, 0.8 - Global.difficulty * 0.18)
	spawn_timer.wait_time = spawn_rate

func _on_spawn_timer_timeout():
	if Global.is_game_over or Global.is_paused:
		return
	
	# Count existing objects
	var meteor_count = get_tree().get_nodes_in_group("meteor").size()
	var asteroid_count = get_tree().get_nodes_in_group("asteroid").size()
	var pickup_count = get_tree().get_nodes_in_group("pickup").size()
	
	# Only spawn if under limits
	if meteor_count < MAX_METEORS or asteroid_count < MAX_ASTEROIDS:
		spawn_hazard()
	
	if pickup_count < MAX_PICKUPS and randf() < 0.25:
		spawn_pickup()

func spawn_hazard():
	var cam = get_viewport().get_camera_2d()
	var screen = get_viewport().get_visible_rect().size
	var spawn_pos = cam.global_position + random_offscreen(screen)
	
	var roll = randf()
	var diff = Global.difficulty
	
	if roll < 0.5:
		# Meteor
		var m = Meteor.instantiate()
		m.global_position = spawn_pos
		m.add_to_group("meteor")
		m.direction = (cam.global_position - spawn_pos + Vector2(randf_range(-200,200), randf_range(-200,200))).normalized()
		m.speed = randf_range(200, 350) + diff * 20
		add_child(m)
	elif roll < 0.8:
		# Asteroid
		var a = Asteroid.instantiate()
		a.global_position = spawn_pos
		a.add_to_group("asteroid")
		a.direction = (cam.global_position - spawn_pos).normalized()
		a.speed = randf_range(60, 120) + diff * 10
		add_child(a)
	else:
		if diff > 2.0 and randf() < 0.3:
			# Solar Flare
			var s = SolarFlare.instantiate()
			s.global_position = spawn_pos
			add_child(s)

func spawn_pickup():
	var cam = get_viewport().get_camera_2d()
	var screen = get_viewport().get_visible_rect().size
	var pos = cam.global_position + Vector2(randf_range(-screen.x*0.4, screen.x*0.4), randf_range(-screen.y*0.4, screen.y*0.4))
	
	var roll = randf()
	var node = null
	
	if roll < 0.5:
		node = FuelPickup.instantiate()
	elif roll < 0.8:
		node = RepairKit.instantiate()
	else:
		node = UpgradePickup.instantiate()
	
	if node:
		node.global_position = pos
		node.add_to_group("pickup")
		get_parent().add_child(node)

func random_offscreen(screen: Vector2) -> Vector2:
	var side = randi() % 4
	match side:
		0: return Vector2(-screen.x * 0.6, randf_range(-screen.y, screen.y))
		1: return Vector2(screen.x * 0.6, randf_range(-screen.y, screen.y))
		2: return Vector2(randf_range(-screen.x, screen.x), -screen.y * 0.6)
		3: return Vector2(randf_range(-screen.x, screen.x), screen.y * 0.6)
	return Vector2.ZERO
