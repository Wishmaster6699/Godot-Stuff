# Godot 4.5 | GDScript 4.5
# System: S12 - Monster Database
# Created: 2025-11-18
# Dependencies: MonsterResource
# Autoload: MonsterDatabase

extends Node
class_name MonsterDatabaseImpl

## Singleton autoload for managing the monster database
## Loads monsters from JSON and provides query/lookup methods
## Handles type effectiveness calculations

## Signal emitted when monsters finish loading
signal monsters_loaded(count: int)

## Signal emitted when a monster is queried
signal monster_queried(monster_id: String)

## Dictionary mapping monster IDs to MonsterResource instances
var monsters: Dictionary = {}

## Dictionary storing type effectiveness matrix
## Format: type_chart[attacker_type][defender_type] = multiplier
var type_chart: Dictionary = {}

## List of all valid types in the game
var valid_types: Array[String] = []

## Flag indicating if data has been loaded
var is_loaded: bool = false


## Initialize the database on ready
func _ready() -> void:
	_load_type_chart()
	_load_monsters()


## Load the type effectiveness chart from JSON
func _load_type_chart() -> void:
	var data := _load_json("res://data/type_effectiveness.json")
	if data == null:
		push_error("MonsterDatabase: Failed to load type_effectiveness.json")
		return

	type_chart = data.get("type_chart", {})
	valid_types = data.get("types", [])

	print("MonsterDatabase: Loaded type chart with %d types" % valid_types.size())


## Load all monsters from JSON
func _load_monsters() -> void:
	var data := _load_json("res://data/monsters.json")
	if data == null:
		push_error("MonsterDatabase: Failed to load monsters.json")
		return

	var monsters_array: Array = data.get("monsters", [])

	for monster_data in monsters_array:
		var monster := MonsterResource.new()
		monster.from_dict(monster_data)
		monsters[monster.id] = monster

	is_loaded = true
	print("MonsterDatabase: Loaded %d monsters" % monsters.size())
	monsters_loaded.emit(monsters.size())


## Load and parse a JSON file
func _load_json(path: String) -> Variant:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("MonsterDatabase: Failed to open file: " + path)
		return null

	var json_text := file.get_as_text()
	file.close()

	var json := JSON.new()
	var parse_result := json.parse(json_text)
	if parse_result != OK:
		push_error("MonsterDatabase: JSON parse error in " + path)
		return null

	return json.data


## Get a monster by ID
func get_monster(monster_id: String) -> MonsterResource:
	if not is_loaded:
		push_warning("MonsterDatabase: Attempting to get monster before data loaded")
		return null

	monster_queried.emit(monster_id)
	return monsters.get(monster_id)


## Get all monsters
func get_all_monsters() -> Array[MonsterResource]:
	var result: Array[MonsterResource] = []
	for monster in monsters.values():
		result.append(monster)
	return result


## Get monsters by type
func get_monsters_by_type(type: String) -> Array[MonsterResource]:
	var result: Array[MonsterResource] = []

	for monster in monsters.values():
		if monster.has_type(type):
			result.append(monster)

	return result


## Get monsters by evolution stage
func get_monsters_by_stage(stage: int) -> Array[MonsterResource]:
	var result: Array[MonsterResource] = []

	for monster in monsters.values():
		if monster.evolution_stage == stage:
			result.append(monster)

	return result


## Get monsters by AI behavior type
func get_monsters_by_ai_type(ai_type: String) -> Array[MonsterResource]:
	var result: Array[MonsterResource] = []

	for monster in monsters.values():
		if monster.ai_behavior_type == ai_type:
			result.append(monster)

	return result


## Calculate type effectiveness for an attack
## attacker_types: The type(s) of the attacking move/monster
## defender_types: The type(s) of the defending monster
## Returns: Damage multiplier (0.0 = immune, 0.5 = not very effective, 1.0 = neutral, 2.0 = super effective)
func calculate_type_effectiveness(attacker_types: Array[String], defender_types: Array[String]) -> float:
	var effectiveness := 1.0

	for atk_type in attacker_types:
		for def_type in defender_types:
			var modifier := _get_type_modifier(atk_type, def_type)
			effectiveness *= modifier

	return effectiveness


