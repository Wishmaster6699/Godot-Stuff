# Godot 4.5 | GDScript 4.5
# System: S02 - Controller Input System
# Purpose: Test script for input system - displays controller input visually

extends Node2D

class_name TestInputScene

# References to UI nodes (will be set by scene)
var lane_labels: Array[Label] = []
var stick_label: Label
var buffer_display: VBoxContainer
var deadzone_visual: ColorRect

# State tracking
var stick_position: Vector2 = Vector2.ZERO
var button_states: Dictionary = {}

func _ready() -> void:
	print("TestInputScene: Initializing...")

	# Find lane labels
	lane_labels.clear()
	for i in range(4):
		var label = find_child("Lane%dLabel" % i) as Label
		if label:
			lane_labels.append(label)
			label.text = "Lane %d: Not Pressed" % i

	# Find stick label
	stick_label = find_child("StickLabel") as Label
	if stick_label:
		stick_label.text = "Left Stick: (0.00, 0.00)"

	# Find buffer display
	buffer_display = find_child("BufferDisplay") as VBoxContainer

	# Find deadzone visual
	deadzone_visual = find_child("DeadzoneVisual") as ColorRect
	if deadzone_visual:
		deadzone_visual.custom_minimum_size = Vector2(200, 200)

	# Connect to InputManager signals
	if InputManager:
		InputManager.lane_pressed.connect(_on_lane_pressed)
		InputManager.lane_released.connect(_on_lane_released)
		InputManager.button_pressed.connect(_on_button_pressed)
		InputManager.button_held.connect(_on_button_held)
		InputManager.button_released.connect(_on_button_released)
		InputManager.stick_moved.connect(_on_stick_moved)
		InputManager.controller_connected.connect(_on_controller_connected)
		InputManager.controller_disconnected.connect(_on_controller_disconnected)
		print("TestInputScene: Connected to InputManager signals")
	else:
		push_error("TestInputScene: InputManager autoload not found!")

func _process(_delta: float) -> void:
	"""Update display each frame"""
	_update_stick_display()
	_update_buffer_display()
	_update_deadzone_visual()

func _on_lane_pressed(lane_id: int, _timestamp: float) -> void:
	"""Handle lane press"""
	if lane_id >= 0 and lane_id < lane_labels.size():
		var lane_config = InputManager.get_lane_config(lane_id)
		var label = lane_config.get("label", "?")
		lane_labels[lane_id].text = "Lane %d (%s): PRESSED" % [lane_id, label]
		lane_labels[lane_id].add_theme_color_override("font_color", Color.GREEN)

func _on_lane_released(lane_id: int, _timestamp: float) -> void:
	"""Handle lane release"""
	if lane_id >= 0 and lane_id < lane_labels.size():
		var lane_config = InputManager.get_lane_config(lane_id)
		var label = lane_config.get("label", "?")
		lane_labels[lane_id].text = "Lane %d (%s): Released" % [lane_id, label]
		lane_labels[lane_id].add_theme_color_override("font_color", Color.WHITE)

func _on_button_pressed(action: String) -> void:
	"""Handle button press"""
	button_states[action] = {"pressed": true, "time": Time.get_ticks_msec()}
	print("Button pressed: %s" % action)

func _on_button_held(action: String, hold_duration: float) -> void:
	"""Handle button hold"""
	print("Button held: %s (%.2fs)" % [action, hold_duration])

func _on_button_released(action: String) -> void:
	"""Handle button release"""
	if action in button_states:
		button_states.erase(action)
	print("Button released: %s" % action)

func _on_stick_moved(stick: String, direction: Vector2, magnitude: float) -> void:
	"""Handle stick movement"""
	stick_position = direction
	if stick == "left_stick":
		pass  # Stick moved is handled in _process

func _on_controller_connected(device_id: int) -> void:
	"""Handle controller connection"""
	print("TestInputScene: Controller connected (device %d)" % device_id)

func _on_controller_disconnected(device_id: int) -> void:
	"""Handle controller disconnection"""
	print("TestInputScene: Controller disconnected (device %d)" % device_id)

func _update_stick_display() -> void:
	"""Update stick position display"""
	if stick_label:
		var stick_pos = InputManager.get_stick_input("left_stick")
		stick_label.text = "Left Stick: (%.2f, %.2f)" % [stick_pos.x, stick_pos.y]

func _update_buffer_display() -> void:
	"""Update input buffer display"""
	if not buffer_display:
		return

	# Clear existing entries (keep title)
	var child_count = buffer_display.get_child_count()
	for i in range(1, child_count):  # Skip first child (title)
		buffer_display.get_child(i).queue_free()

	# Add current buffer entries
	var buffer = InputManager.get_buffer()
	for i in range(min(buffer.size(), 10)):
		var entry = buffer[i] as Dictionary
		var action = entry.get("action", "unknown")
		var label = Label.new()
		label.text = "[%d] %s" % [i, action]
		buffer_display.add_child(label)

func _update_deadzone_visual() -> void:
	"""Update deadzone circle visualization"""
	if not deadzone_visual:
		return

	deadzone_visual.queue_redraw()

func _draw_deadzone_circle() -> void:
	"""Draw deadzone visualization circle"""
	if not deadzone_visual:
		return

	# This would be implemented in the scene's _draw override
	# Draw a circle for the deadzone threshold
	# Draw a dot for the current stick position
	pass
