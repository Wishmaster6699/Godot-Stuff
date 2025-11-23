# Godot 4.5 | GDScript 4.5
# System: S15 - Vehicle System - Mech Suit
# Created: 2025-11-18
# Dependencies: VehicleBase
# Purpose: Heavy combat mech with high defense, slow movement, and AoE stomp ability

extends VehicleBase

class_name MechSuit

## Emitted when stomp ability hits enemies
signal stomp_hit(enemies: Array)

# Mech-specific properties
var stomp_damage: int = 50
var stomp_radius: float = 100.0
var stomp_knockback: float = 300.0

# Visual effects
var is_stomping: bool = false
var stomp_animation_duration: float = 0.5
var stomp_timer: float = 0.0

# Damage area for stomp
var stomp_area: Area2D = null

func _ready() -> void:
	super._ready()
	vehicle_type = VehicleType.MECH_SUIT
	_load_mech_config()
	_create_stomp_area()
	print("MechSuit: Initialized")

func _load_mech_config() -> void:
	"""Load mech-specific configuration"""
	if config.has("mech_suit"):
		var mech_config = config["mech_suit"] as Dictionary

		# Physics
		max_speed = mech_config.get("max_speed", 100.0) as float
		acceleration = mech_config.get("acceleration", 300.0) as float
		friction = mech_config.get("friction", 600.0) as float
		turn_speed = mech_config.get("turn_speed", 1.5) as float

		# Combat
		defense_bonus = mech_config.get("defense_bonus", 50.0) as float
		can_attack = mech_config.get("can_attack", true) as bool
		max_health = mech_config.get("max_health", 200) as int
		current_health = max_health

		# Ability
		stomp_damage = mech_config.get("stomp_damage", 50) as int
		stomp_radius = mech_config.get("stomp_radius", 100.0) as float
		stomp_knockback = mech_config.get("stomp_knockback", 300.0) as float
		ability_cooldown_duration = mech_config.get("stomp_cooldown", 3.0) as float

		print("MechSuit: Config loaded - Speed: %.1f, Defense: %.1f" % [max_speed, defense_bonus])
	else:
		# Use defaults
		max_speed = 100.0
		acceleration = 300.0
		friction = 600.0
		defense_bonus = 50.0
		can_attack = true
		max_health = 200
		current_health = max_health
		print("MechSuit: Using default configuration")

func _create_stomp_area() -> void:
	"""Create the damage area for stomp ability"""
	stomp_area = Area2D.new()
	stomp_area.name = "StompArea"
	stomp_area.monitoring = false  # Only enable during stomp
	stomp_area.monitorable = false

	var shape = CircleShape2D.new()
	shape.radius = stomp_radius

	var collision = CollisionShape2D.new()
	collision.shape = shape
	collision.name = "StompCollision"

	stomp_area.add_child(collision)
	add_child(stomp_area)

	print("MechSuit: Stomp area created (radius: %.1f)" % stomp_radius)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

	# Update stomp animation
	if is_stomping:
		stomp_timer += delta
		if stomp_timer >= stomp_animation_duration:
			is_stomping = false
			stomp_timer = 0.0

func _update_vehicle_physics(delta: float) -> void:
	"""Mech has heavy, slow movement with momentum"""
	if input_direction.length() > 0.0:
		# Slow acceleration (heavy mech)
		var target_velocity = input_direction.normalized() * max_speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		# Slow deceleration (momentum)
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)

func _execute_ability() -> void:
	"""Execute stomp ability - AoE damage"""
	if not mounted:
		return

	print("MechSuit: STOMP!")
	is_stomping = true
	stomp_timer = 0.0

	# Emit signal
	ability_used.emit("stomp")

	# Enable area temporarily to detect enemies
	stomp_area.monitoring = true

	# Get all bodies in stomp radius
	await get_tree().create_timer(0.1).timeout  # Brief delay for area to register

	var enemies: Array = []
	var bodies = stomp_area.get_overlapping_bodies()

	for body in bodies:
		if body == self or body == mounted_player:
			continue

		# Check if body is an enemy (has health/damage method)
		if body.has_method("take_damage"):
			enemies.append(body)

			# Apply damage
			body.call("take_damage", stomp_damage)

			# Apply knockback
			if body is CharacterBody2D:
				var direction = (body.global_position - global_position).normalized()
				var knockback_velocity = direction * stomp_knockback
				if body.has_method("apply_knockback"):
					body.call("apply_knockback", knockback_velocity)
				elif "velocity" in body:
					body.velocity += knockback_velocity

			print("MechSuit: Stomped enemy: %s (damage: %d)" % [body.name, stomp_damage])

	# Disable area
	stomp_area.monitoring = false

	# Emit hit signal
	stomp_hit.emit(enemies)

	print("MechSuit: Stomp hit %d enemies" % enemies.size())

func _on_mount() -> void:
	"""Apply mech-specific mount effects"""
	print("MechSuit: Player mounted - Defense bonus active: +%.1f" % defense_bonus)

	# Could apply defense buff to player here
	if mounted_player != null and mounted_player.has_method("add_defense_modifier"):
		mounted_player.call("add_defense_modifier", "mech_suit", defense_bonus)

func _on_dismount() -> void:
	"""Remove mech-specific dismount effects"""
	print("MechSuit: Player dismounted - Defense bonus removed")

	# Remove defense buff
	if mounted_player != null and mounted_player.has_method("remove_defense_modifier"):
		mounted_player.call("remove_defense_modifier", "mech_suit")

## Public API

func get_stomp_radius() -> float:
	"""Get the radius of the stomp ability"""
	return stomp_radius

func get_stomp_damage() -> int:
	"""Get the damage of the stomp ability"""
	return stomp_damage

func is_stomp_animation_playing() -> bool:
	"""Check if stomp animation is currently playing"""
	return is_stomping
