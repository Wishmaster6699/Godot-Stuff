# Godot 4.5 | GDScript 4.5
# System: S15 - Vehicle System - Airship
# Created: 2025-11-18
# Dependencies: VehicleBase
# Purpose: Aerial vehicle with altitude control, ignores ground obstacles, requires landing pads

extends VehicleBase

class_name Airship

## Emitted when altitude changes
signal altitude_changed(new_altitude: float)

## Emitted when attempting to land without landing pad
signal landing_failed(reason: String)

## Emitted when successfully landed on landing pad
signal landed_on_pad(pad: Node)

# Airship-specific properties
var current_altitude: float = 100.0  # Current height (visual only, uses z_index)
var min_altitude: float = 0.0
var max_altitude: float = 500.0
var altitude_change_speed: float = 100.0

# Landing system
var can_land: bool = false
var nearby_landing_pads: Array[Node] = []
var is_airborne: bool = true

# Altitude input
var altitude_input: float = 0.0  # -1 = down, +1 = up

# Physics
var air_friction: float = 0.95  # Reduced friction (floaty movement)
var hover_stability: float = 0.8  # How stable the hover is

# Visual shadow (for altitude indication)
var shadow_node: Sprite2D = null
var base_shadow_scale: float = 1.0

func _ready() -> void:
	super._ready()
	vehicle_type = VehicleType.AIRSHIP
	_load_airship_config()
	_setup_collision_layers()
	_create_shadow()
	_set_altitude(current_altitude)
	print("Airship: Initialized at altitude %.1f" % current_altitude)

func _load_airship_config() -> void:
	"""Load airship-specific configuration"""
	if config.has("airship"):
		var airship_config = config["airship"] as Dictionary

		# Physics
		max_speed = airship_config.get("max_speed", 250.0) as float
		acceleration = airship_config.get("acceleration", 400.0) as float
		friction = airship_config.get("friction", 800.0) as float
		turn_speed = airship_config.get("turn_speed", 2.0) as float

		# Altitude
		min_altitude = airship_config.get("min_altitude", 0.0) as float
		max_altitude = airship_config.get("max_altitude", 500.0) as float
		altitude_change_speed = airship_config.get("altitude_change_speed", 100.0) as float
		current_altitude = airship_config.get("default_altitude", 100.0) as float

		# Combat
		can_attack = airship_config.get("can_attack", false) as bool

		# Cooldown
		ability_cooldown_duration = airship_config.get("ability_cooldown", 1.0) as float

		print("Airship: Config loaded - Speed: %.1f, Max Altitude: %.1f" % [max_speed, max_altitude])
	else:
		# Use defaults
		max_speed = 250.0
		acceleration = 400.0
		friction = 800.0
		can_attack = false
		print("Airship: Using default configuration")

func _setup_collision_layers() -> void:
	"""Setup collision layers to ignore ground obstacles when airborne"""
	# When airborne, should be on different layer
	# This would be configured in Tier 2 with proper collision layer setup
	pass

func _create_shadow() -> void:
	"""Create visual shadow to indicate altitude"""
	shadow_node = Sprite2D.new()
	shadow_node.name = "AltitudeShadow"
	shadow_node.modulate = Color(0, 0, 0, 0.3)  # Semi-transparent black
	shadow_node.z_index = -10  # Below everything
	add_child(shadow_node)
	print("Airship: Shadow created")

func _physics_process(delta: float) -> void:
	if mounted:
		_update_altitude_input()
		_update_altitude(delta)
		_update_shadow()
		_check_landing_pads()

	super._physics_process(delta)

func _update_altitude_input() -> void:
	"""Get altitude control input"""
	altitude_input = 0.0

	# Check for altitude control buttons
	if Input.is_action_pressed("ui_page_up") or Input.is_key_pressed(KEY_SPACE):
		altitude_input = 1.0  # Ascend
	elif Input.is_action_pressed("ui_page_down") or Input.is_key_pressed(KEY_CTRL):
		altitude_input = -1.0  # Descend

