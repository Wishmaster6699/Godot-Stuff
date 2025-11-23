# Godot 4.5 | GDScript 4.5
# System: S18 - Polyrhythmic Environment
# Created: 2025-11-18
# Dependencies: S01 Conductor, PolyrhythmController
#
# A platform that rises and falls on polyrhythmic beats.
# Players must time their jumps to land on the platform when it's raised.
# Integrates with puzzle mechanics (S17 optional).

extends AnimatableBody2D
class_name TimingPlatform

## Emitted when platform starts rising
signal platform_rising()

## Emitted when platform reaches raised position
signal platform_raised()

## Emitted when platform starts lowering
signal platform_lowering()

## Emitted when platform reaches lowered position
signal platform_lowered()

## Emitted when player lands on raised platform
signal player_landed_on_platform()

## Emitted when player misses platform timing
signal player_missed_platform()

# Polyrhythm pattern to follow (e.g., "4:3", "5:4", "7:4")
@export var rhythm_pattern: String = "4:3"

# Which polyrhythm track to follow ("numerator" or "denominator")
@export_enum("numerator", "denominator") var rhythm_track: String = "numerator"

# Rise/lower behavior
@export_enum("rise_on_beat", "lower_on_beat", "toggle_on_beat") var behavior: String = "toggle_on_beat"

# How far the platform rises (in pixels)
@export var rise_height: float = 100.0

# Duration of rise/lower animation (in seconds)
@export_range(0.1, 2.0) var move_duration: float = 0.5

# Platform easing
@export_enum("ease_in", "ease_out", "ease_in_out", "linear") var platform_easing: String = "ease_in_out"

# Stay raised duration (0 = instant lower, -1 = stay until next beat)
@export var raised_duration: float = 1.0

# Enable collision only when raised
@export var collision_only_when_raised: bool = true

# Visual feedback color when raised
@export var raised_color: Color = Color(1.0, 1.0, 1.0, 1.0)

# Visual feedback color when lowered
@export var lowered_color: Color = Color(0.6, 0.6, 0.6, 1.0)

# Auto-start on ready
@export var auto_start: bool = true

# Reference to PolyrhythmController
var polyrhythm_controller: PolyrhythmController = null

# Platform sprite (for visual feedback)
var platform_sprite: Sprite2D = null

# Collision shape (for enabling/disabling collision)
var collision_shape: CollisionShape2D = null

# Movement tween
var movement_tween: Tween = null

# Timer for raised duration
var raised_timer: Timer = null

# Original position (lowered state)
var original_position: Vector2 = Vector2.ZERO

# Raised position
var raised_position: Vector2 = Vector2.ZERO

# Current state
var is_raised: bool = false
var is_moving: bool = false
var pattern_active: bool = false

# Player tracking (for landing detection)
var players_on_platform: Array = []


## Initialize the timing platform
func _ready() -> void:
	_setup_components()
	_store_original_position()
	_setup_raised_timer()
	_connect_to_polyrhythm_controller()

	# Set initial state
	_set_lowered_state()

	if auto_start:
		start()


## Setup platform components (sprite, collision)
func _setup_components() -> void:
	# Find sprite child
	for child in get_children():
		if child is Sprite2D:
			platform_sprite = child
		if child is CollisionShape2D:
			collision_shape = child

	if platform_sprite == null:
		push_warning("TimingPlatform: No Sprite2D found. Add one for visual feedback.")

	if collision_shape == null:
		push_warning("TimingPlatform: No CollisionShape2D found. Platform won't have collision.")


## Store original (lowered) position
func _store_original_position() -> void:
	original_position = position
	raised_position = original_position - Vector2(0, rise_height)  # Negative Y is up


## Setup timer for raised duration
func _setup_raised_timer() -> void:
	raised_timer = Timer.new()
	raised_timer.name = "RaisedTimer"
	raised_timer.one_shot = true
	raised_timer.timeout.connect(_on_raised_timer_timeout)
	add_child(raised_timer)


## Connect to PolyrhythmController singleton
func _connect_to_polyrhythm_controller() -> void:
	# Try to get PolyrhythmController from scene tree
	if has_node("/root/PolyrhythmController"):
		polyrhythm_controller = get_node("/root/PolyrhythmController")
	else:
		# Search for it in the scene tree
		polyrhythm_controller = _find_polyrhythm_controller_in_tree(get_tree().root)

	if polyrhythm_controller == null:
		push_error("TimingPlatform: PolyrhythmController not found in scene tree")
		return

	# Connect to appropriate signal based on rhythm_track
	if rhythm_track == "numerator":
		if polyrhythm_controller.has_signal("polyrhythm_numerator_beat"):
			polyrhythm_controller.polyrhythm_numerator_beat.connect(_on_polyrhythm_beat)
	else:  # denominator
		if polyrhythm_controller.has_signal("polyrhythm_denominator_beat"):
			polyrhythm_controller.polyrhythm_denominator_beat.connect(_on_polyrhythm_beat)


## Recursively find PolyrhythmController in scene tree
## @param node: Starting node for search
## @return Node: PolyrhythmController instance or null
func _find_polyrhythm_controller_in_tree(node: Node) -> Node:
	if node is PolyrhythmController:
		return node

	for child in node.get_children():
		var result: Node = _find_polyrhythm_controller_in_tree(child)
		if result != null:
			return result

	return null


## Start the timing platform (activate pattern)
func start() -> void:
	if pattern_active:
		return

	if polyrhythm_controller == null:
		push_error("TimingPlatform: Cannot start - PolyrhythmController not connected")
		return

	# Activate the rhythm pattern
	polyrhythm_controller.activate_pattern(rhythm_pattern)
	pattern_active = true


