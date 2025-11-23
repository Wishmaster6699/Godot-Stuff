# Godot 4.5 | GDScript 4.5
# System: S16 - Grind Rail Traversal
# Created: 2025-11-18
# Dependencies: S01 (Conductor), S03 (Player Controller)
#
# Grind Rail system provides Jet Set Radio-style rail grinding with rhythm-based
# balance mechanics. Players must press Left/Right on beat to maintain balance
# and can only jump off on the Conductor's upbeat.

extends Path2D

class_name GrindRail

## Signals for grind rail events

## Emitted when player enters the grind rail
signal player_entered_rail(player: Node2D)

## Emitted when player exits/falls from the grind rail
signal player_exited_rail(player: Node2D, reason: String)

## Emitted when balance changes
signal balance_changed(balance: float, is_in_safe_zone: bool)

## Emitted when player successfully balances on beat
signal balance_success(timing_quality: String)

## Emitted when player misses a balance input
signal balance_miss()

## Emitted when Discord penalty is applied
signal discord_applied(duration: float)

## Emitted when jump is executed
signal jump_executed(force: float, is_perfect: bool)

## Emitted when rail traversal progress updates
signal progress_updated(progress_ratio: float)

# ═════════════════════════════════════════════════════════════════════════════
# Configuration
# ═════════════════════════════════════════════════════════════════════════════

var config: Dictionary = {}

## Rail movement speed (pixels per second)
var rail_speed: float = 200.0

## Balance oscillation speed multiplier
var balance_oscillation_speed: float = 1.0

## Safe zone boundaries (-balance_safe_zone to +balance_safe_zone)
var balance_safe_zone: float = 30.0

## Discord penalty configuration
var discord_stat_reduction: float = 0.2  # 20% stat reduction
var discord_duration: float = 5.0  # Duration in seconds

## Jump timing configuration
var perfect_upbeat_window_ms: float = 50.0  # Perfect timing window
var jump_force_perfect: float = 500.0  # Jump force for perfect timing
var jump_force_miss: float = 250.0  # Jump force for missed timing

# ═════════════════════════════════════════════════════════════════════════════
# State
# ═════════════════════════════════════════════════════════════════════════════

## Current player on the rail (null if no player)
var current_player: Node2D = null

## Is player currently grinding this rail
var is_grinding: bool = false

## Current balance value (-100 to +100)
var current_balance: float = 0.0

## Balance oscillation direction (1 or -1)
var balance_oscillation_direction: float = 1.0

## PathFollow2D node for following the rail curve
var path_follower: PathFollow2D = null

## Reference to Conductor for beat timing
var conductor: Node = null

## Last beat number processed (to detect new beats)
var last_beat_number: int = 0

## Track if player needs to input on this beat
var expecting_input_this_beat: bool = false

## Input timing tracking
var last_input_time: float = 0.0

## Track consecutive missed beats
var consecutive_missed_beats: int = 0

## Max missed beats before falling
const MAX_MISSED_BEATS: int = 3

# ═════════════════════════════════════════════════════════════════════════════
# Initialization
# ═════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Load configuration
	_load_configuration()

	# Get Conductor reference
	if has_node("/root/Conductor"):
		conductor = get_node("/root/Conductor")
		_connect_conductor_signals()
	else:
		push_warning("GrindRail: Conductor autoload not found - rhythm timing disabled")

	# Create PathFollow2D if not exists
	_setup_path_follower()

	print("GrindRail: Initialized at position ", global_position)


