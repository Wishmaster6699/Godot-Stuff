# Godot 4.5 | GDScript 4.5
# System: S03 - Player Controller
# Created: 2025-11-18
# Dependencies: S02 (InputManager)
# Purpose: CharacterBody2D-based player character with smooth movement, state machine, and interaction system

extends CharacterBody2D

class_name PlayerController

## Signals for state changes and interactions

## Emitted when movement state changes
signal movement_state_changed(old_state: String, new_state: String)

## Emitted when an interactable object enters interaction range
signal interaction_detected(object: Node)

## Emitted when an interactable object leaves interaction range
signal interaction_lost(object: Node)

## Emitted when player presses interact button while near an object
signal player_interacted(object: Node)

## Emitted when facing direction changes
signal facing_direction_changed(direction: Vector2)

# Player States
enum State {
	IDLE,
	WALKING,
	RUNNING
}

# Configuration
var config: Dictionary = {}
var movement_config: Dictionary = {}
var interaction_config: Dictionary = {}
var animation_config: Dictionary = {}

# State
var current_state: State = State.IDLE
var previous_state: State = State.IDLE

# Movement
var walk_speed: float = 200.0
var run_speed: float = 400.0
var acceleration: float = 800.0
var friction: float = 1000.0

# Interaction
var interaction_radius: float = 64.0
var nearby_interactables: Array[Node] = []
var nearest_interactable: Node = null

# Facing direction
var facing_direction: Vector2 = Vector2.DOWN
var last_move_direction: Vector2 = Vector2.ZERO

# Animation
@onready var sprite: AnimatedSprite2D = $Sprite
@onready var interaction_area: Area2D = $InteractionArea

const CONFIG_PATH: String = "res://data/player_config.json"

func _ready() -> void:
	print("PlayerController: Initializing...")
	_load_config()
	_setup_interaction_area()
	_change_state(State.IDLE)
	print("PlayerController: Ready")

func _load_config() -> void:
	"""Load configuration from player_config.json"""
	var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		push_error("PlayerController: Failed to load config from %s" % CONFIG_PATH)
		_use_default_config()
		return

	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		push_error("PlayerController: JSON parse error: %s" % json.get_error_message())
		_use_default_config()
		return

	var data = json.data as Dictionary
	if data.is_empty() or not data.has("player_config"):
		push_error("PlayerController: Invalid config structure")
		_use_default_config()
		return

	config = data["player_config"] as Dictionary

	# Load movement config
	if config.has("movement"):
		movement_config = config["movement"] as Dictionary
		walk_speed = movement_config.get("walk_speed", 200.0) as float
		run_speed = movement_config.get("run_speed", 400.0) as float
		acceleration = movement_config.get("acceleration", 800.0) as float
		friction = movement_config.get("friction", 1000.0) as float

	# Load interaction config
	if config.has("interaction"):
		interaction_config = config["interaction"] as Dictionary
		interaction_radius = interaction_config.get("detection_radius", 64.0) as float

	# Load animation config
	if config.has("animations"):
		animation_config = config["animations"] as Dictionary

	print("PlayerController: Config loaded successfully")
	print("  - Walk speed: %.1f px/s" % walk_speed)
	print("  - Run speed: %.1f px/s" % run_speed)
	print("  - Interaction radius: %.1f px" % interaction_radius)

func _use_default_config() -> void:
	"""Use default configuration if JSON load fails"""
	walk_speed = 200.0
	run_speed = 400.0
	acceleration = 800.0
	friction = 1000.0
	interaction_radius = 64.0
	print("PlayerController: Using default configuration")

func _setup_interaction_area() -> void:
	"""Setup the interaction area for detecting nearby objects"""
	if interaction_area == null:
		push_warning("PlayerController: InteractionArea node not found - interaction system disabled")
		return

	# Connect signals
	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)
	interaction_area.body_entered.connect(_on_interaction_body_entered)
	interaction_area.body_exited.connect(_on_interaction_body_exited)

	print("PlayerController: Interaction area configured (radius: %.1f px)" % interaction_radius)

func _physics_process(delta: float) -> void:
	"""Main physics update - movement and state machine"""
	_update_movement(delta)
	_update_state()
	_update_facing_direction()
	_update_animation()
	_find_nearest_interactable()

func _update_movement(delta: float) -> void:
	"""Update player movement based on input"""
	# Get movement input from InputManager
	var input_direction = Vector2.ZERO

	# Access InputManager autoload (registered as InputManager in project.godot)
	if has_node("/root/InputManager"):
		var input_manager = get_node("/root/InputManager")
		input_direction = input_manager.get_stick_input("left_stick")
	else:
		# Fallback to keyboard input if InputManager not available
		input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

	# Determine target speed (could add run detection later)
	var target_speed = walk_speed

	if input_direction.length() > 0.0:
		# Moving - accelerate towards target velocity
		var target_velocity = input_direction.normalized() * target_speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
		last_move_direction = input_direction.normalized()
	else:
		# Not moving - apply friction
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# Move the character
	move_and_slide()

func _update_state() -> void:
	"""Update state machine based on velocity"""
	var speed = velocity.length()
	var new_state = current_state

	# State transitions based on speed
	if speed < 10.0:  # Almost stopped
		new_state = State.IDLE
	elif speed < walk_speed * 0.8:
		new_state = State.WALKING
	else:
		new_state = State.RUNNING

	# Change state if different
	if new_state != current_state:
		_change_state(new_state)

