# Godot 4.5 | GDScript 4.5
# System: S11 - Enemy AI System
# Enemy Type: Swarm
#
# Swarm enemies have lower HP but are fast and call nearby allies when damaged.
# They work best in groups and overwhelm with numbers.

extends EnemyBase

class_name EnemySwarm


func _ready() -> void:
	# Set enemy type before calling super._ready()
	enemy_type = EnemyType.SWARM

	super._ready()

	# Additional swarm-specific initialization
	_setup_swarm_stats()


func _setup_swarm_stats() -> void:
	# Load type-specific stats from config
	var type_config: Dictionary = ai_config.get("enemy_types", {}).get("swarm", {})

	if not type_config.is_empty():
		# Reduce HP
		var hp_multiplier: float = type_config.get("hp_multiplier", 0.7)
		max_hp = int(max_hp * hp_multiplier)
		current_hp = max_hp

		# Increase speed
		move_speed = type_config.get("move_speed", 120.0)
		chase_speed_multiplier = type_config.get("chase_speed_multiplier", 1.6)

	# Visual distinction (can be overridden in scene)
	modulate = Color(1.0, 1.0, 0.5)  # Yellowish tint

	# Slightly smaller scale to represent weaker individual unit
	scale = Vector2(0.8, 0.8)
