# Godot 4.5 | GDScript 4.5
# System: S23 - Player Progression Story System
# Created: 2025-11-18
# Dependencies: S22 (NPCs for story), S21 (Alignment for endings), S04 (Combat story events), S06 (Save/Load)
#
# StoryManager tracks player choices, manages branching story paths, and determines
# endings based on alignment and NPC relationship totals. Supports multiple endings,
# hidden paths, and character backstory reveals.

extends Node

class_name StoryManagerImpl

## Signals

## Emitted when a story flag is set
signal story_flag_set(flag: String)

## Emitted when a chapter completes
signal chapter_complete(chapter_id: int)

## Emitted when an ending is reached
signal ending_reached(ending_type: String)

## Emitted when the story branch changes
signal branch_changed(new_branch: String)

## Emitted when a story choice is made
signal choice_made(choice_id: String, branch: String)

# ═════════════════════════════════════════════════════════════════════════════
# Story State
# ═════════════════════════════════════════════════════════════════════════════

## List of story flags (e.g., "met_elder", "saved_village", "discovered_secret")
var story_flags: Array[String] = []

## Current chapter number (1-based)
var current_chapter: int = 1

## Current story branch: "authentic", "neutral", "algorithm"
var story_branch: String = "neutral"

## Story choice history for debugging/analytics
var choice_history: Array[Dictionary] = []

## Maximum history entries to store
const MAX_HISTORY_ENTRIES: int = 100

# ═════════════════════════════════════════════════════════════════════════════
# Configuration
# ═════════════════════════════════════════════════════════════════════════════

## Configuration data loaded from JSON
var config: Dictionary = {}

## Chapter definitions (loaded from config)
var chapters: Array = []

## Ending requirements (loaded from config)
var endings: Dictionary = {}

## Choice definitions (loaded from config)
var choices: Dictionary = {}

## Hidden path requirements (loaded from config)
var hidden_paths: Dictionary = {}

## Path to configuration file
const CONFIG_PATH: String = "res://data/story_config.json"

# ═════════════════════════════════════════════════════════════════════════════
# References to Other Systems
# ═════════════════════════════════════════════════════════════════════════════

## Reference to ResonanceAlignment (autoload)
var alignment_system: Node = null

## Reference to NPC system (when S22 is implemented)
var npc_system: Node = null

# ═════════════════════════════════════════════════════════════════════════════
# Initialization
# ═════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	_load_configuration()
	_initialize_story()
	_connect_to_systems()

	print("═".repeat(60))
	print("StoryManager System Initialized")
	print("═".repeat(60))
	print("Starting Chapter: ", current_chapter)
	print("Story Branch: ", story_branch)
	print("Chapters Loaded: ", chapters.size())
	print("Endings Available: ", endings.size())
	print("═".repeat(60))


## Load configuration from JSON file
func _load_configuration() -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		push_error("StoryManager: Failed to load config from " + CONFIG_PATH)
		_use_default_configuration()
		return

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(json_string)

	if error != OK:
		push_error("StoryManager: JSON parse error at line " + str(json.get_error_line()) + ": " + json.get_error_message())
		_use_default_configuration()
		return

	var data: Dictionary = json.get_data()
	config = data.get("story_config", {})

	# Extract configuration sections
	chapters = config.get("chapters", [])
	endings = config.get("endings", {})
	choices = config.get("choices", {})
	hidden_paths = config.get("hidden_paths", {})

	print("StoryManager: Configuration loaded successfully")


