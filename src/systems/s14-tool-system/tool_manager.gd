# Godot 4.5 | GDScript 4.5
# System: S14 - Tool System
# Created: 2025-11-18
# Dependencies: S03 (Player Controller)
# Purpose: Tool switching system for player abilities - Grapple Hook, Laser, Roller Blades, Surfboard

extends Node2D

class_name ToolManager

## Signals for tool events

## Emitted when the active tool changes
signal tool_switched(tool_id: String, previous_tool_id: String)

## Emitted when a tool is used/activated
signal tool_used(tool_id: String)

## Emitted when a tool goes on cooldown
signal tool_cooldown_started(tool_id: String, cooldown_duration: float)

## Emitted when a tool cooldown completes
signal tool_cooldown_finished(tool_id: String)

## Tool IDs
enum ToolID {
	NONE,
	GRAPPLE_HOOK,
	LASER,
	ROLLER_BLADES,
	SURFBOARD
}

# Configuration
var config: Dictionary = {}
var tools_config: Dictionary = {}

# Current tool state
var current_tool: ToolID = ToolID.NONE
var previous_tool: ToolID = ToolID.NONE
var available_tools: Array[ToolID] = []

# Tool instances
var grapple_hook: Node2D = null
var laser: Node2D = null
var roller_blades: Node2D = null
var surfboard: Node2D = null

# Cooldown tracking
var tool_cooldowns: Dictionary = {
	"grapple_hook": 0.0,
	"laser": 0.0,
	"roller_blades": 0.0,
	"surfboard": 0.0
}

# References
var player: PlayerController = null

const CONFIG_PATH: String = "res://data/tools_config.json"
const GRAPPLE_HOOK_SCENE = preload("res://src/systems/s14-tool-system/grapple_hook.gd")
const LASER_SCENE = preload("res://src/systems/s14-tool-system/laser.gd")
const ROLLER_BLADES_SCENE = preload("res://src/systems/s14-tool-system/roller_blades.gd")
const SURFBOARD_SCENE = preload("res://src/systems/s14-tool-system/surfboard.gd")

func _ready() -> void:
	print("ToolManager: Initializing...")
	_load_config()
	_setup_tools()
	_initialize_available_tools()
	print("ToolManager: Ready")

func _load_config() -> void:
	"""Load tool configuration from tools_config.json"""
	var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		push_error("ToolManager: Failed to load config from %s" % CONFIG_PATH)
		_use_default_config()
		return

	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		push_error("ToolManager: JSON parse error: %s" % json.get_error_message())
		_use_default_config()
		return

	var data = json.data as Dictionary
	if data.is_empty() or not data.has("tools"):
		push_error("ToolManager: Invalid config structure")
		_use_default_config()
		return

	tools_config = data["tools"] as Dictionary
	print("ToolManager: Config loaded successfully")
	print("  - Tools configured: %d" % tools_config.size())

func _use_default_config() -> void:
	"""Use default tool configuration if JSON load fails"""
	tools_config = {
		"grapple_hook": {
			"max_range": 200,
			"swing_force": 500,
			"cooldown_s": 0.5
		},
		"laser": {
			"damage_per_second": 15,
			"max_duration_s": 3.0,
			"overheat_cooldown_s": 2.0
		},
		"roller_blades": {
			"speed_multiplier": 2.0,
			"balance_difficulty": 0.3
		},
		"surfboard": {
			"water_speed": 150,
			"wave_amplitude": 10
		}
	}
	print("ToolManager: Using default configuration")

func _setup_tools() -> void:
	"""Create and setup tool instances"""
	# Get player reference
	player = get_parent() as PlayerController
	if player == null:
		push_error("ToolManager: Must be child of PlayerController")
		return

	# Create tool instances
	grapple_hook = GRAPPLE_HOOK_SCENE.new()
	grapple_hook.name = "GrappleHook"
	add_child(grapple_hook)
	if grapple_hook.has_method("initialize"):
		var grapple_config = tools_config.get("grapple_hook", {})
		grapple_hook.call("initialize", player, grapple_config)

	laser = LASER_SCENE.new()
	laser.name = "Laser"
	add_child(laser)
	if laser.has_method("initialize"):
		var laser_config = tools_config.get("laser", {})
		laser.call("initialize", player, laser_config)

	roller_blades = ROLLER_BLADES_SCENE.new()
	roller_blades.name = "RollerBlades"
	add_child(roller_blades)
	if roller_blades.has_method("initialize"):
		var blades_config = tools_config.get("roller_blades", {})
		roller_blades.call("initialize", player, blades_config)

	surfboard = SURFBOARD_SCENE.new()
	surfboard.name = "Surfboard"
	add_child(surfboard)
	if surfboard.has_method("initialize"):
		var surfboard_config = tools_config.get("surfboard", {})
		surfboard.call("initialize", player, surfboard_config)

	print("ToolManager: All tools initialized")

func _initialize_available_tools() -> void:
	"""Initialize the list of available tools (all tools available by default)"""
	available_tools = [
		ToolID.GRAPPLE_HOOK,
		ToolID.LASER,
		ToolID.ROLLER_BLADES,
		ToolID.SURFBOARD
	]

	# Set first tool as active
	if available_tools.size() > 0:
		switch_tool(available_tools[0])

func _process(delta: float) -> void:
	"""Update cooldown timers"""
	_update_cooldowns(delta)

func _update_cooldowns(delta: float) -> void:
	"""Update all tool cooldowns"""
	for tool_id in tool_cooldowns.keys():
		if tool_cooldowns[tool_id] > 0.0:
			tool_cooldowns[tool_id] -= delta
			if tool_cooldowns[tool_id] <= 0.0:
				tool_cooldowns[tool_id] = 0.0
				tool_cooldown_finished.emit(tool_id)

