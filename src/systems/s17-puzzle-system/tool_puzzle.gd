# Godot 4.5 | GDScript 4.5
# System: S17 - Puzzle System - Tool-Based Puzzles
# Created: 2025-11-18
# Dependencies: S14 (Tool System)
# Purpose: Tool-based puzzles (grapple, laser, roller blades, surfboard)

extends Puzzle
class_name ToolPuzzle

## Tool puzzle specific signals

## Emitted when a grapple point is used
signal grapple_point_used(point_id: String)

## Emitted when laser hits a target
signal laser_target_hit(target_id: String)

## Emitted when speed plate is activated by roller blades
signal speed_plate_activated(plate_id: String)

## Emitted when surfboard reaches checkpoint
signal surfboard_checkpoint_reached(checkpoint_id: String)

## Tool puzzle subtypes
enum ToolPuzzleType {
	GRAPPLE_SWITCH,      # Grapple to unreachable switch
	LASER_CUT,           # Cut patterns with laser
	SPEED_PLATE,         # Activate plates with roller blades
	WAVE_SEQUENCE        # Navigate waves with surfboard
}

@export var tool_puzzle_type: ToolPuzzleType = ToolPuzzleType.GRAPPLE_SWITCH

# Required tool for this puzzle
@export var required_tool: String = "grapple_hook"  # grapple_hook, laser, roller_blades, surfboard

# Puzzle elements
var grapple_points: Dictionary = {}  # point_id -> Node2D
var laser_targets: Dictionary = {}  # target_id -> Area2D
var speed_plates: Dictionary = {}  # plate_id -> Area2D
var surf_checkpoints: Dictionary = {}  # checkpoint_id -> Area2D

# State tracking
var used_grapple_points: Array[String] = []
var hit_laser_targets: Array[String] = []
var activated_speed_plates: Array[String] = []
var reached_checkpoints: Array[String] = []

# Tool usage tracking
var current_tool_in_use: String = ""
var tool_use_start_time: float = 0.0


func _ready() -> void:
	puzzle_type = PuzzleType.TOOL_BASED
	super._ready()


## Initialize tool puzzle
func _initialize_puzzle() -> void:
	super._initialize_puzzle()

	# Find puzzle elements in scene tree
	_find_puzzle_elements()

	# Connect to tool manager if available
	_connect_to_tool_manager()

	# Setup based on tool puzzle type
	match tool_puzzle_type:
		ToolPuzzleType.GRAPPLE_SWITCH:
			_setup_grapple_switch_puzzle()
		ToolPuzzleType.LASER_CUT:
			_setup_laser_cut_puzzle()
		ToolPuzzleType.SPEED_PLATE:
			_setup_speed_plate_puzzle()
		ToolPuzzleType.WAVE_SEQUENCE:
			_setup_wave_sequence_puzzle()


## Find all puzzle elements in the scene tree
func _find_puzzle_elements() -> void:
	# Find grapple points (Node2D in "GrapplePoints" group)
	var grapple_nodes: Array[Node] = get_tree().get_nodes_in_group("grapple_points")
	for point in grapple_nodes:
		if point.has_meta("point_id"):
			var point_id: String = point.get_meta("point_id")
			grapple_points[point_id] = point

	# Find laser targets (Area2D in "LaserTargets" group)
	var target_nodes: Array[Node] = get_tree().get_nodes_in_group("laser_targets")
	for target in target_nodes:
		if target.has_meta("target_id"):
			var target_id: String = target.get_meta("target_id")
			laser_targets[target_id] = target
			# Connect area signals
			if target.has_signal("area_entered"):
				target.area_entered.connect(_on_laser_target_hit.bind(target_id))

	# Find speed plates (Area2D in "SpeedPlates" group)
	var plate_nodes: Array[Node] = get_tree().get_nodes_in_group("speed_plates")
	for plate in plate_nodes:
		if plate.has_meta("plate_id"):
			var plate_id: String = plate.get_meta("plate_id")
			speed_plates[plate_id] = plate
			# Connect signals
			if plate.has_signal("body_entered"):
				plate.body_entered.connect(_on_speed_plate_entered.bind(plate_id))

	# Find surfboard checkpoints (Area2D in "SurfCheckpoints" group)
	var checkpoint_nodes: Array[Node] = get_tree().get_nodes_in_group("surf_checkpoints")
	for checkpoint in checkpoint_nodes:
		if checkpoint.has_meta("checkpoint_id"):
			var checkpoint_id: String = checkpoint.get_meta("checkpoint_id")
			surf_checkpoints[checkpoint_id] = checkpoint
			# Connect signals
			if checkpoint.has_signal("body_entered"):
				checkpoint.body_entered.connect(_on_checkpoint_reached.bind(checkpoint_id))


