# Godot 4.5 | GDScript 4.5
# System: S12 - Monster Database
# Created: 2025-11-18
# Dependencies: None (data structure only)

extends Resource
class_name MonsterResource

## Monster data resource containing all stats, types, moves, and evolution data
## Used by MonsterDatabase to create monster instances from JSON data

## Unique identifier for this monster (e.g., "001_sparkle")
@export var id: String = ""

## Display name of the monster
@export var monster_name: String = ""

## Type(s) of the monster - can have 1 or 2 types
## Valid types: normal, fire, water, grass, electric, ice, fighting, poison, ground, flying, psychic, dark
@export var types: Array[String] = []

## Evolution stage (1-5)
## Stage 1: Basic form
## Stage 2-4: Intermediate evolutions
## Stage 5: Final form
@export var evolution_stage: int = 1

## Base stats for the monster
## Contains: hp, attack, defense, speed, sp_attack, sp_defense
@export var base_stats: Dictionary = {
	"hp": 0,
	"attack": 0,
	"defense": 0,
	"speed": 0,
	"sp_attack": 0,
	"sp_defense": 0
}

## Array of move IDs this monster can learn
## Move IDs reference moves from the move database
@export var moves: Array[String] = []

## Array of ability IDs this monster has
## Abilities provide passive bonuses or special effects
@export var abilities: Array[String] = []

## AI behavior type from S11 Enemy AI system
## Valid types: aggressive, defensive, ranged, swarm
@export var ai_behavior_type: String = "aggressive"

## Loot table defining what items this monster drops
## Format: {
##   "common": ["item_id1", "item_id2"],
##   "rare": ["rare_item_id"],
##   "drop_chance": 0.3
## }
@export var loot_table: Dictionary = {
	"common": [],
	"rare": [],
	"drop_chance": 0.0
}

## Evolution requirements and target
## Format: {
##   "type": "level" | "item" | "soul_shard",
##   "value": level_number | item_id | shard_count,
##   "evolves_into": "monster_id"
## }
@export var evolution_requirements: Dictionary = {}

## Description text for the monster (flavor text)
@export var description: String = ""

## Encounter rate modifier (0.0 - 1.0)
## Higher = more common encounters
@export var encounter_rate: float = 1.0

## Base experience yield when defeated
@export var exp_yield: int = 0

## Sprite/texture path for the monster
@export var sprite_path: String = ""


## Initialize a monster from a dictionary (loaded from JSON)
func from_dict(data: Dictionary) -> MonsterResource:
	id = data.get("id", "")
	monster_name = data.get("name", "")
	types = data.get("types", [])
	evolution_stage = data.get("evolution_stage", 1)
	base_stats = data.get("base_stats", {})
	moves = data.get("moves", [])
	abilities = data.get("abilities", [])
	ai_behavior_type = data.get("ai_behavior_type", "aggressive")
	loot_table = data.get("loot_table", {})
	evolution_requirements = data.get("evolution_requirements", {})
	description = data.get("description", "")
	encounter_rate = data.get("encounter_rate", 1.0)
	exp_yield = data.get("exp_yield", 0)
	sprite_path = data.get("sprite_path", "")

	return self


## Convert this resource back to a dictionary
func to_dict() -> Dictionary:
	return {
		"id": id,
		"name": monster_name,
		"types": types,
		"evolution_stage": evolution_stage,
		"base_stats": base_stats,
		"moves": moves,
		"abilities": abilities,
		"ai_behavior_type": ai_behavior_type,
		"loot_table": loot_table,
		"evolution_requirements": evolution_requirements,
		"description": description,
		"encounter_rate": encounter_rate,
		"exp_yield": exp_yield,
		"sprite_path": sprite_path
	}


## Check if this monster can evolve
func can_evolve() -> bool:
	return not evolution_requirements.is_empty()


## Get the evolution target monster ID
func get_evolution_target() -> String:
	return evolution_requirements.get("evolves_into", "")


## Get the evolution type (level, item, soul_shard)
func get_evolution_type() -> String:
	return evolution_requirements.get("type", "")


## Check if this monster has a specific type
func has_type(type: String) -> bool:
	return type in types


## Calculate effective HP with level scaling
func get_effective_hp(level: int) -> int:
	return base_stats.get("hp", 0) + (level * 2)


## Calculate effective attack with level scaling
func get_effective_attack(level: int) -> int:
	return base_stats.get("attack", 0) + level


## Calculate effective defense with level scaling
func get_effective_defense(level: int) -> int:
	return base_stats.get("defense", 0) + level


## Calculate effective speed with level scaling
func get_effective_speed(level: int) -> int:
	return base_stats.get("speed", 0) + level


## Get total base stat value (BST - Base Stat Total)
func get_base_stat_total() -> int:
	var total := 0
	for stat_value in base_stats.values():
		total += int(stat_value)
	return total
