# Godot 4.5 | GDScript 4.5
# System: S18 - Polyrhythmic Environment
# Created: 2025-11-18
# Dependencies: S01 Conductor, PolyrhythmController
#
# A light that pulses in brightness on polyrhythmic beats.
# Attach this to a Light2D or PointLight2D node for automatic pulsing.

extends Node2D
class_name PolyrhythmLight

## Emitted when light pulse starts
signal pulse_started()

## Emitted when light pulse completes
signal pulse_completed()

# Polyrhythm pattern to follow (e.g., "4:3", "5:4", "7:4")
@export var rhythm_pattern: String = "4:3"

# Which polyrhythm track to follow ("numerator" or "denominator")
@export_enum("numerator", "denominator") var rhythm_track: String = "numerator"

# Base energy (brightness) when not pulsing
@export_range(0.0, 2.0) var base_energy: float = 0.5

# Peak energy (brightness) during pulse
@export_range(0.0, 2.0) var peak_energy: float = 1.5

# Pulse duration in seconds
@export_range(0.05, 1.0) var pulse_duration: float = 0.2

# Pulse easing curve (ease_in, ease_out, ease_in_out)
@export_enum("ease_in", "ease_out", "ease_in_out") var pulse_easing: String = "ease_out"

# Color tint during pulse (optional)
@export var pulse_color: Color = Color.WHITE

# Base color when not pulsing
@export var base_color: Color = Color.WHITE

# Auto-start on ready
@export var auto_start: bool = true

# Reference to PolyrhythmController
var polyrhythm_controller: PolyrhythmController = null

# Light node (Light2D or PointLight2D)
var light_node: Node = null

# Tween for brightness animation
var pulse_tween: Tween = null

# Current state
var is_pulsing: bool = false
var pattern_active: bool = false


## Initialize the polyrhythmic light
func _ready() -> void:
	_find_light_node()
	_connect_to_polyrhythm_controller()

	if auto_start:
		start()


## Find the Light2D or PointLight2D child node
func _find_light_node() -> void:
	# Check if this node itself is a light
	if self is Light2D or self is PointLight2D:
		light_node = self
		return

	# Search children for light node
	for child in get_children():
		if child is Light2D or child is PointLight2D:
			light_node = child
			break

	if light_node == null:
		# Check parent (in case this script is attached to the light directly)
		if get_parent() is Light2D or get_parent() is PointLight2D:
			light_node = get_parent()

	if light_node == null:
		push_warning("PolyrhythmLight: No Light2D or PointLight2D found. Add one as a child or parent.")
		# Create a default modulate target (this node)
		light_node = self


## Connect to PolyrhythmController singleton
func _connect_to_polyrhythm_controller() -> void:
	# Try to get PolyrhythmController from scene tree
	# It might be an autoload or in the scene
	if has_node("/root/PolyrhythmController"):
		polyrhythm_controller = get_node("/root/PolyrhythmController")
	else:
		# Search for it in the scene tree
		polyrhythm_controller = _find_polyrhythm_controller_in_tree(get_tree().root)

	if polyrhythm_controller == null:
		push_error("PolyrhythmLight: PolyrhythmController not found in scene tree")
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


## Start the polyrhythmic light (activate pattern)
func start() -> void:
	if pattern_active:
		return

	if polyrhythm_controller == null:
		push_error("PolyrhythmLight: Cannot start - PolyrhythmController not connected")
		return

	# Activate the rhythm pattern
	polyrhythm_controller.activate_pattern(rhythm_pattern)
	pattern_active = true

	# Set initial state
	_set_light_properties(base_energy, base_color)


## Stop the polyrhythmic light
func stop() -> void:
	if not pattern_active:
		return

	if polyrhythm_controller != null:
		polyrhythm_controller.deactivate_pattern(rhythm_pattern)

	pattern_active = false

	# Stop any active pulse
	if pulse_tween != null:
		pulse_tween.kill()
		pulse_tween = null

	is_pulsing = false


## Handle polyrhythm beat signal
## @param pattern_name: Pattern that triggered the beat
## @param beat_index: Index of the beat in the sequence
func _on_polyrhythm_beat(pattern_name: String, beat_index: int) -> void:
	# Only respond to our pattern
	if pattern_name != rhythm_pattern:
		return

	# Trigger pulse
	_trigger_pulse()


## Trigger a light pulse animation
func _trigger_pulse() -> void:
	if is_pulsing:
		# Cancel previous pulse
		if pulse_tween != null:
			pulse_tween.kill()

	is_pulsing = true
	pulse_started.emit()

	# Create new tween
	pulse_tween = create_tween()
	pulse_tween.set_parallel(true)

	# Determine easing
	var easing_type: Tween.EaseType = Tween.EASE_OUT
	match pulse_easing:
		"ease_in":
			easing_type = Tween.EASE_IN
		"ease_out":
			easing_type = Tween.EASE_OUT
		"ease_in_out":
			easing_type = Tween.EASE_IN_OUT

	# Animate to peak
	if light_node is Light2D or light_node is PointLight2D:
		# Tween energy (brightness)
		pulse_tween.tween_property(light_node, "energy", peak_energy, pulse_duration * 0.5).set_ease(easing_type).set_trans(Tween.TRANS_QUAD)
		pulse_tween.tween_property(light_node, "color", pulse_color, pulse_duration * 0.5).set_ease(easing_type).set_trans(Tween.TRANS_QUAD)
	else:
		# Fallback: modulate the node
		pulse_tween.tween_property(light_node, "modulate", pulse_color * peak_energy, pulse_duration * 0.5).set_ease(easing_type).set_trans(Tween.TRANS_QUAD)

	# Animate back to base (chain after peak)
	pulse_tween.chain()

	if light_node is Light2D or light_node is PointLight2D:
		pulse_tween.tween_property(light_node, "energy", base_energy, pulse_duration * 0.5).set_ease(easing_type).set_trans(Tween.TRANS_QUAD)
		pulse_tween.tween_property(light_node, "color", base_color, pulse_duration * 0.5).set_ease(easing_type).set_trans(Tween.TRANS_QUAD)
	else:
		pulse_tween.tween_property(light_node, "modulate", base_color * base_energy, pulse_duration * 0.5).set_ease(easing_type).set_trans(Tween.TRANS_QUAD)

	# Handle completion
	pulse_tween.finished.connect(_on_pulse_finished)


## Handle pulse completion
func _on_pulse_finished() -> void:
	is_pulsing = false
	pulse_completed.emit()


## Set light properties (energy and color)
## @param energy: Brightness value
## @param color: Light color
func _set_light_properties(energy: float, color: Color) -> void:
	if light_node == null:
		return

	if light_node is Light2D or light_node is PointLight2D:
		light_node.energy = energy
		light_node.color = color
	else:
		# Fallback: use modulate
		light_node.modulate = color * energy


## Get current energy value
## @return float: Current light energy/brightness
func get_current_energy() -> float:
	if light_node == null:
		return 0.0

	if light_node is Light2D or light_node is PointLight2D:
		return light_node.energy
	else:
		return light_node.modulate.a


## Set rhythm pattern at runtime
## @param new_pattern: New pattern name (e.g., "5:4")
func set_rhythm_pattern(new_pattern: String) -> void:
	var was_active: bool = pattern_active

	if was_active:
		stop()

	rhythm_pattern = new_pattern

	if was_active:
		start()


## Clean up on exit
func _exit_tree() -> void:
	if pulse_tween != null:
		pulse_tween.kill()
		pulse_tween = null
