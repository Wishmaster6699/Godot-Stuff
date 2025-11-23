# Godot 4.5 | GDScript 4.5
# System: S05 - Inventory System
# Created: 2025-11-18
# Dependencies: GLoot plugin
# Purpose: UI wrapper for GLoot's CtrlInventoryGrid with game-specific functionality

extends Control
class_name InventoryUI

## Signals

## Emitted when inventory UI is opened
signal inventory_opened()

## Emitted when inventory UI is closed
signal inventory_closed()

## Emitted when item is selected in UI
signal item_selected(item: InventoryItem)

## Emitted when item is used from UI
signal item_used(item: InventoryItem)

# UI Configuration
@export var toggle_key: String = "ui_cancel"  # Default: ESC, can be customized to "I"
@export var start_hidden: bool = true
@export var pause_game_when_open: bool = false

# References to UI nodes (will be set up in scene by MCP agent)
var ctrl_inventory_grid: Control = null  # GLoot's CtrlInventoryGrid
var inventory_manager: InventoryManager = null
var title_label: Label = null
var capacity_label: Label = null
var close_button: Button = null

# State
var is_open: bool = false

func _ready() -> void:
	print("InventoryUI: Initializing...")

	# Hide by default if configured
	if start_hidden:
		visible = false
		is_open = false

	# Try to find UI components (may not exist if scene not fully configured yet)
	_find_ui_components()

	# Try to find InventoryManager
	_find_inventory_manager()

	# Connect signals if components found
	_connect_signals()

	print("InventoryUI: Ready (Start hidden: %s)" % start_hidden)

func _find_ui_components() -> void:
	"""Find UI components in scene"""
	# Find CtrlInventoryGrid
	if has_node("Panel/CtrlInventoryGrid"):
		ctrl_inventory_grid = get_node("Panel/CtrlInventoryGrid")
	elif has_node("CtrlInventoryGrid"):
		ctrl_inventory_grid = get_node("CtrlInventoryGrid")

	# Find labels
	if has_node("Panel/TitleLabel"):
		title_label = get_node("Panel/TitleLabel")
	if has_node("Panel/CapacityLabel"):
		capacity_label = get_node("Panel/CapacityLabel")

	# Find close button
	if has_node("Panel/CloseButton"):
		close_button = get_node("Panel/CloseButton")

	if ctrl_inventory_grid != null:
		print("InventoryUI: Found CtrlInventoryGrid")
	else:
		push_warning("InventoryUI: CtrlInventoryGrid not found - UI may not function correctly")

func _find_inventory_manager() -> void:
	"""Find InventoryManager in scene tree"""
	# Look in player node first
	var player = get_tree().get_first_node_in_group("player")
	if player != null:
		for child in player.get_children():
			if child is InventoryManager:
				inventory_manager = child
				print("InventoryUI: Found InventoryManager in Player")
				return

	# Look in scene root
	var root = get_tree().current_scene
	if root != null:
		for child in root.get_children():
			if child is InventoryManager:
				inventory_manager = child
				print("InventoryUI: Found InventoryManager in scene root")
				return

	# Last resort: search entire tree
	var found = _find_node_recursive(get_tree().root, "InventoryManager")
	if found != null and found is InventoryManager:
		inventory_manager = found
		print("InventoryUI: Found InventoryManager via recursive search")
		return

	push_warning("InventoryUI: InventoryManager not found - inventory UI will not function")

func _find_node_recursive(node: Node, target_name: String) -> Node:
	"""Recursively search for node by name"""
	if node.name == target_name:
		return node

	for child in node.get_children():
		var found = _find_node_recursive(child, target_name)
		if found != null:
			return found

	return null

func _connect_signals() -> void:
	"""Connect UI component signals"""
	# Connect close button
	if close_button != null:
		close_button.pressed.connect(_on_close_button_pressed)

	# Connect inventory manager signals
	if inventory_manager != null:
		if inventory_manager.has_signal("item_added"):
			inventory_manager.item_added.connect(_on_inventory_changed)
		if inventory_manager.has_signal("item_removed"):
			inventory_manager.item_removed.connect(_on_inventory_changed)
		if inventory_manager.has_signal("capacity_changed"):
			inventory_manager.capacity_changed.connect(_on_capacity_changed)

	# Connect CtrlInventoryGrid signals (GLoot)
	if ctrl_inventory_grid != null:
		if ctrl_inventory_grid.has_signal("item_selected"):
			ctrl_inventory_grid.item_selected.connect(_on_grid_item_selected)
		if ctrl_inventory_grid.has_signal("item_activated"):
			ctrl_inventory_grid.item_activated.connect(_on_grid_item_activated)

func _unhandled_input(event: InputEvent) -> void:
	"""Handle input for toggling inventory"""
	if event.is_action_pressed(toggle_key):
		toggle_inventory()
		get_viewport().set_input_as_handled()

## Public API Methods

func toggle_inventory() -> void:
	"""Toggle inventory open/closed"""
	if is_open:
		close_inventory()
	else:
		open_inventory()

func open_inventory() -> void:
	"""Open the inventory UI"""
	if is_open:
		return

	visible = true
	is_open = true

	# Pause game if configured
	if pause_game_when_open:
		get_tree().paused = true

	# Update UI
	_update_ui()

	inventory_opened.emit()
	print("InventoryUI: Inventory opened")

func close_inventory() -> void:
	"""Close the inventory UI"""
	if not is_open:
		return

	visible = false
	is_open = false

	# Unpause game if it was paused
	if pause_game_when_open:
		get_tree().paused = false

	inventory_closed.emit()
	print("InventoryUI: Inventory closed")

