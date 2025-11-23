# Godot 4.5 | GDScript 4.5
# System: S26 - Rhythm Mini-Games
# Created: 2025-11-18
# Dependencies: S01 (Conductor), S04 (Combat for boss phases)
#
# The RhythmGame system provides three types of rhythm mini-games:
# - Story Moments: Scripted rhythm sequences during cutscenes
# - Boss Rhythm Phases: Special rhythm challenges mid-boss-battle
# - Training Mode: Practice mode for skill building
#
# Features combo tracking, difficulty scaling, and visual feedback integration.

extends Node

class_name RhythmGame

## Signals for rhythm game events

## Emitted when player hits a beat with timing quality
signal beat_hit(timing_quality: String, combo_count: int, multiplier: float)

## Emitted when combo count changes
signal combo_changed(new_combo: int, old_combo: int)

## Emitted when combo multiplier changes
signal multiplier_changed(new_multiplier: float)

## Emitted when rhythm sequence completes
signal sequence_complete(success: bool, final_score: int, stats: Dictionary)

## Emitted when boss is stunned after successful rhythm phase
signal boss_stunned()

## Emitted when boss is enraged after failed rhythm phase
signal boss_enraged()

## Emitted when pattern changes (for UI updates)
signal pattern_changed(pattern_id: String, difficulty: String)

## Emitted for visual feedback (note spawning, hit feedback)
signal visual_feedback_requested(feedback_type: String, timing_quality: String)

# ═════════════════════════════════════════════════════════════════════════════
# Enums
# ═════════════════════════════════════════════════════════════════════════════

## Game modes for rhythm mini-games
enum GameMode {
	STORY,      ## Story moment - scripted sequence, no penalty for failure
	BOSS,       ## Boss rhythm phase - success stuns, failure enrages
	TRAINING    ## Training mode - practice with high score tracking
}

## Current game mode
var current_mode: GameMode = GameMode.STORY

# ═════════════════════════════════════════════════════════════════════════════
# Combo System
# ═════════════════════════════════════════════════════════════════════════════

## Current combo count (consecutive perfect hits)
var combo_count: int = 0

## Combo multiplier (1.0 + combo * 0.1, max 3.0x)
var combo_multiplier: float = 1.0

## Maximum combo multiplier
const MAX_COMBO_MULTIPLIER: float = 3.0

## Combo increment per perfect hit
const COMBO_INCREMENT_PER_PERFECT: float = 0.1

# ═════════════════════════════════════════════════════════════════════════════
# Pattern Management
# ═════════════════════════════════════════════════════════════════════════════

## Currently active rhythm pattern
var current_pattern: Dictionary = {}

## Current difficulty level
var current_difficulty: String = "normal"

## All loaded patterns
var patterns: Dictionary = {}

## Difficulty configurations
var difficulty_config: Dictionary = {}

## Current pattern progress (notes hit / total notes)
var pattern_progress: int = 0
var pattern_total_notes: int = 0

# ═════════════════════════════════════════════════════════════════════════════
# Score Tracking
# ═════════════════════════════════════════════════════════════════════════════

## Current session score
var current_score: int = 0

## Session statistics
var session_stats: Dictionary = {
	"perfect_hits": 0,
	"good_hits": 0,
	"miss_hits": 0,
	"max_combo": 0,
	"total_score": 0
}

## High scores per pattern (Training mode)
var high_scores: Dictionary = {}

# ═════════════════════════════════════════════════════════════════════════════
# Dependencies
# ═════════════════════════════════════════════════════════════════════════════

## Reference to Conductor for rhythm timing
var conductor: Node = null

## Reference to CombatManager for boss phases
var combat_manager: Node = null

# ═════════════════════════════════════════════════════════════════════════════
# State Management
# ═════════════════════════════════════════════════════════════════════════════

## Is rhythm sequence currently active
var is_active: bool = false

## Start time of current sequence
var sequence_start_time: float = 0.0

# ═════════════════════════════════════════════════════════════════════════════
# Initialization
# ═════════════════════════════════════════════════════════════════════════════

func _ready() -> void:
	# Get Conductor reference
	if has_node("/root/Conductor"):
		conductor = get_node("/root/Conductor")
		conductor.beat.connect(_on_conductor_beat)
	else:
		push_error("RhythmGame: Conductor autoload not found!")

	# Get CombatManager reference (optional - only needed for boss phases)
	if has_node("/root/CombatManager"):
		combat_manager = get_node("/root/CombatManager")

	# Load patterns and difficulty configs
	_load_rhythm_patterns()
	_load_difficulty_config()


