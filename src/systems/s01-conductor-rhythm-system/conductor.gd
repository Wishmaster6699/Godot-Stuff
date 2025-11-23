# Godot 4.5 | GDScript 4.5
# System: S01 - Conductor/Rhythm System
# Created: 2025-11-18
# Dependencies: RhythmNotifier plugin (addons/rhythm_notifier)
#
# The Conductor is the master beat synchronization system that powers ALL rhythm-dependent
# mechanics in the game. It wraps the RhythmNotifier plugin and emits standardized signals
# for downbeat, upbeat, and custom beat intervals with audio latency compensation.
#
# This is a FOUNDATION system - all rhythm-based gameplay (combat, traversal, puzzles)
# depends on this system's signals.

extends Node

## Emitted every 4 beats (measure start) - beat_number is 1-indexed for game designers
signal downbeat(measure_number: int)

## Emitted on beats 2 and 4 of each measure
signal upbeat(beat_number: int)

## Emitted on every beat with 1-indexed beat number
signal beat(beat_number: int)

## Emitted at end of measure (after beat 4)
signal measure_complete(measure_number: int)

## Emitted when BPM changes at runtime
signal bpm_changed(new_bpm: float, old_bpm: float)

# RhythmNotifier plugin instance (must be installed in addons/)
var rhythm_notifier: Node = null

# Configuration loaded from rhythm_config.json
var config: Dictionary = {}

# Current BPM (beats per minute)
var current_bpm: float = 120.0

# Time signature [beats_per_measure, beat_unit]
var time_signature: Array = [4, 4]

# Beat tracking (0-indexed internally, 1-indexed for emissions)
var _current_beat_internal: int = 0
var _current_measure: int = 0

# Timing windows for quality evaluation (in milliseconds)
var timing_windows: Dictionary = {
	"perfect": {"offset_ms": 50, "score_multiplier": 2.0},
	"good": {"offset_ms": 100, "score_multiplier": 1.5},
	"miss": {"offset_ms": 150, "score_multiplier": 0.0}
}

# Visual feedback configuration
var visual_feedback: Dictionary = {}

# Debug settings
var debug_settings: Dictionary = {}

# Flag to track if conductor is actively running
var is_running: bool = false

# Latency compensation (ms) - loaded from config
var latency_compensation_ms: float = 0.0


## Initialize the Conductor and load configuration
func _ready() -> void:
	_load_configuration()
	_initialize_rhythm_notifier()

	if debug_settings.get("log_beat_emissions", false):
		print("Conductor initialized with BPM: ", current_bpm)


## Load rhythm configuration from JSON file
func _load_configuration() -> void:
	var config_path: String = "res://src/systems/s01-conductor-rhythm-system/rhythm_config.json"

	if not FileAccess.file_exists(config_path):
		push_error("Conductor: rhythm_config.json not found at ", config_path)
		_use_default_configuration()
		return

	var file: FileAccess = FileAccess.open(config_path, FileAccess.READ)
	if file == null:
		push_error("Conductor: Failed to open rhythm_config.json")
		_use_default_configuration()
		return

	var json_text: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result: Error = json.parse(json_text)

	if parse_result != OK:
		push_error("Conductor: Failed to parse rhythm_config.json: ", json.get_error_message())
		_use_default_configuration()
		return

	var data: Variant = json.data
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Conductor: Invalid JSON format in rhythm_config.json")
		_use_default_configuration()
		return

	config = data.get("rhythm_config", {})

	# Apply configuration
	current_bpm = config.get("default_bpm", 120.0)
	time_signature = config.get("time_signature", [4, 4])
	timing_windows = config.get("timing_windows", timing_windows)
	visual_feedback = config.get("visual_feedback", {})
	debug_settings = config.get("debug_settings", {})
	latency_compensation_ms = config.get("latency_compensation_ms", 0.0)


## Use default configuration if JSON loading fails
func _use_default_configuration() -> void:
	push_warning("Conductor: Using default configuration")
	config = {
		"default_bpm": 120,
		"time_signature": [4, 4],
		"timing_windows": timing_windows,
		"visual_feedback": {},
		"debug_settings": {},
		"latency_compensation_ms": 0.0
	}


