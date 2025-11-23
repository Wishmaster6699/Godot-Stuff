# Godot 4.5 | GDScript 4.5
# System: S14 - Tool System - Surfboard
# Created: 2025-11-18
# Dependencies: S03 (Player Controller), tool_manager.gd
# Purpose: Surfboard tool for water traversal with wave physics

extends Node2D

class_name Surfboard

## Signals for surfboard events

## Emitted when surfboard is activated
signal surfboard_activated()

## Emitted when surfboard is deactivated
signal surfboard_deactivated()

## Emitted when entering water
signal entered_water()

## Emitted when exiting water
signal exited_water()

## Emitted when riding a wave
signal riding_wave()

# Tool states
enum State {
	INACTIVE,
	READY,
	SURFING,
	TRANSITIONING
}

# Configuration
var config: Dictionary = {}
var water_speed: float = 150.0
var wave_amplitude: float = 10.0
var wave_frequency: float = 2.0
var auto_activate: bool = true

# State
var current_state: State = State.INACTIVE
var is_active: bool = false
var on_water: bool = false
var is_surfing: bool = false

# Wave physics
var wave_time: float = 0.0
var wave_offset: float = 0.0
var original_y_position: float = 0.0

# Movement
var surf_velocity: Vector2 = Vector2.ZERO
var water_friction: float = 0.95

# References
var player: PlayerController = null
var tool_manager: Node = null
var water_detector: Area2D = null

# Water detection
var water_bodies_in_range: Array[Node] = []

func _ready() -> void:
	visible = false
	_setup_water_detector()

func initialize(player_ref: PlayerController, tool_config: Dictionary) -> void:
	"""Initialize the surfboard with player reference and configuration"""
	player = player_ref
	config = tool_config

	# Load config values
	water_speed = config.get("water_speed", 150.0) as float
	wave_amplitude = config.get("wave_amplitude", 10.0) as float

	# Get tool manager reference
	tool_manager = get_parent()

	print("Surfboard: Initialized (speed: %.1f, wave: %.1f)" % [water_speed, wave_amplitude])

func _setup_water_detector() -> void:
	"""Setup area for detecting water tiles/bodies"""
	water_detector = Area2D.new()
	water_detector.name = "WaterDetector"
	add_child(water_detector)

	# Create collision shape for water detection
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 16.0  # Detection radius
	collision_shape.shape = shape
	water_detector.add_child(collision_shape)

	# Set up collision layers for water detection
	water_detector.collision_layer = 0
	water_detector.collision_mask = 8  # Layer 4 for water

	# Connect signals
	water_detector.area_entered.connect(_on_water_area_entered)
	water_detector.area_exited.connect(_on_water_area_exited)
	water_detector.body_entered.connect(_on_water_body_entered)
	water_detector.body_exited.connect(_on_water_body_exited)

func _process(delta: float) -> void:
	"""Update surfboard state and visuals"""
	if not is_active:
		return

	_update_state(delta)
	_update_wave_physics(delta)

func _physics_process(delta: float) -> void:
	"""Handle surfing physics"""
	if is_surfing and player != null:
		_apply_surfing_physics(delta)

func _update_state(delta: float) -> void:
	"""Update surfboard state machine"""
	match current_state:
		State.READY:
			# Check for auto-activation on water
			if auto_activate and _is_on_water():
				_start_surfing()
		State.SURFING:
			# Check if still on water
			if not _is_on_water():
				_stop_surfing()
		State.TRANSITIONING:
			# Brief transition state
			pass

func _update_wave_physics(delta: float) -> void:
	"""Update wave bobbing physics"""
	if not is_surfing:
		return

	# Update wave time
	wave_time += delta * wave_frequency

	# Calculate wave offset (sine wave)
	wave_offset = sin(wave_time * TAU) * wave_amplitude

	# Apply wave bobbing to player position
	if player != null:
		# This creates a bobbing effect
		# The MCP agent will need to adjust this in the scene for proper visual effect
		pass

func _apply_surfing_physics(delta: float) -> void:
	"""Apply surfing movement physics"""
	if player == null:
		return

	# Get input for surfing direction
	var input_direction = Vector2.ZERO
	if has_node("/root/InputManager"):
		var input_manager = get_node("/root/InputManager")
		input_direction = input_manager.get_stick_input("left_stick")
	else:
		input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Apply surfing movement
	if input_direction.length() > 0.0:
		var target_velocity = input_direction.normalized() * water_speed
		surf_velocity = surf_velocity.lerp(target_velocity, 0.1)
	else:
		# Apply water friction
		surf_velocity *= water_friction

	# Apply velocity to player
	player.velocity = surf_velocity
	player.move_and_slide()