## Load configuration from JSON file
func _load_configuration() -> void:
	var config_path: String = "res://data/grind_rail_config.json"

	if not FileAccess.file_exists(config_path):
		push_warning("GrindRail: grind_rail_config.json not found, using defaults")
		_use_default_configuration()
		return

	var file: FileAccess = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("GrindRail: Failed to open grind_rail_config.json")
		_use_default_configuration()
		return

	var json_text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_text)

	if parse_result != OK:
		push_error("GrindRail: Failed to parse grind_rail_config.json: ", json.get_error_message())
		_use_default_configuration()
		return

	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("GrindRail: Invalid JSON format in grind_rail_config.json")
		_use_default_configuration()
		return

	config = data.get("grind_rail_config", {})

	# Apply configuration
	rail_speed = config.get("rail_speed", 200.0)
	balance_oscillation_speed = config.get("balance_oscillation_speed", 1.0)
	balance_safe_zone = config.get("balance_safe_zone", 30.0)

	var discord_config: Dictionary = config.get("discord_penalty", {})
	discord_stat_reduction = discord_config.get("stat_reduction", 0.2)
	discord_duration = discord_config.get("duration_s", 5.0)

	var jump_config: Dictionary = config.get("jump_timing", {})
	perfect_upbeat_window_ms = jump_config.get("perfect_upbeat_window_ms", 50.0)
	jump_force_perfect = jump_config.get("jump_force_perfect", 500.0)
	jump_force_miss = jump_config.get("jump_force_miss", 250.0)

	print("GrindRail: Configuration loaded successfully")


## Use default configuration if JSON loading fails
func _use_default_configuration() -> void:
	rail_speed = 200.0
	balance_oscillation_speed = 1.0
	balance_safe_zone = 30.0
	discord_stat_reduction = 0.2
	discord_duration = 5.0
	perfect_upbeat_window_ms = 50.0
	jump_force_perfect = 500.0
	jump_force_miss = 250.0
	print("GrindRail: Using default configuration")


## Setup PathFollow2D for rail traversal
func _setup_path_follower() -> void:
	# Check if PathFollow2D already exists
	for child in get_children():
		if child is PathFollow2D:
			path_follower = child as PathFollow2D
			print("GrindRail: Found existing PathFollow2D")
			return

	# Create new PathFollow2D if not found
	path_follower = PathFollow2D.new()
	path_follower.name = "RailFollower"
	path_follower.loop = false
	add_child(path_follower)
	print("GrindRail: Created PathFollow2D")


## Connect to Conductor signals
func _connect_conductor_signals() -> void:
	if conductor == null:
		return

	# Connect to beat signal for balance oscillation
	if conductor.has_signal("beat"):
		conductor.beat.connect(_on_conductor_beat)

	# Connect to upbeat signal for jump timing
	if conductor.has_signal("upbeat"):
		conductor.upbeat.connect(_on_conductor_upbeat)


# ═════════════════════════════════════════════════════════════════════════════
# Main Loop
# ═════════════════════════════════════════════════════════════════════════════

func _process(delta: float) -> void:
	if not is_grinding or current_player == null:
		return

	# Update rail progress
	_update_rail_progress(delta)

	# Update balance oscillation
	_update_balance_oscillation(delta)

	# Check if player has fallen off
	_check_balance_failure()

	# Check for jump input
	_check_jump_input()


## Update player progress along the rail
func _update_rail_progress(delta: float) -> void:
	if path_follower == null:
		return

	# Move along the path
	path_follower.progress += rail_speed * delta

	# Update player position if attached
	if current_player != null:
		current_player.global_position = path_follower.global_position

	# Emit progress signal
	var progress_ratio: float = 0.0
	if curve != null and curve.get_baked_length() > 0.0:
		progress_ratio = path_follower.progress / curve.get_baked_length()
	progress_updated.emit(progress_ratio)

	# Check if reached end of rail
	if path_follower.progress_ratio >= 1.0:
		_exit_rail("completed")


## Update balance oscillation based on Conductor tempo
func _update_balance_oscillation(delta: float) -> void:
	# Get BPM from Conductor for oscillation speed
	var bpm: float = 120.0  # Default BPM
	if conductor != null and conductor.has_method("get_bpm"):
		bpm = conductor.get_bpm()

	# Calculate oscillation speed based on tempo
	# Oscillation should complete one cycle per measure (4 beats)
	var beats_per_second: float = bpm / 60.0
	var oscillation_rate: float = beats_per_second * balance_oscillation_speed

	# Oscillate balance automatically (player must counteract this)
	current_balance += balance_oscillation_direction * oscillation_rate * delta * 10.0

	# Reverse direction if hitting boundaries
	if current_balance >= 100.0:
		current_balance = 100.0
		balance_oscillation_direction = -1.0
	elif current_balance <= -100.0:
		current_balance = -100.0
		balance_oscillation_direction = 1.0

	# Check if in safe zone
	var is_safe: bool = abs(current_balance) <= balance_safe_zone
	balance_changed.emit(current_balance, is_safe)


