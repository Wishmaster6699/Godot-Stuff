# Godot 4.5 | GDScript 4.5
# System: S14 - Tool System - Grapple Hook
# Created: 2025-11-18
# Dependencies: S03 (Player Controller), tool_manager.gd
# Purpose: Grapple hook tool with raycast detection and swing physics

extends Node2D

class_name GrappleHook

## Signals for grapple events

## Emitted when grapple attaches to a point
signal grapple_attached(attach_point: Vector2)

## Emitted when grapple is released
signal grapple_released()

## Emitted when grapple swing starts
signal grapple_swinging()

# Tool states
enum State {
	INACTIVE,
	AIMING,
	SHOOTING,
	ATTACHED,
	SWINGING,
	RETRACTING
}

# Configuration
var config: Dictionary = {}
var max_range: float = 200.0
var swing_force: float = 500.0
var cooldown_duration: float = 0.5
var rope_pull_speed: float = 300.0
var gravity_during_swing: float = 400.0

# State
var current_state: State = State.INACTIVE
var is_active: bool = false

# Grapple point tracking
var grapple_point: Vector2 = Vector2.ZERO
var is_grappled: bool = false
var rope_length: float = 0.0

# References
var player: PlayerController = null
var tool_manager: Node = null
var raycast: RayCast2D = null
var rope_line: Line2D = null

# Physics
var swing_velocity: Vector2 = Vector2.ZERO
var pendulum_angle: float = 0.0

func _ready() -> void:
	visible = false
	_setup_raycast()
	_setup_rope_visual()

func initialize(player_ref: PlayerController, tool_config: Dictionary) -> void:
	"""Initialize the grapple hook with player reference and configuration"""
	player = player_ref
	config = tool_config

	# Load config values
	max_range = config.get("max_range", 200.0) as float
	swing_force = config.get("swing_force", 500.0) as float
	cooldown_duration = config.get("cooldown_s", 0.5) as float

	# Get tool manager reference
	tool_manager = get_parent()

	print("GrappleHook: Initialized (range: %.1f, force: %.1f)" % [max_range, swing_force])

func _setup_raycast() -> void:
	"""Setup raycast for detecting grapple points"""
	raycast = RayCast2D.new()
	raycast.name = "GrappleRaycast"
	raycast.enabled = false
	raycast.hit_from_inside = false
	raycast.collide_with_areas = true
	raycast.collide_with_bodies = true
	raycast.collision_mask = 1  # Layer 1 for grapple points
	add_child(raycast)

func _setup_rope_visual() -> void:
	"""Setup Line2D for visualizing the rope"""
	rope_line = Line2D.new()
	rope_line.name = "RopeLine"
	rope_line.width = 2.0
	rope_line.default_color = Color(0.8, 0.8, 0.2, 1.0)  # Yellow rope
	rope_line.visible = false
	add_child(rope_line)

func _process(delta: float) -> void:
	"""Update grapple state and visuals"""
	if not is_active:
		return

	_update_state(delta)
	_update_rope_visual()

func _physics_process(delta: float) -> void:
	"""Handle swing physics"""
	if current_state == State.SWINGING:
		_apply_swing_physics(delta)

func _update_state(delta: float) -> void:
	"""Update grapple state machine"""
	match current_state:
		State.AIMING:
			_update_aiming()
		State.SHOOTING:
			_update_shooting(delta)
		State.ATTACHED:
			_update_attached()
		State.SWINGING:
			_update_swinging(delta)
		State.RETRACTING:
			_update_retracting(delta)

func _update_aiming() -> void:
	"""Update aiming direction"""
	# Could add visual aiming indicator here
	pass

func _update_shooting(delta: float) -> void:
	"""Update shooting state - raycast to find grapple point"""
	var aim_direction = _get_aim_direction()
	raycast.target_position = aim_direction * max_range
	raycast.force_raycast_update()

	if raycast.is_colliding():
		# Found a grapple point
		grapple_point = raycast.get_collision_point()
		rope_length = player.global_position.distance_to(grapple_point)
		is_grappled = true
		current_state = State.ATTACHED
		grapple_attached.emit(grapple_point)
		print("GrappleHook: Attached to point at %s" % str(grapple_point))
	else:
		# No grapple point found, return to inactive
		_release_grapple()
		print("GrappleHook: No grapple point in range")

func _update_attached() -> void:
	"""Update attached state - waiting for player to start swinging"""
	# Automatically start swinging when attached
	if is_grappled:
		current_state = State.SWINGING
		grapple_swinging.emit()

