# Godot 4.5 | GDScript 4.5
# System: S06 - Save/Load System
# Created: 2025-11-18
# Dependencies: S03 (Player), S05 (Inventory)
# Purpose: Manages game state persistence with multiple save slots using JSON serialization

extends Node

class_name SaveManagerImpl

## Signals for save/load events

## Emitted when a save operation completes successfully
signal save_completed(slot_id: int, save_path: String)

## Emitted when a save operation fails
signal save_failed(slot_id: int, error_message: String)

## Emitted when a load operation completes successfully
signal load_completed(slot_id: int)

## Emitted when a load operation fails
signal load_failed(slot_id: int, error_message: String)

## Emitted when a save file is deleted
signal save_deleted(slot_id: int)

# Configuration
const SAVE_DIR: String = "user://saves/"
const SAVE_FILE_PREFIX: String = "save_slot_"
const SAVE_FILE_EXTENSION: String = ".json"
const GAME_VERSION: String = "0.1.0"
const MAX_SAVE_SLOTS: int = 3

# Registered saveable systems
var registered_systems: Dictionary = {}  # system_name -> Node reference

# Session tracking
var current_play_time: float = 0.0
var session_start_time: float = 0.0
var current_location: String = "Unknown"

func _ready() -> void:
	print("SaveManager: Initializing...")
	_ensure_save_directory_exists()
	session_start_time = Time.get_unix_time_from_system()
	print("SaveManager: Ready (Max slots: %d, Save dir: %s)" % [MAX_SAVE_SLOTS, SAVE_DIR])

func _process(delta: float) -> void:
	"""Track play time"""
	current_play_time += delta

func _ensure_save_directory_exists() -> void:
	"""Create saves directory if it doesn't exist"""
	var dir = DirAccess.open("user://")
	if dir == null:
		push_error("SaveManager: Failed to access user:// directory")
		return

	if not dir.dir_exists("saves"):
		var error = dir.make_dir("saves")
		if error != OK:
			push_error("SaveManager: Failed to create saves directory: %d" % error)
		else:
			print("SaveManager: Created saves directory at %s" % SAVE_DIR)

## Public API Methods

func save_game(slot_id: int) -> bool:
	"""
	Save current game state to specified slot (1-3)
	Returns true if successful, false otherwise
	"""
	if not _is_valid_slot_id(slot_id):
		push_error("SaveManager: Invalid slot ID %d (must be 1-%d)" % [slot_id, MAX_SAVE_SLOTS])
		save_failed.emit(slot_id, "Invalid slot ID")
		return false

	print("SaveManager: Saving game to slot %d..." % slot_id)

	# Gather data from all registered systems
	var save_data: Dictionary = {
		"save_file": {
			"metadata": _generate_metadata(slot_id),
			"player": _collect_player_data(),
			"inventory": _collect_inventory_data(),
			"progress": _collect_progress_data(),
			"world_state": _collect_world_state_data(),
			"custom_systems": _collect_custom_system_data()
		}
	}

	# Serialize to JSON
	var json_string = JSON.stringify(save_data, "\t")

	# Write to file
	var save_path = _get_save_path(slot_id)
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	if file == null:
		var error_code = FileAccess.get_open_error()
		push_error("SaveManager: Failed to open save file for writing: %d" % error_code)
		save_failed.emit(slot_id, "Failed to open file for writing")
		return false

	file.store_string(json_string)
	file.close()

	print("SaveManager: Save completed successfully to %s" % save_path)
	save_completed.emit(slot_id, save_path)
	return true

func load_game(slot_id: int) -> bool:
	"""
	Load game state from specified slot (1-3)
	Returns true if successful, false otherwise
	"""
	if not _is_valid_slot_id(slot_id):
		push_error("SaveManager: Invalid slot ID %d (must be 1-%d)" % [slot_id, MAX_SAVE_SLOTS])
		load_failed.emit(slot_id, "Invalid slot ID")
		return false

	var save_path = _get_save_path(slot_id)

	# Check if save file exists
	if not FileAccess.file_exists(save_path):
		push_warning("SaveManager: Save file not found at %s" % save_path)
		load_failed.emit(slot_id, "Save file not found")
		return false

	print("SaveManager: Loading game from slot %d..." % slot_id)

	# Read file
	var file = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		var error_code = FileAccess.get_open_error()
		push_error("SaveManager: Failed to open save file for reading: %d" % error_code)
		load_failed.emit(slot_id, "Failed to open file")
		return false

	var json_string = file.get_as_text()
	file.close()

	# Parse JSON
	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("SaveManager: JSON parse error at line %d: %s" % [json.get_error_line(), json.get_error_message()])
		load_failed.emit(slot_id, "Corrupted save file (JSON parse error)")
		return false

	var data = json.data as Dictionary
	if data.is_empty() or not data.has("save_file"):
		push_error("SaveManager: Invalid save file structure")
		load_failed.emit(slot_id, "Invalid save file structure")
		return false

	var save_file = data["save_file"] as Dictionary

	# Restore data to all registered systems
	_restore_player_data(save_file.get("player", {}))
	_restore_inventory_data(save_file.get("inventory", {}))
	_restore_progress_data(save_file.get("progress", {}))
	_restore_world_state_data(save_file.get("world_state", {}))
	_restore_custom_system_data(save_file.get("custom_systems", {}))

	# Update session tracking
	var metadata = save_file.get("metadata", {}) as Dictionary
	current_play_time = metadata.get("play_time_seconds", 0.0) as float
	current_location = metadata.get("location", "Unknown") as String

	print("SaveManager: Load completed successfully from slot %d" % slot_id)
	load_completed.emit(slot_id)
	return true

