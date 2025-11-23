# Godot 4.5 | GDScript 4.5
# System: S04 - Combat Prototype
# Created: 2025-11-18
# Dependencies: S01 (Conductor), S02 (InputManager), S03 (Player), Combatant base class
#
# CombatManager orchestrates 1v1 combat encounters with rhythm integration.
# It manages turn order, enemy AI telegraphs, win/lose conditions, and combat state.
#
# This is the CORE combat system that all future combat features build upon.

extends Node2D

class_name CombatManager

## Signals for combat flow

## Emitted when combat begins
signal combat_started(player: Combatant, enemy: Combatant)

## Emitted when combat ends
signal combat_ended(winner: String, victory_data: Dictionary)

## Emitted when combat state changes
signal combat_state_changed(old_state: String, new_state: String)

## Emitted when player's turn begins
signal player_turn_started()

## Emitted when enemy's turn begins
signal enemy_turn_started()

## Emitted when enemy telegraphs an attack (1 beat warning)
signal enemy_telegraph_started(attack_type: String, target: Combatant)

## Emitted when enemy telegraph ends and attack executes
signal enemy_telegraph_ended()

## Emitted when attack lands (for UI feedback)
signal attack_landed(attacker: Combatant, target: Combatant, damage: int, timing: String)

# ═════════════════════════════════════════════════════════════════════════════
# Combat States
# ═════════════════════════════════════════════════════════════════════════════

enum CombatState {
	IDLE,              ## Not in combat
	INITIALIZING,      ## Setting up combat encounter
	PLAYER_TURN,       ## Player can act
	ENEMY_TURN,        ## Enemy is acting
	ENEMY_TELEGRAPH,   ## Enemy telegraphing attack (1 beat warning)
	RESOLVING,         ## Resolving actions/damage
	VICTORY,           ## Player won
	DEFEAT             ## Player lost
}

## Current combat state
var current_state: CombatState = CombatState.IDLE

## Previous combat state (for transition tracking)
var previous_state: CombatState = CombatState.IDLE

# ═════════════════════════════════════════════════════════════════════════════
# Combat Participants
# ═════════════════════════════════════════════════════════════════════════════

## Player combatant
var player: Combatant = null

## Enemy combatant
var enemy: Combatant = null

# ═════════════════════════════════════════════════════════════════════════════
# Rhythm Integration
# ═════════════════════════════════════════════════════════════════════════════

## Reference to Conductor for rhythm timing
var conductor: Node = null

## Current beat number (tracked for turn timing)
var current_beat: int = 0

## Beats until enemy attack executes (after telegraph)
var beats_until_enemy_attack: int = 0

## Is enemy attack telegraphed
var enemy_attack_telegraphed: bool = false

## Enemy's planned attack (stored during telegraph)
var telegraphed_attack_power: int = 60

# ═════════════════════════════════════════════════════════════════════════════
# Combat Configuration
# ═════════════════════════════════════════════════════════════════════════════

var combat_config: Dictionary = {}

# ═════════════════════════════════════════════════════════════════════════════
# Victory/Defeat Tracking
# ═════════════════════════════════════════════════════════════════════════════

## Combat statistics for victory screen
var combat_stats: Dictionary = {
	"total_damage_dealt": 0,
	"total_damage_taken": 0,
	"perfect_hits": 0,
	"good_hits": 0,
	"missed_hits": 0,
	"dodges_successful": 0,
	"blocks_successful": 0,
	"turns_elapsed": 0,
	"combat_duration": 0.0
}

## Combat start time
var combat_start_time: float = 0.0

# ═════════════════════════════════════════════════════════════════════════════
# Initialization
# ═════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Get Conductor reference
	if has_node("/root/Conductor"):
		conductor = get_node("/root/Conductor")
		# Connect to conductor signals for rhythm timing
		conductor.beat.connect(_on_conductor_beat)
		conductor.downbeat.connect(_on_conductor_downbeat)
	else:
		push_error("CombatManager: Conductor autoload not found - combat system requires rhythm timing!")

	# Load combat configuration
	_load_combat_config()


