# Godot 4.5 | GDScript 4.5
# System: S07 - Weapons & Shields Database
# Created: 2025-11-18
# Dependencies: None (foundation data system)

extends Resource
class_name WeaponResource

## Represents a weapon item with combat stats and properties
##
## This resource defines all weapon attributes used by the combat system (S04),
## equipment system (S08), special moves (S10), and crafting (S25).
## Instances are loaded from weapons.json at startup by ItemDatabase.

## Unique identifier for this weapon (e.g., "wooden_sword", "flame_blade")
@export var id: String = ""

## Display name shown in UI (e.g., "Wooden Sword", "Flame Blade")
@export var name: String = ""

## Weapon category: sword, axe, spear, bow, staff, or legendary
@export var type: String = ""

## Power tier from 1 (starter) to 5 (legendary)
@export var tier: int = 1

## Base damage dealt on successful hit
@export var damage: int = 0

## Attack speed multiplier (lower = faster, typical range: 0.5 - 2.0)
@export var speed: float = 1.0

## Attack range in pixels (typical: 16-128)
@export var range: int = 32

## Attack animation pattern: slash, thrust, swing, shoot, cast
@export var attack_pattern: String = "slash"

## Special effects applied on hit (e.g., ["fire_damage", "poison"])
## Used by combat system for status effects
@export var special_effects: Array[String] = []

## Path to weapon icon texture for inventory/equipment UI
@export var icon_path: String = ""

## Gold value for shop purchase/sell
@export var value: int = 0


## Returns a human-readable description of this weapon
func get_description() -> String:
	var desc: String = "%s\n" % name
	desc += "Type: %s | Tier: %d\n" % [type.capitalize(), tier]
	desc += "Damage: %d | Speed: %.1fx | Range: %d\n" % [damage, speed, range]
	desc += "Pattern: %s\n" % attack_pattern

	if special_effects.size() > 0:
		desc += "Effects: %s\n" % ", ".join(special_effects)

	desc += "Value: %d gold" % value
	return desc


## Returns true if this weapon has the specified special effect
func has_effect(effect_name: String) -> bool:
	return effect_name in special_effects


## Returns the effective DPS (damage per second) based on damage and speed
## Lower speed values = faster attacks = higher DPS
func get_dps() -> float:
	if speed <= 0.0:
		return 0.0
	return float(damage) / speed


## Creates a deep copy of this weapon resource
## Used by crafting system when creating modified weapons
func duplicate_weapon() -> WeaponResource:
	var copy := WeaponResource.new()
	copy.id = id
	copy.name = name
	copy.type = type
	copy.tier = tier
	copy.damage = damage
	copy.speed = speed
	copy.range = range
	copy.attack_pattern = attack_pattern
	copy.special_effects = special_effects.duplicate()
	copy.icon_path = icon_path
	copy.value = value
	return copy
