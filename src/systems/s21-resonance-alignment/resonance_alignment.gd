# Godot 4.5 | GDScript 4.5
# System: S21 - Resonance Alignment System
# Created: 2025-11-18
# Dependencies: S04 (Combat), S11 (Enemy AI), S12 (Monsters)
#
# ResonanceAlignment is the thematic core of the game - the duality between
# authentic human creativity and algorithmic generation. This autoload singleton
# tracks player alignment from -100 (Algorithmic) to +100 (Authentic) and
# affects combat effectiveness, NPC reactions, loot tables, and visual language.

extends Node

class_name ResonanceAlignmentImpl

## Signals

## Emitted when alignment value changes
signal alignment_changed(new_alignment: float, reason: String)

## Emitted when alignment crosses a major threshold
signal alignment_threshold_crossed(threshold_name: String, new_alignment: float)

## Emitted when visual theme should update
signal visual_theme_changed(theme_data: Dictionary)

# ═════════════════════════════════════════════════════════════════════════════
# Alignment State
# ═════════════════════════════════════════════════════════════════════════════

## Current alignment value: -100 (Algorithmic) to +100 (Authentic)
var alignment: float = 0.0

## Previous alignment value (for detecting threshold crossings)
var _previous_alignment: float = 0.0

## Alignment history for debugging/analytics
var alignment_history: Array[Dictionary] = []

## Maximum history entries to store
const MAX_HISTORY_ENTRIES: int = 100

# ═════════════════════════════════════════════════════════════════════════════
# Configuration
# ═════════════════════════════════════════════════════════════════════════════

## Configuration data loaded from JSON
var config: Dictionary = {}

## Action shift values (loaded from config)
var action_shifts: Dictionary = {}

## Threshold definitions (loaded from config)
var thresholds: Dictionary = {}

## Combat modifier settings (loaded from config)
var combat_modifiers: Dictionary = {}

## Visual theme mappings (loaded from config)
var visual_themes: Dictionary = {}

## Path to configuration file
const CONFIG_PATH: String = "res://data/alignment_config.json"

# ═════════════════════════════════════════════════════════════════════════════
# Alignment Type Enum
# ═════════════════════════════════════════════════════════════════════════════

## Alignment categories
enum AlignmentType {
	ALGORITHMIC,  ## -100 to -50: Strong algorithmic lean
	NEUTRAL,      ## -50 to +50: Balanced between both
	AUTHENTIC     ## +50 to +100: Strong authentic lean
}

# ═════════════════════════════════════════════════════════════════════════════
# Initialization
# ═════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	_load_configuration()
	_initialize_alignment()

	# Print initialization info
	print("═".repeat(60))
	print("ResonanceAlignment System Initialized")
	print("═".repeat(60))
	print("Starting Alignment: ", alignment)
	print("Alignment Type: ", get_alignment_type())
	print("Configuration Loaded: ", config.size(), " entries")
	print("═".repeat(60))


## Load configuration from JSON file
func _load_configuration() -> void:
	var file := FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		push_error("ResonanceAlignment: Failed to load config from " + CONFIG_PATH)
		_use_default_configuration()
		return

	var json_string := file.get_as_text()
	file.close()

	var json := JSON.new()
	var error := json.parse(json_string)

	if error != OK:
		push_error("ResonanceAlignment: JSON parse error at line " + str(json.get_error_line()) + ": " + json.get_error_message())
		_use_default_configuration()
		return

	config = json.get_data()

	# Extract configuration sections
	action_shifts = config.get("action_shifts", {})
	thresholds = config.get("thresholds", {})
	combat_modifiers = config.get("combat_modifiers", {})
	visual_themes = config.get("visual_themes", {})

	print("ResonanceAlignment: Configuration loaded successfully")


## Use default configuration if JSON fails to load
func _use_default_configuration() -> void:
	push_warning("ResonanceAlignment: Using default configuration")

	action_shifts = {
		"help_npc_authentic": 5.0,
		"use_algorithm_exploit": -10.0,
		"solve_puzzle_creatively": 3.0,
		"use_brute_force": -3.0,
		"befriend_authentic_npc": 7.0,
		"befriend_algorithm_npc": -7.0,
		"craft_organic_item": 2.0,
		"craft_digital_item": -2.0
	}

	thresholds = {
		"strong_authentic": 50.0,
		"neutral_upper": 50.0,
		"neutral_lower": -50.0,
		"strong_algorithmic": -50.0
	}

	combat_modifiers = {
		"type_advantage_bonus": 0.20,
		"alignment_bonus_threshold": 70.0,
		"max_bonus_multiplier": 1.5
	}

	visual_themes = {
		"authentic": {
			"primary_color": "#FF8C42",
			"secondary_color": "#8B4513",
			"particle_style": "organic",
			"ui_style": "hand_drawn"
		},
		"algorithmic": {
			"primary_color": "#00BFFF",
			"secondary_color": "#4169E1",
			"particle_style": "digital",
			"ui_style": "geometric"
		}
	}


