# Godot 4.5 | GDScript 4.5
# System: S18 - Polyrhythmic Environment
# Created: 2025-11-18
# Dependencies: S01 Conductor, PolyrhythmController
#
# Machinery that animates (rotates or moves) on polyrhythmic beats.
# Supports rotation, linear movement, and custom animations.

extends Node2D
class_name PolyrhythmMachinery

## Emitted when machinery animation starts
signal animation_started()

## Emitted when machinery animation completes
signal animation_completed()

# Animation type
@export_enum("rotate", "move_horizontal", "move_vertical", "scale_pulse") var animation_type: String = "rotate"

# Polyrhythm pattern to follow (e.g., "4:3", "5:4", "7:4")
@export var rhythm_pattern: String = "5:4"

# Which polyrhythm track to follow ("numerator" or "denominator")
@export_enum("numerator", "denominator") var rhythm_track: String = "numerator"

# Rotation settings (for "rotate" animation)
@export_range(-360.0, 360.0) var rotation_angle: float = 90.0

# Movement settings (for "move" animations)
@export var move_distance: float = 32.0

# Scale settings (for "scale_pulse" animation)
@export_range(0.5, 2.0) var scale_min: float = 1.0
@export_range(0.5, 2.0) var scale_max: float = 1.2

# Animation duration in seconds
@export_range(0.1, 2.0) var animation_duration: float = 0.3

# Animation easing
@export_enum("ease_in", "ease_out", "ease_in_out", "linear") var animation_easing: String = "ease_in_out"

# Return to original state after animation
@export var return_to_origin: bool = true

# Auto-start on ready
@export var auto_start: bool = true

# Reference to PolyrhythmController
var polyrhythm_controller: PolyrhythmController = null

# Animated node (defaults to self, can be overridden)
var animated_node: Node2D = null

# Tween for animation
var animation_tween: Tween = null

# Original transform state
var original_position: Vector2 = Vector2.ZERO
var original_rotation: float = 0.0
var original_scale: Vector2 = Vector2.ONE

# Current state
var is_animating: bool = false
var pattern_active: bool = false


## Initialize the polyrhythmic machinery
func _ready() -> void:
	_setup_animated_node()
	_store_original_state()
	_connect_to_polyrhythm_controller()

	if auto_start:
		start()


## Setup the node that will be animated
func _setup_animated_node() -> void:
	# By default, animate self
	animated_node = self

	# Check if there's a specific child node to animate (look for "AnimatedPart")
	var target_node: Node = get_node_or_null("AnimatedPart")
	if target_node != null and target_node is Node2D:
		animated_node = target_node


## Store original transform state for reset
func _store_original_state() -> void:
	if animated_node == null:
		return

	original_position = animated_node.position
	original_rotation = animated_node.rotation
	original_scale = animated_node.scale


## Connect to PolyrhythmController singleton
func _connect_to_polyrhythm_controller() -> void:
	# Try to get PolyrhythmController from scene tree
	if has_node("/root/PolyrhythmController"):
		polyrhythm_controller = get_node("/root/PolyrhythmController")
	else:
		# Search for it in the scene tree
		polyrhythm_controller = _find_polyrhythm_controller_in_tree(get_tree().root)

	if polyrhythm_controller == null:
		push_error("PolyrhythmMachinery: PolyrhythmController not found in scene tree")
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


## Start the polyrhythmic machinery (activate pattern)
func start() -> void:
	if pattern_active:
		return

	if polyrhythm_controller == null:
		push_error("PolyrhythmMachinery: Cannot start - PolyrhythmController not connected")
		return

	# Activate the rhythm pattern
	polyrhythm_controller.activate_pattern(rhythm_pattern)
	pattern_active = true


## Stop the polyrhythmic machinery
func stop() -> void:
	if not pattern_active:
		return

	if polyrhythm_controller != null:
		polyrhythm_controller.deactivate_pattern(rhythm_pattern)

	pattern_active = false

	# Stop any active animation
	if animation_tween != null:
		animation_tween.kill()
		animation_tween = null

	is_animating = false

	# Reset to original state
	if return_to_origin:
		_reset_to_original_state()


## Handle polyrhythm beat signal
## @param pattern_name: Pattern that triggered the beat
## @param beat_index: Index of the beat in the sequence
func _on_polyrhythm_beat(pattern_name: String, beat_index: int) -> void:
	# Only respond to our pattern
	if pattern_name != rhythm_pattern:
		return

	# Trigger animation
	_trigger_animation()


