# Godot 4.5 | GDScript 4.5
# System: S08 - Equipment System
# Created: 2025-11-18
# Dependencies: S03 (Player), S05 (Inventory), S07 (Weapons Database)
# Purpose: Manages player equipment with 5 slots, stat bonuses, and visual representation

extends Node
class_name EquipmentManager

## Signals for equipment events

## Emitted when item is equipped in a slot
signal item_equipped(slot: String, item_data: Dictionary)

## Emitted when item is unequipped from a slot
signal item_unequipped(slot: String, item_data: Dictionary)

## Emitted when total stat bonuses change
signal stats_changed(new_stats: Dictionary)

## Emitted when equipment visual changes (for sprite updates)
signal visual_equipment_changed(slot: String, sprite_path: String)

## Equipment slot types
enum EquipmentSlot {
	WEAPON,
	HELMET,
	TORSO,
	BOOTS,
	ACCESSORY_1,
	ACCESSORY_2,
	ACCESSORY_3
}

# Configuration
const CONFIG_PATH: String = "res://data/equipment_config.json"
const EQUIPMENT_DATA_PATH: String = "res://data/equipment.json"

# Equipment slots - stores item data dictionaries
var equipped_items: Dictionary = {
	"weapon": null,
	"helmet": null,
	"torso": null,
	"boots": null,
	"accessories": []  # Array of up to 3 items
}

# Maximum accessories allowed
const MAX_ACCESSORIES: int = 3

# Equipment database (loaded from JSON)
var equipment_database: Dictionary = {}

# Current total stat bonuses
var current_stat_bonuses: Dictionary = {
	"defense": 0,
	"max_hp": 0,
	"speed": 0,
	"attack": 0,
	"max_mp": 0,
	"critical_chance": 0.0,
	"evasion": 0.0
}

# Resistance bonuses
var current_resistances: Dictionary = {
	"physical": 0.0,
	"fire": 0.0,
	"ice": 0.0,
	"lightning": 0.0,
	"poison": 0.0
}

# Total weight of equipped items (affects movement speed)
var total_weight: float = 0.0

# Initialization state
var is_initialized: bool = false

# Reference to player (if attached to Player node)
var player: Node = null

func _ready() -> void:
	print("EquipmentManager: Initializing...")
	_load_equipment_database()
	_initialize_equipment_slots()
	is_initialized = true

	# Get player reference if this is a child of Player
	if get_parent() is CharacterBody2D:
		player = get_parent()
		print("EquipmentManager: Attached to player: %s" % player.name)

	print("EquipmentManager: Ready (Max accessories: %d)" % MAX_ACCESSORIES)