## Initialize RhythmNotifier plugin instance
func _initialize_rhythm_notifier() -> void:
	# Check if RhythmNotifier plugin is available
	# Note: The actual plugin must be installed by Tier 2 agent
	# This creates a placeholder that will be replaced when plugin is available

	# Try to create RhythmNotifier instance
	# If plugin not installed, this will fail gracefully
	if Engine.has_singleton("RhythmNotifier"):
		rhythm_notifier = Engine.get_singleton("RhythmNotifier")
	else:
		# Create a Node as placeholder if plugin not available yet
		# Tier 2 will install plugin and this will be replaced
		rhythm_notifier = Node.new()
		rhythm_notifier.name = "RhythmNotifierPlaceholder"
		add_child(rhythm_notifier)

		push_warning("Conductor: RhythmNotifier plugin not found. Install from AssetLib (asset #3417)")
		push_warning("Conductor: Running in fallback mode - manual beat tracking only")

		# Set up fallback timer-based beat tracking
		_setup_fallback_beat_tracking()
		return

	# Configure RhythmNotifier
	if rhythm_notifier.has_method("set_bpm"):
		rhythm_notifier.set_bpm(current_bpm)

	# Connect RhythmNotifier signals to our standardized signals
	_connect_rhythm_notifier_signals()


## Set up fallback beat tracking using Timer (if RhythmNotifier unavailable)
func _setup_fallback_beat_tracking() -> void:
	var beat_timer: Timer = Timer.new()
	beat_timer.name = "FallbackBeatTimer"
	add_child(beat_timer)

	# Calculate beat interval in seconds
	var beat_interval: float = 60.0 / current_bpm
	beat_timer.wait_time = beat_interval
	beat_timer.timeout.connect(_on_fallback_beat)

	push_warning("Conductor: Using fallback Timer-based beat tracking (not recommended for production)")


## Fallback beat emission (when RhythmNotifier unavailable)
func _on_fallback_beat() -> void:
	_current_beat_internal += 1
	var beat_in_measure: int = (_current_beat_internal % time_signature[0])

	if beat_in_measure == 0:
		beat_in_measure = time_signature[0]

	# Emit beat signal (1-indexed)
	beat.emit(beat_in_measure)

	# Emit downbeat on beat 1
	if beat_in_measure == 1:
		_current_measure += 1
		downbeat.emit(_current_measure)

	# Emit upbeat on beats 2 and 4 (in 4/4 time)
	if beat_in_measure == 2 or beat_in_measure == 4:
		upbeat.emit(beat_in_measure)

	# Emit measure_complete on beat 4
	if beat_in_measure == time_signature[0]:
		measure_complete.emit(_current_measure)


## Connect RhythmNotifier plugin signals to Conductor signals
func _connect_rhythm_notifier_signals() -> void:
	if not rhythm_notifier:
		return

	# Check if RhythmNotifier has the beats() method
	if not rhythm_notifier.has_method("beats"):
		push_warning("Conductor: RhythmNotifier instance doesn't have beats() method")
		return

	# Connect to every beat (1-beat interval)
	var beat_signal: Signal = rhythm_notifier.beats(1, true, 0.0)
	if beat_signal:
		beat_signal.connect(_on_rhythm_notifier_beat)

	# Connect to every 4 beats for downbeat/measure tracking
	var measure_signal: Signal = rhythm_notifier.beats(4, true, 0.0)
	if measure_signal:
		measure_signal.connect(_on_rhythm_notifier_measure)


