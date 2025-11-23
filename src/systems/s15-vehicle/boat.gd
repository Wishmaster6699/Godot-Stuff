# Godot 4.5 | GDScript 4.5
# System: S15 - Vehicle System - Boat
# Created: 2025-11-18
# Dependencies: VehicleBase
# Purpose: Water-only vehicle with wave physics, bobbing/tilting, and fishing ability

extends VehicleBase

class_name Boat

## Emitted when wave motion updates
signal wave_motion_updated(bob_offset: float, tilt_angle: float)

## Emitted when fishing starts
signal fishing_started()

## Emitted when fishing ends
signal fishing_ended(caught_fish: bool)

## Emitted when trying to enter non-water area
signal water_boundary_hit()

# Boat-specific properties
var is_on_water: bool = true
var can_move: bool = true

# Wave physics
var wave_amplitude: float = 10.0  # Height of wave bob
var wave_frequency: float = 1.0  # Speed of wave oscillation
var wave_phase: float = 0.0  # Current position in wave cycle
var current_bob_offset: float = 0.0
var current_tilt_angle: float = 0.0

# Tilt based on movement
var max_tilt_angle: float = 15.0  # degrees
var tilt_speed: float = 2.0

# Fishing system
var is_fishing: bool = false
var fishing_duration: float = 3.0
var fishing_timer: float = 0.0
var fishing_success_chance: float = 0.7

# Water detection (would be enhanced in Tier 2 with actual water areas)
var water_check_area: Area2D = null

func _ready() -> void:
	super._ready()
	vehicle_type = VehicleType.BOAT
	_load_boat_config()
	_create_water_check_area()
	print("Boat: Initialized")

func _load_boat_config() -> void:
	"""Load boat-specific configuration"""
	if config.has("boat"):
		var boat_config = config["boat"] as Dictionary

		# Physics
		max_speed = boat_config.get("max_speed", 200.0) as float
		acceleration = boat_config.get("acceleration", 400.0) as float
		friction = boat_config.get("friction", 900.0) as float
		turn_speed = boat_config.get("turn_speed", 2.5) as float

		# Wave physics
		wave_amplitude = boat_config.get("wave_amplitude", 10.0) as float
		wave_frequency = boat_config.get("wave_frequency", 1.0) as float
		max_tilt_angle = boat_config.get("max_tilt_angle", 15.0) as float
		tilt_speed = boat_config.get("tilt_speed", 2.0) as float

		# Fishing
		fishing_duration = boat_config.get("fishing_duration", 3.0) as float
		fishing_success_chance = boat_config.get("fishing_success_chance", 0.7) as float
		ability_cooldown_duration = boat_config.get("fishing_cooldown", 5.0) as float

		# Combat
		can_attack = boat_config.get("can_attack", false) as bool

		print("Boat: Config loaded - Speed: %.1f, Wave amplitude: %.1f" % [max_speed, wave_amplitude])
	else:
		# Use defaults
		max_speed = 200.0
		acceleration = 400.0
		friction = 900.0
		can_attack = false
		print("Boat: Using default configuration")

func _create_water_check_area() -> void:
	"""Create area to detect water/land boundaries"""
	water_check_area = Area2D.new()
	water_check_area.name = "WaterCheckArea"

	var shape = CircleShape2D.new()
	shape.radius = 32.0

	var collision = CollisionShape2D.new()
	collision.shape = shape
	collision.name = "WaterCheckCollision"

	water_check_area.add_child(collision)
	add_child(water_check_area)

	# Connect signals for water area detection
	water_check_area.area_entered.connect(_on_water_area_entered)
	water_check_area.area_exited.connect(_on_water_area_exited)

	print("Boat: Water detection area created")

func _physics_process(delta: float) -> void:
	if mounted:
		_update_wave_physics(delta)
		_update_tilt_physics(delta)
		_update_fishing(delta)

	super._physics_process(delta)

func _update_wave_physics(delta: float) -> void:
	"""Update wave bobbing motion"""
	if not is_on_water:
		current_bob_offset = 0.0
		return

	# Update wave phase
	wave_phase += wave_frequency * delta

	# Calculate sine wave for bobbing
	current_bob_offset = sin(wave_phase * TAU) * wave_amplitude

	# Apply visual offset (y-position adjustment)
	# This would be applied to a sprite or visual node in Tier 2
	# For now, just track the value

	wave_motion_updated.emit(current_bob_offset, current_tilt_angle)

