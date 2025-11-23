# Godot 4.5 | GDScript 4.5
# System: S20 - Monster Evolution System
# Created: 2025-11-18
# Dependencies: S12 (Monster Database), S04 (Combat), S19 (Dual XP)

extends Node
class_name MonsterEvolutionSystem

## Manages monster evolution with multiple triggers and hybrid stat growth
## Supports level-based, tool-based, and Soul Shard (temporary) evolution
## Integrates with S19 Dual XP System for stat customization based on playstyle

## Emitted when a monster successfully evolves (permanent)
signal evolution_triggered(monster_id: String, new_form: String, evolution_type: String)

## Emitted when evolution completes
signal evolution_complete(monster_id: String)

## Emitted when Soul Shard temporary form is applied
signal soul_shard_applied(monster_id: String, form: String, duration: int)

## Emitted when Soul Shard temporary form reverts
signal soul_shard_reverted(monster_id: String, original_form: String)

## Emitted when evolution is prevented
signal evolution_prevented(monster_id: String, reason: String)

# ═════════════════════════════════════════════════════════════════════════════
# Configuration
# ═════════════════════════════════════════════════════════════════════════════

## Evolution configuration data loaded from JSON
var evolution_config: Dictionary = {}

## Reference to Monster Database (S12)
var monster_database = null

## Reference to XP Manager (S19) for stat growth calculations
var xp_manager = null

# ═════════════════════════════════════════════════════════════════════════════
# Active State Tracking
# ═════════════════════════════════════════════════════════════════════════════

## Tracks active Soul Shard temporary transformations
## Format: { monster_id: { form: String, battles_remaining: int, original_stats: Dictionary } }
var active_soul_shards: Dictionary = {}

## Evolution animations in progress
var evolving_monsters: Dictionary = {}


# ═════════════════════════════════════════════════════════════════════════════
# Initialization
# ═════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	_load_evolution_config()


## Load evolution configuration from JSON
func _load_evolution_config() -> void:
	var config_path := "res://data/evolution_config.json"

	if not FileAccess.file_exists(config_path):
		push_error("MonsterEvolutionSystem: evolution_config.json not found at " + config_path)
		return

	var file := FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("MonsterEvolutionSystem: Failed to open evolution_config.json")
		return

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(json_string)

	if error != OK:
		push_error("MonsterEvolutionSystem: JSON parse error in evolution_config.json at line " + str(json.get_error_line()))
		return

	evolution_config = json.data
	print("MonsterEvolutionSystem: Loaded evolution configuration")


## Set reference to Monster Database (called by Tier 2 setup)
func set_monster_database(db) -> void:
	monster_database = db
	print("MonsterEvolutionSystem: Monster Database reference set")


## Set reference to XP Manager (called by Tier 2 setup)
func set_xp_manager(xp_mgr) -> void:
	xp_manager = xp_mgr
	print("MonsterEvolutionSystem: XP Manager reference set")


# ═════════════════════════════════════════════════════════════════════════════
# Level-Based Evolution (Pokemon-style)
# ═════════════════════════════════════════════════════════════════════════════

## Check if monster can evolve based on level
func check_level_evolution(monster_id: String, level: int) -> bool:
	if not evolution_config.has("level_evolutions"):
		return false

	var level_evolutions: Dictionary = evolution_config.get("level_evolutions", {})

	if not level_evolutions.has(monster_id):
		return false

	var evo_data: Dictionary = level_evolutions[monster_id]
	var required_level: int = evo_data.get("level", 999)

	return level >= required_level


## Get the evolution target for level-based evolution
func get_level_evolution_target(monster_id: String) -> String:
	if not evolution_config.has("level_evolutions"):
		return ""

	var level_evolutions: Dictionary = evolution_config.get("level_evolutions", {})

	if not level_evolutions.has(monster_id):
		return ""

	var evo_data: Dictionary = level_evolutions[monster_id]
	return evo_data.get("evolves_into", "")


