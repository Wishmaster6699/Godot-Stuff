# Godot 4.5 | GDScript 4.5
# System: S11 - Enemy AI System
# LimboAI Behavior Tree Action: Attack the player with telegraph

extends BTAction

class_name BTAttackPlayer

## Attack the current target with telegraphed warning
## Returns RUNNING while telegraphing, SUCCESS when attack completes

## Enemy node reference (from blackboard)
@export var enemy_var: StringName = &"enemy"

## Internal state tracking
var is_attacking: bool = false


func _tick(delta: float) -> int:
	var enemy: Node = blackboard.get_var(enemy_var, null)

	if enemy == null or not is_instance_valid(enemy):
		is_attacking = false
		return FAILURE

	# Check if target exists
	var target: Node = enemy.get("target")
	if target == null or not is_instance_valid(target):
		is_attacking = false
		return FAILURE

	# Check if not in attack range anymore
	if enemy.has_method("is_in_attack_range") and not enemy.is_in_attack_range():
		is_attacking = false
		return FAILURE

	# Start telegraph if not already attacking
	if not is_attacking:
		if enemy.has_method("start_attack_telegraph"):
			enemy.start_attack_telegraph()
			is_attacking = true

	# Check if still telegraphing
	var is_telegraphing: bool = enemy.get("is_telegraphing")
	if is_telegraphing:
		# Update AI state if method exists
		if enemy.has_method("change_state"):
			var AIState: Variant = enemy.get("AIState")
			if AIState != null:
				enemy.change_state(AIState.ATTACK)

		return RUNNING

	# Attack completed
	is_attacking = false
	return SUCCESS


## Reset state when task is exited
func _exit() -> void:
	is_attacking = false
