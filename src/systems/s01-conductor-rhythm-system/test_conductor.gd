# Godot 4.5 | GDScript 4.5
# System: S01 - Conductor/Rhythm System - Test Script
# Created: 2025-11-18
# Dependencies: Conductor autoload
#
# This script tests the Conductor system by visualizing beat emissions and
# allowing manual timing quality testing via keyboard/controller input.
# Attach to the root Node2D of test_conductor.tscn scene.

extends Node2D

# UI elements (assigned by Tier 2 via scene configuration)
@onready var bpm_label: Label = $BPMDisplay
@onready var beat_label: Label = $BeatDisplay
@onready var measure_label: Label = $MeasureDisplay
@onready var timing_quality_label: Label = $TimingQualityDisplay
@onready var beat_flash: ColorRect = $BeatFlash
@onready var test_audio: AudioStreamPlayer = $TestAudio

# Track last input for timing quality testing
var last_input_time: float = 0.0
var last_quality: String = ""

# Visual feedback animation state
var flash_timer: float = 0.0
var flash_duration: float = 0.1

# BPM test presets for runtime testing
var bpm_presets: Array = [60, 120, 180]
var current_preset_index: int = 1  # Start at 120 BPM


func _ready() -> void:
	# Connect to Conductor signals
	if Conductor:
		Conductor.beat.connect(_on_conductor_beat)
		Conductor.downbeat.connect(_on_conductor_downbeat)
		Conductor.upbeat.connect(_on_conductor_upbeat)
		Conductor.measure_complete.connect(_on_conductor_measure_complete)
		Conductor.bpm_changed.connect(_on_conductor_bpm_changed)

		print("Test Scene: Connected to Conductor signals")
		print("Test Scene: Press SPACE to test timing quality")
		print("Test Scene: Press B to change BPM (60/120/180)")
		print("Test Scene: Press P to play/pause")
		print("Test Scene: Press D to toggle debug info")
	else:
		push_error("Test Scene: Conductor autoload not found!")
		return

	# Initialize UI
	_update_ui()

	# Start conductor automatically for testing
	Conductor.start()


func _process(delta: float) -> void:
	# Handle flash animation
	if flash_timer > 0.0:
		flash_timer -= delta
		var alpha: float = flash_timer / flash_duration
		var color: Color = beat_flash.color
		color.a = alpha * 0.5  # Max 50% opacity
		beat_flash.color = color

	# Update current beat display
	if beat_label:
		beat_label.text = "Beat: %d" % Conductor.get_current_beat()

	if measure_label:
		measure_label.text = "Measure: %d" % Conductor.get_current_measure()


func _unhandled_input(event: InputEvent) -> void:
	# Test timing quality on spacebar press
	if event is InputEventKey and event.pressed and event.keycode == KEY_SPACE:
		_test_timing_quality()

	# Change BPM on 'B' key press
	if event is InputEventKey and event.pressed and event.keycode == KEY_B:
		_cycle_bpm_preset()

	# Toggle play/pause on 'P' key press
	if event is InputEventKey and event.pressed and event.keycode == KEY_P:
		_toggle_playback()

	# Print debug info on 'D' key press
	if event is InputEventKey and event.pressed and event.keycode == KEY_D:
		Conductor.print_debug_info()


## Test timing quality of current input
func _test_timing_quality() -> void:
	last_input_time = Time.get_ticks_msec() / 1000.0
	last_quality = Conductor.get_timing_quality(last_input_time)

	# Update UI
	if timing_quality_label:
		var quality_color: Color = Conductor.get_timing_color(last_quality)
		var multiplier: float = Conductor.get_score_multiplier(last_quality)

		timing_quality_label.text = "Timing: %s (x%.1f)" % [last_quality.to_upper(), multiplier]
		timing_quality_label.modulate = quality_color

	# Visual feedback
	_flash_beat_indicator(Conductor.get_timing_color(last_quality))

	print("Timing Quality: ", last_quality, " | Multiplier: ", Conductor.get_score_multiplier(last_quality))