func delete_save(slot_id: int) -> bool:
	"""
	Delete save file for specified slot (1-3)
	Returns true if successful, false otherwise
	"""
	if not _is_valid_slot_id(slot_id):
		push_error("SaveManager: Invalid slot ID %d (must be 1-%d)" % [slot_id, MAX_SAVE_SLOTS])
		return false

	var save_path = _get_save_path(slot_id)

	if not FileAccess.file_exists(save_path):
		push_warning("SaveManager: Cannot delete - save file not found at %s" % save_path)
		return false

	var dir = DirAccess.open(SAVE_DIR)
	if dir == null:
		push_error("SaveManager: Failed to access save directory")
		return false

	var error = dir.remove(save_path)
	if error != OK:
		push_error("SaveManager: Failed to delete save file: %d" % error)
		return false

	print("SaveManager: Deleted save file from slot %d" % slot_id)
	save_deleted.emit(slot_id)
	return true

func get_save_slots() -> Array[Dictionary]:
	"""
	Get metadata for all save slots
	Returns array of dictionaries with save metadata
	"""
	var slots: Array[Dictionary] = []

	for slot_id in range(1, MAX_SAVE_SLOTS + 1):
		var slot_info: Dictionary = {
			"slot_id": slot_id,
			"exists": false,
			"timestamp": "",
			"play_time_seconds": 0.0,
			"location": "",
			"game_version": ""
		}

		var save_path = _get_save_path(slot_id)
		if FileAccess.file_exists(save_path):
			var metadata = _read_save_metadata(slot_id)
			if not metadata.is_empty():
				slot_info["exists"] = true
				slot_info["timestamp"] = metadata.get("timestamp", "")
				slot_info["play_time_seconds"] = metadata.get("play_time_seconds", 0.0)
				slot_info["location"] = metadata.get("location", "")
				slot_info["game_version"] = metadata.get("game_version", "")

		slots.append(slot_info)

	return slots

func register_saveable(system: Node, system_name: String) -> void:
	"""
	Register a system/node for save/load operations
	System must implement: save_state() -> Dictionary and load_state(data: Dictionary)
	"""
	if system == null:
		push_error("SaveManager: Cannot register null system")
		return

	if not system.has_method("save_state"):
		push_error("SaveManager: System '%s' missing save_state() method" % system_name)
		return

	if not system.has_method("load_state"):
		push_error("SaveManager: System '%s' missing load_state() method" % system_name)
		return

	registered_systems[system_name] = system
	print("SaveManager: Registered saveable system '%s'" % system_name)

func unregister_saveable(system_name: String) -> void:
	"""Unregister a saveable system"""
	if system_name in registered_systems:
		registered_systems.erase(system_name)
		print("SaveManager: Unregistered system '%s'" % system_name)

func set_current_location(location: String) -> void:
	"""Set current location name for save metadata"""
	current_location = location

func get_current_play_time() -> float:
	"""Get current play time in seconds"""
	return current_play_time

func has_save(slot_id: int) -> bool:
	"""Check if a save file exists for the given slot"""
	if not _is_valid_slot_id(slot_id):
		return false
	return FileAccess.file_exists(_get_save_path(slot_id))

## Private Helper Methods

func _is_valid_slot_id(slot_id: int) -> bool:
	"""Validate slot ID is in range 1-3"""
	return slot_id >= 1 and slot_id <= MAX_SAVE_SLOTS

func _get_save_path(slot_id: int) -> String:
	"""Get full path for save file"""
	return SAVE_DIR + SAVE_FILE_PREFIX + str(slot_id) + SAVE_FILE_EXTENSION

func _generate_metadata(slot_id: int) -> Dictionary:
	"""Generate metadata section for save file"""
	return {
		"save_slot": slot_id,
		"timestamp": Time.get_datetime_string_from_system(false, true),
		"play_time_seconds": current_play_time,
		"game_version": GAME_VERSION,
		"location": current_location
	}

