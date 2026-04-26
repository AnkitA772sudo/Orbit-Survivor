extends CharacterBody2D

# --- Realistic Space Physics ---
@export var rotation_speed: float = 4.5
@export var rotation_inertia: float = 0.88
@export var base_thrust: float = 220.0
@export var base_boost: float = 480.0
@export var max_speed: float = 1200.0
@export var space_drag: float = 0.9992

@export var max_fuel: float = 100.0
@export var fuel_drain: float = 4.0
@export var fuel_drain_boost: float = 12.0

@export var max_health: float = 100.0
@export var max_shield: float = 100.0
@export var shield_regen: float = 3.0
@export var shield_regen_delay: float = 2.0

var fuel: float = 100.0
var health: float = 100.0
var shield: float = 100.0
var shield_timer: float = 0.0
var is_alive: bool = true

# Realistic momentum
var angular_velocity: float = 0.0
var engine_heat: float = 0.0

@onready var thrust_particles: CPUParticles2D = $ThrustParticles
@onready var thrust_left: CPUParticles2D = $ThrustLeft
@onready var thrust_right: CPUParticles2D = $ThrustRight
@onready var boost_particles: CPUParticles2D = $BoostParticles
@onready var boost_left: CPUParticles2D = $BoostLeft
@onready var boost_right: CPUParticles2D = $BoostRight

func _ready():
	motion_mode = MOTION_MODE_FLOATING
	apply_upgrades()
	fuel = max_fuel
	health = max_health
	shield = max_shield

func apply_upgrades():
	base_thrust += Global.upgrade_thruster * 50.0
	max_shield += Global.upgrade_shield * 25.0
	max_fuel += Global.upgrade_fuel * 20.0

func _physics_process(delta):
	if not is_alive:
		return

	# --- Realistic Rotation with Inertia ---
	var rot_input = 0.0
	if Input.is_action_pressed("rotate_left"):
		rot_input -= 1.0
	if Input.is_action_pressed("rotate_right"):
		rot_input += 1.0
	
	# Apply torque with inertia
	angular_velocity += rot_input * rotation_speed * delta
	angular_velocity *= rotation_inertia
	rotation += angular_velocity * delta

	# --- Realistic Thrust (Newton's 3rd Law) ---
	var thrusting = false
	var boosting = false
	if Input.is_action_pressed("thrust") and fuel > 0.0:
		var current_thrust = base_thrust
		var current_drain = fuel_drain
		if Input.is_action_pressed("boost"):
			current_thrust = base_boost
			current_drain = fuel_drain_boost
			boosting = true
			engine_heat = min(engine_heat + delta * 2.0, 1.0)
		else:
			engine_heat = max(engine_heat - delta * 0.5, 0.0)
		
		thrusting = true
		# Thrust applied in direction ship is facing (rear engines push forward)
		var thrust_vec = Vector2.UP.rotated(rotation) * current_thrust * delta
		velocity += thrust_vec
		fuel -= current_drain * delta
		fuel = clamp(fuel, 0.0, max_fuel)
	else:
		engine_heat = max(engine_heat - delta * 0.8, 0.0)

	# Fuel death
	if fuel <= 0.0:
		die()
		return

	# --- Realistic Space Movement (minimal drag) ---
	velocity *= space_drag
	velocity = velocity.limit_length(max_speed)

	# Gravity
	apply_gravity(delta)

	# Move
	move_and_slide()

	# Shield regen
	if shield_timer > 0.0:
		shield_timer -= delta
	else:
		shield = move_toward(shield, max_shield, shield_regen * delta)

	# --- Realistic Particle Control ---
	update_particles(thrusting, boosting, delta)

	# Boundaries - hard clamp to camera limits (prevents wrap-around glitch)
	var cam = get_viewport().get_camera_2d()
	if cam:
		global_position.x = clamp(global_position.x, cam.limit_left + 20, cam.limit_right - 20)
		global_position.y = clamp(global_position.y, cam.limit_top + 20, cam.limit_bottom - 20)

func update_particles(thrusting: bool, boosting: bool, delta: float):
	# Speed factor affects particle intensity
	var speed_ratio = velocity.length() / max_speed
	
	# Main center engine
	thrust_particles.emitting = thrusting and not boosting
	boost_particles.emitting = boosting
	
	# Side engines (left/right nozzles)
	thrust_left.emitting = thrusting and not boosting
	thrust_right.emitting = thrusting and not boosting
	boost_left.emitting = boosting
	boost_right.emitting = boosting
	
	# Adjust particle properties based on speed for realism
	if thrusting and not boosting:
		# Faster ship = longer, more stretched particles
		var stretch = 0.4 + speed_ratio * 0.6
		thrust_particles.lifetime = 0.5 + speed_ratio * 0.4
		thrust_particles.initial_velocity_min = 60.0 + speed_ratio * 40.0
		thrust_particles.initial_velocity_max = 140.0 + speed_ratio * 60.0
		
		thrust_left.lifetime = 0.4 + speed_ratio * 0.3
		thrust_right.lifetime = 0.4 + speed_ratio * 0.3
		
		# Slight color shift toward white at high speed
		var heat_tint = Color(1.0, 1.0, 1.0, 0.9).lerp(Color(0.2, 0.85, 1.0, 0.7), 1.0 - speed_ratio)
		thrust_particles.color = heat_tint
	
	if boosting:
		# Boost particles get more intense with speed
		var boost_intensity = 0.7 + speed_ratio * 0.3
		boost_particles.lifetime = 0.8 + speed_ratio * 0.4
		boost_particles.initial_velocity_min = 200.0 + speed_ratio * 100.0
		boost_particles.initial_velocity_max = 400.0 + speed_ratio * 150.0
		
		boost_left.lifetime = 0.6 + speed_ratio * 0.3
		boost_right.lifetime = 0.6 + speed_ratio * 0.3
		
		# Boost color shifts from orange to blue-white at extreme speeds
		var boost_color = Color(1.0, 0.9, 0.7, 0.95).lerp(Color(0.7, 0.85, 1.0, 0.9), speed_ratio)
		boost_particles.color = boost_color

