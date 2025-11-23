# Godot 4.5 | GDScript 4.5
# System: S17 - Puzzle System - Rhythmic Puzzles
# Created: 2025-11-18
# Dependencies: S01 (Conductor/Rhythm System)
# Purpose: Rhythmic puzzles (beat sequences, Simon Says, multi-beat patterns)

extends Puzzle
class_name RhythmPuzzle

## Rhythm puzzle specific signals

## Emitted when player hits a beat correctly
signal beat_hit_correct(beat_index: int, timing_quality: String)

## Emitted when player misses a beat
signal beat_missed(beat_index: int)

## Emitted when player hits wrong beat
signal beat_hit_wrong(beat_index: int)

## Emitted when pattern sequence completes
signal pattern_complete(success: bool)

## Rhythm puzzle subtypes
enum RhythmPuzzleType {
	BEAT_SEQUENCE,     # Hit specific beats in order
	SIMON_SAYS,        # Repeat shown pattern
	MULTI_BEAT,        # Complex rhythm patterns (4/4, 3/4)
	TIMING_LOCK        # Hold beat window for duration
}

@export var rhythm_puzzle_type: RhythmPuzzleType = RhythmPuzzleType.BEAT_SEQUENCE

# Rhythm configuration
var beat_pattern: Array = []  # Array of beat numbers to hit (1-4)
var timing_tolerance: String = "good"  # perfect, good, or miss
var required_combo: int = 1  # How many times pattern must be repeated

# State tracking
var current_beat_index: int = 0
var pattern_repetitions: int = 0
var hit_beats: Array[int] = []
var last_hit_time: float = 0.0
var waiting_for_input: bool = false
var current_measure: int = 0

# Visual feedback
var beat_indicators: Array = []  # Visual beat markers


func _ready() -> void:
	puzzle_type = PuzzleType.RHYTHMIC
	super._ready()


## Initialize rhythm puzzle
func _initialize_puzzle() -> void:
	super._initialize_puzzle()

	# Load beat pattern from solution data
	beat_pattern = solution_data.get("beat_pattern", [])
	timing_tolerance = solution_data.get("timing_tolerance", "good")
	required_combo = solution_data.get("required_combo", 1)

	# Connect to Conductor for beat signals
	_connect_to_conductor()

	# Setup based on rhythm puzzle type
	match rhythm_puzzle_type:
		RhythmPuzzleType.BEAT_SEQUENCE:
			_setup_beat_sequence_puzzle()
		RhythmPuzzleType.SIMON_SAYS:
			_setup_simon_says_puzzle()
		RhythmPuzzleType.MULTI_BEAT:
			_setup_multi_beat_puzzle()
		RhythmPuzzleType.TIMING_LOCK:
			_setup_timing_lock_puzzle()


## Connect to Conductor for rhythm events
func _connect_to_conductor() -> void:
	if conductor == null:
		push_error("RhythmPuzzle: Conductor not found! Cannot initialize rhythm puzzle.")
		return

	# Connect to beat signals
	if conductor.has_signal("beat"):
		conductor.beat.connect(_on_conductor_beat)
	if conductor.has_signal("downbeat"):
		conductor.downbeat.connect(_on_conductor_downbeat)
	if conductor.has_signal("measure_complete"):
		conductor.measure_complete.connect(_on_conductor_measure_complete)

	print("RhythmPuzzle: Connected to Conductor")


## Setup beat sequence puzzle
func _setup_beat_sequence_puzzle() -> void:
	print("RhythmPuzzle: Setting up beat sequence puzzle")
	# Solution data should contain beat sequence
	# Example: {"beat_pattern": [1, 3, 2, 4], "timing_tolerance": "good"}


## Setup Simon Says puzzle
func _setup_simon_says_puzzle() -> void:
	print("RhythmPuzzle: Setting up Simon Says puzzle")
	# Solution data should contain pattern to repeat
	# Example: {"beat_pattern": [1, 1, 2, 3, 4], "required_combo": 3}


