# Godot 4.5 | GDScript 4.5
# System: S22 - Complex NPC System
# Created: 2025-11-18
# Dependencies: S21 (Alignment), S03 (Player), S04 (Combat)
#
# NPCBase - Base class for all NPCs with dialogue, relationships, and schedules

class_name NPCBase extends CharacterBody2D

## ═══════════════════════════════════════════════════════════════════════════
## SIGNALS
## ═══════════════════════════════════════════════════════════════════════════

## Emitted when NPC relationship value changes
signal relationship_changed(npc_id: String, new_value: int, old_value: int, reason: String)

## Emitted when dialogue with this NPC starts
signal dialogue_started(npc_id: String)

## Emitted when dialogue with this NPC ends
signal dialogue_ended(npc_id: String)

## Emitted when dialogue triggers a quest
signal quest_triggered(quest_id: String, npc_id: String)

## Emitted when NPC changes location/activity based on schedule
signal schedule_changed(npc_id: String, location: String, activity: String)

## Emitted when relationship crosses a threshold
signal relationship_threshold_crossed(npc_id: String, threshold_name: String, new_value: int)

## ═══════════════════════════════════════════════════════════════════════════
## CONFIGURATION
## ═══════════════════════════════════════════════════════════════════════════

## Unique identifier for this NPC (e.g., "elder", "shopkeeper")
@export var npc_id: String = ""

## Display name for this NPC
@export var npc_name: String = ""

## Path to dialogue file (res://path/to/dialogue.dialogue)
@export var dialogue_file_path: String = ""

## Alignment preference: "authentic", "algorithmic", or "neutral"
@export var alignment_preference: String = "neutral"

## Starting relationship value (0-100)
@export var starting_relationship: int = 50

## ═══════════════════════════════════════════════════════════════════════════
## STATE
## ═══════════════════════════════════════════════════════════════════════════

## Current relationship value (0-100)
## 0 = Stranger, 25 = Acquaintance, 50 = Friend, 75 = Close Friend, 100 = Best Friend
var relationship: int = 50

## Dialogue state flags (e.g., {"met": true, "quest_given": false})
var dialogue_state: Dictionary = {}

## NPC schedule (array of {time: String, location: String, activity: String})
var schedule: Array[Dictionary] = []

## Current location based on schedule
var current_location: String = ""

## Current activity based on schedule
var current_activity: String = ""

## Whether this NPC is currently in dialogue
var is_in_dialogue: bool = false

## Whether this NPC can currently be interacted with
var can_interact: bool = true

## Configuration data loaded from JSON
var config_data: Dictionary = {}

## Relationship thresholds from config
var relationship_thresholds: Dictionary = {}

## Relationship action modifiers from config
var relationship_actions: Dictionary = {}

## ═══════════════════════════════════════════════════════════════════════════
## INITIALIZATION
## ═══════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Load configuration
	load_npc_config()

	# Initialize relationship
	relationship = starting_relationship

	# Connect to Dialogue Manager if available
	_connect_dialogue_manager()

	# Set up initial schedule
	if schedule.size() > 0:
		update_schedule_for_time("08:00")  # Default to morning


## Load NPC configuration from JSON file
func load_npc_config() -> void:
	var config_path: String = "res://data/npc_config.json"

	if not FileAccess.file_exists(config_path):
		push_warning("NPC config file not found: %s" % config_path)
		return

	var file: FileAccess = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open NPC config file: %s" % config_path)
		return

	var json_text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_text)

	if parse_result != OK:
		push_error("Failed to parse NPC config JSON: %s" % json.get_error_message())
		return

	config_data = json.data

	# Load relationship thresholds
	if config_data.has("relationship_config") and config_data["relationship_config"].has("thresholds"):
		relationship_thresholds = config_data["relationship_config"]["thresholds"]

	# Load relationship actions
	if config_data.has("relationship_config") and config_data["relationship_config"].has("actions"):
		relationship_actions = config_data["relationship_config"]["actions"]

	# Load specific NPC data
	if npc_id != "" and config_data.has("npcs") and config_data["npcs"].has(npc_id):
		var npc_data: Dictionary = config_data["npcs"][npc_id]

		# Apply NPC-specific configuration
		if npc_data.has("npc_name"):
			npc_name = npc_data["npc_name"]
		if npc_data.has("starting_relationship"):
			starting_relationship = npc_data["starting_relationship"]
		if npc_data.has("alignment_preference"):
			alignment_preference = npc_data["alignment_preference"]
		if npc_data.has("dialogue_file"):
			dialogue_file_path = npc_data["dialogue_file"]
		if npc_data.has("schedule"):
			schedule = npc_data["schedule"]