## Load combat configuration from JSON
func _load_combat_config() -> void:
	var config_path: String = "res://src/systems/s04-combat/combat_config.json"

	if not FileAccess.file_exists(config_path):
		push_warning("CombatManager: combat_config.json not found, using defaults")
		_use_default_config()
		return

	var file: FileAccess = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("CombatManager: Failed to open combat_config.json")
		_use_default_config()
		return

	var json_text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_text)

	if parse_result != OK:
		push_error("CombatManager: Failed to parse combat_config.json: ", json.get_error_message())
		_use_default_config()
		return

	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("CombatManager: Invalid JSON format")
		_use_default_config()
		return

	combat_config = data.get("combat_config", {})


## Use default configuration
func _use_default_config() -> void:
	combat_config = {
		"telegraph": {
			"display_duration_beats": 1,
			"visual_cue_color": "#FFFF00"
		},
		"turn_timing": {
			"player_action_window_beats": 4,
			"enemy_action_interval_beats": 4
		},
		"ai": {
			"attack_variation": 0.2,
			"telegraph_chance": 1.0
		}
	}


# ═════════════════════════════════════════════════════════════════════════════
# Combat Flow Control
# ═════════════════════════════════════════════════════════════════════════════

## Start a combat encounter
## @param player_combatant: Player's combatant
## @param enemy_combatant: Enemy combatant to fight
func start_combat(player_combatant: Combatant, enemy_combatant: Combatant) -> void:
	if player_combatant == null or enemy_combatant == null:
		push_error("CombatManager: Cannot start combat with null combatants")
		return

	if current_state != CombatState.IDLE:
		push_warning("CombatManager: Combat already in progress")
		return

	# Set combatants
	player = player_combatant
	enemy = enemy_combatant

	# Reset combatants for combat
	player.reset_for_combat()
	enemy.reset_for_combat()

	# Connect to combatant signals
	_connect_combatant_signals()

	# Reset combat stats
	_reset_combat_stats()
	combat_start_time = Time.get_ticks_msec() / 1000.0

	# Initialize combat
	_change_state(CombatState.INITIALIZING)

	# Emit combat started signal
	combat_started.emit(player, enemy)

	# Start with player turn
	await get_tree().create_timer(0.5).timeout
	_change_state(CombatState.PLAYER_TURN)


## End the current combat encounter
## @param winner: "player" or "enemy"
func end_combat(winner: String) -> void:
	if current_state == CombatState.IDLE:
		return

	# Calculate combat duration
	var combat_end_time: float = Time.get_ticks_msec() / 1000.0
	combat_stats["combat_duration"] = combat_end_time - combat_start_time

	# Determine victory state
	if winner == "player":
		_change_state(CombatState.VICTORY)
	else:
		_change_state(CombatState.DEFEAT)

	# Prepare victory data
	var victory_data: Dictionary = {
		"winner": winner,
		"stats": combat_stats.duplicate(),
		"player_final_hp": player.current_hp if player else 0,
		"enemy_final_hp": enemy.current_hp if enemy else 0
	}

	# Emit combat ended signal
	combat_ended.emit(winner, victory_data)

	# Disconnect combatant signals
	_disconnect_combatant_signals()

	# Clean up after delay
	await get_tree().create_timer(2.0).timeout
	_cleanup_combat()


## Clean up combat state
func _cleanup_combat() -> void:
	player = null
	enemy = null
	current_beat = 0
	beats_until_enemy_attack = 0
	enemy_attack_telegraphed = false
	_change_state(CombatState.IDLE)


## Change combat state
func _change_state(new_state: CombatState) -> void:
	if new_state == current_state:
		return

	previous_state = current_state
	current_state = new_state

	var old_state_name: String = _state_to_string(previous_state)
	var new_state_name: String = _state_to_string(current_state)

	combat_state_changed.emit(old_state_name, new_state_name)

	# Handle state entry logic
	_on_state_entered(new_state)


## Handle state entry logic
func _on_state_entered(state: CombatState) -> void:
	match state:
		CombatState.PLAYER_TURN:
			player_turn_started.emit()
			combat_stats["turns_elapsed"] += 1

		CombatState.ENEMY_TURN:
			enemy_turn_started.emit()
			_execute_enemy_ai()

		CombatState.ENEMY_TELEGRAPH:
			_start_enemy_telegraph()

		CombatState.VICTORY:
			print("CombatManager: VICTORY! Player wins!")

		CombatState.DEFEAT:
			print("CombatManager: DEFEAT! Enemy wins!")


