# Godot 4.5 | GDScript 4.5
# System: S08 - Equipment System Test Scene
# Created: 2025-11-18
# Purpose: Test scene script for equipment system with button controls

extends Node2D

@onready var player: Node = $Player
@onready var equipment_manager: EquipmentManager = $Player/EquipmentManager

func _ready() -> void:
	# Verify equipment manager exists
	if equipment_manager == null:
		push_error("TestEquipment: EquipmentManager not found on Player")
		return

	# Connect test buttons
	$UI/TestControls/EquipHelmet.pressed.connect(_on_equip_helmet)
	$UI/TestControls/EquipArmor.pressed.connect(_on_equip_armor)
	$UI/TestControls/EquipBoots.pressed.connect(_on_equip_boots)
	$UI/TestControls/EquipAccessory.pressed.connect(_on_equip_accessory)
	$UI/TestControls/UnequipAll.pressed.connect(_on_unequip_all)
	$UI/TestControls/ShowStats.pressed.connect(_on_show_stats)

	# Connect to equipment manager signals
	equipment_manager.item_equipped.connect(_on_item_equipped)
	equipment_manager.item_unequipped.connect(_on_item_unequipped)
	equipment_manager.stats_changed.connect(_on_stats_changed)

	print("TestEquipment: Ready")
	print("TestEquipment: Use buttons on the left to test equipment system")

func _on_equip_helmet() -> void:
	"""Test equipping iron helmet"""
	if equipment_manager.equip_item_by_id("helmet", "iron_helmet"):
		print("TestEquipment: Successfully equipped Iron Helmet")
	else:
		print("TestEquipment: Failed to equip Iron Helmet")

func _on_equip_armor() -> void:
	"""Test equipping chainmail armor"""
	if equipment_manager.equip_item_by_id("torso", "chainmail"):
		print("TestEquipment: Successfully equipped Chainmail")
	else:
		print("TestEquipment: Failed to equip Chainmail")

func _on_equip_boots() -> void:
	"""Test equipping leather boots"""
	if equipment_manager.equip_item_by_id("boots", "leather_boots"):
		print("TestEquipment: Successfully equipped Leather Boots")
	else:
		print("TestEquipment: Failed to equip Leather Boots")

func _on_equip_accessory() -> void:
	"""Test equipping ring of strength"""
	if equipment_manager.equip_item_by_id("accessories", "ring_of_strength"):
		print("TestEquipment: Successfully equipped Ring of Strength")
	else:
		print("TestEquipment: Failed to equip Ring of Strength (max 3 accessories)")

func _on_unequip_all() -> void:
	"""Unequip all items"""
	print("TestEquipment: Unequipping all items...")

	equipment_manager.unequip_item("helmet")
	equipment_manager.unequip_item("torso")
	equipment_manager.unequip_item("boots")

	# Unequip all accessories (iterate backwards to avoid index issues)
	var accessory_count: int = equipment_manager.get_accessory_count()
	for i in range(accessory_count - 1, -1, -1):
		equipment_manager.unequip_accessory(i)

	print("TestEquipment: All equipment unequipped")

func _on_show_stats() -> void:
	"""Print equipment stats to console"""
	print("\n" + "=".repeat(50))
	print("EQUIPMENT STATS (from test button)")
	equipment_manager.print_equipment()
	print("=".repeat(50) + "\n")

## Signal Handlers

func _on_item_equipped(slot: String, item_data: Dictionary) -> void:
	"""Called when item is equipped"""
	var item_name: String = item_data.get("name", "Unknown") as String
	print("TestEquipment: SIGNAL - Item equipped in %s: %s" % [slot, item_name])
	_update_ui_stats()

func _on_item_unequipped(slot: String, item_data: Dictionary) -> void:
	"""Called when item is unequipped"""
	var item_name: String = item_data.get("name", "Unknown") as String
	print("TestEquipment: SIGNAL - Item unequipped from %s: %s" % [slot, item_name])
	_update_ui_stats()

func _on_stats_changed(new_stats: Dictionary) -> void:
	"""Called when total stats change"""
	print("TestEquipment: SIGNAL - Stats changed:")
	for stat in new_stats.keys():
		var value: Variant = new_stats[stat]
		if value != 0:
			print("  %s: +%s" % [stat.capitalize(), str(value)])

func _update_ui_stats() -> void:
	"""Update the stats display in the UI"""
	var stats: Dictionary = equipment_manager.get_total_stat_bonuses()

	# Update stat labels
	$UI/EquipmentUI/MainLayout/StatsDisplay/StatDefense.text = "Defense: +%d" % stats.get("defense", 0)
	$UI/EquipmentUI/MainLayout/StatsDisplay/StatMaxHP.text = "Max HP: +%d" % stats.get("max_hp", 0)
	$UI/EquipmentUI/MainLayout/StatsDisplay/StatSpeed.text = "Speed: +%d" % stats.get("speed", 0)
	$UI/EquipmentUI/MainLayout/StatsDisplay/StatAttack.text = "Attack: +%d" % stats.get("attack", 0)
	$UI/EquipmentUI/MainLayout/StatsDisplay/StatMaxMP.text = "Max MP: +%d" % stats.get("max_mp", 0)

	# Update weight display
	var total_weight: float = equipment_manager.get_total_weight()
	$UI/EquipmentUI/MainLayout/StatsDisplay/TotalWeight.text = "Weight: %.1f kg" % total_weight
