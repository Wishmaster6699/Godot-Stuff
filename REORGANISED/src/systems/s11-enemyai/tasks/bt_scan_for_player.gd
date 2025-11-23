# Godot 4.5 | GDScript 4.5
# System: S11 - Enemy AI System
# LimboAI Behavior Tree Action: Scan for player in detection range

extends BTAction

class_name BTScanForPlayer

## Scan for player in detection range and set as target
## Returns SUCCESS if player found, FAILURE otherwise

## Enemy node reference (from blackboard)
@export var enemy_var: StringName = &"enemy"

## Target variable to store detected player (from blackboard)
@export var target_var: StringName = &"target"


func _tick(delta: float) -> int:
	var enemy: Node = blackboard.get_var(enemy_var, null)

	if enemy == null or not is_instance_valid(enemy):
		return FAILURE

	# Scan for player using private method
	if not enemy.has_method("_find_player_in_range"):
		return FAILURE

	var detected_player: Node2D = enemy._find_player_in_range()

	if detected_player:
		# Set target
		if enemy.has_method("set_target"):
			enemy.set_target(detected_player)

		# Update blackboard
		blackboard.set_var(target_var, detected_player)

		return SUCCESS

	return FAILURE
