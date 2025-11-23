# Godot 4.5 | GDScript 4.5
# System: S11 - Enemy AI System
# Created: 2025-11-18
# Dependencies: S04 (Combat/Combatant), S01 (Conductor), LimboAI plugin
#
# EnemyBase is the base class for all AI-controlled enemies in the game.
# It extends Combatant (from S04) and integrates with LimboAI behavior trees
# for decision-making, state management, and attack telegraphing.

extends Combatant

class_name EnemyBase

## Signals for enemy AI events

## Emitted when enemy changes state
signal state_changed(old_state: String, new_state: String)

## Emitted when enemy detects the player
signal player_detected(player: Node2D)

## Emitted when enemy loses sight of player
signal player_lost()

## Emitted when enemy begins telegraphing an attack
signal attack_telegraph_started(telegraph_duration: float)

## Emitted when telegraphed attack executes
signal attack_telegraph_completed()

# ═════════════════════════════════════════════════════════════════════════════
# AI States
# ═════════════════════════════════════════════════════════════════════════════

## AI state enum
enum AIState {
	PATROL,    ## Wandering random points
	CHASE,     ## Following detected player
	ATTACK,    ## Executing attack
	RETREAT,   ## Low HP, running away
	STUN       ## Hit by stun effect, immobile
}

## Current AI state
var current_state: AIState = AIState.PATROL

## Previous state (for returning after stun/interrupt)
var previous_state: AIState = AIState.PATROL

# ═════════════════════════════════════════════════════════════════════════════
# AI Configuration (loaded from enemy_ai_config.json)
# ═════════════════════════════════════════════════════════════════════════════

var ai_config: Dictionary = {}

## Detection range for player (pixels)
var detection_range: float = 200.0

## Attack range (pixels)
var attack_range: float = 64.0

## HP threshold for retreat (0.0-1.0)
var retreat_hp_threshold: float = 0.2

## Telegraph duration in beats
var telegraph_duration_beats: int = 1

## Difficulty modifiers
var difficulty: String = "normal"
var reaction_time: float = 0.5
var accuracy: float = 0.7

# ═════════════════════════════════════════════════════════════════════════════
# Enemy Type (affects behavior pattern)
# ═════════════════════════════════════════════════════════════════════════════

## Enemy behavior type
enum EnemyType {
	AGGRESSIVE,  ## Always chase, low retreat threshold
	DEFENSIVE,   ## Block more, high retreat threshold
	RANGED,      ## Keep distance, shoot projectiles
	SWARM        ## Call allies when damaged
}

## This enemy's type
var enemy_type: EnemyType = EnemyType.AGGRESSIVE

# ═════════════════════════════════════════════════════════════════════════════
# LimboAI Integration
# ═════════════════════════════════════════════════════════════════════════════

## Reference to BTPlayer node (LimboAI behavior tree player)
var behavior_tree: Node = null

## Blackboard variables for behavior tree
var blackboard: Dictionary = {}

# ═════════════════════════════════════════════════════════════════════════════
# Target Tracking
# ═════════════════════════════════════════════════════════════════════════════

## Current target (usually player)
var target: Node2D = null

## Last known target position
var last_known_target_pos: Vector2 = Vector2.ZERO

## Time since last saw target
var time_since_target_seen: float = 0.0

# ═════════════════════════════════════════════════════════════════════════════
# Patrol State
# ═════════════════════════════════════════════════════════════════════════════

## Current patrol waypoint
var patrol_target: Vector2 = Vector2.ZERO

## Patrol radius (how far to wander from spawn)
var patrol_radius: float = 150.0

## Time until next patrol waypoint
var patrol_timer: float = 0.0

## Patrol interval (seconds between waypoint changes)
var patrol_interval: float = 3.0

# ═════════════════════════════════════════════════════════════════════════════
# Telegraph System (rhythm-synced attack warnings)
# ═════════════════════════════════════════════════════════════════════════════

## Is currently telegraphing an attack
var is_telegraphing: bool = false

## Telegraph timer (counts down to attack execution)
var telegraph_timer: float = 0.0

## Telegraph visual flash node (Sprite2D for red flash effect)
var telegraph_flash: Node2D = null

## Original position (for return after patrol)
var spawn_position: Vector2 = Vector2.ZERO

# ═════════════════════════════════════════════════════════════════════════════
# Movement
# ═════════════════════════════════════════════════════════════════════════════

