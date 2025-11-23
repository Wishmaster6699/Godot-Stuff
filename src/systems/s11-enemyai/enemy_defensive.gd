# Godot 4.5 | GDScript 4.5
# System: S11 - Enemy AI System
# Enemy Type: Defensive
#
# Defensive enemies have high retreat threshold, increased defense stats,
# and prioritize survival over aggression.

extends EnemyBase

class_name EnemyDefensive


func _ready() -> void:
	# Set enemy type before calling super._ready()
	enemy_type = EnemyType.DEFENSIVE

	super._ready()

	# Additional defensive-specific initialization
	_setup_defensive_stats()


func _setup_defensive_stats() -> void:
	# Load type-specific stats from config
	var type_config: Dictionary = ai_config.get("enemy_types", {}).get("defensive", {})

	if not type_config.is_empty():
		retreat_hp_threshold = type_config.get("retreat_hp_threshold", 0.4)
		move_speed = type_config.get("move_speed", 80.0)

		# Increase defensive stats
		var defense_bonus: int = type_config.get("defense_bonus", 5)
		var special_defense_bonus: int = type_config.get("special_defense_bonus", 5)
		defense += defense_bonus
		special_defense += special_defense_bonus

	# Visual distinction (can be overridden in scene)
	modulate = Color(0.5, 0.5, 1.0)  # Bluish tint