func _update_tilt_physics(delta: float) -> void:
	"""Update tilt based on movement direction"""
	if not is_on_water:
		current_tilt_angle = 0.0
		return

	# Calculate target tilt based on turning
	var turn_factor = input_direction.x if mounted else 0.0
	var target_tilt = turn_factor * max_tilt_angle

	# Smoothly interpolate to target tilt
	current_tilt_angle = lerp(current_tilt_angle, target_tilt, tilt_speed * delta)

	# Apply tilt to sprite rotation (in addition to facing rotation)
	# This would be applied to sprite in Tier 2
	# rotation.z = deg_to_rad(current_tilt_angle)  # For 3D
	# For 2D, we'd rotate the sprite node separately

func _update_fishing(delta: float) -> void:
	"""Update fishing timer"""
	if is_fishing:
		fishing_timer -= delta
		if fishing_timer <= 0.0:
			_end_fishing()

func _update_vehicle_physics(delta: float) -> void:
	"""Boat has momentum-based water movement"""
	# Can't move if not on water
	if not is_on_water:
		velocity = velocity.move_toward(Vector2.ZERO, friction * 2.0 * delta)
		return

	# Can't move while fishing
	if is_fishing:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
		return

	if input_direction.length() > 0.0:
		# Water movement - slightly floaty
		var target_velocity = input_direction.normalized() * max_speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		# Water friction (medium resistance)
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func _execute_ability() -> void:
	"""Execute fishing ability"""
	if not mounted:
		return

	if is_fishing:
		print("Boat: Already fishing!")
		return

	if not is_on_water:
		print("Boat: Must be on water to fish!")
		return

	# Stop movement
	velocity = Vector2.ZERO

	# Start fishing
	_start_fishing()

func _start_fishing() -> void:
	"""Start fishing minigame/timer"""
	is_fishing = true
	fishing_timer = fishing_duration

	fishing_started.emit()
	ability_used.emit("fishing")
	print("Boat: Fishing started (%.1fs)..." % fishing_duration)

func _end_fishing() -> void:
	"""End fishing and determine success"""
	is_fishing = false
	fishing_timer = 0.0

	# Random chance to catch fish
	var caught_fish = randf() < fishing_success_chance

	fishing_ended.emit(caught_fish)

	if caught_fish:
		print("Boat: Caught a fish!")
		# Could add fish to inventory here
		if mounted_player != null and mounted_player.has_method("add_item"):
			mounted_player.call("add_item", "fish", 1)
	else:
		print("Boat: The fish got away...")

## Water Detection

func _on_water_area_entered(area: Area2D) -> void:
	"""Entered a water area"""
	# Check if area is tagged as water
	if area.is_in_group("water"):
		is_on_water = true
		print("Boat: Entered water area")

func _on_water_area_exited(area: Area2D) -> void:
	"""Exited a water area"""
	if area.is_in_group("water"):
		is_on_water = false
		water_boundary_hit.emit()
		print("Boat: Exited water area - cannot move on land!")

func _on_mount() -> void:
	"""Boat-specific mount effects"""
	print("Boat: Player mounted - Water vehicle ready!")

	# Check if currently on water
	if not is_on_water:
		push_warning("Boat: Mounted on land - limited movement!")

func _on_dismount() -> void:
	"""Boat-specific dismount effects"""
	# End fishing if active
	if is_fishing:
		is_fishing = false
		fishing_timer = 0.0
		fishing_ended.emit(false)

	print("Boat: Player dismounted")

func request_dismount() -> void:
	"""Request to dismount - check if safe location"""
	if is_fishing:
		print("Boat: Cannot dismount while fishing!")
		return

	# Could check for nearby shore/dock
	dismount()

## Public API

func get_wave_bob_offset() -> float:
	"""Get current wave bob offset"""
	return current_bob_offset

func get_tilt_angle() -> float:
	"""Get current tilt angle"""
	return current_tilt_angle

func is_currently_fishing() -> bool:
	"""Check if currently fishing"""
	return is_fishing

func get_fishing_time_remaining() -> float:
	"""Get remaining fishing time"""
	return fishing_timer

func is_in_water() -> bool:
	"""Check if boat is in water"""
	return is_on_water

func get_fishing_success_chance() -> float:
	"""Get chance to catch fish"""
	return fishing_success_chance