## Initialize alignment to neutral (0.0)
func _initialize_alignment() -> void:
	alignment = 0.0
	_previous_alignment = 0.0


# ═════════════════════════════════════════════════════════════════════════════
# Public API - Alignment Modification
# ═════════════════════════════════════════════════════════════════════════════

## Shift alignment by a specific amount with a reason
## @param amount: The amount to shift (-100 to +100)
## @param reason: Description of why alignment shifted (for history tracking)
func shift_alignment(amount: float, reason: String) -> void:
	_previous_alignment = alignment
	alignment = clamp(alignment + amount, -100.0, 100.0)

	# Record in history
	_add_to_history(amount, reason)

	# Emit alignment changed signal
	alignment_changed.emit(alignment, reason)

	# Check for threshold crossings
	_check_threshold_crossings()

	# Check for visual theme changes
	_check_visual_theme_change()

	# Debug output
	if OS.is_debug_build():
		print("Alignment Shift: ", amount, " | Reason: ", reason, " | New Alignment: ", alignment, " (", get_alignment_type(), ")")


## Set alignment to a specific value (for save/load or debugging)
## @param value: The new alignment value (-100 to +100)
## @param reason: Description of why alignment was set
func set_alignment(value: float, reason: String = "direct_set") -> void:
	var clamped_value := clamp(value, -100.0, 100.0)
	var shift_amount := clamped_value - alignment
	shift_alignment(shift_amount, reason)


## Shift alignment based on a predefined action from configuration
## @param action_id: The action identifier from alignment_config.json
func shift_alignment_by_action(action_id: String) -> void:
	if not action_shifts.has(action_id):
		push_warning("ResonanceAlignment: Unknown action_id: " + action_id)
		return

	var shift_value: float = action_shifts[action_id]
	shift_alignment(shift_value, "Action: " + action_id)


## Reset alignment to neutral (0.0)
func reset_alignment() -> void:
	set_alignment(0.0, "reset")


# ═════════════════════════════════════════════════════════════════════════════
# Public API - Alignment Queries
# ═════════════════════════════════════════════════════════════════════════════

## Get current alignment value
## @return: Current alignment (-100 to +100)
func get_alignment() -> float:
	return alignment


## Get alignment type as string
## @return: "authentic", "neutral", or "algorithmic"
func get_alignment_type() -> String:
	if alignment >= thresholds.get("strong_authentic", 50.0):
		return "authentic"
	elif alignment <= thresholds.get("strong_algorithmic", -50.0):
		return "algorithmic"
	else:
		return "neutral"


## Get alignment type as enum
## @return: AlignmentType enum value
func get_alignment_type_enum() -> AlignmentType:
	if alignment >= thresholds.get("strong_authentic", 50.0):
		return AlignmentType.AUTHENTIC
	elif alignment <= thresholds.get("strong_algorithmic", -50.0):
		return AlignmentType.ALGORITHMIC
	else:
		return AlignmentType.NEUTRAL


## Get normalized alignment (-1.0 to +1.0)
## @return: Normalized alignment value
func get_normalized_alignment() -> float:
	return alignment / 100.0


## Check if player is aligned toward authentic
## @return: true if alignment > 0
func is_authentic_aligned() -> bool:
	return alignment > 0.0


## Check if player is aligned toward algorithmic
## @return: true if alignment < 0
func is_algorithmic_aligned() -> bool:
	return alignment < 0.0


## Check if player is neutral
## @return: true if alignment between -50 and +50
func is_neutral() -> bool:
	var neutral_upper: float = thresholds.get("neutral_upper", 50.0)
	var neutral_lower: float = thresholds.get("neutral_lower", -50.0)
	return alignment > neutral_lower and alignment < neutral_upper


