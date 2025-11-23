# Godot 4.5 | GDScript 4.5
# System: S17 - Puzzle System - Environmental Puzzles
# Created: 2025-11-18
# Purpose: Environmental puzzles (push/pull blocks, levers, mirrors, switches)

extends Puzzle
class_name EnvironmentalPuzzle

## Environmental puzzle specific signals

## Emitted when a block is moved
signal block_moved(block_id: String, new_position: Vector2)

## Emitted when a pressure plate is activated
signal pressure_plate_activated(plate_id: String)

## Emitted when a pressure plate is deactivated
signal pressure_plate_deactivated(plate_id: String)

## Emitted when a lever is toggled
signal lever_toggled(lever_id: String, is_on: bool)

## Emitted when a mirror is rotated
signal mirror_rotated(mirror_id: String, new_angle: float)

## Emitted when a switch is activated
signal switch_activated(switch_id: String)

## Environmental puzzle subtypes
enum EnvironmentalType {
	PRESSURE_PLATES,   # Push blocks onto plates
	LEVER_SEQUENCE,    # Activate levers in correct order
	MIRROR_REFLECTION, # Redirect light beams to target
	SWITCH_TIMING      # Hit switches in time window
}

@export var environmental_type: EnvironmentalType = EnvironmentalType.PRESSURE_PLATES

# Puzzle elements
var blocks: Dictionary = {}  # block_id -> StaticBody2D/RigidBody2D
var pressure_plates: Dictionary = {}  # plate_id -> Area2D
var levers: Dictionary = {}  # lever_id -> Node2D
var mirrors: Dictionary = {}  # mirror_id -> Node2D
var switches: Dictionary = {}  # switch_id -> Area2D
var light_beams: Array = []  # Array of Line2D for laser beams

# State tracking
var activated_plates: Array[String] = []
var lever_sequence: Array[String] = []
var current_lever_index: int = 0
var active_switches: Array[String] = []


func _ready() -> void:
	puzzle_type = PuzzleType.ENVIRONMENTAL
	super._ready()


## Initialize environmental puzzle
func _initialize_puzzle() -> void:
	super._initialize_puzzle()

	# Find puzzle elements in scene tree
	_find_puzzle_elements()

	# Setup based on environmental type
	match environmental_type:
		EnvironmentalType.PRESSURE_PLATES:
			_setup_pressure_plate_puzzle()
		EnvironmentalType.LEVER_SEQUENCE:
			_setup_lever_sequence_puzzle()
		EnvironmentalType.MIRROR_REFLECTION:
			_setup_mirror_reflection_puzzle()
		EnvironmentalType.SWITCH_TIMING:
			_setup_switch_timing_puzzle()


## Find all puzzle elements in the scene tree
func _find_puzzle_elements() -> void:
	# Find blocks (any StaticBody2D or RigidBody2D in "Blocks" group)
	var block_nodes: Array[Node] = get_tree().get_nodes_in_group("puzzle_blocks")
	for block in block_nodes:
		if block.has_meta("block_id"):
			var block_id: String = block.get_meta("block_id")
			blocks[block_id] = block

	# Find pressure plates (Area2D in "PressurePlates" group)
	var plate_nodes: Array[Node] = get_tree().get_nodes_in_group("pressure_plates")
	for plate in plate_nodes:
		if plate.has_meta("plate_id"):
			var plate_id: String = plate.get_meta("plate_id")
			pressure_plates[plate_id] = plate
			# Connect signals
			if plate.has_signal("body_entered"):
				plate.body_entered.connect(_on_pressure_plate_entered.bind(plate_id))
			if plate.has_signal("body_exited"):
				plate.body_exited.connect(_on_pressure_plate_exited.bind(plate_id))

	# Find levers (Node2D in "Levers" group)
	var lever_nodes: Array[Node] = get_tree().get_nodes_in_group("puzzle_levers")
	for lever in lever_nodes:
		if lever.has_meta("lever_id"):
			var lever_id: String = lever.get_meta("lever_id")
			levers[lever_id] = lever

	# Find mirrors (Node2D in "Mirrors" group)
	var mirror_nodes: Array[Node] = get_tree().get_nodes_in_group("puzzle_mirrors")
	for mirror in mirror_nodes:
		if mirror.has_meta("mirror_id"):
			var mirror_id: String = mirror.get_meta("mirror_id")
			mirrors[mirror_id] = mirror

	# Find switches (Area2D in "Switches" group)
	var switch_nodes: Array[Node] = get_tree().get_nodes_in_group("puzzle_switches")
	for switch_node in switch_nodes:
		if switch_node.has_meta("switch_id"):
			var switch_id: String = switch_node.get_meta("switch_id")
			switches[switch_id] = switch_node


## Setup pressure plate puzzle
func _setup_pressure_plate_puzzle() -> void:
	print("EnvironmentalPuzzle: Setting up pressure plate puzzle")
	# Solution data should contain required blocks on plates
	# Example: {"blocks_on_plates": ["block_a", "block_b", "block_c"]}