## Connect to Dialogue Manager signals (if plugin is loaded)
func _connect_dialogue_manager() -> void:
	# Note: Dialogue Manager is a plugin, so we check if it exists
	# MCP agent will install plugin in Tier 2
	if Engine.has_singleton("DialogueManager"):
		var dialogue_manager: Object = Engine.get_singleton("DialogueManager")
		if dialogue_manager.has_signal("dialogue_ended"):
			dialogue_manager.dialogue_ended.connect(_on_dialogue_ended)


## ═══════════════════════════════════════════════════════════════════════════
## RELATIONSHIP SYSTEM
## ═══════════════════════════════════════════════════════════════════════════

## Change relationship value by amount
func change_relationship(amount: int, reason: String) -> void:
	var old_value: int = relationship
	relationship = clamp(relationship + amount, 0, 100)

	# Emit change signal
	relationship_changed.emit(npc_id, relationship, old_value, reason)

	# Check for threshold crossings
	_check_relationship_thresholds(old_value, relationship)


## Set relationship to specific value
func set_relationship(value: int, reason: String) -> void:
	var old_value: int = relationship
	relationship = clamp(value, 0, 100)

	relationship_changed.emit(npc_id, relationship, old_value, reason)
	_check_relationship_thresholds(old_value, relationship)


## Apply relationship change based on predefined action
func apply_relationship_action(action_id: String) -> void:
	if relationship_actions.has(action_id):
		var amount: int = relationship_actions[action_id]
		change_relationship(amount, action_id)
	else:
		push_warning("Unknown relationship action: %s" % action_id)


## Get current relationship level name (stranger, friend, etc.)
func get_relationship_level() -> String:
	# Sort thresholds by value
	var sorted_thresholds: Array[Dictionary] = []
	for threshold_name: String in relationship_thresholds.keys():
		sorted_thresholds.append({
			"name": threshold_name,
			"value": relationship_thresholds[threshold_name]
		})

	sorted_thresholds.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a["value"] > b["value"])

	# Find highest threshold we've crossed
	for threshold: Dictionary in sorted_thresholds:
		if relationship >= threshold["value"]:
			return threshold["name"]

	return "unknown"


## Check if relationship crossed any thresholds
func _check_relationship_thresholds(old_value: int, new_value: int) -> void:
	for threshold_name: String in relationship_thresholds.keys():
		var threshold_value: int = relationship_thresholds[threshold_name]

		# Check if we crossed this threshold
		if old_value < threshold_value and new_value >= threshold_value:
			relationship_threshold_crossed.emit(npc_id, threshold_name, new_value)
		elif old_value >= threshold_value and new_value < threshold_value:
			relationship_threshold_crossed.emit(npc_id, "lost_" + threshold_name, new_value)