## Trigger level-based evolution
func trigger_level_evolution(monster_id: String, level: int, xp_ratio: Dictionary = {}) -> String:
	if not check_level_evolution(monster_id, level):
		evolution_prevented.emit(monster_id, "Level requirement not met")
		return ""

	var new_form := get_level_evolution_target(monster_id)

	if new_form.is_empty():
		evolution_prevented.emit(monster_id, "No evolution target defined")
		return ""

	# Calculate hybrid stats based on XP ratio
	var hybrid_stats := calculate_hybrid_stats(monster_id, xp_ratio)

	# Emit evolution signals
	evolution_triggered.emit(monster_id, new_form, "level")

	# Mark as evolving (animation would play here)
	evolving_monsters[monster_id] = {
		"new_form": new_form,
		"hybrid_stats": hybrid_stats,
		"type": "level"
	}

	# Evolution complete
	evolution_complete.emit(new_form)
	evolving_monsters.erase(monster_id)

	print("MonsterEvolutionSystem: %s evolved into %s (level-based)" % [monster_id, new_form])

	return new_form


# ═════════════════════════════════════════════════════════════════════════════
# Tool-Based Evolution (Hold item + use)
# ═════════════════════════════════════════════════════════════════════════════

## Check if monster can evolve with a specific tool
func check_tool_evolution(monster_id: String, tool_id: String) -> bool:
	if not evolution_config.has("tool_evolutions"):
		return false

	var tool_evolutions: Dictionary = evolution_config.get("tool_evolutions", {})

	if not tool_evolutions.has(monster_id):
		return false

	var evo_data: Dictionary = tool_evolutions[monster_id]
	var required_tool: String = evo_data.get("tool", "")

	return tool_id == required_tool


## Get the evolution target for tool-based evolution
func get_tool_evolution_target(monster_id: String, tool_id: String) -> String:
	if not check_tool_evolution(monster_id, tool_id):
		return ""

	var tool_evolutions: Dictionary = evolution_config.get("tool_evolutions", {})
	var evo_data: Dictionary = tool_evolutions[monster_id]

	return evo_data.get("evolves_into", "")


## Trigger tool-based evolution
func trigger_tool_evolution(monster_id: String, tool_id: String, xp_ratio: Dictionary = {}) -> bool:
	if not check_tool_evolution(monster_id, tool_id):
		evolution_prevented.emit(monster_id, "Tool requirement not met or incorrect tool")
		return false

	var new_form := get_tool_evolution_target(monster_id, tool_id)

	if new_form.is_empty():
		evolution_prevented.emit(monster_id, "No evolution target defined")
		return false

	# Calculate hybrid stats based on XP ratio
	var hybrid_stats := calculate_hybrid_stats(monster_id, xp_ratio)

	# Emit evolution signals
	evolution_triggered.emit(monster_id, new_form, "tool")

	# Mark as evolving
	evolving_monsters[monster_id] = {
		"new_form": new_form,
		"hybrid_stats": hybrid_stats,
		"type": "tool"
	}

	# Evolution complete
	evolution_complete.emit(new_form)
	evolving_monsters.erase(monster_id)

	print("MonsterEvolutionSystem: %s evolved into %s (tool-based with %s)" % [monster_id, new_form, tool_id])

	return true


# ═════════════════════════════════════════════════════════════════════════════
# Soul Shard Evolution (Temporary boss forms)
# ═════════════════════════════════════════════════════════════════════════════

