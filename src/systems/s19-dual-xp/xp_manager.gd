# Godot 4.5 | GDScript 4.5
# System: S19 - Dual XP System
# Created: 2025-11-18
# Dependencies: S04 (Combat), S17 (Puzzles), S06 (Save/Load)
#
# XP Manager handles dual progression paths: Combat XP and Knowledge XP
# Combat XP: From enemy defeats, increases HP/Physical stats
# Knowledge XP: From puzzles/lore/dialogue, increases MP/Special stats

extends Node

class_name XPManagerImpl

## Signals for XP events

## Emitted when combat XP is gained
signal combat_xp_gained(amount: int, source: String)

## Emitted when knowledge XP is gained
signal knowledge_xp_gained(amount: int, source: String)

## Emitted when combat level increases
signal combat_level_up(new_level: int, stat_increases: Dictionary)

## Emitted when knowledge level increases
signal knowledge_level_up(new_level: int, stat_increases: Dictionary)

## Emitted when any XP value changes (for UI updates)
signal xp_changed(combat_xp: int, knowledge_xp: int, combat_level: int, knowledge_level: int)

# ═════════════════════════════════════════════════════════════════════════════
# Combat XP Tracking
# ═════════════════════════════════════════════════════════════════════════════

## Current combat experience points
var combat_xp: int = 0

## Current combat level
var combat_level: int = 1

## Combat XP needed for next level
var combat_xp_required: int = 100

# ═════════════════════════════════════════════════════════════════════════════
# Knowledge XP Tracking
# ═════════════════════════════════════════════════════════════════════════════

## Current knowledge experience points
var knowledge_xp: int = 0

## Current knowledge level
var knowledge_level: int = 1

## Knowledge XP needed for next level
var knowledge_xp_required: int = 100

# ═════════════════════════════════════════════════════════════════════════════
# Configuration
# ═════════════════════════════════════════════════════════════════════════════

## XP configuration loaded from JSON
var xp_config: Dictionary = {}

## Reference to player combatant for stat bonuses
var player_combatant: Node = null

# ═════════════════════════════════════════════════════════════════════════════
# Initialization
# ═════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	_load_xp_config()
	_setup_signal_connections()
	print("XPManager: Dual XP System initialized (Combat Level: %d, Knowledge Level: %d)" % [combat_level, knowledge_level])


## Load XP configuration from JSON
func _load_xp_config() -> void:
	var config_path: String = "res://src/systems/s19-dual-xp/xp_config.json"

	if not FileAccess.file_exists(config_path):
		push_warning("XPManager: xp_config.json not found, using defaults")
		_use_default_xp_config()
		return

	var file: FileAccess = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("XPManager: Failed to open xp_config.json")
		_use_default_xp_config()
		return

	var json_text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_text)

	if parse_result != OK:
		push_error("XPManager: Failed to parse xp_config.json: %s" % json.get_error_message())
		_use_default_xp_config()
		return

	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("XPManager: Invalid JSON format in xp_config.json")
		_use_default_xp_config()
		return

	xp_config = data.get("xp_config", {})

	# Update XP required for current levels
	_update_xp_requirements()


## Use default XP configuration
func _use_default_xp_config() -> void:
	xp_config = {
		"combat_xp": {
			"level_curve": [100, 250, 500, 1000, 2000, 3500, 5500, 8000, 11000, 15000],
			"stat_growth_per_level": {
				"max_hp": 10,
				"physical_attack": 3,
				"physical_defense": 2,
				"speed": 1
			}
		},
		"knowledge_xp": {
			"level_curve": [100, 250, 500, 1000, 2000, 3500, 5500, 8000, 11000, 15000],
			"stat_growth_per_level": {
				"max_mp": 10,
				"special_attack": 3,
				"special_defense": 2,
				"magic_affinity": 1
			}
		},
		"xp_sources": {
			"enemy_defeat_base": 50,
			"puzzle_solved_base": 50,
			"lore_discovered": 100,
			"npc_dialogue": 25,
			"area_discovered": 75
		},
		"bonuses": {
			"perfect_rhythm_combat": 0.25,
			"boss_multiplier": 5.0
		}
	}

	_update_xp_requirements()


## Setup signal connections to combat and puzzle systems
func _setup_signal_connections() -> void:
	# Connect to combat system (S04) - will be connected when CombatManager is available
	# Note: This is handled dynamically when combat encounters occur
	pass


