# Godot 4.5 | GDScript 4.5
# System: S14 - Tool System - Roller Blades
# Created: 2025-11-18
# Dependencies: S03 (Player Controller), S01 (Conductor), tool_manager.gd
# Purpose: Roller blades tool with speed boost and rhythm balance mini-game

extends Node2D

class_name RollerBlades

## Signals for roller blade events

## Emitted when roller blades are activated
signal blades_activated()

## Emitted when roller blades are deactivated
signal blades_deactivated()

## Emitted when skating on rough terrain
signal rough_terrain_entered()

## Emitted when leaving rough terrain
signal rough_terrain_exited()

## Emitted when balance mini-game starts
signal balance_challenge_started()

## Emitted when balance mini-game succeeds
signal balance_challenge_success()

## Emitted when balance mini-game fails
signal balance_challenge_failed()

# Tool states
enum State {
	INACTIVE,
	SKATING,
	BALANCING,
	STUMBLED
}

# Configuration
var config: Dictionary = {}
var speed_multiplier: float = 2.0
var balance_difficulty: float = 0.3  # 0.0 to 1.0
var balance_window: float = 0.15  # Timing window for balance inputs
var stumble_duration: float = 1.0  # Time to recover from failed balance

# State
var current_state: State = State.INACTIVE
var is_active: bool = false
var is_skating: bool = false
var on_rough_terrain: bool = false

# Balance mini-game
var balance_required: bool = false
var balance_score: float = 0.0  # 0.0 to 1.0
var balance_input_timer: float = 0.0
var balance_beat_count: int = 0
var balance_success_threshold: float = 0.7

# Speed boost
var original_speed: float = 0.0
var boosted_speed: float = 0.0

# References
var player: PlayerController = null
var tool_manager: Node = null
var conductor: Node = null

# Stumble recovery
var stumble_timer: float = 0.0

func _ready() -> void:
	visible = false

func initialize(player_ref: PlayerController, tool_config: Dictionary) -> void:
	"""Initialize the roller blades with player reference and configuration"""
	player = player_ref
	config = tool_config

	# Load config values
	speed_multiplier = config.get("speed_multiplier", 2.0) as float
	balance_difficulty = config.get("balance_difficulty", 0.3) as float

	# Calculate balance parameters based on difficulty
	balance_window = 0.2 - (balance_difficulty * 0.1)  # Smaller window = harder
	balance_success_threshold = 0.6 + (balance_difficulty * 0.2)  # Higher threshold = harder

	# Get tool manager reference
	tool_manager = get_parent()

	# Get conductor reference for rhythm mechanics
	if has_node("/root/Conductor"):
		conductor = get_node("/root/Conductor")

	print("RollerBlades: Initialized (speed: %.1fx, difficulty: %.1f)" % [speed_multiplier, balance_difficulty])

func _process(delta: float) -> void:
	"""Update roller blade state"""
	if not is_active:
		return

	_update_state(delta)
	_update_terrain_detection()

func _update_state(delta: float) -> void:
	"""Update roller blade state machine"""
	match current_state:
		State.SKATING:
			_update_skating(delta)
		State.BALANCING:
			_update_balancing(delta)
		State.STUMBLED:
			_update_stumbled(delta)

func _update_skating(delta: float) -> void:
	"""Update skating state"""
	if is_skating:
		# Check for rough terrain
		if on_rough_terrain and not balance_required:
			_start_balance_challenge()

func _update_balancing(delta: float) -> void:
	"""Update balance mini-game"""
	if not balance_required:
		return

	# Update input timer
	balance_input_timer += delta

	# Check for balance input (rhythmic button presses)
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump"):
		_handle_balance_input()

	# Auto-fail after too long without input
	if balance_input_timer > 2.0:
		_fail_balance_challenge()

func _update_stumbled(delta: float) -> void:
	"""Update stumbled recovery state"""
	stumble_timer -= delta
	if stumble_timer <= 0.0:
		_recover_from_stumble()

func _update_terrain_detection() -> void:
	"""Detect if player is on rough terrain"""
	# This would use raycasts or area detection in a full implementation
	# For now, we'll use a simple placeholder that can be triggered by terrain
	# The actual terrain detection would be done by the MCP agent in Tier 2
	pass

func _start_balance_challenge() -> void:
	"""Start the rhythm balance mini-game"""
	current_state = State.BALANCING
	balance_required = true
	balance_score = 0.0
	balance_input_timer = 0.0
	balance_beat_count = 0
	balance_challenge_started.emit()
	print("RollerBlades: Balance challenge started!")