func _read_save_metadata(slot_id: int) -> Dictionary:
	"""Read only metadata from a save file without loading the entire game state"""
	var save_path = _get_save_path(slot_id)

	if not FileAccess.file_exists(save_path):
		return {}

	var file = FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		return {}

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		return {}

	var data = json.data as Dictionary
	if data.has("save_file"):
		var save_file = data["save_file"] as Dictionary
		return save_file.get("metadata", {})

	return {}

## Data Collection Methods

func _collect_player_data() -> Dictionary:
	"""Collect player state data"""
	var player_data: Dictionary = {
		"position": {"x": 0.0, "y": 0.0},
		"stats": {
			"level": 1,
			"hp": 100,
			"max_hp": 100,
			"xp": 0
		},
		"state": "idle",
		"facing_direction": {"x": 0.0, "y": 1.0}
	}

	# Try to get player from scene tree
	var player: Node = _find_player_node()
	if player != null:
		# Get position
		if player is Node2D:
			var pos = (player as Node2D).global_position
			player_data["position"] = {"x": pos.x, "y": pos.y}

		# Get state if available
		if player.has_method("get_current_state"):
			player_data["state"] = player.call("get_current_state")

		# Get facing direction if available
		if player.has_method("get_facing_direction"):
			var facing = player.call("get_facing_direction") as Vector2
			player_data["facing_direction"] = {"x": facing.x, "y": facing.y}

		# Call save_state if player is registered as saveable
		if player.has_method("save_state"):
			var custom_data = player.call("save_state") as Dictionary
			if not custom_data.is_empty():
				player_data.merge(custom_data, true)

	return player_data

func _collect_inventory_data() -> Dictionary:
	"""Collect inventory state data"""
	var inventory_data: Dictionary = {
		"items": []
	}

	# Try to find InventoryManager in scene tree
	var inventory: Node = _find_inventory_manager()
	if inventory != null:
		# Use InventoryManager's serialize method (S05 already has this)
		if inventory.has_method("serialize"):
			var serialized = inventory.call("serialize") as Dictionary
			inventory_data.merge(serialized, true)

		# Fallback: get items manually
		if inventory.has_method("get_all_items") and inventory_data["items"].is_empty():
			var items = inventory.call("get_all_items") as Array
			var items_array: Array = []
			for item in items:
				if item != null:
					var item_id = ""
					var quantity = 1

					# Try to get item ID
					if item.has_method("get_prototype_id"):
						item_id = item.call("get_prototype_id")
					elif item.has_property("prototype_id"):
						item_id = item.get("prototype_id")

					# Try to get quantity
					if item.has_method("get_property"):
						quantity = item.call("get_property", "quantity", 1)
					elif item.has_property("quantity"):
						quantity = item.get("quantity")

					items_array.append({"id": item_id, "quantity": quantity})

			inventory_data["items"] = items_array

	return inventory_data

func _collect_progress_data() -> Dictionary:
	"""Collect progress/quest data"""
	var progress_data: Dictionary = {
		"flags": [],
		"quests_active": [],
		"quests_completed": []
	}

	# Check if there's a registered progress/quest system
	if "progress" in registered_systems:
		var system = registered_systems["progress"]
		if system.has_method("save_state"):
			var custom_data = system.call("save_state") as Dictionary
			progress_data.merge(custom_data, true)

	return progress_data

func _collect_world_state_data() -> Dictionary:
	"""Collect world state data (doors, items collected, etc.)"""
	var world_state: Dictionary = {
		"doors_unlocked": [],
		"items_collected": [],
		"bosses_defeated": [],
		"areas_discovered": []
	}

	# Check if there's a registered world state system
	if "world_state" in registered_systems:
		var system = registered_systems["world_state"]
		if system.has_method("save_state"):
			var custom_data = system.call("save_state") as Dictionary
			world_state.merge(custom_data, true)

	return world_state

func _collect_custom_system_data() -> Dictionary:
	"""Collect data from all other registered systems"""
	var custom_data: Dictionary = {}

	# Skip built-in systems (player, inventory, progress, world_state)
	var skip_systems = ["player", "inventory", "progress", "world_state"]

	for system_name in registered_systems.keys():
		if system_name in skip_systems:
			continue

		var system = registered_systems[system_name]
		if system != null and system.has_method("save_state"):
			custom_data[system_name] = system.call("save_state")

	return custom_data

## Data Restoration Methods