## Get the type effectiveness multiplier for a single type matchup
func _get_type_modifier(attacker_type: String, defender_type: String) -> float:
	if not type_chart.has(attacker_type):
		return 1.0

	var attacker_data: Dictionary = type_chart[attacker_type]

	# Check for immunity
	if defender_type in attacker_data.get("immune", []):
		return 0.0

	# Check for super effective
	if defender_type in attacker_data.get("super_effective", []):
		return 2.0

	# Check for not very effective
	if defender_type in attacker_data.get("not_very_effective", []):
		return 0.5

	# Default: neutral effectiveness
	return 1.0


## Get type effectiveness as a string description
func get_effectiveness_description(effectiveness: float) -> String:
	if effectiveness == 0.0:
		return "No Effect"
	elif effectiveness < 0.5:
		return "Barely Effective"
	elif effectiveness < 1.0:
		return "Not Very Effective"
	elif effectiveness == 1.0:
		return "Neutral"
	elif effectiveness <= 2.0:
		return "Super Effective"
	else:
		return "Extremely Effective"


## Get all evolution chains (monsters grouped by evolution line)
func get_evolution_chains() -> Array[Array]:
	var chains: Array[Array] = []
	var processed: Dictionary = {}

	for monster in monsters.values():
		if monster.id in processed:
			continue

		# Start new chain with stage 1 monsters
		if monster.evolution_stage == 1:
			var chain: Array[MonsterResource] = [monster]
			processed[monster.id] = true

			# Follow evolution chain
			var current := monster
			while current.can_evolve():
				var next_id := current.get_evolution_target()
				var next_monster := get_monster(next_id)

				if next_monster == null:
					break

				chain.append(next_monster)
				processed[next_monster.id] = true
				current = next_monster

			chains.append(chain)

	return chains


## Check if a monster meets evolution requirements
func check_evolution_requirements(monster_id: String, current_level: int, inventory_items: Array = []) -> bool:
	var monster := get_monster(monster_id)
	if monster == null or not monster.can_evolve():
		return false

	var evo_type := monster.get_evolution_type()
	var evo_value = monster.evolution_requirements.get("value")

	match evo_type:
		"level":
			return current_level >= int(evo_value)
		"item":
			return evo_value in inventory_items
		"soul_shard":
			# This will be integrated with S20 Evolution System
			return false
		_:
			return false


## Get monsters sorted by base stat total (BST)
func get_monsters_by_power() -> Array[MonsterResource]:
	var result := get_all_monsters()

	result.sort_custom(func(a: MonsterResource, b: MonsterResource) -> bool:
		return a.get_base_stat_total() > b.get_base_stat_total()
	)

	return result


## Get random monster by evolution stage
func get_random_monster_by_stage(stage: int) -> MonsterResource:
	var monsters_at_stage := get_monsters_by_stage(stage)
	if monsters_at_stage.is_empty():
		return null

	return monsters_at_stage[randi() % monsters_at_stage.size()]


## Get a random monster of a specific type
func get_random_monster_by_type(type: String) -> MonsterResource:
	var type_monsters := get_monsters_by_type(type)
	if type_monsters.is_empty():
		return null

	return type_monsters[randi() % type_monsters.size()]


## Validate that a type exists in the type system
func is_valid_type(type: String) -> bool:
	return type in valid_types


## Get all types that are super effective against a given type
func get_weaknesses(defender_type: String) -> Array[String]:
	var weaknesses: Array[String] = []

	for atk_type in valid_types:
		if _get_type_modifier(atk_type, defender_type) > 1.0:
			weaknesses.append(atk_type)

	return weaknesses


## Get all types that this type is super effective against
func get_strengths(attacker_type: String) -> Array[String]:
	if not type_chart.has(attacker_type):
		return []

	return type_chart[attacker_type].get("super_effective", [])


## Get all types that this type is not very effective against
func get_resistances(attacker_type: String) -> Array[String]:
	if not type_chart.has(attacker_type):
		return []

	return type_chart[attacker_type].get("not_very_effective", [])


## Get debug statistics about the monster database
func get_database_stats() -> Dictionary:
	return {
		"total_monsters": monsters.size(),
		"total_types": valid_types.size(),
		"stage_1_count": get_monsters_by_stage(1).size(),
		"stage_2_count": get_monsters_by_stage(2).size(),
		"stage_3_count": get_monsters_by_stage(3).size(),
		"stage_4_count": get_monsters_by_stage(4).size(),
		"stage_5_count": get_monsters_by_stage(5).size(),
		"evolution_chains": get_evolution_chains().size(),
		"is_loaded": is_loaded
	}