## Get NPC reaction modifier based on player alignment
## Returns -1.0 to +1.0 based on alignment match
func get_npc_reaction_to_player() -> float:
	# Check if ResonanceAlignment autoload exists
	if not Engine.has_singleton("ResonanceAlignment"):
		return 0.0

	var alignment_system: Object = Engine.get_singleton("ResonanceAlignment")
	var player_alignment: float = alignment_system.get_alignment()
	var player_type: String = alignment_system.get_alignment_type()

	# Match preference
	if alignment_preference == player_type:
		return 1.0  # Very positive
	elif alignment_preference == "neutral":
		return 0.0  # Neutral
	elif alignment_preference == "authentic" and player_type == "algorithmic":
		return -1.0  # Very negative
	elif alignment_preference == "algorithmic" and player_type == "authentic":
		return -1.0  # Very negative
	else:
		return 0.0


## ═══════════════════════════════════════════════════════════════════════════
## DIALOGUE SYSTEM
## ═══════════════════════════════════════════════════════════════════════════

## Start dialogue with this NPC
func start_dialogue() -> void:
	if not can_interact:
		push_warning("Cannot interact with NPC %s right now" % npc_id)
		return

	if is_in_dialogue:
		push_warning("NPC %s is already in dialogue" % npc_id)
		return

	if dialogue_file_path == "":
		push_error("No dialogue file set for NPC %s" % npc_id)
		return

	# Check if Dialogue Manager exists
	if not Engine.has_singleton("DialogueManager"):
		push_error("Dialogue Manager plugin not found. Install it first!")
		return

	# Load dialogue resource
	if not ResourceLoader.exists(dialogue_file_path):
		push_error("Dialogue file not found: %s" % dialogue_file_path)
		return

	var dialogue_resource: Resource = load(dialogue_file_path)

	# Prepare state dictionary for dialogue
	var state_dict: Dictionary = {
		"npc_id": npc_id,
		"npc_name": npc_name,
		"npc_relationship": relationship,
		"relationship_level": get_relationship_level(),
		"player_alignment": 0.0,  # Will be set below
		"npc_alignment_preference": alignment_preference,
		"current_location": current_location,
		"current_activity": current_activity
	}

	# Add player alignment if available
	if Engine.has_singleton("ResonanceAlignment"):
		var alignment_system: Object = Engine.get_singleton("ResonanceAlignment")
		state_dict["player_alignment"] = alignment_system.get_alignment()
		state_dict["player_alignment_type"] = alignment_system.get_alignment_type()

	# Add all dialogue state flags
	for flag: String in dialogue_state.keys():
		state_dict[flag] = dialogue_state[flag]

	# Start dialogue
	is_in_dialogue = true
	dialogue_started.emit(npc_id)

	var dialogue_manager: Object = Engine.get_singleton("DialogueManager")
	dialogue_manager.show_dialogue_balloon(dialogue_resource, "start", [state_dict])


## Handle dialogue ending
func _on_dialogue_ended(resource: Resource) -> void:
	# Only process if this was our dialogue
	if resource != null and dialogue_file_path != "" and resource.resource_path == dialogue_file_path:
		is_in_dialogue = false
		dialogue_ended.emit(npc_id)


## Set a dialogue state flag
func set_dialogue_flag(flag_name: String, value: Variant) -> void:
	dialogue_state[flag_name] = value


## Get a dialogue state flag
func get_dialogue_flag(flag_name: String, default_value: Variant = null) -> Variant:
	return dialogue_state.get(flag_name, default_value)


## Check if dialogue flag exists and is true
func has_dialogue_flag(flag_name: String) -> bool:
	return dialogue_state.has(flag_name) and dialogue_state[flag_name] == true


## Trigger a quest from this NPC
func trigger_quest(quest_id: String) -> void:
	quest_triggered.emit(quest_id, npc_id)


## ═══════════════════════════════════════════════════════════════════════════
## SCHEDULE SYSTEM
## ═══════════════════════════════════════════════════════════════════════════

