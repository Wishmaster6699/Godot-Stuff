# Godot 4.5 | GDScript 4.5
# System: S17 - Puzzle System - Multi-Stage Puzzles
# Created: 2025-11-18
# Purpose: Multi-stage puzzles (combinations of different puzzle types in sequence)

extends Puzzle
class_name MultiStagePuzzle

## Multi-stage puzzle specific signals

## Emitted when a stage is completed
signal stage_completed(stage_index: int, stage_type: String)

## Emitted when a stage is failed
signal stage_failed(stage_index: int, reason: String)

## Emitted when a stage becomes active
signal stage_activated(stage_index: int, stage_type: String)

## Emitted when all stages are complete
signal all_stages_complete()

# Stage configuration
var stages: Array[Dictionary] = []  # Array of stage configurations
var current_stage_index: int = 0
var completed_stages: Array[int] = []

# Stage puzzle instances
var stage_puzzles: Array[Puzzle] = []

# Stage types (references to puzzle class names)
const STAGE_TYPE_MAP: Dictionary = {
	"environmental": "EnvironmentalPuzzle",
	"tool": "ToolPuzzle",
	"item": "ItemPuzzle",
	"rhythm": "RhythmPuzzle",
	"physics": "PhysicsPuzzle"
}


func _ready() -> void:
	puzzle_type = PuzzleType.MULTI_STAGE
	super._ready()


## Initialize multi-stage puzzle
func _initialize_puzzle() -> void:
	super._initialize_puzzle()

	# Load stages from solution data
	stages = solution_data.get("stages", [])

	if stages.is_empty():
		push_error("MultiStagePuzzle: No stages defined in solution data")
		return

	# Create puzzle instances for each stage
	_create_stage_puzzles()

	print("MultiStagePuzzle: Initialized with %d stages" % stages.size())


## Create puzzle instances for each stage
func _create_stage_puzzles() -> void:
	for i in range(stages.size()):
		var stage_config: Dictionary = stages[i]
		var stage_type: String = stage_config.get("type", "")

		# Create appropriate puzzle instance based on type
		var puzzle: Puzzle = _create_puzzle_for_stage(stage_type, stage_config)

		if puzzle != null:
			puzzle.name = "Stage_%d_%s" % [i, stage_type]
			add_child(puzzle)

			# Connect stage puzzle signals
			if puzzle.has_signal("puzzle_solved"):
				puzzle.puzzle_solved.connect(_on_stage_puzzle_solved.bind(i))
			if puzzle.has_signal("puzzle_failed"):
				puzzle.puzzle_failed.connect(_on_stage_puzzle_failed.bind(i))

			# Disable puzzle initially (will be enabled when stage becomes active)
			puzzle.enabled = false
			puzzle.deactivate()

			stage_puzzles.append(puzzle)
			print("MultiStagePuzzle: Created stage %d (%s)" % [i, stage_type])
		else:
			push_error("MultiStagePuzzle: Failed to create puzzle for stage %d (type: %s)" % [i, stage_type])


## Create a puzzle instance for a specific stage
func _create_puzzle_for_stage(stage_type: String, stage_config: Dictionary) -> Puzzle:
	# Determine which puzzle class to instantiate
	match stage_type:
		"environmental":
			var puzzle: EnvironmentalPuzzle = EnvironmentalPuzzle.new()
			_configure_environmental_puzzle(puzzle, stage_config)
			return puzzle

		"tool":
			var puzzle: ToolPuzzle = ToolPuzzle.new()
			_configure_tool_puzzle(puzzle, stage_config)
			return puzzle

		"item":
			var puzzle: ItemPuzzle = ItemPuzzle.new()
			_configure_item_puzzle(puzzle, stage_config)
			return puzzle

		"rhythm":
			var puzzle: RhythmPuzzle = RhythmPuzzle.new()
			_configure_rhythm_puzzle(puzzle, stage_config)
			return puzzle

		"physics":
			var puzzle: PhysicsPuzzle = PhysicsPuzzle.new()
			_configure_physics_puzzle(puzzle, stage_config)
			return puzzle

		_:
			push_error("MultiStagePuzzle: Unknown stage type: %s" % stage_type)
			return null


