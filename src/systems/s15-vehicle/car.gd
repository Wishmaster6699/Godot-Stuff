# Godot 4.5 | GDScript 4.5
# System: S15 - Vehicle System - Car
# Created: 2025-11-18
# Dependencies: VehicleBase
# Purpose: Fast racing car with drifting mechanics and nitro boost ability

extends VehicleBase

class_name Car

## Emitted when drift starts
signal drift_started()

## Emitted when drift ends
signal drift_ended()

## Emitted when nitro boost activates
signal nitro_activated()

## Emitted when nitro boost ends
signal nitro_ended()

# Car-specific properties
var drift_coefficient: float = 0.8  # How much lateral velocity to preserve (0.0 = no drift, 1.0 = full drift)
var drift_threshold: float = 0.3  # Minimum turn input to trigger drift
var is_drifting: bool = false

# Nitro boost
var nitro_speed_multiplier: float = 1.5
var nitro_duration: float = 2.0
var nitro_active: bool = false
var nitro_timer: float = 0.0
var nitro_stamina_cost: float = 30.0

# Advanced physics
var lateral_friction: float = 0.9  # How quickly to reduce sideways velocity when not drifting
var drift_lateral_friction: float = 0.3  # Reduced friction during drift
var steering_angle: float = 0.0
var max_steering_angle: float = 30.0  # degrees

func _ready() -> void:
	super._ready()
	vehicle_type = VehicleType.CAR
	_load_car_config()
	print("Car: Initialized")

func _load_car_config() -> void:
	"""Load car-specific configuration"""
	if config.has("car"):
		var car_config = config["car"] as Dictionary

		# Physics
		max_speed = car_config.get("max_speed", 400.0) as float
		acceleration = car_config.get("acceleration", 800.0) as float
		friction = car_config.get("friction", 1200.0) as float
		turn_speed = car_config.get("turn_speed", 3.0) as float

		# Drifting
		drift_coefficient = car_config.get("drift_coefficient", 0.8) as float
		drift_threshold = car_config.get("drift_threshold", 0.3) as float
		lateral_friction = car_config.get("lateral_friction", 0.9) as float

		# Nitro
		nitro_speed_multiplier = car_config.get("nitro_speed_multiplier", 1.5) as float
		nitro_duration = car_config.get("nitro_duration_s", 2.0) as float
		nitro_stamina_cost = car_config.get("nitro_stamina_cost", 30.0) as float
		ability_cooldown_duration = car_config.get("nitro_cooldown", 5.0) as float

		# Combat
		can_attack = car_config.get("can_attack", false) as bool

		print("Car: Config loaded - Speed: %.1f, Drift: %.2f" % [max_speed, drift_coefficient])
	else:
		# Use defaults
		max_speed = 400.0
		acceleration = 800.0
		friction = 1200.0
		drift_coefficient = 0.8
		can_attack = false
		print("Car: Using default configuration")

func _physics_process(delta: float) -> void:
	# Update nitro timer
	if nitro_active:
		nitro_timer -= delta
		if nitro_timer <= 0.0:
			_end_nitro()

	super._physics_process(delta)

func _update_vehicle_physics(delta: float) -> void:
	"""Car has fast arcade physics with drifting"""
	var speed_multiplier = nitro_speed_multiplier if nitro_active else 1.0
	var current_max_speed = max_speed * speed_multiplier

	if input_direction.length() > 0.0:
		# Get forward/backward input
		var forward_input = input_direction.y  # Negative = forward in typical setup
		var turn_input = input_direction.x

		# Check if drifting
		var should_drift = abs(turn_input) > drift_threshold and velocity.length() > max_speed * 0.5

		if should_drift and not is_drifting:
			_start_drift()
		elif not should_drift and is_drifting:
			_end_drift()

		# Calculate target velocity based on current facing direction
		var forward_direction = Vector2.RIGHT.rotated(rotation)
		var target_velocity = forward_direction * (-forward_input) * current_max_speed

		# Accelerate
		velocity = velocity.move_toward(target_velocity, acceleration * delta)

		# Apply steering (affects rotation)
		steering_angle = turn_input * max_steering_angle
		rotation += deg_to_rad(steering_angle) * delta * (velocity.length() / max_speed)

		# Apply lateral friction (drifting mechanic)
		_apply_lateral_friction(delta)
	else:
		# No input - apply friction
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

		# End drift if stopped
		if is_drifting:
			_end_drift()

func _apply_lateral_friction(delta: float) -> void:
	"""Reduce sideways velocity to simulate tire grip"""
	# Get forward and lateral components
	var forward_direction = Vector2.RIGHT.rotated(rotation)
	var lateral_direction = Vector2.UP.rotated(rotation)

	var forward_velocity = forward_direction * velocity.dot(forward_direction)
	var lateral_velocity = lateral_direction * velocity.dot(lateral_direction)

	# Apply different friction based on drift state
	var friction_amount = drift_lateral_friction if is_drifting else lateral_friction

	# Reduce lateral velocity
	lateral_velocity = lateral_velocity.move_toward(Vector2.ZERO, friction_amount * 1000.0 * delta)

	# Reconstruct velocity
	velocity = forward_velocity + lateral_velocity

func _start_drift() -> void:
	"""Start drifting"""
	if is_drifting:
		return

	is_drifting = true
	drift_started.emit()
	print("Car: Drift started!")

func _end_drift() -> void:
	"""End drifting"""
	if not is_drifting:
		return

	is_drifting = false
	drift_ended.emit()
	print("Car: Drift ended")

func _execute_ability() -> void:
	"""Execute nitro boost ability"""
	if not mounted:
		return

	# Check if player has enough stamina (if stamina system exists)
	if mounted_player != null and mounted_player.has_method("get_stamina"):
		var stamina = mounted_player.call("get_stamina") as float
		if stamina < nitro_stamina_cost:
			print("Car: Not enough stamina for nitro boost")
			return

		# Consume stamina
		if mounted_player.has_method("consume_stamina"):
			mounted_player.call("consume_stamina", nitro_stamina_cost)

	_activate_nitro()

func _activate_nitro() -> void:
	"""Activate nitro boost"""
	print("Car: NITRO BOOST!")
	nitro_active = true
	nitro_timer = nitro_duration

	ability_used.emit("nitro_boost")
	nitro_activated.emit()

func _end_nitro() -> void:
	"""End nitro boost"""
	nitro_active = false
	nitro_timer = 0.0
	nitro_ended.emit()
	print("Car: Nitro boost ended")

func _on_mount() -> void:
	"""Car-specific mount effects"""
	print("Car: Player mounted - High speed vehicle ready!")

func _on_dismount() -> void:
	"""Car-specific dismount effects"""
	# End any active effects
	if nitro_active:
		_end_nitro()
	if is_drifting:
		_end_drift()

	print("Car: Player dismounted")

## Public API

func get_drift_coefficient() -> float:
	"""Get current drift coefficient"""
	return drift_coefficient

func is_currently_drifting() -> bool:
	"""Check if currently drifting"""
	return is_drifting

func is_nitro_active() -> bool:
	"""Check if nitro boost is active"""
	return nitro_active

func get_nitro_remaining_time() -> float:
	"""Get remaining nitro time"""
	return nitro_timer

func get_nitro_stamina_cost() -> float:
	"""Get stamina cost for nitro"""
	return nitro_stamina_cost