## Check if player has failed to maintain balance
func _check_balance_failure() -> void:
	# If balance is outside safe zone, increment miss counter
	if abs(current_balance) > balance_safe_zone:
		# Player is in danger zone but not immediately falling
		# They have a chance to recover on the next beat
		pass

	# Fall off if too many consecutive missed beats
	if consecutive_missed_beats >= MAX_MISSED_BEATS:
		_apply_discord_penalty()
		_exit_rail("balance_failure")


## Check for jump input from player
func _check_jump_input() -> void:
	if current_player == null:
		return

	# Check if jump button pressed (space/A button)
	if Input.is_action_just_pressed("ui_accept") or Input.is_action_just_pressed("jump"):
		_attempt_jump()


# ═════════════════════════════════════════════════════════════════════════════
# Conductor Event Handlers
# ═════════════════════════════════════════════════════════════════════════════

## Handle beat signal from Conductor
func _on_conductor_beat(beat_number: int) -> void:
	if not is_grinding:
		return

	# Check if this is a new beat
	if beat_number != last_beat_number:
		last_beat_number = beat_number
		expecting_input_this_beat = true

		# If player didn't balance on previous beat, increment miss counter
		if beat_number > 1 and abs(current_balance) > balance_safe_zone:
			consecutive_missed_beats += 1
			balance_miss.emit()

			# Apply Discord penalty if too many misses
			if consecutive_missed_beats >= MAX_MISSED_BEATS:
				_apply_discord_penalty()

		print("GrindRail: Beat ", beat_number, " - Balance: ", current_balance, " (Misses: ", consecutive_missed_beats, ")")


## Handle upbeat signal from Conductor (for jump timing)
var _last_upbeat_time: float = 0.0

func _on_conductor_upbeat(beat_number: int) -> void:
	if not is_grinding:
		return

	# Store the time of this upbeat for jump timing checks
	_last_upbeat_time = Time.get_ticks_msec() / 1000.0

	print("GrindRail: Upbeat on beat ", beat_number)


# ═════════════════════════════════════════════════════════════════════════════
# Input Handling
# ═════════════════════════════════════════════════════════════════════════════

func _unhandled_input(event: InputEvent) -> void:
	if not is_grinding or current_player == null:
		return

	# Handle left/right balance inputs
	if event.is_action_pressed("ui_left") or event.is_action_pressed("move_left"):
		_handle_balance_input(-1.0)
	elif event.is_action_pressed("ui_right") or event.is_action_pressed("move_right"):
		_handle_balance_input(1.0)


## Handle balance input from player (direction: -1 for left, +1 for right)
func _handle_balance_input(direction: float) -> void:
	if conductor == null:
		# No rhythm checking, just apply balance
		current_balance += direction * 20.0
		current_balance = clamp(current_balance, -100.0, 100.0)
		return

	# Get timing quality from Conductor
	var input_time: float = Time.get_ticks_msec() / 1000.0
	var timing_quality: String = "miss"

	if conductor.has_method("get_timing_quality"):
		timing_quality = conductor.get_timing_quality(input_time)

	# Apply balance adjustment based on timing
	var adjustment: float = 0.0
	match timing_quality:
		"perfect":
			adjustment = direction * 30.0
			consecutive_missed_beats = 0  # Reset miss counter
		"good":
			adjustment = direction * 20.0
			consecutive_missed_beats = 0  # Reset miss counter
		_:  # miss
			adjustment = direction * 10.0
			consecutive_missed_beats += 1

	current_balance += adjustment
	current_balance = clamp(current_balance, -100.0, 100.0)

	# Emit success signal if good timing
	if timing_quality != "miss":
		balance_success.emit(timing_quality)
	else:
		balance_miss.emit()

	print("GrindRail: Balance input (", direction, ") - Timing: ", timing_quality, " - New balance: ", current_balance)