## Use default configuration if JSON fails to load
func _use_default_configuration() -> void:
	push_warning("StoryManager: Using default configuration")

	chapters = [
		{
			"id": 1,
			"name": "The Awakening",
			"main_quest": "discover_rhythm",
			"branching_points": ["choice_help_village", "choice_confront_elder"]
		},
		{
			"id": 2,
			"name": "The Resonance",
			"main_quest": "find_alignment",
			"branching_points": ["choice_join_authentic", "choice_join_algorithm"]
		},
		{
			"id": 3,
			"name": "The Choice",
			"main_quest": "make_final_decision",
			"branching_points": ["choice_save_world", "choice_control_world"]
		}
	]

	endings = {
		"authentic_good": {
			"name": "Harmony Restored",
			"requirements": {
				"alignment_min": 80,
				"relationships_avg_min": 70
			},
			"description": "You embraced authenticity and forged strong bonds."
		},
		"algorithm_good": {
			"name": "Perfect Order",
			"requirements": {
				"alignment_max": -80,
				"relationships_avg_min": 70
			},
			"description": "You brought algorithmic order and efficiency."
		},
		"neutral_good": {
			"name": "Balanced Coexistence",
			"requirements": {
				"alignment_min": -50,
				"alignment_max": 50,
				"relationships_avg_min": 60
			},
			"description": "You found balance between authenticity and algorithm."
		},
		"bad": {
			"name": "Isolation",
			"requirements": {
				"relationships_avg_max": 30
			},
			"description": "You rejected all connections and stand alone."
		},
		"hidden_authentic": {
			"name": "Transcendent Harmony",
			"requirements": {
				"alignment_min": 90,
				"relationships_avg_min": 85,
				"required_flags": ["discovered_secret", "helped_all_npcs"]
			},
			"description": "You achieved perfect harmony and unlocked hidden potential."
		}
	}

	choices = {
		"help_village": {
			"alignment_shift": 10,
			"branch": "authentic",
			"flags": ["helped_village"],
			"description": "Help the village with their problem"
		},
		"confront_elder": {
			"alignment_shift": -10,
			"branch": "algorithm",
			"flags": ["confronted_elder"],
			"description": "Confront the elder about the truth"
		},
		"discover_secret": {
			"alignment_shift": 5,
			"branch": "authentic",
			"flags": ["discovered_secret"],
			"description": "Discover the hidden secret"
		}
	}

	hidden_paths = {
		"secret_path": {
			"required_flags": ["helped_village", "discovered_secret"],
			"unlocks": "hidden_authentic"
		}
	}


## Initialize story state
func _initialize_story() -> void:
	current_chapter = 1
	story_branch = "neutral"
	story_flags = []
	choice_history = []


## Connect to other game systems
func _connect_to_systems() -> void:
	# Connect to ResonanceAlignment (S21)
	if has_node("/root/ResonanceAlignment"):
		alignment_system = get_node("/root/ResonanceAlignment")
		print("StoryManager: Connected to ResonanceAlignment system")
	else:
		push_warning("StoryManager: ResonanceAlignment system not found")

	# Connect to NPC system (S22) when available
	if has_node("/root/NPCManager"):
		npc_system = get_node("/root/NPCManager")
		print("StoryManager: Connected to NPC system")
	else:
		push_warning("StoryManager: NPC system not found (S22 not yet implemented)")


# ═════════════════════════════════════════════════════════════════════════════
# Public API - Story Flags
# ═════════════════════════════════════════════════════════════════════════════

## Set a story flag
## @param flag: The flag identifier to set
func set_story_flag(flag: String) -> void:
	if flag in story_flags:
		push_warning("StoryManager: Flag already set: " + flag)
		return

	story_flags.append(flag)
	story_flag_set.emit(flag)

	# Check for hidden path unlocks
	_check_hidden_paths()

	if OS.is_debug_build():
		print("StoryManager: Flag set: ", flag, " | Total flags: ", story_flags.size())


## Check if a story flag is set
## @param flag: The flag identifier to check
## @return: true if flag is set, false otherwise
func has_story_flag(flag: String) -> bool:
	return flag in story_flags


## Get all story flags
## @return: Array of all story flags
func get_story_flags() -> Array[String]:
	return story_flags.duplicate()


## Clear a story flag (for debugging/testing)
## @param flag: The flag identifier to clear
func clear_story_flag(flag: String) -> void:
	if flag in story_flags:
		story_flags.erase(flag)
		if OS.is_debug_build():
			print("StoryManager: Flag cleared: ", flag)


# ═════════════════════════════════════════════════════════════════════════════
# Public API - Chapter Progression
# ═════════════════════════════════════════════════════════════════════════════

## Advance to the next chapter
func advance_chapter() -> void:
	var max_chapter: int = chapters.size()

	if current_chapter >= max_chapter:
		push_warning("StoryManager: Already at final chapter (%d)" % max_chapter)
		return

	current_chapter += 1
	chapter_complete.emit(current_chapter - 1)

	if OS.is_debug_build():
		print("StoryManager: Advanced to Chapter ", current_chapter)

	# Check if this is the final chapter
	if current_chapter == max_chapter:
		if OS.is_debug_build():
			print("StoryManager: Reached final chapter - endings available")


## Get current chapter number
## @return: Current chapter number (1-based)
func get_current_chapter() -> int:
	return current_chapter


## Get current chapter data
## @return: Dictionary with chapter information
func get_current_chapter_data() -> Dictionary:
	if current_chapter > 0 and current_chapter <= chapters.size():
		return chapters[current_chapter - 1]
	return {}


## Set chapter directly (for save/load or debugging)
## @param chapter_id: The chapter number to set
func set_chapter(chapter_id: int) -> void:
	if chapter_id < 1 or chapter_id > chapters.size():
		push_error("StoryManager: Invalid chapter ID: %d" % chapter_id)
		return

	current_chapter = chapter_id
	if OS.is_debug_build():
		print("StoryManager: Chapter set to ", current_chapter)


