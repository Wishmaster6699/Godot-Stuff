# Godot 4.5 | GDScript 4.5
# System: S18 - Polyrhythmic Environment
# Created: 2025-11-18
# Dependencies: S01 Conductor (beat signals)
#
# The PolyrhythmController calculates and emits complex polyrhythmic patterns
# based on simple beat signals from the Conductor. It supports multiple
# polyrhythm ratios (4:3, 5:4, 7:4, etc.) and provides timing for animated
# environment elements.

extends Node
class_name PolyrhythmController

## Emitted when a polyrhythm numerator beat occurs
## @param pattern_name: The pattern ID (e.g., "4:3", "5:4")
## @param beat_index: Which beat in the numerator sequence (0-indexed)
signal polyrhythm_numerator_beat(pattern_name: String, beat_index: int)

## Emitted when a polyrhythm denominator beat occurs
## @param pattern_name: The pattern ID (e.g., "4:3", "5:4")
## @param beat_index: Which beat in the denominator sequence (0-indexed)
signal polyrhythm_denominator_beat(pattern_name: String, beat_index: int)

## Emitted when a polyrhythm cycle completes (both sequences aligned)
## @param pattern_name: The pattern ID
## @param cycle_number: How many complete cycles have occurred
signal polyrhythm_cycle_complete(pattern_name: String, cycle_number: int)

# Reference to Conductor autoload (S01)
var conductor: Node = null

# Configuration loaded from polyrhythm_config.json
var config: Dictionary = {}

# Active polyrhythm patterns
# Key: pattern_name (e.g., "4:3")
# Value: Dictionary with pattern data and tracking state
var active_patterns: Dictionary = {}

# Pattern definitions from config
var pattern_definitions: Dictionary = {}

# Element type configurations
var element_types: Dictionary = {}

# Debug settings
var debug_enabled: bool = false


## Initialize the polyrhythm controller
func _ready() -> void:
	_load_configuration()
	_connect_to_conductor()


## Load polyrhythm configuration from JSON file
func _load_configuration() -> void:
	var config_path: String = "res://data/polyrhythm_config.json"

	if not FileAccess.file_exists(config_path):
		push_error("PolyrhythmController: polyrhythm_config.json not found at ", config_path)
		_use_default_configuration()
		return

	var file: FileAccess = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("PolyrhythmController: Failed to open polyrhythm_config.json")
		_use_default_configuration()
		return

	var json_text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_text)

	if parse_result != OK:
		push_error("PolyrhythmController: Failed to parse JSON: ", json.get_error_message())
		_use_default_configuration()
		return

	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("PolyrhythmController: Invalid JSON format")
		_use_default_configuration()
		return

	config = data.get("polyrhythm_config", {})
	pattern_definitions = config.get("patterns", {})
	element_types = config.get("element_types", {})
	debug_enabled = config.get("debug_enabled", false)

	if debug_enabled:
		print("PolyrhythmController: Loaded ", pattern_definitions.size(), " pattern definitions")


## Use default configuration if JSON loading fails
func _use_default_configuration() -> void:
	push_warning("PolyrhythmController: Using default configuration")

	config = {
		"patterns": {
			"4:3": {"numerator": 4, "denominator": 3, "description": "4 over 3"},
			"5:4": {"numerator": 5, "denominator": 4, "description": "5 over 4"},
			"7:4": {"numerator": 7, "denominator": 4, "description": "7 over 4"}
		},
		"element_types": {
			"light": {
				"pulse_duration": 0.2,
				"brightness_range": [0.5, 1.0]
			},
			"machinery": {
				"rotation_angle": 90,
				"move_distance": 32
			},
			"platform": {
				"rise_distance": 64,
				"move_duration": 0.5
			}
		},
		"debug_enabled": false
	}

	pattern_definitions = config["patterns"]
	element_types = config["element_types"]


