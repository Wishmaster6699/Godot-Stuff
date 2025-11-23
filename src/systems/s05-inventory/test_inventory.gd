# Godot 4.5 | GDScript 4.5
# System: S05 - Inventory System
# Created: 2025-11-18
# Dependencies: S03 (PlayerController), GLoot plugin
# Purpose: Test scene for inventory system - demonstrates pickup, storage, and UI

extends Node2D

## Test scene for S05 Inventory System
## Tests: Item pickup, inventory management, UI display, capacity limits

# References (set up by MCP agent in scene)
@onready var player: PlayerController = $Player
@onready var inventory_ui: InventoryUI = $UI/InventoryUI
@onready var instructions_label: Label = $UI/Instructions
@onready var debug_panel: Control = $UI/DebugPanel
@onready var debug_label: Label = $UI/DebugPanel/DebugLabel

# Test configuration
@export var spawn_test_items: bool = true
@export var auto_open_inventory: bool = false
@export var show_debug_info: bool = true

# Test state
var test_items_spawned: int = 0
var test_items_picked_up: int = 0
var inventory_manager: InventoryManager = null

func _ready() -> void:
	print("TestInventory: Initializing test scene...")

	# Setup instructions
	_setup_instructions()

	# Find inventory manager
	_find_inventory_manager()

	# Connect signals
	_connect_signals()

	# Spawn test items if enabled
	if spawn_test_items:
		_spawn_test_items()

	# Auto-open inventory if configured
	if auto_open_inventory and inventory_ui != null:
		await get_tree().create_timer(1.0).timeout
		inventory_ui.open_inventory()

	# Setup debug panel
	if debug_panel != null:
		debug_panel.visible = show_debug_info

	print("TestInventory: Test scene ready")
	print("  - Player: %s" % (player != null))
	print("  - InventoryUI: %s" % (inventory_ui != null))
	print("  - InventoryManager: %s" % (inventory_manager != null))
	print("  - Test items spawned: %d" % test_items_spawned)

func _setup_instructions() -> void:
	"""Setup instruction text"""
	if instructions_label == null:
		return

	var instructions = """INVENTORY SYSTEM TEST

CONTROLS:
- WASD / Arrow Keys: Move player
- E / Enter: Interact with items
- ESC: Toggle inventory
- D: Debug print inventory
- C: Clear inventory
- T: Test spawn 5 more items

TEST ITEMS:
Walk near glowing items to pick them up.
Press ESC to view inventory.
Test capacity limits (30 slots max).

EXPECTED BEHAVIOR:
- Items picked up automatically or via interaction
- Inventory UI updates in real-time
- Item stacking works correctly
- Inventory prevents overflow when full
"""

	instructions_label.text = instructions

func _find_inventory_manager() -> void:
	"""Find InventoryManager in player node"""
	if player == null:
		push_error("TestInventory: Player node not found!")
		return

	for child in player.get_children():
		if child is InventoryManager:
			inventory_manager = child
			print("TestInventory: Found InventoryManager")
			return

	push_warning("TestInventory: InventoryManager not found in Player")

func _connect_signals() -> void:
	"""Connect signals for test tracking"""
	if inventory_manager != null:
		if inventory_manager.has_signal("item_added"):
			inventory_manager.item_added.connect(_on_item_added)
		if inventory_manager.has_signal("item_removed"):
			inventory_manager.item_removed.connect(_on_item_removed)
		if inventory_manager.has_signal("inventory_full"):
			inventory_manager.inventory_full.connect(_on_inventory_full)

	if inventory_ui != null:
		if inventory_ui.has_signal("inventory_opened"):
			inventory_ui.inventory_opened.connect(_on_inventory_opened)
		if inventory_ui.has_signal("inventory_closed"):
			inventory_ui.inventory_closed.connect(_on_inventory_closed)

func _spawn_test_items() -> void:
	"""Spawn test items around the scene"""
	# This will be fully implemented by MCP agent with actual ItemPickup scenes
	# For now, we just track that items should be spawned

	var test_item_ids = [
		"health_potion",
		"mana_potion",
		"iron_sword",
		"copper_ore",
		"iron_ore",
		"bread",
		"herb_green",
		"gold_coin"
	]

	test_items_spawned = test_item_ids.size()

	print("TestInventory: Test expects %d item pickups in scene" % test_items_spawned)
	print("  Items: %s" % ", ".join(test_item_ids))

func _process(_delta: float) -> void:
	"""Update debug info"""
	if show_debug_info:
		_update_debug_label()

func _unhandled_input(event: InputEvent) -> void:
	"""Handle test input commands"""
	if event.is_action_pressed("ui_text_delete"):  # D key
		_debug_print_inventory()

	if event.is_action_pressed("ui_cancel"):  # ESC
		if event.is_action_pressed("ui_accept"):  # ESC + Enter
			_clear_inventory()

	if event.is_action_pressed("ui_text_completion_query"):  # T key
		_spawn_more_items()