# ═════════════════════════════════════════════════════════════════════════════
# Public API - Story Choices
# ═════════════════════════════════════════════════════════════════════════════

## Make a story choice
## @param choice_id: The choice identifier from story_config.json
func make_story_choice(choice_id: String) -> void:
	if not choices.has(choice_id):
		push_warning("StoryManager: Unknown choice_id: " + choice_id)
		return

	var choice: Dictionary = choices[choice_id]

	# Apply alignment shift (if connected to S21)
	if alignment_system != null and choice.has("alignment_shift"):
		var shift_amount: float = choice["alignment_shift"]
		alignment_system.shift_alignment(shift_amount, "Story choice: " + choice_id)

	# Set story flags
	if choice.has("flags"):
		var flags: Array = choice["flags"]
		for flag in flags:
			set_story_flag(flag)

	# Update story branch
	if choice.has("branch"):
		var new_branch: String = choice["branch"]
		if new_branch != story_branch:
			story_branch = new_branch
			branch_changed.emit(new_branch)

	# Record in history
	_add_to_choice_history(choice_id, choice.get("description", ""))

	# Emit signal
	choice_made.emit(choice_id, story_branch)

	if OS.is_debug_build():
		print("StoryManager: Choice made: ", choice_id, " | Branch: ", story_branch)


## Get current story branch
## @return: Current story branch ("authentic", "neutral", "algorithm")
func get_story_branch() -> String:
	return story_branch


## Set story branch directly (for save/load or debugging)
## @param branch: The branch to set
func set_story_branch(branch: String) -> void:
	if branch != story_branch:
		story_branch = branch
		branch_changed.emit(branch)


# ═════════════════════════════════════════════════════════════════════════════
# Public API - Ending Determination
# ═════════════════════════════════════════════════════════════════════════════

## Determine ending based on alignment and relationships
## @return: Ending type identifier
func determine_ending() -> String:
	var alignment: float = _get_current_alignment()
	var avg_relationship: float = _calculate_avg_npc_relationship()

	if OS.is_debug_build():
		print("StoryManager: Determining ending...")
		print("  Alignment: ", alignment)
		print("  Avg Relationship: ", avg_relationship)
		print("  Story Flags: ", story_flags)

	# Check hidden endings first (most restrictive)
	for ending_id in endings.keys():
		var ending: Dictionary = endings[ending_id]
		if ending_id.begins_with("hidden_"):
			if _meets_ending_requirements(ending, alignment, avg_relationship):
				return ending_id

	# Check good endings
	if alignment >= 80 and avg_relationship >= 70:
		return "authentic_good"

	if alignment <= -80 and avg_relationship >= 70:
		return "algorithm_good"

	if alignment >= -50 and alignment <= 50 and avg_relationship >= 60:
		return "neutral_good"

	# Check bad ending
	if avg_relationship <= 30:
		return "bad"

	# Default to neutral if no other conditions met
	return "neutral_good"


## Trigger an ending
## @param ending_type: The ending type identifier
func trigger_ending(ending_type: String) -> void:
	if not endings.has(ending_type):
		push_error("StoryManager: Unknown ending type: " + ending_type)
		return

	var ending: Dictionary = endings[ending_type]

	ending_reached.emit(ending_type)

	print("═".repeat(60))
	print("ENDING REACHED: ", ending.get("name", ending_type))
	print("═".repeat(60))
	print(ending.get("description", "No description available"))
	print("═".repeat(60))


## Get ending data
## @param ending_type: The ending type identifier
## @return: Dictionary with ending information
func get_ending_data(ending_type: String) -> Dictionary:
	return endings.get(ending_type, {})


## Get all available endings
## @return: Array of ending type identifiers
func get_all_endings() -> Array:
	return endings.keys()


# ═════════════════════════════════════════════════════════════════════════════
# Private Helper Methods
# ═════════════════════════════════════════════════════════════════════════════

## Get current alignment from S21
func _get_current_alignment() -> float:
	if alignment_system != null and alignment_system.has_method("get_alignment"):
		return alignment_system.get_alignment()
	return 0.0


## Calculate average NPC relationship (for S22 integration)
func _calculate_avg_npc_relationship() -> float:
	# If S22 is not yet implemented, return default value
	if npc_system == null or not npc_system.has_method("get_average_relationship"):
		# For testing purposes, calculate based on story flags
		# More flags = better relationships (simplified model)
		var relationship_estimate: float = min(story_flags.size() * 10.0, 100.0)
		return relationship_estimate

	# Get average relationship from NPC system
	return npc_system.get_average_relationship()


