# Godot 4.5 | GDScript 4.5
# System: S11 - Enemy AI System
# LimboAI Behavior Tree Condition: Check if should retreat

extends BTCondition

class_name BTCheckShouldRetreat

## Check if the enemy should retreat (low HP)
## Returns SUCCESS if should retreat, FAILURE otherwise

## Enemy node reference (from blackboard)
@export var enemy_var: StringName = &"enemy"


func _tick(delta: float) -> int:
	var enemy: Node = blackboard.get_var(enemy_var, null)

	if enemy == null or not is_instance_valid(enemy):
		return FAILURE

	# Check if enemy has should_retreat method
	if not enemy.has_method("should_retreat"):
		return FAILURE

	# Check retreat condition
	if enemy.should_retreat():
		return SUCCESS

	return FAILURE
