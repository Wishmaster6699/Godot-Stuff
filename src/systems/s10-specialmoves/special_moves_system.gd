# Godot 4.5 | GDScript 4.5
# System: S10 - Special Moves System
# Created: 2025-11-18
# Dependencies: S01 (Conductor upbeat), S02 (InputManager buffer), S04 (Combat), S07 (Weapons), S09 (Dodge)
#
# SpecialMovesSystem manages powerful rhythm-gated attacks triggered by button combos.
# Special moves can only be executed on Conductor upbeats (beats 2 and 4).
# Each weapon type has unique special moves with resource costs and cooldowns.
#
# This is the FINAL combat system enhancement (S04 → S09 → S10).

extends Node
class_name SpecialMovesSystem

## Signals for special move events

## Emitted when combo is detected (before upbeat validation)
signal combo_detected(combo_pattern: String, move_id: String)

## Emitted when special move execution attempted (may fail if not on upbeat)
signal special_move_attempted(move_id: String, upbeat_active: bool)

## Emitted when special move successfully executes
signal special_move_executed(move_data: Dictionary, damage: int, timing_quality: String)

## Emitted when special move fails (wrong timing, insufficient resources, on cooldown)
signal special_move_failed(move_id: String, reason: String)

## Emitted when cooldown completes for a move
signal cooldown_complete(move_id: String)

## Emitted when resources (stamina/energy) change
signal resources_changed(stamina: int, energy: int)

# ═════════════════════════════════════════════════════════════════════════════
# Configuration (loaded from special_moves_config.json)
# ═════════════════════════════════════════════════════════════════════════════

## Configuration dictionary loaded from JSON
var config: Dictionary = {}

## Combo detection window in milliseconds (time to complete combo)
var combo_window_ms: float = 200.0

## Maximum number of inputs to check in buffer
var max_buffer_check: int = 10

## Upbeat timing window (ms before/after upbeat to allow execution)
var upbeat_window_ms: float = 100.0

# ═════════════════════════════════════════════════════════════════════════════
# Resource System (Stamina from S09 + new Energy resource)
# ═════════════════════════════════════════════════════════════════════════════

## Current player stamina (managed externally by dodge/block system)
var current_stamina: int = 100

## Maximum stamina
var max_stamina: int = 100

## Current energy (special move resource)
var current_energy: int = 50

## Maximum energy
var max_energy: int = 50

## Energy regeneration rate per second
var energy_regen_rate: float = 5.0

## Stamina regeneration rate per second
var stamina_regen_rate: float = 10.0

# ═════════════════════════════════════════════════════════════════════════════
# Special Moves Database
# ═════════════════════════════════════════════════════════════════════════════

## All special moves loaded from JSON
var special_moves: Dictionary = {}

## Available special moves for current weapon type
var available_moves: Array = []

## Currently equipped weapon type (e.g., "sword", "axe", "staff")
var current_weapon_type: String = "sword"

# ═════════════════════════════════════════════════════════════════════════════
# Combo Detection State
# ═════════════════════════════════════════════════════════════════════════════

## Last detected combo pattern
var last_combo_pattern: String = ""

## Last detected move ID
var last_detected_move_id: String = ""

## Timestamp of last combo detection
var last_combo_time: float = 0.0

## Is combo waiting for upbeat execution
var combo_pending: bool = false

# ═════════════════════════════════════════════════════════════════════════════
# Upbeat Gating
# ═════════════════════════════════════════════════════════════════════════════

## Is upbeat window currently active
var upbeat_active: bool = false

## Time when upbeat started (for window calculation)
var upbeat_start_time: float = 0.0

# ═════════════════════════════════════════════════════════════════════════════
# Cooldown Management
# ═════════════════════════════════════════════════════════════════════════════

## Cooldown timers for each move (move_id -> remaining_time)
var move_cooldowns: Dictionary = {}

# ═════════════════════════════════════════════════════════════════════════════
# References
# ═════════════════════════════════════════════════════════════════════════════

## Reference to Conductor for rhythm timing
var conductor: Node = null

## Reference to InputManager for combo detection
var input_manager: Node = null

## Reference to parent combatant (if attached to one)
var combatant: Node = null

## Reference to combat manager (if available)
var combat_manager: Node = null