## Convert state enum to string
func _state_to_string(state: CombatState) -> String:
	match state:
		CombatState.IDLE:
			return "Idle"
		CombatState.INITIALIZING:
			return "Initializing"
		CombatState.PLAYER_TURN:
			return "Player Turn"
		CombatState.ENEMY_TURN:
			return "Enemy Turn"
		CombatState.ENEMY_TELEGRAPH:
			return "Enemy Telegraph"
		CombatState.RESOLVING:
			return "Resolving"
		CombatState.VICTORY:
			return "Victory"
		CombatState.DEFEAT:
			return "Defeat"
		_:
			return "Unknown"


# ═════════════════════════════════════════════════════════════════════════════
# Rhythm Integration (Conductor Signals)
# ═════════════════════════════════════════════════════════════════════════════

## Called every beat by Conductor
func _on_conductor_beat(beat_number: int) -> void:
	current_beat = beat_number

	# Handle enemy telegraph countdown
	if enemy_attack_telegraphed:
		beats_until_enemy_attack -= 1
		if beats_until_enemy_attack <= 0:
			_execute_telegraphed_attack()


## Called every downbeat (measure start) by Conductor
func _on_conductor_downbeat(measure_number: int) -> void:
	# Downbeat is a good time for turn transitions or special events
	pass


# ═════════════════════════════════════════════════════════════════════════════
# Player Actions
# ═════════════════════════════════════════════════════════════════════════════

## Player attacks enemy (called from input/UI)
## @param input_timestamp: Time of input for rhythm evaluation
func player_attack(input_timestamp: float = 0.0) -> void:
	if current_state != CombatState.PLAYER_TURN:
		push_warning("CombatManager: Cannot attack - not player's turn")
		return

	if player == null or enemy == null:
		return

	# Get timing quality from input
	if input_timestamp == 0.0:
		input_timestamp = Time.get_ticks_msec() / 1000.0

	# Execute attack
	var damage: int = player.attack_target(enemy, 60, false, input_timestamp)

	# Get timing quality for stats
	var timing_quality: String = "okay"
	if conductor != null:
		timing_quality = conductor.get_timing_quality(input_timestamp)

	# Update combat stats
	combat_stats["total_damage_dealt"] += damage
	match timing_quality:
		"perfect":
			combat_stats["perfect_hits"] += 1
		"good":
			combat_stats["good_hits"] += 1
		_:
			combat_stats["missed_hits"] += 1

	# Emit attack landed signal
	attack_landed.emit(player, enemy, damage, timing_quality)

	# Check for enemy defeat
	if not enemy.is_alive():
		end_combat("player")
		return

	# Transition to enemy turn
	await get_tree().create_timer(0.5).timeout
	_change_state(CombatState.ENEMY_TURN)


## Player dodges (called from input)
## @param input_timestamp: Time of dodge input
func player_dodge(input_timestamp: float = 0.0) -> void:
	if player == null:
		return

	if input_timestamp == 0.0:
		input_timestamp = Time.get_ticks_msec() / 1000.0

	player.dodge(input_timestamp)
	combat_stats["dodges_successful"] += 1


## Player blocks (called from input)
func player_block() -> void:
	if player == null:
		return

	player.block()
	combat_stats["blocks_successful"] += 1


# ═════════════════════════════════════════════════════════════════════════════
# Enemy AI
# ═════════════════════════════════════════════════════════════════════════════

## Execute enemy AI decision (simplified for prototype)
func _execute_enemy_ai() -> void:
	if enemy == null or player == null:
		return

	# For prototype: Enemy always telegraphs attack
	var telegraph_config: Dictionary = combat_config.get("telegraph", {})
	var telegraph_duration: int = telegraph_config.get("display_duration_beats", 1)

	# Start telegraph
	beats_until_enemy_attack = telegraph_duration
	enemy_attack_telegraphed = true
	telegraphed_attack_power = int(randf_range(40, 80))  # Random attack power

	_change_state(CombatState.ENEMY_TELEGRAPH)