## Configure environmental puzzle stage
func _configure_environmental_puzzle(puzzle: EnvironmentalPuzzle, config: Dictionary) -> void:
	puzzle.puzzle_id = config.get("puzzle_id", "env_stage")
	puzzle.description = config.get("description", "")
	puzzle.solution_data = config.get("solution", {})
	puzzle.reward = config.get("reward", {})

	# Set environmental type
	var env_type: String = config.get("environmental_type", "pressure_plates")
	match env_type:
		"pressure_plates":
			puzzle.environmental_type = EnvironmentalPuzzle.EnvironmentalType.PRESSURE_PLATES
		"lever_sequence":
			puzzle.environmental_type = EnvironmentalPuzzle.EnvironmentalType.LEVER_SEQUENCE
		"mirror_reflection":
			puzzle.environmental_type = EnvironmentalPuzzle.EnvironmentalType.MIRROR_REFLECTION
		"switch_timing":
			puzzle.environmental_type = EnvironmentalPuzzle.EnvironmentalType.SWITCH_TIMING


## Configure tool puzzle stage
func _configure_tool_puzzle(puzzle: ToolPuzzle, config: Dictionary) -> void:
	puzzle.puzzle_id = config.get("puzzle_id", "tool_stage")
	puzzle.description = config.get("description", "")
	puzzle.solution_data = config.get("solution", {})
	puzzle.reward = config.get("reward", {})
	puzzle.required_tool = config.get("required_tool", "grapple_hook")

	# Set tool puzzle type
	var tool_type: String = config.get("tool_puzzle_type", "grapple_switch")
	match tool_type:
		"grapple_switch":
			puzzle.tool_puzzle_type = ToolPuzzle.ToolPuzzleType.GRAPPLE_SWITCH
		"laser_cut":
			puzzle.tool_puzzle_type = ToolPuzzle.ToolPuzzleType.LASER_CUT
		"speed_plate":
			puzzle.tool_puzzle_type = ToolPuzzle.ToolPuzzleType.SPEED_PLATE
		"wave_sequence":
			puzzle.tool_puzzle_type = ToolPuzzle.ToolPuzzleType.WAVE_SEQUENCE


## Configure item puzzle stage
func _configure_item_puzzle(puzzle: ItemPuzzle, config: Dictionary) -> void:
	puzzle.puzzle_id = config.get("puzzle_id", "item_stage")
	puzzle.description = config.get("description", "")
	puzzle.solution_data = config.get("solution", {})
	puzzle.reward = config.get("reward", {})
	puzzle.consume_items = config.get("consume_items", true)

	# Set item puzzle type
	var item_type: String = config.get("item_puzzle_type", "single_key")
	match item_type:
		"single_key":
			puzzle.item_puzzle_type = ItemPuzzle.ItemPuzzleType.SINGLE_KEY
		"multi_key":
			puzzle.item_puzzle_type = ItemPuzzle.ItemPuzzleType.MULTI_KEY
		"orb_collection":
			puzzle.item_puzzle_type = ItemPuzzle.ItemPuzzleType.ORB_COLLECTION
		"gem_socket":
			puzzle.item_puzzle_type = ItemPuzzle.ItemPuzzleType.GEM_SOCKET
		"item_combination":
			puzzle.item_puzzle_type = ItemPuzzle.ItemPuzzleType.ITEM_COMBINATION