## Movement speed (pixels per second)
var move_speed: float = 100.0

## Chase speed multiplier
var chase_speed_multiplier: float = 1.5

## Retreat speed multiplier
var retreat_speed_multiplier: float = 1.3

# ═════════════════════════════════════════════════════════════════════════════
# Initialization
# ═════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	super._ready()

	# Store spawn position for patrol
	spawn_position = global_position

	# Load AI configuration
	_load_ai_config()

	# Apply difficulty modifiers
	_apply_difficulty_modifiers()

	# Set initial patrol target
	_pick_new_patrol_target()

	# Find behavior tree node (will be added by MCP agent)
	_find_behavior_tree_node()

	# Find telegraph flash node (will be added by MCP agent)
	_find_telegraph_flash_node()

	# Initialize blackboard variables for LimboAI
	_initialize_blackboard()

	# Connect to stun status effect for state changes
	status_effect_applied.connect(_on_status_effect_applied)
	status_effect_expired.connect(_on_status_effect_expired)

	# Connect to health changes for retreat logic
	health_changed.connect(_on_health_changed)


## Load AI configuration from JSON
func _load_ai_config() -> void:
	var config_path: String = "res://src/systems/s11-enemyai/enemy_ai_config.json"

	if not FileAccess.file_exists(config_path):
		push_warning("EnemyBase: enemy_ai_config.json not found, using defaults")
		_use_default_ai_config()
		return

	var file: FileAccess = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("EnemyBase: Failed to open enemy_ai_config.json")
		_use_default_ai_config()
		return

	var json_text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_text)

	if parse_result != OK:
		push_error("EnemyBase: Failed to parse enemy_ai_config.json: ", json.get_error_message())
		_use_default_ai_config()
		return

	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("EnemyBase: Invalid JSON format in enemy_ai_config.json")
		_use_default_ai_config()
		return

	ai_config = data.get("ai_config", {})

	# Apply config values
	detection_range = ai_config.get("detection_range", 200.0)
	attack_range = ai_config.get("attack_range", 64.0)
	retreat_hp_threshold = ai_config.get("retreat_hp_threshold", 0.2)
	telegraph_duration_beats = ai_config.get("telegraph_duration_beats", 1)


## Use default AI configuration
func _use_default_ai_config() -> void:
	ai_config = {
		"detection_range": 200,
		"attack_range": 64,
		"retreat_hp_threshold": 0.2,
		"telegraph_duration_beats": 1,
		"difficulty_modifiers": {
			"normal": {"reaction_time": 0.5, "accuracy": 0.7},
			"hard": {"reaction_time": 0.3, "accuracy": 0.9},
			"expert": {"reaction_time": 0.1, "accuracy": 1.0}
		}
	}

	detection_range = 200.0
	attack_range = 64.0
	retreat_hp_threshold = 0.2
	telegraph_duration_beats = 1


## Apply difficulty-specific modifiers
func _apply_difficulty_modifiers() -> void:
	var difficulty_modifiers: Dictionary = ai_config.get("difficulty_modifiers", {})
	var current_difficulty: Dictionary = difficulty_modifiers.get(difficulty, {})

	if current_difficulty.is_empty():
		# Default to normal
		current_difficulty = difficulty_modifiers.get("normal", {})

	reaction_time = current_difficulty.get("reaction_time", 0.5)
	accuracy = current_difficulty.get("accuracy", 0.7)


## Find BTPlayer node in children
func _find_behavior_tree_node() -> void:
	behavior_tree = get_node_or_null("BTPlayer")

	if behavior_tree == null:
		push_warning("EnemyBase: BTPlayer node not found - AI will use fallback behavior")
		# Fallback to simple state machine in _physics_process


## Find telegraph flash node
func _find_telegraph_flash_node() -> void:
	telegraph_flash = get_node_or_null("TelegraphFlash")

	if telegraph_flash == null:
		push_warning("EnemyBase: TelegraphFlash node not found - attack telegraphing disabled")