## Connect to tool manager for tool change events
func _connect_to_tool_manager() -> void:
	if tool_manager != null:
		if tool_manager.has_signal("tool_switched"):
			tool_manager.tool_switched.connect(_on_tool_switched)
		if tool_manager.has_signal("tool_used"):
			tool_manager.tool_used.connect(_on_tool_used)


## Setup grapple switch puzzle
func _setup_grapple_switch_puzzle() -> void:
	print("ToolPuzzle: Setting up grapple switch puzzle")
	required_tool = "grapple_hook"
	# Solution data should contain required grapple points
	# Example: {"grapple_points": ["point_a", "point_b", "switch_1"]}


## Setup laser cut puzzle
func _setup_laser_cut_puzzle() -> void:
	print("ToolPuzzle: Setting up laser cut puzzle")
	required_tool = "laser"
	# Solution data should contain laser targets and cut pattern
	# Example: {"laser_targets": ["target_1", "target_2", "target_3"], "pattern": "triangle"}


## Setup speed plate puzzle
func _setup_speed_plate_puzzle() -> void:
	print("ToolPuzzle: Setting up speed plate puzzle")
	required_tool = "roller_blades"
	# Solution data should contain speed plates and minimum speed
	# Example: {"speed_plates": ["plate_1", "plate_2"], "min_speed": 150}


## Setup wave sequence puzzle
func _setup_wave_sequence_puzzle() -> void:
	print("ToolPuzzle: Setting up wave sequence puzzle")
	required_tool = "surfboard"
	# Solution data should contain checkpoint sequence
	# Example: {"checkpoints": ["cp_1", "cp_2", "cp_3"], "time_limit_s": 30.0}


## Check if puzzle solution is correct
func check_solution() -> bool:
	match tool_puzzle_type:
		ToolPuzzleType.GRAPPLE_SWITCH:
			return _check_grapple_switch_solution()
		ToolPuzzleType.LASER_CUT:
			return _check_laser_cut_solution()
		ToolPuzzleType.SPEED_PLATE:
			return _check_speed_plate_solution()
		ToolPuzzleType.WAVE_SEQUENCE:
			return _check_wave_sequence_solution()

	return false


## Check grapple switch solution
func _check_grapple_switch_solution() -> bool:
	var required_points: Array = solution_data.get("grapple_points", [])

	# Check if all required grapple points were used
	if used_grapple_points.size() != required_points.size():
		return false

	for point_id in required_points:
		if not point_id in used_grapple_points:
			return false

	return true


## Check laser cut solution
func _check_laser_cut_solution() -> bool:
	var required_targets: Array = solution_data.get("laser_targets", [])

	# Check if all required targets were hit
	if hit_laser_targets.size() != required_targets.size():
		return false

	for target_id in required_targets:
		if not target_id in hit_laser_targets:
			return false

	return true


## Check speed plate solution
func _check_speed_plate_solution() -> bool:
	var required_plates: Array = solution_data.get("speed_plates", [])

	# Check if all required plates were activated
	if activated_speed_plates.size() != required_plates.size():
		return false

	for plate_id in required_plates:
		if not plate_id in activated_speed_plates:
			return false

	return true


## Check wave sequence solution
func _check_wave_sequence_solution() -> bool:
	var required_checkpoints: Array = solution_data.get("checkpoints", [])

	# Check if checkpoints were reached in order
	if reached_checkpoints.size() != required_checkpoints.size():
		return false

	for i in range(required_checkpoints.size()):
		if reached_checkpoints[i] != required_checkpoints[i]:
			return false

	return true


## Called when tool is switched
func _on_tool_switched(tool_id: String, previous_tool_id: String) -> void:
	current_tool_in_use = tool_id

	# Check if correct tool is equipped for puzzle
	if is_active and tool_id != required_tool:
		print("ToolPuzzle: Wrong tool equipped (need %s, got %s)" % [required_tool, tool_id])


## Called when tool is used
func _on_tool_used(tool_id: String) -> void:
	if not is_active:
		return

	if tool_id != required_tool:
		fail_puzzle("wrong_tool_used")
		return

	tool_use_start_time = Time.get_ticks_msec() / 1000.0
	print("ToolPuzzle: Tool %s used" % tool_id)


## Called when player grapples to a point
func use_grapple_point(point_id: String) -> void:
	if not is_active or not grapple_points.has(point_id):
		return

	if current_tool_in_use != "grapple_hook":
		fail_puzzle("wrong_tool")
		return

	if not point_id in used_grapple_points:
		used_grapple_points.append(point_id)
		grapple_point_used.emit(point_id)
		print("ToolPuzzle: Grapple point %s used" % point_id)

		# Check solution
		if check_solution():
			solve_puzzle()