## Trigger machinery animation based on type
func _trigger_animation() -> void:
	if animated_node == null:
		return

	if is_animating:
		# Cancel previous animation
		if animation_tween != null:
			animation_tween.kill()

	is_animating = true
	animation_started.emit()

	# Create new tween
	animation_tween = create_tween()

	# Determine easing
	var easing_type: Tween.EaseType = Tween.EASE_IN_OUT
	match animation_easing:
		"ease_in":
			easing_type = Tween.EASE_IN
		"ease_out":
			easing_type = Tween.EASE_OUT
		"ease_in_out":
			easing_type = Tween.EASE_IN_OUT
		"linear":
			easing_type = Tween.EASE_IN  # Linear is EASE_IN with TRANS_LINEAR

	var trans_type: Tween.TransitionType = Tween.TRANS_QUAD
	if animation_easing == "linear":
		trans_type = Tween.TRANS_LINEAR

	# Apply animation based on type
	match animation_type:
		"rotate":
			_animate_rotation(easing_type, trans_type)
		"move_horizontal":
			_animate_horizontal_movement(easing_type, trans_type)
		"move_vertical":
			_animate_vertical_movement(easing_type, trans_type)
		"scale_pulse":
			_animate_scale_pulse(easing_type, trans_type)

	# Handle completion
	animation_tween.finished.connect(_on_animation_finished)


## Animate rotation
## @param easing: Easing type
## @param trans: Transition type
func _animate_rotation(easing: Tween.EaseType, trans: Tween.TransitionType) -> void:
	var target_rotation: float = original_rotation + deg_to_rad(rotation_angle)

	# Rotate to target
	animation_tween.tween_property(animated_node, "rotation", target_rotation, animation_duration * 0.5).set_ease(easing).set_trans(trans)

	if return_to_origin:
		# Rotate back to original
		animation_tween.tween_property(animated_node, "rotation", original_rotation, animation_duration * 0.5).set_ease(easing).set_trans(trans)


## Animate horizontal movement
## @param easing: Easing type
## @param trans: Transition type
func _animate_horizontal_movement(easing: Tween.EaseType, trans: Tween.TransitionType) -> void:
	var target_position: Vector2 = original_position + Vector2(move_distance, 0)

	# Move to target
	animation_tween.tween_property(animated_node, "position", target_position, animation_duration * 0.5).set_ease(easing).set_trans(trans)

	if return_to_origin:
		# Move back to original
		animation_tween.tween_property(animated_node, "position", original_position, animation_duration * 0.5).set_ease(easing).set_trans(trans)


## Animate vertical movement
## @param easing: Easing type
## @param trans: Transition type
func _animate_vertical_movement(easing: Tween.EaseType, trans: Tween.TransitionType) -> void:
	var target_position: Vector2 = original_position + Vector2(0, -move_distance)  # Negative for upward

	# Move to target
	animation_tween.tween_property(animated_node, "position", target_position, animation_duration * 0.5).set_ease(easing).set_trans(trans)

	if return_to_origin:
		# Move back to original
		animation_tween.tween_property(animated_node, "position", original_position, animation_duration * 0.5).set_ease(easing).set_trans(trans)


## Animate scale pulse
## @param easing: Easing type
## @param trans: Transition type
func _animate_scale_pulse(easing: Tween.EaseType, trans: Tween.TransitionType) -> void:
	var target_scale: Vector2 = Vector2(scale_max, scale_max)

	# Scale up
	animation_tween.tween_property(animated_node, "scale", target_scale, animation_duration * 0.5).set_ease(easing).set_trans(trans)

	if return_to_origin:
		# Scale back
		animation_tween.tween_property(animated_node, "scale", original_scale, animation_duration * 0.5).set_ease(easing).set_trans(trans)


## Handle animation completion
func _on_animation_finished() -> void:
	is_animating = false
	animation_completed.emit()


## Reset to original transform state
func _reset_to_original_state() -> void:
	if animated_node == null:
		return

	animated_node.position = original_position
	animated_node.rotation = original_rotation
	animated_node.scale = original_scale


## Set rhythm pattern at runtime
## @param new_pattern: New pattern name (e.g., "7:4")
func set_rhythm_pattern(new_pattern: String) -> void:
	var was_active: bool = pattern_active

	if was_active:
		stop()

	rhythm_pattern = new_pattern

	if was_active:
		start()


## Set animation type at runtime
## @param new_type: New animation type ("rotate", "move_horizontal", etc.)
func set_animation_type(new_type: String) -> void:
	animation_type = new_type
	_store_original_state()  # Update original state when changing type


## Clean up on exit
func _exit_tree() -> void:
	if animation_tween != null:
		animation_tween.kill()
		animation_tween = null