# ═════════════════════════════════════════════════════════════════════════════
# Public API - Combat Integration
# ═════════════════════════════════════════════════════════════════════════════

## Get combat effectiveness modifier against an enemy
## @param enemy_alignment: "authentic", "neutral", or "algorithmic"
## @return: Damage multiplier (e.g., 1.2 for +20% damage)
func get_combat_modifier(enemy_alignment: String) -> float:
	# Opposite alignments get damage bonus
	var type_advantage_bonus: float = combat_modifiers.get("type_advantage_bonus", 0.20)

	var player_type := get_alignment_type()

	# Check for type advantage
	if _has_type_advantage(player_type, enemy_alignment):
		return 1.0 + type_advantage_bonus  # 1.2 = +20% damage

	return 1.0  # No modifier


## Check if player has type advantage over enemy
## @param player_type: Player's alignment type
## @param enemy_type: Enemy's alignment type
## @return: true if player has advantage
func _has_type_advantage(player_type: String, enemy_type: String) -> bool:
	# Authentic has advantage over Algorithmic
	if player_type == "authentic" and enemy_type == "algorithmic":
		return true

	# Algorithmic has advantage over Authentic
	if player_type == "algorithmic" and enemy_type == "authentic":
		return true

	# Neutral has no advantage
	return false


## Get defensive modifier when being attacked
## @param attacker_alignment: Alignment of the attacker
## @return: Damage reduction multiplier (e.g., 0.8 for -20% damage taken)
func get_defensive_modifier(attacker_alignment: String) -> float:
	# If attacker has type advantage, player takes more damage
	var player_type := get_alignment_type()

	if _has_type_advantage(attacker_alignment, player_type):
		return 1.2  # Take +20% more damage

	return 1.0  # No modifier


# ═════════════════════════════════════════════════════════════════════════════
# Public API - Visual Theme
# ═════════════════════════════════════════════════════════════════════════════

## Get current visual theme data
## @return: Dictionary with theme colors, styles, etc.
func get_visual_theme() -> Dictionary:
	var alignment_type := get_alignment_type()

	if alignment_type == "authentic":
		return visual_themes.get("authentic", {})
	elif alignment_type == "algorithmic":
		return visual_themes.get("algorithmic", {})
	else:
		# Neutral: blend of both themes
		return _blend_visual_themes()


## Blend authentic and algorithmic themes for neutral alignment
func _blend_visual_themes() -> Dictionary:
	var authentic_theme: Dictionary = visual_themes.get("authentic", {})
	var algorithmic_theme: Dictionary = visual_themes.get("algorithmic", {})

	# For neutral, return a basic blend
	return {
		"primary_color": "#FFFFFF",
		"secondary_color": "#CCCCCC",
		"particle_style": "neutral",
		"ui_style": "standard"
	}


## Get theme color based on alignment
## @return: Color object for UI/visual elements
func get_theme_color() -> Color:
	var theme := get_visual_theme()
	var color_string: String = theme.get("primary_color", "#FFFFFF")
	return Color(color_string)


# ═════════════════════════════════════════════════════════════════════════════
# Public API - Loot & Rewards
# ═════════════════════════════════════════════════════════════════════════════

## Get loot category based on alignment
## @return: "organic", "digital", or "neutral"
func get_loot_category() -> String:
	var alignment_type := get_alignment_type()

	if alignment_type == "authentic":
		return "organic"
	elif alignment_type == "algorithmic":
		return "digital"
	else:
		return "neutral"


## Determine if a specific loot type should drop based on alignment
## @param loot_alignment: "organic", "digital", or "neutral"
## @return: Drop chance multiplier (0.0 to 2.0)
func get_loot_drop_multiplier(loot_alignment: String) -> float:
	var player_loot_category := get_loot_category()

	# Matching alignment gets 1.5x drop rate
	if player_loot_category == loot_alignment:
		return 1.5

	# Opposite alignment gets 0.5x drop rate
	if (player_loot_category == "organic" and loot_alignment == "digital") or \
	   (player_loot_category == "digital" and loot_alignment == "organic"):
		return 0.5

	# Neutral or same category gets normal rate
	return 1.0


# ═════════════════════════════════════════════════════════════════════════════
# Public API - NPC Reactions (Ready for S22)
# ═════════════════════════════════════════════════════════════════════════════