## Configure rhythm puzzle stage
func _configure_rhythm_puzzle(puzzle: RhythmPuzzle, config: Dictionary) -> void:
	puzzle.puzzle_id = config.get("puzzle_id", "rhythm_stage")
	puzzle.description = config.get("description", "")
	puzzle.solution_data = config.get("solution", {})
	puzzle.reward = config.get("reward", {})

	# Set rhythm puzzle type
	var rhythm_type: String = config.get("rhythm_puzzle_type", "beat_sequence")
	match rhythm_type:
		"beat_sequence":
			puzzle.rhythm_puzzle_type = RhythmPuzzle.RhythmPuzzleType.BEAT_SEQUENCE
		"simon_says":
			puzzle.rhythm_puzzle_type = RhythmPuzzle.RhythmPuzzleType.SIMON_SAYS
		"multi_beat":
			puzzle.rhythm_puzzle_type = RhythmPuzzle.RhythmPuzzleType.MULTI_BEAT
		"timing_lock":
			puzzle.rhythm_puzzle_type = RhythmPuzzle.RhythmPuzzleType.TIMING_LOCK


## Configure physics puzzle stage
func _configure_physics_puzzle(puzzle: PhysicsPuzzle, config: Dictionary) -> void:
	puzzle.puzzle_id = config.get("puzzle_id", "physics_stage")
	puzzle.description = config.get("description", "")
	puzzle.solution_data = config.get("solution", {})
	puzzle.reward = config.get("reward", {})

	# Set physics puzzle type
	var physics_type: String = config.get("physics_puzzle_type", "momentum_swing")
	match physics_type:
		"momentum_swing":
			puzzle.physics_puzzle_type = PhysicsPuzzle.PhysicsPuzzleType.MOMENTUM_SWING
		"gravity_drop":
			puzzle.physics_puzzle_type = PhysicsPuzzle.PhysicsPuzzleType.GRAVITY_DROP
		"buoyancy":
			puzzle.physics_puzzle_type = PhysicsPuzzle.PhysicsPuzzleType.BUOYANCY
		"projectile":
			puzzle.physics_puzzle_type = PhysicsPuzzle.PhysicsPuzzleType.PROJECTILE


## Activate the multi-stage puzzle
func activate() -> void:
	super.activate()

	# Activate first stage
	if stages.size() > 0 and stage_puzzles.size() > 0:
		_activate_stage(0)


## Activate a specific stage
func _activate_stage(stage_index: int) -> void:
	if stage_index < 0 or stage_index >= stage_puzzles.size():
		push_error("MultiStagePuzzle: Invalid stage index: %d" % stage_index)
		return

	current_stage_index = stage_index

	# Deactivate all other stages
	for i in range(stage_puzzles.size()):
		if i != stage_index:
			stage_puzzles[i].deactivate()
			stage_puzzles[i].enabled = false

	# Activate current stage
	var current_puzzle: Puzzle = stage_puzzles[stage_index]
	current_puzzle.enabled = true
	current_puzzle.activate()

	var stage_type: String = stages[stage_index].get("type", "unknown")
	stage_activated.emit(stage_index, stage_type)

	print("MultiStagePuzzle: Activated stage %d/%d (%s)" % [stage_index + 1, stages.size(), stage_type])


## Called when a stage puzzle is solved
func _on_stage_puzzle_solved(stage_puzzle_id: String, stage_reward: Dictionary, stage_index: int) -> void:
	if stage_index != current_stage_index:
		# Old stage solved late, ignore
		return

	var stage_type: String = stages[stage_index].get("type", "unknown")
	completed_stages.append(stage_index)

	stage_completed.emit(stage_index, stage_type)
	print("MultiStagePuzzle: Stage %d/%d completed (%s)" % [stage_index + 1, stages.size(), stage_type])

	# Check if there are more stages
	if stage_index + 1 < stages.size():
		# Move to next stage
		_activate_stage(stage_index + 1)
	else:
		# All stages complete!
		_complete_all_stages()


