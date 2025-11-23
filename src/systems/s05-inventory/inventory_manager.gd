# Godot 4.5 | GDScript 4.5
# System: S05 - Inventory System
# Created: 2025-11-18
# Dependencies: GLoot plugin
# Purpose: Manages player inventory using GLoot's Inventory class with grid constraints

extends Node
class_name InventoryManager

## Signals for inventory events

## Emitted when item successfully added to inventory
signal item_added(item: InventoryItem, item_id: String)

## Emitted when item removed from inventory
signal item_removed(item: InventoryItem, item_id: String)

## Emitted when inventory is full and cannot accept more items
signal inventory_full()

## Emitted when inventory capacity changes
signal capacity_changed(current: int, maximum: int)

## Emitted when item properties change (e.g., stack size)
signal item_changed(item: InventoryItem)

# Configuration
const CONFIG_PATH: String = "res://data/inventory_config.json"
const PROTOSET_PATH: String = "res://data/items.json"

# Grid configuration
@export var grid_width: int = 6
@export var grid_height: int = 5
@export var max_slots: int = 30

# GLoot inventory reference (will be created programmatically)
var inventory: Node = null  # Will be Inventory class from GLoot
var grid_constraint: Node = null  # Will be GridConstraint from GLoot
var protoset: Resource = null  # Will be ItemProtoset from GLoot

# Inventory state
var is_initialized: bool = false
var current_item_count: int = 0

func _ready() -> void:
	print("InventoryManager: Initializing...")
	_load_config()
	_setup_inventory()
	_load_protoset()
	_setup_grid_constraint()
	is_initialized = true
	print("InventoryManager: Ready (Grid: %dx%d, Max slots: %d)" % [grid_width, grid_height, max_slots])

func _load_config() -> void:
	"""Load configuration from inventory_config.json"""
	var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		push_warning("InventoryManager: Config file not found at %s, using defaults" % CONFIG_PATH)
		return

	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		push_error("InventoryManager: JSON parse error: %s" % json.get_error_message())
		return

	var data = json.data as Dictionary
	if data.is_empty() or not data.has("inventory_config"):
		push_warning("InventoryManager: Invalid config structure, using defaults")
		return

	var config = data["inventory_config"] as Dictionary
	grid_width = config.get("grid_width", 6) as int
	grid_height = config.get("grid_height", 5) as int
	max_slots = config.get("max_slots", 30) as int

	print("InventoryManager: Config loaded - %dx%d grid (%d slots)" % [grid_width, grid_height, max_slots])

func _setup_inventory() -> void:
	"""Create GLoot Inventory node programmatically"""
	# NOTE: GLoot plugin must be installed and enabled for this to work
	# The Inventory class will be available after plugin is enabled

	# Create Inventory node (GLoot class)
	var inventory_class = ClassDB.instantiate("Inventory")
	if inventory_class == null:
		push_error("InventoryManager: GLoot plugin not loaded! Inventory class not found.")
		push_error("  -> Please install GLoot plugin from AssetLib and enable in Project Settings")
		return

	inventory = inventory_class
	add_child(inventory)
	inventory.name = "PlayerInventory"

	# Connect signals
	if inventory.has_signal("item_added"):
		inventory.item_added.connect(_on_inventory_item_added)
	if inventory.has_signal("item_removed"):
		inventory.item_removed.connect(_on_inventory_item_removed)
	if inventory.has_signal("item_property_changed"):
		inventory.item_property_changed.connect(_on_inventory_item_changed)

	print("InventoryManager: GLoot Inventory node created")

func _load_protoset() -> void:
	"""Load item protoset from JSON"""
	if inventory == null:
		return

	# Load protoset resource
	if ResourceLoader.exists(PROTOSET_PATH):
		protoset = load(PROTOSET_PATH)
		if protoset != null and inventory.has_method("set_protoset"):
			inventory.call("set_protoset", protoset)
			print("InventoryManager: Protoset loaded from %s" % PROTOSET_PATH)
		else:
			push_warning("InventoryManager: Failed to load protoset resource")
	else:
		push_warning("InventoryManager: Protoset file not found at %s" % PROTOSET_PATH)

func _setup_grid_constraint() -> void:
	"""Add GridConstraint to inventory for slot management"""
	if inventory == null:
		return

	# Create GridConstraint (GLoot class)
	var constraint_class = ClassDB.instantiate("GridConstraint")
	if constraint_class == null:
		push_error("InventoryManager: GridConstraint class not found (GLoot plugin issue)")
		return

	grid_constraint = constraint_class

	# Set grid size using Vector2i (Godot 4.5)
	if grid_constraint.has_method("set_size"):
		grid_constraint.call("set_size", Vector2i(grid_width, grid_height))
	elif grid_constraint.has_property("size"):
		grid_constraint.set("size", Vector2i(grid_width, grid_height))

	# Add constraint to inventory
	if inventory.has_method("add_constraint"):
		inventory.call("add_constraint", grid_constraint)
		print("InventoryManager: GridConstraint added (%dx%d)" % [grid_width, grid_height])
	else:
		push_error("InventoryManager: Inventory does not support constraints")

## Public API Methods

func add_item_by_id(item_id: String) -> bool:
	"""
	Add item to inventory by prototype ID
	Returns true if successful, false if inventory full or invalid ID
	"""
	if not is_initialized or inventory == null:
		push_warning("InventoryManager: Cannot add item, inventory not initialized")
		return false

	if not inventory.has_method("create_and_add_item"):
		push_error("InventoryManager: Inventory missing create_and_add_item method")
		return false

	var item = inventory.call("create_and_add_item", item_id)
	if item == null:
		# Inventory full or invalid item ID
		inventory_full.emit()
		return false

	return true