## Initialize blackboard variables for LimboAI behavior tree
func _initialize_blackboard() -> void:
	blackboard = {
		"enemy": self,
		"target": null,
		"detection_range": detection_range,
		"attack_range": attack_range,
		"retreat_hp_threshold": retreat_hp_threshold,
		"current_state": "patrol",
		"patrol_target": patrol_target,
		"spawn_position": spawn_position,
		"is_telegraphing": false,
		"can_attack": true,
		"time_since_target_seen": 0.0
	}

	# If BTPlayer exists and has a blackboard, set variables
	if behavior_tree and behavior_tree.has_method("get_blackboard"):
		var bt_blackboard: Variant = behavior_tree.get_blackboard()
		if bt_blackboard:
			for key in blackboard:
				if bt_blackboard.has_method("set_var"):
					bt_blackboard.set_var(key, blackboard[key])


# ═════════════════════════════════════════════════════════════════════════════
# Physics Process (Movement & State Machine Fallback)
# ═════════════════════════════════════════════════════════════════════════════

func _physics_process(delta: float) -> void:
	# Update blackboard each frame
	_update_blackboard()

	# Update telegraph timer
	if is_telegraphing:
		_update_telegraph(delta)

	# If no behavior tree, use fallback state machine
	if behavior_tree == null or not behavior_tree.has_method("get_blackboard"):
		_fallback_ai_behavior(delta)
		return

	# Move enemy based on current state
	_execute_movement(delta)


## Update blackboard variables each frame
func _update_blackboard() -> void:
	blackboard["target"] = target
	blackboard["current_state"] = _get_state_string(current_state)
	blackboard["patrol_target"] = patrol_target
	blackboard["is_telegraphing"] = is_telegraphing
	blackboard["time_since_target_seen"] = time_since_target_seen

	# Update in BTPlayer blackboard if available
	if behavior_tree and behavior_tree.has_method("get_blackboard"):
		var bt_blackboard: Variant = behavior_tree.get_blackboard()
		if bt_blackboard:
			for key in blackboard:
				if bt_blackboard.has_method("set_var"):
					bt_blackboard.set_var(key, blackboard[key])


## Fallback AI behavior (simple state machine when LimboAI unavailable)
func _fallback_ai_behavior(delta: float) -> void:
	match current_state:
		AIState.PATROL:
			_fallback_patrol_behavior(delta)
		AIState.CHASE:
			_fallback_chase_behavior(delta)
		AIState.ATTACK:
			_fallback_attack_behavior(delta)
		AIState.RETREAT:
			_fallback_retreat_behavior(delta)
		AIState.STUN:
			# Do nothing during stun
			pass


## Fallback patrol behavior
func _fallback_patrol_behavior(delta: float) -> void:
	# Check for player detection
	var player: Node2D = _find_player_in_range()
	if player:
		set_target(player)
		change_state(AIState.CHASE)
		return

	# Move toward patrol target
	var direction: Vector2 = (patrol_target - global_position).normalized()
	velocity = direction * move_speed
	move_and_slide()

	# Check if reached patrol target
	if global_position.distance_to(patrol_target) < 10.0:
		patrol_timer -= delta
		if patrol_timer <= 0.0:
			_pick_new_patrol_target()


