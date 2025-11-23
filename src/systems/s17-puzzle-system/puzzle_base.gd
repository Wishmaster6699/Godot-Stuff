# Godot 4.5 | GDScript 4.5
# System: S17 - Puzzle System
# Created: 2025-11-18
# Purpose: Base class for all puzzle types (Environmental, Tool, Item, Rhythm, Physics, Multi-stage)

extends Node2D
class_name Puzzle

## Signals for puzzle events

## Emitted when the puzzle is successfully solved
signal puzzle_solved(puzzle_id: String, reward: Dictionary)

## Emitted when puzzle state changes (partially solved, reset, etc.)
signal puzzle_state_changed(puzzle_id: String, new_state: String)

## Emitted when puzzle fails (wrong input, timeout, etc.)
signal puzzle_failed(puzzle_id: String, reason: String)

## Emitted when puzzle is reset to initial state
signal puzzle_reset(puzzle_id: String)

## Puzzle types
enum PuzzleType {
	ENVIRONMENTAL,    # Push/pull blocks, levers, mirrors
	TOOL_BASED,       # Grapple, laser, roller blades
	ITEM_LOCKED,      # Requires inventory items
	RHYTHMIC,         # Beat sequence timing
	PHYSICS,          # Momentum, gravity, buoyancy
	MULTI_STAGE       # Combination of types
}

# Puzzle configuration
@export var puzzle_id: String = ""
@export var puzzle_type: PuzzleType = PuzzleType.ENVIRONMENTAL
@export var description: String = ""
@export var enabled: bool = true

# Puzzle state
var is_solved: bool = false
var is_active: bool = false
var attempts: int = 0
var max_attempts: int = -1  # -1 = unlimited
var time_limit: float = -1.0  # -1 = no time limit
var time_elapsed: float = 0.0

# Reward configuration (loaded from puzzles.json)
var reward: Dictionary = {}

# Solution tracking
var solution_data: Dictionary = {}
var current_state: Dictionary = {}

# References to game systems (set by parent or loaded from autoload)
var conductor: Node = null  # S01 Conductor for rhythm puzzles
var inventory_manager: Node = null  # S05 Inventory for item-locked puzzles
var tool_manager: Node = null  # S14 Tool Manager for tool-based puzzles


func _ready() -> void:
	if enabled:
		_initialize_puzzle()


## Initialize puzzle - override in subclasses for specific setup
func _initialize_puzzle() -> void:
	# Get references to game systems
	_get_system_references()

	# Load puzzle configuration if puzzle_id is set
	if puzzle_id != "":
		_load_puzzle_config()

	print("Puzzle: Initialized %s (ID: %s)" % [PuzzleType.keys()[puzzle_type], puzzle_id])


## Get references to autoload systems
func _get_system_references() -> void:
	# Get Conductor (S01) - autoload
	if has_node("/root/Conductor"):
		conductor = get_node("/root/Conductor")

	# Get InventoryManager (S05) - may be child of player or autoload
	if has_node("/root/InventoryManager"):
		inventory_manager = get_node("/root/InventoryManager")

	# Get ToolManager (S14) - may be child of player
	# This will be set by the puzzle scene or parent node


## Load puzzle configuration from puzzles.json
func _load_puzzle_config() -> void:
	var config_path: String = "res://data/puzzles.json"

	if not FileAccess.file_exists(config_path):
		push_warning("Puzzle: puzzles.json not found at %s" % config_path)
		return

	var file: FileAccess = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("Puzzle: Failed to open puzzles.json")
		return

	var json_text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_text)

	if parse_result != OK:
		push_error("Puzzle: Failed to parse puzzles.json: %s" % json.get_error_message())
		return

	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Puzzle: Invalid JSON format in puzzles.json")
		return

	var puzzles: Array = data.get("puzzles", [])

	# Find this puzzle's configuration
	for puzzle_config in puzzles:
		if puzzle_config.get("id", "") == puzzle_id:
			_apply_puzzle_config(puzzle_config)
			return

	push_warning("Puzzle: No configuration found for puzzle ID: %s" % puzzle_id)


## Apply puzzle configuration from JSON
func _apply_puzzle_config(config: Dictionary) -> void:
	description = config.get("description", description)
	solution_data = config.get("solution", {})
	reward = config.get("reward", {})
	max_attempts = config.get("max_attempts", -1)
	time_limit = config.get("time_limit_s", -1.0)

	print("Puzzle: Loaded config for %s - %s" % [puzzle_id, description])


## Process method for time-limited puzzles
func _process(delta: float) -> void:
	if not is_active or is_solved:
		return

	# Update time limit if enabled
	if time_limit > 0.0:
		time_elapsed += delta
		if time_elapsed >= time_limit:
			_on_time_limit_exceeded()


## Called when time limit is exceeded
func _on_time_limit_exceeded() -> void:
	print("Puzzle: Time limit exceeded for %s" % puzzle_id)
	fail_puzzle("time_limit_exceeded")
	reset_puzzle()


## Activate the puzzle (start accepting input)
func activate() -> void:
	if is_solved:
		push_warning("Puzzle: Cannot activate solved puzzle %s" % puzzle_id)
		return

	is_active = true
	time_elapsed = 0.0
	puzzle_state_changed.emit(puzzle_id, "activated")
	print("Puzzle: Activated %s" % puzzle_id)