func apply_gravity(delta: float):
	var gravity_sources = get_tree().get_nodes_in_group("gravity_sources")
	for source in gravity_sources:
		if not is_instance_valid(source):
			continue
		var dir = source.global_position - global_position
		var dist = dir.length()
		if dist < 10.0:
			continue
		var strength = source.gravity_strength / (dist * dist)
		# Gravity stabilizer upgrade reduces hostile pull slightly
		if source.is_in_group("black_hole") and Global.upgrade_gravity > 0:
			strength *= max(0.3, 1.0 - Global.upgrade_gravity * 0.15)
		velocity += dir.normalized() * strength * delta

func take_damage(amount: float):
	shield_timer = shield_regen_delay
	if shield > 0.0:
		var absorb = min(shield, amount)
		shield -= absorb
		amount -= absorb
	if amount > 0.0:
		health -= amount
	if health <= 0.0:
		die()

func die():
	is_alive = false
	thrust_particles.emitting = false
	boost_particles.emitting = false
	thrust_left.emitting = false
	thrust_right.emitting = false
	boost_left.emitting = false
	boost_right.emitting = false
	Global.is_game_over = true
	get_parent().game_over()

func add_fuel(amount: float):
	fuel = clamp(fuel + amount, 0.0, max_fuel)

func repair(amount: float):
	health = clamp(health + amount, 0.0, max_health)

func add_shield(amount: float):
	shield = clamp(shield + amount, 0.0, max_shield)

func _draw():
	# --- Realistic Spacecraft Design ---
	var body_color = Color(0.85, 0.88, 0.92)
	var dark_color = Color(0.4, 0.45, 0.5)
	var accent_color = Color(0.0, 0.75, 1.0)
	var engine_glow = Color(1.0, 0.5, 0.1).lerp(Color(1.0, 0.8, 0.3), engine_heat)
	
	# Main fuselage (elongated hexagon)
	var fuselage = [
		Vector2(0, -22),      # nose
		Vector2(6, -8),       # front shoulder
		Vector2(7, 8),        # rear shoulder
		Vector2(5, 18),       # engine mount left
		Vector2(0, 20),       # engine center
		Vector2(-5, 18),      # engine mount right
		Vector2(-7, 8),       # rear shoulder
		Vector2(-6, -8),      # front shoulder
	]
	draw_colored_polygon(fuselage, body_color)
	
	# Dark panel lines
	draw_line(Vector2(-6, -8), Vector2(-7, 8), dark_color, 1.0)
	draw_line(Vector2(6, -8), Vector2(7, 8), dark_color, 1.0)
	draw_line(Vector2(-5, 18), Vector2(5, 18), dark_color, 1.5)
	
	# Left wing
	var left_wing = [
		Vector2(-6, -2),
		Vector2(-18, 14),
		Vector2(-14, 16),
		Vector2(-7, 10),
	]
	draw_colored_polygon(left_wing, body_color)
	draw_line(Vector2(-6, -2), Vector2(-18, 14), dark_color, 1.0)
	
	# Right wing
	var right_wing = [
		Vector2(6, -2),
		Vector2(18, 14),
		Vector2(14, 16),
		Vector2(7, 10),
	]
	draw_colored_polygon(right_wing, body_color)
	draw_line(Vector2(6, -2), Vector2(18, 14), dark_color, 1.0)
	
	# Engine nozzles
	draw_circle(Vector2(-4, 19), 2.5, dark_color)
	draw_circle(Vector2(4, 19), 2.5, dark_color)
	draw_circle(Vector2(0, 20), 3.0, dark_color)
	
	# Engine glow (heat based)
	if engine_heat > 0.05:
		var glow_alpha = engine_heat * 0.7
		draw_circle(Vector2(-4, 20), 3.0 + engine_heat * 2.0, Color(engine_glow.r, engine_glow.g, engine_glow.b, glow_alpha))
		draw_circle(Vector2(4, 20), 3.0 + engine_heat * 2.0, Color(engine_glow.r, engine_glow.g, engine_glow.b, glow_alpha))
		draw_circle(Vector2(0, 21), 3.5 + engine_heat * 2.5, Color(engine_glow.r, engine_glow.g, engine_glow.b, glow_alpha * 1.2))
	
	# Cockpit canopy
	var canopy = [
		Vector2(0, -12),
		Vector2(3, -4),
		Vector2(2, 2),
		Vector2(0, 4),
		Vector2(-2, 2),
		Vector2(-3, -4),
	]
	draw_colored_polygon(canopy, Color(0.1, 0.6, 0.9, 0.85))
	draw_polyline(canopy + [canopy[0]], Color(0.6, 0.9, 1.0, 0.6), 1.0)
	
	# Navigation lights
	var blink = sin(Time.get_ticks_msec() / 200.0) > 0
	if blink:
		draw_circle(Vector2(-18, 14), 1.5, Color(1.0, 0.1, 0.1, 0.9))
	else:
		draw_circle(Vector2(18, 14), 1.5, Color(0.1, 1.0, 0.2, 0.9))
	
	# Accent stripe
	draw_line(Vector2(0, -18), Vector2(0, 14), accent_color, 1.5)