# ═════════════════════════════════════════════════════════════════════════════
# Initialization
# ═════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Get Conductor reference
	if has_node("/root/Conductor"):
		conductor = get_node("/root/Conductor")
		# Connect to upbeat signal for rhythm gating
		conductor.upbeat.connect(_on_conductor_upbeat)
	else:
		push_error("SpecialMovesSystem: Conductor autoload not found - special moves require rhythm timing!")

	# Get InputManager reference
	if has_node("/root/InputManager"):
		input_manager = get_node("/root/InputManager")
		# Connect to input signals for combo detection
		input_manager.button_pressed.connect(_on_button_pressed)
	else:
		push_warning("SpecialMovesSystem: InputManager autoload not found - combo detection disabled")

	# Get parent combatant reference
	if get_parent() is Combatant:
		combatant = get_parent()
		print("SpecialMovesSystem: Attached to combatant: %s" % combatant.name)

	# Load configuration
	_load_configuration()

	# Load special moves database
	_load_special_moves_database()

	# Update available moves for current weapon
	_update_available_moves()

	print("SpecialMovesSystem: Initialized (%d total moves, %d available for %s)" % [special_moves.size(), available_moves.size(), current_weapon_type])


## Load special moves configuration from JSON file
func _load_configuration() -> void:
	var config_path: String = "res://src/systems/s10-specialmoves/special_moves_config.json"

	if not FileAccess.file_exists(config_path):
		push_warning("SpecialMovesSystem: special_moves_config.json not found at %s, using defaults" % config_path)
		_use_default_configuration()
		return

	var file: FileAccess = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("SpecialMovesSystem: Failed to open special_moves_config.json")
		_use_default_configuration()
		return

	var json_text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_text)

	if parse_result != OK:
		push_error("SpecialMovesSystem: Failed to parse special_moves_config.json: %s" % json.get_error_message())
		_use_default_configuration()
		return

	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("SpecialMovesSystem: Invalid JSON format in special_moves_config.json")
		_use_default_configuration()
		return

	config = data.get("special_moves_config", {})

	# Apply configuration
	combo_window_ms = config.get("combo_window_ms", 200.0)
	max_buffer_check = config.get("max_buffer_check", 10)
	upbeat_window_ms = config.get("upbeat_window_ms", 100.0)
	max_stamina = config.get("max_stamina", 100)
	max_energy = config.get("max_energy", 50)
	energy_regen_rate = config.get("energy_regen_rate", 5.0)
	stamina_regen_rate = config.get("stamina_regen_rate", 10.0)

	# Initialize resources to max
	current_stamina = max_stamina
	current_energy = max_energy


## Use default configuration if JSON loading fails
func _use_default_configuration() -> void:
	config = {
		"combo_window_ms": 200.0,
		"max_buffer_check": 10,
		"upbeat_window_ms": 100.0,
		"max_stamina": 100,
		"max_energy": 50,
		"energy_regen_rate": 5.0,
		"stamina_regen_rate": 10.0
	}

	combo_window_ms = 200.0
	max_buffer_check = 10
	upbeat_window_ms = 100.0
	max_stamina = 100
	max_energy = 50
	energy_regen_rate = 5.0
	stamina_regen_rate = 10.0

	current_stamina = max_stamina
	current_energy = max_energy


## Load special moves database from JSON
func _load_special_moves_database() -> void:
	var database_path: String = "res://data/special_moves.json"

	if not FileAccess.file_exists(database_path):
		push_error("SpecialMovesSystem: special_moves.json not found at %s" % database_path)
		return

	var file: FileAccess = FileAccess.open(database_path, FileAccess.READ)
	if file == null:
		push_error("SpecialMovesSystem: Failed to open special_moves.json")
		return

	var json_text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_text)

	if parse_result != OK:
		push_error("SpecialMovesSystem: Failed to parse special_moves.json: %s" % json.get_error_message())
		return

	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("SpecialMovesSystem: Invalid JSON format in special_moves.json")
		return

	var moves_array: Array = data.get("special_moves", [])

	# Convert array to dictionary keyed by move ID for fast lookup
	for move in moves_array:
		if typeof(move) == TYPE_DICTIONARY:
			var move_id: String = move.get("id", "")
			if move_id != "":
				special_moves[move_id] = move

	print("SpecialMovesSystem: Loaded %d special moves from database" % special_moves.size())


