# Godot 4.5 | GDScript 4.5
# System: S11 - Enemy AI System
# Enemy Type: Aggressive
#
# Aggressive enemies always chase, have low retreat threshold, and deal high damage.
# They are fast and relentless, prioritizing offense over defense.

extends EnemyBase

class_name EnemyAggressive


func _ready() -> void:
	# Set enemy type before calling super._ready()
	enemy_type = EnemyType.AGGRESSIVE

	super._ready()

	# Additional aggressive-specific initialization
	_setup_aggressive_stats()


func _setup_aggressive_stats() -> void:
	# Load type-specific stats from config
	var type_config: Dictionary = ai_config.get("enemy_types", {}).get("aggressive", {})

	if not type_config.is_empty():
		retreat_hp_threshold = type_config.get("retreat_hp_threshold", 0.1)
		chase_speed_multiplier = type_config.get("chase_speed_multiplier", 1.7)
		attack_range = type_config.get("attack_range", 80.0)

	# Visual distinction (can be overridden in scene)
	modulate = Color(1.0, 0.5, 0.5)  # Reddish tint
