# Godot 4.5 | GDScript 4.5
# System: S12 - Monster Database - Evolution System
# Created: 2025-11-18
# Dependencies: MonsterDatabase, MonsterResource

extends Node
class_name EvolutionSystem

## Handles monster evolution logic and triggers
## Integrates with MonsterDatabase to manage evolution requirements
## Will integrate with S20 for soul shard evolution

## Signal emitted when a monster successfully evolves
signal monster_evolved(old_monster_id: String, new_monster_id: String, evolution_type: String)

## Signal emitted when evolution is prevented
signal evolution_prevented(monster_id: String, reason: String)

## Reference to MonsterDatabase autoload (set at runtime)
var monster_db: MonsterDatabaseImpl = null


## Initialize the evolution system
func _ready() -> void:
	# Will be connected to MonsterDatabase autoload by Tier 2
	pass


## Set the monster database reference
func set_monster_database(db: MonsterDatabaseImpl) -> void:
	monster_db = db


## Check if a monster can evolve based on current conditions
## Returns a dictionary with: { can_evolve: bool, reason: String, target_id: String }
func can_monster_evolve(monster_id: String, level: int, inventory_items: Array[String] = [], soul_shards: int = 0) -> Dictionary:
	if monster_db == null:
		return {"can_evolve": false, "reason": "Monster database not initialized", "target_id": ""}

	var monster := monster_db.get_monster(monster_id)
	if monster == null:
		return {"can_evolve": false, "reason": "Monster not found", "target_id": ""}

	if not monster.can_evolve():
		return {"can_evolve": false, "reason": "Monster cannot evolve (no evolution data)", "target_id": ""}

	var evo_type := monster.get_evolution_type()
	var evo_value = monster.evolution_requirements.get("value")
	var target_id := monster.get_evolution_target()

	# Check if target monster exists
	if monster_db.get_monster(target_id) == null:
		return {"can_evolve": false, "reason": "Evolution target not found", "target_id": target_id}

	var can_evolve := false
	var reason := ""

	match evo_type:
		"level":
			can_evolve = level >= int(evo_value)
			reason = "Requires level %d (current: %d)" % [int(evo_value), level] if not can_evolve else "Level requirement met"

		"item":
			can_evolve = str(evo_value) in inventory_items
			reason = "Requires item: %s" % evo_value if not can_evolve else "Item requirement met"

		"soul_shard":
			can_evolve = soul_shards >= int(evo_value)
			reason = "Requires %d soul shards (current: %d)" % [int(evo_value), soul_shards] if not can_evolve else "Soul shard requirement met"

		_:
			can_evolve = false
			reason = "Unknown evolution type: %s" % evo_type

	return {
		"can_evolve": can_evolve,
		"reason": reason,
		"target_id": target_id,
		"evolution_type": evo_type
	}


## Attempt to evolve a monster
## Returns the new monster ID on success, empty string on failure
func evolve_monster(monster_id: String, level: int, inventory_items: Array[String] = [], soul_shards: int = 0, consume_item: bool = true) -> String:
	var check_result := can_monster_evolve(monster_id, level, inventory_items, soul_shards)

	if not check_result["can_evolve"]:
		evolution_prevented.emit(monster_id, check_result["reason"])
		return ""

	var new_monster_id: String = check_result["target_id"]
	var evo_type: String = check_result["evolution_type"]

	# Handle item consumption if needed
	if evo_type == "item" and consume_item:
		# This would integrate with S05 Inventory System
		# For now, just emit signal - actual item removal handled by inventory system
		pass

	# Emit evolution success signal
	monster_evolved.emit(monster_id, new_monster_id, evo_type)

	print("EvolutionSystem: %s evolved into %s (via %s)" % [monster_id, new_monster_id, evo_type])

	return new_monster_id


## Get the full evolution chain for a monster
## Returns array of monster IDs in evolution order
func get_evolution_chain(monster_id: String) -> Array[String]:
	if monster_db == null:
		return []

	var chain: Array[String] = []
	var current_monster := monster_db.get_monster(monster_id)

	if current_monster == null:
		return []

	# Find the start of the chain (stage 1)
	var stage_1_id := _find_evolution_start(monster_id)
	var current_id := stage_1_id
	chain.append(current_id)

	# Follow the chain forward
	while true:
		var current := monster_db.get_monster(current_id)
		if current == null or not current.can_evolve():
			break

		current_id = current.get_evolution_target()
		chain.append(current_id)

	return chain