# ═════════════════════════════════════════════════════════════════════════════
# Data Loading
# ═════════════════════════════════════════════════════════════════════════════

## Load rhythm patterns from JSON
func _load_rhythm_patterns() -> void:
	var patterns_path: String = "res://src/systems/s26-rhythm-mini-games/rhythm_patterns.json"

	if not FileAccess.file_exists(patterns_path):
		push_error("RhythmGame: rhythm_patterns.json not found at ", patterns_path)
		_use_default_patterns()
		return

	var file: FileAccess = FileAccess.open(patterns_path, FileAccess.READ)
	if file == null:
		push_error("RhythmGame: Failed to open rhythm_patterns.json")
		_use_default_patterns()
		return

	var json_text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_text)

	if parse_result != OK:
		push_error("RhythmGame: Failed to parse rhythm_patterns.json: ", json.get_error_message())
		_use_default_patterns()
		return

	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("RhythmGame: Invalid JSON format in rhythm_patterns.json")
		_use_default_patterns()
		return

	patterns = data.get("patterns", {})
	print("RhythmGame: Loaded ", patterns.size(), " rhythm patterns")


## Use default patterns if JSON loading fails
func _use_default_patterns() -> void:
	push_warning("RhythmGame: Using default patterns")
	patterns = {
		"simple_4beat": {
			"name": "Simple 4-Beat",
			"description": "Four quarter notes",
			"beats": [1, 2, 3, 4],
			"time_signature": [4, 4],
			"difficulty": "normal"
		}
	}


## Load difficulty configuration from JSON
func _load_difficulty_config() -> void:
	var config_path: String = "res://src/systems/s26-rhythm-mini-games/difficulty_config.json"

	if not FileAccess.file_exists(config_path):
		push_error("RhythmGame: difficulty_config.json not found at ", config_path)
		_use_default_difficulty_config()
		return

	var file: FileAccess = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("RhythmGame: Failed to open difficulty_config.json")
		_use_default_difficulty_config()
		return

	var json_text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_text)

	if parse_result != OK:
		push_error("RhythmGame: Failed to parse difficulty_config.json: ", json.get_error_message())
		_use_default_difficulty_config()
		return

	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("RhythmGame: Invalid JSON format in difficulty_config.json")
		_use_default_difficulty_config()
		return

	difficulty_config = data.get("difficulty_config", {})
	print("RhythmGame: Loaded difficulty configurations for ", difficulty_config.size(), " levels")


## Use default difficulty config if JSON loading fails
func _use_default_difficulty_config() -> void:
	push_warning("RhythmGame: Using default difficulty config")
	difficulty_config = {
		"normal": {
			"timing_window_ms": 100,
			"pattern_complexity": "simple",
			"bpm": 120
		},
		"hard": {
			"timing_window_ms": 70,
			"pattern_complexity": "moderate",
			"bpm": 150
		},
		"expert": {
			"timing_window_ms": 50,
			"pattern_complexity": "complex",
			"bpm": 180
		}
	}


# ═════════════════════════════════════════════════════════════════════════════
# Rhythm Sequence Control
# ═════════════════════════════════════════════════════════════════════════════

## Start a rhythm sequence
## @param pattern_id: ID of pattern from rhythm_patterns.json
## @param difficulty: "normal", "hard", or "expert"
## @param mode: GameMode enum value (STORY, BOSS, TRAINING)
func start_rhythm_sequence(pattern_id: String, difficulty: String = "normal", mode: GameMode = GameMode.STORY) -> bool:
	if is_active:
		push_warning("RhythmGame: Sequence already active")
		return false

	# Validate pattern exists
	if not patterns.has(pattern_id):
		push_error("RhythmGame: Pattern '", pattern_id, "' not found")
		return false

	# Validate difficulty exists
	if not difficulty_config.has(difficulty):
		push_error("RhythmGame: Difficulty '", difficulty, "' not found")
		return false

	# Set up sequence
	current_pattern = patterns[pattern_id]
	current_difficulty = difficulty
	current_mode = mode
	is_active = true
	sequence_start_time = Time.get_ticks_msec() / 1000.0

	# Reset state
	_reset_session_stats()
	reset_combo()
	pattern_progress = 0
	pattern_total_notes = current_pattern.get("beats", []).size()

	# Set BPM from difficulty config
	var config: Dictionary = difficulty_config[difficulty]
	var target_bpm: float = config.get("bpm", 120)
	if conductor:
		conductor.set_bpm(target_bpm)

	# Emit pattern changed signal
	pattern_changed.emit(pattern_id, difficulty)

	print("RhythmGame: Started sequence '", pattern_id, "' on ", difficulty, " difficulty")
	return true