## Apply Soul Shard temporary transformation
func apply_soul_shard(monster_id: String, shard_id: String) -> bool:
	if not evolution_config.has("soul_shards"):
		push_error("MonsterEvolutionSystem: No soul_shards configuration found")
		return false

	var soul_shards: Dictionary = evolution_config.get("soul_shards", {})

	if not soul_shards.has(shard_id):
		evolution_prevented.emit(monster_id, "Soul Shard not found: " + shard_id)
		return false

	var shard_data: Dictionary = soul_shards[shard_id]
	var temp_form: String = shard_data.get("grants_form", "")
	var duration_battles: int = shard_data.get("duration_battles", 3)

	if temp_form.is_empty():
		evolution_prevented.emit(monster_id, "Soul Shard has no form defined")
		return false

	# Save original stats (for reversion)
	var original_stats := _get_monster_stats(monster_id)

	# Apply temporary transformation
	active_soul_shards[monster_id] = {
		"original_id": monster_id,
		"temp_form": temp_form,
		"battles_remaining": duration_battles,
		"original_stats": original_stats,
		"shard_id": shard_id
	}

	# Emit signal
	soul_shard_applied.emit(monster_id, temp_form, duration_battles)

	print("MonsterEvolutionSystem: Soul Shard '%s' applied to %s - temporary form: %s (%d battles)" % [shard_id, monster_id, temp_form, duration_battles])

	return true


## Decrement Soul Shard duration after battle
func decrement_soul_shard_duration(monster_id: String) -> void:
	if not active_soul_shards.has(monster_id):
		return

	var shard_data: Dictionary = active_soul_shards[monster_id]
	shard_data["battles_remaining"] -= 1

	if shard_data["battles_remaining"] <= 0:
		_revert_soul_shard(monster_id)


## Revert Soul Shard temporary form
func _revert_soul_shard(monster_id: String) -> void:
	if not active_soul_shards.has(monster_id):
		return

	var shard_data: Dictionary = active_soul_shards[monster_id]
	var original_id: String = shard_data["original_id"]

	# Restore original stats
	_restore_monster_stats(monster_id, shard_data["original_stats"])

	# Emit reversion signal
	soul_shard_reverted.emit(monster_id, original_id)

	# Remove from active tracking
	active_soul_shards.erase(monster_id)

	print("MonsterEvolutionSystem: Soul Shard temporary form reverted for %s" % monster_id)


## Check if monster has active Soul Shard transformation
func has_active_soul_shard(monster_id: String) -> bool:
	return active_soul_shards.has(monster_id)


## Get Soul Shard data for monster
func get_soul_shard_data(monster_id: String) -> Dictionary:
	return active_soul_shards.get(monster_id, {})


# ═════════════════════════════════════════════════════════════════════════════
# Hybrid Stat Growth (Based on S19 Dual XP Ratios)
# ═════════════════════════════════════════════════════════════════════════════

## Calculate hybrid stats based on XP type ratios from S19
## XP ratio format: { "combat_ratio": float, "knowledge_ratio": float }
## Combat-heavy → Higher Attack/Defense
## Puzzle-heavy → Higher Special Attack/Special Defense
## Balanced → Even distribution
func calculate_hybrid_stats(monster_id: String, xp_ratio: Dictionary) -> Dictionary:
	# Default balanced growth if no XP ratio provided
	var combat_ratio := xp_ratio.get("combat_ratio", 0.5)
	var knowledge_ratio := xp_ratio.get("knowledge_ratio", 0.5)

	# Normalize ratios to ensure they sum to 1.0
	var total := combat_ratio + knowledge_ratio
	if total > 0.0:
		combat_ratio = combat_ratio / total
		knowledge_ratio = knowledge_ratio / total
	else:
		combat_ratio = 0.5
		knowledge_ratio = 0.5

	# Get base stats from monster database (or use defaults)
	var base_stats := _get_monster_base_stats(monster_id)

	# Calculate stat bonuses based on playstyle
	# Combat XP ratio influences physical stats
	var combat_bonus := combat_ratio * 1.5  # Up to +50% bonus for pure combat
	var knowledge_bonus := knowledge_ratio * 1.5  # Up to +50% bonus for pure knowledge

	var hybrid_stats := {
		"max_hp": base_stats.get("max_hp", 100),
		"attack": int(base_stats.get("attack", 10) * (1.0 + combat_bonus)),
		"defense": int(base_stats.get("defense", 5) * (1.0 + combat_bonus)),
		"special_attack": int(base_stats.get("special_attack", 10) * (1.0 + knowledge_bonus)),
		"special_defense": int(base_stats.get("special_defense", 5) * (1.0 + knowledge_bonus)),
		"speed": base_stats.get("speed", 10),
		"combat_ratio": combat_ratio,
		"knowledge_ratio": knowledge_ratio
	}

	return hybrid_stats