## Get NPC reaction modifier based on NPC's alignment preference
## @param npc_alignment_preference: "authentic", "algorithmic", or "neutral"
## @return: Reaction modifier (-1.0 to +1.0)
func get_npc_reaction_modifier(npc_alignment_preference: String) -> float:
	var player_type := get_alignment_type()

	# NPCs like similar alignment
	if player_type == npc_alignment_preference:
		return abs(alignment) / 100.0  # 0.0 to 1.0 based on strength

	# NPCs dislike opposite alignment
	if (player_type == "authentic" and npc_alignment_preference == "algorithmic") or \
	   (player_type == "algorithmic" and npc_alignment_preference == "authentic"):
		return -abs(alignment) / 100.0  # -0.0 to -1.0

	# Neutral NPCs don't care
	return 0.0


# ═════════════════════════════════════════════════════════════════════════════
# Private Helper Methods
# ═════════════════════════════════════════════════════════════════════════════

## Add alignment change to history
func _add_to_history(amount: float, reason: String) -> void:
	alignment_history.append({
		"timestamp": Time.get_ticks_msec(),
		"amount": amount,
		"reason": reason,
		"new_alignment": alignment,
		"alignment_type": get_alignment_type()
	})

	# Trim history if too long
	if alignment_history.size() > MAX_HISTORY_ENTRIES:
		alignment_history.pop_front()


## Check if alignment crossed any thresholds
func _check_threshold_crossings() -> void:
	var prev_type := _get_alignment_type_for_value(_previous_alignment)
	var current_type := get_alignment_type()

	if prev_type != current_type:
		alignment_threshold_crossed.emit(current_type, alignment)

		if OS.is_debug_build():
			print("Alignment Threshold Crossed: ", prev_type, " → ", current_type)


## Get alignment type for a specific value (helper)
func _get_alignment_type_for_value(value: float) -> String:
	if value >= thresholds.get("strong_authentic", 50.0):
		return "authentic"
	elif value <= thresholds.get("strong_algorithmic", -50.0):
		return "algorithmic"
	else:
		return "neutral"


## Check if visual theme should change
func _check_visual_theme_change() -> void:
	var prev_type := _get_alignment_type_for_value(_previous_alignment)
	var current_type := get_alignment_type()

	if prev_type != current_type:
		var theme_data := get_visual_theme()
		visual_theme_changed.emit(theme_data)

		if OS.is_debug_build():
			print("Visual Theme Changed: ", theme_data)


# ═════════════════════════════════════════════════════════════════════════════
# Save/Load Integration (S06)
# ═════════════════════════════════════════════════════════════════════════════

## Get save data for this system
## @return: Dictionary with save data
func get_save_data() -> Dictionary:
	return {
		"alignment": alignment,
		"alignment_history": alignment_history.slice(-10)  # Save last 10 entries
	}


## Load save data for this system
## @param data: Dictionary with save data
func load_save_data(data: Dictionary) -> void:
	if data.has("alignment"):
		set_alignment(data["alignment"], "loaded_from_save")

	if data.has("alignment_history"):
		alignment_history = data["alignment_history"]


# ═════════════════════════════════════════════════════════════════════════════
# Debug & Testing
# ═════════════════════════════════════════════════════════════════════════════

## Get debug info string
## @return: Formatted debug information
func get_debug_info() -> String:
	var info := "═".repeat(60) + "\n"
	info += "RESONANCE ALIGNMENT DEBUG INFO\n"
	info += "═".repeat(60) + "\n"
	info += "Current Alignment: %.2f\n" % alignment
	info += "Alignment Type: %s\n" % get_alignment_type()
	info += "Normalized: %.2f\n" % get_normalized_alignment()
	info += "Visual Theme: %s\n" % str(get_visual_theme())
	info += "Loot Category: %s\n" % get_loot_category()
	info += "History Entries: %d\n" % alignment_history.size()
	info += "═".repeat(60)
	return info


## Print debug information to console
func print_debug_info() -> void:
	print(get_debug_info())


## Get alignment history as formatted string
## @param count: Number of recent entries to include (default: 10)
## @return: Formatted history string
func get_alignment_history_string(count: int = 10) -> String:
	var history_string := "Recent Alignment Changes:\n"
	var recent_history := alignment_history.slice(-count)

	for entry in recent_history:
		history_string += "  %+.1f (%s) → %.1f [%s]\n" % [
			entry["amount"],
			entry["reason"],
			entry["new_alignment"],
			entry["alignment_type"]
		]

	return history_string