## Update XP requirements based on current levels
func _update_xp_requirements() -> void:
	combat_xp_required = _get_xp_for_level(combat_level, "combat_xp")
	knowledge_xp_required = _get_xp_for_level(knowledge_level, "knowledge_xp")


# ═════════════════════════════════════════════════════════════════════════════
# Combat XP Methods
# ═════════════════════════════════════════════════════════════════════════════

## Add combat XP from enemy defeat
## @param amount: Base XP amount
## @param source: Description of XP source (for feedback)
func add_combat_xp(amount: int, source: String = "Enemy Defeat") -> void:
	if amount <= 0:
		return

	combat_xp += amount
	combat_xp_gained.emit(amount, source)

	# Check for level-up
	_check_combat_level_up()

	# Emit XP changed for UI updates
	xp_changed.emit(combat_xp, knowledge_xp, combat_level, knowledge_level)

	print("XPManager: Gained %d Combat XP from %s (Total: %d/%d)" % [amount, source, combat_xp, combat_xp_required])


## Check if combat XP is sufficient for level-up
func _check_combat_level_up() -> void:
	while combat_xp >= combat_xp_required:
		# Subtract XP for this level
		combat_xp -= combat_xp_required

		# Increase level
		combat_level += 1

		# Update XP required for next level
		combat_xp_required = _get_xp_for_level(combat_level, "combat_xp")

		# Apply stat growth
		var stat_increases: Dictionary = _apply_combat_stat_growth()

		# Emit level-up signal
		combat_level_up.emit(combat_level, stat_increases)

		print("XPManager: COMBAT LEVEL UP! Level %d reached" % combat_level)
		print("XPManager: Stat increases: %s" % str(stat_increases))


## Apply stat bonuses for combat level-up
func _apply_combat_stat_growth() -> Dictionary:
	var growth: Dictionary = xp_config.get("combat_xp", {}).get("stat_growth_per_level", {})
	var stat_increases: Dictionary = {}

	if player_combatant == null:
		# Store for later application when player is set
		return growth

	# Apply stat increases to player
	for stat_name in growth:
		var increase: int = growth[stat_name]
		stat_increases[stat_name] = increase

		match stat_name:
			"max_hp":
				if player_combatant.has("max_hp"):
					player_combatant.max_hp += increase
					player_combatant.current_hp += increase  # Heal on level-up
			"physical_attack":
				if player_combatant.has("attack"):
					player_combatant.attack += increase
			"physical_defense":
				if player_combatant.has("defense"):
					player_combatant.defense += increase
			"speed":
				if player_combatant.has("speed"):
					player_combatant.speed += increase

	return stat_increases


## Calculate XP from enemy defeat
## @param enemy_level: Level of defeated enemy
## @param enemy_base_xp: Base XP value of enemy (from enemy data)
## @param difficulty_multiplier: Multiplier for enemy difficulty
## @param perfect_rhythm: Whether combat had perfect rhythm timing
## @param is_boss: Whether this is a boss enemy
func calculate_combat_xp_reward(
	enemy_level: int,
	enemy_base_xp: int = 0,
	difficulty_multiplier: float = 1.0,
	perfect_rhythm: bool = false,
	is_boss: bool = false
) -> int:
	# Use base XP if enemy_base_xp not provided
	if enemy_base_xp == 0:
		enemy_base_xp = xp_config.get("xp_sources", {}).get("enemy_defeat_base", 50)

	# Calculate base XP: base_xp * enemy_level * difficulty
	var xp: float = float(enemy_base_xp) * float(enemy_level) * difficulty_multiplier

	# Apply perfect rhythm bonus (+25%)
	if perfect_rhythm:
		var rhythm_bonus: float = xp_config.get("bonuses", {}).get("perfect_rhythm_combat", 0.25)
		xp *= (1.0 + rhythm_bonus)

	# Apply boss multiplier (5x)
	if is_boss:
		var boss_multiplier: float = xp_config.get("bonuses", {}).get("boss_multiplier", 5.0)
		xp *= boss_multiplier

	return int(xp)


# ═════════════════════════════════════════════════════════════════════════════
# Knowledge XP Methods
# ═════════════════════════════════════════════════════════════════════════════

