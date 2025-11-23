# Godot 4.5 | GDScript 4.5
# System: S07 - Weapons & Shields Database
# Created: 2025-11-18
# Dependencies: None (foundation data system)

extends Resource
class_name ShieldResource

## Represents a shield item with defensive stats and properties
##
## This resource defines all shield attributes used by the combat system (S04),
## equipment system (S08), dodge/block system (S09), and crafting (S25).
## Instances are loaded from shields.json at startup by ItemDatabase.

## Unique identifier for this shield (e.g., "wooden_shield", "tower_shield")
@export var id: String = ""

## Display name shown in UI (e.g., "Wooden Shield", "Tower Shield")
@export var name: String = ""

## Shield category: small, medium, or large
@export var type: String = ""

## Power tier from 1 (starter) to 5 (legendary)
@export var tier: int = 1

## Base defense rating - reduces incoming damage
@export var defense: int = 0

## Percentage chance to fully block an attack (0.0 - 1.0, e.g., 0.5 = 50%)
@export var block_percentage: float = 0.0

## Weight affects movement speed when equipped (lighter = faster)
@export var weight: float = 1.0

## Special properties like "reflect_damage", "elemental_resistance", "parry_bonus"
## Used by combat and dodge/block systems for special mechanics
@export var special_properties: Array[String] = []

## Path to shield icon texture for inventory/equipment UI
@export var icon_path: String = ""

## Gold value for shop purchase/sell
@export var value: int = 0


## Returns a human-readable description of this shield
func get_description() -> String:
	var desc: String = "%s\n" % name
	desc += "Type: %s | Tier: %d\n" % [type.capitalize(), tier]
	desc += "Defense: %d | Block Chance: %.0f%% | Weight: %.1f\n" % [defense, block_percentage * 100.0, weight]

	if special_properties.size() > 0:
		desc += "Properties: %s\n" % ", ".join(special_properties)

	desc += "Value: %d gold" % value
	return desc


## Returns true if this shield has the specified special property
func has_property(property_name: String) -> bool:
	return property_name in special_properties


## Calculates effective damage reduction for given incoming damage
## Combines defense rating with random block chance
func calculate_damage_reduction(incoming_damage: int) -> int:
	# Check for full block
	if randf() < block_percentage:
		return incoming_damage  # Full block - all damage negated

	# Partial reduction based on defense rating
	# Formula: reduction = min(defense / 2, incoming_damage * 0.8)
	# This prevents shields from reducing damage to 0 unless blocking
	var reduction: int = mini(defense / 2, int(float(incoming_damage) * 0.8))
	return reduction


## Returns movement speed penalty multiplier based on weight
## Lighter shields = less penalty (closer to 1.0)
## Heavy shields = more penalty (closer to 0.7)
func get_speed_penalty() -> float:
	# Weight range: 1.0 (small) to 5.0 (large)
	# Speed range: 1.0 (no penalty) to 0.7 (30% slower)
	var penalty := 1.0 - ((weight - 1.0) / 4.0) * 0.3
	return clampf(penalty, 0.7, 1.0)


## Creates a deep copy of this shield resource
## Used by crafting system when creating modified shields
func duplicate_shield() -> ShieldResource:
	var copy := ShieldResource.new()
	copy.id = id
	copy.name = name
	copy.type = type
	copy.tier = tier
	copy.defense = defense
	copy.block_percentage = block_percentage
	copy.weight = weight
	copy.special_properties = special_properties.duplicate()
	copy.icon_path = icon_path
	copy.value = value
	return copy
