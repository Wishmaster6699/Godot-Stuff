# Godot 4.5 | GDScript 4.5
# System: S15 - Vehicle System
# Created: 2025-11-18
# Dependencies: S03 (PlayerController)
# Purpose: Base class for all mountable vehicles with physics and interaction

extends CharacterBody2D

class_name VehicleBase

## Signals for vehicle state and interaction

## Emitted when a player mounts this vehicle
signal player_mounted(player: Node)

## Emitted when a player dismounts this vehicle
signal player_dismounted(player: Node)

## Emitted when vehicle ability is used
signal ability_used(ability_name: String)

## Emitted when vehicle takes damage (for mech suit)
signal vehicle_damaged(damage: int, remaining_health: int)

# Vehicle Type
enum VehicleType {
	MECH_SUIT,
	CAR,
	AIRSHIP,
	BOAT
}

# Configuration
var config: Dictionary = {}
var vehicle_type: VehicleType = VehicleType.CAR

# Mount state
var mounted: bool = false
var mounted_player: Node = null
var player_original_sprite_visible: bool = true

# Physics properties
var max_speed: float = 300.0
var acceleration: float = 500.0
var friction: float = 800.0
var turn_speed: float = 2.0

# Vehicle-specific properties
var defense_bonus: float = 0.0
var can_attack: bool = false
var current_health: int = 100
var max_health: int = 100

# Movement
var input_direction: Vector2 = Vector2.ZERO
var facing_direction: float = 0.0  # Angle in radians

# Ability cooldowns
var ability_cooldown: float = 0.0
var ability_cooldown_duration: float = 2.0

# Child nodes
@onready var sprite: Sprite2D = $Sprite
@onready var mount_area: Area2D = $MountArea
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

const CONFIG_PATH: String = "res://data/vehicles_config.json"

func _ready() -> void:
	print("VehicleBase: Initializing %s..." % name)
	_load_config()
	_setup_mount_area()
	print("VehicleBase: Ready")

func _load_config() -> void:
	"""Load vehicle configuration from JSON"""
	var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
	if file == null:
		push_warning("VehicleBase: Failed to load config from %s, using defaults" % CONFIG_PATH)
		return

	var json_string = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_string)

	if error != OK:
		push_error("VehicleBase: JSON parse error: %s" % json.get_error_message())
		return

	var data = json.data as Dictionary
	if not data.has("vehicles"):
		push_warning("VehicleBase: No 'vehicles' key in config")
		return

	config = data["vehicles"] as Dictionary
	print("VehicleBase: Config loaded successfully")

func _setup_mount_area() -> void:
	"""Setup the interaction area for mounting"""
	if mount_area == null:
		push_warning("VehicleBase: MountArea node not found - mounting disabled")
		return

	# Connect signals for mounting
	mount_area.body_entered.connect(_on_mount_area_entered)
	mount_area.body_exited.connect(_on_mount_area_exited)

	print("VehicleBase: Mount area configured")

func _physics_process(delta: float) -> void:
	"""Main physics update - only active when mounted"""
	if mounted:
		_update_input()
		_update_vehicle_physics(delta)
		_update_rotation(delta)
	else:
		# Apply friction when not mounted
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

	# Update ability cooldown
	if ability_cooldown > 0.0:
		ability_cooldown -= delta

	# Always move with current velocity
	move_and_slide()

func _update_input() -> void:
	"""Get input from InputManager or fallback to keyboard"""
	input_direction = Vector2.ZERO

	# Try to get input from InputManager
	if has_node("/root/InputManager"):
		var input_manager = get_node("/root/InputManager")
		input_direction = input_manager.get_stick_input("left_stick")
	else:
		# Fallback to keyboard
		input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")

func _update_vehicle_physics(delta: float) -> void:
	"""Update vehicle physics - override in child classes for unique behavior"""
	if input_direction.length() > 0.0:
		# Accelerate towards target velocity
		var target_velocity = input_direction.normalized() * max_speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		# Apply friction
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func _update_rotation(delta: float) -> void:
	"""Update vehicle rotation based on movement direction"""
	if velocity.length() > 10.0:
		# Rotate towards movement direction
		var target_rotation = velocity.angle()
		rotation = lerp_angle(rotation, target_rotation, turn_speed * delta)

func _unhandled_input(event: InputEvent) -> void:
	"""Handle input for abilities"""
	if not mounted:
		return

	# Ability button (mapped to attack/special)
	if event.is_action_pressed("ui_accept"):
		use_ability()

	# Dismount button
	if event.is_action_pressed("ui_cancel"):
		request_dismount()