## Update NPC schedule for given time (format: "HH:MM")
func update_schedule_for_time(game_time: String) -> void:
	if schedule.size() == 0:
		return

	# Parse time string to minutes since midnight
	var time_parts: PackedStringArray = game_time.split(":")
	if time_parts.size() != 2:
		push_error("Invalid time format: %s (expected HH:MM)" % game_time)
		return

	var hours: int = int(time_parts[0])
	var minutes: int = int(time_parts[1])
	var current_minutes: int = hours * 60 + minutes

	# Find the most recent schedule entry
	var active_entry: Dictionary = {}
	var active_minutes: int = -1

	for entry: Dictionary in schedule:
		if not entry.has("time"):
			continue

		var entry_parts: PackedStringArray = entry["time"].split(":")
		if entry_parts.size() != 2:
			continue

		var entry_hours: int = int(entry_parts[0])
		var entry_mins: int = int(entry_parts[1])
		var entry_minutes: int = entry_hours * 60 + entry_mins

		# If this entry is before current time and after our best match
		if entry_minutes <= current_minutes and entry_minutes > active_minutes:
			active_entry = entry
			active_minutes = entry_minutes

	# Apply schedule entry
	if active_entry.size() > 0:
		var new_location: String = active_entry.get("location", "unknown")
		var new_activity: String = active_entry.get("activity", "idle")

		if new_location != current_location or new_activity != current_activity:
			current_location = new_location
			current_activity = new_activity
			schedule_changed.emit(npc_id, current_location, current_activity)


## Get current schedule entry
func get_current_schedule_entry() -> Dictionary:
	return {
		"location": current_location,
		"activity": current_activity
	}


## Add a schedule entry
func add_schedule_entry(time: String, location: String, activity: String) -> void:
	schedule.append({
		"time": time,
		"location": location,
		"activity": activity
	})


## ═══════════════════════════════════════════════════════════════════════════
## SAVE/LOAD SYSTEM
## ═══════════════════════════════════════════════════════════════════════════

## Get save data for this NPC
func get_save_data() -> Dictionary:
	return {
		"npc_id": npc_id,
		"relationship": relationship,
		"dialogue_state": dialogue_state,
		"current_location": current_location,
		"current_activity": current_activity,
		"is_in_dialogue": is_in_dialogue,
		"can_interact": can_interact
	}


## Load save data for this NPC
func load_save_data(data: Dictionary) -> void:
	if data.has("relationship"):
		relationship = data["relationship"]
	if data.has("dialogue_state"):
		dialogue_state = data["dialogue_state"]
	if data.has("current_location"):
		current_location = data["current_location"]
	if data.has("current_activity"):
		current_activity = data["current_activity"]
	if data.has("is_in_dialogue"):
		is_in_dialogue = data["is_in_dialogue"]
	if data.has("can_interact"):
		can_interact = data["can_interact"]


## ═══════════════════════════════════════════════════════════════════════════
## DEBUG & TESTING
## ═══════════════════════════════════════════════════════════════════════════

## Get debug info string for this NPC
func get_debug_info() -> String:
	var separator: String = "=".repeat(60)
	var info: String = ""

	info += separator + "\n"
	info += "NPC DEBUG INFO: %s (%s)\n" % [npc_name, npc_id]
	info += separator + "\n"
	info += "Relationship: %d/100 (%s)\n" % [relationship, get_relationship_level()]
	info += "Alignment Preference: %s\n" % alignment_preference
	info += "Current Location: %s\n" % current_location
	info += "Current Activity: %s\n" % current_activity
	info += "In Dialogue: %s\n" % str(is_in_dialogue)
	info += "Can Interact: %s\n" % str(can_interact)
	info += "\nDialogue State:\n"
	for flag: String in dialogue_state.keys():
		info += "  %s: %s\n" % [flag, str(dialogue_state[flag])]
	info += "\nSchedule (%d entries):\n" % schedule.size()
	for entry: Dictionary in schedule:
		info += "  %s: %s (%s)\n" % [entry.get("time", "??:??"), entry.get("location", "unknown"), entry.get("activity", "idle")]
	info += separator + "\n"

	return info


## Print debug info to console
func print_debug_info() -> void:
	print(get_debug_info())