func _update_swinging(delta: float) -> void:
	"""Update swinging state"""
	# Check if player released the grapple (jump button or tool button)
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump"):
		_release_grapple()
		return

	# Check if rope is too short (player pulled too close)
	var current_distance = player.global_position.distance_to(grapple_point)
	if current_distance < 20.0:
		_release_grapple()
		return

	# Update rope length (could allow shortening/lengthening)
	rope_length = current_distance

func _update_retracting(delta: float) -> void:
	"""Update retracting state"""
	# Return to inactive after a brief delay
	current_state = State.INACTIVE
	is_grappled = false

func _apply_swing_physics(delta: float) -> void:
	"""Apply pendulum physics to the player during swing"""
	if not is_grappled or player == null:
		return

	# Calculate pendulum physics
	var to_grapple = grapple_point - player.global_position
	var distance = to_grapple.length()

	# Keep player at rope length (constraint)
	if distance > rope_length:
		var direction = to_grapple.normalized()
		var offset = distance - rope_length
		player.global_position += direction * offset

	# Apply swing force (perpendicular to rope)
	var rope_direction = to_grapple.normalized()
	var perpendicular = Vector2(-rope_direction.y, rope_direction.x)

	# Get input for swing control
	var input_direction = Vector2.ZERO
	if has_node("/root/InputManager"):
		var input_manager = get_node("/root/InputManager")
		input_direction = input_manager.get_stick_input("left_stick")
	else:
		input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Apply swing force based on input
	var swing_input = input_direction.dot(perpendicular)
	var force = perpendicular * swing_input * swing_force * delta

	# Apply gravity (downward pull)
	var gravity = Vector2.DOWN * gravity_during_swing * delta

	# Update player velocity
	var current_velocity = player.velocity + force + gravity

	# Constrain velocity to be tangent to the rope (no movement toward/away from grapple point)
	var radial_velocity = rope_direction * current_velocity.dot(rope_direction)
	var tangential_velocity = current_velocity - radial_velocity

	player.velocity = tangential_velocity
	player.move_and_slide()

func _update_rope_visual() -> void:
	"""Update the visual representation of the rope"""
	if is_grappled and player != null:
		rope_line.visible = true
		rope_line.clear_points()
		rope_line.add_point(Vector2.ZERO)  # Start at tool (player position)
		var local_grapple_point = to_local(grapple_point)
		rope_line.add_point(local_grapple_point)  # End at grapple point
	else:
		rope_line.visible = false

func _get_aim_direction() -> Vector2:
	"""Get the direction the player is aiming"""
	# Use player's facing direction or input direction
	var aim_dir = Vector2.ZERO

	if has_node("/root/InputManager"):
		var input_manager = get_node("/root/InputManager")
		aim_dir = input_manager.get_stick_input("right_stick")
		if aim_dir.length() < 0.1:
			aim_dir = input_manager.get_stick_input("left_stick")

	if aim_dir.length() < 0.1:
		# Use player facing direction as fallback
		if player != null:
			aim_dir = player.get_facing_direction()

	if aim_dir.length() < 0.1:
		# Default to right if no input
		aim_dir = Vector2.RIGHT

	return aim_dir.normalized()

func _release_grapple() -> void:
	"""Release the grapple hook"""
	if is_grappled:
		is_grappled = false
		grapple_released.emit()
		print("GrappleHook: Released")

	current_state = State.RETRACTING
	rope_line.visible = false

## Public API Methods

func activate() -> void:
	"""Called when this tool is selected"""
	is_active = true
	visible = true
	current_state = State.INACTIVE
	print("GrappleHook: Activated")

func deactivate() -> void:
	"""Called when this tool is deselected"""
	is_active = false
	visible = false
	_release_grapple()
	current_state = State.INACTIVE
	print("GrappleHook: Deactivated")

func use() -> void:
	"""Use the grapple hook - shoot to attach"""
	if not is_active:
		return

	if current_state == State.SWINGING or current_state == State.ATTACHED:
		# Already grappling, release it
		_release_grapple()
		return

	if current_state != State.INACTIVE:
		print("GrappleHook: Cannot use while in state %s" % current_state)
		return

	# Start shooting
	current_state = State.SHOOTING
	raycast.enabled = true
	print("GrappleHook: Shooting grapple...")

	# Start cooldown after use
	if tool_manager != null and tool_manager.has_method("start_tool_cooldown"):
		tool_manager.call("start_tool_cooldown", "grapple_hook", cooldown_duration)

func is_grappling() -> bool:
	"""Check if currently grappling"""
	return is_grappled

func get_grapple_point() -> Vector2:
	"""Get the current grapple point"""
	return grapple_point

func get_rope_length() -> float:
	"""Get the current rope length"""
	return rope_length