## Handle beat signal from RhythmNotifier (0-indexed)
func _on_rhythm_notifier_beat(beat_count: int) -> void:
	_current_beat_internal = beat_count

	# Calculate beat within measure (0-indexed internally)
	var beat_in_measure: int = (beat_count % time_signature[0])

	# Convert to 1-indexed for game designers
	var beat_1indexed: int = beat_in_measure + 1

	# Emit standardized beat signal
	beat.emit(beat_1indexed)

	# Emit downbeat on first beat of measure
	if beat_in_measure == 0:
		_current_measure = int(beat_count / time_signature[0])
		downbeat.emit(_current_measure)

	# Emit upbeat on beats 2 and 4 (in 4/4 time)
	if beat_in_measure == 1 or beat_in_measure == 3:  # 0-indexed: 1=beat2, 3=beat4
		upbeat.emit(beat_1indexed)

	# Log beat emissions if debug enabled
	if debug_settings.get("log_beat_emissions", false):
		print("Beat: ", beat_1indexed, " | Measure: ", _current_measure)


## Handle measure signal from RhythmNotifier
func _on_rhythm_notifier_measure(measure_count: int) -> void:
	_current_measure = measure_count
	measure_complete.emit(_current_measure)

	if debug_settings.get("log_beat_emissions", false):
		print("Measure Complete: ", _current_measure)


## Evaluate timing quality of player input relative to nearest beat
## Returns "perfect", "good", or "miss" based on timing windows from config
## @param input_timestamp: Time in seconds when input occurred (use Time.get_ticks_msec() / 1000.0)
## @return String: "perfect", "good", or "miss"
func get_timing_quality(input_timestamp: float) -> String:
	# Get current playback position
	var current_time: float = _get_current_time()

	# Calculate time since last beat
	var beat_duration: float = 60.0 / current_bpm  # Duration of one beat in seconds
	var time_in_beat: float = fmod(current_time, beat_duration)

	# Calculate offset from nearest beat (either previous or next)
	var offset_from_previous: float = time_in_beat
	var offset_from_next: float = beat_duration - time_in_beat
	var nearest_offset: float = min(offset_from_previous, offset_from_next)

	# Convert to milliseconds
	var offset_ms: float = nearest_offset * 1000.0

	# Apply latency compensation
	offset_ms -= latency_compensation_ms
	offset_ms = abs(offset_ms)

	# Evaluate against timing windows (sorted from strictest to most lenient)
	if offset_ms <= timing_windows["perfect"]["offset_ms"]:
		return "perfect"
	elif offset_ms <= timing_windows["good"]["offset_ms"]:
		return "good"
	else:
		return "miss"


## Get current playback time from RhythmNotifier or fallback
func _get_current_time() -> float:
	if rhythm_notifier and rhythm_notifier.has_method("get_current_position"):
		return rhythm_notifier.get_current_position()
	else:
		# Fallback: use Time class
		return Time.get_ticks_msec() / 1000.0


## Change BPM at runtime (affects all future beat emissions)
## @param new_bpm: New beats per minute value
func set_bpm(new_bpm: float) -> void:
	if new_bpm <= 0:
		push_error("Conductor: Invalid BPM value: ", new_bpm)
		return

	var old_bpm: float = current_bpm
	current_bpm = new_bpm

	# Update RhythmNotifier if available
	if rhythm_notifier and rhythm_notifier.has_method("set_bpm"):
		rhythm_notifier.set_bpm(new_bpm)

	# Update fallback timer if using fallback mode
	var fallback_timer: Timer = get_node_or_null("FallbackBeatTimer")
	if fallback_timer:
		fallback_timer.wait_time = 60.0 / new_bpm

	bpm_changed.emit(new_bpm, old_bpm)

	if debug_settings.get("log_beat_emissions", false):
		print("Conductor: BPM changed from ", old_bpm, " to ", new_bpm)


## Get current beat number (1-indexed for game designers)
## @return int: Current beat within measure (1-4 in 4/4 time)
func get_current_beat() -> int:
	var beat_in_measure: int = (_current_beat_internal % time_signature[0])
	return beat_in_measure + 1  # Convert to 1-indexed


## Get current measure number
## @return int: Current measure number
func get_current_measure() -> int:
	return _current_measure


## Get current BPM
## @return float: Current beats per minute
func get_bpm() -> float:
	return current_bpm