## Add knowledge XP from puzzle solving, lore, etc.
## @param amount: XP amount
## @param source: Description of XP source (for feedback)
func add_knowledge_xp(amount: int, source: String = "Discovery") -> void:
	if amount <= 0:
		return

	knowledge_xp += amount
	knowledge_xp_gained.emit(amount, source)

	# Check for level-up
	_check_knowledge_level_up()

	# Emit XP changed for UI updates
	xp_changed.emit(combat_xp, knowledge_xp, combat_level, knowledge_level)

	print("XPManager: Gained %d Knowledge XP from %s (Total: %d/%d)" % [amount, source, knowledge_xp, knowledge_xp_required])


## Check if knowledge XP is sufficient for level-up
func _check_knowledge_level_up() -> void:
	while knowledge_xp >= knowledge_xp_required:
		# Subtract XP for this level
		knowledge_xp -= knowledge_xp_required

		# Increase level
		knowledge_level += 1

		# Update XP required for next level
		knowledge_xp_required = _get_xp_for_level(knowledge_level, "knowledge_xp")

		# Apply stat growth
		var stat_increases: Dictionary = _apply_knowledge_stat_growth()

		# Emit level-up signal
		knowledge_level_up.emit(knowledge_level, stat_increases)

		print("XPManager: KNOWLEDGE LEVEL UP! Level %d reached" % knowledge_level)
		print("XPManager: Stat increases: %s" % str(stat_increases))


## Apply stat bonuses for knowledge level-up
func _apply_knowledge_stat_growth() -> Dictionary:
	var growth: Dictionary = xp_config.get("knowledge_xp", {}).get("stat_growth_per_level", {})
	var stat_increases: Dictionary = {}

	if player_combatant == null:
		# Store for later application when player is set
		return growth

	# Apply stat increases to player
	for stat_name in growth:
		var increase: int = growth[stat_name]
		stat_increases[stat_name] = increase

		match stat_name:
			"max_mp":
				# MP system may be added in future - store for now
				stat_increases["max_mp"] = increase
			"special_attack":
				if player_combatant.has("special_attack"):
					player_combatant.special_attack += increase
			"special_defense":
				if player_combatant.has("special_defense"):
					player_combatant.special_defense += increase
			"magic_affinity":
				# Magic affinity may be added in future - store for now
				stat_increases["magic_affinity"] = increase

	return stat_increases


## Calculate XP from puzzle completion
## @param difficulty: Puzzle difficulty (1-10)
func calculate_puzzle_xp_reward(difficulty: int) -> int:
	var base_xp: int = xp_config.get("xp_sources", {}).get("puzzle_solved_base", 50)
	return difficulty * base_xp


## Grant XP for lore item discovered
func grant_lore_xp() -> void:
	var xp: int = xp_config.get("xp_sources", {}).get("lore_discovered", 100)
	add_knowledge_xp(xp, "Lore Discovered")


## Grant XP for NPC dialogue completion
func grant_dialogue_xp() -> void:
	var xp: int = xp_config.get("xp_sources", {}).get("npc_dialogue", 25)
	add_knowledge_xp(xp, "NPC Dialogue")


## Grant XP for area discovered
func grant_area_xp() -> void:
	var xp: int = xp_config.get("xp_sources", {}).get("area_discovered", 75)
	add_knowledge_xp(xp, "Area Discovered")


# ═════════════════════════════════════════════════════════════════════════════
# Level Curve Calculations
# ═════════════════════════════════════════════════════════════════════════════

## Get XP required to reach a specific level
## @param level: Target level
## @param xp_type: "combat_xp" or "knowledge_xp"
func _get_xp_for_level(level: int, xp_type: String) -> int:
	var curve: Array = xp_config.get(xp_type, {}).get("level_curve", [])

	if curve.is_empty():
		# Fallback exponential curve: 100 * (level ^ 1.5)
		return int(100.0 * pow(float(level), 1.5))

	# Use curve value if available, otherwise extrapolate
	var curve_index: int = level - 1
	if curve_index < curve.size():
		return curve[curve_index]
	else:
		# Extrapolate beyond curve using last growth rate
		var last_xp: int = curve[-1]
		var second_last_xp: int = curve[-2] if curve.size() > 1 else last_xp
		var growth_rate: float = float(last_xp) / float(second_last_xp)

		var extra_levels: int = curve_index - curve.size() + 1
		var extrapolated_xp: float = float(last_xp) * pow(growth_rate, float(extra_levels))

		return int(extrapolated_xp)