func _handle_balance_input() -> void:
	"""Handle player input during balance challenge"""
	if not balance_required:
		return

	# Check timing with conductor if available
	var timing_quality = 1.0
	if conductor != null and conductor.has_method("get_timing_quality"):
		timing_quality = conductor.call("get_timing_quality")
	else:
		# Fallback: simple timing check
		var time_since_beat = fmod(balance_input_timer, 0.5)
		if time_since_beat < balance_window or time_since_beat > (0.5 - balance_window):
			timing_quality = 1.0
		else:
			timing_quality = 0.3

	# Update balance score
	balance_score += timing_quality * 0.25
	balance_beat_count += 1
	balance_input_timer = 0.0

	print("RollerBlades: Balance input (quality: %.2f, score: %.2f)" % [timing_quality, balance_score])

	# Check if challenge is complete
	if balance_beat_count >= 4:
		if balance_score >= balance_success_threshold:
			_succeed_balance_challenge()
		else:
			_fail_balance_challenge()

func _succeed_balance_challenge() -> void:
	"""Handle successful balance challenge"""
	balance_required = false
	current_state = State.SKATING
	balance_challenge_success.emit()
	print("RollerBlades: Balance challenge SUCCESS!")

func _fail_balance_challenge() -> void:
	"""Handle failed balance challenge"""
	balance_required = false
	current_state = State.STUMBLED
	stumble_timer = stumble_duration
	balance_challenge_failed.emit()
	_disable_speed_boost()
	print("RollerBlades: Balance challenge FAILED! Stumbled.")

func _recover_from_stumble() -> void:
	"""Recover from stumble and return to skating"""
	current_state = State.SKATING
	_enable_speed_boost()
	print("RollerBlades: Recovered from stumble")

func _enable_speed_boost() -> void:
	"""Apply speed boost to player"""
	if player == null:
		return

	# Store original speed
	original_speed = player.walk_speed

	# Apply speed boost
	boosted_speed = original_speed * speed_multiplier
	player.walk_speed = boosted_speed
	player.run_speed = boosted_speed * 1.5

	print("RollerBlades: Speed boost enabled (%.1f -> %.1f)" % [original_speed, boosted_speed])

func _disable_speed_boost() -> void:
	"""Remove speed boost from player"""
	if player == null:
		return

	# Restore original speed
	if original_speed > 0.0:
		player.walk_speed = original_speed
		player.run_speed = original_speed * 2.0

	print("RollerBlades: Speed boost disabled")

func _check_terrain_roughness() -> bool:
	"""Check if current terrain is rough (requires balance)"""
	# This would be implemented with tilemap checks or area detection
	# For now, return false as a placeholder
	# The MCP agent will set up proper terrain detection in Tier 2
	return false

## Public API Methods

func activate() -> void:
	"""Called when this tool is selected"""
	is_active = true
	visible = true
	current_state = State.SKATING
	is_skating = true
	_enable_speed_boost()
	blades_activated.emit()
	print("RollerBlades: Activated")

func deactivate() -> void:
	"""Called when this tool is deselected"""
	is_active = false
	visible = false
	is_skating = false
	balance_required = false
	_disable_speed_boost()
	current_state = State.INACTIVE
	blades_deactivated.emit()
	print("RollerBlades: Deactivated")

func use() -> void:
	"""Use the roller blades - toggle skating"""
	if not is_active:
		return

	# Roller blades are passive, but this could trigger a speed burst
	if current_state == State.SKATING:
		print("RollerBlades: Already skating")
	elif current_state == State.STUMBLED:
		print("RollerBlades: Cannot use - stumbled!")

func enter_rough_terrain() -> void:
	"""Called when player enters rough terrain"""
	if not is_active or not is_skating:
		return

	on_rough_terrain = true
	rough_terrain_entered.emit()
	print("RollerBlades: Entered rough terrain")

func exit_rough_terrain() -> void:
	"""Called when player exits rough terrain"""
	on_rough_terrain = false
	rough_terrain_exited.emit()
	print("RollerBlades: Exited rough terrain")

func is_speed_boosted() -> bool:
	"""Check if speed boost is currently active"""
	return is_skating and current_state != State.STUMBLED

func get_balance_score() -> float:
	"""Get current balance score"""
	return balance_score

func is_balancing() -> bool:
	"""Check if currently in balance mini-game"""
	return current_state == State.BALANCING

func get_speed_multiplier() -> float:
	"""Get the speed multiplier value"""
	return speed_multiplier