## Deactivate the puzzle (stop accepting input)
func deactivate() -> void:
	is_active = false
	puzzle_state_changed.emit(puzzle_id, "deactivated")
	print("Puzzle: Deactivated %s" % puzzle_id)


## Check if puzzle solution is correct - OVERRIDE IN SUBCLASSES
func check_solution() -> bool:
	push_error("Puzzle: check_solution() must be overridden in subclass")
	return false


## Solve the puzzle (grants rewards)
func solve_puzzle() -> void:
	if is_solved:
		return

	is_solved = true
	is_active = false

	print("Puzzle: SOLVED - %s (%s)" % [puzzle_id, description])

	# Grant rewards
	_grant_rewards()

	# Emit solve signal
	puzzle_solved.emit(puzzle_id, reward)
	puzzle_state_changed.emit(puzzle_id, "solved")


## Fail the puzzle (wrong attempt)
func fail_puzzle(reason: String) -> void:
	attempts += 1

	print("Puzzle: FAILED - %s (Reason: %s, Attempts: %d/%s)" % [
		puzzle_id,
		reason,
		attempts,
		str(max_attempts) if max_attempts > 0 else "unlimited"
	])

	puzzle_failed.emit(puzzle_id, reason)

	# Check if max attempts exceeded
	if max_attempts > 0 and attempts >= max_attempts:
		print("Puzzle: Max attempts exceeded for %s" % puzzle_id)
		reset_puzzle()


## Reset puzzle to initial state - OVERRIDE IN SUBCLASSES for specific reset logic
func reset_puzzle() -> void:
	is_solved = false
	is_active = false
	attempts = 0
	time_elapsed = 0.0
	current_state.clear()

	print("Puzzle: Reset %s" % puzzle_id)
	puzzle_reset.emit(puzzle_id)
	puzzle_state_changed.emit(puzzle_id, "reset")

	# Call subclass-specific reset
	_on_puzzle_reset()


## Override in subclasses for specific reset behavior
func _on_puzzle_reset() -> void:
	pass


## Grant rewards to player
func _grant_rewards() -> void:
	if reward.is_empty():
		return

	print("Puzzle: Granting rewards for %s" % puzzle_id)

	# Grant XP
	if reward.has("xp"):
		var xp_amount: int = reward.get("xp", 0)
		print("  - XP: %d" % xp_amount)
		# TODO: Connect to XP system when implemented

	# Grant items
	if reward.has("item"):
		var item_id: String = reward.get("item", "")
		if inventory_manager != null and inventory_manager.has_method("add_item_by_id"):
			var success: bool = inventory_manager.add_item_by_id(item_id)
			if success:
				print("  - Item: %s (added to inventory)" % item_id)
			else:
				print("  - Item: %s (inventory full!)" % item_id)

	# Grant multiple items
	if reward.has("items"):
		var items: Array = reward.get("items", [])
		for item_id in items:
			if inventory_manager != null and inventory_manager.has_method("add_item_by_id"):
				inventory_manager.add_item_by_id(item_id)
				print("  - Item: %s" % item_id)

	# Unlock door/gate
	if reward.has("unlock"):
		var unlock_target: String = reward.get("unlock", "")
		print("  - Unlock: %s" % unlock_target)
		# TODO: Emit signal for door/gate unlock

	# Custom reward handling
	if reward.has("custom"):
		var custom_reward: Dictionary = reward.get("custom", {})
		_handle_custom_reward(custom_reward)


## Override in subclasses for custom reward handling
func _handle_custom_reward(custom_data: Dictionary) -> void:
	pass


## Get puzzle progress (0.0 to 1.0)
func get_progress() -> float:
	if is_solved:
		return 1.0
	return 0.0


## Get hint for puzzle (if available)
func get_hint() -> String:
	return solution_data.get("hint", "No hint available")


## Get puzzle info as dictionary
func get_puzzle_info() -> Dictionary:
	return {
		"id": puzzle_id,
		"type": PuzzleType.keys()[puzzle_type],
		"description": description,
		"is_solved": is_solved,
		"is_active": is_active,
		"attempts": attempts,
		"max_attempts": max_attempts,
		"time_limit": time_limit,
		"time_elapsed": time_elapsed,
		"progress": get_progress()
	}


## Debug method to print puzzle state
func print_debug_info() -> void:
	print("═".repeat(60))
	print("Puzzle Debug Info: %s" % puzzle_id)
	print("═".repeat(60))
	print("Type: %s" % PuzzleType.keys()[puzzle_type])
	print("Description: %s" % description)
	print("Solved: %s" % is_solved)
	print("Active: %s" % is_active)
	print("Attempts: %d/%s" % [attempts, str(max_attempts) if max_attempts > 0 else "unlimited"])
	if time_limit > 0.0:
		print("Time: %.1f/%.1f seconds" % [time_elapsed, time_limit])
	print("Progress: %.1f%%" % (get_progress() * 100.0))
	print("Reward: %s" % str(reward))
	print("═".repeat(60))
