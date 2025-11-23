# Godot 4.5 | GDScript 4.5
# System: S11 - Enemy AI System
# LimboAI Behavior Tree Condition: Check if target is in attack range

extends BTCondition

class_name BTCheckInAttackRange

## Check if the current target is within attack range
## Returns SUCCESS if in range, FAILURE otherwise

## Enemy node reference (from blackboard)
@export var enemy_var: StringName = &"enemy"


func _tick(delta: float) -> int:
	var enemy: Node = blackboard.get_var(enemy_var, null)

	if enemy == null or not is_instance_valid(enemy):
		return FAILURE

	# Check if enemy has is_in_attack_range method
	if not enemy.has_method("is_in_attack_range"):
		return FAILURE

	# Check attack range
	if enemy.is_in_attack_range():
		return SUCCESS

	return FAILURE