## End current rhythm sequence
## @param success: Whether sequence was completed successfully
func end_rhythm_sequence(success: bool) -> void:
	if not is_active:
		return

	is_active = false

	# Calculate final score
	var final_score: int = current_score

	# Update high score if in training mode
	if current_mode == GameMode.TRAINING:
		_update_high_score(current_pattern.get("name", "Unknown"), final_score)

	# Handle boss phase outcomes
	if current_mode == GameMode.BOSS:
		if success:
			boss_stunned.emit()
			print("RhythmGame: Boss stunned!")
		else:
			boss_enraged.emit()
			print("RhythmGame: Boss enraged!")

	# Emit completion signal
	var stats: Dictionary = session_stats.duplicate()
	stats["final_combo"] = combo_count
	stats["final_multiplier"] = combo_multiplier
	sequence_complete.emit(success, final_score, stats)

	print("RhythmGame: Sequence complete - Success: ", success, " | Score: ", final_score)


## Cancel current sequence (e.g., player quit)
func cancel_sequence() -> void:
	if not is_active:
		return

	end_rhythm_sequence(false)


# ═════════════════════════════════════════════════════════════════════════════
# Input Evaluation
# ═════════════════════════════════════════════════════════════════════════════

## Evaluate player input timing
## @param input_time: Time when input occurred (use Time.get_ticks_msec() / 1000.0)
## @return String: Timing quality ("perfect", "good", "miss")
func evaluate_input(input_time: float) -> String:
	if not is_active:
		push_warning("RhythmGame: No active sequence to evaluate")
		return "miss"

	if not conductor:
		push_error("RhythmGame: Conductor not available")
		return "miss"

	# Get timing quality from Conductor
	var timing_quality: String = conductor.get_timing_quality(input_time)

	# Update combo based on timing
	_handle_beat_hit(timing_quality)

	# Update pattern progress
	pattern_progress += 1

	# Calculate score
	var base_score: int = _calculate_base_score(timing_quality)
	var score_with_multiplier: int = int(base_score * combo_multiplier)
	current_score += score_with_multiplier

	# Update stats
	session_stats["total_score"] = current_score

	# Emit signals
	beat_hit.emit(timing_quality, combo_count, combo_multiplier)
	visual_feedback_requested.emit("hit", timing_quality)

	# Check if pattern complete
	if pattern_progress >= pattern_total_notes:
		var success: bool = _evaluate_sequence_success()
		end_rhythm_sequence(success)

	return timing_quality


## Calculate base score for a timing quality
func _calculate_base_score(timing_quality: String) -> int:
	match timing_quality:
		"perfect":
			return 100
		"good":
			return 50
		"miss":
			return 0
		_:
			return 0


## Evaluate if sequence was successful
func _evaluate_sequence_success() -> bool:
	var total_hits: int = session_stats["perfect_hits"] + session_stats["good_hits"] + session_stats["miss_hits"]
	if total_hits == 0:
		return false

	# Success if at least 70% of hits were good or better
	var good_hits: int = session_stats["perfect_hits"] + session_stats["good_hits"]
	var success_rate: float = float(good_hits) / float(total_hits)

	return success_rate >= 0.7


# ═════════════════════════════════════════════════════════════════════════════
# Combo System
# ═════════════════════════════════════════════════════════════════════════════

## Handle beat hit and update combo
func _handle_beat_hit(timing_quality: String) -> void:
	var old_combo: int = combo_count

	match timing_quality:
		"perfect":
			# Perfect hit: increment combo
			combo_count += 1
			session_stats["perfect_hits"] += 1
			_update_combo_multiplier()

		"good":
			# Good hit: maintain combo
			session_stats["good_hits"] += 1

		"miss":
			# Miss: reset combo
			reset_combo()
			session_stats["miss_hits"] += 1

	# Update max combo
	if combo_count > session_stats["max_combo"]:
		session_stats["max_combo"] = combo_count

	# Emit combo changed if changed
	if combo_count != old_combo:
		combo_changed.emit(combo_count, old_combo)


## Update combo multiplier based on combo count
func _update_combo_multiplier() -> void:
	var old_multiplier: float = combo_multiplier

	# Formula: 1.0 + (combo * 0.1), max 3.0x
	combo_multiplier = 1.0 + (combo_count * COMBO_INCREMENT_PER_PERFECT)
	combo_multiplier = min(combo_multiplier, MAX_COMBO_MULTIPLIER)

	if combo_multiplier != old_multiplier:
		multiplier_changed.emit(combo_multiplier)