func _update_altitude(delta: float) -> void:
	"""Update current altitude based on input"""
	if altitude_input != 0.0:
		var target_altitude = current_altitude + (altitude_input * altitude_change_speed * delta)
		target_altitude = clamp(target_altitude, min_altitude, max_altitude)

		if target_altitude != current_altitude:
			_set_altitude(target_altitude)

func _set_altitude(new_altitude: float) -> void:
	"""Set altitude and update visual representation"""
	var old_altitude = current_altitude
	current_altitude = clamp(new_altitude, min_altitude, max_altitude)

	# Update z_index to simulate altitude (higher = in front)
	z_index = int(current_altitude / 50.0)

	# Check if landed
	is_airborne = current_altitude > 10.0

	if current_altitude != old_altitude:
		altitude_changed.emit(current_altitude)

func _update_shadow() -> void:
	"""Update shadow position and size based on altitude"""
	if shadow_node == null:
		return

	# Shadow gets smaller and more transparent the higher we are
	var altitude_ratio = current_altitude / max_altitude
	var shadow_scale = base_shadow_scale * (1.0 - altitude_ratio * 0.7)
	var shadow_alpha = 0.3 * (1.0 - altitude_ratio * 0.8)

	shadow_node.scale = Vector2(shadow_scale, shadow_scale)
	shadow_node.modulate = Color(0, 0, 0, shadow_alpha)

	# Shadow offset increases with altitude
	shadow_node.position = Vector2(altitude_ratio * 20.0, altitude_ratio * 30.0)

func _check_landing_pads() -> void:
	"""Check if airship is near a landing pad"""
	# This would be enhanced in Tier 2 with actual landing pad detection
	# For now, allow landing if altitude is low enough
	can_land = current_altitude <= 10.0

func _update_vehicle_physics(delta: float) -> void:
	"""Airship has floaty, smooth aerial movement"""
	if input_direction.length() > 0.0:
		# Smooth acceleration
		var target_velocity = input_direction.normalized() * max_speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		# Apply air friction (very smooth deceleration)
		velocity *= air_friction

	# Add slight hover wobble for effect (optional)
	# This could be enhanced with sine wave movement

func request_dismount() -> void:
	"""Request to dismount - requires landing pad or low altitude"""
	if not can_land:
		var reason = "Must land the airship first (lower altitude or find landing pad)"
		landing_failed.emit(reason)
		print("Airship: Cannot dismount - %s" % reason)
		return

	# Successful landing
	print("Airship: Landing successful")
	dismount()

func _execute_ability() -> void:
	"""Execute altitude adjustment ability (quick ascend)"""
	if not mounted:
		return

	print("Airship: Quick ascend!")
	_set_altitude(current_altitude + 100.0)
	ability_used.emit("quick_ascend")

func _on_mount() -> void:
	"""Airship-specific mount effects"""
	print("Airship: Player mounted - Aerial vehicle ready!")
	# Ensure airborne
	if current_altitude < 50.0:
		_set_altitude(50.0)

func _on_dismount() -> void:
	"""Airship-specific dismount effects"""
	print("Airship: Player dismounted")

## Landing Pad System

func register_landing_pad(pad: Node) -> void:
	"""Register a landing pad in range"""
	if not pad in nearby_landing_pads:
		nearby_landing_pads.append(pad)
		can_land = true
		print("Airship: Landing pad available: %s" % pad.name)

func unregister_landing_pad(pad: Node) -> void:
	"""Remove landing pad from range"""
	if pad in nearby_landing_pads:
		nearby_landing_pads.erase(pad)
		can_land = nearby_landing_pads.size() > 0 or current_altitude <= 10.0
		print("Airship: Landing pad out of range: %s" % pad.name)

## Public API

func get_current_altitude() -> float:
	"""Get current altitude"""
	return current_altitude

func get_max_altitude() -> float:
	"""Get maximum altitude"""
	return max_altitude

func is_landed() -> bool:
	"""Check if airship is currently landed"""
	return not is_airborne

func can_dismount() -> bool:
	"""Check if player can dismount"""
	return can_land

func get_nearby_landing_pads() -> Array[Node]:
	"""Get all nearby landing pads"""
	return nearby_landing_pads.duplicate()