## Setup multi-beat pattern puzzle
func _setup_multi_beat_puzzle() -> void:
	print("RhythmPuzzle: Setting up multi-beat pattern puzzle")
	# Solution data should contain complex rhythm pattern
	# Example: {"beat_pattern": [1, 2, 3, 4, 1, 3], "time_signature": [4, 4]}


## Setup timing lock puzzle
func _setup_timing_lock_puzzle() -> void:
	print("RhythmPuzzle: Setting up timing lock puzzle")
	# Solution data should contain timing window
	# Example: {"hold_beats": 8, "timing_tolerance": "perfect"}


## Check if puzzle solution is correct
func check_solution() -> bool:
	match rhythm_puzzle_type:
		RhythmPuzzleType.BEAT_SEQUENCE:
			return _check_beat_sequence_solution()
		RhythmPuzzleType.SIMON_SAYS:
			return _check_simon_says_solution()
		RhythmPuzzleType.MULTI_BEAT:
			return _check_multi_beat_solution()
		RhythmPuzzleType.TIMING_LOCK:
			return _check_timing_lock_solution()

	return false


## Check beat sequence solution
func _check_beat_sequence_solution() -> bool:
	# Check if hit beats match required pattern
	if hit_beats.size() != beat_pattern.size():
		return false

	for i in range(beat_pattern.size()):
		if hit_beats[i] != beat_pattern[i]:
			return false

	return true


## Check Simon Says solution
func _check_simon_says_solution() -> bool:
	# Check if pattern was repeated correct number of times
	return pattern_repetitions >= required_combo


## Check multi-beat solution
func _check_multi_beat_solution() -> bool:
	# Check if complex pattern matches
	if hit_beats.size() != beat_pattern.size():
		return false

	for i in range(beat_pattern.size()):
		if hit_beats[i] != beat_pattern[i]:
			return false

	return true


## Check timing lock solution
func _check_timing_lock_solution() -> bool:
	var hold_beats: int = solution_data.get("hold_beats", 0)
	# Check if player maintained timing for required number of beats
	return hit_beats.size() >= hold_beats


## Called when Conductor emits beat signal
func _on_conductor_beat(beat_number: int) -> void:
	if not is_active or is_solved:
		return

	# Update waiting state
	waiting_for_input = true

	# Visual feedback for current beat
	_highlight_beat_indicator(beat_number)


## Called when Conductor emits downbeat signal
func _on_conductor_downbeat(measure_number: int) -> void:
	if not is_active or is_solved:
		return

	current_measure = measure_number
	print("RhythmPuzzle: Measure %d started" % measure_number)


## Called when Conductor emits measure complete signal
func _on_conductor_measure_complete(measure_number: int) -> void:
	if not is_active or is_solved:
		return

	# Check if pattern should reset at end of measure
	if rhythm_puzzle_type == RhythmPuzzleType.MULTI_BEAT:
		# Multi-beat patterns might span multiple measures
		pass


## Handle player input on beat (called from input system)
func hit_beat() -> void:
	if not is_active or is_solved:
		return

	if conductor == null:
		push_error("RhythmPuzzle: Conductor not available")
		return

	# Get current beat number
	var current_beat: int = conductor.get_current_beat()

	# Get timing quality
	var input_time: float = Time.get_ticks_msec() / 1000.0
	var timing_quality: String = conductor.get_timing_quality(input_time)

	print("RhythmPuzzle: Player hit beat %d with %s timing" % [current_beat, timing_quality])

	# Check if timing is acceptable
	if timing_quality == "miss":
		beat_missed.emit(current_beat_index)
		fail_puzzle("timing_miss")
		_reset_pattern()
		return

	# Check if timing meets tolerance requirement
	if timing_tolerance == "perfect" and timing_quality != "perfect":
		beat_missed.emit(current_beat_index)
		fail_puzzle("timing_not_perfect")
		_reset_pattern()
		return

	# Check if this is the correct beat in the pattern
	if current_beat_index >= beat_pattern.size():
		# Pattern already complete
		return

	var expected_beat: int = beat_pattern[current_beat_index]

	if current_beat != expected_beat:
		beat_hit_wrong.emit(current_beat_index)
		fail_puzzle("wrong_beat")
		_reset_pattern()
		return

	# Correct beat hit!
	hit_beats.append(current_beat)
	current_beat_index += 1
	last_hit_time = input_time

	beat_hit_correct.emit(current_beat_index - 1, timing_quality)
	print("RhythmPuzzle: Correct beat! (%d/%d)" % [current_beat_index, beat_pattern.size()])

	# Check if pattern is complete
	if current_beat_index >= beat_pattern.size():
		_on_pattern_complete()