## Reset combo to 0
func reset_combo() -> void:
	var old_combo: int = combo_count
	combo_count = 0
	combo_multiplier = 1.0

	if old_combo > 0:
		combo_changed.emit(0, old_combo)
		multiplier_changed.emit(1.0)


# ═════════════════════════════════════════════════════════════════════════════
# Conductor Integration
# ═════════════════════════════════════════════════════════════════════════════

## Called every beat by Conductor
func _on_conductor_beat(beat_number: int) -> void:
	if not is_active:
		return

	# Check if current beat is in the pattern
	var pattern_beats: Array = current_pattern.get("beats", [])
	if beat_number in pattern_beats:
		# This is a note beat - spawn visual cue
		visual_feedback_requested.emit("note_spawn", "")


# ═════════════════════════════════════════════════════════════════════════════
# Stats & Scoring
# ═════════════════════════════════════════════════════════════════════════════

## Reset session statistics
func _reset_session_stats() -> void:
	session_stats = {
		"perfect_hits": 0,
		"good_hits": 0,
		"miss_hits": 0,
		"max_combo": 0,
		"total_score": 0
	}
	current_score = 0


## Update high score for a pattern
func _update_high_score(pattern_name: String, score: int) -> void:
	var current_high: int = high_scores.get(pattern_name, 0)
	if score > current_high:
		high_scores[pattern_name] = score
		print("RhythmGame: New high score for '", pattern_name, "': ", score)


## Get high score for a pattern
func get_high_score(pattern_name: String) -> int:
	return high_scores.get(pattern_name, 0)


# ═════════════════════════════════════════════════════════════════════════════
# Public API
# ═════════════════════════════════════════════════════════════════════════════

## Get current combo count
func get_combo_count() -> int:
	return combo_count


## Get current combo multiplier
func get_combo_multiplier() -> float:
	return combo_multiplier


## Get current score
func get_current_score() -> int:
	return current_score


## Get session statistics
func get_session_stats() -> Dictionary:
	return session_stats.duplicate()


## Get rhythm accuracy percentage (perfect + good / total)
func get_rhythm_accuracy() -> float:
	var total_hits: int = session_stats["perfect_hits"] + session_stats["good_hits"] + session_stats["miss_hits"]
	if total_hits == 0:
		return 0.0

	var good_hits: int = session_stats["perfect_hits"] + session_stats["good_hits"]
	return (float(good_hits) / float(total_hits)) * 100.0


## Check if rhythm sequence is active
func is_sequence_active() -> bool:
	return is_active


## Get current pattern info
func get_current_pattern() -> Dictionary:
	return current_pattern.duplicate()


## Get current difficulty
func get_current_difficulty() -> String:
	return current_difficulty


## Get available patterns
func get_available_patterns() -> Array:
	return patterns.keys()


## Get pattern details by ID
func get_pattern(pattern_id: String) -> Dictionary:
	return patterns.get(pattern_id, {})


## Get difficulty config by level
func get_difficulty_config_for_level(difficulty: String) -> Dictionary:
	return difficulty_config.get(difficulty, {})


## Get all difficulty levels
func get_difficulty_levels() -> Array:
	return difficulty_config.keys()


# ═════════════════════════════════════════════════════════════════════════════
# Debug
# ═════════════════════════════════════════════════════════════════════════════

## Print debug information
func print_debug_info() -> void:
	print("═".repeat(60))
	print("RhythmGame Debug Info")
	print("═".repeat(60))
	print("Active: ", is_active)
	print("Mode: ", _mode_to_string(current_mode))
	print("Difficulty: ", current_difficulty)
	print("Combo: ", combo_count, " (x", combo_multiplier, ")")
	print("Score: ", current_score)
	print("Pattern Progress: ", pattern_progress, "/", pattern_total_notes)
	print("Session Stats:")
	for key in session_stats:
		print("  ", key, ": ", session_stats[key])
	print("Patterns Loaded: ", patterns.size())
	print("Difficulties Available: ", difficulty_config.size())
	print("═".repeat(60))


## Convert mode enum to string
func _mode_to_string(mode: GameMode) -> String:
	match mode:
		GameMode.STORY:
			return "Story"
		GameMode.BOSS:
			return "Boss"
		GameMode.TRAINING:
			return "Training"
		_:
			return "Unknown"