func _change_state(new_state: State) -> void:
	"""Change the current state and emit signal"""
	previous_state = current_state
	current_state = new_state

	var old_state_name = _state_to_string(previous_state)
	var new_state_name = _state_to_string(current_state)

	movement_state_changed.emit(old_state_name, new_state_name)
	print("PlayerController: State changed: %s -> %s" % [old_state_name, new_state_name])

func _state_to_string(state: State) -> String:
	"""Convert state enum to string"""
	match state:
		State.IDLE:
			return "Idle"
		State.WALKING:
			return "Walking"
		State.RUNNING:
			return "Running"
		_:
			return "Unknown"

func _update_facing_direction() -> void:
	"""Update the facing direction based on movement"""
	if last_move_direction.length() > 0.1:
		var new_direction = last_move_direction.normalized()
		if new_direction != facing_direction:
			facing_direction = new_direction
			facing_direction_changed.emit(facing_direction)

func _update_animation() -> void:
	"""Update animation based on current state and facing direction"""
	if sprite == null:
		return

	var animation_name = ""

	# Determine animation based on state
	match current_state:
		State.IDLE:
			animation_name = "idle"
		State.WALKING:
			animation_name = "walk"
		State.RUNNING:
			animation_name = "run"

	# Play animation if it exists and is not already playing
	if sprite.sprite_frames != null and sprite.sprite_frames.has_animation(animation_name):
		if sprite.animation != animation_name:
			sprite.play(animation_name)

	# Flip sprite based on facing direction
	if facing_direction.x < -0.1:
		sprite.flip_h = true
	elif facing_direction.x > 0.1:
		sprite.flip_h = false

func _find_nearest_interactable() -> void:
	"""Find the nearest interactable object"""
	if nearby_interactables.is_empty():
		if nearest_interactable != null:
			nearest_interactable = null
		return

	var closest_distance = INF
	var closest_object: Node = null

	for obj in nearby_interactables:
		if obj == null or not is_instance_valid(obj):
			continue

		var obj_pos = Vector2.ZERO
		if obj is Node2D:
			obj_pos = (obj as Node2D).global_position
		elif obj.has_method("get_global_position"):
			obj_pos = obj.call("get_global_position")

		var distance = global_position.distance_to(obj_pos)
		if distance < closest_distance:
			closest_distance = distance
			closest_object = obj

	if closest_object != nearest_interactable:
		nearest_interactable = closest_object

func _unhandled_input(event: InputEvent) -> void:
	"""Handle input events"""
	# Check for interact button press
	if event.is_action_pressed("ui_accept") or _is_interact_pressed():
		if nearest_interactable != null:
			interact()

func _is_interact_pressed() -> bool:
	"""Check if interact button is pressed via InputManager"""
	if has_node("/root/InputManager"):
		var input_manager = get_node("/root/InputManager")
		return input_manager.is_action_pressed("interact")
	return false

func _on_interaction_area_entered(area: Area2D) -> void:
	"""Called when an Area2D enters the interaction zone"""
	if area == null or area == interaction_area:
		return

	if not area in nearby_interactables:
		nearby_interactables.append(area)
		interaction_detected.emit(area)
		print("PlayerController: Detected interactable: %s" % area.name)

func _on_interaction_area_exited(area: Area2D) -> void:
	"""Called when an Area2D leaves the interaction zone"""
	if area in nearby_interactables:
		nearby_interactables.erase(area)
		interaction_lost.emit(area)
		print("PlayerController: Lost interactable: %s" % area.name)

func _on_interaction_body_entered(body: Node2D) -> void:
	"""Called when a body enters the interaction zone"""
	if body == self or body == null:
		return

	if not body in nearby_interactables:
		nearby_interactables.append(body)
		interaction_detected.emit(body)
		print("PlayerController: Detected interactable body: %s" % body.name)

func _on_interaction_body_exited(body: Node2D) -> void:
	"""Called when a body leaves the interaction zone"""
	if body in nearby_interactables:
		nearby_interactables.erase(body)
		interaction_lost.emit(body)
		print("PlayerController: Lost interactable body: %s" % body.name)

## Public API Methods

func interact() -> void:
	"""Trigger interaction with the nearest interactable object"""
	if nearest_interactable == null:
		return

	player_interacted.emit(nearest_interactable)
	print("PlayerController: Interacting with %s" % nearest_interactable.name)

	# Call interact method on the object if it has one
	if nearest_interactable.has_method("interact"):
		nearest_interactable.call("interact", self)

func set_velocity_external(new_velocity: Vector2) -> void:
	"""Manually set player velocity (for cutscenes, knockback, etc.)"""
	velocity = new_velocity

func change_state_external(new_state_name: String) -> void:
	"""Force state change (for cutscenes, etc.)"""
	match new_state_name.to_lower():
		"idle":
			_change_state(State.IDLE)
		"walking", "walk":
			_change_state(State.WALKING)
		"running", "run":
			_change_state(State.RUNNING)
		_:
			push_warning("PlayerController: Unknown state '%s'" % new_state_name)

func get_current_state() -> String:
	"""Get current state as string"""
	return _state_to_string(current_state)

func get_facing_direction() -> Vector2:
	"""Get normalized facing direction"""
	return facing_direction

func get_nearest_interactable() -> Node:
	"""Get the nearest interactable object"""
	return nearest_interactable

func get_all_nearby_interactables() -> Array[Node]:
	"""Get all objects in interaction range"""
	return nearby_interactables.duplicate()

func is_moving() -> bool:
	"""Check if player is moving"""
	return velocity.length() > 10.0

func get_speed() -> float:
	"""Get current movement speed"""
	return velocity.length()