## Find the first stage of an evolution chain
func _find_evolution_start(monster_id: String) -> String:
	var current_id := monster_id
	var visited: Dictionary = {}

	# Walk backwards through evolutions to find stage 1
	while true:
		if current_id in visited:
			# Circular reference detected, return current
			return current_id

		visited[current_id] = true
		var current := monster_db.get_monster(current_id)

		if current == null or current.evolution_stage == 1:
			return current_id

		# Find what evolves into this monster
		var pre_evo := _find_pre_evolution(current_id)
		if pre_evo.is_empty():
			return current_id

		current_id = pre_evo

	return current_id


## Find the monster that evolves into the given monster
func _find_pre_evolution(monster_id: String) -> String:
	for monster in monster_db.get_all_monsters():
		if monster.can_evolve() and monster.get_evolution_target() == monster_id:
			return monster.id
	return ""


## Get all possible evolution paths from a monster
## Some monsters might have branching evolutions (not in current implementation but future-proof)
func get_evolution_paths(monster_id: String) -> Array[Array]:
	var paths: Array[Array] = []
	var chain := get_evolution_chain(monster_id)

	if not chain.is_empty():
		paths.append(chain)

	return paths


## Calculate the level requirement for evolution
func get_level_requirement(monster_id: String) -> int:
	if monster_db == null:
		return -1

	var monster := monster_db.get_monster(monster_id)
	if monster == null or not monster.can_evolve():
		return -1

	if monster.get_evolution_type() == "level":
		return int(monster.evolution_requirements.get("value", -1))

	return -1


## Get the item requirement for evolution
func get_item_requirement(monster_id: String) -> String:
	if monster_db == null:
		return ""

	var monster := monster_db.get_monster(monster_id)
	if monster == null or not monster.can_evolve():
		return ""

	if monster.get_evolution_type() == "item":
		return str(monster.evolution_requirements.get("value", ""))

	return ""


## Get the soul shard requirement for evolution
func get_soul_shard_requirement(monster_id: String) -> int:
	if monster_db == null:
		return -1

	var monster := monster_db.get_monster(monster_id)
	if monster == null or not monster.can_evolve():
		return -1

	if monster.get_evolution_type() == "soul_shard":
		return int(monster.evolution_requirements.get("value", -1))

	return -1


## Get evolution progress as a percentage (for level-based evolutions)
func get_evolution_progress(monster_id: String, current_level: int) -> float:
	var level_req := get_level_requirement(monster_id)

	if level_req <= 0:
		return 0.0

	var progress := float(current_level) / float(level_req)
	return clamp(progress, 0.0, 1.0)


## Get all monsters that can evolve at a specific level
func get_monsters_evolving_at_level(level: int) -> Array[MonsterResource]:
	var result: Array[MonsterResource] = []

	if monster_db == null:
		return result

	for monster in monster_db.get_all_monsters():
		if monster.can_evolve() and monster.get_evolution_type() == "level":
			var req_level := int(monster.evolution_requirements.get("value", 0))
			if req_level == level:
				result.append(monster)

	return result


## Get all monsters that require a specific item to evolve
func get_monsters_evolving_with_item(item_id: String) -> Array[MonsterResource]:
	var result: Array[MonsterResource] = []

	if monster_db == null:
		return result

	for monster in monster_db.get_all_monsters():
		if monster.can_evolve() and monster.get_evolution_type() == "item":
			var req_item := str(monster.evolution_requirements.get("value", ""))
			if req_item == item_id:
				result.append(monster)

	return result


## Get evolution statistics for the database
func get_evolution_stats() -> Dictionary:
	if monster_db == null:
		return {}

	var total_monsters := monster_db.get_all_monsters().size()
	var can_evolve_count := 0
	var level_evo_count := 0
	var item_evo_count := 0
	var shard_evo_count := 0
	var final_forms := 0

	for monster in monster_db.get_all_monsters():
		if monster.can_evolve():
			can_evolve_count += 1
			match monster.get_evolution_type():
				"level":
					level_evo_count += 1
				"item":
					item_evo_count += 1
				"soul_shard":
					shard_evo_count += 1
		else:
			final_forms += 1

	return {
		"total_monsters": total_monsters,
		"can_evolve": can_evolve_count,
		"final_forms": final_forms,
		"level_based": level_evo_count,
		"item_based": item_evo_count,
		"soul_shard_based": shard_evo_count,
		"evolution_chains": monster_db.get_evolution_chains().size()
	}