## Stop the timing platform
func stop() -> void:
	if not pattern_active:
		return

	if polyrhythm_controller != null:
		polyrhythm_controller.deactivate_pattern(rhythm_pattern)

	pattern_active = false

	# Stop any active movement
	if movement_tween != null:
		movement_tween.kill()
		movement_tween = null

	# Stop raised timer
	if raised_timer != null and raised_timer.time_left > 0:
		raised_timer.stop()

	is_moving = false

	# Lower platform
	_set_lowered_state()


## Handle polyrhythm beat signal
## @param pattern_name: Pattern that triggered the beat
## @param beat_index: Index of the beat in the sequence
func _on_polyrhythm_beat(pattern_name: String, beat_index: int) -> void:
	# Only respond to our pattern
	if pattern_name != rhythm_pattern:
		return

	# Trigger behavior based on mode
	match behavior:
		"rise_on_beat":
			if not is_raised and not is_moving:
				_rise()
		"lower_on_beat":
			if is_raised and not is_moving:
				_lower()
		"toggle_on_beat":
			if not is_moving:
				if is_raised:
					_lower()
				else:
					_rise()


## Raise the platform
func _rise() -> void:
	if is_moving:
		return

	is_moving = true
	platform_rising.emit()

	# Cancel any previous tween
	if movement_tween != null:
		movement_tween.kill()

	# Create rise tween
	movement_tween = create_tween()

	# Determine easing
	var easing_type: Tween.EaseType = Tween.EASE_IN_OUT
	var trans_type: Tween.TransitionType = Tween.TRANS_QUAD

	match platform_easing:
		"ease_in":
			easing_type = Tween.EASE_IN
		"ease_out":
			easing_type = Tween.EASE_OUT
		"ease_in_out":
			easing_type = Tween.EASE_IN_OUT
		"linear":
			easing_type = Tween.EASE_IN
			trans_type = Tween.TRANS_LINEAR

	# Animate to raised position
	movement_tween.tween_property(self, "position", raised_position, move_duration).set_ease(easing_type).set_trans(trans_type)

	# Handle completion
	movement_tween.finished.connect(_on_rise_finished)


## Handle rise completion
func _on_rise_finished() -> void:
	is_moving = false
	is_raised = true
	_set_raised_state()
	platform_raised.emit()

	# Start raised timer if duration > 0
	if raised_duration > 0:
		raised_timer.start(raised_duration)
	# If raised_duration is -1, stay raised until next beat


## Lower the platform
func _lower() -> void:
	if is_moving:
		return

	is_moving = true
	platform_lowering.emit()

	# Stop raised timer if running
	if raised_timer != null and raised_timer.time_left > 0:
		raised_timer.stop()

	# Cancel any previous tween
	if movement_tween != null:
		movement_tween.kill()

	# Create lower tween
	movement_tween = create_tween()

	# Determine easing
	var easing_type: Tween.EaseType = Tween.EASE_IN_OUT
	var trans_type: Tween.TransitionType = Tween.TRANS_QUAD

	match platform_easing:
		"ease_in":
			easing_type = Tween.EASE_IN
		"ease_out":
			easing_type = Tween.EASE_OUT
		"ease_in_out":
			easing_type = Tween.EASE_IN_OUT
		"linear":
			easing_type = Tween.EASE_IN
			trans_type = Tween.TRANS_LINEAR

	# Animate to lowered position
	movement_tween.tween_property(self, "position", original_position, move_duration).set_ease(easing_type).set_trans(trans_type)

	# Handle completion
	movement_tween.finished.connect(_on_lower_finished)


## Handle lower completion
func _on_lower_finished() -> void:
	is_moving = false
	is_raised = false
	_set_lowered_state()
	platform_lowered.emit()


## Handle raised timer timeout (auto-lower after duration)
func _on_raised_timer_timeout() -> void:
	if is_raised and not is_moving:
		_lower()


## Set visual/collision state for raised platform
func _set_raised_state() -> void:
	# Update sprite color
	if platform_sprite != null:
		platform_sprite.modulate = raised_color

	# Enable collision
	if collision_shape != null and collision_only_when_raised:
		collision_shape.disabled = false


## Set visual/collision state for lowered platform
func _set_lowered_state() -> void:
	# Update sprite color
	if platform_sprite != null:
		platform_sprite.modulate = lowered_color

	# Disable collision
	if collision_shape != null and collision_only_when_raised:
		collision_shape.disabled = true


## Check if platform is currently raised
## @return bool: True if platform is in raised position
func is_platform_raised() -> bool:
	return is_raised


## Check if platform is currently moving
## @return bool: True if platform is animating
func is_platform_moving() -> bool:
	return is_moving


## Get current platform height (0.0 = lowered, 1.0 = fully raised)
## @return float: Platform height ratio
func get_platform_height_ratio() -> float:
	var current_offset: float = original_position.y - position.y
	var height_ratio: float = current_offset / rise_height
	return clamp(height_ratio, 0.0, 1.0)


## Set rhythm pattern at runtime
## @param new_pattern: New pattern name (e.g., "5:4")
func set_rhythm_pattern(new_pattern: String) -> void:
	var was_active: bool = pattern_active

	if was_active:
		stop()

	rhythm_pattern = new_pattern

	if was_active:
		start()


## Manually raise the platform (for testing/debugging)
func manual_rise() -> void:
	if not is_raised and not is_moving:
		_rise()


## Manually lower the platform (for testing/debugging)
func manual_lower() -> void:
	if is_raised and not is_moving:
		_lower()


## Clean up on exit
func _exit_tree() -> void:
	if movement_tween != null:
		movement_tween.kill()
		movement_tween = null