func _restore_player_data(data: Dictionary) -> void:
	"""Restore player state from save data"""
	if data.is_empty():
		return

	var player: Node = _find_player_node()
	if player == null:
		push_warning("SaveManager: Could not find player node to restore data")
		return

	# Restore position
	if data.has("position") and player is Node2D:
		var pos_dict = data["position"] as Dictionary
		var position = Vector2(pos_dict.get("x", 0.0), pos_dict.get("y", 0.0))
		(player as Node2D).global_position = position
		print("SaveManager: Restored player position: %v" % position)

	# Restore state
	if data.has("state") and player.has_method("change_state_external"):
		player.call("change_state_external", data["state"])

	# Call load_state if player is registered as saveable
	if player.has_method("load_state"):
		player.call("load_state", data)

func _restore_inventory_data(data: Dictionary) -> void:
	"""Restore inventory state from save data"""
	if data.is_empty():
		return

	var inventory: Node = _find_inventory_manager()
	if inventory == null:
		push_warning("SaveManager: Could not find InventoryManager to restore data")
		return

	# Use InventoryManager's deserialize method (S05 already has this)
	if inventory.has_method("deserialize"):
		var success = inventory.call("deserialize", data) as bool
		if success:
			print("SaveManager: Restored inventory data")
		else:
			push_warning("SaveManager: Failed to deserialize inventory data")
	else:
		push_warning("SaveManager: InventoryManager missing deserialize method")

func _restore_progress_data(data: Dictionary) -> void:
	"""Restore progress/quest data from save"""
	if data.is_empty():
		return

	if "progress" in registered_systems:
		var system = registered_systems["progress"]
		if system.has_method("load_state"):
			system.call("load_state", data)
			print("SaveManager: Restored progress data")

func _restore_world_state_data(data: Dictionary) -> void:
	"""Restore world state data from save"""
	if data.is_empty():
		return

	if "world_state" in registered_systems:
		var system = registered_systems["world_state"]
		if system.has_method("load_state"):
			system.call("load_state", data)
			print("SaveManager: Restored world state data")

func _restore_custom_system_data(data: Dictionary) -> void:
	"""Restore data to all custom registered systems"""
	if data.is_empty():
		return

	for system_name in data.keys():
		if system_name in registered_systems:
			var system = registered_systems[system_name]
			if system != null and system.has_method("load_state"):
				var system_data = data[system_name] as Dictionary
				system.call("load_state", system_data)
				print("SaveManager: Restored data for system '%s'" % system_name)

## Node Finding Helpers

func _find_player_node() -> Node:
	"""Find player node in scene tree"""
	# Try to find by class name
	var players = get_tree().get_nodes_in_group("player")
	if not players.is_empty():
		return players[0]

	# Try to find by type
	var root = get_tree().root
	for child in root.get_children():
		var found = _find_node_by_class_recursive(child, "PlayerController")
		if found != null:
			return found

	return null

func _find_inventory_manager() -> Node:
	"""Find InventoryManager in scene tree"""
	# Try to find by class name
	var managers = get_tree().get_nodes_in_group("inventory_manager")
	if not managers.is_empty():
		return managers[0]

	# Try to find by type
	var root = get_tree().root
	for child in root.get_children():
		var found = _find_node_by_class_recursive(child, "InventoryManager")
		if found != null:
			return found

	return null

func _find_node_by_class_recursive(node: Node, class_name: String) -> Node:
	"""Recursively find node by class name"""
	if node == null:
		return null

	# Check if node's script has the class name
	var script = node.get_script()
	if script != null:
		var script_class = script.get_global_name()
		if script_class == class_name:
			return node

	# Search children
	for child in node.get_children():
		var found = _find_node_by_class_recursive(child, class_name)
		if found != null:
			return found

	return null

## Debug Methods

func print_save_slots() -> void:
	"""Debug method to print all save slot information"""
	print("=".repeat(60))
	print("SAVE SLOTS")
	print("=".repeat(60))

	var slots = get_save_slots()
	for slot in slots:
		var slot_id = slot["slot_id"]
		print("\n[Slot %d]" % slot_id)
		if slot["exists"]:
			print("  Exists: Yes")
			print("  Timestamp: %s" % slot["timestamp"])
			print("  Play Time: %.1f seconds (%.1f minutes)" % [slot["play_time_seconds"], slot["play_time_seconds"] / 60.0])
			print("  Location: %s" % slot["location"])
			print("  Version: %s" % slot["game_version"])
		else:
			print("  Exists: No")

	print("\n" + "=".repeat(60))

func print_registered_systems() -> void:
	"""Debug method to print all registered saveable systems"""
	print("=".repeat(60))
	print("REGISTERED SAVEABLE SYSTEMS")
	print("=".repeat(60))

	if registered_systems.is_empty():
		print("  (None registered)")
	else:
		for system_name in registered_systems.keys():
			var system = registered_systems[system_name]
			var system_type = system.get_class() if system != null else "null"
			print("  - %s (%s)" % [system_name, system_type])

	print("=".repeat(60))
