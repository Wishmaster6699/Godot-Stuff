# Godot 4.5 | GDScript 4.5
# System: S07 - Weapons & Shields Database
# Created: 2025-11-18
# Dependencies: WeaponResource, ShieldResource
# Autoload: ItemDatabase (registered in project.godot)

extends Node

## Singleton database for all weapons and shields in the game
##
## Loads all item definitions from JSON files at startup and caches them
## as WeaponResource and ShieldResource instances. Provides fast O(1) lookup
## by item ID and iteration methods for UI display.
##
## Usage:
##   var weapon = ItemDatabase.get_weapon("iron_sword")
##   var all_swords = ItemDatabase.get_weapons_by_type("sword")
##   var shield = ItemDatabase.get_shield("wooden_shield")

## Cached weapons dictionary: id (String) -> WeaponResource
var weapons: Dictionary = {}

## Cached shields dictionary: id (String) -> ShieldResource
var shields: Dictionary = {}

## Paths to data files
const WEAPONS_DATA_PATH: String = "res://data/weapons.json"
const SHIELDS_DATA_PATH: String = "res://data/shields.json"


## Loads all weapon and shield data at startup
func _ready() -> void:
	print("ItemDatabase: Loading weapons and shields...")
	_load_weapons()
	_load_shields()
	print("ItemDatabase: Loaded %d weapons and %d shields" % [weapons.size(), shields.size()])


## Loads all weapons from weapons.json
func _load_weapons() -> void:
	var data: Dictionary = _load_json_file(WEAPONS_DATA_PATH)
	if data.is_empty():
		push_error("ItemDatabase: Failed to load weapons data")
		return

	if not data.has("weapons"):
		push_error("ItemDatabase: weapons.json missing 'weapons' array")
		return

	var weapons_array: Array = data["weapons"]
	for weapon_data in weapons_array:
		if not weapon_data is Dictionary:
			push_warning("ItemDatabase: Invalid weapon data entry (not a dictionary)")
			continue

		var weapon := _create_weapon_from_data(weapon_data)
		if weapon:
			weapons[weapon.id] = weapon


## Loads all shields from shields.json
func _load_shields() -> void:
	var data: Dictionary = _load_json_file(SHIELDS_DATA_PATH)
	if data.is_empty():
		push_error("ItemDatabase: Failed to load shields data")
		return

	if not data.has("shields"):
		push_error("ItemDatabase: shields.json missing 'shields' array")
		return

	var shields_array: Array = data["shields"]
	for shield_data in shields_array:
		if not shield_data is Dictionary:
			push_warning("ItemDatabase: Invalid shield data entry (not a dictionary)")
			continue

		var shield := _create_shield_from_data(shield_data)
		if shield:
			shields[shield.id] = shield