## Called when a stage puzzle fails
func _on_stage_puzzle_failed(stage_puzzle_id: String, reason: String, stage_index: int) -> void:
	if stage_index != current_stage_index:
		return

	var stage_type: String = stages[stage_index].get("type", "unknown")
	stage_failed.emit(stage_index, reason)

	print("MultiStagePuzzle: Stage %d failed (%s) - Reason: %s" % [stage_index + 1, stage_type, reason])

	# Determine if failure should reset entire puzzle or just current stage
	var reset_all_on_fail: bool = solution_data.get("reset_all_on_fail", false)

	if reset_all_on_fail:
		print("MultiStagePuzzle: Failure reset mode - resetting entire puzzle")
		reset_puzzle()
	else:
		# Just reset current stage
		stage_puzzles[stage_index].reset_puzzle()


## Complete all stages
func _complete_all_stages() -> void:
	all_stages_complete.emit()
	print("MultiStagePuzzle: All %d stages completed!" % stages.size())

	# Solve the multi-stage puzzle
	solve_puzzle()


## Check if puzzle solution is correct
func check_solution() -> bool:
	# All stages must be completed
	return completed_stages.size() == stages.size()


## Reset puzzle to initial state
func _on_puzzle_reset() -> void:
	current_stage_index = 0
	completed_stages.clear()

	# Reset all stage puzzles
	for puzzle in stage_puzzles:
		puzzle.reset_puzzle()
		puzzle.deactivate()
		puzzle.enabled = false

	# Reactivate first stage if puzzle is still active
	if is_active and stages.size() > 0:
		_activate_stage(0)


## Get puzzle progress (0.0 to 1.0)
func get_progress() -> float:
	if is_solved:
		return 1.0

	if stages.is_empty():
		return 0.0

	# Progress based on completed stages plus current stage progress
	var base_progress: float = float(completed_stages.size()) / float(stages.size())

	# Add partial progress from current stage
	if current_stage_index < stage_puzzles.size():
		var current_puzzle: Puzzle = stage_puzzles[current_stage_index]
		var stage_progress: float = current_puzzle.get_progress()
		base_progress += stage_progress / float(stages.size())

	return min(base_progress, 1.0)


## Get current stage info
func get_current_stage_info() -> Dictionary:
	if current_stage_index >= stages.size():
		return {}

	var stage_config: Dictionary = stages[current_stage_index]
	var current_puzzle: Puzzle = stage_puzzles[current_stage_index]

	return {
		"index": current_stage_index,
		"total_stages": stages.size(),
		"type": stage_config.get("type", "unknown"),
		"description": stage_config.get("description", ""),
		"progress": current_puzzle.get_progress(),
		"is_solved": current_puzzle.is_solved
	}


## Get hint for current stage
func get_hint() -> String:
	if current_stage_index >= stage_puzzles.size():
		return "No active stage"

	var current_puzzle: Puzzle = stage_puzzles[current_stage_index]
	var stage_hint: String = current_puzzle.get_hint()

	return "Stage %d/%d: %s" % [current_stage_index + 1, stages.size(), stage_hint]


## Get all stage information
func get_all_stages_info() -> Array[Dictionary]:
	var stages_info: Array[Dictionary] = []

	for i in range(stages.size()):
		var stage_config: Dictionary = stages[i]
		var is_complete: bool = i in completed_stages
		var is_current: bool = i == current_stage_index

		stages_info.append({
			"index": i,
			"type": stage_config.get("type", "unknown"),
			"description": stage_config.get("description", ""),
			"is_complete": is_complete,
			"is_current": is_current
		})

	return stages_info


## Print debug information
func print_debug_info() -> void:
	super.print_debug_info()

	print("═".repeat(60))
	print("Multi-Stage Puzzle Details")
	print("═".repeat(60))
	print("Total Stages: %d" % stages.size())
	print("Current Stage: %d/%d" % [current_stage_index + 1, stages.size()])
	print("Completed Stages: %d" % completed_stages.size())
	print("")
	print("Stage Breakdown:")
	for i in range(stages.size()):
		var stage_config: Dictionary = stages[i]
		var status: String = "✓" if i in completed_stages else ("→" if i == current_stage_index else "○")
		print("  %s Stage %d: %s - %s" % [status, i + 1, stage_config.get("type", ""), stage_config.get("description", "")])
	print("═".repeat(60))