func _update_debug_label() -> void:
	"""Update debug label with current stats"""
	if debug_label == null or inventory_manager == null:
		return

	var capacity = inventory_manager.get_capacity()
	var item_count = inventory_manager.get_total_item_count()

	var debug_text = """DEBUG INFO:
Items Spawned: %d
Items Picked Up: %d
Inventory: %d/%d (%.1f%%)
Item Stacks: %d

Press D: Print inventory
Press C: Clear inventory
Press T: Spawn 5 more items
""" % [
		test_items_spawned,
		test_items_picked_up,
		capacity["current"],
		capacity["maximum"],
		capacity["percentage"],
		item_count
	]

	debug_label.text = debug_text

func _debug_print_inventory() -> void:
	"""Print inventory contents to console"""
	if inventory_manager == null:
		print("TestInventory: No InventoryManager found")
		return

	print("\n" + "=".repeat(50))
	print("INVENTORY DEBUG PRINT")
	print("=".repeat(50))

	inventory_manager.print_inventory()

	print("=".repeat(50) + "\n")

func _clear_inventory() -> void:
	"""Clear all items from inventory"""
	if inventory_manager == null:
		return

	inventory_manager.clear_inventory()
	test_items_picked_up = 0
	print("TestInventory: Inventory cleared")

func _spawn_more_items() -> void:
	"""Spawn 5 more test items"""
	print("TestInventory: Spawning 5 more test items...")

	# This would create more ItemPickup instances dynamically
	# For now, just a placeholder for MCP agent to implement

	var spawn_positions = [
		Vector2(300, 200),
		Vector2(500, 200),
		Vector2(400, 300),
		Vector2(350, 400),
		Vector2(450, 400)
	]

	var spawn_items = [
		"health_potion",
		"mana_potion",
		"copper_ore",
		"iron_ore",
		"gold_coin"
	]

	# MCP agent will implement actual spawning
	test_items_spawned += 5

	print("  Total test items available: %d" % test_items_spawned)

## Signal Handlers

func _on_item_added(item: InventoryItem, item_id: String) -> void:
	"""Called when item added to inventory"""
	test_items_picked_up += 1
	print("TestInventory: Item picked up - %s (Total: %d)" % [item_id, test_items_picked_up])

	# Show feedback
	_show_pickup_feedback(item_id)

func _on_item_removed(item: InventoryItem, item_id: String) -> void:
	"""Called when item removed from inventory"""
	print("TestInventory: Item removed - %s" % item_id)

func _on_inventory_full() -> void:
	"""Called when inventory is full"""
	print("TestInventory: INVENTORY FULL - Cannot add more items!")

	# Show visual feedback
	_show_full_inventory_feedback()

func _on_inventory_opened() -> void:
	"""Called when inventory UI opened"""
	print("TestInventory: Inventory UI opened")

func _on_inventory_closed() -> void:
	"""Called when inventory UI closed"""
	print("TestInventory: Inventory UI closed")

## Feedback Methods

func _show_pickup_feedback(item_id: String) -> void:
	"""Show visual feedback when item picked up"""
	# This would create a popup notification
	# MCP agent can enhance with actual UI
	print("  [Feedback] Picked up: %s" % item_id.replace("_", " ").capitalize())

func _show_full_inventory_feedback() -> void:
	"""Show visual feedback when inventory is full"""
	# This would create a warning notification
	# MCP agent can enhance with actual UI
	print("  [WARNING] Inventory is full! (30/30 slots)")

## Test Validation Methods

func run_automated_tests() -> Dictionary:
	"""Run automated tests and return results"""
	var results = {
		"total_tests": 0,
		"passed": 0,
		"failed": 0,
		"tests": []
	}

	# Test 1: InventoryManager exists
	results.total_tests += 1
	if inventory_manager != null:
		results.passed += 1
		results.tests.append({"name": "InventoryManager exists", "passed": true})
	else:
		results.failed += 1
		results.tests.append({"name": "InventoryManager exists", "passed": false})

	# Test 2: InventoryUI exists
	results.total_tests += 1
	if inventory_ui != null:
		results.passed += 1
		results.tests.append({"name": "InventoryUI exists", "passed": true})
	else:
		results.failed += 1
		results.tests.append({"name": "InventoryUI exists", "passed": false})

	# Test 3: Player exists
	results.total_tests += 1
	if player != null:
		results.passed += 1
		results.tests.append({"name": "Player exists", "passed": true})
	else:
		results.failed += 1
		results.tests.append({"name": "Player exists", "passed": false})

	# Test 4: Inventory capacity correct
	results.total_tests += 1
	if inventory_manager != null:
		var capacity = inventory_manager.get_capacity()
		if capacity["maximum"] == 30:
			results.passed += 1
			results.tests.append({"name": "Inventory capacity = 30", "passed": true})
		else:
			results.failed += 1
			results.tests.append({"name": "Inventory capacity = 30", "passed": false})

	print("\n========== AUTOMATED TEST RESULTS ==========")
	print("Total: %d | Passed: %d | Failed: %d" % [results.total_tests, results.passed, results.failed])
	for test in results.tests:
		var status = "✓ PASS" if test.passed else "✗ FAIL"
		print("  %s - %s" % [status, test.name])
	print("===========================================\n")

	return results