## Connect to Conductor singleton for beat signals
func _connect_to_conductor() -> void:
	# Check if Conductor autoload exists
	if not has_node("/root/Conductor"):
		push_error("PolyrhythmController: Conductor autoload not found!")
		push_error("PolyrhythmController: S01 (Conductor) must be initialized first")
		return

	conductor = get_node("/root/Conductor")

	# Connect to Conductor beat signal
	if conductor.has_signal("beat"):
		conductor.beat.connect(_on_conductor_beat)
	else:
		push_error("PolyrhythmController: Conductor doesn't have 'beat' signal")

	# Connect to measure_complete for cycle tracking
	if conductor.has_signal("measure_complete"):
		conductor.measure_complete.connect(_on_conductor_measure_complete)

	if debug_enabled:
		print("PolyrhythmController: Connected to Conductor")


## Activate a polyrhythm pattern for calculation
## @param pattern_name: Pattern ID (e.g., "4:3", "5:4")
## @return bool: True if pattern activated successfully
func activate_pattern(pattern_name: String) -> bool:
	if not pattern_definitions.has(pattern_name):
		push_error("PolyrhythmController: Unknown pattern '", pattern_name, "'")
		return false

	if active_patterns.has(pattern_name):
		push_warning("PolyrhythmController: Pattern '", pattern_name, "' already active")
		return true

	var pattern_def: Dictionary = pattern_definitions[pattern_name]
	var numerator: int = pattern_def.get("numerator", 4)
	var denominator: int = pattern_def.get("denominator", 3)

	# Calculate timing for polyrhythm
	# A polyrhythm like 4:3 means 4 beats in the time of 3 beats
	# If base measure is 4 beats, then:
	# - Numerator beats at: 0, 1, 2, 3 (evenly spaced over 4 beats)
	# - Denominator beats at: 0, 4/3, 8/3, 12/3 (evenly spaced over 4 beats)

	var pattern_state: Dictionary = {
		"numerator": numerator,
		"denominator": denominator,
		"numerator_beats": _calculate_beat_positions(numerator),
		"denominator_beats": _calculate_beat_positions(denominator),
		"current_numerator_index": 0,
		"current_denominator_index": 0,
		"cycle_count": 0,
		"beats_in_cycle": 0
	}

	active_patterns[pattern_name] = pattern_state

	if debug_enabled:
		print("PolyrhythmController: Activated pattern '", pattern_name, "' (", numerator, ":", denominator, ")")

	return true


## Deactivate a polyrhythm pattern
## @param pattern_name: Pattern ID to deactivate
func deactivate_pattern(pattern_name: String) -> void:
	if active_patterns.has(pattern_name):
		active_patterns.erase(pattern_name)
		if debug_enabled:
			print("PolyrhythmController: Deactivated pattern '", pattern_name, "'")


## Calculate beat positions for a polyrhythm sequence
## Returns array of fractional beat positions (0.0 to 4.0 for a 4-beat measure)
## @param num_beats: Number of beats in the sequence
## @return Array: Beat positions as floats
func _calculate_beat_positions(num_beats: int) -> Array:
	var positions: Array = []
	var beats_per_measure: int = 4  # Standard 4/4 time

	for i in range(num_beats):
		var position: float = (float(i) / float(num_beats)) * float(beats_per_measure)
		positions.append(position)

	return positions


## Handle beat signal from Conductor
## @param beat_number: Current beat number (1-indexed from Conductor)
func _on_conductor_beat(beat_number: int) -> void:
	# Convert 1-indexed beat to 0-indexed for calculations
	var beat_index: int = beat_number - 1

	# Process all active patterns
	for pattern_name in active_patterns:
		_process_pattern_beat(pattern_name, beat_index)