## Mount/Dismount System

func _on_mount_area_entered(body: Node2D) -> void:
	"""Called when something enters the mount area"""
	# Check if it's a player
	if body == null or mounted:
		return

	# Only allow mounting if not already mounted
	if body.has_method("interact"):
		print("VehicleBase: Player entered mount area: %s" % body.name)

func _on_mount_area_exited(body: Node2D) -> void:
	"""Called when something exits the mount area"""
	pass

func interact(player: Node) -> void:
	"""Called by player when they press interact near this vehicle"""
	if not mounted:
		mount(player)
	else:
		dismount()

func mount(player: Node) -> void:
	"""Mount the player to this vehicle"""
	if mounted:
		push_warning("VehicleBase: Already mounted")
		return

	if player == null:
		push_error("VehicleBase: Cannot mount null player")
		return

	mounted = true
	mounted_player = player

	# Hide player sprite
	if player.has_node("Sprite"):
		var player_sprite = player.get_node("Sprite")
		player_original_sprite_visible = player_sprite.visible
		player_sprite.visible = false

	# Disable player movement
	player.set_physics_process(false)

	# Move player to vehicle position
	if player is Node2D:
		player.global_position = global_position

	# Apply vehicle-specific mount effects
	_on_mount()

	player_mounted.emit(player)
	print("VehicleBase: Player mounted: %s" % player.name)

func dismount() -> void:
	"""Dismount the player from this vehicle"""
	if not mounted or mounted_player == null:
		push_warning("VehicleBase: No player to dismount")
		return

	var player = mounted_player

	# Show player sprite
	if player.has_node("Sprite"):
		var player_sprite = player.get_node("Sprite")
		player_sprite.visible = player_original_sprite_visible

	# Re-enable player movement
	player.set_physics_process(true)

	# Calculate safe dismount position (to the side)
	var dismount_offset = Vector2(64, 0).rotated(rotation)
	if player is Node2D:
		player.global_position = global_position + dismount_offset

	# Apply vehicle-specific dismount effects
	_on_dismount()

	player_dismounted.emit(player)
	print("VehicleBase: Player dismounted: %s" % player.name)

	mounted = false
	mounted_player = null

	# Stop movement
	velocity = Vector2.ZERO

func request_dismount() -> void:
	"""Request to dismount (can be overridden for conditions like landing pads)"""
	dismount()

## Abilities

func use_ability() -> void:
	"""Use vehicle-specific ability - override in child classes"""
	if ability_cooldown > 0.0:
		print("VehicleBase: Ability on cooldown (%.1fs remaining)" % ability_cooldown)
		return

	_execute_ability()
	ability_cooldown = ability_cooldown_duration

func _execute_ability() -> void:
	"""Execute the ability - override in child classes"""
	print("VehicleBase: Base ability (no effect)")
	ability_used.emit("base_ability")

## Vehicle-Specific Hooks (override in child classes)

func _on_mount() -> void:
	"""Called when player mounts - override for vehicle-specific behavior"""
	pass

func _on_dismount() -> void:
	"""Called when player dismounts - override for vehicle-specific behavior"""
	pass

## Damage System (for vehicles that can take damage)

func take_damage(damage: int) -> void:
	"""Apply damage to vehicle"""
	current_health -= damage
	current_health = max(0, current_health)

	vehicle_damaged.emit(damage, current_health)
	print("VehicleBase: Took %d damage, health: %d/%d" % [damage, current_health, max_health])

	if current_health <= 0:
		_on_vehicle_destroyed()

func _on_vehicle_destroyed() -> void:
	"""Called when vehicle is destroyed"""
	print("VehicleBase: Vehicle destroyed!")
	if mounted:
		dismount()
	# Could add explosion effect, respawn logic, etc.

## Public API

func is_mounted() -> bool:
	"""Check if vehicle is currently mounted"""
	return mounted

func get_mounted_player() -> Node:
	"""Get the currently mounted player"""
	return mounted_player

func get_defense_bonus() -> float:
	"""Get vehicle defense bonus"""
	return defense_bonus

func can_player_attack() -> bool:
	"""Check if player can attack while in this vehicle"""
	return can_attack

func get_vehicle_type() -> VehicleType:
	"""Get the type of this vehicle"""
	return vehicle_type

func get_speed() -> float:
	"""Get current speed"""
	return velocity.length()

func is_ability_ready() -> bool:
	"""Check if ability is off cooldown"""
	return ability_cooldown <= 0.0
