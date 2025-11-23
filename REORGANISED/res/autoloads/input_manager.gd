# Godot 4.5 | GDScript 4.5
# System: S02 - Controller Input System
# Created: 2025-11-18
# Dependencies: None (foundation system)
# Purpose: Manages all controller input with 4-lane rhythm support, deadzone filtering, and input buffering

extends Node

class_name InputManagerImpl

## Signal emitted when a rhythm lane button is pressed
signal lane_pressed(lane_id: int, timestamp: float)

## Signal emitted when a rhythm lane button is released
signal lane_released(lane_id: int, timestamp: float)

## Signal emitted when a non-rhythm button is pressed
signal button_pressed(action: String)

## Signal emitted when a button is held for >0.3 seconds
signal button_held(action: String, hold_duration: float)

## Signal emitted when a non-rhythm button is released
signal button_released(action: String)

## Signal emitted when an analog stick moves
signal stick_moved(stick: String, direction: Vector2, magnitude: float)

## Signal emitted when a controller is connected
signal controller_connected(device_id: int)

## Signal emitted when a controller is disconnected
signal controller_disconnected(device_id: int)

# Configuration
var config: Dictionary = {}
var rhythm_lanes: Array[Dictionary] = []
var deadzones: Dictionary = {}
var action_mappings: Dictionary = {}
var input_buffer_config: Dictionary = {}

# State tracking
var input_buffer: Array[Dictionary] = []
var button_hold_timers: Dictionary = {}  # Track hold durations
var stick_positions: Dictionary = {}  # Track current stick positions
var pressed_buttons: Dictionary = {}  # Track currently pressed buttons
var connected_devices: Array[int] = []

const HOLD_THRESHOLD_MS: float = 300.0
const CONFIG_PATH: String = "res://data/input_config.json"

func _ready() -> void:
	print("InputManager: Initializing...")
	_load_config()
	_setup_input_signals()
	print("InputManager: Ready. Connected devices: %d" % Input.get_connected_joypads().size())

func _load_config() -> void:
	"""Load configuration from input_config.json"""
	var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		push_error("InputManager: Failed to load config from %s" % CONFIG_PATH)
		return

	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		push_error("InputManager: JSON parse error: %s" % json.get_error_message())
		return

	var data = json.data as Dictionary
	if data.is_empty() or not data.has("input_config"):
		push_error("InputManager: Invalid config structure")
		return

	var input_config = data["input_config"] as Dictionary

	# Load rhythm lanes
	if input_config.has("rhythm_lanes"):
		rhythm_lanes = input_config["rhythm_lanes"] as Array[Dictionary]

	# Load deadzones
	if input_config.has("deadzones"):
		deadzones = input_config["deadzones"] as Dictionary

	# Load action mappings
	if input_config.has("action_mappings"):
		action_mappings = input_config["action_mappings"] as Dictionary

	# Load input buffer config
	if input_config.has("input_buffer"):
		input_buffer_config = input_config["input_buffer"] as Dictionary

	config = input_config
	print("InputManager: Config loaded successfully")
	print("  - Rhythm lanes: %d" % rhythm_lanes.size())
	print("  - Action mappings: %d" % action_mappings.size())
	print("  - Deadzones: %s" % deadzones)

func _setup_input_signals() -> void:
	"""Connect to Input signals for controller connect/disconnect"""
	Input.joy_connection_changed.connect(_on_joy_connection_changed)

func _on_joy_connection_changed(device: int, connected: bool) -> void:
	"""Handle controller connection/disconnection"""
	if connected:
		if not device in connected_devices:
			connected_devices.append(device)
		controller_connected.emit(device)
		print("InputManager: Controller connected (device %d)" % device)
	else:
		connected_devices.erase(device)
		controller_disconnected.emit(device)
		print("InputManager: Controller disconnected (device %d)" % device)

func _process(_delta: float) -> void:
	"""Process input and update buffer"""
	_update_stick_input()
	_update_button_holds()
	_cleanup_input_buffer()

func _unhandled_input(event: InputEvent) -> void:
	"""Handle input events from joystick"""
	if event is InputEventJoypadButton:
		_handle_joypad_button(event as InputEventJoypadButton)
	elif event is InputEventJoypadMotion:
		_handle_joypad_motion(event as InputEventJoypadMotion)