## Check if ending requirements are met
func _meets_ending_requirements(ending: Dictionary, alignment: float, avg_relationship: float) -> bool:
	var requirements: Dictionary = ending.get("requirements", {})

	# Check alignment minimum
	if requirements.has("alignment_min"):
		if alignment < requirements["alignment_min"]:
			return false

	# Check alignment maximum
	if requirements.has("alignment_max"):
		if alignment > requirements["alignment_max"]:
			return false

	# Check relationship minimum
	if requirements.has("relationships_avg_min"):
		if avg_relationship < requirements["relationships_avg_min"]:
			return false

	# Check relationship maximum
	if requirements.has("relationships_avg_max"):
		if avg_relationship > requirements["relationships_avg_max"]:
			return false

	# Check required flags
	if requirements.has("required_flags"):
		var required_flags: Array = requirements["required_flags"]
		for flag in required_flags:
			if not has_story_flag(flag):
				return false

	return true


## Check for hidden path unlocks
func _check_hidden_paths() -> void:
	for path_id in hidden_paths.keys():
		var path: Dictionary = hidden_paths[path_id]
		var required_flags: Array = path.get("required_flags", [])

		# Check if all required flags are set
		var all_flags_met := true
		for flag in required_flags:
			if not has_story_flag(flag):
				all_flags_met = false
				break

		if all_flags_met:
			var unlocks: String = path.get("unlocks", "")
			if unlocks != "":
				if OS.is_debug_build():
					print("StoryManager: Hidden path unlocked: ", path_id, " -> ", unlocks)


## Add choice to history
func _add_to_choice_history(choice_id: String, description: String) -> void:
	choice_history.append({
		"timestamp": Time.get_ticks_msec(),
		"choice_id": choice_id,
		"description": description,
		"chapter": current_chapter,
		"branch": story_branch
	})

	# Trim history if too long
	if choice_history.size() > MAX_HISTORY_ENTRIES:
		choice_history.pop_front()


# ═════════════════════════════════════════════════════════════════════════════
# Save/Load Integration (S06)
# ═════════════════════════════════════════════════════════════════════════════

## Get save data for this system
## @return: Dictionary with save data
func save_state() -> Dictionary:
	return {
		"story_flags": story_flags.duplicate(),
		"current_chapter": current_chapter,
		"story_branch": story_branch,
		"choice_history": choice_history.slice(-10)  # Save last 10 choices
	}


## Load save data for this system
## @param data: Dictionary with save data
func load_state(data: Dictionary) -> void:
	if data.has("story_flags"):
		story_flags = data["story_flags"].duplicate()

	if data.has("current_chapter"):
		current_chapter = data["current_chapter"]

	if data.has("story_branch"):
		story_branch = data["story_branch"]

	if data.has("choice_history"):
		choice_history = data["choice_history"].duplicate()

	if OS.is_debug_build():
		print("StoryManager: State loaded from save")
		print("  Chapter: ", current_chapter)
		print("  Branch: ", story_branch)
		print("  Flags: ", story_flags.size())


# ═════════════════════════════════════════════════════════════════════════════
# Debug & Testing
# ═════════════════════════════════════════════════════════════════════════════

## Get debug info string
## @return: Formatted debug information
func get_debug_info() -> String:
	var info := "═".repeat(60) + "\n"
	info += "STORY MANAGER DEBUG INFO\n"
	info += "═".repeat(60) + "\n"
	info += "Current Chapter: %d / %d\n" % [current_chapter, chapters.size()]
	info += "Story Branch: %s\n" % story_branch
	info += "Story Flags: %d set\n" % story_flags.size()
	info += "Choice History: %d entries\n" % choice_history.size()
	info += "Current Alignment: %.2f\n" % _get_current_alignment()
	info += "Avg NPC Relationship: %.2f\n" % _calculate_avg_npc_relationship()
	info += "Predicted Ending: %s\n" % determine_ending()
	info += "═".repeat(60)
	return info


## Print debug information to console
func print_debug_info() -> void:
	print(get_debug_info())


## Get story flags as formatted string
## @return: Formatted flags string
func get_story_flags_string() -> String:
	if story_flags.is_empty():
		return "No story flags set"

	var flags_string := "Story Flags:\n"
	for flag in story_flags:
		flags_string += "  - " + flag + "\n"

	return flags_string


## Get choice history as formatted string
## @param count: Number of recent entries to include (default: 10)
## @return: Formatted history string
func get_choice_history_string(count: int = 10) -> String:
	var history_string := "Recent Choices:\n"
	var recent_history: Array = choice_history.slice(-count)

	for entry in recent_history:
		history_string += "  Ch%d: %s (%s)\n" % [
			entry.get("chapter", 0),
			entry.get("choice_id", ""),
			entry.get("branch", "")
		]

	return history_string
