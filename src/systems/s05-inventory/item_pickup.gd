# Godot 4.5 | GDScript 4.5
# System: S05 - Inventory System
# Created: 2025-11-18
# Dependencies: S03 (PlayerController), GLoot plugin
# Purpose: World item pickup that adds items to player inventory on interaction

extends Area2D
class_name ItemPickup

## Signals

## Emitted when item is picked up successfully
signal item_picked_up(item_id: String, player: PlayerController)

## Emitted when pickup fails (inventory full)
signal pickup_failed(item_id: String, reason: String)

# Item configuration
@export var item_prototype_id: String = "health_potion"
@export var quantity: int = 1
@export var auto_pickup: bool = false  # If true, picks up on collision (no interact needed)
@export var respawn: bool = false
@export var respawn_time: float = 30.0

# Visual feedback
@export var hover_scale: float = 1.2
@export var bob_height: float = 5.0
@export var bob_speed: float = 2.0
@export var spin_speed: float = 90.0  # Degrees per second

# State
var is_player_nearby: bool = false
var can_be_picked_up: bool = true
var original_position: Vector2 = Vector2.ZERO
var time_elapsed: float = 0.0

# References
@onready var sprite: Sprite2D = $Sprite
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var label: Label = $ItemLabel

func _ready() -> void:
	# Store original position for bobbing animation
	original_position = position

	# Setup collision layer/mask for Player interaction
	collision_layer = 4  # Layer 3 (2^2 = 4) for interactables
	collision_mask = 0  # Don't detect anything, Player will detect us

	# Connect signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

	# Setup label
	if label != null:
		label.text = item_prototype_id.replace("_", " ").capitalize()
		label.visible = false  # Hidden until player nearby

	print("ItemPickup: Ready - ID: %s, Qty: %d, Auto: %s" % [item_prototype_id, quantity, auto_pickup])

func _process(delta: float) -> void:
	if not can_be_picked_up:
		return

	time_elapsed += delta

	# Bobbing animation
	if bob_height > 0.0:
		var bob_offset = sin(time_elapsed * bob_speed) * bob_height
		position.y = original_position.y + bob_offset

	# Spinning animation
	if spin_speed > 0.0 and sprite != null:
		sprite.rotation_degrees += spin_speed * delta

	# Scale animation when player nearby
	if sprite != null:
		var target_scale = hover_scale if is_player_nearby else 1.0
		sprite.scale = sprite.scale.lerp(Vector2.ONE * target_scale, delta * 5.0)

func _on_body_entered(body: Node2D) -> void:
	"""Called when body enters pickup area"""
	if not can_be_picked_up:
		return

	# Check if it's the player
	if body is PlayerController:
		is_player_nearby = true

		# Show label
		if label != null:
			label.visible = true

		# Auto-pickup if enabled
		if auto_pickup:
			_attempt_pickup(body as PlayerController)
		else:
			print("ItemPickup: Player nearby - press interact to pick up %s" % item_prototype_id)

func _on_body_exited(body: Node2D) -> void:
	"""Called when body exits pickup area"""
	if body is PlayerController:
		is_player_nearby = false

		# Hide label
		if label != null:
			label.visible = false

		print("ItemPickup: Player left pickup area")

func _on_area_entered(area: Area2D) -> void:
	"""Called when area enters pickup area (e.g., Player's InteractionArea)"""
	if not can_be_picked_up:
		return

	# The Player's InteractionArea should detect us, not the other way around
	# This is here for compatibility with different interaction systems
	pass

func _on_area_exited(area: Area2D) -> void:
	"""Called when area exits pickup area"""
	pass

## Public API (called by Player interaction system)

func interact(player: PlayerController) -> void:
	"""
	Called by PlayerController when player presses interact button
	This is the standard S03 interaction pattern
	"""
	_attempt_pickup(player)

## Private Methods

func _attempt_pickup(player: PlayerController) -> void:
	"""Try to add item to player's inventory"""
	if not can_be_picked_up:
		print("ItemPickup: Cannot pick up %s (already picked up or disabled)" % item_prototype_id)
		return

	if player == null:
		push_error("ItemPickup: Player is null")
		return

	# Get player's InventoryManager
	var inventory_manager = _find_inventory_manager(player)
	if inventory_manager == null:
		push_error("ItemPickup: Player has no InventoryManager")
		pickup_failed.emit(item_prototype_id, "No inventory manager")
		return

	# Try to add item to inventory
	var success = false
	for i in range(quantity):
		if inventory_manager.has_method("add_item_by_id"):
			var result = inventory_manager.call("add_item_by_id", item_prototype_id)
			if result:
				success = true
			else:
				# Inventory full
				print("ItemPickup: Inventory full, cannot add %s" % item_prototype_id)
				pickup_failed.emit(item_prototype_id, "Inventory full")
				break

	if success:
		# Successfully picked up
		print("ItemPickup: Player picked up %dx %s" % [quantity, item_prototype_id])
		item_picked_up.emit(item_prototype_id, player)

		# Remove from world or start respawn timer
		if respawn:
			_start_respawn_timer()
		else:
			_remove_pickup()

func _find_inventory_manager(player: PlayerController) -> Node:
	"""Find InventoryManager in player node"""
	# Check if player has InventoryManager as child
	for child in player.get_children():
		if child is InventoryManager:
			return child
		if child.has_method("add_item_by_id"):  # Duck typing
			return child

	# Check if player has InventoryManager in specific path
	if player.has_node("InventoryManager"):
		return player.get_node("InventoryManager")

	return null

func _remove_pickup() -> void:
	"""Remove pickup from world"""
	can_be_picked_up = false

	# Fade out animation (optional, MCP agent can enhance this)
	if sprite != null:
		var tween = create_tween()
		tween.tween_property(sprite, "modulate:a", 0.0, 0.3)
		tween.tween_callback(queue_free)
	else:
		queue_free()

func _start_respawn_timer() -> void:
	"""Start respawn timer"""
	can_be_picked_up = false

	# Hide visually
	if sprite != null:
		sprite.visible = false
	if label != null:
		label.visible = false
	if collision_shape != null:
		collision_shape.disabled = true

	# Start timer
	await get_tree().create_timer(respawn_time).timeout

	# Respawn
	_respawn_pickup()

func _respawn_pickup() -> void:
	"""Respawn the pickup"""
	can_be_picked_up = true

	# Show visually
	if sprite != null:
		sprite.visible = true
		sprite.modulate.a = 1.0
	if collision_shape != null:
		collision_shape.disabled = false

	print("ItemPickup: Respawned %s" % item_prototype_id)

## Configuration Methods (for dynamic item spawning)

func set_item(item_id: String, item_quantity: int = 1) -> void:
	"""Dynamically set the item this pickup represents"""
	item_prototype_id = item_id
	quantity = item_quantity

	# Update label
	if label != null:
		label.text = item_id.replace("_", " ").capitalize()

	print("ItemPickup: Item set to %dx %s" % [quantity, item_id])

func set_respawn(enable: bool, time: float = 30.0) -> void:
	"""Configure respawn behavior"""
	respawn = enable
	respawn_time = time

func enable_auto_pickup(enable: bool) -> void:
	"""Enable/disable auto-pickup"""
	auto_pickup = enable

## Debug Methods

func get_item_info() -> Dictionary:
	"""Get information about this pickup"""
	return {
		"item_id": item_prototype_id,
		"quantity": quantity,
		"auto_pickup": auto_pickup,
		"respawn": respawn,
		"respawn_time": respawn_time,
		"can_be_picked_up": can_be_picked_up,
		"player_nearby": is_player_nearby
	}