## Loads and parses a JSON file, returns Dictionary or empty dict on error
func _load_json_file(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		push_error("ItemDatabase: File not found: %s" % path)
		return {}

	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("ItemDatabase: Failed to open file: %s" % path)
		return {}

	var content := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(content)
	if error != OK:
		push_error("ItemDatabase: JSON parse error in %s at line %d: %s" % [path, json.get_error_line(), json.get_error_message()])
		return {}

	if not json.data is Dictionary:
		push_error("ItemDatabase: JSON root must be a Dictionary in %s" % path)
		return {}

	return json.data as Dictionary


## Creates a WeaponResource from JSON data dictionary
func _create_weapon_from_data(data: Dictionary) -> WeaponResource:
	if not data.has("id"):
		push_warning("ItemDatabase: Weapon missing 'id' field")
		return null

	var weapon := WeaponResource.new()
	weapon.id = data.get("id", "")
	weapon.name = data.get("name", "Unknown Weapon")
	weapon.type = data.get("type", "sword")
	weapon.tier = data.get("tier", 1)
	weapon.damage = data.get("damage", 0)
	weapon.speed = data.get("speed", 1.0)
	weapon.range = data.get("range", 32)
	weapon.attack_pattern = data.get("attack_pattern", "slash")
	weapon.icon_path = data.get("icon_path", "")
	weapon.value = data.get("value", 0)

	# Handle special_effects array
	if data.has("special_effects") and data["special_effects"] is Array:
		var effects: Array = data["special_effects"]
		weapon.special_effects.clear()
		for effect in effects:
			if effect is String:
				weapon.special_effects.append(effect)

	return weapon


## Creates a ShieldResource from JSON data dictionary
func _create_shield_from_data(data: Dictionary) -> ShieldResource:
	if not data.has("id"):
		push_warning("ItemDatabase: Shield missing 'id' field")
		return null

	var shield := ShieldResource.new()
	shield.id = data.get("id", "")
	shield.name = data.get("name", "Unknown Shield")
	shield.type = data.get("type", "medium")
	shield.tier = data.get("tier", 1)
	shield.defense = data.get("defense", 0)
	shield.block_percentage = data.get("block_percentage", 0.0)
	shield.weight = data.get("weight", 1.0)
	shield.icon_path = data.get("icon_path", "")
	shield.value = data.get("value", 0)

	# Handle special_properties array
	if data.has("special_properties") and data["special_properties"] is Array:
		var properties: Array = data["special_properties"]
		shield.special_properties.clear()
		for prop in properties:
			if prop is String:
				shield.special_properties.append(prop)

	return shield


## Returns weapon by ID, or null if not found
func get_weapon(id: String) -> WeaponResource:
	if id in weapons:
		return weapons[id]
	push_warning("ItemDatabase: Weapon '%s' not found" % id)
	return null


## Returns shield by ID, or null if not found
func get_shield(id: String) -> ShieldResource:
	if id in shields:
		return shields[id]
	push_warning("ItemDatabase: Shield '%s' not found" % id)
	return null


## Returns array of all weapons (unsorted)
func get_all_weapons() -> Array[WeaponResource]:
	var result: Array[WeaponResource] = []
	for weapon in weapons.values():
		result.append(weapon)
	return result


## Returns array of all shields (unsorted)
func get_all_shields() -> Array[ShieldResource]:
	var result: Array[ShieldResource] = []
	for shield in shields.values():
		result.append(shield)
	return result


## Returns weapons of specific type (e.g., "sword", "axe", "bow")
func get_weapons_by_type(weapon_type: String) -> Array[WeaponResource]:
	var result: Array[WeaponResource] = []
	for weapon in weapons.values():
		if weapon.type == weapon_type:
			result.append(weapon)
	return result


## Returns shields of specific type (e.g., "small", "medium", "large")
func get_shields_by_type(shield_type: String) -> Array[ShieldResource]:
	var result: Array[ShieldResource] = []
	for shield in shields.values():
		if shield.type == shield_type:
			result.append(shield)
	return result


## Returns weapons of specific tier (1-5)
func get_weapons_by_tier(tier_level: int) -> Array[WeaponResource]:
	var result: Array[WeaponResource] = []
	for weapon in weapons.values():
		if weapon.tier == tier_level:
			result.append(weapon)
	return result


## Returns shields of specific tier (1-5)
func get_shields_by_tier(tier_level: int) -> Array[ShieldResource]:
	var result: Array[ShieldResource] = []
	for shield in shields.values():
		if shield.tier == tier_level:
			result.append(shield)
	return result


## Returns true if weapon with given ID exists
func has_weapon(id: String) -> bool:
	return id in weapons


## Returns true if shield with given ID exists
func has_shield(id: String) -> bool:
	return id in shields


## Returns total number of weapons in database
func get_weapon_count() -> int:
	return weapons.size()


## Returns total number of shields in database
func get_shield_count() -> int:
	return shields.size()


## Prints debug info about loaded items
func print_database_stats() -> void:
	print("=".repeat(60))
	print("ItemDatabase Statistics")
	print("=".repeat(60))
	print("Total Weapons: %d" % weapons.size())
	print("Total Shields: %d" % shields.size())
	print("")

	# Weapons by type
	var weapon_types: Dictionary = {}
	for weapon in weapons.values():
		if not weapon_types.has(weapon.type):
			weapon_types[weapon.type] = 0
		weapon_types[weapon.type] += 1

	print("Weapons by Type:")
	for type in weapon_types.keys():
		print("  %s: %d" % [type.capitalize(), weapon_types[type]])

	# Shields by type
	var shield_types: Dictionary = {}
	for shield in shields.values():
		if not shield_types.has(shield.type):
			shield_types[shield.type] = 0
		shield_types[shield.type] += 1

	print("\nShields by Type:")
	for type in shield_types.keys():
		print("  %s: %d" % [type.capitalize(), shield_types[type]])

	print("=".repeat(60))
