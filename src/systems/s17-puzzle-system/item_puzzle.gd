# Godot 4.5 | GDScript 4.5
# System: S17 - Puzzle System - Item-Locked Puzzles
# Created: 2025-11-18
# Dependencies: S05 (Inventory System)
# Purpose: Item-locked puzzles (require specific inventory items like keys, orbs, gems)

extends Puzzle
class_name ItemPuzzle

## Item puzzle specific signals

## Emitted when correct item is used
signal correct_item_used(item_id: String)

## Emitted when wrong item is used
signal wrong_item_used(item_id: String)

## Emitted when item is consumed
signal item_consumed(item_id: String)

## Emitted when all required items are collected
signal all_items_collected()

## Item puzzle subtypes
enum ItemPuzzleType {
	SINGLE_KEY,        # Single key unlocks door
	MULTI_KEY,         # Multiple keys required
	ORB_COLLECTION,    # Collect specific orbs
	GEM_SOCKET,        # Place gems in correct sockets
	ITEM_COMBINATION   # Combine multiple items
}

@export var item_puzzle_type: ItemPuzzleType = ItemPuzzleType.SINGLE_KEY
@export var consume_items: bool = true  # Whether to remove items from inventory when used

# Puzzle elements
var locks: Dictionary = {}  # lock_id -> Node2D (door, chest, gate)
var sockets: Dictionary = {}  # socket_id -> Node2D (gem sockets, orb pedestals)

# State tracking
var used_items: Array[String] = []
var placed_items: Dictionary = {}  # socket_id -> item_id
var required_items: Array = []  # Loaded from solution_data


func _ready() -> void:
	puzzle_type = PuzzleType.ITEM_LOCKED
	super._ready()


## Initialize item puzzle
func _initialize_puzzle() -> void:
	super._initialize_puzzle()

	# Load required items from solution data
	required_items = solution_data.get("required_items", [])

	# Find puzzle elements in scene tree
	_find_puzzle_elements()

	# Setup based on item puzzle type
	match item_puzzle_type:
		ItemPuzzleType.SINGLE_KEY:
			_setup_single_key_puzzle()
		ItemPuzzleType.MULTI_KEY:
			_setup_multi_key_puzzle()
		ItemPuzzleType.ORB_COLLECTION:
			_setup_orb_collection_puzzle()
		ItemPuzzleType.GEM_SOCKET:
			_setup_gem_socket_puzzle()
		ItemPuzzleType.ITEM_COMBINATION:
			_setup_item_combination_puzzle()


## Find all puzzle elements in the scene tree
func _find_puzzle_elements() -> void:
	# Find locks (Node2D in "PuzzleLocks" group)
	var lock_nodes: Array[Node] = get_tree().get_nodes_in_group("puzzle_locks")
	for lock in lock_nodes:
		if lock.has_meta("lock_id"):
			var lock_id: String = lock.get_meta("lock_id")
			locks[lock_id] = lock

	# Find sockets (Node2D in "ItemSockets" group)
	var socket_nodes: Array[Node] = get_tree().get_nodes_in_group("item_sockets")
	for socket in socket_nodes:
		if socket.has_meta("socket_id"):
			var socket_id: String = socket.get_meta("socket_id")
			sockets[socket_id] = socket


## Setup single key puzzle
func _setup_single_key_puzzle() -> void:
	print("ItemPuzzle: Setting up single key puzzle")
	# Solution data should contain single required key
	# Example: {"required_items": ["bronze_key"]}


## Setup multi key puzzle
func _setup_multi_key_puzzle() -> void:
	print("ItemPuzzle: Setting up multi key puzzle")
	# Solution data should contain multiple required keys
	# Example: {"required_items": ["bronze_key", "silver_key", "gold_key"]}


## Setup orb collection puzzle
func _setup_orb_collection_puzzle() -> void:
	print("ItemPuzzle: Setting up orb collection puzzle")
	# Solution data should contain orb IDs
	# Example: {"required_items": ["red_orb", "blue_orb", "green_orb"]}


## Setup gem socket puzzle
func _setup_gem_socket_puzzle() -> void:
	print("ItemPuzzle: Setting up gem socket puzzle")
	# Solution data should contain gem-socket mappings
	# Example: {"socket_mapping": {"socket_1": "ruby", "socket_2": "sapphire", "socket_3": "emerald"}}


