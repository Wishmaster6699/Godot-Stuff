# Godot 4.5 | GDScript 4.5
# System: S11 - Enemy AI System
# LimboAI Behavior Tree Condition: Check if player is detected

extends BTCondition

class_name BTCheckPlayerDetected

## Check if the enemy has detected a player within detection range
## Returns SUCCESS if player detected, FAILURE otherwise

## Enemy node reference (from blackboard)
@export var enemy_var: StringName = &"enemy"

## Target variable to store detected player (from blackboard)
@export var target_var: StringName = &"target"


func _tick(delta: float) -> int:
	var enemy: Node = blackboard.get_var(enemy_var, null)

	if enemy == null or not is_instance_valid(enemy):
		return FAILURE

	# Check if enemy has is_player_detected method
	if not enemy.has_method("is_player_detected"):
		return FAILURE

	# Check detection
	if enemy.is_player_detected():
		# Update target in blackboard
		var current_target: Node = enemy.get("target")
		if current_target:
			blackboard.set_var(target_var, current_target)
		return SUCCESS

	return FAILURE