func _handle_joypad_button(event: InputEventJoypadButton) -> void:
	"""Process joypad button events"""
	var button_index = event.button_index
	var is_pressed = event.pressed
	var timestamp = Time.get_ticks_msec() / 1000.0

	# Check if this is a rhythm lane button
	var lane_id = _get_lane_id_for_button(button_index)
	if lane_id >= 0:
		if is_pressed:
			lane_pressed.emit(lane_id, timestamp)
			_add_to_buffer({"action": "lane_%d" % lane_id, "timestamp": timestamp, "type": "button_press"})
		else:
			lane_released.emit(lane_id, timestamp)
			_add_to_buffer({"action": "lane_%d" % lane_id, "timestamp": timestamp, "type": "button_release"})

	# Check if this is an action button
	var action_name = _get_action_for_button(button_index)
	if action_name != "":
		if is_pressed:
			pressed_buttons[action_name] = Time.get_ticks_msec()
			button_pressed.emit(action_name)
			_add_to_buffer({"action": action_name, "timestamp": timestamp, "type": "button_press"})
		else:
			button_released.emit(action_name)
			_add_to_buffer({"action": action_name, "timestamp": timestamp, "type": "button_release"})
			if action_name in pressed_buttons:
				pressed_buttons.erase(action_name)

func _handle_joypad_motion(event: InputEventJoypadMotion) -> void:
	"""Process joypad motion events (analog sticks)"""
	var axis = event.axis
	var value = event.axis_value
	var timestamp = Time.get_ticks_msec() / 1000.0

	# Identify which stick this is
	var stick_name = _get_stick_name_for_axis(axis)
	if stick_name == "":
		return

	# Initialize stick position if not present
	if not stick_name in stick_positions:
		stick_positions[stick_name] = Vector2.ZERO

	# Update stick position based on axis
	if axis in [JOY_AXIS_LEFT_X, JOY_AXIS_RIGHT_X]:
		var current = stick_positions[stick_name] as Vector2
		stick_positions[stick_name] = Vector2(value, current.y)
	elif axis in [JOY_AXIS_LEFT_Y, JOY_AXIS_RIGHT_Y]:
		var current = stick_positions[stick_name] as Vector2
		stick_positions[stick_name] = Vector2(current.x, value)

	# Apply deadzone and emit signal
	var deadzone_value = _get_deadzone_for_stick(stick_name)
	var filtered_pos = _apply_circular_deadzone(stick_positions[stick_name], deadzone_value)
	var magnitude = filtered_pos.length()

	if magnitude > 0.01:  # Only emit if significant movement
		stick_moved.emit(stick_name, filtered_pos, magnitude)
		_add_to_buffer({"action": "stick_%s" % stick_name, "timestamp": timestamp, "type": "motion"})

func _update_stick_input() -> void:
	"""Update analog stick positions each frame"""
	for stick_name in ["left_stick", "right_stick"]:
		var pos = _get_stick_input(stick_name)
		if stick_name in stick_positions and stick_positions[stick_name] != pos:
			stick_positions[stick_name] = pos

func _update_button_holds() -> void:
	"""Check for button holds and emit signals when threshold exceeded"""
	var current_time = Time.get_ticks_msec()

	for action_name in pressed_buttons.keys():
		var press_time = pressed_buttons[action_name] as int
		var hold_duration = (current_time - press_time) / 1000.0

		if hold_duration >= HOLD_THRESHOLD_MS / 1000.0:
			if not action_name in button_hold_timers:
				button_hold_timers[action_name] = true
				button_held.emit(action_name, hold_duration)

func _add_to_buffer(entry: Dictionary) -> void:
	"""Add input to buffer (max 10 entries)"""
	var max_size = input_buffer_config.get("max_size", 10) as int

	input_buffer.append(entry)
	if input_buffer.size() > max_size:
		input_buffer.pop_front()

func _cleanup_input_buffer() -> void:
	"""Remove old entries from buffer"""
	var retention_time_ms = input_buffer_config.get("retention_time_ms", 200) as int
	var current_time = Time.get_ticks_msec() / 1000.0

	var i = 0
	while i < input_buffer.size():
		var entry = input_buffer[i] as Dictionary
		var entry_time = entry.get("timestamp", 0.0) as float
		var age_ms = (current_time - entry_time) * 1000.0

		if age_ms > retention_time_ms:
			input_buffer.remove_at(i)
		else:
			i += 1

func _get_lane_id_for_button(button_index: JoyButton) -> int:
	"""Get rhythm lane ID for a button, -1 if not a rhythm lane"""
	for lane in rhythm_lanes:
		var lane_button = _button_string_to_enum(lane.get("button", ""))
		if lane_button == button_index:
			return lane.get("lane_id", -1) as int
	return -1