## Setup item combination puzzle
func _setup_item_combination_puzzle() -> void:
	print("ItemPuzzle: Setting up item combination puzzle")
	# Solution data should contain items to combine
	# Example: {"required_items": ["gear_a", "gear_b", "power_cell"], "combine_order": true}


## Check if puzzle solution is correct
func check_solution() -> bool:
	match item_puzzle_type:
		ItemPuzzleType.SINGLE_KEY:
			return _check_single_key_solution()
		ItemPuzzleType.MULTI_KEY:
			return _check_multi_key_solution()
		ItemPuzzleType.ORB_COLLECTION:
			return _check_orb_collection_solution()
		ItemPuzzleType.GEM_SOCKET:
			return _check_gem_socket_solution()
		ItemPuzzleType.ITEM_COMBINATION:
			return _check_item_combination_solution()

	return false


## Check single key solution
func _check_single_key_solution() -> bool:
	if required_items.is_empty():
		return false

	var required_key: String = required_items[0]
	return required_key in used_items


## Check multi key solution
func _check_multi_key_solution() -> bool:
	# Check if all required keys have been used
	if used_items.size() != required_items.size():
		return false

	for item_id in required_items:
		if not item_id in used_items:
			return false

	return true


## Check orb collection solution
func _check_orb_collection_solution() -> bool:
	# Check if player has all required orbs in inventory
	if inventory_manager == null:
		push_error("ItemPuzzle: InventoryManager not found")
		return false

	for orb_id in required_items:
		if not inventory_manager.has_method("has_item"):
			push_error("ItemPuzzle: InventoryManager missing has_item method")
			return false

		if not inventory_manager.has_item(orb_id):
			return false

	return true


## Check gem socket solution
func _check_gem_socket_solution() -> bool:
	var socket_mapping: Dictionary = solution_data.get("socket_mapping", {})

	# Check if all sockets have correct gems
	if placed_items.size() != socket_mapping.size():
		return false

	for socket_id in socket_mapping.keys():
		var required_gem: String = socket_mapping[socket_id]
		if not placed_items.has(socket_id):
			return false
		if placed_items[socket_id] != required_gem:
			return false

	return true


## Check item combination solution
func _check_item_combination_solution() -> bool:
	var combine_order: bool = solution_data.get("combine_order", false)

	if combine_order:
		# Order matters - check sequence
		if used_items.size() != required_items.size():
			return false

		for i in range(required_items.size()):
			if used_items[i] != required_items[i]:
				return false
	else:
		# Order doesn't matter - check all items used
		if used_items.size() != required_items.size():
			return false

		for item_id in required_items:
			if not item_id in used_items:
				return false

	return true


## Use an item on the puzzle (called from interaction system)
func use_item(item_id: String) -> bool:
	if not is_active or is_solved:
		return false

	# Check if player has the item in inventory
	if not _player_has_item(item_id):
		print("ItemPuzzle: Player does not have item %s" % item_id)
		return false

	# Check if item is required for this puzzle
	if not item_id in required_items:
		print("ItemPuzzle: Item %s not required for this puzzle" % item_id)
		wrong_item_used.emit(item_id)
		fail_puzzle("wrong_item")
		return false

	# Use the item
	used_items.append(item_id)
	correct_item_used.emit(item_id)
	print("ItemPuzzle: Item %s used (%d/%d)" % [item_id, used_items.size(), required_items.size()])

	# Consume item if configured
	if consume_items:
		_consume_item(item_id)

	# Check if all items collected
	if used_items.size() == required_items.size():
		all_items_collected.emit()

	# Check solution
	if check_solution():
		solve_puzzle()
		return true

	return true


## Place item in a socket (for gem socket puzzles)
func place_item_in_socket(socket_id: String, item_id: String) -> bool:
	if not is_active or is_solved:
		return false

	if not sockets.has(socket_id):
		print("ItemPuzzle: Socket %s not found" % socket_id)
		return false

	# Check if player has the item
	if not _player_has_item(item_id):
		print("ItemPuzzle: Player does not have item %s" % item_id)
		return false

	# Place item in socket
	placed_items[socket_id] = item_id
	correct_item_used.emit(item_id)
	print("ItemPuzzle: Placed %s in socket %s" % [item_id, socket_id])

	# Consume item if configured
	if consume_items:
		_consume_item(item_id)

	# Visual feedback - update socket sprite/color
	_update_socket_visual(socket_id, item_id)

	# Check solution
	if check_solution():
		solve_puzzle()
		return true

	return true