## Setup lever sequence puzzle
func _setup_lever_sequence_puzzle() -> void:
	print("EnvironmentalPuzzle: Setting up lever sequence puzzle")
	# Solution data should contain lever activation order
	# Example: {"lever_sequence": ["lever_1", "lever_3", "lever_2", "lever_4"]}


## Setup mirror reflection puzzle
func _setup_mirror_reflection_puzzle() -> void:
	print("EnvironmentalPuzzle: Setting up mirror reflection puzzle")
	# Solution data should contain mirror angles and target
	# Example: {"mirror_angles": {"mirror_1": 45.0, "mirror_2": 90.0}, "target": "receptor_1"}


## Setup switch timing puzzle
func _setup_switch_timing_puzzle() -> void:
	print("EnvironmentalPuzzle: Setting up switch timing puzzle")
	# Solution data should contain switches and time windows
	# Example: {"switches": ["switch_1", "switch_2"], "time_window_s": 2.0}


## Check if puzzle solution is correct
func check_solution() -> bool:
	match environmental_type:
		EnvironmentalType.PRESSURE_PLATES:
			return _check_pressure_plate_solution()
		EnvironmentalType.LEVER_SEQUENCE:
			return _check_lever_sequence_solution()
		EnvironmentalType.MIRROR_REFLECTION:
			return _check_mirror_reflection_solution()
		EnvironmentalType.SWITCH_TIMING:
			return _check_switch_timing_solution()

	return false


## Check pressure plate solution
func _check_pressure_plate_solution() -> bool:
	var required_blocks: Array = solution_data.get("blocks_on_plates", [])

	# Check if all required blocks are on plates
	if activated_plates.size() != required_blocks.size():
		return false

	for block_id in required_blocks:
		if not block_id in activated_plates:
			return false

	return true


## Check lever sequence solution
func _check_lever_sequence_solution() -> bool:
	var required_sequence: Array = solution_data.get("lever_sequence", [])

	# Check if lever sequence matches
	if lever_sequence.size() != required_sequence.size():
		return false

	for i in range(lever_sequence.size()):
		if lever_sequence[i] != required_sequence[i]:
			return false

	return true


## Check mirror reflection solution
func _check_mirror_reflection_solution() -> bool:
	var required_angles: Dictionary = solution_data.get("mirror_angles", {})
	var target_id: String = solution_data.get("target", "")

	# Check if all mirrors are at correct angles (with tolerance)
	var angle_tolerance: float = 5.0  # degrees

	for mirror_id in required_angles.keys():
		if not mirrors.has(mirror_id):
			return false

		var mirror: Node2D = mirrors[mirror_id]
		var required_angle: float = required_angles[mirror_id]
		var current_angle: float = rad_to_deg(mirror.rotation)

		if abs(current_angle - required_angle) > angle_tolerance:
			return false

	# TODO: Check if light beam reaches target
	# This would require raycasting from light source through mirrors to target

	return true


## Check switch timing solution
func _check_switch_timing_solution() -> bool:
	var required_switches: Array = solution_data.get("switches", [])

	# Check if all required switches are active
	if active_switches.size() != required_switches.size():
		return false

	for switch_id in required_switches:
		if not switch_id in active_switches:
			return false

	return true


## Called when a pressure plate is entered
func _on_pressure_plate_entered(body: Node2D, plate_id: String) -> void:
	if not is_active:
		return

	# Check if body is a puzzle block
	var is_puzzle_block: bool = false
	var block_id: String = ""

	if body.has_meta("block_id"):
		block_id = body.get_meta("block_id")
		is_puzzle_block = blocks.has(block_id)

	if not is_puzzle_block:
		return

	# Activate pressure plate
	if not block_id in activated_plates:
		activated_plates.append(block_id)
		pressure_plate_activated.emit(plate_id)
		print("EnvironmentalPuzzle: Pressure plate %s activated by %s" % [plate_id, block_id])

		# Check solution
		if check_solution():
			solve_puzzle()


## Called when a pressure plate is exited
func _on_pressure_plate_exited(body: Node2D, plate_id: String) -> void:
	if not is_active:
		return

	# Check if body is a puzzle block
	var is_puzzle_block: bool = false
	var block_id: String = ""

	if body.has_meta("block_id"):
		block_id = body.get_meta("block_id")
		is_puzzle_block = blocks.has(block_id)

	if not is_puzzle_block:
		return

	# Deactivate pressure plate
	if block_id in activated_plates:
		activated_plates.erase(block_id)
		pressure_plate_deactivated.emit(plate_id)
		print("EnvironmentalPuzzle: Pressure plate %s deactivated" % plate_id)