## Update available moves based on current weapon type
func _update_available_moves() -> void:
	available_moves.clear()

	for move_id in special_moves:
		var move: Dictionary = special_moves[move_id]
		var weapon_type: String = move.get("weapon_type", "")

		if weapon_type == current_weapon_type or weapon_type == "all":
			available_moves.append(move)

	print("SpecialMovesSystem: Updated available moves - %d moves for %s" % [available_moves.size(), current_weapon_type])


## Update timers and resource regeneration each frame
func _process(delta: float) -> void:
	# Update cooldown timers
	var completed_cooldowns: Array = []
	for move_id in move_cooldowns:
		move_cooldowns[move_id] -= delta
		if move_cooldowns[move_id] <= 0.0:
			completed_cooldowns.append(move_id)

	# Remove completed cooldowns and emit signals
	for move_id in completed_cooldowns:
		move_cooldowns.erase(move_id)
		cooldown_complete.emit(move_id)

	# Regenerate resources
	_regenerate_resources(delta)

	# Update upbeat window
	if upbeat_active:
		var time_since_upbeat: float = (Time.get_ticks_msec() - upbeat_start_time)
		if time_since_upbeat > upbeat_window_ms:
			upbeat_active = false

	# Check for pending combo execution on upbeat
	if combo_pending and upbeat_active:
		_execute_pending_combo()


## Regenerate stamina and energy over time
func _regenerate_resources(delta: float) -> void:
	var stamina_before: int = current_stamina
	var energy_before: int = current_energy

	# Regenerate stamina
	current_stamina = mini(current_stamina + int(stamina_regen_rate * delta), max_stamina)

	# Regenerate energy
	current_energy = mini(current_energy + int(energy_regen_rate * delta), max_energy)

	# Emit signal if resources changed
	if current_stamina != stamina_before or current_energy != energy_before:
		resources_changed.emit(current_stamina, current_energy)


# ═════════════════════════════════════════════════════════════════════════════
# Rhythm Integration (Conductor Signals)
# ═════════════════════════════════════════════════════════════════════════════

## Called on upbeat (beats 2 and 4) by Conductor
func _on_conductor_upbeat(beat_number: int) -> void:
	upbeat_active = true
	upbeat_start_time = Time.get_ticks_msec()

	# If combo is pending, execute it now
	if combo_pending:
		_execute_pending_combo()


# ═════════════════════════════════════════════════════════════════════════════
# Combo Detection (InputManager Integration)
# ═════════════════════════════════════════════════════════════════════════════

## Called when button is pressed by InputManager
func _on_button_pressed(button: String, lane: int) -> void:
	# Check if a combo is detected
	var detected_move: Dictionary = _detect_combo_from_buffer()

	if not detected_move.is_empty():
		var move_id: String = detected_move.get("id", "")
		var button_combo: Array = detected_move.get("button_combo", [])

		# Convert button combo array to string pattern
		var combo_pattern: String = _array_to_combo_string(button_combo)

		# Store detected combo
		last_combo_pattern = combo_pattern
		last_detected_move_id = move_id
		last_combo_time = Time.get_ticks_msec() / 1000.0
		combo_pending = true

		# Emit combo detected signal
		combo_detected.emit(combo_pattern, move_id)

		print("SpecialMovesSystem: Combo detected - %s (%s)" % [move_id, combo_pattern])


## Detect combo from InputManager buffer
func _detect_combo_from_buffer() -> Dictionary:
	if input_manager == null:
		return {}

	# Get input buffer (assume InputManager has get_input_buffer() method)
	var buffer: Array = []
	if input_manager.has_method("get_input_buffer"):
		buffer = input_manager.get_input_buffer()

	if buffer.is_empty():
		return {}

	# Check each available move's combo pattern
	for move in available_moves:
		var button_combo: Array = move.get("button_combo", [])
		if _matches_combo_pattern(buffer, button_combo):
			return move

	return {}