func _unhandled_input(event: InputEvent) -> void:
	"""Handle tool switching input"""
	# Switch to next tool with shoulder button or d-pad right
	if event.is_action_pressed("tool_next"):
		switch_to_next_tool()
		get_viewport().set_input_as_handled()
	# Switch to previous tool with d-pad left
	elif event.is_action_pressed("tool_previous"):
		switch_to_previous_tool()
		get_viewport().set_input_as_handled()
	# Use current tool with tool use button
	elif event.is_action_pressed("tool_use"):
		use_current_tool()
		get_viewport().set_input_as_handled()

## Public API Methods

func switch_tool(new_tool_id: ToolID) -> void:
	"""Switch to a specific tool"""
	if new_tool_id == current_tool:
		return

	if not new_tool_id in available_tools and new_tool_id != ToolID.NONE:
		push_warning("ToolManager: Tool %s not available" % _tool_id_to_string(new_tool_id))
		return

	# Deactivate previous tool
	if current_tool != ToolID.NONE:
		_deactivate_tool(current_tool)

	# Switch tool
	previous_tool = current_tool
	current_tool = new_tool_id

	# Activate new tool
	if current_tool != ToolID.NONE:
		_activate_tool(current_tool)

	# Emit signal
	var prev_name = _tool_id_to_string(previous_tool)
	var curr_name = _tool_id_to_string(current_tool)
	tool_switched.emit(curr_name, prev_name)
	print("ToolManager: Switched tool: %s -> %s" % [prev_name, curr_name])

func switch_to_next_tool() -> void:
	"""Switch to the next tool in the available tools list"""
	if available_tools.is_empty():
		return

	var current_index = available_tools.find(current_tool)
	if current_index == -1:
		# Current tool not in list, switch to first
		switch_tool(available_tools[0])
		return

	var next_index = (current_index + 1) % available_tools.size()
	switch_tool(available_tools[next_index])

func switch_to_previous_tool() -> void:
	"""Switch to the previous tool in the available tools list"""
	if available_tools.is_empty():
		return

	var current_index = available_tools.find(current_tool)
	if current_index == -1:
		# Current tool not in list, switch to last
		switch_tool(available_tools[available_tools.size() - 1])
		return

	var prev_index = (current_index - 1) % available_tools.size()
	if prev_index < 0:
		prev_index = available_tools.size() - 1
	switch_tool(available_tools[prev_index])

func use_current_tool() -> void:
	"""Use/activate the currently selected tool"""
	if current_tool == ToolID.NONE:
		return

	var tool_name = _tool_id_to_string(current_tool)

	# Check cooldown
	if is_tool_on_cooldown(tool_name):
		print("ToolManager: Tool %s is on cooldown" % tool_name)
		return

	# Use the tool
	var tool_node = _get_tool_node(current_tool)
	if tool_node != null and tool_node.has_method("use"):
		tool_node.call("use")
		tool_used.emit(tool_name)
		print("ToolManager: Used tool: %s" % tool_name)

func is_tool_on_cooldown(tool_name: String) -> bool:
	"""Check if a tool is currently on cooldown"""
	var tool_key = tool_name.to_lower()
	if tool_cooldowns.has(tool_key):
		return tool_cooldowns[tool_key] > 0.0
	return false

func get_tool_cooldown(tool_name: String) -> float:
	"""Get the remaining cooldown time for a tool"""
	var tool_key = tool_name.to_lower()
	if tool_cooldowns.has(tool_key):
		return tool_cooldowns[tool_key]
	return 0.0

func start_tool_cooldown(tool_name: String, duration: float) -> void:
	"""Start a cooldown timer for a tool"""
	var tool_key = tool_name.to_lower()
	tool_cooldowns[tool_key] = duration
	tool_cooldown_started.emit(tool_name, duration)
	print("ToolManager: Tool %s cooldown started (%.1fs)" % [tool_name, duration])

func get_current_tool_name() -> String:
	"""Get the name of the currently active tool"""
	return _tool_id_to_string(current_tool)

func get_available_tools() -> Array[String]:
	"""Get list of available tool names"""
	var tool_names: Array[String] = []
	for tool_id in available_tools:
		tool_names.append(_tool_id_to_string(tool_id))
	return tool_names

## Internal Methods

func _activate_tool(tool_id: ToolID) -> void:
	"""Activate a tool (make it visible/active)"""
	var tool_node = _get_tool_node(tool_id)
	if tool_node != null:
		if tool_node.has_method("activate"):
			tool_node.call("activate")
		tool_node.visible = true

func _deactivate_tool(tool_id: ToolID) -> void:
	"""Deactivate a tool (make it invisible/inactive)"""
	var tool_node = _get_tool_node(tool_id)
	if tool_node != null:
		if tool_node.has_method("deactivate"):
			tool_node.call("deactivate")
		tool_node.visible = false

func _get_tool_node(tool_id: ToolID) -> Node2D:
	"""Get the node for a specific tool"""
	match tool_id:
		ToolID.GRAPPLE_HOOK:
			return grapple_hook
		ToolID.LASER:
			return laser
		ToolID.ROLLER_BLADES:
			return roller_blades
		ToolID.SURFBOARD:
			return surfboard
		_:
			return null

func _tool_id_to_string(tool_id: ToolID) -> String:
	"""Convert tool ID enum to string"""
	match tool_id:
		ToolID.NONE:
			return "None"
		ToolID.GRAPPLE_HOOK:
			return "grapple_hook"
		ToolID.LASER:
			return "laser"
		ToolID.ROLLER_BLADES:
			return "roller_blades"
		ToolID.SURFBOARD:
			return "surfboard"
		_:
			return "Unknown"