## Toggle a lever (called from interaction system)
func toggle_lever(lever_id: String) -> void:
	if not is_active or not levers.has(lever_id):
		return

	var lever: Node = levers[lever_id]

	# Toggle lever state
	var is_on: bool = lever.get_meta("is_on", false)
	is_on = not is_on
	lever.set_meta("is_on", is_on)

	# Add to sequence
	lever_sequence.append(lever_id)

	lever_toggled.emit(lever_id, is_on)
	print("EnvironmentalPuzzle: Lever %s toggled to %s" % [lever_id, "ON" if is_on else "OFF"])

	# Check solution
	if check_solution():
		solve_puzzle()
	else:
		# Check if sequence is wrong
		var required_sequence: Array = solution_data.get("lever_sequence", [])
		if lever_sequence.size() > required_sequence.size():
			fail_puzzle("lever_sequence_too_long")
		elif lever_sequence.size() <= required_sequence.size():
			var expected_lever: String = required_sequence[lever_sequence.size() - 1]
			if lever_id != expected_lever:
				fail_puzzle("wrong_lever_sequence")
				reset_puzzle()


## Rotate a mirror (called from interaction system)
func rotate_mirror(mirror_id: String, angle_delta: float) -> void:
	if not is_active or not mirrors.has(mirror_id):
		return

	var mirror: Node2D = mirrors[mirror_id]
	mirror.rotation += deg_to_rad(angle_delta)

	mirror_rotated.emit(mirror_id, rad_to_deg(mirror.rotation))
	print("EnvironmentalPuzzle: Mirror %s rotated to %.1f degrees" % [mirror_id, rad_to_deg(mirror.rotation)])

	# Update light beam visualization
	_update_light_beams()

	# Check solution
	if check_solution():
		solve_puzzle()


## Update light beam visualization
func _update_light_beams() -> void:
	# Clear existing light beams
	for beam in light_beams:
		beam.queue_free()
	light_beams.clear()

	# TODO: Implement raycast-based light beam rendering
	# This would trace from light source through mirrors to show beam path


## Activate a switch (called from interaction system or timer)
func activate_switch(switch_id: String) -> void:
	if not is_active or not switches.has(switch_id):
		return

	if not switch_id in active_switches:
		active_switches.append(switch_id)
		switch_activated.emit(switch_id)
		print("EnvironmentalPuzzle: Switch %s activated" % switch_id)

		# Check solution
		if check_solution():
			solve_puzzle()

		# Auto-deactivate after time window
		var time_window: float = solution_data.get("time_window_s", 2.0)
		await get_tree().create_timer(time_window).timeout
		deactivate_switch(switch_id)


## Deactivate a switch
func deactivate_switch(switch_id: String) -> void:
	if switch_id in active_switches:
		active_switches.erase(switch_id)
		print("EnvironmentalPuzzle: Switch %s deactivated" % switch_id)


## Reset puzzle to initial state
func _on_puzzle_reset() -> void:
	activated_plates.clear()
	lever_sequence.clear()
	current_lever_index = 0
	active_switches.clear()

	# Reset all lever states
	for lever_id in levers.keys():
		var lever: Node = levers[lever_id]
		lever.set_meta("is_on", false)

	# Reset all mirror rotations
	for mirror_id in mirrors.keys():
		var mirror: Node2D = mirrors[mirror_id]
		mirror.rotation = 0.0

	# Clear light beams
	_update_light_beams()


## Get puzzle progress (0.0 to 1.0)
func get_progress() -> float:
	if is_solved:
		return 1.0

	match environmental_type:
		EnvironmentalType.PRESSURE_PLATES:
			var required_blocks: Array = solution_data.get("blocks_on_plates", [])
			if required_blocks.is_empty():
				return 0.0
			return float(activated_plates.size()) / float(required_blocks.size())

		EnvironmentalType.LEVER_SEQUENCE:
			var required_sequence: Array = solution_data.get("lever_sequence", [])
			if required_sequence.is_empty():
				return 0.0
			# Count correct sequence prefix
			var correct_count: int = 0
			for i in range(min(lever_sequence.size(), required_sequence.size())):
				if lever_sequence[i] == required_sequence[i]:
					correct_count += 1
				else:
					break
			return float(correct_count) / float(required_sequence.size())

		EnvironmentalType.MIRROR_REFLECTION:
			var required_angles: Dictionary = solution_data.get("mirror_angles", {})
			if required_angles.is_empty():
				return 0.0
			# Count mirrors at correct angles
			var correct_count: int = 0
			var angle_tolerance: float = 5.0
			for mirror_id in required_angles.keys():
				if mirrors.has(mirror_id):
					var mirror: Node2D = mirrors[mirror_id]
					var required_angle: float = required_angles[mirror_id]
					var current_angle: float = rad_to_deg(mirror.rotation)
					if abs(current_angle - required_angle) <= angle_tolerance:
						correct_count += 1
			return float(correct_count) / float(required_angles.size())

		EnvironmentalType.SWITCH_TIMING:
			var required_switches: Array = solution_data.get("switches", [])
			if required_switches.is_empty():
				return 0.0
			return float(active_switches.size()) / float(required_switches.size())

	return 0.0