## Check if input buffer matches a combo pattern
func _matches_combo_pattern(buffer: Array, pattern: Array) -> bool:
	if buffer.size() < pattern.size():
		return false

	# Check if the last N inputs match the pattern (in order)
	var buffer_start: int = buffer.size() - pattern.size()
	var current_time: float = Time.get_ticks_msec()

	for i in range(pattern.size()):
		var buffer_input: Dictionary = buffer[buffer_start + i]
		var expected_button: String = pattern[i]

		# Extract button from buffer input
		var actual_button: String = buffer_input.get("action", "")

		# Check if button matches
		if actual_button != expected_button:
			return false

		# Check if input is within combo window
		var input_time: float = buffer_input.get("timestamp", 0.0)
		var time_diff: float = current_time - input_time

		if time_diff > combo_window_ms:
			return false

	return true


## Convert button combo array to display string
func _array_to_combo_string(combo: Array) -> String:
	var result: String = ""
	for i in range(combo.size()):
		result += combo[i]
		if i < combo.size() - 1:
			result += "+"
	return result


# ═════════════════════════════════════════════════════════════════════════════
# Special Move Execution
# ═════════════════════════════════════════════════════════════════════════════

## Execute pending combo (called when upbeat is active)
func _execute_pending_combo() -> void:
	if not combo_pending:
		return

	combo_pending = false

	# Get move data
	var move: Dictionary = special_moves.get(last_detected_move_id, {})
	if move.is_empty():
		return

	# Attempt to execute the move
	execute_special_move(last_detected_move_id)


## Execute a special move by ID
## @param move_id: ID of special move to execute
## @return bool: True if execution successful, false if failed
func execute_special_move(move_id: String) -> bool:
	# Check if upbeat is active
	if not upbeat_active:
		special_move_failed.emit(move_id, "not_on_upbeat")
		print("SpecialMovesSystem: Move %s failed - not on upbeat" % move_id)
		return false

	# Get move data
	var move: Dictionary = special_moves.get(move_id, {})
	if move.is_empty():
		special_move_failed.emit(move_id, "move_not_found")
		return false

	# Check if move is on cooldown
	if is_move_on_cooldown(move_id):
		special_move_failed.emit(move_id, "on_cooldown")
		print("SpecialMovesSystem: Move %s failed - on cooldown" % move_id)
		return false

	# Check resource costs
	var resource_cost: Dictionary = move.get("resource_cost", {})
	if not _has_sufficient_resources(resource_cost):
		special_move_failed.emit(move_id, "insufficient_resources")
		print("SpecialMovesSystem: Move %s failed - insufficient resources" % move_id)
		return false

	# Deduct resource costs
	_deduct_resources(resource_cost)

	# Calculate damage
	var base_damage: int = 60  # Base attack damage from combatant
	if combatant != null and combatant.has_method("get_attack_power"):
		base_damage = combatant.get_attack_power()

	var damage_multiplier: float = move.get("damage_multiplier", 1.5)
	var final_damage: int = int(base_damage * damage_multiplier)

	# Get timing quality
	var timing_quality: String = "good"
	if conductor != null:
		var current_time: float = Time.get_ticks_msec() / 1000.0
		timing_quality = conductor.get_timing_quality(current_time)

	# Apply timing bonus
	if timing_quality == "perfect":
		final_damage = int(final_damage * 1.2)  # 20% bonus for perfect timing

	# Start cooldown
	var cooldown: float = move.get("cooldown_s", 3.0)
	_start_move_cooldown(move_id, cooldown)

	# Emit execution signal
	special_move_executed.emit(move, final_damage, timing_quality)

	print("SpecialMovesSystem: Executed %s - %d damage (%s timing)" % [move_id, final_damage, timing_quality])

	return true


## Check if player has sufficient resources for move
func _has_sufficient_resources(cost: Dictionary) -> bool:
	var stamina_cost: int = cost.get("stamina", 0)
	var energy_cost: int = cost.get("energy", 0)

	return current_stamina >= stamina_cost and current_energy >= energy_cost


## Deduct resource costs
func _deduct_resources(cost: Dictionary) -> void:
	var stamina_cost: int = cost.get("stamina", 0)
	var energy_cost: int = cost.get("energy", 0)

	current_stamina -= stamina_cost
	current_energy -= energy_cost

	current_stamina = maxi(current_stamina, 0)
	current_energy = maxi(current_energy, 0)

	resources_changed.emit(current_stamina, current_energy)