## Cycle through BPM presets (60, 120, 180)
func _cycle_bpm_preset() -> void:
	current_preset_index = (current_preset_index + 1) % bpm_presets.size()
	var new_bpm: float = bpm_presets[current_preset_index]
	Conductor.set_bpm(new_bpm)

	print("BPM changed to: ", new_bpm)


## Toggle playback (pause/resume)
func _toggle_playback() -> void:
	if Conductor.is_running:
		Conductor.pause()
		print("Conductor paused")
	else:
		Conductor.resume()
		print("Conductor resumed")


## Update all UI elements
func _update_ui() -> void:
	if bpm_label:
		bpm_label.text = "BPM: %d" % Conductor.get_bpm()

	if beat_label:
		beat_label.text = "Beat: %d" % Conductor.get_current_beat()

	if measure_label:
		measure_label.text = "Measure: %d" % Conductor.get_current_measure()

	if timing_quality_label:
		timing_quality_label.text = "Timing: (press SPACE to test)"


## Flash the beat indicator with specified color
func _flash_beat_indicator(color: Color) -> void:
	if beat_flash:
		beat_flash.color = color
		flash_timer = flash_duration


## Signal handler: Beat emitted
func _on_conductor_beat(beat_number: int) -> void:
	print("Beat: ", beat_number)

	# Flash white for normal beats
	var flash_color: Color = Color(1, 1, 1, 0.5)
	_flash_beat_indicator(flash_color)


## Signal handler: Downbeat emitted (first beat of measure)
func _on_conductor_downbeat(measure_number: int) -> void:
	print("Downbeat! Measure: ", measure_number)

	# Flash green for downbeat
	var visual_config: Dictionary = Conductor.get_visual_feedback_config()
	var downbeat_color_hex: String = visual_config.get("downbeat_color", "#00FF00")
	var flash_color: Color = Color(downbeat_color_hex)
	_flash_beat_indicator(flash_color)


## Signal handler: Upbeat emitted (beats 2 and 4)
func _on_conductor_upbeat(beat_number: int) -> void:
	print("Upbeat: ", beat_number)

	# Flash yellow for upbeat
	var visual_config: Dictionary = Conductor.get_visual_feedback_config()
	var upbeat_color_hex: String = visual_config.get("upbeat_color", "#FFFF00")
	var flash_color: Color = Color(upbeat_color_hex)
	_flash_beat_indicator(flash_color)


## Signal handler: Measure complete
func _on_conductor_measure_complete(measure_number: int) -> void:
	print("Measure Complete: ", measure_number)

	# Flash cyan for measure complete
	var visual_config: Dictionary = Conductor.get_visual_feedback_config()
	var measure_color_hex: String = visual_config.get("measure_complete_color", "#00FFFF")
	var flash_color: Color = Color(measure_color_hex)
	_flash_beat_indicator(flash_color)


## Signal handler: BPM changed
func _on_conductor_bpm_changed(new_bpm: float, old_bpm: float) -> void:
	print("BPM Changed: ", old_bpm, " -> ", new_bpm)
	_update_ui()


## Clean up on exit
func _exit_tree() -> void:
	# Disconnect signals
	if Conductor:
		if Conductor.beat.is_connected(_on_conductor_beat):
			Conductor.beat.disconnect(_on_conductor_beat)
		if Conductor.downbeat.is_connected(_on_conductor_downbeat):
			Conductor.downbeat.disconnect(_on_conductor_downbeat)
		if Conductor.upbeat.is_connected(_on_conductor_upbeat):
			Conductor.upbeat.disconnect(_on_conductor_upbeat)
		if Conductor.measure_complete.is_connected(_on_conductor_measure_complete):
			Conductor.measure_complete.disconnect(_on_conductor_measure_complete)
		if Conductor.bpm_changed.is_connected(_on_conductor_bpm_changed):
			Conductor.bpm_changed.disconnect(_on_conductor_bpm_changed)

		# Stop conductor
		Conductor.stop()