## Get progress toward next level as percentage (0.0 to 1.0)
func get_combat_xp_progress() -> float:
	if combat_xp_required <= 0:
		return 1.0
	return float(combat_xp) / float(combat_xp_required)


## Get progress toward next knowledge level as percentage (0.0 to 1.0)
func get_knowledge_xp_progress() -> float:
	if knowledge_xp_required <= 0:
		return 1.0
	return float(knowledge_xp) / float(knowledge_xp_required)


# ═════════════════════════════════════════════════════════════════════════════
# Integration with Combat System (S04)
# ═════════════════════════════════════════════════════════════════════════════

## Connect to enemy defeated signal
## @param enemy: Enemy combatant that was defeated
func on_enemy_defeated(enemy: Node) -> void:
	if enemy == null or not is_instance_valid(enemy):
		return

	# Get enemy properties
	var enemy_level: int = enemy.level if enemy.has("level") else 1
	var enemy_base_xp: int = enemy.base_xp if enemy.has("base_xp") else 0
	var difficulty_multiplier: float = enemy.difficulty_multiplier if enemy.has("difficulty_multiplier") else 1.0
	var is_boss: bool = enemy.is_boss if enemy.has("is_boss") else false

	# Check if combat had perfect rhythm (placeholder for S01 integration)
	var perfect_rhythm: bool = false

	# Calculate and grant XP
	var xp: int = calculate_combat_xp_reward(enemy_level, enemy_base_xp, difficulty_multiplier, perfect_rhythm, is_boss)
	add_combat_xp(xp, "Enemy Defeated")


# ═════════════════════════════════════════════════════════════════════════════
# Integration with Puzzle System (S17)
# ═════════════════════════════════════════════════════════════════════════════

## Connect to puzzle solved signal
## @param puzzle_id: ID of solved puzzle
## @param reward: Reward data from puzzle
func on_puzzle_solved(puzzle_id: String, reward: Dictionary) -> void:
	# Get difficulty from reward or default to 5
	var difficulty: int = reward.get("difficulty", 5)

	# Calculate and grant XP
	var xp: int = calculate_puzzle_xp_reward(difficulty)
	add_knowledge_xp(xp, "Puzzle Solved: %s" % puzzle_id)


# ═════════════════════════════════════════════════════════════════════════════
# Save/Load Integration (S06)
# ═════════════════════════════════════════════════════════════════════════════

## Get save data for this system
func get_save_data() -> Dictionary:
	return {
		"combat_xp": combat_xp,
		"combat_level": combat_level,
		"knowledge_xp": knowledge_xp,
		"knowledge_level": knowledge_level
	}


## Load save data for this system
func load_save_data(save_data: Dictionary) -> void:
	combat_xp = save_data.get("combat_xp", 0)
	combat_level = save_data.get("combat_level", 1)
	knowledge_xp = save_data.get("knowledge_xp", 0)
	knowledge_level = save_data.get("knowledge_level", 1)

	# Update XP requirements
	_update_xp_requirements()

	# Emit XP changed for UI updates
	xp_changed.emit(combat_xp, knowledge_xp, combat_level, knowledge_level)

	print("XPManager: Loaded save data (Combat: Lv%d, Knowledge: Lv%d)" % [combat_level, knowledge_level])


# ═════════════════════════════════════════════════════════════════════════════
# Player Reference Management
# ═════════════════════════════════════════════════════════════════════════════

## Set reference to player combatant for stat bonuses
func set_player_combatant(player: Node) -> void:
	player_combatant = player
	print("XPManager: Player combatant reference set")


# ═════════════════════════════════════════════════════════════════════════════
# Getters
# ═════════════════════════════════════════════════════════════════════════════

## Get complete XP data for UI display
func get_xp_data() -> Dictionary:
	return {
		"combat_xp": combat_xp,
		"combat_xp_required": combat_xp_required,
		"combat_level": combat_level,
		"combat_progress": get_combat_xp_progress(),
		"knowledge_xp": knowledge_xp,
		"knowledge_xp_required": knowledge_xp_required,
		"knowledge_level": knowledge_level,
		"knowledge_progress": get_knowledge_xp_progress()
	}