func add_item(item: InventoryItem) -> bool:
	"""
	Add existing item to inventory
	Returns true if successful, false if inventory full
	"""
	if not is_initialized or inventory == null:
		return false

	if not inventory.has_method("add_item"):
		return false

	var success = inventory.call("add_item", item) as bool
	if not success:
		inventory_full.emit()

	return success

func remove_item(item: InventoryItem) -> bool:
	"""Remove specific item from inventory"""
	if not is_initialized or inventory == null:
		return false

	if not inventory.has_method("remove_item"):
		return false

	return inventory.call("remove_item", item) as bool

func has_item(item_id: String) -> bool:
	"""Check if inventory contains item with given ID"""
	if not is_initialized or inventory == null:
		return false

	var items = get_all_items()
	for item in items:
		if item == null:
			continue
		var proto_id = _get_item_prototype_id(item)
		if proto_id == item_id:
			return true

	return false

func get_item_count(item_id: String) -> int:
	"""Get total count of items with given ID (including stacks)"""
	if not is_initialized or inventory == null:
		return 0

	var total = 0
	var items = get_all_items()
	for item in items:
		if item == null:
			continue
		var proto_id = _get_item_prototype_id(item)
		if proto_id == item_id:
			# Get stack size
			var stack_size = _get_item_stack_size(item)
			total += stack_size

	return total

func get_all_items() -> Array:
	"""Get array of all items in inventory"""
	if not is_initialized or inventory == null:
		return []

	if not inventory.has_method("get_items"):
		return []

	var items = inventory.call("get_items")
	if items == null:
		return []

	return items

func get_total_item_count() -> int:
	"""Get total number of item stacks (not individual items)"""
	if not is_initialized or inventory == null:
		return 0

	if not inventory.has_method("get_item_count"):
		return 0

	return inventory.call("get_item_count") as int

func is_full() -> bool:
	"""Check if inventory is at capacity"""
	return get_total_item_count() >= max_slots

func get_capacity() -> Dictionary:
	"""Get current and maximum capacity"""
	return {
		"current": get_total_item_count(),
		"maximum": max_slots,
		"percentage": (float(get_total_item_count()) / float(max_slots)) * 100.0
	}

func clear_inventory() -> void:
	"""Remove all items from inventory"""
	if not is_initialized or inventory == null:
		return

	if inventory.has_method("clear"):
		inventory.call("clear")
		print("InventoryManager: Inventory cleared")

func serialize() -> Dictionary:
	"""Serialize inventory data for saving (used by S06 Save/Load)"""
	if not is_initialized or inventory == null:
		return {}

	if not inventory.has_method("serialize"):
		return {}

	var data = inventory.call("serialize")
	return data as Dictionary

func deserialize(data: Dictionary) -> bool:
	"""Deserialize inventory data for loading (used by S06 Save/Load)"""
	if not is_initialized or inventory == null:
		return false

	if not inventory.has_method("deserialize"):
		return false

	return inventory.call("deserialize", data) as bool

## Private Helper Methods

func _get_item_prototype_id(item: InventoryItem) -> String:
	"""Get prototype ID from item"""
	if item == null:
		return ""

	if item.has_method("get_prototype_id"):
		return item.call("get_prototype_id") as String
	elif item.has_property("prototype_id"):
		return item.get("prototype_id") as String

	return ""

func _get_item_stack_size(item: InventoryItem) -> int:
	"""Get stack size from item"""
	if item == null:
		return 0

	if item.has_method("get_property"):
		var stack = item.call("get_property", "quantity", 1)
		return stack as int
	elif item.has_property("quantity"):
		return item.get("quantity") as int

	return 1  # Default stack size

## Signal Handlers

func _on_inventory_item_added(item: InventoryItem) -> void:
	"""Called when item added to inventory"""
	if item == null:
		return

	current_item_count = get_total_item_count()
	var item_id = _get_item_prototype_id(item)

	print("InventoryManager: Item added - %s (Total: %d/%d)" % [item_id, current_item_count, max_slots])
	item_added.emit(item, item_id)

	var capacity = get_capacity()
	capacity_changed.emit(capacity["current"], capacity["maximum"])

func _on_inventory_item_removed(item: InventoryItem) -> void:
	"""Called when item removed from inventory"""
	if item == null:
		return

	current_item_count = get_total_item_count()
	var item_id = _get_item_prototype_id(item)

	print("InventoryManager: Item removed - %s (Total: %d/%d)" % [item_id, current_item_count, max_slots])
	item_removed.emit(item, item_id)

	var capacity = get_capacity()
	capacity_changed.emit(capacity["current"], capacity["maximum"])

func _on_inventory_item_changed(item: InventoryItem, property_name: String) -> void:
	"""Called when item property changes"""
	if item == null:
		return

	item_changed.emit(item)
	print("InventoryManager: Item property changed - %s" % property_name)

## Debug Methods

func print_inventory() -> void:
	"""Debug method to print all inventory contents"""
	print("========== INVENTORY CONTENTS ==========")
	print("Capacity: %d/%d (%.1f%%)" % [current_item_count, max_slots, get_capacity()["percentage"]])

	var items = get_all_items()
	if items.is_empty():
		print("  (Empty)")
	else:
		for i in range(items.size()):
			var item = items[i]
			var item_id = _get_item_prototype_id(item)
			var stack_size = _get_item_stack_size(item)
			print("  [%d] %s x%d" % [i, item_id, stack_size])

	print("========================================")
