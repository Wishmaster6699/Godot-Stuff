# Godot 4.5 | GDScript 4.5
# System: S01 - Conductor/Rhythm System - Debug Overlay
# Created: 2025-11-18
# Dependencies: Conductor autoload
#
# Debug overlay that displays real-time rhythm information.
# Attach to a CanvasLayer node and toggle with F3 key.
# This overlay can be added to any scene to visualize beat timing.

extends CanvasLayer

# UI elements (assigned by Tier 2 via scene configuration)
@onready var debug_panel: Panel = $DebugPanel
@onready var bpm_label: Label = $DebugPanel/DebugInfo/BPMLabel
@onready var beat_label: Label = $DebugPanel/DebugInfo/BeatLabel
@onready var measure_label: Label = $DebugPanel/DebugInfo/MeasureLabel
@onready var latency_label: Label = $DebugPanel/DebugInfo/LatencyLabel
@onready var timing_windows_label: Label = $DebugPanel/DebugInfo/TimingWindowsLabel
@onready var status_label: Label = $DebugPanel/DebugInfo/StatusLabel

# Visibility state
var is_visible: bool = false

# Update frequency (updates per second)
var update_frequency: float = 10.0
var time_since_update: float = 0.0


func _ready() -> void:
	# Start hidden
	visible = false

	# Check if Conductor is available
	if not Conductor:
		push_error("Debug Overlay: Conductor autoload not found!")
		return

	# Connect to Conductor signals for real-time updates
	Conductor.beat.connect(_on_conductor_beat)
	Conductor.bpm_changed.connect(_on_bpm_changed)

	# Initial update
	_update_display()

	print("Debug Overlay: Press F3 to toggle")


func _process(delta: float) -> void:
	if not visible:
		return

	# Update display at specified frequency
	time_since_update += delta
	if time_since_update >= (1.0 / update_frequency):
		_update_display()
		time_since_update = 0.0


func _unhandled_input(event: InputEvent) -> void:
	# Toggle visibility with F3 key
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		_toggle_visibility()
		get_viewport().set_input_as_handled()


## Toggle debug overlay visibility
func _toggle_visibility() -> void:
	is_visible = !is_visible
	visible = is_visible

	if is_visible:
		_update_display()
		print("Debug Overlay: Visible")
	else:
		print("Debug Overlay: Hidden")


## Update all debug display elements
func _update_display() -> void:
	if not Conductor:
		return

	# BPM display
	if bpm_label:
		bpm_label.text = "BPM: %.1f" % Conductor.get_bpm()

	# Beat and measure display
	if beat_label:
		beat_label.text = "Beat: %d / %d" % [Conductor.get_current_beat(), Conductor.time_signature[0]]

	if measure_label:
		measure_label.text = "Measure: %d" % Conductor.get_current_measure()

	# Latency information
	if latency_label:
		var audio_latency: float = Conductor.get_audio_latency()
		var latency_compensation: float = Conductor.latency_compensation_ms
		latency_label.text = "Latency: %.1fms (comp: %.1fms)" % [audio_latency * 1000.0, latency_compensation]

	# Timing windows display
	if timing_windows_label:
		var perfect_window: Dictionary = Conductor.get_timing_window("perfect")
		var good_window: Dictionary = Conductor.get_timing_window("good")

		var windows_text: String = "Timing Windows:\n"
		windows_text += "  Perfect: ±%dms (x%.1f)\n" % [perfect_window.get("offset_ms", 0), perfect_window.get("score_multiplier", 0)]
		windows_text += "  Good: ±%dms (x%.1f)" % [good_window.get("offset_ms", 0), good_window.get("score_multiplier", 0)]

		timing_windows_label.text = windows_text

	# Status display
	if status_label:
		var status_text: String = "Status: "
		if Conductor.is_running:
			status_text += "Running"
		else:
			status_text += "Stopped"

		status_label.text = status_text


## Signal handler: Beat emitted
func _on_conductor_beat(beat_number: int) -> void:
	# Immediate update on beat for responsiveness
	if visible:
		_update_display()

	# Flash the panel border on beat
	if debug_panel:
		_flash_panel_border()


## Signal handler: BPM changed
func _on_bpm_changed(new_bpm: float, old_bpm: float) -> void:
	if visible:
		_update_display()


## Flash the panel border to visualize beat
func _flash_panel_border() -> void:
	if not debug_panel:
		return

	# Create a brief flash animation
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	# Flash to bright color and back
	var original_modulate: Color = debug_panel.modulate
	var flash_color: Color = Color(1.5, 1.5, 1.5, 1.0)

	tween.tween_property(debug_panel, "modulate", flash_color, 0.05)
	tween.tween_property(debug_panel, "modulate", original_modulate, 0.15)


## Get formatted timing information for external use
func get_timing_info() -> Dictionary:
	return {
		"bpm": Conductor.get_bpm(),
		"current_beat": Conductor.get_current_beat(),
		"current_measure": Conductor.get_current_measure(),
		"audio_latency_ms": Conductor.get_audio_latency() * 1000.0,
		"latency_compensation_ms": Conductor.latency_compensation_ms,
		"is_running": Conductor.is_running
	}


## Clean up on exit
func _exit_tree() -> void:
	if Conductor:
		if Conductor.beat.is_connected(_on_conductor_beat):
			Conductor.beat.disconnect(_on_conductor_beat)
		if Conductor.bpm_changed.is_connected(_on_bpm_changed):
			Conductor.bpm_changed.disconnect(_on_bpm_changed)