func _is_on_water() -> bool:
	"""Check if player is currently on water"""
	return on_water or water_bodies_in_range.size() > 0

func _start_surfing() -> void:
	"""Start surfing on water"""
	if is_surfing:
		return

	is_surfing = true
	current_state = State.SURFING
	wave_time = 0.0
	surf_velocity = player.velocity if player != null else Vector2.ZERO

	# Store original position for wave physics
	if player != null:
		original_y_position = player.global_position.y

	riding_wave.emit()
	print("Surfboard: Started surfing")

func _stop_surfing() -> void:
	"""Stop surfing"""
	if not is_surfing:
		return

	is_surfing = false
	current_state = State.READY
	surf_velocity = Vector2.ZERO

	# Restore player velocity
	if player != null:
		player.velocity = Vector2.ZERO

	print("Surfboard: Stopped surfing")

func _on_water_area_entered(area: Area2D) -> void:
	"""Called when a water area is detected"""
	if area == null or area == water_detector:
		return

	# Check if area is tagged as water
	if area.is_in_group("water"):
		water_bodies_in_range.append(area)
		_check_water_entry()
		print("Surfboard: Detected water area: %s" % area.name)

func _on_water_area_exited(area: Area2D) -> void:
	"""Called when a water area is left"""
	if area in water_bodies_in_range:
		water_bodies_in_range.erase(area)
		_check_water_exit()
		print("Surfboard: Left water area: %s" % area.name)

func _on_water_body_entered(body: Node2D) -> void:
	"""Called when a water body is detected"""
	if body == null or body == player:
		return

	# Check if body is tagged as water
	if body.is_in_group("water"):
		water_bodies_in_range.append(body)
		_check_water_entry()
		print("Surfboard: Detected water body: %s" % body.name)

func _on_water_body_exited(body: Node2D) -> void:
	"""Called when a water body is left"""
	if body in water_bodies_in_range:
		water_bodies_in_range.erase(body)
		_check_water_exit()
		print("Surfboard: Left water body: %s" % body.name)

func _check_water_entry() -> void:
	"""Check if we should enter water state"""
	if not on_water and water_bodies_in_range.size() > 0:
		on_water = true
		entered_water.emit()
		print("Surfboard: Entered water")

		# Auto-activate surfing if enabled and tool is active
		if is_active and auto_activate:
			_start_surfing()

func _check_water_exit() -> void:
	"""Check if we should exit water state"""
	if on_water and water_bodies_in_range.is_empty():
		on_water = false
		exited_water.emit()
		_stop_surfing()
		print("Surfboard: Exited water")

## Public API Methods

func activate() -> void:
	"""Called when this tool is selected"""
	is_active = true
	visible = true
	current_state = State.READY
	surfboard_activated.emit()

	# Auto-start surfing if already on water
	if _is_on_water() and auto_activate:
		_start_surfing()

	print("Surfboard: Activated")

func deactivate() -> void:
	"""Called when this tool is deselected"""
	is_active = false
	visible = false
	_stop_surfing()
	current_state = State.INACTIVE
	surfboard_deactivated.emit()
	print("Surfboard: Deactivated")

func use() -> void:
	"""Use the surfboard - toggle surfing"""
	if not is_active:
		return

	if _is_on_water():
		if is_surfing:
			_stop_surfing()
		else:
			_start_surfing()
	else:
		print("Surfboard: Not on water!")

func is_on_water_surface() -> bool:
	"""Check if currently on water"""
	return on_water

func is_currently_surfing() -> bool:
	"""Check if currently surfing"""
	return is_surfing

func get_wave_offset() -> float:
	"""Get current wave offset for visual effects"""
	return wave_offset

func get_surf_speed() -> float:
	"""Get current surfing speed"""
	return surf_velocity.length()

func set_auto_activate(enabled: bool) -> void:
	"""Enable/disable auto-activation on water"""
	auto_activate = enabled
	print("Surfboard: Auto-activate %s" % ("enabled" if enabled else "disabled"))
