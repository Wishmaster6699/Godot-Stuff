# Godot 4.5 | GDScript 4.5
# System: S11 - Enemy AI System
# LimboAI Behavior Tree Action: Chase the player

extends BTAction

class_name BTChasePlayer

## Chase the current target (player)
## Returns RUNNING while chasing, SUCCESS when in attack range

## Enemy node reference (from blackboard)
@export var enemy_var: StringName = &"enemy"

## Chase speed multiplier
@export var speed_multiplier: float = 1.5


func _tick(delta: float) -> int:
	var enemy: Node = blackboard.get_var(enemy_var, null)

	if enemy == null or not is_instance_valid(enemy):
		return FAILURE

	# Check if target exists
	var target: Node = enemy.get("target")
	if target == null or not is_instance_valid(target):
		return FAILURE

	# Check if in attack range
	if enemy.has_method("is_in_attack_range") and enemy.is_in_attack_range():
		return SUCCESS

	# Move toward target
	if not enemy.has_method("get_direction_to_target"):
		return FAILURE

	if not enemy.has_method("move_in_direction"):
		return FAILURE

	var direction: Vector2 = enemy.get_direction_to_target()
	enemy.move_in_direction(direction, speed_multiplier)

	# Update AI state if method exists
	if enemy.has_method("change_state"):
		var AIState: Variant = enemy.get("AIState")
		if AIState != null:
			enemy.change_state(AIState.CHASE)

	return RUNNING