## Get audio output latency from AudioServer (for debugging)
## @return float: Output latency in seconds
func get_audio_latency() -> float:
	return AudioServer.get_output_latency()


## Get timing window configuration for a specific quality level
## @param quality: "perfect", "good", or "miss"
## @return Dictionary: Timing window configuration or empty dict if invalid
func get_timing_window(quality: String) -> Dictionary:
	return timing_windows.get(quality, {})


## Get score multiplier for a timing quality
## @param quality: "perfect", "good", or "miss"
## @return float: Score multiplier (0.0 to 2.0)
func get_score_multiplier(quality: String) -> float:
	var window: Dictionary = get_timing_window(quality)
	return window.get("score_multiplier", 0.0)


## Start the conductor (begins beat emissions)
func start() -> void:
	if is_running:
		push_warning("Conductor: Already running")
		return

	is_running = true

	# Start RhythmNotifier if available
	if rhythm_notifier and rhythm_notifier.has_method("start"):
		rhythm_notifier.start()

	# Start fallback timer if using fallback mode
	var fallback_timer: Timer = get_node_or_null("FallbackBeatTimer")
	if fallback_timer:
		fallback_timer.start()

	if debug_settings.get("log_beat_emissions", false):
		print("Conductor: Started at BPM ", current_bpm)


## Stop the conductor (stops beat emissions)
func stop() -> void:
	if not is_running:
		return

	is_running = false

	# Stop RhythmNotifier if available
	if rhythm_notifier and rhythm_notifier.has_method("stop"):
		rhythm_notifier.stop()

	# Stop fallback timer if using fallback mode
	var fallback_timer: Timer = get_node_or_null("FallbackBeatTimer")
	if fallback_timer:
		fallback_timer.stop()

	if debug_settings.get("log_beat_emissions", false):
		print("Conductor: Stopped")


## Pause the conductor
func pause() -> void:
	if not is_running:
		return

	# Pause RhythmNotifier if available
	if rhythm_notifier and rhythm_notifier.has_method("pause"):
		rhythm_notifier.pause()

	# Pause fallback timer if using fallback mode
	var fallback_timer: Timer = get_node_or_null("FallbackBeatTimer")
	if fallback_timer:
		fallback_timer.paused = true


## Resume the conductor after pause
func resume() -> void:
	if not is_running:
		start()
		return

	# Resume RhythmNotifier if available
	if rhythm_notifier and rhythm_notifier.has_method("resume"):
		rhythm_notifier.resume()

	# Resume fallback timer if using fallback mode
	var fallback_timer: Timer = get_node_or_null("FallbackBeatTimer")
	if fallback_timer:
		fallback_timer.paused = false


## Get visual feedback color for a timing quality
## @param quality: "perfect", "good", or "miss"
## @return Color: Color for visual feedback
func get_timing_color(quality: String) -> Color:
	var window: Dictionary = get_timing_window(quality)
	var color_hex: String = window.get("color", "#FFFFFF")
	return Color(color_hex)


## Get visual feedback settings
## @return Dictionary: Visual feedback configuration
func get_visual_feedback_config() -> Dictionary:
	return visual_feedback


## Print debug information about current state
func print_debug_info() -> void:
	print("═".repeat(60))
	print("Conductor Debug Info")
	print("═".repeat(60))
	print("BPM: ", current_bpm)
	print("Time Signature: ", time_signature[0], "/", time_signature[1])
	print("Current Beat: ", get_current_beat())
	print("Current Measure: ", _current_measure)
	print("Audio Latency: ", get_audio_latency(), " seconds")
	print("Latency Compensation: ", latency_compensation_ms, " ms")
	print("Running: ", is_running)
	print("RhythmNotifier Available: ", rhythm_notifier != null and rhythm_notifier.has_method("beats"))
	print("Timing Windows:")
	for quality in timing_windows:
		var window: Dictionary = timing_windows[quality]
		print("  ", quality, ": ±", window["offset_ms"], "ms (x", window["score_multiplier"], ")")
	print("═".repeat(60))