## Called when laser hits a target
func _on_laser_target_hit(area: Area2D, target_id: String) -> void:
	if not is_active:
		return

	if current_tool_in_use != "laser":
		return

	# Check if area is from laser beam
	if not area.is_in_group("laser_beam"):
		return

	if not target_id in hit_laser_targets:
		hit_laser_targets.append(target_id)
		laser_target_hit.emit(target_id)
		print("ToolPuzzle: Laser target %s hit" % target_id)

		# Check solution
		if check_solution():
			solve_puzzle()


## Called when speed plate is entered
func _on_speed_plate_entered(body: Node2D, plate_id: String) -> void:
	if not is_active:
		return

	# Check if player is using roller blades
	if current_tool_in_use != "roller_blades":
		return

	# Check player speed
	var min_speed: float = solution_data.get("min_speed", 0.0)
	var player_speed: float = 0.0

	if body.has_method("get_velocity"):
		var velocity: Vector2 = body.call("get_velocity")
		player_speed = velocity.length()
	elif body.has_property("velocity"):
		var velocity: Vector2 = body.get("velocity")
		player_speed = velocity.length()

	if player_speed < min_speed:
		print("ToolPuzzle: Speed too low (%.1f < %.1f)" % [player_speed, min_speed])
		fail_puzzle("insufficient_speed")
		return

	if not plate_id in activated_speed_plates:
		activated_speed_plates.append(plate_id)
		speed_plate_activated.emit(plate_id)
		print("ToolPuzzle: Speed plate %s activated (speed: %.1f)" % [plate_id, player_speed])

		# Check solution
		if check_solution():
			solve_puzzle()


## Called when surfboard checkpoint is reached
func _on_checkpoint_reached(body: Node2D, checkpoint_id: String) -> void:
	if not is_active:
		return

	# Check if player is using surfboard
	if current_tool_in_use != "surfboard":
		return

	# Check if checkpoint is next in sequence
	var required_checkpoints: Array = solution_data.get("checkpoints", [])
	var expected_checkpoint: String = ""

	if reached_checkpoints.size() < required_checkpoints.size():
		expected_checkpoint = required_checkpoints[reached_checkpoints.size()]
	else:
		# All checkpoints already reached
		return

	if checkpoint_id != expected_checkpoint:
		print("ToolPuzzle: Wrong checkpoint order (expected %s, got %s)" % [expected_checkpoint, checkpoint_id])
		fail_puzzle("wrong_checkpoint_order")
		reset_puzzle()
		return

	reached_checkpoints.append(checkpoint_id)
	surfboard_checkpoint_reached.emit(checkpoint_id)
	print("ToolPuzzle: Checkpoint %s reached (%d/%d)" % [checkpoint_id, reached_checkpoints.size(), required_checkpoints.size()])

	# Check solution
	if check_solution():
		solve_puzzle()


## Activate puzzle (override to check for required tool)
func activate() -> void:
	super.activate()

	# Check if player has required tool equipped
	if tool_manager != null and tool_manager.has_method("get_current_tool_name"):
		var current_tool: String = tool_manager.get_current_tool_name()
		if current_tool != required_tool:
			print("ToolPuzzle: Warning - Puzzle requires %s (current: %s)" % [required_tool, current_tool])


## Reset puzzle to initial state
func _on_puzzle_reset() -> void:
	used_grapple_points.clear()
	hit_laser_targets.clear()
	activated_speed_plates.clear()
	reached_checkpoints.clear()
	tool_use_start_time = 0.0


## Get puzzle progress (0.0 to 1.0)
func get_progress() -> float:
	if is_solved:
		return 1.0

	match tool_puzzle_type:
		ToolPuzzleType.GRAPPLE_SWITCH:
			var required_points: Array = solution_data.get("grapple_points", [])
			if required_points.is_empty():
				return 0.0
			return float(used_grapple_points.size()) / float(required_points.size())

		ToolPuzzleType.LASER_CUT:
			var required_targets: Array = solution_data.get("laser_targets", [])
			if required_targets.is_empty():
				return 0.0
			return float(hit_laser_targets.size()) / float(required_targets.size())

		ToolPuzzleType.SPEED_PLATE:
			var required_plates: Array = solution_data.get("speed_plates", [])
			if required_plates.is_empty():
				return 0.0
			return float(activated_speed_plates.size()) / float(required_plates.size())

		ToolPuzzleType.WAVE_SEQUENCE:
			var required_checkpoints: Array = solution_data.get("checkpoints", [])
			if required_checkpoints.is_empty():
				return 0.0
			return float(reached_checkpoints.size()) / float(required_checkpoints.size())

	return 0.0


## Get hint for puzzle
func get_hint() -> String:
	var base_hint: String = super.get_hint()

	if base_hint != "No hint available":
		return base_hint

	# Provide tool-specific hints
	return "Try using the %s to interact with puzzle elements" % required_tool