## Get base stats for a monster (integrates with S12 Monster Database)
func _get_monster_base_stats(monster_id: String) -> Dictionary:
	if monster_database != null and monster_database.has_method("get_monster"):
		var monster = monster_database.get_monster(monster_id)
		if monster != null:
			return {
				"max_hp": monster.get("max_hp", 100),
				"attack": monster.get("attack", 10),
				"defense": monster.get("defense", 5),
				"special_attack": monster.get("special_attack", 10),
				"special_defense": monster.get("special_defense", 5),
				"speed": monster.get("speed", 10)
			}

	# Default stats if monster database not available
	return {
		"max_hp": 100,
		"attack": 10,
		"defense": 5,
		"special_attack": 10,
		"special_defense": 5,
		"speed": 10
	}


## Get current monster stats (for Soul Shard saving)
func _get_monster_stats(monster_id: String) -> Dictionary:
	# This would integrate with the actual monster instance
	# For now, return base stats
	return _get_monster_base_stats(monster_id)


## Restore monster stats (for Soul Shard reversion)
func _restore_monster_stats(monster_id: String, stats: Dictionary) -> void:
	# This would integrate with the actual monster instance
	# Stats would be restored to the monster object
	print("MonsterEvolutionSystem: Restoring stats for %s" % monster_id)


# ═════════════════════════════════════════════════════════════════════════════
# Utility Functions
# ═════════════════════════════════════════════════════════════════════════════

## Get all available evolution types for a monster
func get_available_evolutions(monster_id: String, level: int, inventory_items: Array = []) -> Array:
	var available := []

	# Check level evolution
	if check_level_evolution(monster_id, level):
		available.append({
			"type": "level",
			"target": get_level_evolution_target(monster_id),
			"requirement": "Level " + str(get_level_requirement(monster_id))
		})

	# Check tool evolutions
	for item in inventory_items:
		if check_tool_evolution(monster_id, item):
			available.append({
				"type": "tool",
				"target": get_tool_evolution_target(monster_id, item),
				"requirement": "Tool: " + item
			})

	return available


## Get level requirement for evolution
func get_level_requirement(monster_id: String) -> int:
	if not evolution_config.has("level_evolutions"):
		return -1

	var level_evolutions: Dictionary = evolution_config.get("level_evolutions", {})

	if not level_evolutions.has(monster_id):
		return -1

	var evo_data: Dictionary = level_evolutions[monster_id]
	return evo_data.get("level", -1)


## Get all available Soul Shards
func get_available_soul_shards() -> Array:
	if not evolution_config.has("soul_shards"):
		return []

	var soul_shards: Dictionary = evolution_config.get("soul_shards", {})
	return soul_shards.keys()


## Get Soul Shard info
func get_soul_shard_info(shard_id: String) -> Dictionary:
	if not evolution_config.has("soul_shards"):
		return {}

	var soul_shards: Dictionary = evolution_config.get("soul_shards", {})
	return soul_shards.get(shard_id, {})


## Get evolution statistics
func get_evolution_stats() -> Dictionary:
	var level_evo_count := 0
	var tool_evo_count := 0
	var soul_shard_count := 0

	if evolution_config.has("level_evolutions"):
		level_evo_count = evolution_config["level_evolutions"].size()

	if evolution_config.has("tool_evolutions"):
		tool_evo_count = evolution_config["tool_evolutions"].size()

	if evolution_config.has("soul_shards"):
		soul_shard_count = evolution_config["soul_shards"].size()

	return {
		"level_evolutions": level_evo_count,
		"tool_evolutions": tool_evo_count,
		"soul_shards": soul_shard_count,
		"active_soul_shards": active_soul_shards.size(),
		"evolving_monsters": evolving_monsters.size()
	}