func set_inventory_manager(manager: InventoryManager) -> void:
	"""Manually set the inventory manager reference"""
	inventory_manager = manager

	# Reconnect signals
	_connect_signals()

	# Link to CtrlInventoryGrid
	if ctrl_inventory_grid != null and inventory_manager != null:
		_link_grid_to_inventory()

func _link_grid_to_inventory() -> void:
	"""Link CtrlInventoryGrid to InventoryManager's inventory"""
	if ctrl_inventory_grid == null or inventory_manager == null:
		return

	# Get the GLoot Inventory node from InventoryManager
	var inventory = inventory_manager.get("inventory")
	if inventory == null:
		push_warning("InventoryUI: Cannot link - InventoryManager has no inventory")
		return

	# Set inventory property on CtrlInventoryGrid
	if ctrl_inventory_grid.has_property("inventory"):
		ctrl_inventory_grid.set("inventory", inventory)
		print("InventoryUI: CtrlInventoryGrid linked to Inventory")
	else:
		push_error("InventoryUI: CtrlInventoryGrid missing 'inventory' property")

## UI Update Methods

func _update_ui() -> void:
	"""Update all UI elements"""
	_update_title()
	_update_capacity()

func _update_title() -> void:
	"""Update title label"""
	if title_label == null:
		return

	var capacity_info = ""
	if inventory_manager != null:
		var capacity = inventory_manager.get_capacity()
		capacity_info = " (%d/%d)" % [capacity["current"], capacity["maximum"]]

	title_label.text = "Inventory" + capacity_info

func _update_capacity() -> void:
	"""Update capacity label"""
	if capacity_label == null:
		return

	if inventory_manager == null:
		capacity_label.text = "Capacity: Unknown"
		return

	var capacity = inventory_manager.get_capacity()
	var percentage = capacity["percentage"]

	# Color code based on capacity
	var color = Color.WHITE
	if percentage >= 90.0:
		color = Color.RED
	elif percentage >= 75.0:
		color = Color.ORANGE
	elif percentage >= 50.0:
		color = Color.YELLOW

	capacity_label.text = "Capacity: %d/%d (%.0f%%)" % [
		capacity["current"],
		capacity["maximum"],
		percentage
	]
	capacity_label.modulate = color

## Signal Handlers

func _on_close_button_pressed() -> void:
	"""Called when close button pressed"""
	close_inventory()

func _on_inventory_changed(item: InventoryItem = null, item_id: String = "") -> void:
	"""Called when inventory contents change"""
	if not is_open:
		return

	_update_ui()

func _on_capacity_changed(current: int, maximum: int) -> void:
	"""Called when inventory capacity changes"""
	if not is_open:
		return

	_update_capacity()

func _on_grid_item_selected(item: InventoryItem) -> void:
	"""Called when item selected in grid"""
	item_selected.emit(item)
	print("InventoryUI: Item selected: %s" % _get_item_name(item))

func _on_grid_item_activated(item: InventoryItem) -> void:
	"""Called when item double-clicked or activated"""
	item_used.emit(item)
	print("InventoryUI: Item activated: %s" % _get_item_name(item))

	# Try to use item if it's consumable
	_try_use_item(item)

## Item Actions

func _try_use_item(item: InventoryItem) -> void:
	"""Try to use/consume an item"""
	if item == null:
		return

	# Get item properties
	var item_type = _get_item_property(item, "type", "")

	if item_type == "consumable":
		_use_consumable_item(item)
	elif item_type == "weapon" or item_type == "armor":
		print("InventoryUI: Equipment items handled by S08 Equipment system")
	else:
		print("InventoryUI: Item type '%s' cannot be used from inventory" % item_type)

func _use_consumable_item(item: InventoryItem) -> void:
	"""Use a consumable item (healing, buff, etc.)"""
	if item == null or inventory_manager == null:
		return

	# Get item effects
	var heal_amount = _get_item_property(item, "heal_amount", 0) as int
	var mana_amount = _get_item_property(item, "mana_amount", 0) as int

	# Apply effects (this would connect to S03 Player stats in full implementation)
	if heal_amount > 0:
		print("InventoryUI: Healing player for %d HP" % heal_amount)
		# TODO: Connect to player health system when implemented

	if mana_amount > 0:
		print("InventoryUI: Restoring %d MP" % mana_amount)
		# TODO: Connect to player mana system when implemented

	# Remove item from inventory (consumed)
	if inventory_manager.has_method("remove_item"):
		inventory_manager.call("remove_item", item)

## Helper Methods

func _get_item_name(item: InventoryItem) -> String:
	"""Get item name"""
	if item == null:
		return "Unknown"

	return _get_item_property(item, "name", "Unknown Item") as String

func _get_item_property(item: InventoryItem, property_name: String, default_value: Variant) -> Variant:
	"""Get property from item"""
	if item == null:
		return default_value

	if item.has_method("get_property"):
		return item.call("get_property", property_name, default_value)
	elif item.has_property(property_name):
		return item.get(property_name)

	return default_value

## Debug Methods

func print_debug_info() -> void:
	"""Print debug information"""
	print("========== INVENTORY UI DEBUG ==========")
	print("Open: %s" % is_open)
	print("Visible: %s" % visible)
	print("CtrlInventoryGrid found: %s" % (ctrl_inventory_grid != null))
	print("InventoryManager found: %s" % (inventory_manager != null))

	if inventory_manager != null:
		var capacity = inventory_manager.get_capacity()
		print("Capacity: %d/%d (%.1f%%)" % [
			capacity["current"],
			capacity["maximum"],
			capacity["percentage"]
		])

	print("=======================================")