## Start cooldown for a move
func _start_move_cooldown(move_id: String, cooldown: float) -> void:
	move_cooldowns[move_id] = cooldown


# ═════════════════════════════════════════════════════════════════════════════
# Weapon Integration (S07)
# ═════════════════════════════════════════════════════════════════════════════

## Set current weapon type (updates available moves)
## @param weapon_type: Weapon type string (e.g., "sword", "axe", "staff")
func set_weapon_type(weapon_type: String) -> void:
	if weapon_type == current_weapon_type:
		return

	current_weapon_type = weapon_type
	_update_available_moves()


## Get current weapon type
func get_weapon_type() -> String:
	return current_weapon_type


# ═════════════════════════════════════════════════════════════════════════════
# Public API
# ═════════════════════════════════════════════════════════════════════════════

## Check if a move is on cooldown
## @param move_id: ID of move to check
## @return bool: True if on cooldown
func is_move_on_cooldown(move_id: String) -> bool:
	return move_cooldowns.has(move_id)


## Get cooldown remaining for a move
## @param move_id: ID of move to check
## @return float: Seconds until move is available, 0 if not on cooldown
func get_cooldown_remaining(move_id: String) -> float:
	return move_cooldowns.get(move_id, 0.0)


## Get all available moves for current weapon
## @return Array: Array of move dictionaries
func get_available_moves() -> Array:
	return available_moves.duplicate()


## Get move by ID
## @param move_id: ID of move to get
## @return Dictionary: Move data or empty dict if not found
func get_move(move_id: String) -> Dictionary:
	return special_moves.get(move_id, {})


## Get current resources
## @return Dictionary: {"stamina": int, "energy": int}
func get_resources() -> Dictionary:
	return {
		"stamina": current_stamina,
		"energy": current_energy
	}


## Get max resources
## @return Dictionary: {"stamina": int, "energy": int}
func get_max_resources() -> Dictionary:
	return {
		"stamina": max_stamina,
		"energy": max_energy
	}


## Set resources (for testing or external modification)
func set_resources(stamina: int, energy: int) -> void:
	current_stamina = clampi(stamina, 0, max_stamina)
	current_energy = clampi(energy, 0, max_energy)
	resources_changed.emit(current_stamina, current_energy)


## Check if upbeat window is currently active
func is_upbeat_active() -> bool:
	return upbeat_active


## Reset special moves system (useful for starting new combat)
func reset() -> void:
	combo_pending = false
	last_combo_pattern = ""
	last_detected_move_id = ""
	last_combo_time = 0.0
	upbeat_active = false
	move_cooldowns.clear()

	# Reset resources to max
	current_stamina = max_stamina
	current_energy = max_energy
	resources_changed.emit(current_stamina, current_energy)


# ═════════════════════════════════════════════════════════════════════════════
# Debug / Testing
# ═════════════════════════════════════════════════════════════════════════════

## Print debug information about special moves state
func print_debug_info() -> void:
	print("═".repeat(60))
	print("SpecialMovesSystem Debug Info")
	print("═".repeat(60))
	print("Weapon Type: %s" % current_weapon_type)
	print("Available Moves: %d" % available_moves.size())
	print("Total Moves in Database: %d" % special_moves.size())
	print("")
	print("Resources:")
	print("  Stamina: %d/%d (Regen: %.1f/s)" % [current_stamina, max_stamina, stamina_regen_rate])
	print("  Energy: %d/%d (Regen: %.1f/s)" % [current_energy, max_energy, energy_regen_rate])
	print("")
	print("Upbeat State:")
	print("  Active: %s" % upbeat_active)
	print("  Window: %.0fms" % upbeat_window_ms)
	print("")
	print("Combo Detection:")
	print("  Window: %.0fms" % combo_window_ms)
	print("  Max Buffer Check: %d" % max_buffer_check)
	print("  Combo Pending: %s" % combo_pending)
	print("  Last Detected: %s (%s)" % [last_detected_move_id, last_combo_pattern])
	print("")
	print("Active Cooldowns:")
	if move_cooldowns.is_empty():
		print("  None")
	else:
		for move_id in move_cooldowns:
			print("  %s: %.2fs" % [move_id, move_cooldowns[move_id]])
	print("═".repeat(60))