func _get_action_for_button(button_index: JoyButton) -> String:
	"""Get action name for a button, empty string if not an action button"""
	for action_name in action_mappings.keys():
		var mapping = action_mappings[action_name] as Dictionary
		if mapping.get("type", "") == "button":
			var action_button = _button_string_to_enum(mapping.get("button", ""))
			if action_button == button_index:
				return action_name
	return ""

func _get_stick_name_for_axis(axis: JoyAxis) -> String:
	"""Get stick name for a joypad axis"""
	match axis:
		JOY_AXIS_LEFT_X, JOY_AXIS_LEFT_Y:
			return "left_stick"
		JOY_AXIS_RIGHT_X, JOY_AXIS_RIGHT_Y:
			return "right_stick"
		_:
			return ""

func _button_string_to_enum(button_str: String) -> JoyButton:
	"""Convert button string from config to JoyButton enum"""
	match button_str:
		"joy_button_0": return JOY_BUTTON_A
		"joy_button_1": return JOY_BUTTON_B
		"joy_button_2": return JOY_BUTTON_X
		"joy_button_3": return JOY_BUTTON_Y
		"joy_button_4": return JOY_BUTTON_LB
		"joy_button_5": return JOY_BUTTON_RB
		"joy_button_6": return JOY_BUTTON_BACK
		"joy_button_7": return JOY_BUTTON_START
		"joy_button_8": return JOY_BUTTON_LEFT_STICK
		"joy_button_9": return JOY_BUTTON_RIGHT_STICK
		_: return JOY_BUTTON_INVALID

func _apply_circular_deadzone(input: Vector2, deadzone: float) -> Vector2:
	"""Apply circular deadzone filtering to analog input"""
	var magnitude = input.length()

	if magnitude < deadzone:
		return Vector2.ZERO

	# Scale the magnitude from [deadzone, 1.0] to [0.0, 1.0]
	var scaled_magnitude = (magnitude - deadzone) / (1.0 - deadzone)
	scaled_magnitude = clamp(scaled_magnitude, 0.0, 1.0)

	# Return scaled and normalized vector
	if magnitude > 0:
		return input.normalized() * scaled_magnitude
	return Vector2.ZERO

func _get_deadzone_for_stick(stick_name: String) -> float:
	"""Get deadzone value for a stick"""
	return deadzones.get(stick_name, 0.2) as float

## Public API Methods

func get_buffer() -> Array[Dictionary]:
	"""Return the current input buffer (last 10 inputs)"""
	return input_buffer.duplicate(true)

func clear_buffer() -> void:
	"""Clear the input buffer"""
	input_buffer.clear()

func is_action_pressed(action: String) -> bool:
	"""Check if an action is currently pressed"""
	return action in pressed_buttons

func get_stick_input(stick: String) -> Vector2:
	"""Get analog stick position with deadzone applied"""
	var deadzone = _get_deadzone_for_stick(stick)
	var raw_input = Vector2.ZERO

	match stick:
		"left_stick":
			raw_input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
			# Get actual joypad values
			for joy_id in Input.get_connected_joypads():
				var left_x = Input.get_joy_axis(joy_id, JOY_AXIS_LEFT_X)
				var left_y = Input.get_joy_axis(joy_id, JOY_AXIS_LEFT_Y)
				raw_input = Vector2(left_x, left_y)
				break

		"right_stick":
			for joy_id in Input.get_connected_joypads():
				var right_x = Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_X)
				var right_y = Input.get_joy_axis(joy_id, JOY_AXIS_RIGHT_Y)
				raw_input = Vector2(right_x, right_y)
				break

	return _apply_circular_deadzone(raw_input, deadzone)

func remap_action(action: String, new_button: String) -> void:
	"""Remap an action to a different button at runtime"""
	if action in action_mappings:
		var mapping = action_mappings[action] as Dictionary
		mapping["button"] = new_button
		print("InputManager: Remapped action '%s' to button '%s'" % [action, new_button])
	else:
		push_warning("InputManager: Unknown action '%s'" % action)

func get_controller_count() -> int:
	"""Get number of connected controllers"""
	return Input.get_connected_joypads().size()

func get_lane_config(lane_id: int) -> Dictionary:
	"""Get configuration for a specific rhythm lane"""
	for lane in rhythm_lanes:
		if lane.get("lane_id", -1) == lane_id:
			return lane
	return {}