## Fallback chase behavior
func _fallback_chase_behavior(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		change_state(AIState.PATROL)
		return

	var distance: float = global_position.distance_to(target.global_position)

	# Check if in attack range
	if distance <= attack_range:
		change_state(AIState.ATTACK)
		return

	# Check if lost sight of player
	if distance > detection_range * 1.5:
		time_since_target_seen += delta
		if time_since_target_seen > 3.0:
			target = null
			change_state(AIState.PATROL)
			return
	else:
		time_since_target_seen = 0.0

	# Move toward target
	var direction: Vector2 = (target.global_position - global_position).normalized()
	velocity = direction * move_speed * chase_speed_multiplier
	move_and_slide()


## Fallback attack behavior
func _fallback_attack_behavior(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		change_state(AIState.PATROL)
		return

	var distance: float = global_position.distance_to(target.global_position)

	# If too far, return to chase
	if distance > attack_range * 1.2:
		change_state(AIState.CHASE)
		return

	# Execute attack with telegraph
	if not is_telegraphing:
		start_attack_telegraph()


## Fallback retreat behavior
func _fallback_retreat_behavior(delta: float) -> void:
	if target == null:
		change_state(AIState.PATROL)
		return

	# Check if HP recovered enough
	if get_hp_percentage() > retreat_hp_threshold + 0.1:
		change_state(AIState.CHASE)
		return

	# Run away from target
	var direction: Vector2 = (global_position - target.global_position).normalized()
	velocity = direction * move_speed * retreat_speed_multiplier
	move_and_slide()


## Execute movement based on current state
func _execute_movement(delta: float) -> void:
	# Movement is handled by behavior tree tasks or fallback AI
	# This is a hook for additional movement processing
	pass


# ═════════════════════════════════════════════════════════════════════════════
# Target Detection & Tracking
# ═════════════════════════════════════════════════════════════════════════════

## Find player within detection range
func _find_player_in_range() -> Node2D:
	# Get all nodes in "player" group (player should be in this group)
	var players: Array[Node] = get_tree().get_nodes_in_group("player")

	for player_node in players:
		if player_node is Node2D:
			var distance: float = global_position.distance_to(player_node.global_position)
			if distance <= detection_range:
				return player_node

	return null


## Set current target
func set_target(new_target: Node2D) -> void:
	if target != new_target:
		target = new_target
		if target:
			last_known_target_pos = target.global_position
			time_since_target_seen = 0.0
			player_detected.emit(target)


## Clear current target
func clear_target() -> void:
	if target:
		target = null
		player_lost.emit()


# ═════════════════════════════════════════════════════════════════════════════
# State Management
# ═════════════════════════════════════════════════════════════════════════════

## Change AI state
func change_state(new_state: AIState) -> void:
	if current_state == new_state:
		return

	var old_state: AIState = current_state
	current_state = new_state

	# Store previous state for resuming after stun
	if new_state != AIState.STUN:
		previous_state = old_state

	state_changed.emit(_get_state_string(old_state), _get_state_string(new_state))


## Get state as string
func _get_state_string(state: AIState) -> String:
	match state:
		AIState.PATROL:
			return "patrol"
		AIState.CHASE:
			return "chase"
		AIState.ATTACK:
			return "attack"
		AIState.RETREAT:
			return "retreat"
		AIState.STUN:
			return "stun"
		_:
			return "unknown"


# ═════════════════════════════════════════════════════════════════════════════
# Patrol System
# ═════════════════════════════════════════════════════════════════════════════

## Pick a new random patrol waypoint
func _pick_new_patrol_target() -> void:
	# Random point within patrol radius from spawn
	var random_offset: Vector2 = Vector2(
		randf_range(-patrol_radius, patrol_radius),
		randf_range(-patrol_radius, patrol_radius)
	)

	patrol_target = spawn_position + random_offset
	patrol_timer = patrol_interval


# ═════════════════════════════════════════════════════════════════════════════
# Telegraph System (rhythm-synced attack warnings)
# ═════════════════════════════════════════════════════════════════════════════

## Start telegraphing an attack (visual cue before damage)
func start_attack_telegraph() -> void:
	if is_telegraphing:
		return

	is_telegraphing = true

	# Calculate telegraph duration from beats
	var beat_duration: float = 60.0 / conductor.get_bpm() if conductor else 0.5
	telegraph_timer = telegraph_duration_beats * beat_duration

	# Start visual telegraph (red flash)
	if telegraph_flash:
		telegraph_flash.visible = true
		if telegraph_flash.has_method("play"):
			telegraph_flash.play("telegraph")

	attack_telegraph_started.emit(telegraph_timer)


## Update telegraph timer
func _update_telegraph(delta: float) -> void:
	telegraph_timer -= delta

	# Pulse telegraph flash
	if telegraph_flash and telegraph_flash is CanvasItem:
		var pulse: float = abs(sin(telegraph_timer * 10.0))
		telegraph_flash.modulate = Color(1.0, 0.0, 0.0, pulse * 0.7)

	# Execute attack when timer expires
	if telegraph_timer <= 0.0:
		_execute_telegraphed_attack()


## Execute the telegraphed attack
func _execute_telegraphed_attack() -> void:
	is_telegraphing = false

	# Hide telegraph flash
	if telegraph_flash:
		telegraph_flash.visible = false

	attack_telegraph_completed.emit()

	# Execute attack on target
	if target and is_instance_valid(target):
		# Apply accuracy modifier
		var hit_roll: float = randf()
		if hit_roll <= accuracy:
			# Hit - calculate attack power based on enemy type
			var attack_power: int = _get_attack_power_for_type()

			if target.has_method("take_damage"):
				attack_target(target, attack_power, false, Time.get_ticks_msec() / 1000.0)
		else:
			# Miss
			pass

	# Return to appropriate state after attack
	if get_hp_percentage() < retreat_hp_threshold:
		change_state(AIState.RETREAT)
	elif target:
		change_state(AIState.CHASE)
	else:
		change_state(AIState.PATROL)


## Get attack power based on enemy type
func _get_attack_power_for_type() -> int:
	match enemy_type:
		EnemyType.AGGRESSIVE:
			return 80  # High damage
		EnemyType.DEFENSIVE:
			return 50  # Medium damage
		EnemyType.RANGED:
			return 60  # Medium damage
		EnemyType.SWARM:
			return 40  # Low damage (compensated by numbers)
		_:
			return 60


# ═════════════════════════════════════════════════════════════════════════════
# Type-Based Behavior Modifiers
# ═════════════════════════════════════════════════════════════════════════════

## Set enemy type and apply modifiers
func set_enemy_type(type: EnemyType) -> void:
	enemy_type = type
	_apply_type_modifiers()


## Apply behavior modifiers based on enemy type
func _apply_type_modifiers() -> void:
	match enemy_type:
		EnemyType.AGGRESSIVE:
			# Always chase, low retreat threshold
			retreat_hp_threshold = 0.1
			chase_speed_multiplier = 1.7
			attack_range = 80.0

		EnemyType.DEFENSIVE:
			# Block more, high retreat threshold
			retreat_hp_threshold = 0.4
			defense += 5
			special_defense += 5
			move_speed = 80.0

		EnemyType.RANGED:
			# Keep distance, longer attack range
			attack_range = 150.0
			detection_range = 250.0
			move_speed = 90.0

		EnemyType.SWARM:
			# Call allies, lower stats but fast
			max_hp = int(max_hp * 0.7)
			current_hp = max_hp
			move_speed = 120.0
			chase_speed_multiplier = 1.6


# ═════════════════════════════════════════════════════════════════════════════
# Event Handlers
# ═════════════════════════════════════════════════════════════════════════════

## Handle status effect applied
func _on_status_effect_applied(effect_name: String, duration: float) -> void:
	if effect_name == "stun":
		change_state(AIState.STUN)


## Handle status effect expired
func _on_status_effect_expired(effect_name: String) -> void:
	if effect_name == "stun":
		# Return to previous state
		change_state(previous_state)


## Handle health changed
func _on_health_changed(current: int, maximum: int, delta: int) -> void:
	# Check retreat threshold
	if get_hp_percentage() < retreat_hp_threshold and current_state != AIState.RETREAT:
		change_state(AIState.RETREAT)

	# Swarm type calls allies when damaged
	if enemy_type == EnemyType.SWARM and delta < 0:
		_call_nearby_allies()


## Call nearby allies (Swarm type behavior)
func _call_nearby_allies() -> void:
	# Get all enemies in scene
	var enemies: Array[Node] = get_tree().get_nodes_in_group("enemy")

	for enemy_node in enemies:
		if enemy_node == self or not is_instance_valid(enemy_node):
			continue

		if enemy_node is EnemyBase:
			var distance: float = global_position.distance_to(enemy_node.global_position)

			# Alert enemies within 300 pixels
			if distance <= 300.0 and enemy_node.target == null:
				enemy_node.set_target(target)
				enemy_node.change_state(AIState.CHASE)


# ═════════════════════════════════════════════════════════════════════════════
# Public API for Behavior Tree Tasks
# ═════════════════════════════════════════════════════════════════════════════

## Check if player is in detection range
func is_player_detected() -> bool:
	return target != null and is_instance_valid(target)


## Check if target is in attack range
func is_in_attack_range() -> bool:
	if target == null or not is_instance_valid(target):
		return false

	return global_position.distance_to(target.global_position) <= attack_range


## Check if should retreat
func should_retreat() -> bool:
	return get_hp_percentage() < retreat_hp_threshold


## Get direction to target
func get_direction_to_target() -> Vector2:
	if target and is_instance_valid(target):
		return (target.global_position - global_position).normalized()
	return Vector2.ZERO


## Get direction away from target
func get_direction_away_from_target() -> Vector2:
	return -get_direction_to_target()


## Get direction to patrol target
func get_direction_to_patrol() -> Vector2:
	return (patrol_target - global_position).normalized()


## Move in direction
func move_in_direction(direction: Vector2, speed_multiplier: float = 1.0) -> void:
	velocity = direction * move_speed * speed_multiplier
	move_and_slide()


## Check if reached patrol target
func is_at_patrol_target() -> bool:
	return global_position.distance_to(patrol_target) < 10.0