## Check if player has item in inventory
func _player_has_item(item_id: String) -> bool:
	if inventory_manager == null:
		push_error("ItemPuzzle: InventoryManager not found")
		return false

	if not inventory_manager.has_method("has_item"):
		push_error("ItemPuzzle: InventoryManager missing has_item method")
		return false

	return inventory_manager.has_item(item_id)


## Consume item from inventory
func _consume_item(item_id: String) -> void:
	if inventory_manager == null:
		return

	# Get all items and remove first matching item
	if not inventory_manager.has_method("get_all_items"):
		return

	var all_items: Array = inventory_manager.get_all_items()
	for item in all_items:
		if item == null:
			continue

		# Check if this is the item we want to consume
		var proto_id: String = ""
		if item.has_method("get_prototype_id"):
			proto_id = item.call("get_prototype_id")
		elif item.has_property("prototype_id"):
			proto_id = item.get("prototype_id")

		if proto_id == item_id:
			# Remove this item
			if inventory_manager.has_method("remove_item"):
				inventory_manager.remove_item(item)
				item_consumed.emit(item_id)
				print("ItemPuzzle: Consumed item %s from inventory" % item_id)
			break


## Update socket visual when item is placed
func _update_socket_visual(socket_id: String, item_id: String) -> void:
	if not sockets.has(socket_id):
		return

	var socket: Node = sockets[socket_id]

	# Set metadata for visual state
	socket.set_meta("placed_item", item_id)
	socket.set_meta("is_filled", true)

	# TODO: Update sprite/color based on item
	# This would be handled by the socket's visual script


## Reset puzzle to initial state
func _on_puzzle_reset() -> void:
	used_items.clear()
	placed_items.clear()

	# Clear socket visuals
	for socket_id in sockets.keys():
		var socket: Node = sockets[socket_id]
		socket.set_meta("placed_item", "")
		socket.set_meta("is_filled", false)
		_update_socket_visual(socket_id, "")


## Unlock a lock (called when puzzle is solved)
func unlock_lock(lock_id: String) -> void:
	if not locks.has(lock_id):
		return

	var lock: Node = locks[lock_id]
	lock.set_meta("is_locked", false)

	# Trigger unlock animation/effect
	if lock.has_method("unlock"):
		lock.call("unlock")

	print("ItemPuzzle: Lock %s unlocked" % lock_id)


## Solve puzzle (override to unlock all locks)
func solve_puzzle() -> void:
	super.solve_puzzle()

	# Unlock all locks
	for lock_id in locks.keys():
		unlock_lock(lock_id)


## Get puzzle progress (0.0 to 1.0)
func get_progress() -> float:
	if is_solved:
		return 1.0

	match item_puzzle_type:
		ItemPuzzleType.SINGLE_KEY, ItemPuzzleType.MULTI_KEY, ItemPuzzleType.ITEM_COMBINATION:
			if required_items.is_empty():
				return 0.0
			return float(used_items.size()) / float(required_items.size())

		ItemPuzzleType.ORB_COLLECTION:
			if required_items.is_empty():
				return 0.0
			# Count how many orbs player has
			var collected_count: int = 0
			for orb_id in required_items:
				if _player_has_item(orb_id):
					collected_count += 1
			return float(collected_count) / float(required_items.size())

		ItemPuzzleType.GEM_SOCKET:
			var socket_mapping: Dictionary = solution_data.get("socket_mapping", {})
			if socket_mapping.is_empty():
				return 0.0
			# Count correctly placed gems
			var correct_count: int = 0
			for socket_id in socket_mapping.keys():
				var required_gem: String = socket_mapping[socket_id]
				if placed_items.get(socket_id, "") == required_gem:
					correct_count += 1
			return float(correct_count) / float(socket_mapping.size())

	return 0.0


## Get hint for puzzle
func get_hint() -> String:
	var base_hint: String = super.get_hint()

	if base_hint != "No hint available":
		return base_hint

	# Provide item-specific hints
	var missing_items: Array = []
	for item_id in required_items:
		if not item_id in used_items:
			missing_items.append(item_id)

	if missing_items.is_empty():
		return "You have all the required items!"

	return "Required items: %s" % ", ".join(missing_items)