## Called when beat pattern is completed
func _on_pattern_complete() -> void:
	pattern_repetitions += 1
	pattern_complete.emit(true)
	print("RhythmPuzzle: Pattern complete! (Repetition %d/%d)" % [pattern_repetitions, required_combo])

	# Check if puzzle is solved
	if check_solution():
		solve_puzzle()
	else:
		# Reset for next repetition
		_reset_pattern()


## Reset pattern for next attempt
func _reset_pattern() -> void:
	current_beat_index = 0
	hit_beats.clear()
	waiting_for_input = false


## Highlight beat indicator for visual feedback
func _highlight_beat_indicator(beat_number: int) -> void:
	# TODO: Update visual indicators (handled by scene/UI)
	# This would highlight the current beat marker
	pass


## Activate puzzle (override to start conductor if needed)
func activate() -> void:
	super.activate()

	# Ensure conductor is running
	if conductor != null and conductor.has_method("is_running"):
		var is_running: bool = conductor.get("is_running")
		if not is_running and conductor.has_method("start"):
			conductor.start()
			print("RhythmPuzzle: Started Conductor")


## Reset puzzle to initial state
func _on_puzzle_reset() -> void:
	current_beat_index = 0
	pattern_repetitions = 0
	hit_beats.clear()
	last_hit_time = 0.0
	waiting_for_input = false
	current_measure = 0


## Get puzzle progress (0.0 to 1.0)
func get_progress() -> float:
	if is_solved:
		return 1.0

	match rhythm_puzzle_type:
		RhythmPuzzleType.BEAT_SEQUENCE, RhythmPuzzleType.MULTI_BEAT:
			if beat_pattern.is_empty():
				return 0.0
			return float(current_beat_index) / float(beat_pattern.size())

		RhythmPuzzleType.SIMON_SAYS:
			if required_combo <= 0:
				return 0.0
			# Progress based on pattern repetitions
			var base_progress: float = float(pattern_repetitions) / float(required_combo)
			# Add partial progress for current pattern
			if not beat_pattern.is_empty():
				var pattern_progress: float = float(current_beat_index) / float(beat_pattern.size())
				base_progress += pattern_progress / float(required_combo)
			return min(base_progress, 1.0)

		RhythmPuzzleType.TIMING_LOCK:
			var hold_beats: int = solution_data.get("hold_beats", 0)
			if hold_beats <= 0:
				return 0.0
			return float(hit_beats.size()) / float(hold_beats)

	return 0.0


## Get hint for puzzle
func get_hint() -> String:
	var base_hint: String = super.get_hint()

	if base_hint != "No hint available":
		return base_hint

	# Provide rhythm-specific hints
	match rhythm_puzzle_type:
		RhythmPuzzleType.BEAT_SEQUENCE:
			return "Hit beats in this order: %s" % str(beat_pattern)
		RhythmPuzzleType.SIMON_SAYS:
			return "Repeat the pattern %d times: %s" % [required_combo, str(beat_pattern)]
		RhythmPuzzleType.MULTI_BEAT:
			return "Follow the complex rhythm pattern: %s" % str(beat_pattern)
		RhythmPuzzleType.TIMING_LOCK:
			var hold_beats: int = solution_data.get("hold_beats", 0)
			return "Maintain perfect timing for %d beats" % hold_beats

	return "Listen to the rhythm and hit the beats correctly"


## Get current BPM from conductor
func get_current_bpm() -> float:
	if conductor != null and conductor.has_method("get_bpm"):
		return conductor.get_bpm()
	return 120.0


## Get time signature from conductor
func get_time_signature() -> Array:
	if conductor != null and conductor.has_property("time_signature"):
		return conductor.get("time_signature")
	return [4, 4]