## Attempt to jump off the rail
func _attempt_jump() -> void:
	if conductor == null:
		# No rhythm checking, just jump with default force
		_execute_jump(jump_force_miss, false)
		return

	# Check if jump is on upbeat
	var current_time: float = Time.get_ticks_msec() / 1000.0
	var time_since_upbeat: float = (current_time - _last_upbeat_time) * 1000.0  # Convert to ms

	# Check if within perfect timing window
	var is_perfect: bool = time_since_upbeat <= perfect_upbeat_window_ms
	var jump_force: float = jump_force_perfect if is_perfect else jump_force_miss

	_execute_jump(jump_force, is_perfect)


## Execute jump with specified force
func _execute_jump(force: float, is_perfect: bool) -> void:
	if current_player == null:
		return

	# Apply jump velocity to player
	if current_player.has_method("set_velocity_external"):
		var jump_velocity: Vector2 = Vector2(0, -force)
		current_player.set_velocity_external(jump_velocity)
	elif current_player is CharacterBody2D:
		var player_body: CharacterBody2D = current_player as CharacterBody2D
		player_body.velocity = Vector2(0, -force)

	# Emit jump signal
	jump_executed.emit(force, is_perfect)

	# Exit the rail
	_exit_rail("jumped")

	print("GrindRail: Jump executed - Force: ", force, " - Perfect: ", is_perfect)


# ═════════════════════════════════════════════════════════════════════════════
# Discord Penalty
# ═════════════════════════════════════════════════════════════════════════════

## Apply Discord status effect penalty
func _apply_discord_penalty() -> void:
	if current_player == null:
		return

	# Check if player has Combatant functionality (status effects)
	if current_player.has_method("apply_status_effect"):
		current_player.apply_status_effect("discord", discord_duration)
		discord_applied.emit(discord_duration)
		print("GrindRail: Discord penalty applied - ", discord_stat_reduction * 100.0, "% stat reduction for ", discord_duration, "s")

	# Apply visual/audio feedback
	_trigger_discord_feedback()


## Trigger visual and audio feedback for Discord penalty
func _trigger_discord_feedback() -> void:
	# This would be connected to visual effects in the scene
	# The MCP agent will set up the visual feedback nodes
	pass


# ═════════════════════════════════════════════════════════════════════════════
# Rail Entry/Exit
# ═════════════════════════════════════════════════════════════════════════════

## Called when player enters the grind rail
func enter_rail(player: Node2D) -> void:
	if player == null:
		push_error("GrindRail: Cannot enter rail with null player")
		return

	if is_grinding:
		push_warning("GrindRail: Player already grinding this rail")
		return

	current_player = player
	is_grinding = true
	current_balance = 0.0
	consecutive_missed_beats = 0

	# Reset path progress
	if path_follower != null:
		path_follower.progress = 0.0

	# Position player at start of rail
	if path_follower != null:
		player.global_position = path_follower.global_position

	# Disable normal player movement
	if player.has_method("set_process_mode"):
		# Player movement will be overridden by rail movement
		pass

	player_entered_rail.emit(player)
	print("GrindRail: Player entered rail - ", player.name)


## Called when player exits the grind rail
func _exit_rail(reason: String) -> void:
	if not is_grinding or current_player == null:
		return

	var player: Node2D = current_player

	# Reset state
	is_grinding = false
	current_player = null
	current_balance = 0.0
	consecutive_missed_beats = 0

	# Re-enable normal player movement
	# Player controller will resume normal input handling

	player_exited_rail.emit(player, reason)
	print("GrindRail: Player exited rail - Reason: ", reason)


# ═════════════════════════════════════════════════════════════════════════════
# Public API
# ═════════════════════════════════════════════════════════════════════════════

## Check if a player is currently grinding this rail
func is_player_grinding() -> bool:
	return is_grinding


## Get current balance value
func get_balance() -> float:
	return current_balance


## Get balance safe zone range
func get_safe_zone() -> float:
	return balance_safe_zone


## Check if balance is currently in safe zone
func is_balance_safe() -> bool:
	return abs(current_balance) <= balance_safe_zone


## Get current progress along the rail (0.0 to 1.0)
func get_progress_ratio() -> float:
	if path_follower == null:
		return 0.0
	return path_follower.progress_ratio


## Get current player on the rail (null if none)
func get_current_player() -> Node2D:
	return current_player


## Force exit from rail (for external events)
func force_exit(reason: String = "forced") -> void:
	_exit_rail(reason)