func _load_equipment_database() -> void:
	"""Load equipment definitions from JSON"""
	var file = FileAccess.open(EQUIPMENT_DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("EquipmentManager: Failed to load equipment database from %s" % EQUIPMENT_DATA_PATH)
		return

	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		push_error("EquipmentManager: JSON parse error: %s" % json.get_error_message())
		return

	var data = json.data as Dictionary
	if data.is_empty() or not data.has("equipment"):
		push_error("EquipmentManager: Invalid equipment database structure")
		return

	# Build equipment lookup dictionary by ID
	var equipment_list = data["equipment"] as Array
	for equipment_item in equipment_list:
		var item_dict = equipment_item as Dictionary
		var item_id = item_dict.get("id", "") as String
		if item_id != "":
			equipment_database[item_id] = item_dict

	print("EquipmentManager: Loaded %d equipment definitions" % equipment_database.size())

func _initialize_equipment_slots() -> void:
	"""Initialize all equipment slots to empty"""
	equipped_items["weapon"] = null
	equipped_items["helmet"] = null
	equipped_items["torso"] = null
	equipped_items["boots"] = null
	equipped_items["accessories"] = []

## Public API Methods

func equip_item(slot: String, item_data: Dictionary) -> bool:
	"""
	Equip an item in the specified slot
	Returns true if successful, false if invalid slot or item
	"""
	if not is_initialized:
		push_warning("EquipmentManager: Cannot equip item, not initialized")
		return false

	# Validate slot type
	if not _is_valid_slot(slot):
		push_error("EquipmentManager: Invalid slot '%s'" % slot)
		return false

	# Validate item can be equipped in this slot
	if not _can_equip_in_slot(item_data, slot):
		push_warning("EquipmentManager: Item '%s' cannot be equipped in slot '%s'" % [item_data.get("name", "Unknown"), slot])
		return false

	# Handle accessories differently (array)
	if slot == "accessories":
		return _equip_accessory(item_data)

	# Unequip existing item in slot if present
	if equipped_items[slot] != null:
		unequip_item(slot)

	# Equip new item
	equipped_items[slot] = item_data

	# Recalculate stats
	_recalculate_stats()

	# Emit signals
	item_equipped.emit(slot, item_data)

	# Update visual equipment if sprite path exists
	var sprite_path = item_data.get("sprite_path", "")
	if sprite_path != "":
		visual_equipment_changed.emit(slot, sprite_path)

	print("EquipmentManager: Equipped %s in %s slot" % [item_data.get("name", "Unknown"), slot])
	return true

func equip_item_by_id(slot: String, item_id: String) -> bool:
	"""
	Equip an item by its ID from the equipment database
	Returns true if successful
	"""
	if not equipment_database.has(item_id):
		push_error("EquipmentManager: Equipment ID '%s' not found in database" % item_id)
		return false

	var item_data = equipment_database[item_id]
	return equip_item(slot, item_data)

func unequip_item(slot: String) -> bool:
	"""
	Unequip item from the specified slot
	Returns the unequipped item data, or null if slot was empty
	"""
	if not _is_valid_slot(slot):
		push_error("EquipmentManager: Invalid slot '%s'" % slot)
		return false

	var unequipped_item: Dictionary = {}

	# Handle accessories
	if slot == "accessories":
		push_warning("EquipmentManager: Use unequip_accessory(index) for accessories")
		return false

	# Check if slot has item
	if equipped_items[slot] == null:
		return false

	unequipped_item = equipped_items[slot]
	equipped_items[slot] = null

	# Recalculate stats
	_recalculate_stats()

	# Emit signals
	item_unequipped.emit(slot, unequipped_item)
	visual_equipment_changed.emit(slot, "")  # Clear visual

	print("EquipmentManager: Unequipped %s from %s slot" % [unequipped_item.get("name", "Unknown"), slot])
	return true

func _equip_accessory(item_data: Dictionary) -> bool:
	"""Equip an accessory item (max 3)"""
	var accessories = equipped_items["accessories"] as Array

	if accessories.size() >= MAX_ACCESSORIES:
		push_warning("EquipmentManager: Cannot equip more than %d accessories" % MAX_ACCESSORIES)
		return false

	accessories.append(item_data)
	_recalculate_stats()

	item_equipped.emit("accessories", item_data)
	print("EquipmentManager: Equipped accessory %s (%d/%d)" % [item_data.get("name", "Unknown"), accessories.size(), MAX_ACCESSORIES])
	return true

func unequip_accessory(index: int) -> bool:
	"""Unequip accessory at specified index (0-2)"""
	var accessories = equipped_items["accessories"] as Array

	if index < 0 or index >= accessories.size():
		push_error("EquipmentManager: Invalid accessory index %d" % index)
		return false

	var unequipped_item = accessories[index] as Dictionary
	accessories.remove_at(index)

	_recalculate_stats()
	item_unequipped.emit("accessories", unequipped_item)

	print("EquipmentManager: Unequipped accessory %s" % unequipped_item.get("name", "Unknown"))
	return true

func get_equipped_item(slot: String) -> Dictionary:
	"""Get the item equipped in the specified slot"""
	if not _is_valid_slot(slot):
		return {}

	if slot == "accessories":
		push_warning("EquipmentManager: Use get_equipped_accessories() for accessories")
		return {}

	if equipped_items[slot] == null:
		return {}

	return equipped_items[slot]

func get_equipped_accessories() -> Array:
	"""Get array of equipped accessories"""
	return (equipped_items["accessories"] as Array).duplicate()

func get_total_stat_bonuses() -> Dictionary:
	"""Get the total stat bonuses from all equipped items"""
	return current_stat_bonuses.duplicate()

func get_total_resistances() -> Dictionary:
	"""Get the total resistance bonuses from all equipped items"""
	return current_resistances.duplicate()

func get_total_weight() -> float:
	"""Get the total weight of all equipped items"""
	return total_weight

func is_slot_empty(slot: String) -> bool:
	"""Check if a slot is empty"""
	if slot == "accessories":
		return (equipped_items["accessories"] as Array).is_empty()

	return equipped_items.get(slot, null) == null

func get_accessory_count() -> int:
	"""Get number of equipped accessories"""
	return (equipped_items["accessories"] as Array).size()

## Stat Calculation

func _recalculate_stats() -> void:
	"""Recalculate total stat bonuses from all equipped items"""
	# Reset all bonuses
	current_stat_bonuses = {
		"defense": 0,
		"max_hp": 0,
		"speed": 0,
		"attack": 0,
		"max_mp": 0,
		"critical_chance": 0.0,
		"evasion": 0.0
	}

	current_resistances = {
		"physical": 0.0,
		"fire": 0.0,
		"ice": 0.0,
		"lightning": 0.0,
		"poison": 0.0
	}

	total_weight = 0.0

	# Add bonuses from each equipment slot
	for slot in ["weapon", "helmet", "torso", "boots"]:
		var item = equipped_items[slot]
		if item != null:
			_add_item_bonuses(item)

	# Add bonuses from accessories
	var accessories = equipped_items["accessories"] as Array
	for accessory in accessories:
		_add_item_bonuses(accessory)

	# Emit stats changed signal
	stats_changed.emit(current_stat_bonuses)

	print("EquipmentManager: Stats recalculated - Defense: %d, Attack: %d, HP: %d, Weight: %.1f" %
		[current_stat_bonuses["defense"], current_stat_bonuses["attack"], current_stat_bonuses["max_hp"], total_weight])

func _add_item_bonuses(item: Dictionary) -> void:
	"""Add stat bonuses from a single item"""
	if item.is_empty():
		return

	# Add stat bonuses
	if item.has("stat_bonuses"):
		var bonuses = item["stat_bonuses"] as Dictionary
		for stat in bonuses.keys():
			if current_stat_bonuses.has(stat):
				var bonus_value = bonuses[stat]
				# Handle both int and float values
				if bonus_value is int:
					current_stat_bonuses[stat] += bonus_value
				elif bonus_value is float:
					current_stat_bonuses[stat] += bonus_value

	# Add resistances
	if item.has("resistances"):
		var resistances = item["resistances"] as Dictionary
		for resistance in resistances.keys():
			if current_resistances.has(resistance):
				current_resistances[resistance] += resistances[resistance] as float

	# Add weight
	if item.has("weight"):
		total_weight += item["weight"] as float

## Validation

func _is_valid_slot(slot: String) -> bool:
	"""Check if slot name is valid"""
	return slot in ["weapon", "helmet", "torso", "boots", "accessories"]

func _can_equip_in_slot(item_data: Dictionary, slot: String) -> bool:
	"""Check if item can be equipped in the specified slot"""
	if item_data.is_empty():
		return false

	# Get item's equipment slot from data
	var item_slot = item_data.get("slot", "")

	# Special case for accessories
	if slot == "accessories":
		return item_slot == "accessory" or item_slot == "accessories"

	# Check if item's slot matches requested slot
	return item_slot == slot

## Save/Load Integration (S06)

func save_state() -> Dictionary:
	"""
	Serialize equipment state for saving
	Used by SaveManager (S06)
	"""
	var save_data: Dictionary = {
		"weapon": _serialize_item(equipped_items["weapon"]),
		"helmet": _serialize_item(equipped_items["helmet"]),
		"torso": _serialize_item(equipped_items["torso"]),
		"boots": _serialize_item(equipped_items["boots"]),
		"accessories": []
	}

	# Serialize accessories
	var accessories = equipped_items["accessories"] as Array
	for accessory in accessories:
		save_data["accessories"].append(_serialize_item(accessory))

	return save_data

func load_state(save_data: Dictionary) -> bool:
	"""
	Deserialize equipment state for loading
	Used by SaveManager (S06)
	"""
	if save_data.is_empty():
		return false

	# Clear current equipment
	_initialize_equipment_slots()

	# Load each slot
	if save_data.has("weapon") and save_data["weapon"] != null:
		var item_id = save_data["weapon"] as String
		equip_item_by_id("weapon", item_id)

	if save_data.has("helmet") and save_data["helmet"] != null:
		var item_id = save_data["helmet"] as String
		equip_item_by_id("helmet", item_id)

	if save_data.has("torso") and save_data["torso"] != null:
		var item_id = save_data["torso"] as String
		equip_item_by_id("torso", item_id)

	if save_data.has("boots") and save_data["boots"] != null:
		var item_id = save_data["boots"] as String
		equip_item_by_id("boots", item_id)

	# Load accessories
	if save_data.has("accessories"):
		var accessories_data = save_data["accessories"] as Array
		for accessory_id in accessories_data:
			if accessory_id != null and accessory_id is String:
				equip_item_by_id("accessories", accessory_id)

	print("EquipmentManager: Loaded equipment state")
	return true

func _serialize_item(item: Variant) -> Variant:
	"""Convert item to saveable format (just ID)"""
	if item == null:
		return null

	if item is Dictionary:
		return item.get("id", null)

	return null

## Debug Methods

func print_equipment() -> void:
	"""Debug method to print all equipped items"""
	print("========== EQUIPPED ITEMS ==========")
	print("Weapon: %s" % _format_item_name(equipped_items["weapon"]))
	print("Helmet: %s" % _format_item_name(equipped_items["helmet"]))
	print("Torso: %s" % _format_item_name(equipped_items["torso"]))
	print("Boots: %s" % _format_item_name(equipped_items["boots"]))

	var accessories = equipped_items["accessories"] as Array
	print("Accessories (%d/%d):" % [accessories.size(), MAX_ACCESSORIES])
	for i in range(accessories.size()):
		print("  [%d] %s" % [i, _format_item_name(accessories[i])])

	print("\nTotal Stats:")
	for stat in current_stat_bonuses.keys():
		var value = current_stat_bonuses[stat]
		if value != 0:
			print("  +%s: %s" % [stat.capitalize(), str(value)])

	print("\nTotal Resistances:")
	for resistance in current_resistances.keys():
		var value = current_resistances[resistance]
		if value != 0.0:
			print("  %s: +%.1f%%" % [resistance.capitalize(), value * 100.0])

	print("\nTotal Weight: %.1f kg" % total_weight)
	print("====================================")

func _format_item_name(item: Variant) -> String:
	"""Format item name for display"""
	if item == null:
		return "(Empty)"

	if item is Dictionary:
		return item.get("name", "Unknown")

	return "Unknown"