## Start enemy telegraph visual cue
func _start_enemy_telegraph() -> void:
	var telegraph_config: Dictionary = combat_config.get("telegraph", {})
	var attack_type: String = "basic_attack"

	enemy_telegraph_started.emit(attack_type, player)


## Execute the telegraphed attack after countdown
func _execute_telegraphed_attack() -> void:
	if enemy == null or player == null:
		return

	enemy_attack_telegraphed = false
	enemy_telegraph_ended.emit()

	# Enemy attack always happens on-beat (no timing check for AI)
	var damage: int = enemy.attack_target(player, telegraphed_attack_power, false, 0.0)

	# Update combat stats
	combat_stats["total_damage_taken"] += damage

	# Emit attack landed signal
	attack_landed.emit(enemy, player, damage, "good")

	# Check for player defeat
	if not player.is_alive():
		end_combat("enemy")
		return

	# Transition back to player turn
	await get_tree().create_timer(0.5).timeout
	_change_state(CombatState.PLAYER_TURN)


# ═════════════════════════════════════════════════════════════════════════════
# Combatant Signal Handling
# ═════════════════════════════════════════════════════════════════════════════

## Connect to combatant signals
func _connect_combatant_signals() -> void:
	if player != null:
		player.defeated.connect(_on_player_defeated)
		player.health_changed.connect(_on_player_health_changed)

	if enemy != null:
		enemy.defeated.connect(_on_enemy_defeated)
		enemy.health_changed.connect(_on_enemy_health_changed)


## Disconnect from combatant signals
func _disconnect_combatant_signals() -> void:
	if player != null:
		if player.defeated.is_connected(_on_player_defeated):
			player.defeated.disconnect(_on_player_defeated)
		if player.health_changed.is_connected(_on_player_health_changed):
			player.health_changed.disconnect(_on_player_health_changed)

	if enemy != null:
		if enemy.defeated.is_connected(_on_enemy_defeated):
			enemy.defeated.disconnect(_on_enemy_defeated)
		if enemy.health_changed.is_connected(_on_enemy_health_changed):
			enemy.health_changed.disconnect(_on_enemy_health_changed)


## Handle player defeated
func _on_player_defeated(killer: Combatant) -> void:
	end_combat("enemy")


## Handle enemy defeated
func _on_enemy_defeated(killer: Combatant) -> void:
	end_combat("player")


## Handle player health change (for UI updates)
func _on_player_health_changed(current_hp: int, max_hp: int, delta: int) -> void:
	# UI will listen to this via player's signal
	pass


## Handle enemy health change (for UI updates)
func _on_enemy_health_changed(current_hp: int, max_hp: int, delta: int) -> void:
	# UI will listen to this via enemy's signal
	pass


# ═════════════════════════════════════════════════════════════════════════════
# Combat Stats
# ═════════════════════════════════════════════════════════════════════════════

## Reset combat statistics
func _reset_combat_stats() -> void:
	combat_stats = {
		"total_damage_dealt": 0,
		"total_damage_taken": 0,
		"perfect_hits": 0,
		"good_hits": 0,
		"missed_hits": 0,
		"dodges_successful": 0,
		"blocks_successful": 0,
		"turns_elapsed": 0,
		"combat_duration": 0.0
	}


## Get current combat statistics
func get_combat_stats() -> Dictionary:
	return combat_stats.duplicate()


## Get rhythm accuracy percentage
func get_rhythm_accuracy() -> float:
	var total_hits: int = combat_stats["perfect_hits"] + combat_stats["good_hits"] + combat_stats["missed_hits"]
	if total_hits == 0:
		return 0.0

	var good_hits: int = combat_stats["perfect_hits"] + combat_stats["good_hits"]
	return (float(good_hits) / float(total_hits)) * 100.0


# ═════════════════════════════════════════════════════════════════════════════
# Public API
# ═════════════════════════════════════════════════════════════════════════════

## Get current combat state as string
func get_combat_state() -> String:
	return _state_to_string(current_state)


## Check if combat is active
func is_combat_active() -> bool:
	return current_state not in [CombatState.IDLE, CombatState.VICTORY, CombatState.DEFEAT]


## Get current player combatant
func get_player() -> Combatant:
	return player


## Get current enemy combatant
func get_enemy() -> Combatant:
	return enemy