## Process a single pattern for the current beat
## @param pattern_name: Pattern ID
## @param beat_index: Current beat index (0-indexed)
func _process_pattern_beat(pattern_name: String, beat_index: int) -> void:
	var pattern: Dictionary = active_patterns[pattern_name]

	# Increment beats in cycle
	pattern["beats_in_cycle"] += 1

	# Check numerator beats
	var numerator_beats: Array = pattern["numerator_beats"]
	var numerator_index: int = pattern["current_numerator_index"]

	if numerator_index < numerator_beats.size():
		var target_beat: float = numerator_beats[numerator_index]

		# Check if current beat matches numerator beat (with small tolerance)
		if abs(float(beat_index) - target_beat) < 0.1:
			polyrhythm_numerator_beat.emit(pattern_name, numerator_index)
			pattern["current_numerator_index"] += 1

			if debug_enabled:
				print("PolyrhythmController: Numerator beat for '", pattern_name, "' at index ", numerator_index)

	# Check denominator beats
	var denominator_beats: Array = pattern["denominator_beats"]
	var denominator_index: int = pattern["current_denominator_index"]

	if denominator_index < denominator_beats.size():
		var target_beat: float = denominator_beats[denominator_index]

		# Check if current beat matches denominator beat (with small tolerance)
		if abs(float(beat_index) - target_beat) < 0.1:
			polyrhythm_denominator_beat.emit(pattern_name, denominator_index)
			pattern["current_denominator_index"] += 1

			if debug_enabled:
				print("PolyrhythmController: Denominator beat for '", pattern_name, "' at index ", denominator_index)


## Handle measure complete signal from Conductor
## @param measure_number: Completed measure number
func _on_conductor_measure_complete(measure_number: int) -> void:
	# Reset pattern indices for next cycle
	for pattern_name in active_patterns:
		var pattern: Dictionary = active_patterns[pattern_name]

		# Check if cycle is complete (both sequences finished)
		var numerator_complete: bool = pattern["current_numerator_index"] >= pattern["numerator"]
		var denominator_complete: bool = pattern["current_denominator_index"] >= pattern["denominator"]

		if numerator_complete and denominator_complete:
			pattern["cycle_count"] += 1
			polyrhythm_cycle_complete.emit(pattern_name, pattern["cycle_count"])

			if debug_enabled:
				print("PolyrhythmController: Cycle complete for '", pattern_name, "' (", pattern["cycle_count"], ")")

		# Reset indices for next cycle
		pattern["current_numerator_index"] = 0
		pattern["current_denominator_index"] = 0
		pattern["beats_in_cycle"] = 0


## Get element type configuration
## @param element_type: Type name (e.g., "light", "machinery", "platform")
## @return Dictionary: Element configuration or empty dict
func get_element_config(element_type: String) -> Dictionary:
	return element_types.get(element_type, {})


## Get pattern definition
## @param pattern_name: Pattern ID (e.g., "4:3")
## @return Dictionary: Pattern definition or empty dict
func get_pattern_definition(pattern_name: String) -> Dictionary:
	return pattern_definitions.get(pattern_name, {})


## Check if a pattern is currently active
## @param pattern_name: Pattern ID to check
## @return bool: True if pattern is active
func is_pattern_active(pattern_name: String) -> bool:
	return active_patterns.has(pattern_name)


## Get all active pattern names
## @return Array: Array of active pattern name strings
func get_active_patterns() -> Array:
	return active_patterns.keys()


## Get current state of a pattern
## @param pattern_name: Pattern ID
## @return Dictionary: Pattern state or empty dict if not active
func get_pattern_state(pattern_name: String) -> Dictionary:
	return active_patterns.get(pattern_name, {})


## Print debug information about polyrhythm controller state
func print_debug_info() -> void:
	print("═".repeat(60))
	print("PolyrhythmController Debug Info")
	print("═".repeat(60))
	print("Active Patterns: ", active_patterns.size())

	for pattern_name in active_patterns:
		var pattern: Dictionary = active_patterns[pattern_name]
		print("  Pattern: ", pattern_name)
		print("    Numerator: ", pattern["numerator"])
		print("    Denominator: ", pattern["denominator"])
		print("    Cycle Count: ", pattern["cycle_count"])
		print("    Numerator Index: ", pattern["current_numerator_index"])
		print("    Denominator Index: ", pattern["current_denominator_index"])

	print("Available Patterns: ", pattern_definitions.size())
	for pattern_name in pattern_definitions:
		var pattern_def: Dictionary = pattern_definitions[pattern_name]
		print("  ", pattern_name, ": ", pattern_def.get("description", "No description"))

	print("═".repeat(60))
