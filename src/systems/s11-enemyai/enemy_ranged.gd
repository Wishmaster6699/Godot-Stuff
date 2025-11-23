# Godot 4.5 | GDScript 4.5
# System: S11 - Enemy AI System
# Enemy Type: Ranged
#
# Ranged enemies keep distance from the player, have longer attack and detection range,
# and prefer to attack from afar (projectile attacks in future systems).

extends EnemyBase

class_name EnemyRanged


func _ready() -> void:
	# Set enemy type before calling super._ready()
	enemy_type = EnemyType.RANGED

	super._ready()

	# Additional ranged-specific initialization
	_setup_ranged_stats()


func _setup_ranged_stats() -> void:
	# Load type-specific stats from config
	var type_config: Dictionary = ai_config.get("enemy_types", {}).get("ranged", {})

	if not type_config.is_empty():
		attack_range = type_config.get("attack_range", 150.0)
		detection_range = type_config.get("detection_range", 250.0)
		move_speed = type_config.get("move_speed", 90.0)

	# Visual distinction (can be overridden in scene)
	modulate = Color(0.5, 1.0, 0.5)  # Greenish tint
