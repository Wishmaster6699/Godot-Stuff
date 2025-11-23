# Godot 4.5 | GDScript 4.5
# System: S11 - Enemy AI System
# LimboAI Behavior Tree Action: Retreat from player

extends BTAction

class_name BTRetreat

## Retreat away from the current target
## Returns RUNNING while retreating, SUCCESS when HP recovered or safe

## Enemy node reference (from blackboard)
@export var enemy_var: StringName = &"enemy"

## Retreat speed multiplier
@export var speed_multiplier: float = 1.3


func _tick(delta: float) -> int:
	var enemy: Node = blackboard.get_var(enemy_var, null)

	if enemy == null or not is_instance_valid(enemy):
		return FAILURE

	# Check if still should retreat
	if enemy.has_method("should_retreat") and not enemy.should_retreat():
		# HP recovered, stop retreating
		return SUCCESS

	# Check if target exists
	var target: Node = enemy.get("target")
	if target == null or not is_instance_valid(target):
		# No threat, stop retreating
		return SUCCESS

	# Move away from target
	if not enemy.has_method("get_direction_away_from_target"):
		return FAILURE

	if not enemy.has_method("move_in_direction"):
		return FAILURE

	var direction: Vector2 = enemy.get_direction_away_from_target()
	enemy.move_in_direction(direction, speed_multiplier)

	# Update AI state if method exists
	if enemy.has_method("change_state"):
		var AIState: Variant = enemy.get("AIState")
		if AIState != null:
			enemy.change_state(AIState.RETREAT)

	return RUNNING
