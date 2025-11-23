# Godot 4.5 | GDScript 4.5
# System: S11 - Enemy AI System
# LimboAI Behavior Tree Action: Move to patrol waypoint

extends BTAction

class_name BTPatrolMove

## Move enemy toward current patrol waypoint
## Returns RUNNING while moving, SUCCESS when reached

## Enemy node reference (from blackboard)
@export var enemy_var: StringName = &"enemy"


func _tick(delta: float) -> int:
	var enemy: Node = blackboard.get_var(enemy_var, null)

	if enemy == null or not is_instance_valid(enemy):
		return FAILURE

	# Check if enemy has patrol methods
	if not enemy.has_method("is_at_patrol_target"):
		return FAILURE

	if not enemy.has_method("get_direction_to_patrol"):
		return FAILURE

	if not enemy.has_method("move_in_direction"):
		return FAILURE

	# Check if reached patrol target
	if enemy.is_at_patrol_target():
		# Pick new patrol target if method exists
		if enemy.has_method("_pick_new_patrol_target"):
			enemy._pick_new_patrol_target()
		return SUCCESS

	# Move toward patrol target
	var direction: Vector2 = enemy.get_direction_to_patrol()
	enemy.move_in_direction(direction, 1.0)

	return RUNNING
